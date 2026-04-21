import 'dart:math';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

import '../data/azkar_data.dart';
import 'notification_service.dart';
import 'reminder_settings.dart';

class SmartAzkarService {
  SmartAzkarService._();

  static const int hourlyAzkarAlarmId = 3001;
  static final Random _random = Random();

  static Future<void> scheduleHourlyAzkar() async {
    await cancelHourlyAzkar();

    await AndroidAlarmManager.periodic(
      const Duration(hours: 1),
      hourlyAzkarAlarmId,
      hourlyAzkarCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
  }

  static Future<void> cancelHourlyAzkar() async {
    await AndroidAlarmManager.cancel(hourlyAzkarAlarmId);
  }

  @pragma('vm:entry-point')
  static Future<void> hourlyAzkarCallback() async {
    await NotificationService.init();

    final settings = await ReminderSettings.load();

    if (!settings.masterEnabled || !settings.engineRunning) return;
    if (!settings.hourlyGeneralEnabled) return;

    final content = await pickGeneralContent();

    await NotificationService.showNow(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: content['title'] ?? 'ذكرني',
      body: content['body'] ?? '',
      payload: 'hourly_general_azkar',
    );

    await ReminderSettings.incrementSent();
  }

  static Future<void> sendInstantSample() async {
    final content = await pickGeneralContent();
    await NotificationService.showNow(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: content['title'] ?? 'ذكرني',
      body: content['body'] ?? '',
      payload: 'instant_general_azkar',
    );
    await ReminderSettings.incrementSent();
  }

  static Future<Map<String, String>> pickGeneralContent() async {
    final settings = await ReminderSettings.load();

    List<Map<String, String>> pool = AzkarData.data.where((item) {
      final type = item['type'] ?? '';

      if (type == 'quran' && !settings.quranEnabled) return false;
      if (type == 'hadith' && !settings.hadithEnabled) return false;
      if (type == 'dhikr' && !settings.dhikrEnabled) return false;
      if (type == 'dua' && !settings.duaEnabled) return false;

      return type == 'quran' ||
          type == 'hadith' ||
          type == 'dhikr' ||
          type == 'dua';
    }).toList();

    if (pool.isEmpty) {
      return {
        'title': 'ذكرني',
        'body': 'حان وقت الذكر 🌿',
      };
    }

    final selected = pool[_random.nextInt(pool.length)];
    final text = selected['text'] ?? '';
    final ref = selected['ref'] ?? '';

    return {
      'title': selected['title'] ?? 'ذكرني',
      'body': ref.isNotEmpty ? '$text\n$ref' : text,
    };
  }
}