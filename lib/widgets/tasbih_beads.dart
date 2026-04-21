import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TasbihScreen extends StatefulWidget {
  @override
  _TasbihScreenState createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen>
    with TickerProviderStateMixin {
  int counter = 0;
  int index = 0;

  List<int> targets = [33, 100, 1000];
  int targetIndex = 0;

  List<String> azkar = [
    "سُبْحَانَ اللَّهِ",
    "الْحَمْدُ لِلَّهِ",
    "اللَّهُ أَكْبَرُ",
    "لَا إِلَهَ إِلَّا اللَّهُ"
  ];

  late AnimationController scaleController;

  @override
  void initState() {
    super.initState();
    loadData();

    scaleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 150),
      lowerBound: 0.9,
      upperBound: 1.05,
    )..value = 1;
  }

  int get target => targets[targetIndex];

  void increment() async {
    scaleController.forward().then((_) => scaleController.reverse());

    setState(() => counter++);


    if (counter % target == 0) {
      setState(() {
        targetIndex = (targetIndex + 1) % targets.length;
      });
    }

    saveData();
  }

  void reset() {
    setState(() => counter = 0);
    saveData();
  }

  void nextZikr() {
    setState(() => index = (index + 1) % azkar.length);
  }

  void previousZikr() {
    setState(() => index = (index - 1) % azkar.length);
  }

  double get progress => (counter % target) / target;

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt("counter", counter);
    prefs.setInt("index", index);
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      counter = prefs.getInt("counter") ?? 0;
      index = prefs.getInt("index") ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isCompleted = counter % target == 0 && counter != 0;

    return Scaffold(
      body: Stack(
        children: [

          /// 🌌 الخلفية (صورة)
          Positioned.fill(
            child: Image.asset(
              "assets/images/splash_background.png",
              fit: BoxFit.cover,
            ),
          ),

          /// 🔳 طبقة تعتيم خفيفة
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.6),
            ),
          ),

          /// 🧊 المحتوى
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),

                child: Container(
                  padding: EdgeInsets.all(25),
                  margin: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white24),
                  ),

                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      /// 🕌 الذكر (3D Card)
                      GestureDetector(
                        onHorizontalDragEnd: (details) {
                          if (details.primaryVelocity! > 0) {
                            previousZikr();
                          } else {
                            nextZikr();
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          decoration: BoxDecoration(
                            color: Color(0xFF0A122A),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(6, 6),
                                blurRadius: 15,
                              ),
                              BoxShadow(
                                color: Colors.blueGrey.shade800,
                                offset: Offset(-6, -6),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              AnimatedSwitcher(
                                duration: Duration(milliseconds: 400),
                                child: Text(
                                  azkar[index],
                                  key: ValueKey(index),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 34,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              Container(
                                width: 80,
                                height: 2,
                                color: Colors.amber,
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 40),

                      /// 🔵 العداد
                      GestureDetector(
                        onTap: increment,
                        child: ScaleTransition(
                          scale: scaleController,
                          child: CustomPaint(
                            painter: CirclePainter(progress),
                            child: Container(
                              width: 150,
                              height: 150,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF0A122A),
                                boxShadow: [
                                  BoxShadow(
                                    color: isCompleted
                                        ? Colors.amber.withOpacity(0.8)
                                        : Colors.cyanAccent.withOpacity(0.5),
                                    blurRadius: isCompleted ? 40 : 20,
                                    spreadRadius: isCompleted ? 5 : 1,
                                  ),
                                ],
                              ),
                              child: Text(
                                "$counter",
                                style: TextStyle(
                                  fontSize: 42,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 15),

                      Text(
                        "الهدف: $target",
                        style: TextStyle(color: Colors.white70),
                      ),

                      SizedBox(height: 25),

                      /// 🎮 أزرار
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
                        children: [
                          iconBtn(Icons.refresh, reset),
                          iconBtn(Icons.save, () {}),
                          iconBtn(Icons.notifications, () {}),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget iconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF0A122A),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              offset: Offset(6, 6),
              blurRadius: 12,
            ),
            BoxShadow(
              color: Colors.blueGrey,
              offset: Offset(-6, -6),
              blurRadius: 12,
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

/// 🎯 Progress Circle
class CirclePainter extends CustomPainter {
  final double progress;

  CirclePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    final paintBg = Paint()
      ..color = Colors.white24
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;

    final paintProgress = Paint()
      ..shader = SweepGradient(
        colors: [Colors.cyan, Colors.blue],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, paintBg);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      paintProgress,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}