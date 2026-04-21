import 'dart:math';
import 'package:flutter/material.dart';
import '../../controllers/home_controller.dart';
import '../../constants/app_colors.dart';

class HomeDynamicBackground extends StatefulWidget {
  final String backgroundImage;
  final HomeVisualState themeMode;
  final double zikrEnergy;
  final double qiblaAngle;

  const HomeDynamicBackground({
    super.key,
    required this.backgroundImage,
    required this.themeMode,
    required this.zikrEnergy,
    required this.qiblaAngle,
  });

  @override
  State<HomeDynamicBackground> createState() => _HomeDynamicBackgroundState();
}

class _HomeDynamicBackgroundState extends State<HomeDynamicBackground>
    with SingleTickerProviderStateMixin {
  Offset offset = Offset.zero;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colorsForState(widget.themeMode);

    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          offset += details.delta * 0.02;
          offset = Offset(offset.dx.clamp(-12, 12), offset.dy.clamp(-12, 12));
        });
      },
      onPanEnd: (_) => setState(() => offset = Offset.zero),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            children: [
              Positioned.fill(
                child: Transform.translate(
                  offset: Offset(offset.dx * 0.4, offset.dy * 0.25),
                  child: Image.asset(
                    widget.backgroundImage,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: colors,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -80 + offset.dy,
                left: -30 + offset.dx,
                child: _glowBubble(
                  220 + (widget.zikrEnergy * 50),
                  AppColors.gold.withOpacity(0.10 + (widget.zikrEnergy * 0.08)),
                ),
              ),
              Positioned(
                bottom: 90 - offset.dy,
                right: -50 - offset.dx,
                child: _glowBubble(
                  180 + (widget.zikrEnergy * 35),
                  Colors.white.withOpacity(0.05 + (widget.zikrEnergy * 0.04)),
                ),
              ),
              Positioned.fill(
                child: CustomPaint(
                  painter: _ParticlesPainter(
                    seedColor: AppColors.gold.withOpacity(0.08 + widget.zikrEnergy * 0.10),
                    phase: _controller.value,
                    densityBoost: widget.zikrEnergy,
                  ),
                ),
              ),
              Positioned(
                top: 150,
                right: 26,
                child: Transform.rotate(
                  angle: widget.qiblaAngle * pi / 180,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.24),
                      border: Border.all(color: AppColors.gold.withOpacity(0.22)),
                    ),
                    child: Icon(
                      Icons.navigation_rounded,
                      color: AppColors.gold.withOpacity(0.9),
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
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

  List<Color> _colorsForState(HomeVisualState state) {
    switch (state) {
      case HomeVisualState.fajr:
        return [
          const Color(0xFF071B2E).withOpacity(0.58),
          const Color(0xFF183B63).withOpacity(0.38),
          const Color(0xFF7B5B1D).withOpacity(0.20),
        ];
      case HomeVisualState.sunset:
        return [
          const Color(0xFF2A1028).withOpacity(0.48),
          const Color(0xFF6A3420).withOpacity(0.28),
          const Color(0xFF241631).withOpacity(0.32),
        ];
      case HomeVisualState.fridayNight:
        return [
          const Color(0xFF141229).withOpacity(0.62),
          const Color(0xFF2C1D59).withOpacity(0.34),
          const Color(0xFF8A6A22).withOpacity(0.18),
        ];
      case HomeVisualState.ramadan:
        return [
          const Color(0xFF061C14).withOpacity(0.62),
          const Color(0xFF0D3A2E).withOpacity(0.35),
          const Color(0xFFB38A2E).withOpacity(0.18),
        ];
      case HomeVisualState.night:
        return [
          Colors.black.withOpacity(0.58),
          const Color(0xFF0F172A).withOpacity(0.44),
          const Color(0xFF151515).withOpacity(0.32),
        ];
    }
  }
}

class _ParticlesPainter extends CustomPainter {
  final Color seedColor;
  final double phase;
  final double densityBoost;

  _ParticlesPainter({
    required this.seedColor,
    required this.phase,
    required this.densityBoost,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = seedColor;
    final random = Random(7);
    final total = 28 + (densityBoost * 24).round();

    for (int i = 0; i < total; i++) {
      final dx = random.nextDouble() * size.width;
      final baseDy = random.nextDouble() * size.height;
      final wave = sin((phase * 2 * pi) + (i * 0.35)) * 6;
      final dy = baseDy + wave;
      final r = random.nextDouble() * 2.4 + 0.7;
      canvas.drawCircle(Offset(dx, dy), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.seedColor != seedColor ||
        oldDelegate.densityBoost != densityBoost;
  }
}