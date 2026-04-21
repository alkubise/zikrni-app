import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'tilt_glass_card.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  final String aiMessage;
  final String level;
  final double progress;
  final VoidCallback onMenuTap;

  const HomeHeader({
    super.key,
    required this.userName,
    required this.aiMessage,
    required this.level,
    required this.progress,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return TiltGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      maxTilt: 0.03,
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onMenuTap,
                icon: const Icon(Icons.menu_rounded, color: AppColors.gold),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: "Cairo",
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "المستوى الروحاني: $level",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.58),
                        fontFamily: "Cairo",
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold.withOpacity(0.28)),
                  gradient: RadialGradient(
                    colors: [
                      AppColors.gold.withOpacity(0.16),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: const Icon(Icons.auto_awesome, color: AppColors.gold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.08),
              valueColor: AlwaysStoppedAnimation(AppColors.gold),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: AppColors.gold, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    aiMessage,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: "Cairo",
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}