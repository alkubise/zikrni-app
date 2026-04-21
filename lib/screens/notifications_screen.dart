import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_colors.dart';
import '../controllers/home_controller.dart';
import '../core/ui/app_layout.dart';
import '../services/reminder_engine.dart';

class NotificationsScreen extends StatefulWidget {
  final HomeController controller;
  const NotificationsScreen({super.key, required this.controller});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool azkarEngineRunning = false;
  bool morningEnabled = true;
  bool eveningEnabled = true;
  bool quranWardEnabled = true;
  bool fridayEnabled = true;
  bool hourlyGeneralEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadReminderState();
  }

  Future<void> _loadReminderState() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;
    setState(() {
      azkarEngineRunning =
          prefs.getBool(ReminderEngine.azkarRunningKey) ?? false;
      morningEnabled = prefs.getBool(ReminderEngine.azkarMorningKey) ?? true;
      eveningEnabled = prefs.getBool(ReminderEngine.azkarEveningKey) ?? true;
      quranWardEnabled =
          prefs.getBool(ReminderEngine.quranDailyWardKey) ?? true;
      fridayEnabled = prefs.getBool(ReminderEngine.azkarFridayKey) ?? true;
      hourlyGeneralEnabled =
          prefs.getBool(ReminderEngine.hourlyGeneralKey) ?? true;
    });
  }

  Future<void> _toggleMaster(bool value) async {
    await widget.controller.setNotifications(value);
    await _loadReminderState();
  }

  Future<void> _toggleAzkarEngine(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    final quran = prefs.getBool(ReminderEngine.azkarQuranKey) ?? true;
    final hadith = prefs.getBool(ReminderEngine.azkarHadithKey) ?? true;
    final dhikr = prefs.getBool(ReminderEngine.azkarDhikrKey) ?? true;
    final dua = prefs.getBool(ReminderEngine.azkarDuaKey) ?? true;

    final friday = prefs.getBool(ReminderEngine.azkarFridayKey) ?? true;
    final morning = prefs.getBool(ReminderEngine.azkarMorningKey) ?? true;
    final evening = prefs.getBool(ReminderEngine.azkarEveningKey) ?? true;
    final quranWard =
        prefs.getBool(ReminderEngine.quranDailyWardKey) ?? true;
    final hourlyGeneral =
        prefs.getBool(ReminderEngine.hourlyGeneralKey) ?? true;

    await ReminderEngine.saveSettings(
      quran: quran,
      hadith: hadith,
      dhikr: dhikr,
      dua: dua,
      fridayEnabled: friday,
      running: value,
      morningEnabled: morning,
      eveningEnabled: evening,
      quranWardEnabled: quranWard,
      hourlyGeneralEnabled: hourlyGeneral,
    );

    if (widget.controller.notificationsEnabled && value) {
      await ReminderEngine.start();
    } else {
      await ReminderEngine.stopAll();
    }

    await _loadReminderState();
  }

  Future<void> _saveExtended({
    bool? morning,
    bool? evening,
    bool? quranWard,
    bool? friday,
    bool? hourlyGeneral,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final quran = prefs.getBool(ReminderEngine.azkarQuranKey) ?? true;
    final hadith = prefs.getBool(ReminderEngine.azkarHadithKey) ?? true;
    final dhikr = prefs.getBool(ReminderEngine.azkarDhikrKey) ?? true;
    final dua = prefs.getBool(ReminderEngine.azkarDuaKey) ?? true;
    final running = prefs.getBool(ReminderEngine.azkarRunningKey) ?? false;

    await ReminderEngine.saveSettings(
      quran: quran,
      hadith: hadith,
      dhikr: dhikr,
      dua: dua,
      fridayEnabled: friday ?? fridayEnabled,
      running: running,
      morningEnabled: morning ?? morningEnabled,
      eveningEnabled: evening ?? eveningEnabled,
      quranWardEnabled: quranWard ?? quranWardEnabled,
      hourlyGeneralEnabled: hourlyGeneral ?? hourlyGeneralEnabled,
    );

    await ReminderEngine.restartIfRunning();
    await _loadReminderState();
  }

  @override
  Widget build(BuildContext context) {
    final layout = AppLayout(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.28,
              child: Image.asset(
                'assets/images/background_night.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(color: Colors.black.withOpacity(0.82)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, layout),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: layout.scale(20)),
                    children: [
                      _buildHeaderCard(layout),
                      SizedBox(height: layout.scale(24)),

                      _buildSectionTitle('التحكم الرئيسي', layout),
                      _buildNotificationToggle(
                        title: 'إشعارات النظام العامة',
                        desc: 'تشغيل أو إيقاف جميع التنبيهات في التطبيق.',
                        value: widget.controller.notificationsEnabled,
                        onChanged: _toggleMaster,
                        icon: Icons.notifications_active_outlined,
                        layout: layout,
                      ),
                      _buildNotificationToggle(
                        title: 'محرك التذكير',
                        desc: 'تشغيل أو إيقاف جميع خدمات التذكير الذكية.',
                        value: azkarEngineRunning,
                        onChanged: widget.controller.notificationsEnabled
                            ? _toggleAzkarEngine
                            : null,
                        icon: Icons.auto_awesome_rounded,
                        layout: layout,
                      ),

                      SizedBox(height: layout.scale(24)),

                      _buildSectionTitle('التذكيرات الزمنية', layout),
                      _buildInfoCard(
                        '🌅 أذكار الصباح',
                        'بعد الفجر بساعة + قبل الظهر بساعة',
                      ),
                      _buildNotificationToggle(
                        title: 'تفعيل أذكار الصباح',
                        desc: 'إرسال أذكار الصباح في الوقتين المحددين.',
                        value: morningEnabled,
                        onChanged: (v) async => _saveExtended(morning: v),
                        icon: Icons.wb_sunny_rounded,
                        layout: layout,
                      ),

                      _buildInfoCard(
                        '🌇 أذكار المساء',
                        'بعد العصر بساعة',
                      ),
                      _buildNotificationToggle(
                        title: 'تفعيل أذكار المساء',
                        desc: 'إرسال أذكار المساء بعد صلاة العصر بساعة.',
                        value: eveningEnabled,
                        onChanged: (v) async => _saveExtended(evening: v),
                        icon: Icons.nightlight_round,
                        layout: layout,
                      ),

                      _buildInfoCard(
                        '📖 الورد القرآني',
                        'بعد كل صلاة: اقرأ عدد الصفحات الموصى بها من وردك.',
                      ),
                      _buildNotificationToggle(
                        title: 'تفعيل الورد القرآني',
                        desc: 'إرسال تذكير بالورد القرآني بعد كل صلاة.',
                        value: quranWardEnabled,
                        onChanged: (v) async => _saveExtended(quranWard: v),
                        icon: Icons.menu_book_rounded,
                        layout: layout,
                      ),

                      _buildInfoCard(
                        '✨ الذكر المتنوع',
                        'كل ساعة: آية أو حديث أو دعاء أو ذكر',
                      ),
                      _buildNotificationToggle(
                        title: 'تفعيل الذكر المتنوع كل ساعة',
                        desc: 'يرسل إشعارًا متنوعًا كل ساعة.',
                        value: hourlyGeneralEnabled,
                        onChanged: (v) async => _saveExtended(hourlyGeneral: v),
                        icon: Icons.access_time_filled_rounded,
                        layout: layout,
                      ),

                      SizedBox(height: layout.scale(24)),

                      _buildSectionTitle('الجمعة', layout),
                      _buildNotificationToggle(
                        title: 'سنن الجمعة',
                        desc: 'تذكير خاص يوم الجمعة فقط.',
                        value: fridayEnabled,
                        onChanged: (v) async => _saveExtended(friday: v),
                        icon: Icons.mosque_rounded,
                        layout: layout,
                      ),

                      SizedBox(height: layout.scale(40)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, AppLayout layout) {
    return Padding(
      padding: EdgeInsets.all(layout.scale(16)),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: layout.scale(20),
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.05),
            ),
          ),
          const Spacer(),
          Text(
            'الإشعارات والتنبيهات',
            style: TextStyle(
              color: AppColors.gold,
              fontFamily: 'Cairo',
              fontSize: layout.scale(16),
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          SizedBox(width: layout.scale(48)),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(AppLayout layout) {
    return Container(
      padding: EdgeInsets.all(layout.scale(22)),
      decoration: BoxDecoration(
        color: AppColors.gold.withOpacity(0.05),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.gold.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.notifications_active_rounded,
            color: AppColors.gold,
            size: layout.scale(42),
          ),
          SizedBox(height: layout.scale(12)),
          const Text(
            'منظومة تذكير ذكية',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
          SizedBox(height: layout.scale(6)),
          Text(
            'صباح، مساء، ورد قرآني بعد كل صلاة، ذكر متنوع كل ساعة، وسنن خاصة بيوم الجمعة.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white38,
              fontSize: 12,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, AppLayout layout) {
    return Padding(
      padding: EdgeInsets.only(bottom: layout.scale(14), right: 4),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.gold.withOpacity(0.85),
          fontSize: 14,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.025),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationToggle({
    required String title,
    required String desc,
    required bool value,
    required ValueChanged<bool>? onChanged,
    required IconData icon,
    required AppLayout layout,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.gold, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.gold,
            activeTrackColor: AppColors.gold.withOpacity(0.2),
            inactiveThumbColor: Colors.white24,
            inactiveTrackColor: Colors.white10,
          ),
        ],
      ),
    );
  }
}