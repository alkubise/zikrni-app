import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';

class ThemeService extends ChangeNotifier {
  ThemeService._();
  static final ThemeService instance = ThemeService._();

  bool _isDarkMode = true;
  String _selectedFont = "Cairo";
  String _visualMode = "balanced";
  bool _compactMode = false;
  bool _autoThemeEnabled = false;
  String _selectedLocale = 'ar';

  bool get isDarkMode => _isDarkMode;
  String get selectedFont => _selectedFont;
  String get visualMode => _visualMode;
  bool get compactMode => _compactMode;
  bool get autoThemeEnabled => _autoThemeEnabled;
  String get selectedLocale => _selectedLocale;

  String get backgroundImage =>
      _isDarkMode
          ? "assets/images/background_night.png"
          : "assets/images/background_day.png";

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool("darkMode") ?? true;
    _selectedFont = prefs.getString("font") ?? "Cairo";
    _visualMode = prefs.getString("visual_mode") ?? "balanced";
    _compactMode = prefs.getBool("compact_mode") ?? false;
    _autoThemeEnabled = prefs.getBool("auto_theme") ?? false;
    _selectedLocale = prefs.getString("selected_locale") ?? 'ar';
    
    if (_autoThemeEnabled) {
      await updateThemeBasedOnPrayer();
    }
    
    notifyListeners();
  }

  Future<void> updateThemeBasedOnPrayer() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      final coordinates = Coordinates(position.latitude, position.longitude);
      final params = CalculationMethod.karachi.getParameters();
      final prayerTimes = PrayerTimes.today(coordinates, params);

      final now = DateTime.now();
      if (now.isAfter(prayerTimes.fajr) && now.isBefore(prayerTimes.maghrib)) {
        _isDarkMode = false;
      } else {
        _isDarkMode = true;
      }
    } catch (e) {}
  }

  Future<void> setLocale(String localeCode) async {
    _selectedLocale = localeCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("selected_locale", localeCode);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("darkMode", value);
    notifyListeners();
  }

  Future<void> setAutoTheme(bool value) async {
    _autoThemeEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("auto_theme", value);
    if (value) await updateThemeBasedOnPrayer();
    notifyListeners();
  }

  Future<void> setFont(String font) async {
    _selectedFont = font;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("font", font);
    notifyListeners();
  }

  Future<void> setVisualMode(String mode) async {
    _visualMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("visual_mode", mode);
    notifyListeners();
  }

  Future<void> setCompactMode(bool value) async {
    _compactMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("compact_mode", value);
    notifyListeners();
  }
}
