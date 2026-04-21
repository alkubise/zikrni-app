import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'tilt_glass_card.dart';

class QuickActionsGrid extends StatelessWidget {
  final VoidCallback onQuran;
  final VoidCallback onQibla;
  final VoidCallback onPrayer;
  final VoidCallback onSunnah;
  final VoidCallback onNames;
  final VoidCallback onAchievements;

  const QuickActionsGrid({
    super.key,
    required this.onQuran,
    required this.onQibla,
    required this.onPrayer,
    required this.onSunnah,
    required this.onNames,
    required this.onAchievements,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.95,
      children: [
        _item(Icons.menu_book_rounded, "القرآن", onQuran),
        _item(Icons.explore_rounded, "القبلة", onQibla),
        _item(Icons.access_time_rounded, "الصلاة", onPrayer),
        _item(Icons.track_changes_rounded, "السنن", onSunnah),
        _item(Icons.auto_awesome_mosaic_rounded, "الأسماء", onNames),
        _item(Icons.emoji_events_rounded, "الإنجازات", onAchievements),
      ],
    );
  }

  Widget _item(IconData icon, String title, VoidCallback onTap) {
    return TiltGlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.gold.withOpacity(0.18),
                  Colors.transparent,
                ],
              ),
            ),
            child: Icon(icon, color: AppColors.gold, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: "Cairo",
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}