import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/zikr_event.dart';
import 'user_service.dart';

class Badge {
  final String id;
  final String name;
  final String icon;
  final String description;
  final bool isUnlocked;

  Badge({required this.id, required this.name, required this.icon, required this.description, this.isUnlocked = false});
}

class StatsService {
  static List<ZikrEvent> _events = [];
  static late SharedPreferences _prefs;

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _keyStreak = 'stats_streak_days';
  static const String _keyLastDate = 'stats_last_active_date';
  static const String _keyDailyGoal = 'stats_daily_goal';
  static const String _keyEvents = 'stats_events_json';

  static int get streakDays => _prefs.getInt(_keyStreak) ?? 0;
  static int get dailyGoal => _prefs.getInt(_keyDailyGoal) ?? 100;
  static int get todayCount => getTodayCount();
  static int get totalCount => _events.length;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadLocalEvents();
    await _checkAndResetStreak();
  }

  static void loadFromController(List<ZikrEvent> events) {
    _events = events;
  }

  static List<Badge> getAvailableBadges() {
    final total = totalCount;
    final streak = streakDays;
    
    return [
      Badge(
        id: "early_bird",
        name: "المستيقظ باكراً",
        icon: "🌅",
        description: "قرأت أذكار الصباح قبل الشروق لمدة 7 أيام",
        isUnlocked: streak >= 7,
      ),
      Badge(
        id: "zikr_master",
        name: "سلطان الذاكرين",
        icon: "👑",
        description: "تجاوزت 10,000 ذكر كلي",
        isUnlocked: total >= 10000,
      ),
      Badge(
        id: "global_hero",
        name: "مساهم عالمي",
        icon: "🌍",
        description: "شاركت في التحدي العالمي لأول مرة",
        isUnlocked: total > 0,
      ),
    ];
  }

  static Future<void> recordZikr(ZikrEvent event) async {
    _events.add(event);
    await _saveLocalEvents();
    if (getTodayCount() == 1) await _updateStreak();
    await _saveEventToCloud(event);
    await _syncSummaryToCloud();
  }

  static int getTodayCount() {
    final now = DateTime.now();
    return _events.where((e) => e.timestamp.year == now.year && e.timestamp.month == now.month && e.timestamp.day == now.day).length;
  }

  static int getWeekCount() {
    final now = DateTime.now();
    return _events.where((e) => now.difference(e.timestamp).inDays < 7).length;
  }

  static int getMonthCount() {
    final now = DateTime.now();
    return _events.where((e) {
      return e.timestamp.month == now.month && e.timestamp.year == now.year;
    }).length;
  }

  static String getDailyRecommendation() {
    final today = getTodayCount();
    if (today == 0) return 'ابدأ الآن بـ 10 أذكار فقط';
    if (today < 30) return 'جرّب 50 ذكر الآن';
    return 'حافظ على مستواك 🔥';
  }

  static String getSpiritualStatus() {
    final total = totalCount;
    if (total < 100) return 'مبتدئ بنور الله 🌱';
    if (total < 1000) return 'ذاكر مجتهد ✨';
    return 'نوراني متصل 🌟';
  }

  static String getUserLevel() => getSpiritualStatus();
  static String getBestTimePeriod() => "الصباح ☀️";

  static Future<Map<String, int>> getStats() async {
    return {
      'todayCount': getTodayCount(),
      'total': _events.length,
      'streak': streakDays,
      'weekCount': getWeekCount(),
      'totalCount': totalCount,
    };
  }

  static Future<void> _checkAndResetStreak() async {
    final lastDateStr = _prefs.getString(_keyLastDate) ?? '';
    if (lastDateStr.isEmpty) return;
    final lastDate = DateTime.parse(lastDateStr);
    final today = DateTime.now();
    final diff = DateTime(today.year, today.month, today.day).difference(DateTime(lastDate.year, lastDate.month, lastDate.day)).inDays;
    if (diff > 1) await _prefs.setInt(_keyStreak, 0);
  }

  static Future<void> _updateStreak() async {
    final lastDateStr = _prefs.getString(_keyLastDate) ?? '';
    final today = DateTime.now();
    if (lastDateStr.isNotEmpty) {
      final lastDate = DateTime.parse(lastDateStr);
      final diff = DateTime(today.year, today.month, today.day).difference(DateTime(lastDate.year, lastDate.month, lastDate.day)).inDays;
      if (diff == 1) await _prefs.setInt(_keyStreak, streakDays + 1);
      else if (diff > 1) await _prefs.setInt(_keyStreak, 1);
    } else { await _prefs.setInt(_keyStreak, 1); }
    await _prefs.setString(_keyLastDate, today.toIso8601String());
  }

  static Future<void> _loadLocalEvents() async {
    final list = _prefs.getStringList(_keyEvents) ?? [];
    _events = list.map((e) {
      final parts = e.split('||');
      return ZikrEvent(id: parts[0], text: parts[1], source: parts[2], timestamp: DateTime.parse(parts[3]), count: int.tryParse(parts[4]) ?? 1);
    }).toList();
  }

  static Future<void> _saveLocalEvents() async {
    final list = _events.map((e) => '${e.id}||${e.text}||${e.source}||${e.timestamp.toIso8601String()}||${e.count}').toList();
    await _prefs.setStringList(_keyEvents, list);
  }

  static Future<void> _saveEventToCloud(ZikrEvent event) async {
    final uid = UserService.userId;
    if (uid.isEmpty) return;
    await _firestore.collection('users').doc(uid).collection('events').doc(event.id).set(event.toJson());
  }

  static Future<void> _syncSummaryToCloud() async {
    final uid = UserService.userId;
    if (uid.isEmpty) return;
    await _firestore.collection('users').doc(uid).set({'streakDays': streakDays, 'totalAzkar': totalCount, 'todayCount': todayCount, 'lastStatsSyncAt': DateTime.now().toIso8601String()}, SetOptions(merge: true));
  }
}
