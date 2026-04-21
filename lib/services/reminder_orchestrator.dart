import 'notification_scheduler_service.dart';
import 'notification_service.dart';
import 'prayer_based_reminder_service.dart';
import 'reminder_settings.dart';
import 'smart_azkar_service.dart';
import 'friday_sunnah_service.dart';

class ReminderOrchestrator {
  ReminderOrchestrator._();

  static Future<void> initialize() async {
    await ReminderSettings.ensureDefaults();
    await NotificationService.init();
    await NotificationSchedulerService.initTimezone();
  }

  static Future<void> syncAll() async {
    await initialize();

    final settings = await ReminderSettings.load();
    await cancelAllScheduled();

    if (!settings.masterEnabled) return;
    if (!settings.engineRunning) return;

    await PrayerBasedReminderService.schedulePrayerBasedReminders();

    if (settings.fridaySunnahEnabled) {
      await FridaySunnahService.scheduleFridaySunnah();
    }

    if (settings.hourlyGeneralEnabled) {
      await SmartAzkarService.scheduleHourlyAzkar();
    }
  }

  static Future<void> cancelAllScheduled() async {
    await PrayerBasedReminderService.cancelAll();
    await FridaySunnahService.cancelFridaySunnah();
    await SmartAzkarService.cancelHourlyAzkar();
  }
}