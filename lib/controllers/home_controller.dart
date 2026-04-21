import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import '../services/app_prefs_service.dart';
import '../services/stats_service.dart';
import '../services/user_service.dart';
import '../services/reminder_engine.dart';

enum HomeVisualState { fajr, sunset, night, fridayNight, ramadan }

class SacredPoint {
  final String label;
  final DateTime? time;
  final bool isPassed;
  final bool isNext;

  SacredPoint({
    required this.label,
    required this.time,
    required this.isPassed,
    required this.isNext,
  });
}

class HomeController extends ChangeNotifier {
  int todayZikrCount = 0;
  int streakCount = 0;
  String userName = "عابد لله";
  String userLevel = "مبتدئ";
  String userId = "ID-USER";
  String bestTime = "بعد العصر";

  String nextPrayerName = "الصلاة";
  String nextPrayerCountdown = "--:--";
  double prayerProgress = 0.0;
  double todayProgress = 0.0;

  String hijriDay = "";
  String hijriMonth = "";
  String gregorianText = "";
  String hijriMilestone = "رحلة إيمانية يومية";
  String hijriText = "";

  final List<String> insights = [];
  int _insightIndex = 0;
  String currentInsight = "نور يومك يبدأ من ذكرٍ صادق";

  List<SacredPoint> sacredTimeline = [];
  List<int> weeklyHeatmap = [2, 5, 3, 7, 4, 8, 6];

  String sessionTitle = "جلسة هادئة";
  String sessionSubtitle = "ابدأ باستغفار خفيف مع تنفس هادئ";
  IconData sessionIcon = Icons.self_improvement_rounded;

  String dailyNameTitle = "الرحمن";
  String dailyNameMeaning = "واسع الرحمة بعباده";
  String dailyNameAction = "أظهر الرحمة اليوم في كلمة ولطف ومعاملة";

  double qiblaAngle = 0.0;

  bool isFridayNight = false;
  bool isRamadan = false;

  String selectedProfileSymbolKey = "mosque";
  String drawerMessage = "اجعل للذكر مكانًا خفيفًا وثابتًا في يومك، فالقليل المستمر نور.";

  bool notificationsEnabled = true;
  bool backupEnabled = false;
  bool privacyLocationEnabled = true;
  bool largeTextEnabled = false;
  bool showGlassEffects = true;

  bool isAdmin = false;
  StreamSubscription<User?>? _authSubscription;
  Timer? _heartbeatTimer;

  IconData get selectedProfileSymbol {
    switch (selectedProfileSymbolKey) {
      case "moon": return Icons.nights_stay_outlined;
      case "quran": return Icons.menu_book_rounded;
      case "mosque": return Icons.mosque_outlined;
      case "star": return Icons.auto_awesome_outlined;
      case "light": return Icons.light_mode_outlined;
      case "dua": return Icons.pan_tool_alt_outlined;
      case "seal": return Icons.workspace_premium_outlined;
      case "compass": return Icons.explore_outlined;
      case "sun": return Icons.wb_sunny_outlined;
      case "night": return Icons.dark_mode_outlined;
      case "tasbih": return Icons.blur_circular_outlined;
      case "peace": return Icons.self_improvement_outlined;
      case "energy": return Icons.local_fire_department_outlined;
      case "goal": return Icons.gps_fixed;
      case "calm": return Icons.spa_outlined;
      case "heart": return Icons.favorite_border;
      default: return Icons.auto_awesome_outlined;
    }
  }

  Timer? _prayerTimer;
  Timer? _insightTimer;
  Timer? _adminTapTimer;
  int _adminTapCount = 0;

  HomeVisualState visualState = HomeVisualState.night;

  Future<void> initialize() async {
    await _loadPrefs();
    _updateDateInfo();
    _updateSpecialModes();
    _buildDailyName();
    _buildNowSession();
    
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      checkAdminStatus();
      _startHeartbeat(); // بدء التتبع عند تسجيل الدخول
    });
    
    await checkAdminStatus();
    await refreshAll();
    _startTimers();
    _startHeartbeat();
  }

  // ميزة التتبع اللحظي: تحديث حالة الاتصال كل دقيقتين
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // تحديث فوري عند التشغيل
    _sendHeartbeat(user.uid);

    _heartbeatTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      _sendHeartbeat(user.uid);
    });
  }

  Future<void> _sendHeartbeat(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'lastSeenAt': FieldValue.serverTimestamp(),
        'isOnline': true,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Heartbeat failed: $e");
    }
  }

  Future<void> _loadPrefs() async {
    userName = await AppPrefsService.getUserName(fallback: userName);
    selectedProfileSymbolKey = await AppPrefsService.getProfileSymbolKey(fallback: selectedProfileSymbolKey);
    notificationsEnabled = await AppPrefsService.getNotificationsEnabled();
    backupEnabled = await AppPrefsService.getBackupEnabled();
    privacyLocationEnabled = await AppPrefsService.getPrivacyLocationEnabled();
    largeTextEnabled = await AppPrefsService.getLargeTextEnabled();
    showGlassEffects = await AppPrefsService.getShowGlassEffects();
  }

  Future<void> refreshAll() async {
    _updateDateInfo();
    _updateSpecialModes();
    await _refreshStats();
    await _updateNextPrayer();
    _buildInsights();
    _buildWeeklyHeatmap();
    _buildNowSession();
    _buildDailyName();
    _buildDrawerMessage();
    await checkAdminStatus();
    notifyListeners();
  }

  Future<void> checkAdminStatus() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (user.email?.toLowerCase() == "alkubise7@gmail.com") {
          isAdmin = true;
          notifyListeners();
          return;
        }
        final token = await user.getIdTokenResult();
        isAdmin = token.claims?['admin'] == true;
        notifyListeners();
      } else {
        isAdmin = false;
        notifyListeners();
      }
    } catch (_) {
      isAdmin = false;
      notifyListeners();
    }
  }

  Future<void> saveProfileData({required String name, required String symbolKey}) async {
    userName = name.isEmpty ? "عابد لله" : name;
    selectedProfileSymbolKey = symbolKey;
    await AppPrefsService.saveUserName(userName);
    await AppPrefsService.saveProfileSymbolKey(symbolKey);
    notifyListeners();
  }

  Future<void> setNotifications(bool value) async {
    notificationsEnabled = value;
    await AppPrefsService.setNotificationsEnabled(value);
    await ReminderEngine.setMasterEnabled(value);
    notifyListeners();
  }

  Future<void> setBackup(bool value) async {
    backupEnabled = value;
    await AppPrefsService.setBackupEnabled(value);
    notifyListeners();
  }

  Future<void> setPrivacyLocation(bool value) async {
    privacyLocationEnabled = value;
    await AppPrefsService.setPrivacyLocationEnabled(value);
    notifyListeners();
  }

  Future<void> setLargeText(bool value) async {
    largeTextEnabled = value;
    await AppPrefsService.setLargeTextEnabled(value);
    notifyListeners();
  }

  Future<void> setShowGlassEffects(bool value) async {
    showGlassEffects = value;
    await AppPrefsService.setShowGlassEffects(value);
    notifyListeners();
  }

  void _buildDrawerMessage() {
    if (isRamadan) { drawerMessage = "رمضان موسم النور، فاجعل وردك اليومي أقرب وألطف وأثبت."; return; }
    if (isFridayNight) { drawerMessage = "هذه ليلة الجمعة، أكثر من الصلاة على النبي واهدأ مع ذكر يسير."; return; }
    switch (visualState) {
      case HomeVisualState.fajr: drawerMessage = "بداية اليوم أنقى حين تفتتحه بذكرٍ صادق ونية هادئة."; break;
      case HomeVisualState.sunset: drawerMessage = "وقت المساء مناسب لذكر يلمّ شتات اليوم ويعيد السكينة."; break;
      case HomeVisualState.night: drawerMessage = "اختم يومك بخفة: استغفار، تسبيح، ودعاء قصير من القلب."; break;
      default: break;
    }
  }

  void _startTimers() {
    _insightTimer?.cancel();
    _prayerTimer?.cancel();
    _insightTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (insights.isEmpty) return;
      _insightIndex = (_insightIndex + 1) % insights.length;
      currentInsight = insights[_insightIndex];
      notifyListeners();
    });
    _prayerTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
      _updateSpecialModes();
      await _updateNextPrayer();
      _buildNowSession();
      notifyListeners();
    });
  }

  Future<void> _refreshStats() async {
    final stats = await StatsService.getStats();
    todayZikrCount = stats['todayCount'] ?? 0;
    streakCount = stats['streak'] ?? 0;
    userId = UserService.userId.isEmpty ? "ID-USER" : UserService.userId;
    userLevel = StatsService.getUserLevel();
    bestTime = StatsService.getBestTimePeriod();
    todayProgress = (todayZikrCount / 100).clamp(0.0, 1.0);
  }

  void _updateDateInfo() {
    final hijri = HijriCalendar.now();
    final now = DateTime.now();
    hijriDay = '${hijri.hDay}';
    hijriMonth = hijri.getLongMonthName();
    gregorianText = '${now.day}/${now.month}/${now.year}';
    hijriText = '${hijri.hDay} ${hijri.getLongMonthName()}';
    if (hijri.hDay == 1) hijriMilestone = "بداية شهر هجري جديد";
    else if (hijri.hDay == 15) hijriMilestone = "منتصف الشهر الهجري";
    else if (hijri.hDay >= 27) hijriMilestone = "أيام ختامية مباركة";
    else hijriMilestone = "يوم جديد لزيادة القرب";
  }

  void _updateSpecialModes() {
    final now = DateTime.now();
    final hijri = HijriCalendar.now();
    isFridayNight = now.weekday == DateTime.thursday && now.hour >= 18;
    isRamadan = hijri.hMonth == 9;
    if (isRamadan) { visualState = HomeVisualState.ramadan; return; }
    if (isFridayNight) { visualState = HomeVisualState.fridayNight; return; }
  }

  Future<Position?> _getSafePosition() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return null;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return null;
    return Geolocator.getCurrentPosition();
  }

  Future<void> _updateNextPrayer() async {
    try {
      final pos = await _getSafePosition();
      if (pos == null) {
        nextPrayerName = "الصلاة"; nextPrayerCountdown = "فعّل الموقع"; prayerProgress = 0.0; sacredTimeline = []; qiblaAngle = 0.0;
        if (!isRamadan && !isFridayNight) _updateVisualStateByHour(DateTime.now().hour);
        return;
      }
      final now = DateTime.now();
      final coordinates = Coordinates(pos.latitude, pos.longitude);
      final params = CalculationMethod.karachi.getParameters();
      var prayerTimes = PrayerTimes.today(coordinates, params);
      final qibla = Qibla(coordinates);
      qiblaAngle = qibla.direction;
      var next = prayerTimes.nextPrayer();
      var nextTime = prayerTimes.timeForPrayer(next);
      if (next == Prayer.none || nextTime == null || nextTime.isBefore(now)) {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final tomorrowPrayerTimes = PrayerTimes(coordinates, DateComponents(tomorrow.year, tomorrow.month, tomorrow.day), params);
        next = Prayer.fajr; nextTime = tomorrowPrayerTimes.fajr;
      }
      if (nextTime == null) return;
      nextPrayerName = _prayerNameArabic(next.name);
      final diff = nextTime.difference(now);
      final h = diff.inHours; final m = diff.inMinutes % 60;
      nextPrayerCountdown = h > 0 ? "$nextPrayerName بعد $h س و $m د" : "$nextPrayerName بعد $m دقيقة";
      final ordered = [Prayer.fajr, Prayer.sunrise, Prayer.dhuhr, Prayer.asr, Prayer.maghrib, Prayer.isha];
      DateTime? previousTime;
      for (var p in ordered) { final t = prayerTimes.timeForPrayer(p); if (t != null && t.isBefore(now)) previousTime = t; }
      if (previousTime != null) {
        final total = nextTime.difference(previousTime).inMinutes;
        final passed = now.difference(previousTime).inMinutes;
        if (total > 0) prayerProgress = (passed / total).clamp(0.0, 1.0);
      }
      sacredTimeline = ordered.map((prayer) {
        final t = prayerTimes.timeForPrayer(prayer);
        return SacredPoint(label: _prayerNameArabic(prayer.name), time: t, isPassed: t != null && t.isBefore(now), isNext: prayer == next);
      }).toList();
      if (!isRamadan && !isFridayNight) _updateVisualState(next);
    } catch (e) {
      nextPrayerCountdown = "خطأ في الحساب";
    }
  }

  void _buildInsights() {
    insights..clear()..addAll([
      "🏆 سلسلة $streakCount يوماً", "✨ أكملت ${(todayProgress * 100).round()}% من هدف اليوم",
      "📖 افتح المصحف الآن لدقيقة واحدة على الأقل",
      if (isFridayNight) "🌙 هذه ليلة الجمعة، أكثر من الصلاة على النبي",
      if (isRamadan) "🕌 رمضان حاضر، اجعل الشاشة أكثر نورًا بالذكر",
    ]);
    currentInsight = insights.isNotEmpty ? insights.first : "نور يومك بذكر الله";
  }

  void _buildWeeklyHeatmap() {
    final base = (todayZikrCount / 12).round().clamp(1, 10);
    weeklyHeatmap = List.generate(7, (i) => (base + i % 3).clamp(0, 10));
  }

  void _buildNowSession() {
    final hour = DateTime.now().hour;
    if (isRamadan) { sessionTitle = "جلسة رمضانية"; sessionIcon = Icons.nightlight_round; return; }
    if (isFridayNight) { sessionTitle = "ليلة الجمعة"; sessionIcon = Icons.auto_awesome_rounded; return; }
    if (hour >= 4 && hour <= 7) { sessionTitle = "جلسة الفجر"; sessionIcon = Icons.wb_sunny_rounded; }
    else if (hour >= 17 && hour <= 19) { sessionTitle = "جلسة المساء"; sessionIcon = Icons.nights_stay_rounded; }
    else { sessionTitle = "جلسة هادئة"; sessionIcon = Icons.self_improvement_rounded; }
  }

  void _buildDailyName() {
    final names = [
      {'title': 'الرحمن', 'meaning': 'واسع الرحمة بعباده', 'action': 'أظهر الرحمة اليوم'},
      {'title': 'اللطيف', 'meaning': 'البر بعباده بلطفه', 'action': 'اختر لطفًا صغيرًا اليوم'},
    ];
    final index = DateTime.now().day % names.length;
    dailyNameTitle = names[index]['title']!;
    dailyNameMeaning = names[index]['meaning']!;
    dailyNameAction = names[index]['action']!;
  }

  void _updateVisualState(Prayer prayer) {
    if (prayer == Prayer.fajr || prayer == Prayer.sunrise) visualState = HomeVisualState.fajr;
    else if (prayer == Prayer.maghrib) visualState = HomeVisualState.sunset;
    else visualState = HomeVisualState.night;
  }

  void _updateVisualStateByHour(int hour) {
    if (hour >= 4 && hour <= 7) visualState = HomeVisualState.fajr;
    else if (hour >= 17 && hour <= 19) visualState = HomeVisualState.sunset;
    else visualState = HomeVisualState.night;
  }

  String _prayerNameArabic(String name) {
    switch (name) {
      case 'fajr': return 'الفجر'; case 'sunrise': return 'الشروق';
      case 'dhuhr': return 'الظهر'; case 'asr': return 'العصر';
      case 'maghrib': return 'المغرب'; case 'isha': return 'العشاء';
      default: return 'الصلاة';
    }
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    _authSubscription?.cancel();
    _prayerTimer?.cancel();
    _insightTimer?.cancel();
    _adminTapTimer?.cancel();
    super.dispose();
  }
}
