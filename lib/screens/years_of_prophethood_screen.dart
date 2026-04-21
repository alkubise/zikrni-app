import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class YearsOfProphethoodScreen extends StatefulWidget {
  const YearsOfProphethoodScreen({super.key});

  @override
  State<YearsOfProphethoodScreen> createState() => _YearsOfProphethoodScreenState();
}

class _YearsOfProphethoodScreenState extends State<YearsOfProphethoodScreen> {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<double> _scrollNotifier = ValueNotifier(0.0);

  // بيانات مفصلة جداً للمرحلتين مع السند والتوثيق
  final List<Map<String, dynamic>> historyData = const [
    {
      "title": "المرحلة المكية (بناء العقيدة)",
      "tag": "13 سنة",
      "content": "هي مرحلة التأسيس الروحي والعقدي، وتنقسم لثلاث فترات:\n"
          "1. الدعوة السرية (3 سنوات): ركزت على بناء الرعيل الأول في دار الأرقم.\n"
          "2. الجهر بالدعوة: بدأت بصعود الصفا وما تبعها من مواجهة قريش.\n"
          "3. الحصار والابتلاء: شملت مقاطعة شعب أبي طالب، عام الحزن، رحلة الطائف، وعرض الدعوة على القبائل حتى بيعة العقبة التي مهدت للهجرة.",
      "book": "السيرة النبوية (ابن هشام) / الرحيق المختوم",
      "sanad": "عن ابن عباس رضي الله عنهما في مدة مكثه بمكة",
      "ref_no": "صحيح البخاري (3902)",
      "icon": Icons.fort_rounded,
    },
    {
      "title": "المرحلة المدنية (بناء الدولة)",
      "tag": "10 سنوات",
      "content": "مرحلة التشريع والتمكين، وأهم ركائزها:\n"
          "1. التأسيس: بناء المسجد النبوي، المؤاخاة بين المهاجرين والأنصار، وكتابة وثيقة المدينة.\n"
          "2. الجهاد: الغزوات الكبرى (بدر، أحد، الخندق) حتى صلح الحديبية.\n"
          "3. الفتح والوفود: فتح مكة في العام الثامن، وانتشار الإسلام في جزيرة العرب، وصولاً لحجة الوداع واكتمال الدين.",
      "book": "زاد المعاد (ابن القيم) / صحيح مسلم",
      "sanad": "عن أنس بن مالك رضي الله عنه",
      "ref_no": "صحيح مسلم (2353)",
      "icon": Icons.mosque_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        _scrollNotifier.value = (_scrollController.offset /
            (_scrollController.position.maxScrollExtent > 0
                ? _scrollController.position.maxScrollExtent
                : 1)).clamp(0.0, 1.0);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollNotifier.dispose();
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
            // إصلاح خطأ ParentDataWidget: الـ Positioned هو الابن المباشر للـ Stack
            Positioned.fill(
              child: ValueListenableBuilder<double>(
                valueListenable: _scrollNotifier,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, -value * 50),
                    child: Image.asset(
                      "assets/images/baga.png",
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[900]),
                    ),
                  );
                },
              ),
            ),
            Positioned.fill(child: Container(color: Colors.black.withOpacity(0.85))),

            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 150),
                  sliver: AnimationLimiter(
                    child: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildTimelineItem(index),
                        childCount: historyData.length,
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

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: const SizedBox(),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: const Text(
          "السيرة النبوية الموثقة",
          style: TextStyle(
              color: Color(0xFFD4AF37),
              fontFamily: "Cairo",
              fontWeight: FontWeight.bold,
              fontSize: 18
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem(int index) {
    final item = historyData[index];
    bool isLast = index == historyData.length - 1;

    return IntrinsicHeight( // يضمن أن العمود يأخذ طول الكرت تلقائياً
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
          const SizedBox(width: 15),
          Expanded(
            child: AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 600),
              child: FadeInAnimation(
                child: _DetailedHistoryCard(item: item),
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
          height: 55,
          decoration: BoxDecoration(
            color: const Color(0xFFD4AF37),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 10)],
          ),
          child: const Center(
            child: Text("العودة للقائمة",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: "Cairo")),
          ),
        ),
      ),
    );
  }
}

class _DetailedHistoryCard extends StatelessWidget {
  final Map<String, dynamic> item;
  const _DetailedHistoryCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(item['icon'], color: const Color(0xFFD4AF37), size: 28),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(item["tag"],
                          style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(item["title"],
                    style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold, fontFamily: "Cairo")),
                const SizedBox(height: 10),
                Text(item["content"],
                    textDirection: TextDirection.rtl,
                    style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14, height: 1.6, fontFamily: "Cairo")),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Divider(color: Colors.white10, thickness: 1),
                ),

                _buildInfoRow(Icons.menu_book_rounded, "المصدر:", item['book']),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.verified_user_rounded, "السند:", item['sanad']),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.tag_rounded, "المرجع:", item['ref_no']),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: const Color(0xFFD4AF37).withOpacity(0.7)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 11, fontWeight: FontWeight.bold, fontFamily: "Cairo")),
        const SizedBox(width: 6),
        Expanded(
          child: Text(value,
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11, fontFamily: "Cairo")),
        ),
      ],
    );
  }
}

class PulseDot extends StatelessWidget {
  const PulseDot({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14, height: 14,
      decoration: BoxDecoration(
          color: const Color(0xFFD4AF37),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: const Color(0xFFD4AF37).withOpacity(0.5), blurRadius: 6)]
      ),
    );
  }
}