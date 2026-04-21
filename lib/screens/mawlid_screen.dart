import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class MawlidScreen extends StatefulWidget {
  const MawlidScreen({super.key});

  @override  State<MawlidScreen> createState() => _MawlidScreenState();
}

class _MawlidScreenState extends State<MawlidScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.0;

  final List<Map<String, dynamic>> mawlidData = const [
    {
      "title": "النسب الشريف - الأصل المبارك",
      "tag": "سلسلة الذهب",
      "content": "هو محمد ﷺ بن عبد الله بن عبد المطلب، من أشرف بيوت العرب نسبًا ومكانة. قال ﷺ: «إن الله اصطفى كنانة من ولد إسماعيل، واصطفى قريشًا من كنانة، واصطفى بني هاشم من قريش، واصطفاني من بني هاشم».",
      "icon": Icons.family_restroom_rounded,
    },
    {
      "title": "سلسلة النسب إلى عدنان",
      "tag": "أصح الأنساب",
      "content": "محمد ﷺ بن عبد الله بن عبد المطلب بن هاشم بن عبد مناف بن قصي بن كلاب بن مرة بن كعب... وصولاً إلى عدنان من ذرية نبي الله إسماعيل بن إبراهيم عليهما السلام.",
      "icon": Icons.account_tree_rounded,
    },
    {
      "title": "بشارة الأنبياء (المولد)",
      "tag": "فجر النبوة",
      "content": "وُلد النبي ﷺ في مكة المكرمة في عام الفيل، يوم الاثنين من شهر ربيع الأول، ليضيء الدنيا بنور الهداية بعد قرون من الجاهلية والظلام.",
      "icon": Icons.auto_awesome_rounded,
    },
    {
      "title": "طهارة المولد",
      "tag": "الاختيار الإلهي",
      "content": "قال ﷺ: «خرجت من نكاح ولم أخرج من سفاح من لدن آدم إلى أن ولدني أبي وأمي». وهذا دليل على حفظ الله لهذا النسب من أدناس الجاهلية.",
      "icon": Icons.verified_user_rounded,
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
            Positioned.fill(
              child: Image.asset("assets/images/baga.png", fit: BoxFit.cover),
            ),
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
                    minHeight: 2,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 150),
                  sliver: AnimationLimiter(
                    child: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildTimelineItem(index),
                        childCount: mawlidData.length,
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
        title: Text(
          "المولد والنسب الشريف",
          style: TextStyle(
            color: Color(0xFFD4AF37),
            fontFamily: "Cairo",
            fontWeight: FontWeight.bold,
            fontSize: 18,
            shadows: [Shadow(color: Colors.black, blurRadius: 10)],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem(int index) {
    final item = mawlidData[index];
    bool isLast = index == mawlidData.length - 1;

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
              duration: const Duration(milliseconds: 600),
              child: SlideAnimation(
                horizontalOffset: 50,
                child: FadeInAnimation(
                  child: _InteractiveMawlidCard(item: item),
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
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: "Cairo", fontSize: 16)),
          ),
        ),
      ),
    );
  }
}

class _InteractiveMawlidCard extends StatefulWidget {
  final Map<String, dynamic> item;
  const _InteractiveMawlidCard({required this.item});

  @override
  State<_InteractiveMawlidCard> createState() => _InteractiveMawlidCardState();
}

class _InteractiveMawlidCardState extends State<_InteractiveMawlidCard> {
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
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              // ✅ تغيير Column إلى ListView (shrinkWrap) يحل مشكلة الـ 1 بكسل في الويب
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(widget.item['icon'], color: const Color(0xFFD4AF37), size: 22),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10)),
                          child: Text(widget.item["tag"],
                              style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.item["title"],
                      style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold, fontFamily: "Cairo"),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.item["content"],
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                          height: 1.6,
                          fontFamily: "Cairo"
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(height: 1, color: Colors.white10),
                    const SizedBox(height: 16),
                    Row(
                      children: const [
                        // ✅ تحويل Expanded إلى Flexible يحل تشنج بكسلات الويب
                        Flexible(
                          child: Text("تأمل في عظمة النسب الشريف",
                              style: TextStyle(color: Color(0xFFD4AF37), fontSize: 11, fontFamily: "Cairo", fontWeight: FontWeight.w500)),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.auto_awesome, color: Color(0xFFD4AF37), size: 12),
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