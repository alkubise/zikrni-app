import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_colors.dart';
import '../controllers/home_controller.dart';
import '../core/ui/app_layout.dart';
import '../services/notification_service.dart';
import '../services/reminder_engine.dart';
import '../services/theme_service.dart';

class AzkarScreen extends StatefulWidget {
  const AzkarScreen({super.key});

  @override
  State<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends State<AzkarScreen>
    with WidgetsBindingObserver {
  bool quran = true;
  bool hadith = true;
  bool dhikr = true;
  bool dua = true;

  bool fridayEnabled = true;
  bool morningEnabled = true;
  bool eveningEnabled = true;
  bool quranWardEnabled = true;
  bool hourlyGeneralEnabled = true;

  bool isRunning = false;
  bool masterEnabled = true;
  int totalSent = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadAppState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadAppState() async {
    try {
      await ReminderEngine.initialize();
      final prefs = await SharedPreferences.getInstance();

      if (!mounted) return;

      setState(() {
        quran = prefs.getBool(ReminderEngine.azkarQuranKey) ?? true;
        hadith = prefs.getBool(ReminderEngine.azkarHadithKey) ?? true;
        dhikr = prefs.getBool(ReminderEngine.azkarDhikrKey) ?? true;
        dua = prefs.getBool(ReminderEngine.azkarDuaKey) ?? true;

        fridayEnabled = prefs.getBool(ReminderEngine.azkarFridayKey) ?? true;
        morningEnabled = prefs.getBool(ReminderEngine.azkarMorningKey) ?? true;
        eveningEnabled = prefs.getBool(ReminderEngine.azkarEveningKey) ?? true;
        quranWardEnabled =
            prefs.getBool(ReminderEngine.quranDailyWardKey) ?? true;
        hourlyGeneralEnabled =
            prefs.getBool(ReminderEngine.hourlyGeneralKey) ?? true;

        isRunning = prefs.getBool(ReminderEngine.azkarRunningKey) ?? false;
        masterEnabled =
            prefs.getBool(ReminderEngine.notificationsEnabledKey) ?? true;
        totalSent = prefs.getInt(ReminderEngine.azkarTotalSentKey) ?? 0;

        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<void> _persistSettings() async {
    await ReminderEngine.saveSettings(
      quran: quran,
      hadith: hadith,
      dhikr: dhikr,
      dua: dua,
      fridayEnabled: fridayEnabled,
      running: isRunning,
      morningEnabled: morningEnabled,
      eveningEnabled: eveningEnabled,
      quranWardEnabled: quranWardEnabled,
      hourlyGeneralEnabled: hourlyGeneralEnabled,
    );
  }

  Future<void> _startLogic() async {
    try {
      final granted = await NotificationService.requestPermission();
      if (!granted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'يرجى تفعيل صلاحية الإشعارات أولاً',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
          ),
        );
        return;
      }

      setState(() => isRunning = true);
      await _persistSettings();

      final homeController =
      Provider.of<HomeController>(context, listen: false);

      if (!homeController.notificationsEnabled) {
        await homeController.setNotifications(true);
      } else {
        await ReminderEngine.start();
      }

      await ReminderEngine.sendInstantTestNow();
      totalSent = await ReminderEngine.totalSent();

      if (!mounted) return;
      setState(() {});
      HapticFeedback.mediumImpact();
    } catch (e) {
      debugPrint('Azkar start error: $e');
      if (!mounted) return;
      setState(() => isRunning = false);
    }
  }

  Future<void> _stopLogic() async {
    await ReminderEngine.stopAll();

    if (!mounted) return;

    setState(() => isRunning = false);
    await _persistSettings();
    HapticFeedback.mediumImpact();
  }

  Future<void> _toggleContent({
    required String type,
    required bool value,
  }) async {
    setState(() {
      switch (type) {
        case 'quran':
          quran = value;
          break;
        case 'hadith':
          hadith = value;
          break;
        case 'dhikr':
          dhikr = value;
          break;
        case 'dua':
          dua = value;
          break;
        case 'morning':
          morningEnabled = value;
          break;
        case 'evening':
          eveningEnabled = value;
          break;
        case 'quranWard':
          quranWardEnabled = value;
          break;
        case 'hourly':
          hourlyGeneralEnabled = value;
          break;
        case 'friday':
          fridayEnabled = value;
          break;
      }
    });

    await _persistSettings();
    await ReminderEngine.restartIfRunning();
  }

  @override
  Widget build(BuildContext context) {
    final layout = AppLayout(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              ThemeService.instance.backgroundImage,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(color: Colors.black.withOpacity(0.82)),
            ),
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            )
          else
            SafeArea(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: layout.scale(20)),
                children: [
                  _buildHeader(layout),
                  const SizedBox(height: 12),
                  _buildHeroCore(),
                  const SizedBox(height: 20),
                  if (!masterEnabled) _buildMasterDisabledWarning(),
                  const SizedBox(height: 18),
                  _buildSectionLabel('أنواع المحتوى'),
                  _buildOrbitalGrid(layout),
                  const SizedBox(height: 24),
                  _buildSectionLabel('خريطة التذكيرات'),
                  _buildTimelineCard(),
                  const SizedBox(height: 28),
                  _buildMasterButton(),
                  const SizedBox(height: 36),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLayout layout) {
    return Padding(
      padding: EdgeInsets.only(top: layout.scale(12), bottom: layout.scale(8)),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.05),
            ),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.gold,
              size: 20,
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'مركز الأذكار الذكي',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildHeroCore() {
    final active = isRunning && masterEnabled;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.06),
            AppColors.gold.withOpacity(0.05),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        border: Border.all(color: AppColors.gold.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: active
                    ? [AppColors.gold, const Color(0xFFF3D46A)]
                    : [Colors.white24, Colors.white10],
              ),
              boxShadow: [
                BoxShadow(
                  color: active
                      ? AppColors.gold.withOpacity(0.32)
                      : Colors.transparent,
                  blurRadius: 24,
                  spreadRadius: 4,
                )
              ],
            ),
            child: Icon(
              active ? Icons.auto_awesome : Icons.power_settings_new_rounded,
              color: active ? Colors.black : Colors.white54,
              size: 34,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            active ? 'المحرك يعمل الآن' : 'المحرك متوقف',
            style: TextStyle(
              color: active ? Colors.white : Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'ذكر متنوع كل ساعة + ورد قرآني بعد كل صلاة + صباح ومساء + سنن الجمعة',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontFamily: 'Cairo',
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.notifications_active_rounded,
                    color: AppColors.gold),
                const SizedBox(width: 10),
                Text(
                  'إجمالي التنبيهات المرسلة: $totalSent',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMasterDisabledWarning() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.red.withOpacity(0.20)),
      ),
      child: const Text(
        'الإشعارات العامة متوقفة. فعّلها من صفحة الإشعارات ليعمل النظام بالكامل.',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }

  Widget _buildOrbitalGrid(AppLayout layout) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _orbitCard(
                'آيات',
                Icons.auto_stories_rounded,
                quran,
                AppColors.gold,
                    () => _toggleContent(type: 'quran', value: !quran),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _orbitCard(
                'أحاديث',
                Icons.mosque_rounded,
                hadith,
                const Color(0xFF74C69D),
                    () => _toggleContent(type: 'hadith', value: !hadith),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _orbitCard(
                'أدعية',
                Icons.favorite_rounded,
                dua,
                const Color(0xFFE5989B),
                    () => _toggleContent(type: 'dua', value: !dua),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _orbitCard(
                'أذكار',
                Icons.auto_awesome_rounded,
                dhikr,
                const Color(0xFF90CAF9),
                    () => _toggleContent(type: 'dhikr', value: !dhikr),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _orbitCard(
                'الصباح',
                Icons.wb_sunny_rounded,
                morningEnabled,
                const Color(0xFFFFC857),
                    () => _toggleContent(type: 'morning', value: !morningEnabled),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _orbitCard(
                'المساء',
                Icons.nightlight_round,
                eveningEnabled,
                const Color(0xFF7B8CDE),
                    () => _toggleContent(type: 'evening', value: !eveningEnabled),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _orbitCard(
                'ورد قرآني',
                Icons.menu_book_rounded,
                quranWardEnabled,
                const Color(0xFFA7C957),
                    () => _toggleContent(
                  type: 'quranWard',
                  value: !quranWardEnabled,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _orbitCard(
                'كل ساعة',
                Icons.access_time_filled_rounded,
                hourlyGeneralEnabled,
                const Color(0xFFC77DFF),
                    () => _toggleContent(
                  type: 'hourly',
                  value: !hourlyGeneralEnabled,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _wideCard(
          'سنن الجمعة',
          'تذكير خاص بيوم الجمعة فقط',
          Icons.stars_rounded,
          fridayEnabled,
              () => _toggleContent(type: 'friday', value: !fridayEnabled),
        ),
      ],
    );
  }

  Widget _orbitCard(
      String title,
      IconData icon,
      bool active,
      Color glow,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: active
              ? glow.withOpacity(0.12)
              : Colors.white.withOpacity(0.025),
          border: Border.all(
            color: active ? glow.withOpacity(0.45) : Colors.white.withOpacity(0.05),
          ),
          boxShadow: active
              ? [
            BoxShadow(
              color: glow.withOpacity(0.18),
              blurRadius: 24,
              offset: const Offset(0, 10),
            )
          ]
              : [],
        ),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? glow.withOpacity(0.18) : Colors.white.withOpacity(0.04),
              ),
              child: Icon(icon, color: active ? glow : Colors.white38, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: active ? Colors.white : Colors.white60,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _wideCard(
      String title,
      String subtitle,
      IconData icon,
      bool active,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: active
              ? AppColors.gold.withOpacity(0.10)
              : Colors.white.withOpacity(0.025),
          border: Border.all(
            color: active
                ? AppColors.gold.withOpacity(0.38)
                : Colors.white.withOpacity(0.05),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: active ? AppColors.gold : Colors.white30,
              size: 24,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: active ? Colors.white : Colors.white60,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          _timelineItem('بعد الفجر بساعة', 'أذكار الصباح'),
          _timelineItem('قبل الظهر بساعة', 'أذكار الصباح'),
          _timelineItem('بعد العصر بساعة', 'أذكار المساء'),
          _timelineItem('بعد كل صلاة', 'وردك القرآني'),
          _timelineItem('كل ساعة', 'آية أو حديث أو دعاء أو ذكر'),
          _timelineItem('يوم الجمعة', 'سنن الجمعة'),
        ],
      ),
    );
  }

  Widget _timelineItem(String time, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: Text(
              time,
              style: const TextStyle(
                color: AppColors.gold,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              desc,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMasterButton() {
    return GestureDetector(
      onTap: () => isRunning ? _stopLogic() : _startLogic(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        height: 68,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: isRunning
                ? [Colors.red.shade900, Colors.red.shade700]
                : [AppColors.gold, const Color(0xFFB8860B)],
          ),
          boxShadow: [
            BoxShadow(
              color: isRunning
                  ? Colors.red.withOpacity(0.28)
                  : AppColors.gold.withOpacity(0.30),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isRunning
                    ? Icons.stop_circle_outlined
                    : Icons.play_circle_fill_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Text(
                isRunning ? 'إيقاف منظومة التذكير' : 'تفعيل منظومة التذكير',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 4),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.gold.withOpacity(0.75),
          fontSize: 13,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }
}