import 'package:flutter/material.dart';
import 'dart:async';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import 'login_or_guest_screen.dart';
import 'name_input_screen.dart';
import 'splash_screen.dart';

class StartupGateScreen extends StatefulWidget {
  const StartupGateScreen({super.key});

  @override
  State<StartupGateScreen> createState() => _StartupGateScreenState();
}

class _StartupGateScreenState extends State<StartupGateScreen> {
  @override
  void initState() {
    super.initState();
    // تنفيذ القرار بعد أول إطار لضمان استقرار السياق
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _decideStartScreen();
    });
  }

  Future<void> _decideStartScreen() async {
    try {
      // 1. تهيئة بيانات المستخدم المحلية بمهلة زمنية
      await UserService.init().timeout(const Duration(seconds: 3));

      if (!mounted) return;

      // 2. التحقق من حالة المستخدم (سحابياً ومحلياً)
      final currentUser = AuthService.currentUser;
      final localUserId = UserService.userId;
      
      // إذا كان هناك مستخدم (سواء سحابي أو محلي)
      final bool hasActiveSession = currentUser != null || localUserId.isNotEmpty;
      final bool hasName = UserService.userName.trim().isNotEmpty;

      Widget target;

      if (!hasActiveSession) {
        // لا يوجد مستخدم إطلاقاً -> صفحة الدخول
        target = const LoginOrGuestScreen();
      } else if (!hasName) {
        // مستخدم مسجل لكن بدون اسم -> صفحة إدخال الاسم
        target = const NameInputScreen();
      } else {
        // مستخدم جاهز -> صفحة التحليل (Splash)
        target = const SplashScreen();
      }

      // الانتقال بتأثير تلاشي سلس
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => target,
            transitionDuration: const Duration(milliseconds: 800),
            transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
          ),
        );
      }
    } catch (e) {
      // في حال حدوث أي خطأ غير متوقع، نتوجه لصفحة الدخول بدلاً من الشاشة السوداء
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginOrGuestScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020202),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // شعار خفيف جداً أثناء التحميل لمنع الملل من الشاشة السوداء
            const Text(
              "ذَكِّرْنِي",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFFD4AF37),
                fontFamily: "Cairo",
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 30),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFD4AF37),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
