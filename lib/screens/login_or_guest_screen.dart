import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import 'name_input_screen.dart';
import 'splash_screen.dart';

class LoginOrGuestScreen extends StatefulWidget {
  const LoginOrGuestScreen({super.key});

  @override
  State<LoginOrGuestScreen> createState() => _LoginOrGuestScreenState();
}

class _LoginOrGuestScreenState extends State<LoginOrGuestScreen> {
  bool isLoadingGoogle = false;
  bool isLoadingGuest = false;

  Future<void> _loginWithGoogle() async {
    if (isLoadingGoogle) return;
    setState(() => isLoadingGoogle = true);

    try {
      final user = await AuthService.signInWithGoogle();
      await UserService.bindLoggedInUser(user);

      if (!mounted) return;

      if (user.name.trim().isEmpty || user.name == 'مستخدم جديد') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const NameInputScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SplashScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      // إظهار تفاصيل الخطأ الفعلية للمساعدة في التشخيص
      _showErrorSnackBar('فشل تسجيل الدخول: ${e.toString()}');
    } finally {
      if (mounted) setState(() => isLoadingGoogle = false);
    }
  }

  Future<void> _continueAsGuest() async {
    if (isLoadingGuest) return;
    setState(() => isLoadingGuest = true);

    try {
      final user = await AuthService.continueAsGuest();
      await UserService.bindLoggedInUser(user);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const NameInputScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('فشل دخول الضيف: ${e.toString()}');
    } finally {
      if (mounted) setState(() => isLoadingGuest = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12)),
        backgroundColor: Colors.red.shade900,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'حسناً',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020202),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),
              const Text(
                'ذَكِّرْنِي',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFD4AF37),
                  fontFamily: 'Cairo',
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'هوية روحية ذكية تتطور معك وتمنحك تجربة إيمانية فريدة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.5,
                  fontFamily: 'Cairo',
                ),
              ),
              const Spacer(),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoadingGoogle ? null : _loginWithGoogle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: isLoadingGoogle
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.login_rounded),
                            const SizedBox(width: 12),
                            const Text(
                              'الدخول عبر Google',
                              style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: isLoadingGuest ? null : _continueAsGuest,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    foregroundColor: const Color(0xFFD4AF37),
                  ),
                  child: isLoadingGuest
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFD4AF37)))
                      : const Text(
                          'المتابعة كضيف',
                          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
              ),
              
              const SizedBox(height: 24),
              const Text(
                'يمكنك لاحقاً ربط حسابك لحفظ بياناتك للأبد',
                style: TextStyle(color: Colors.white38, fontSize: 12, fontFamily: 'Cairo'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
