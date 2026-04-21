import 'package:shared_preferences/shared_preferences.dart';

class ReminderSettings {
  final bool masterEnabled;
  final bool engineRunning;

  final bool quranEnabled;
  final bool hadithEnabled;
  final bool dhikrEnabled;
  final bool duaEnabled;

  final bool quranWardEnabled;
  final bool fridaySunnahEnabled;
  final bool morningAzkarEnabled;
  final bool eveningAzkarEnabled;
  final bool hourlyGeneralEnabled;

  final int totalSent;

  ReminderSettings({
    required this.masterEnabled,
    required this.engineRunning,
    required this.quranEnabled,
    required this.hadithEnabled,
    required this.dhikrEnabled,
    required this.duaEnabled,
    required this.quranWardEnabled,
    required this.fridaySunnahEnabled,
    required this.morningAzkarEnabled,
    required this.eveningAzkarEnabled,
    required this.hourlyGeneralEnabled,
    required this.totalSent,
  });

  static const String masterEnabledKey = 'notifications_enabled';
  static const String engineRunningKey = 'azkar_engine_running';

  static const String quranEnabledKey = 'azkar_quran';
  static const String hadithEnabledKey = 'azkar_hadith';
  static const String dhikrEnabledKey = 'azkar_dhikr';
  static const String duaEnabledKey = 'azkar_dua';

  static const String quranWardEnabledKey = 'quran_daily_ward';
  static const String fridaySunnahEnabledKey = 'friday_sunnah_enabled';
  static const String morningAzkarEnabledKey = 'morning_azkar_enabled';
  static const String eveningAzkarEnabledKey = 'evening_azkar_enabled';
  static const String hourlyGeneralEnabledKey = 'hourly_general_enabled';

  static const String totalSentKey = 'azkar_total_sent';

  static Future<ReminderSettings> load() async {
    final prefs = await SharedPreferences.getInstance();

    return ReminderSettings(
      masterEnabled: prefs.getBool(masterEnabledKey) ?? true,
      engineRunning: prefs.getBool(engineRunningKey) ?? false,
      quranEnabled: prefs.getBool(quranEnabledKey) ?? true,
      hadithEnabled: prefs.getBool(hadithEnabledKey) ?? true,
      dhikrEnabled: prefs.getBool(dhikrEnabledKey) ?? true,
      duaEnabled: prefs.getBool(duaEnabledKey) ?? true,
      quranWardEnabled: prefs.getBool(quranWardEnabledKey) ?? true,
      fridaySunnahEnabled: prefs.getBool(fridaySunnahEnabledKey) ?? true,
      morningAzkarEnabled: prefs.getBool(morningAzkarEnabledKey) ?? true,
      eveningAzkarEnabled: prefs.getBool(eveningAzkarEnabledKey) ?? true,
      hourlyGeneralEnabled: prefs.getBool(hourlyGeneralEnabledKey) ?? true,
      totalSent: prefs.getInt(totalSentKey) ?? 0,
    );
  }

  static Future<void> ensureDefaults() async {
    final prefs = await SharedPreferences.getInstance();

    Future<void> setBoolIfMissing(String key, bool value) async {
      if (!prefs.containsKey(key)) {
        await prefs.setBool(key, value);
      }
    }

    Future<void> setIntIfMissing(String key, int value) async {
      if (!prefs.containsKey(key)) {
        await prefs.setInt(key, value);
      }
    }

    await setBoolIfMissing(masterEnabledKey, true);
    await setBoolIfMissing(engineRunningKey, false);

    await setBoolIfMissing(quranEnabledKey, true);
    await setBoolIfMissing(hadithEnabledKey, true);
    await setBoolIfMissing(dhikrEnabledKey, true);
    await setBoolIfMissing(duaEnabledKey, true);

    await setBoolIfMissing(quranWardEnabledKey, true);
    await setBoolIfMissing(fridaySunnahEnabledKey, true);
    await setBoolIfMissing(morningAzkarEnabledKey, true);
    await setBoolIfMissing(eveningAzkarEnabledKey, true);
    await setBoolIfMissing(hourlyGeneralEnabledKey, true);

    await setIntIfMissing(totalSentKey, 0);
  }

  static Future<void> incrementSent() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(totalSentKey) ?? 0;
    await prefs.setInt(totalSentKey, current + 1);
  }
}