import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../services/theme_service.dart';

class DuaDetailsScreen extends StatelessWidget {
  final Map<String, String> data;

  const DuaDetailsScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 🌌 الخلفية
          Positioned.fill(
            child: Image.asset(ThemeService.instance.backgroundImage, fit: BoxFit.cover),
          ),
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.7))),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(25),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(35),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                    child: Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(35),
                        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.4)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ✨ أيقونة علوية
                          const Icon(Icons.auto_awesome_rounded, color: Color(0xFFD4AF37), size: 40),
                          const SizedBox(height: 20),

                          // 🔝 العنوان
                          Text(
                            data["title"] ?? "",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFD4AF37),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Cairo",
                            ),
                          ),
                          const Divider(color: Colors.white12, height: 40, thickness: 1),

                          // 🟡 نص الدعاء (الخط الأميري الفخم)
                          Text(
                            data["dua"] ?? "",
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              height: 1.9,
                              fontFamily: "Amiri",
                            ),
                          ),

                          const SizedBox(height: 30),

                          // 🔻 المرجع
                          Text(
                            data["ref"] ?? "",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 13,
                              fontFamily: "Cairo",
                              fontStyle: FontStyle.italic,
                            ),
                          ),

                          const SizedBox(height: 30),

                          // 🛠 أزرار التفاعل (نسخ ومشاركة)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildActionButton(Icons.copy_rounded, () {
                                Clipboard.setData(ClipboardData(text: data["dua"] ?? ""));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("تم نسخ الدعاء")),
                                );
                              }),
                              const SizedBox(width: 20),
                              _buildActionButton(Icons.share_rounded, () {
                                Share.share(data["dua"] ?? "");
                              }),
                            ],
                          ),

                          const SizedBox(height: 30),

                          // زر الإغلاق الاحترافي
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "إغلاق النافذة",
                              style: TextStyle(color: Color(0xFFD4AF37), fontFamily: "Cairo"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
        ),
        child: Icon(icon, color: const Color(0xFFD4AF37), size: 22),
      ),
    );
  }
}