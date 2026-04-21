import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class MiraclesScreen extends StatefulWidget {
  const MiraclesScreen({super.key});

  @override
  State<MiraclesScreen> createState() => _MiraclesScreenState();
}

class _MiraclesScreenState extends State<MiraclesScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.0;

  final List<Map<String, dynamic>> miraclesData = const [
    {
      "title": "🌙 انشقاق القمر",
      "tag": "معجزة حسية",
      "content": "انشق القمر إلى فلقتين ظاهرًا للعيان أمام كفار قريش حين طلبوا آية تدل على صدق نبوته ﷺ.",
      "ref": "البخاري (4864) / مسلم (2802)",
      "icon": Icons.brightness_3_rounded,
    },
    {
      "title": "💧 نبع الماء من بين أصابعه",
      "tag": "بركة جسدية",
      "content": "نبع الماء من بين أصابع النبي ﷺ في عدة مواقف، مما مكن الجيش من الوضوء والشرب وهم بالألوف.",
      "ref": "البخاري (3576) / مسلم (1856)",
      "icon": Icons.water_drop_rounded,
    },
    {
      "title": "🔮 الإخبار بالمغيبات",
      "tag": "معجزة غيبية",
      "content": "أخبر ﷺ بأحداث مستقبلية وفتوحات وقعت بدقة مذهلة بعد وفاته بسنوات طويلة كما وصفها تماماً.",
      "ref": "البخاري (3029) / مسلم (2890)",
      "icon": Icons.visibility_rounded,
    },
    {
      "title": "📖 المعجزة الكبرى: القرآن",
      "tag": "معجزة خالدة",
      "content": "القرآن الكريم هو المعجزة الخالدة التي تحدى الله بها الثقلين أن يأتوا بمثله، في بلاغته وتشريعه.",
      "ref": "سورة الإسراء - آية 88",
      "icon": Icons.menu_book_rounded,
    },
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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // 🌌 توحيد الخلفية مثل الغزوات والهجرة
            Positioned.fill(
              child: Image.asset("assets/images/baga.png", fit: BoxFit.cover),
            ),
            Positioned.fill(child: Container(color: Colors.black.withOpacity(0.8))),

            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildModernAppBar(),
                SliverToBoxAdapter(
                  child: LinearProgressIndicator(
                    value: _scrollProgress,
                    backgroundColor: Colors.white10,
                    color: const Color(0xFFD4AF37),
                    minHeight: 2,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 150),
                  sliver: AnimationLimiter(
                    child: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildTimelineItem(index),
                        childCount: miraclesData.length,
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

  Widget _buildModernAppBar() {
    return const SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: SizedBox(),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text("دلائل المعجزات النبوية",
          style: TextStyle(color: Color(0xFFD4AF37), fontFamily: "Cairo", fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildTimelineItem(int index) {
    final item = miraclesData[index];
    bool isLast = index == miraclesData.length - 1;

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
          const SizedBox(width: 16),
          Expanded(
            child: AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 700),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _InteractiveMiracleCard(item: item),
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
      bottom: 30, left: 30, right: 30,
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
            child: Text("العودة للفهرس", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: "Cairo")),
          ),
        ),
      ),
    );
  }
}

class _InteractiveMiracleCard extends StatefulWidget {
  final Map<String, dynamic> item;
  const _InteractiveMiracleCard({required this.item});

  @override
  State<_InteractiveMiracleCard> createState() => _InteractiveMiracleCardState();
}

class _InteractiveMiracleCardState extends State<_InteractiveMiracleCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_scale),
        margin: const EdgeInsets.only(bottom: 30),
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
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(widget.item['icon'], color: const Color(0xFFD4AF37), size: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10)),
                          child: Text(widget.item["tag"],
                              style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(widget.item["title"],
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "Cairo"),
                    ),
                    const SizedBox(height: 10),
                    Text(widget.item["content"],
                      textDirection: TextDirection.rtl,
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14, height: 1.6, fontFamily: "Cairo"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Container(height: 1, color: Colors.white10),
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Text(widget.item["ref"],
                              style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 11, fontStyle: FontStyle.italic)),
                        ),
                      ],
                    ),
                  ],
                ),
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