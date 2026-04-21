import 'dart:math';

import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:timezone/timezone.dart' as tz;

import '../data/azkar_data.dart';
import 'notification_service.dart';
import 'quran_completion_service.dart';
import 'reminder_settings.dart';

class PrayerBasedReminderService {
  PrayerBasedReminderService._();

  static const int morningAfterFajrId = 5001;
  static const int morningBeforeDhuhrId = 5002;
  static const int eveningAfterAsrId = 5003;

  static const int quranAfterFajrId = 5101;
  static const int quranAfterDhuhrId = 5102;
  static const int quranAfterAsrId = 5103;
  static const int quranAfterMaghribId = 5104;
  static const int quranAfterIshaId = 5105;

  static final Random _random = Random();

  static Future<Position?> _getSafePosition() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    return Geolocator.getCurrentPosition();
  }

  static Future<void> schedulePrayerBasedReminders() async {
    final settings = await ReminderSettings.load();
    final pos = await _getSafePosition();
    if (pos == null) return;

    final params = CalculationMethod.karachi.getParameters();
    final prayerTimes = PrayerTimes.today(
      Coordinates(pos.latitude, pos.longitude),
      params,
    );

    if (settings.morningAzkarEnabled) {
      await _scheduleAzkarReminder(
        id: morningAfterFajrId,
        title: '🌅 أذكار الصباح',
        body: _pickBody('morning'),
        dateTime: prayerTimes.fajr.add(const Duration(hours: 1)),
        payload: 'morning_after_fajr',
      );

      await _scheduleAzkarReminder(
        id: morningBeforeDhuhrId,
        title: '🌅 أذكار الصباح',
        body: _pickBody('morning'),
        dateTime: prayerTimes.dhuhr.subtract(const Duration(hours: 1)),
        payload: 'morning_before_dhuhr',
      );
    }

    if (settings.eveningAzkarEnabled) {
      await _scheduleAzkarReminder(
        id: eveningAfterAsrId,
        title: '🌇 أذكار المساء',
        body: _pickBody('evening'),
        dateTime: prayerTimes.asr.add(const Duration(hours: 1)),
        payload: 'evening_after_asr',
      );
    }

    if (settings.quranWardEnabled) {
      final wardBody = await _quranWardBody();

      await _scheduleAzkarReminder(
        id: quranAfterFajrId,
        title: '📖 وردك القرآني',
        body: wardBody,
        dateTime: prayerTimes.fajr.add(const Duration(minutes: 15)),
        payload: 'quran_after_fajr',
      );

      await _scheduleAzkarReminder(
        id: quranAfterDhuhrId,
        title: '📖 وردك القرآني',
        body: wardBody,
        dateTime: prayerTimes.dhuhr.add(const Duration(minutes: 15)),
        payload: 'quran_after_dhuhr',
      );

      await _scheduleAzkarReminder(
        id: quranAfterAsrId,
        title: '📖 وردك القرآني',
        body: wardBody,
        dateTime: prayerTimes.asr.add(const Duration(minutes: 15)),
        payload: 'quran_after_asr',
      );

      await _scheduleAzkarReminder(
        id: quranAfterMaghribId,
        title: '📖 وردك القرآني',
        body: wardBody,
        dateTime: prayerTimes.maghrib.add(const Duration(minutes: 15)),
        payload: 'quran_after_maghrib',
      );

      await _scheduleAzkarReminder(
        id: quranAfterIshaId,
        title: '📖 وردك القرآني',
        body: wardBody,
        dateTime: prayerTimes.isha.add(const Duration(minutes: 15)),
        payload: 'quran_after_isha',
      );
    }
  }

  static Future<void> _scheduleAzkarReminder({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
    required String payload,
  }) async {
    final now = DateTime.now();
    if (!dateTime.isAfter(now)) return;

    await NotificationService.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(dateTime, tz.local),
      payload: payload,
    );
  }

  static String _pickBody(String type) {
    final items = AzkarData.data.where((e) => e['type'] == type).toList();

    if (items.isEmpty) {
      return 'حان وقت الذكر 🌿';
    }

    final item = items[_random.nextInt(items.length)];
    final text = item['text'] ?? '';
    final ref = item['ref'] ?? '';
    return ref.isNotEmpty ? '$text\n$ref' : text;
  }

  static Future<String> _quranWardBody() async {
    final plan = await QuranCompletionService.getPlan();

    if (plan == null) {
      return 'اقرأ 4 صفحات من وردك القرآني اليوم.';
    }

    final dailyPages = QuranCompletionService.calculateDailyPages(plan.days);
    return 'اقرأ $dailyPages صفحات من وردك القرآني بدءًا من الصفحة ${plan.currentPage}.';
  }

  static Future<void> cancelAll() async {
    for (final id in [
      morningAfterFajrId,
      morningBeforeDhuhrId,
      eveningAfterAsrId,
      quranAfterFajrId,
      quranAfterDhuhrId,
      quranAfterAsrId,
      quranAfterMaghribId,
      quranAfterIshaId,
    ]) {
      await NotificationService.cancel(id);
    }
  }
}