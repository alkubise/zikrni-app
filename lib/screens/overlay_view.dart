import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class AzkarOverlayView extends StatefulWidget {
  const AzkarOverlayView({super.key});

  @override
  State<AzkarOverlayView> createState() => _AzkarOverlayViewState();
}

class _AzkarOverlayViewState extends State<AzkarOverlayView>
    with TickerProviderStateMixin {

  Map<String, dynamic>? zikrData;

  late AnimationController _mainController;
  late AnimationController _starController;

  late Animation<double> _fade;
  late Animation<double> _scale;
  late Animation<double> _starMove;
  late Animation<double> _starFade;

  bool showStar = false;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _starController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fade = CurvedAnimation(parent: _mainController, curve: Curves.easeOut);
    _scale = Tween(begin: 0.9, end: 1.0).animate(_mainController);

    _starMove = Tween(begin: 0.0, end: -150.0).animate(
      CurvedAnimation(parent: _starController, curve: Curves.easeOut),
    );

    _starFade = Tween(begin: 1.0, end: 0.0).animate(_starController);

    FlutterOverlayWindow.overlayListener.listen((data) {
      if (data != null) {
        setState(() {
          zikrData = Map<String, dynamic>.from(data);
          showStar = false;
        });
        _startAnimation();
      }
    });
  }

  void _startAnimation() {
    _mainController.forward(from: 0);

    /// بعد 4 ثواني يتحول إلى نجمة
    Future.delayed(const Duration(seconds: 4), () async {
      if (!mounted) return;

      setState(() => showStar = true);

      await _starController.forward(from: 0);

      if (await FlutterOverlayWindow.isActive()) {
        await FlutterOverlayWindow.closeOverlay();
      }
    });
  }

  Color _goldColor() {
    return const Color(0xFFD4AF37);
  }

  @override
  Widget build(BuildContext context) {
    final gold = _goldColor();

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [

          /// ⭐ النجمة الطائرة
          if (showStar)
            AnimatedBuilder(
              animation: _starController,
              builder: (_, __) {
                return Positioned(
                  bottom: 120 + _starMove.value,
                  left: MediaQuery.of(context).size.width / 2 - 20,
                  child: FadeTransition(
                    opacity: _starFade,
                    child: Icon(
                      Icons.auto_awesome,
                      color: gold,
                      size: 42,
                    ),
                  ),
                );
              },
            ),

          /// 🪟 الكارد الزجاجي الذهبي
          if (!showStar)
            Center(
              child: FadeTransition(
                opacity: _fade,
                child: ScaleTransition(
                  scale: _scale,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(
                        colors: [
                          gold,
                          const Color(0xFFB8860B),
                          gold,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: gold.withOpacity(0.25),
                          blurRadius: 25,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.80),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              /// Header
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(Icons.auto_awesome,
                                      color: gold, size: 18),

                                  Expanded(
                                    child: Text(
                                      zikrData?['title'] ?? "ذكرني",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: gold,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                  ),

                                  GestureDetector(
                                    onTap: () async {
                                      await FlutterOverlayWindow.closeOverlay();
                                    },
                                    child: const Icon(Icons.close,
                                        color: Colors.white54, size: 20),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 15),

                              /// النص
                              Text(
                                zikrData?['text'] ??
                                    "سبحان الله وبحمده",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontFamily: 'Amiri',
                                  height: 1.6,
                                ),
                              ),

                              const SizedBox(height: 12),

                              /// المرجع
                              Text(
                                zikrData?['ref'] ?? "",
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 11,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}