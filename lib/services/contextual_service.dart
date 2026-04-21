import 'package:geolocator/geolocator.dart';
import 'package:weather/weather.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'notification_service.dart';
import 'localization_service.dart';
import 'package:flutter/material.dart';

class ContextualService {
  static final WeatherFactory _wf = WeatherFactory(dotenv.env['WEATHER_API_KEY'] ?? "");
  static bool _travelDuaSent = false;
  static bool _rainDuaSent = false;
  static bool _nightDuaSent = false;

  static Future<void> checkContext(BuildContext context) async {
    try {
      final now = DateTime.now();

      // 1. Check for Travel (Speed > 30 km/h approx 8.3 m/s)
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.low,
        );
        if (position.speed > 8.3 && !_travelDuaSent) {
          await NotificationService.showNow(
            id: 999,
            title: "دعاء السفر",
            body: "نشعر أنك في طريقك، لا تنسَ دعاء السفر: 'سبحان الذي سخر لنا هذا...'",
          );
          _travelDuaSent = true;
        } else if (position.speed < 1.0) {
          _travelDuaSent = false;
        }

        // 2. Check for Weather (Rain)
        if (dotenv.env['WEATHER_API_KEY'] != null && dotenv.env['WEATHER_API_KEY']!.isNotEmpty) {
          Weather w = await _wf.currentWeatherByLocation(
            position.latitude,
            position.longitude,
          );
          
          if (w.weatherMain?.toLowerCase().contains("rain") == true && !_rainDuaSent) {
            await NotificationService.showNow(
              id: 888,
              title: "خيرات السماء",
              body: "السماء تمطر الآن.. 'اللهم صيباً نافعاً' 🌧️",
            );
            _rainDuaSent = true;
          } else if (w.weatherMain?.toLowerCase().contains("rain") == false) {
            _rainDuaSent = false;
          }
        }
      } catch (e) {
        debugPrint("Location/Weather Context Error: $e");
      }

      // 3. Third of the Night (approx 1 AM to 4 AM)
      if (now.hour >= 1 && now.hour <= 4) {
        if (!_nightDuaSent) {
          await NotificationService.showNow(
            id: 777,
            title: "سهام الليل",
            body: "نحن في الثلث الأخير من الليل.. ساعة استجابة، لا تنسَ نفسك من الدعاء ✨",
          );
          _nightDuaSent = true;
        }
      } else {
        _nightDuaSent = false;
      }

    } catch (e) {
      debugPrint("ContextualService General Error: $e");
    }
  }
}
