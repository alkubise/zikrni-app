import 'package:shared_preferences/shared_preferences.dart';

import 'reminder_orchestrator.dart';
import 'reminder_settings.dart';
import 'smart_azkar_service.dart';

class ReminderEngine {
  ReminderEngine._();

  static const String notificationsEnabledKey =
      ReminderSettings.masterEnabledKey;
  static const String azkarQuranKey = ReminderSettings.quranEnabledKey;
  static const String azkarHadithKey = ReminderSettings.hadithEnabledKey;
  static const String azkarDhikrKey = ReminderSettings.dhikrEnabledKey;
  static const String azkarDuaKey = ReminderSettings.duaEnabledKey;

  static const String quranDailyWardKey =
      ReminderSettings.quranWardEnabledKey;
  static const String azkarFridayKey =
      ReminderSettings.fridaySunnahEnabledKey;
  static const String azkarMorningKey =
      ReminderSettings.morningAzkarEnabledKey;
  static const String azkarEveningKey =
      ReminderSettings.eveningAzkarEnabledKey;
  static const String hourlyGeneralKey =
      ReminderSettings.hourlyGeneralEnabledKey;

  static const String azkarRunningKey =
      ReminderSettings.engineRunningKey;
  static const String azkarTotalSentKey =
      ReminderSettings.totalSentKey;

  static Future<void> initialize() async {
    await ReminderOrchestrator.initialize();
  }

  static Future<void> saveSettings({
    required bool quran,
    required bool hadith,
    required bool dhikr,
    required bool dua,
    required bool fridayEnabled,
    required bool running,
    bool? morningEnabled,
    bool? eveningEnabled,
    bool? quranWardEnabled,
    bool? hourlyGeneralEnabled,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(azkarQuranKey, quran);
    await prefs.setBool(azkarHadithKey, hadith);
    await prefs.setBool(azkarDhikrKey, dhikr);
    await prefs.setBool(azkarDuaKey, dua);
    await prefs.setBool(azkarFridayKey, fridayEnabled);
    await prefs.setBool(azkarRunningKey, running);

    if (morningEnabled != null) {
      await prefs.setBool(azkarMorningKey, morningEnabled);
    }
    if (eveningEnabled != null) {
      await prefs.setBool(azkarEveningKey, eveningEnabled);
    }
    if (quranWardEnabled != null) {
      await prefs.setBool(quranDailyWardKey, quranWardEnabled);
    }
    if (hourlyGeneralEnabled != null) {
      await prefs.setBool(hourlyGeneralKey, hourlyGeneralEnabled);
    }
  }

  static Future<void> start() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(azkarRunningKey, true);
    await ReminderOrchestrator.syncAll();
  }

  static Future<void> stopAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(azkarRunningKey, false);
    await ReminderOrchestrator.cancelAllScheduled();
  }

  static Future<void> stop() async {
    await stopAll();
  }

  static Future<void> restartIfRunning() async {
    final settings = await ReminderSettings.load();
    if (settings.engineRunning && settings.masterEnabled) {
      await ReminderOrchestrator.syncAll();
    }
  }

  static Future<int> totalSent() async {
    final settings = await ReminderSettings.load();
    return settings.totalSent;
  }

  static Future<void> setMasterEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(notificationsEnabledKey, value);

    if (value) {
      await ReminderOrchestrator.syncAll();
    } else {
      await ReminderOrchestrator.cancelAllScheduled();
    }
  }

  static Future<void> sendInstantTestNow() async {
    await SmartAzkarService.sendInstantSample();
  }
}