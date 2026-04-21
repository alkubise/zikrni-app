import 'dart:math';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class QuranOrbButton extends StatefulWidget {
  final String title;
  final String subtitle;
  final double progressGlow;
  final double size;
  final VoidCallback onTap;

  const QuranOrbButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progressGlow,
    required this.onTap,
    this.size = 118,
  });

  @override
  State<QuranOrbButton> createState() => _QuranOrbButtonState();
}

class _QuranOrbButtonState extends State<QuranOrbButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glow = 0.16 + (widget.progressGlow * 0.28);

    final outerGlow = widget.size * 1.50;
    final outerRing = widget.size * 1.10;
    final innerRing = widget.size * 1.00;
    final coreSize = widget.size;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          final angle = _controller.value * 2 * pi;
          final pulse = 1 + (sin(angle) * 0.02);

          return Transform.scale(
            scale: pulse,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: outerGlow,
                  height: outerGlow,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.gold.withOpacity(glow),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: angle,
                  child: Container(
                    width: outerRing,
                    height: outerRing,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.gold.withOpacity(0.18),
                        width: 1.1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(top: 10, left: outerRing * 0.43, child: _dot()),
                        Positioned(bottom: 12, left: outerRing * 0.20, child: _dot()),
                        Positioned(right: 16, top: outerRing * 0.40, child: _dot()),
                      ],
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: -angle * 0.6,
                  child: Container(
                    width: innerRing,
                    height: innerRing,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.07),
                        width: 1,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: coreSize,
                  height: coreSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withOpacity(0.20),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.14),
                        Colors.black.withOpacity(0.42),
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.gold.withOpacity(0.30),
                      width: 1.2,
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.10),
                          const Color(0xFF111111).withOpacity(0.96),
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.menu_book_rounded,
                          color: AppColors.gold,
                          size: 24,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: "Amiri",
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.62),
                            fontFamily: "Cairo",
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _dot() {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.gold,
      ),
    );
  }
}