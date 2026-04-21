import 'package:flutter/material.dart';

class OverlayService {
  // ✅ الدالة الجذرية الناقصة: عرض الإشعار فوق التطبيق
  static void showGlobalOverlay(Map<String, String> data) {
    // ملاحظة: بما أن عرض Overlay يحتاج إلى BuildContext، 
    // سنستخدم navigatorKey الذي عرفناه في main.dart للوصول للسياق العالمي
    
    final context = OverlayService.navigatorKey.currentContext;
    if (context != null) {
      showOverlay(context, data);
    }
  }

  // نحتاج لمرجع الـ navigatorKey هنا أيضاً
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static void showOverlay(BuildContext context, Map<String, String> data) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (_) {
        return Center(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data["title"] ?? "تذكير",
                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Cairo"
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  data["text"] ?? "",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontFamily: "Amiri", fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("إغلاق", style: TextStyle(color: Colors.black)),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
