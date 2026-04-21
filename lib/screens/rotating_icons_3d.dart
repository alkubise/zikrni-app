import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';
import 'morning_screen.dart';
import 'evening_screen.dart';
import 'azkar_screen.dart';
import 'hadith_screen.dart';
import 'dua_screen.dart';
import 'tasbih_screen.dart';
import 'sirah_screen.dart';

class RotatingIcons3D extends StatefulWidget {
  final double orbitWidth;
  final double orbitHeight;
  final double iconSize;
  final bool animateEntrance;

  const RotatingIcons3D({
    super.key,
    this.orbitWidth = 310,
    this.orbitHeight = 190,
    this.iconSize = 76,
    this.animateEntrance = true,
  });

  @override
  State<RotatingIcons3D> createState() => _RotatingIcons3DState();
}

class _RotatingIcons3DState extends State<RotatingIcons3D>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  final List<_OrbitItem> icons = const [
    _OrbitItem("assets/icons/hadith.png", "حديث"),
    _OrbitItem("assets/icons/dua.png", "دعاء"),
    _OrbitItem("assets/icons/tasbih.png", "تسبيح"),
    _OrbitItem("assets/icons/azkar.png", "أذكار"),
    _OrbitItem("assets/icons/sirah.png", "سيرة"),
    _OrbitItem("assets/icons/morning.png", "الصباح"),
    _OrbitItem("assets/icons/evening.png", "المساء"),
  ];

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.82,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutBack,
      ),
    );

    _glowAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOut,
      ),
    );

    if (widget.animateEntrance) {
      Future.delayed(const Duration(milliseconds: 120), () {
        if (mounted) _entranceController.forward();
      });
    } else {
      _entranceController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.orbitWidth,
      height: widget.orbitHeight + 110,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _rotationController,
          _entranceController,
        ]),
        builder: (context, child) {
          final centerX = widget.orbitWidth / 2;
          final centerY = (widget.orbitHeight + 110) / 2;

          final radiusX = widget.orbitWidth * 0.42 * _scaleAnimation.value;
          final radiusY = widget.orbitHeight * 0.38 * _scaleAnimation.value;

          final List<Map<String, dynamic>> itemList = [];

          for (int i = 0; i < icons.length; i++) {
            final angle =
                (2 * pi * i / icons.length) + _rotationController.value * 2 * pi;

            final x = radiusX * cos(angle);
            final y = radiusY * sin(angle);

            final depth = (sin(angle) + 1) / 2;

            final baseScale = 0.68 + (depth * 0.30);
            final frontBoost = depth > 0.86 ? 0.12 : 0.0;
            final scale = (baseScale + frontBoost) * _scaleAnimation.value;

            final opacity = (0.38 + (depth * 0.62)) * _fadeAnimation.value;

            itemList.add({
              "depth": depth,
              "widget": Positioned(
                left: centerX + x - (widget.iconSize / 2),
                top: centerY + y - (widget.iconSize / 2),
                child: Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: opacity.clamp(0.0, 1.0),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        _navigateToScreen(icons[i].title);
                      },
                      child: _buildStyledIcon(
                        assetPath: icons[i].icon,
                        title: icons[i].title,
                        depth: depth,
                        angle: angle,
                      ),
                    ),
                  ),
                ),
              ),
            });
          }

          itemList.sort(
                (a, b) => (a["depth"] as double).compareTo(b["depth"] as double),
          );

          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _GoldenOrbitPainter(
                      progress: _rotationController.value,
                      glowFactor: _glowAnimation.value,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _LightBeamPainter(
                      progress: _rotationController.value,
                      itemCount: icons.length,
                      glowFactor: _glowAnimation.value,
                    ),
                  ),
                ),
              ),
              ...itemList.map((e) => e["widget"] as Widget),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStyledIcon({
    required String assetPath,
    required String title,
    required double depth,
    required double angle,
  }) {
    final bool isFront = depth > 0.86;
    final double borderOpacity = isFront ? 0.58 : 0.24;
    final double glowOpacity = isFront ? 0.34 : 0.10;

    return SizedBox(
      width: widget.iconSize,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: widget.iconSize,
            height: widget.iconSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.34),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: AppColors.gold.withOpacity(glowOpacity),
                  blurRadius: isFront ? 22 : 12,
                  spreadRadius: isFront ? 3 : 0,
                ),
              ],
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.14),
                  Colors.black.withOpacity(0.32),
                ],
              ),
              border: Border.all(
                color: AppColors.gold.withOpacity(borderOpacity),
                width: isFront ? 1.5 : 1.1,
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF173048).withOpacity(0.98),
                    const Color(0xFF09121B).withOpacity(1.0),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.05),
                  width: 0.8,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.gold.withOpacity(isFront ? 0.16 : 0.08),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (isFront)
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            startAngle: angle,
                            endAngle: angle + 2 * pi,
                            colors: [
                              Colors.transparent,
                              AppColors.gold.withOpacity(0.10),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      assetPath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.34),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.gold.withOpacity(isFront ? 0.26 : 0.16),
              ),
              boxShadow: isFront
                  ? [
                BoxShadow(
                  color: AppColors.gold.withOpacity(0.10),
                  blurRadius: 8,
                ),
              ]
                  : null,
            ),
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.96),
                fontFamily: "Cairo",
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToScreen(String title) {
    Widget target;

    switch (title) {
      case "الصباح":
        target = MorningAzkarScreen();
        break;
      case "المساء":
        target = EveningAzkarScreen();
        break;
      case "أذكار":
        target = AzkarScreen();
        break;
      case "حديث":
        target = HadithScreen();
        break;
      case "دعاء":
        target = DuaScreen();
        break;
      case "تسبيح":
        target = TasbihScreen();
        break;
      case "سيرة":
        target = SirahScreen();
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => target),
    );
  }
}

class _OrbitItem {
  final String icon;
  final String title;

  const _OrbitItem(this.icon, this.title);
}

class _GoldenOrbitPainter extends CustomPainter {
  final double progress;
  final double glowFactor;

  _GoldenOrbitPainter({
    required this.progress,
    required this.glowFactor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 4);

    final orbitRect = Rect.fromCenter(
      center: center,
      width: size.width * 0.78,
      height: size.height * 0.44,
    );

    final glowPaint = Paint()
      ..color = AppColors.gold.withOpacity(0.10 * glowFactor)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

    final ringPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.gold.withOpacity(0.05),
          AppColors.gold.withOpacity(0.30),
          AppColors.gold.withOpacity(0.05),
        ],
      ).createShader(orbitRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final dashedPaint = Paint()
      ..color = AppColors.gold.withOpacity(0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    canvas.drawOval(orbitRect, glowPaint);
    canvas.drawOval(orbitRect, ringPaint);

    final dashCount = 44;
    for (int i = 0; i < dashCount; i++) {
      final t1 = (i / dashCount) * 2 * pi;
      final t2 = t1 + 0.06;

      final p1 = Offset(
        center.dx + (orbitRect.width / 2) * cos(t1),
        center.dy + (orbitRect.height / 2) * sin(t1),
      );
      final p2 = Offset(
        center.dx + (orbitRect.width / 2) * cos(t2),
        center.dy + (orbitRect.height / 2) * sin(t2),
      );

      canvas.drawLine(p1, p2, dashedPaint);
    }

    final markerAngle = (progress * 2 * pi);
    final marker = Offset(
      center.dx + (orbitRect.width / 2) * cos(markerAngle),
      center.dy + (orbitRect.height / 2) * sin(markerAngle),
    );

    final markerPaint = Paint()
      ..color = AppColors.gold.withOpacity(0.9)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(marker, 3.2, markerPaint);
  }

  @override
  bool shouldRepaint(covariant _GoldenOrbitPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.glowFactor != glowFactor;
  }
}

class _LightBeamPainter extends CustomPainter {
  final double progress;
  final int itemCount;
  final double glowFactor;

  _LightBeamPainter({
    required this.progress,
    required this.itemCount,
    required this.glowFactor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 4);
    final radiusX = size.width * 0.39;
    final radiusY = size.height * 0.22;

    for (int i = 0; i < itemCount; i++) {
      final angle = (2 * pi * i / itemCount) + progress * 2 * pi;
      final depth = (sin(angle) + 1) / 2;

      if (depth < 0.78) continue;

      final target = Offset(
        center.dx + radiusX * cos(angle),
        center.dy + radiusY * sin(angle),
      );

      final beamPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            AppColors.gold.withOpacity(0.00),
            AppColors.gold.withOpacity(0.10 * glowFactor),
            AppColors.gold.withOpacity(0.00),
          ],
        ).createShader(Rect.fromPoints(center, target))
        ..strokeWidth = depth > 0.9 ? 2.2 : 1.2
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawLine(center, target, beamPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LightBeamPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.itemCount != itemCount ||
        oldDelegate.glowFactor != glowFactor;
  }
}