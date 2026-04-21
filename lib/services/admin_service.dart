import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminService {
  static const String _defaultUser = "admin";
  static const String _defaultPass = "1234";
  static const String _keyPass = "admin_password_hash";

  static Future<bool> verify(String username, String password) async {
    if (username != _defaultUser) return false;

    final prefs = await SharedPreferences.getInstance();
    final savedHash = prefs.getString(_keyPass);

    if (savedHash == null) {
      return password == _defaultPass;
    }

    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString() == savedHash;
  }

  static Future<void> updatePassword(String newPassword) async {
    final prefs = await SharedPreferences.getInstance();
    final bytes = utf8.encode(newPassword);
    final digest = sha256.convert(bytes);
    await prefs.setString(_keyPass, digest.toString());
  }
}
