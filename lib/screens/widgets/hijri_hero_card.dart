import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../hijri_calendar_screen.dart';
import 'tilt_glass_card.dart';

class HijriHeroCard extends StatelessWidget {
  final String hijriDay;
  final String hijriMonth;
  final String gregorianText;
  final String milestoneText;

  const HijriHeroCard({
    super.key,
    required this.hijriDay,
    required this.hijriMonth,
    required this.gregorianText,
    required this.milestoneText,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HijriCalendarScreen()),
        );
      },
      child: TiltGlassCard(
        maxTilt: 0.035,
        child: Row(
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold.withOpacity(0.25)),
                gradient: RadialGradient(
                  colors: [
                    AppColors.gold.withOpacity(0.26),
                    Colors.black.withOpacity(0.22),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withOpacity(0.14),
                    blurRadius: 24,
                  )
                ],
              ),
              child: Center(
                child: Text(
                  hijriDay,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: "Cairo",
                    fontWeight: FontWeight.w900,
                    fontSize: 28,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hijriMonth,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: "Cairo",
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "التاريخ الهجري",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.55),
                      fontFamily: "Cairo",
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    gregorianText,
                    style: TextStyle(
                      color: AppColors.gold.withOpacity(0.90),
                      fontFamily: "Cairo",
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    milestoneText,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.80),
                      fontFamily: "Cairo",
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.calendar_month_rounded, color: AppColors.gold),
          ],
        ),
      ),
    );
  }
}