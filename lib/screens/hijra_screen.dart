import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../data/hijra_data.dart';
import 'hijra_details_screen.dart';

class HijraScreen extends StatelessWidget {
  const HijraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🛡️ تثبيت حجم الخط لمنع الـ Overflow الناتج عن إعدادات النظام
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // 🌌 الخلفية الموحدة مثل الغزوات (baga.png)
            Positioned.fill(
              child: Image.asset("assets/images/baga.png", fit: BoxFit.cover),
            ),
            Positioned.fill(child: Container(color: Colors.black.withOpacity(0.8))),

            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSimpleAppBar(),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 150), // زيادة الـ bottom padding لراحة التمرير
                  sliver: AnimationLimiter(
                    child: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final item = HijraData.data[index];
                          return _buildTimelineItem(context, item, index);
                        },
                        childCount: HijraData.data.length,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            _buildFloatingBackButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleAppBar() {
    return const SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: SizedBox(),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text("رحلة الهجرة النبوية",
            style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontFamily: "Cairo", fontSize: 20)),
      ),
    );
  }

  Widget _buildTimelineItem(BuildContext context, Map<String, dynamic> item, int index) {
    bool isLast = index == HijraData.data.length - 1;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              const PulseDot(),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0xFFD4AF37), Colors.transparent],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 15), // تقليل المسافة قليلاً لتوفير مساحة للكرت
          Expanded(
            child: AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 600),
              child: SlideAnimation(
                horizontalOffset: 50,
                child: FadeInAnimation(
                  child: InteractiveHijraCard(item: item, index: index),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingBackButton(BuildContext context) {
    return Positioned(
      bottom: 30, left: 25, right: 25,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFFD4AF37),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 10)],
          ),
          child: const Center(
              child: Text("العودة للفهرس",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: "Cairo"))),
        ),
      ),
    );
  }
}

class InteractiveHijraCard extends StatefulWidget {
  final Map<String, dynamic> item;
  final int index;
  const InteractiveHijraCard({super.key, required this.item, required this.index});

  @override
  State<InteractiveHijraCard> createState() => _InteractiveHijraCardState();
}

class _InteractiveHijraCardState extends State<InteractiveHijraCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (context, animation, secondaryAnimation) => HijraDetailsScreen(data: widget.item),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_scale),
        margin: const EdgeInsets.only(bottom: 25),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
          color: Colors.white.withOpacity(0.05),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.all(18), // تقليل البادينج قليلاً لحل الـ 1 بكسل
              child: Column(
                mainAxisSize: MainAxisSize.min, // مهم جداً لمنع التمدد الزائد
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFD4AF37).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                        child: Text("المحطة ${widget.index + 1}",
                            style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                      const Icon(Icons.location_on_rounded, color: Color(0xFFD4AF37), size: 18),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Hero(
                    tag: widget.item["title"] ?? "title_${widget.index}",
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        widget.item["title"] ?? "",
                        maxLines: 1, // منع العنوان من النزول لسطر ثاني يسبب Overflow
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "Cairo"),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(color: Colors.white10, height: 20), // تقليل ارتفاع الفاصل
                  Row(
                    children: [
                      const Expanded( // تغليف النص بـ Expanded ليأخذ المساحة المتاحة فقط
                        child: Text("عرض تفاصيل الحدث",
                            style: TextStyle(color: Color(0xFFD4AF37), fontSize: 12, fontFamily: "Cairo", fontWeight: FontWeight.w500)),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFD4AF37), size: 10),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PulseDot extends StatefulWidget {
  const PulseDot({super.key});
  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot> with SingleTickerProviderStateMixin {
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
    return Stack(alignment: Alignment.center, children: [
      ScaleTransition(
          scale: Tween(begin: 1.0, end: 2.2).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
          child: FadeTransition(
              opacity: Tween(begin: 0.5, end: 0.0).animate(_controller),
              child: Container(width: 15, height: 15, decoration: const BoxDecoration(color: Color(0xFFD4AF37), shape: BoxShape.circle)))),
      Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFD4AF37), shape: BoxShape.circle)),
    ]);
  }
}