import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

import '../services/user_service.dart';
import '../services/stats_service.dart';
import '../controllers/zikr_controller.dart';
import '../services/theme_service.dart';
import '../constants/app_colors.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  double _progress = 0;
  String _status = "جاري تهيئة التجربة...";
  String _userName = "";
  String _aiMessage = "";
  String _analysis = "";
  String _userId = "";

  late final AnimationController _pulseController;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _initSystem();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _initSystem() async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) {
      setState(() {
        _progress = 0.12;
        _status = "تحميل البيانات الأساسية...";
      });
    }

    await UserService.init();
    await StatsService.init();
    await ZikrController.instance.loadFromStorage();

    await Future.delayed(const Duration(milliseconds: 800));

    final name = UserService.userName.isEmpty ? "ضيف جديد" : UserService.userName;
    final today = StatsService.todayCount;
    final streak = StatsService.streakDays;

    if (mounted) {
      setState(() {
        _userName = name;
        _userId = UserService.userId;
        _progress = 0.38;
        _status = "تحليل الإيقاع الروحي...";
      });
    }

    await Future.delayed(const Duration(milliseconds: 1000));

    if (streak >= 7 && today > 100) {
      _analysis = "أنت في قمة استقرارك الروحي 🔥";
      _aiMessage = "سلسلتك مستمرة لـ $streak أيام بنجاح\nذكرت الله $today مرة اليوم";
    } else if (today == 0) {
      _analysis = "يوم جديد ينتظر نورك 🤍";
      _aiMessage = "لنبدأ معًا أول خطوات النور لهذا اليوم";
    } else if (today < 30) {
      _analysis = "بداية هادئة وموفقة 🌿";
      _aiMessage = "كل خطوة ذكر تقربك أكثر.. استمر";
    } else if (today < 100) {
      _analysis = "إيقاعك الروحي جميل ✨";
      _aiMessage = "أنت في تقدم رائع.. حافظ على هذا الصفاء";
    } else {
      _analysis = "نورك يتوهج بذكر الله 🌟";
      _aiMessage = "مستواك الإيماني في تصاعد مستمر";
    }

    if (mounted) {
      setState(() {
        _progress = 0.72;
        _status = "مزامنة التفضيلات والواجهة...";
      });
    }

    await Future.delayed(const Duration(milliseconds: 900));

    if (mounted) {
      setState(() {
        _progress = 1.0;
        _status = "كل شيء جاهز";
      });
    }

    await Future.delayed(const Duration(milliseconds: 3700));
    _goToHome();
  }

  void _goToHome() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionDuration: const Duration(milliseconds: 1000),
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(
            opacity: anim,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;

    return Scaffold(
      backgroundColor: const Color(0xFF020202),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              theme.backgroundImage,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.45),
                      Colors.black.withOpacity(0.90),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: -40,
            right: -20,
            child: _glowBubble(180, AppColors.gold.withOpacity(0.10)),
          ),
          Positioned(
            bottom: 120,
            left: -30,
            child: _glowBubble(150, Colors.white.withOpacity(0.05)),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          final glow = 0.10 + (_pulseController.value * 0.10);

                          return Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.gold.withOpacity(glow),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Center(
                              child: Image.asset(
                                "assets/images/icon.png",
                                width: 100,
                                height: 100,
                                fit: BoxFit.contain,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        "ذَكِّرْنِي",
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: AppColors.gold,
                          fontFamily: "Cairo",
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "نورٌ يرافق يومك",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.65),
                          fontSize: 13,
                          fontFamily: "Cairo",
                        ),
                      ),
                      const SizedBox(height: 30),

                      if (_userName.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.06),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "مرحبًا بك يا $_userName",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontFamily: "Cairo",
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _analysis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.gold,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Cairo",
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _aiMessage,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.68),
                                  fontSize: 12.5,
                                  height: 1.6,
                                  fontFamily: "Cairo",
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 28),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: _progress,
                          minHeight: 7,
                          backgroundColor: Colors.white10,
                          valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _status,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.40),
                          fontSize: 11,
                          fontFamily: "Cairo",
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        "USER ID: $_userId",
                        style: const TextStyle(
                          color: Colors.white24,
                          fontSize: 9,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "VER 1.0.0 • SPIRITUAL CORE ONLINE",
                        style: TextStyle(
                          color: Colors.white10,
                          fontSize: 8,
                          letterSpacing: 1,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glowBubble(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
        ),
      ),
    );
  }
}
