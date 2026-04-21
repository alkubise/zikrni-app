import 'dart:ui';
import 'package:flutter/material.dart';
import '../data/hadith_data.dart';
import '../services/theme_service.dart';
import 'hadith_details_screen.dart';

class HadithScreen extends StatelessWidget {
  const HadithScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 🌌 الخلفية الموحدة
          Positioned.fill(
            child: Image.asset(
              ThemeService.instance.backgroundImage,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.5))),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 🕌 العنوان العلوي المتطور
              SliverAppBar(
                expandedHeight: 120.0,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    "جوامع الكلم",
                    style: TextStyle(
                      color: const Color(0xFFD4AF37),
                      fontFamily: "Cairo",
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      shadows: [Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 10)],
                    ),
                  ),
                ),
              ),

              // 📜 قائمة الأحاديث الزجاجية
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final item = HadithData.data[index];
                      return _buildHadithCard(context, item);
                    },
                    childCount: HadithData.data.length,
                  ),
                ),
              ),
            ],
          ),

          // 🔙 زر العودة الزجاجي العائم
          _buildBottomNav(context),
        ],
      ),
    );
  }

  Widget _buildHadithCard(BuildContext context, Map<String, String> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, anim, secAnim) => HadithDetailsScreen(data: item),
                  transitionsBuilder: (context, anim, secAnim, child) => FadeTransition(opacity: anim, child: child),
                ),
              );
            },
            leading: const Icon(Icons.auto_stories_rounded, color: Color(0xFFD4AF37), size: 24),
            title: Text(
              item["title"] ?? "",
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontFamily: "Cairo",
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Positioned(
      bottom: 30, left: 40, right: 40,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
            ),
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: const Center(
                child: Text(
                  "العودة",
                  style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontFamily: "Cairo"),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}