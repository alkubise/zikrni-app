import 'dart:ui';
import 'package:flutter/material.dart';

class HijraDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> data;  const HijraDetailsScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      // 🛡️ تثبيت حجم الخط لمنع الـ Overflow
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // 🌌 الخلفية الموحدة (مثل الغزوات)
            Positioned.fill(
              child: Image.asset(
                "assets/images/baga.png",
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.black),
              ),
            ),

            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(color: Colors.black.withOpacity(0.8)),
              ),
            ),

            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Hero(
                    tag: data["title"] ?? "title_hero",
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 500),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(35),
                          border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.1), blurRadius: 20, spreadRadius: 5)
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(35),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              color: Colors.white.withOpacity(0.05),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildHeader(context),
                                  const Divider(color: Colors.white12, height: 1),
                                  Flexible(
                                    child: SingleChildScrollView(
                                      physics: const BouncingScrollPhysics(),
                                      padding: const EdgeInsets.all(25),
                                      child: Column(
                                        children: [
                                          if (data["icon"] != null)
                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 20),
                                              child: Icon(data["icon"], color: const Color(0xFFD4AF37), size: 50),
                                            ),
                                          Text(
                                            data["content"] ?? "",
                                            textDirection: TextDirection.rtl,
                                            textAlign: TextAlign.justify,
                                            style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.8, fontFamily: "Cairo"),
                                          ),
                                          const SizedBox(height: 30),
                                          if (data["sanad"] != null || data["ref"] != null)
                                            _buildSourceTag(data["sanad"] ?? data["ref"] ?? ""),
                                          const SizedBox(height: 10),
                                        ],
                                      ),
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
                ),
              ),
            ),

            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
                  child: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Column(
        children: [
          Text(
            data["title"] ?? "",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 20, fontWeight: FontWeight.bold, fontFamily: "Cairo"),
          ),
          const SizedBox(height: 8),
          Container(height: 2, width: 40, decoration: BoxDecoration(color: const Color(0xFFD4AF37), borderRadius: BorderRadius.circular(10))),
        ],
      ),
    );
  }

  Widget _buildSourceTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.menu_book_rounded, color: Color(0xFFD4AF37), size: 16),
          const SizedBox(width: 8),
          Flexible(
            child: Text(text, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 12, fontStyle: FontStyle.italic, fontFamily: "Cairo")),
          ),
        ],
      ),
    );
  }
}