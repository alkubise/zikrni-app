import 'dart:ui';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class HomeBottomDock extends StatelessWidget {
  final int todayCount;
  final int streakCount;
  final String prayerText;

  final VoidCallback onHomeTap;
  final VoidCallback onQuranTap;
  final VoidCallback onTasbihTap;
  final VoidCallback onQiblaTap;
  final VoidCallback onProfileTap;

  const HomeBottomDock({
    super.key,
    required this.todayCount,
    required this.streakCount,
    required this.prayerText,
    required this.onHomeTap,
    required this.onQuranTap,
    required this.onTasbihTap,
    required this.onQiblaTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0D1117).withOpacity(0.78),
                const Color(0xFF17120A).withOpacity(0.72),
                const Color(0xFF0B1220).withOpacity(0.78),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.gold.withOpacity(0.22),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withOpacity(0.08),
                blurRadius: 20,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(child: _stat(Icons.auto_awesome, "اليوم", "$todayCount")),
                  Expanded(child: _stat(Icons.local_fire_department, "السلسلة", "$streakCount")),
                  Expanded(child: _stat(Icons.schedule, "الصلاة", prayerText)),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _navIcon(Icons.person_rounded, onProfileTap),
                    _navIcon(Icons.explore_rounded, onQiblaTap),
                    _navIcon(Icons.brightness_7_rounded, onTasbihTap, filled: true),
                    _navIcon(Icons.menu_book_rounded, onQuranTap),
                    _navIcon(Icons.home_rounded, onHomeTap),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppColors.gold, size: 16),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 9,
            fontFamily: "Cairo",
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            fontFamily: "Cairo",
          ),
        ),
      ],
    );
  }

  Widget _navIcon(IconData icon, VoidCallback onTap, {bool filled = false}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: filled ? 50 : 42,
        height: filled ? 50 : 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: filled ? AppColors.gold : Colors.black.withOpacity(0.18),
          border: Border.all(
            color: filled
                ? Colors.transparent
                : AppColors.gold.withOpacity(0.18),
          ),
          boxShadow: filled
              ? [
            BoxShadow(
              color: AppColors.gold.withOpacity(0.30),
              blurRadius: 14,
              spreadRadius: 1,
            ),
          ]
              : null,
        ),
        child: Icon(
          icon,
          size: 20,
          color: filled ? Colors.black : Colors.white,
        ),
      ),
    );
  }
}