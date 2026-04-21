import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../constants/app_colors.dart';
import '../services/theme_service.dart';
import 'login_or_guest_screen.dart';

class LogoutScreen extends StatefulWidget {
  const LogoutScreen({super.key});

  @override
  State<LogoutScreen> createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen> with SingleTickerProviderStateMixin {
  late AnimationController _aniController;
  late Animation<double> _fadeAni;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _aniController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _fadeAni = CurvedAnimation(parent: _aniController, curve: Curves.easeIn);
    _aniController.forward();
  }

  @override
  void dispose() {
    _aniController.dispose();
    super.dispose();
  }

  Future<void> _performLogout() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    
    HapticFeedback.heavyImpact();

    try {
      // 1. تسجيل الخروج من الخدمات
      await UserService.logout();
      await AuthService.signOut();
      
      if (!mounted) return;

      // 2. الانتقال لصفحة تسجيل الدخول مع حذف كافة المسارات السابقة
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginOrGuestScreen()),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تعذر تسجيل الخروج، حاول مرة أخرى")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // خلفية سينمائية
          Positioned.fill(
            child: Opacity(
              opacity: 0.4,
              child: Image.asset(
                ThemeService.instance.backgroundImage,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(color: Colors.black.withOpacity(0.8)),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAni,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // أيقونة الخروج المتوهجة
                    Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.redAccent.withOpacity(0.05),
                        border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.redAccent.withOpacity(0.1),
                            blurRadius: 40,
                          )
                        ],
                      ),
                      child: const Icon(
                        Icons.power_settings_new_rounded,
                        color: Colors.redAccent,
                        size: 60,
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    const Text(
                      "تسجيل الخروج",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        fontFamily: "Cairo",
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    const Text(
                      "في حفظ الله ورعايته..\nننتظر عودتك قريباً لمتابعة نور ذكرك.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 15,
                        height: 1.6,
                        fontFamily: "Cairo",
                      ),
                    ),
                    
                    const SizedBox(height: 60),

                    // زر التأكيد
                    _actionButton(
                      text: _isProcessing ? "جاري الخروج..." : "تأكيد الخروج",
                      color: Colors.redAccent,
                      onTap: _isProcessing ? null : _performLogout,
                      isPrimary: true,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // زر الإلغاء
                    _actionButton(
                      text: "البقاء في التطبيق",
                      color: Colors.white10,
                      onTap: () => Navigator.pop(context),
                      isPrimary: false,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String text,
    required Color color,
    required VoidCallback? onTap,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isPrimary ? color : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isPrimary ? Colors.transparent : Colors.white10),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isPrimary ? Colors.white : Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: "Cairo",
            ),
          ),
        ),
      ),
    );
  }
}
