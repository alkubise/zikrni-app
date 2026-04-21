import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/global_challenge_service.dart';
import '../services/stats_service.dart';
import '../constants/app_colors.dart';
import '../core/ui/app_layout.dart';

class GlobalChallengeScreen extends StatelessWidget {
  const GlobalChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final layout = AppLayout(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // خلفية فخمة
          Positioned.fill(
            child: Image.asset(
              "assets/images/mosque_bg.png",
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.4),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.9),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(context, layout),
                const Spacer(),
                _buildGlobalCounter(layout),
                const Spacer(),
                _buildUserContribution(layout),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLayout layout) {
    return Padding(
      padding: EdgeInsets.all(layout.scale(20)),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.gold),
            style: IconButton.styleFrom(backgroundColor: Colors.white10),
          ),
          const Expanded(
            child: Center(
              child: Text(
                "التحدي العالمي",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Cairo",
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildGlobalCounter(AppLayout layout) {
    return StreamBuilder<int>(
      stream: GlobalChallengeService.getGlobalCounterStream(),
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return Column(
          children: [
            const Text(
              "إجمالي استغفار الأمة اليوم",
              style: TextStyle(color: Colors.white70, fontSize: 16, fontFamily: "Cairo"),
            ),
            const SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: layout.scale(30), vertical: layout.scale(20)),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(color: AppColors.gold.withOpacity(0.1), blurRadius: 40, spreadRadius: 5)
                ],
              ),
              child: Text(
                count.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},'),
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: layout.scale(45),
                  fontWeight: FontWeight.w900,
                  fontFamily: "Cairo",
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              "يَدُ اللَّهِ مَعَ الْجَمَاعَةِ",
              style: TextStyle(color: AppColors.gold, fontSize: 12, fontFamily: "Amiri", fontStyle: FontStyle.italic),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserContribution(AppLayout layout) {
    final todayCount = StatsService.getTodayCount();
    return Container(
      margin: EdgeInsets.symmetric(horizontal: layout.scale(25)),
      padding: EdgeInsets.all(layout.scale(20)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.gold.withOpacity(0.2),
            child: const Icon(Icons.person_rounded, color: AppColors.gold),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("مساهمتك الحالية", style: TextStyle(color: Colors.white60, fontSize: 12, fontFamily: "Cairo")),
                Text("$todayCount ذِكر", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "Cairo")),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              // التفاعل مع التحدي
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("شارك الآن", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: "Cairo")),
          )
        ],
      ),
    );
  }
}
