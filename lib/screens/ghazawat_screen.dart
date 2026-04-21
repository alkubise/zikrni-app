import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'ghazwa_details_screen.dart';

class GhazawatScreen extends StatefulWidget {
  const GhazawatScreen({super.key});

  @override
  _GhazawatScreenState createState() => _GhazawatScreenState();
}

class _GhazawatScreenState extends State<GhazawatScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.0;

  final List<Map<String, String>> allGhazawat = const [
    {"title": "بدر الكبرى", "date": "2 هـ", "desc": "أول انتصار عظيم للمسلمين", "icon": "⚔️"},
    {"title": "أحد", "date": "3 هـ", "desc": "درس عظيم في الطاعة والصبر", "icon": "🛡️"},
    {"title": "الخندق", "date": "5 هـ", "desc": "دفاع بطولي وتحالف الأحزاب", "icon": "🕳️"},
    {"title": "خيبر", "date": "7 هـ", "desc": "فتح حصون اليهود المنيعة", "icon": "🏰"},
    {"title": "فتح مكة", "date": "8 هـ", "desc": "النصر المبين ودخول الناس في دين الله", "icon": "🕋"},
    {"title": "حنين", "date": "8 هـ", "desc": "الثبات بعد الهزيمة والنصر النهائي", "icon": "🏹"},
    {"title": "تبوك", "date": "9 هـ", "desc": "غزوة العسرة وهيبة الدولة الإسلامية", "icon": "🏜️"},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        setState(() {
          _scrollProgress = (_scrollController.offset / _scrollController.position.maxScrollExtent).clamp(0.0, 1.0);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      // تثبيت حجم الخط لمنع الأخطاء في الشاشات المختلفة
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Positioned.fill(child: Image.asset("assets/images/baga.png", fit: BoxFit.cover)),
            Positioned.fill(child: Container(color: Colors.black.withOpacity(0.8))),

            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildSimpleAppBar(),
                SliverToBoxAdapter(
                  child: LinearProgressIndicator(
                      value: _scrollProgress,
                      backgroundColor: Colors.white10,
                      color: const Color(0xFFD4AF37),
                      minHeight: 2
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                  sliver: AnimationLimiter(
                    child: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildTimelineItem(index),
                        childCount: allGhazawat.length,
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
        title: Text("غزوات الرسول ﷺ", style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontFamily: "Cairo", fontSize: 20)),
      ),
    );
  }

  Widget _buildTimelineItem(int index) {
    final item = allGhazawat[index];
    bool isLast = index == allGhazawat.length - 1;

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
          const SizedBox(width: 20),
          Expanded(
            child: AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 600),
              child: SlideAnimation(
                horizontalOffset: 50,
                child: FadeInAnimation(
                  child: InteractiveGlassCard(item: item),
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
      bottom: 30, left: 20, right: 20,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFFD4AF37),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 10)],
          ),
          child: const Center(child: Text("العودة للفهرس", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: "Cairo"))),
        ),
      ),
    );
  }
}

class InteractiveGlassCard extends StatefulWidget {
  final Map<String, String> item;
  const InteractiveGlassCard({super.key, required this.item});

  @override
  _InteractiveGlassCardState createState() => _InteractiveGlassCardState();
}

class _InteractiveGlassCardState extends State<InteractiveGlassCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => GhazwaDetailsScreen(data: Map<String, dynamic>.from(widget.item)),
        ));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_scale), // تم التصحيح إلى نقطتين
        margin: const EdgeInsets.only(bottom: 30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
          color: Colors.white.withOpacity(0.05),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(widget.item["icon"]!, style: const TextStyle(fontSize: 24)),
                      Text(widget.item["date"]!, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Hero(
                    tag: widget.item["title"]!,
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                          widget.item["title"]!,
                          style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold, fontFamily: "Cairo")
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                      widget.item["desc"]!,
                      style: const TextStyle(color: Colors.white70, fontSize: 14, fontFamily: "Cairo", height: 1.4)
                  ),

                  // --- القسم الجديد الذي طلبته ---
                  const Divider(color: Colors.white10, height: 30),
                  Row(
                    children: [
                      const Text(
                          "عرض تفاصيل الأحداث",
                          style: TextStyle(color: Color(0xFFD4AF37), fontSize: 12, fontFamily: "Cairo", fontWeight: FontWeight.w500)
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFD4AF37), size: 10),
                    ],
                  ),
                  // ------------------------------
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
  _PulseDotState createState() => _PulseDotState();
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
          scale: Tween(begin: 1.0, end: 2.5).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut)),
          child: FadeTransition(
              opacity: Tween(begin: 0.5, end: 0.0).animate(_controller),
              child: Container(width: 15, height: 15, decoration: const BoxDecoration(color: Color(0xFFD4AF37), shape: BoxShape.circle))
          )
      ),
      Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFD4AF37), shape: BoxShape.circle)),
    ]);
  }
}