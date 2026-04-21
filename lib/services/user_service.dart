import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/app_user.dart';
import 'auth_service.dart';

class UserService {
  UserService._();

  static late SharedPreferences _prefs;
  static const _secureStorage = FlutterSecureStorage();
  static AppUser? _currentUser;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadUserLocally();
  }

  // استخدام التخزين الآمن للمعرفات الحساسة
  static Future<String> getSecureId() async => await _secureStorage.read(key: 'user_uid') ?? '';
  
  static String get userName => _prefs.getString('user_name') ?? '';
  static String get userId => _prefs.getString('user_uid') ?? '';
  static String get userEmail => _prefs.getString('user_email') ?? '';
  static String get joinDate => _prefs.getString('user_join_date') ?? DateTime.now().toIso8601String();
  static bool get isLoggedIn => userId.isNotEmpty;
  static AppUser? get currentUser => _currentUser;

  static Future<void> _loadUserLocally() async {
    final userData = _prefs.getString('current_user_obj');
    if (userData != null) {
      try {
        _currentUser = AppUser.fromJson(jsonDecode(userData));
      } catch (_) {
        _rebuildUserFromFields();
      }
    } else {
      _rebuildUserFromFields();
    }
  }

  static void _rebuildUserFromFields() {
    final name = userName;
    final uid = userId;
    if (name.isNotEmpty && uid.isNotEmpty) {
      _currentUser = AppUser(
        uid: uid,
        name: name,
        email: userEmail,
        provider: 'Local',
        joinDate: joinDate,
        bestTime: 'لا يوجد',
        spiritualLevel: 'مبتدئ',
        isGuest: true,
        smartModeEnabled: true,
        streakDays: 0,
        totalAzkar: 0,
        dailyGoal: 100,
      );
    }
  }

  static Future<void> setUserName(String name) async {
    await _prefs.setString('user_name', name);
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(name: name);
      await _prefs.setString('current_user_obj', jsonEncode(_currentUser!.toJson()));
    }
    final uid = userId;
    if (uid.isNotEmpty) {
      await AuthService.updateUserProfile(uid: uid, name: name);
    }
  }

  static Future<void> bindLoggedInUser(AppUser user) async {
    _currentUser = user;
    await _prefs.setString('user_name', user.name);
    await _prefs.setString('user_uid', user.uid);
    await _prefs.setString('user_email', user.email);
    await _prefs.setString('user_join_date', user.joinDate);
    await _prefs.setString('current_user_obj', jsonEncode(user.toJson()));
    
    // حفظ المعرف في التخزين المشفر للأمان العالي
    await _secureStorage.write(key: 'user_uid', value: user.uid);
  }

  static Future<void> logout() async {
    await _prefs.clear();
    await _secureStorage.deleteAll(); // مسح البيانات المشفرة
    await AuthService.signOut();
    _currentUser = null;
  }
}
