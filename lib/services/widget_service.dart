import 'package:home_widget/home_widget.dart';
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import '../data/azkar_data.dart';
import 'dart:math';

class WidgetService {
  static const String _groupId = 'group.com.example.azkar_app'; // Replace with actual group id if needed
  static const String _androidWidgetName = 'AzkarWidgetProvider';

  static Future<void> updateWidgets() async {
    await _updateDhikrWidget();
    await _updatePrayerWidget();
  }

  static Future<void> _updateDhikrWidget() async {
    final random = Random();
    final dhikrs = AzkarData.data.where((item) => item['type'] == 'dhikr').toList();
    final selected = dhikrs[random.nextInt(dhikrs.length)];

    await HomeWidget.saveWidgetData<String>('dhikr_text', selected['text'] ?? '');
    await HomeWidget.saveWidgetData<String>('dhikr_title', selected['title'] ?? 'ذكر الساعة');
    
    await HomeWidget.updateWidget(
      name: _androidWidgetName,
      androidName: _androidWidgetName,
    );
  }

  static Future<void> _updatePrayerWidget() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
      final coordinates = Coordinates(position.latitude, position.longitude);
      final params = CalculationMethod.karachi.getParameters();
      final prayerTimes = PrayerTimes.today(coordinates, params);

      await HomeWidget.saveWidgetData<String>('fajr', _formatTime(prayerTimes.fajr));
      await HomeWidget.saveWidgetData<String>('dhuhr', _formatTime(prayerTimes.dhuhr));
      await HomeWidget.saveWidgetData<String>('asr', _formatTime(prayerTimes.asr));
      await HomeWidget.saveWidgetData<String>('maghrib', _formatTime(prayerTimes.maghrib));
      await HomeWidget.saveWidgetData<String>('isha', _formatTime(prayerTimes.isha));

      await HomeWidget.updateWidget(
        name: _androidWidgetName,
        androidName: _androidWidgetName,
      );
    } catch (e) {
      print("Widget Update Error: $e");
    }
  }

  static String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }
}
