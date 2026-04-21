import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'ghazawat_screen.dart';
import 'hijra_screen.dart';
import 'miracles_screen.dart';
import 'mawlid_screen.dart';
import 'years_of_prophethood_screen.dart';

class SirahScreen extends StatefulWidget {
  const SirahScreen({super.key});

  @override
  State<SirahScreen> createState() => _SirahScreenState();
}

class _SirahScreenState extends State<SirahScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pathController;

  final List<Map<String, dynamic>> stations = [
    {"title": "الغزوات والتمكين", "screen": const GhazawatScreen(), "top": 0.20, "left": 0.53},
    {"title": "الهجرة النبوية", "screen": const HijraScreen(), "top": 0.38, "left": 0.23},
    {"title": "أبرز المعجزات", "screen": const MiraclesScreen(), "top": 0.54, "left": 0.73},
    {"title": "سنوات النبوة", "screen": const YearsOfProphethoodScreen(), "top": 0.70, "left": 0.28},
    {"title": "المولد النبوي", "screen": const MawlidScreen(), "top": 0.85, "left": 0.56},
  ];

  @override
  void initState() {
    super.initState();
    _pathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();
  }

  @override
  void dispose() {
    _pathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. الخلفية الثابتة
          Positioned.fill(
            child: Image.asset(
              "assets/images/baga.png",
              fit: BoxFit.fill,
            ),
          ),

          // 2. تعتيم فني خفيف للخلفية
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),

          // 3. رسم المسار المتحرك
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _pathController,
              builder: (context, child) {
                return CustomPaint(
                  painter: MapPathPainter(stations, _pathController.value),
                );
              },
            ),
          ),

          // 4. المحطات التفاعلية
          LayoutBuilder(
            builder: (context, constraints) {
              double h = constraints.maxHeight;
              double w = constraints.maxWidth;

              return AnimationLimiter(
                child: Stack(
                  children: [
                    // نافذة العنوان المحدثة (أقل شفافية ومسمى جديد)
                    Positioned(
                      top: 60,
                      left: 20,
                      right: 20,
                      child: _buildSpiritualHeader(),
                    ),

                    // رسم النقاط
                    ...stations.asMap().entries.map((entry) {
                      int index = entry.key;
                      var data = entry.value;

                      return Positioned(
                        top: h * data['top'] - 30,
                        left: w * data['left'] - 50,
                        child: AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 1000),
                          child: FadeInAnimation(
                            child: _buildStationContent(
                              context,
                              title: data['title'],
                              target: data['screen'],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              );
            },
          ),

          // 5. زر العودة
          Positioned(
            left: 20,
            bottom: 30,
            child: _buildBackButton(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSpiritualHeader() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          decoration: BoxDecoration(
            // تم زيادة التعتيم هنا (0.8 بدلاً من 0.4) لتصبح أقل شفافية
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5)),
          ),
          child: const Column(
            children: [
              Text(
                "سيرة المصطفى ﷺ", // المسمى الجديد
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontFamily: "Cairo",
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "رحلة الهدى والنور", // مسمى ثانوي واضح
                style: TextStyle(
                  color: Colors.white70,
                  fontFamily: "Cairo",
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStationContent(BuildContext context, {required String title, required Widget target}) {
    return GestureDetector(
      onTap: () => _navigateTo(context, target, title),
      child: Column(
        children: [
          Hero(
            tag: "hero-$title",
            child: const _PulseIcon(),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              // تم زيادة التعتيم هنا أيضاً لتناسق التصميم
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5)),
            ),
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: "Cairo"),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget screen, String title) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.7),
          border: Border.all(color: const Color(0xFFD4AF37), width: 2),
        ),
        child: const Icon(Icons.close_rounded, color: Color(0xFFD4AF37), size: 24),
      ),
    );
  }
}

class MapPathPainter extends CustomPainter {
  final List<Map<String, dynamic>> stations;
  final double progress;

  MapPathPainter(this.stations, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final path = Path();
    if (stations.isNotEmpty) {
      path.moveTo(size.width * stations.last['left'], size.height * stations.last['top']);

      for (int i = stations.length - 2; i >= 0; i--) {
        path.lineTo(size.width * stations[i]['left'], size.height * stations[i]['top']);
      }
    }

    PathMetrics pathMetrics = path.computeMetrics();
    for (PathMetric pathMetric in pathMetrics) {
      Path extractPath = pathMetric.extractPath(0, pathMetric.length * progress);
      canvas.drawPath(extractPath, paint);
    }
  }

  @override
  bool shouldRepaint(MapPathPainter oldDelegate) => oldDelegate.progress != progress;
}

class _PulseIcon extends StatefulWidget {
  const _PulseIcon();
  @override
  State<_PulseIcon> createState() => _PulseIconState();
}

class _PulseIconState extends State<_PulseIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ScaleTransition(
          scale: Tween(begin: 1.0, end: 2.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
          child: FadeTransition(
            opacity: Tween(begin: 0.5, end: 0.0).animate(_controller),
            child: Container(width: 35, height: 35, decoration: const BoxDecoration(color: Color(0xFFD4AF37), shape: BoxShape.circle)),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: const Color(0xFFD4AF37),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withOpacity(0.6),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ]
          ),
          child: const Icon(Icons.auto_awesome, color: Colors.black, size: 16),
        ),
      ],
    );
  }
}