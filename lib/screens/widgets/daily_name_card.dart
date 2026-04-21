import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'tilt_glass_card.dart';

class DailyNameCard extends StatelessWidget {
  final String title;
  final String meaning;
  final String action;

  const DailyNameCard({
    super.key,
    required this.title,
    required this.meaning,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return TiltGlassCard(
      maxTilt: 0.03,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_mosaic_rounded, color: AppColors.gold),
              const SizedBox(width: 8),
              Text(
                "اسم اليوم",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.82),
                  fontFamily: "Cairo",
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: "Amiri",
              fontWeight: FontWeight.bold,
              fontSize: 26,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            meaning,
            style: TextStyle(
              color: AppColors.gold.withOpacity(0.92),
              fontFamily: "Cairo",
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            action,
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontFamily: "Cairo",
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}