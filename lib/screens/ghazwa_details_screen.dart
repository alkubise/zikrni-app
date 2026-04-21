import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../data/ghazwa_data.dart';

class GhazwaDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  const GhazwaDetailsScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // جلب تفاصيل الأحداث من ملف البيانات
    final details = GhazwaData.getDetails(data["title"]);

    return MediaQuery(
      // 🛡️ تثبيت حجم الخط لمنع الـ Overflow إذا قام المستخدم بتكبير خط الهاتف
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // 🌌 خلفية سينمائية للغزوات
            Positioned.fill(
              child: Image.asset(
                "assets/images/battle_bg.png",
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.black),
              ),
            ),
            // طبقة تعتيم فخمة
            Positioned.fill(child: Container(color: Colors.black.withOpacity(0.85))),

            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 🏗️ AppBar مخصص مع Hero Animation للعنوان
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: const SizedBox(), // إخفاء زر الرجوع الافتراضي
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Hero(
                      tag: data["title"],
                      child: Material(
                        color: Colors.transparent,
                        child: Text(
                          data["title"],
                          style: const TextStyle(
                            color: Color(0xFFD4AF37),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Cairo",
                          ),
                        ),
                      ),
                    ),
                    background: Center(
                      child: Opacity(
                        opacity: 0.2,
                        child: Icon(
                          Icons.shield_rounded,
                          color: const Color(0xFFD4AF37),
                          size: 100,
                        ),
                      ),
                    ),
                  ),
                ),

                // 📜 قائمة أحداث الغزوة مع أنيميشن ظهور تدريجي
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                  sliver: AnimationLimiter(
                    child: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final item = details[index];
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 600),
                            child: SlideAnimation(
                              verticalOffset: 30,
                              child: FadeInAnimation(
                                child: _buildEventTile(item),
                              ),
                            ),
                          );
                        },
                        childCount: details.length,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 🔙 زر إغلاق علوي مخصص بستايل زجاجي
            Positioned(
              top: 50,
              left: 20,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5)),
                  ),
                  child: const Icon(Icons.close_rounded, color: Colors.white, size: 25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 💎 كرت الحدث (Event Card) بتصميم زجاجي ومرونة عالية
  Widget _buildEventTile(Map<String, String> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.15)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🏷️ عنوان الحدث داخل الغزوة
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Color(0xFFD4AF37), size: 16),
                  const SizedBox(width: 10),
                  // تغليف بـ Expanded لمنع الـ Overflow العرضي للنصوص الطويلة
                  Expanded(
                    child: Text(
                      item["title"] ?? "",
                      style: const TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Cairo",
                      ),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Divider(color: Colors.white10),
              ),
              // 📖 محتوى الحدث (القصة)
              Text(
                item["content"] ?? "",
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.justify, // محاذاة النص لزيادة الاحترافية
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.8,
                  fontFamily: "Cairo",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}