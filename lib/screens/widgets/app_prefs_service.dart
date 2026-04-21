import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPrefsService {
  static const _userNameKey = 'user_name';
  static const _profileSymbolKey = 'profile_symbol_key';
  static const _notificationsEnabledKey = 'notifications_enabled';
  static const _backupEnabledKey = 'backup_enabled';
  static const _privacyLocationEnabledKey = 'privacy_location_enabled';
  static const _largeTextEnabledKey = 'large_text_enabled';
  static const _showGlassEffectsKey = 'show_glass_effects';

  static Future<void> saveUserName(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, value);
  }

  static Future<String> getUserName({String fallback = "عابد لله"}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey) ?? fallback;
  }

  static Future<void> saveProfileSymbolKey(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileSymbolKey, value);
  }

  static Future<String> getProfileSymbolKey({String fallback = "mosque"}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_profileSymbolKey) ?? fallback;
  }

  static Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, value);
  }

  static Future<bool> getNotificationsEnabled({bool fallback = true}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? fallback;
  }

  static Future<void> setBackupEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_backupEnabledKey, value);
  }

  static Future<bool> getBackupEnabled({bool fallback = false}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_backupEnabledKey) ?? fallback;
  }

  static Future<void> setPrivacyLocationEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_privacyLocationEnabledKey, value);
  }

  static Future<bool> getPrivacyLocationEnabled({bool fallback = true}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_privacyLocationEnabledKey) ?? fallback;
  }

  static Future<void> setLargeTextEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_largeTextEnabledKey, value);
  }

  static Future<bool> getLargeTextEnabled({bool fallback = false}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_largeTextEnabledKey) ?? fallback;
  }

  static Future<void> setShowGlassEffects(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showGlassEffectsKey, value);
  }

  static Future<bool> getShowGlassEffects({bool fallback = true}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_showGlassEffectsKey) ?? fallback;
  }
}