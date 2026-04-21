import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../controllers/home_controller.dart';

class AppPreferencesScreen extends StatefulWidget {
  final HomeController controller;

  const AppPreferencesScreen({
    super.key,
    required this.controller,
  });

  @override
  State<AppPreferencesScreen> createState() => _AppPreferencesScreenState();
}

class _AppPreferencesScreenState extends State<AppPreferencesScreen> {
  @override
  Widget build(BuildContext context) {
    final c = widget.controller;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text("الإعدادات", style: TextStyle(fontFamily: "Cairo")),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _tile(
            title: "الإشعارات",
            subtitle: "تفعيل أو إيقاف التذكيرات اليومية",
            trailing: Switch(
              value: c.notificationsEnabled,
              activeColor: AppColors.gold,
              onChanged: (v) async {
                await c.setNotifications(v);
                setState(() {});
              },
            ),
          ),
          _tile(
            title: "السماح بالموقع",
            subtitle: "استخدام الموقع لمواقيت الصلاة والقبلة",
            trailing: Switch(
              value: c.privacyLocationEnabled,
              activeColor: AppColors.gold,
              onChanged: (v) async {
                await c.setPrivacyLocation(v);
                setState(() {});
              },
            ),
          ),
          _tile(
            title: "تكبير النص",
            subtitle: "وضع قراءة مريح",
            trailing: Switch(
              value: c.largeTextEnabled,
              activeColor: AppColors.gold,
              onChanged: (v) async {
                await c.setLargeText(v);
                setState(() {});
              },
            ),
          ),
          _tile(
            title: "تأثيرات الزجاج",
            subtitle: "تشغيل أو تقليل مؤثرات الخلفية",
            trailing: Switch(
              value: c.showGlassEffects,
              activeColor: AppColors.gold,
              onChanged: (v) async {
                await c.setShowGlassEffects(v);
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile({
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Colors.white, fontFamily: "Cairo")),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.white.withOpacity(0.55), fontFamily: "Cairo"),
        ),
        trailing: trailing,
      ),
    );
  }
}