import 'dart:math';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../controllers/home_controller.dart';
import 'tilt_glass_card.dart';

class PrayerHeroCard extends StatelessWidget {
  final String nextPrayerName;
  final String nextPrayerCountdown;
  final double progress;
  final List<SacredPoint> sacredTimeline;
  final VoidCallback onOpenPrayerTimes;
  final VoidCallback onOpenQibla;

  const PrayerHeroCard({
    super.key,
    required this.nextPrayerName,
    required this.nextPrayerCountdown,
    required this.progress,
    required this.sacredTimeline,
    required this.onOpenPrayerTimes,
    required this.onOpenQibla,
  });

  @override
  Widget build(BuildContext context) {
    return TiltGlassCard(
      maxTilt: 0.035,
      child: Column(
        children: [
          Row(
            children: [
              _PrayerRing(progress: progress),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "الصلاة القادمة",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                        fontFamily: "Cairo",
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      nextPrayerName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: "Cairo",
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      nextPrayerCountdown,
                      style: TextStyle(
                        color: AppColors.gold.withOpacity(0.95),
                        fontFamily: "Cairo",
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 9,
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.08),
              valueColor: AlwaysStoppedAnimation(AppColors.gold.withOpacity(0.95)),
            ),
          ),
          const SizedBox(height: 16),
          _SacredTimeline(points: sacredTimeline),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onOpenPrayerTimes,
                  icon: const Icon(Icons.schedule_rounded),
                  label: const Text("المواقيت", style: TextStyle(fontFamily: "Cairo")),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onOpenQibla,
                  icon: const Icon(Icons.explore_rounded),
                  label: const Text("القبلة", style: TextStyle(fontFamily: "Cairo")),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: AppColors.gold.withOpacity(0.28)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrayerRing extends StatelessWidget {
  final double progress;

  const _PrayerRing({required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 74,
      height: 74,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(74, 74),
            painter: _RingPainter(progress: progress),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.gold.withOpacity(0.20),
                  Colors.black.withOpacity(0.35),
                ],
              ),
            ),
            child: const Icon(Icons.access_time_rounded, color: AppColors.gold, size: 24),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;

  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    const stroke = 6.0;
    final radius = (size.width / 2) - stroke;

    final bg = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    final fg = Paint()
      ..shader = SweepGradient(
        colors: [
          AppColors.gold.withOpacity(0.20),
          AppColors.gold,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bg);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _SacredTimeline extends StatelessWidget {
  final List<SacredPoint> points;

  const _SacredTimeline({required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          "الخط الزمني اليومي غير متاح حاليًا",
          style: TextStyle(
            color: Colors.white.withOpacity(0.55),
            fontFamily: "Cairo",
            fontSize: 11,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.timeline_rounded, color: AppColors.gold, size: 18),
              const SizedBox(width: 8),
              Text(
                "الخط الزمني للصوات",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.90),
                  fontFamily: "Cairo",
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(points.length * 2 - 1, (index) {
                if (index.isOdd) {
                  return Container(
                    width: 26,
                    height: 2,
                    color: Colors.white.withOpacity(0.10),
                  );
                }

                final point = points[index ~/ 2];
                final activeColor = point.isNext
                    ? AppColors.gold
                    : point.isPassed
                    ? Colors.white
                    : Colors.white24;

                return Column(
                  children: [
                    Container(
                      width: point.isNext ? 14 : 10,
                      height: point.isNext ? 14 : 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: activeColor,
                        boxShadow: point.isNext
                            ? [
                          BoxShadow(
                            color: AppColors.gold.withOpacity(0.45),
                            blurRadius: 12,
                          ),
                        ]
                            : null,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      point.label,
                      style: TextStyle(
                        color: Colors.white.withOpacity(point.isNext ? 1 : 0.75),
                        fontFamily: "Cairo",
                        fontSize: 9,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}