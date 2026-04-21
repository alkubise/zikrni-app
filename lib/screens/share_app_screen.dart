import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart'; 
import '../services/theme_service.dart';

class ShareAppScreen extends StatelessWidget {
  const ShareAppScreen({super.key});

  // دالة المشاركة المنفصلة لسهولة التعديل
  void _onShare(BuildContext context) async {
    const String appLink = "https://your-app-link.com"; // ضع رابط تطبيقك هنا لاحقاً
    const String message =
        "قال ﷺ: 'الدال على الخير كفاعله'.\n\n"
        "حمل تطبيق (ذكّرني) الآن، وعِش مع الله في كل لحظة بتصميم 3D فريد.\n"
        "رابط التحميل: $appLink";

    // استدعاء نافذة المشاركة الأصلية
    await Share.share(
      message,
      subject: "تطبيق ذكّرني - رفيقك النوراني",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. الخلفية الموحدة مع التغبيش
          Positioned.fill(
            child: Image.asset(
              ThemeService.instance.backgroundImage,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),
          ),

          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // أيقونة المشاركة المتوهجة
                  const Icon(Icons.share_location_rounded, color: Color(0xFFD4AF37), size: 80),
                  const SizedBox(height: 30),

                  const Text(
                    "شارك الخير",
                    style: TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Cairo"
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    child: Text(
                      "كن سبباً في ذكر غيرك لله بانضمامك لعائلة (ذكّرني). اجعل هذا التطبيق صدقة جارية لك ولأحبابك.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.8, fontFamily: "Cairo"),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // زر المشاركة الذهبي التفاعلي
                  GestureDetector(
                    onTap: () => _onShare(context), // تفعيل الدالة عند الضغط
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [const Color(0xFFD4AF37), const Color(0xFFD4AF37).withOpacity(0.7)],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD4AF37).withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.share_rounded, color: Colors.black, size: 20),
                          SizedBox(width: 15),
                          Text(
                            "نشر رابط التطبيق",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                fontFamily: "Cairo"
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 50),

                  // QR Code زخرفي لتعزيز المظهر الاحترافي
                  _qrMockup(),
                ],
              ),
            ),
          ),

          // زر العودة
          Positioned(top: 50, left: 20, child: const BackButton(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _qrMockup() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: const Column(
        children: [
          Icon(Icons.qr_code_2_rounded, color: Colors.white24, size: 100),
          SizedBox(height: 5),
          Text("THIKRNI-APP", style: TextStyle(color: Colors.white12, fontSize: 10, letterSpacing: 2)),
        ],
      ),
    );
  }
}
