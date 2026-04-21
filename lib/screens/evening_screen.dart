import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../controllers/zikr_controller.dart';
import '../services/theme_service.dart';

class EveningAzkarScreen extends StatelessWidget {
  const EveningAzkarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              ThemeService.instance.backgroundImage,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.6)),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(context),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(15, 20, 15, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    
                    _buildSectionHeader("حصن الحماية واليقين"),
                    const DhikrCard(
                      text: "سيد الاستغفار",
                      fullText: "اللهم أنت ربي لا إله إلا أنت، خلقتني وأنا عبدك، وأنا على عهدك ووعدك ما استطعت، أعوذ بك من شر ما صنعت، أبوء لك بنعمتك عليّ، وأبوء بذنبي، فاغفر لي، فإنه لا يغفر الذنوب إلا أنت",
                      reference: "صحيح البخاري (6306)",
                      explanation: "من قالها موقناً بها حين يمسي، فمات من ليلته دخل الجنة. وهو أعظم صيغ الاستغفار وأجمعها للعبودية.",
                      count: 1,
                    ),
                    const DhikrCard(
                      text: "آية الكرسي",
                      fullText: "اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ",
                      reference: "صحيح البخاري (2311)",
                      explanation: "من قرأها مساءً لم يزل عليه من الله حافظ ولا يقربه شيطان حتى يصبح.",
                      count: 1,
                    ),
                    const DhikrCard(
                      text: "الإخلاص والمعوذتين",
                      fullText: "قُلْ هُوَ اللَّهُ أَحَدٌ... قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ... قُلْ أَعُوذُ بِرَبِّ النَّاسِ...",
                      reference: "سنن أبي داود (5082) والترمذي (3575) - صححه الألباني",
                      explanation: "تقرأ ثلاث مرات. تكفيك من كل شيء (أي من كل سوء وشر).",
                      count: 3,
                    ),
                    const DhikrCard(
                      text: "خواتيم سورة البقرة",
                      fullText: "آمَنَ الرَّسُولُ بِمَا أُنزِلَ إِلَيْهِ مِن رَّبِّهِ وَالْمُؤْمِنُونَ... (آخر آيتين)",
                      reference: "صحيح البخاري (4008)، مسلم (807)",
                      explanation: "من قرأهما في ليلة كفتاه. أي كفتاه من شرور الإنس والجن، وقيل كفتاه عن قيام الليل.",
                      count: 1,
                    ),

                    _buildSectionHeader("أذكار المساء الثابتة"),
                    const DhikrCard(
                      text: "إقرار العبودية والملك",
                      fullText: "أَمْسَيْنا وَأَمْسَى المُلْكُ للهِ، وَالحَمْدُ للهِ، لا إِلهَ إلاَّ اللهُ وَحْدَهُ لا شَرِيكَ لَهُ، لَهُ المُلْكُ وَلَهُ الحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، رَبِّ أَسْأَلُكَ خَيْرَ مَا فِي هذِهِ اللَّيْلَةِ وَخَيْرَ مَا بَعْدَهَا، وَأَعُوذُ بِكَ مِنْ شَرِّ مَا فِي هذِهِ اللَّيْلَةِ وَشَرِّ مَا بَعْدَهَا، رَبِّ أَعُوذُ بِكَ مِنَ الكَسَلِ وَسُوءِ الكِبَرِ، رَبِّ أَعُوذُ بِكَ مِنْ عَذَابٍ فِي النَّارِ وَعَذَابٍ فِي القَبْرِ",
                      reference: "صحيح مسلم (2723)",
                      explanation: "دعاء جامع يجمع بين الحمد والاستعاذة من عذاب القبر وعذاب النار.",
                      count: 1,
                    ),
                    const DhikrCard(
                      text: "الاستعاذة بكلمات الله",
                      fullText: "أَعُوذُ بِكَلِمَاتِ اللهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ",
                      reference: "صحيح مسلم (2708)",
                      explanation: "تقرأ ثلاث مرات. من قالها لم تضره حمة (لدغة أو سم) في تلك الليلة.",
                      count: 3,
                    ),
                    const DhikrCard(
                      text: "بسم الله الذي لا يضر",
                      fullText: "بِسْمِ اللهِ الَّذِي لا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الأَرْضِ وَلا فِي السَّمَاءِ وَهُوَ السَّمِيعُ العَلِيمُ",
                      reference: "سنن الترمذي (3388) - صحيح",
                      explanation: "تقرأ ثلاث مرات. من قالها لم يصبه بلاء فجأة ولم يضره شيء.",
                      count: 3,
                    ),
                    const DhikrCard(
                      text: "الرضا بالله ديناً",
                      fullText: "رَضِيتُ بِاللهِ رَبًّا، وَبِالإِسْلامِ دِينًا، وَبِمُحَمَّدٍ ﷺ نَبِيًّا",
                      reference: "صحيح مسلم (34)، سنن النسائي - صحيح",
                      explanation: "من قالها حين يمسي ثلاثاً كان حقاً على الله أن يرضيه يوم القيامة.",
                      count: 3,
                    ),

                    _buildSectionHeader("التسبيح والتهليل والتحميد"),
                    const DhikrCard(
                      text: "التسبيح المعتاد",
                      fullText: "سُبْحَانَ اللهِ وَبِحَمْدِهِ",
                      reference: "صحيح مسلم (2692)",
                      explanation: "تقرأ مائة مرة. من قالها لم يأتِ أحد يوم القيامة بأفضل مما جاء به إلا من قال مثل قوله أو زاد.",
                      count: 100,
                    ),
                    const DhikrCard(
                      text: "التهليل الجامع",
                      fullText: "لا إِلهَ إِلاَّ اللهُ وَحْدَهُ لا شَرِيكَ لَهُ، لَهُ المُلْكُ وَلَهُ الحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ",
                      reference: "صحيح البخاري (3293)، مسلم (2691)",
                      explanation: "مائة مرة. كانت له عدل عشر رقاب، وكتبت له مائة حسنة، ومحيت عنه مائة سيئة.",
                      count: 100,
                    ),
                    const DhikrCard(
                      text: "جوهرة الذكر",
                      fullText: "سُبْحَانَ اللهِ وَبِحَمْدِهِ، عَدَدَ خَلْقِهِ، وَرِضَا نَفْسِهِ، وَزِنَةَ عَرْشِهِ، وَمِدَادَ كَلِمَاتِهِ",
                      reference: "صحيح مسلم (2726)",
                      explanation: "تقرأ ثلاث مرات. ذكر ثقيل في الميزان يزن أذكاراً كثيرة في وقت قصير.",
                      count: 3,
                    ),
                    const DhikrCard(
                      text: "الحول والقوة",
                      fullText: "لا حَوْلَ وَلا قُوَّةَ إِلاَّ بِاللهِ",
                      reference: "صحيح البخاري (6384)، مسلم (2704)",
                      explanation: "كنز من كنوز الجنة، وبها يستعين العبد على مشاق الحياة والعبادة.",
                      count: 10,
                    ),

                    _buildSectionHeader("الدعاء بالعافية والهدى"),
                    const DhikrCard(
                      text: "سؤال العافية",
                      fullText: "اللهم إني أسألك العافية في الدنيا والآخرة، اللهم إني أسألك العفو والعافية في ديني ودنياي وأهلي ومالي، اللهم استر عوراتي وآمن روعاتي، اللهم احفظني من بين يدي ومن خلفي وعن يميني وعن شمالي ومن فوقي وأعوذ بعظمتك أن أغتال من تحتي",
                      reference: "سنن أبي داود (5074)، ابن ماجه (3871) - صحيح",
                      explanation: "دعاء عظيم للحفظ الإلهي من الجهات الست وتحصين الأهل والمال.",
                      count: 1,
                    ),
                    const DhikrCard(
                      text: "يا حي يا قيوم",
                      fullText: "يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ، أَصْلِحْ لِي شَأْنِي كُلَّهُ، وَلا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ",
                      reference: "المستدرك للحاكم (1/545) - صححه الألباني",
                      explanation: "وصية النبي ﷺ لابنته فاطمة. طلب الإصلاح الشامل للشؤون كلها والافتقار إلى الله.",
                      count: 1,
                    ),
                    const DhikrCard(
                      text: "أمسيت أثني عليك",
                      fullText: "اللهم ما أمسى بي من نعمة أو بأحد من خلقك فمنك وحدك لا شريك لك، فلك الحمد ولك الشكر",
                      reference: "سنن أبي داود (5073) - حسن",
                      explanation: "من قالها حين يمسي فقد أدى شكر ليلته.",
                      count: 1,
                    ),
                    const DhikrCard(
                      text: "الصلاة على النبي",
                      fullText: "اللهم صلِّ وسلم على نبينا محمد",
                      reference: "صحيح مسلم (408)، البخاري (6357)",
                      explanation: "تقرأ عشر مرات. صلاة الله على العبد عشر مرات ومحو الخطايا ورفع الدرجات.",
                      count: 10,
                    ),

                    _buildSectionHeader("الافتقار والتوحيد"),
                    const DhikrCard(
                      text: "إخلاص التوحيد",
                      fullText: "اللَّهُمَّ إِنِّي أَمْسَيْتُ أُشْهِدُكَ، وَأُشْهِدُ حَمَلَةَ عَرْشِكَ، وَمَلائِكَتِكَ، وَجَمِيعَ خَلْقِكَ، أَنَّكَ أَنْتَ اللهُ لا إِلهَ إِلاَّ أَنْتَ وَحْدَهُ لا شَرِيكَ لَهُ، وَأَنَّ مُحَمَّدًا عَبْدُكَ وَرَسُولُكَ",
                      reference: "سنن أبي داود (5069) - حسن",
                      explanation: "من قالها حين يمسي أربع مرات أعتقه الله من النار.",
                      count: 4,
                    ),
                    const DhikrCard(
                      text: "الحسبي والموكل",
                      fullText: "حَسْبِيَ اللهُ لا إِلهَ إِلاَّ هُوَ عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ العَرْشِ العَظِيمِ",
                      reference: "سنن أبي داود (5081) - صحيح موقوفاً وله حكم الرفع",
                      explanation: "سبع مرات. من قالها كفاه الله ما أهمه من أمر الدنيا والآخرة.",
                      count: 7,
                    ),
                    const DhikrCard(
                      text: "التوبة الصادقة",
                      fullText: "أَسْتَغْفِرُ اللهَ وَأَتُوبُ إِلَيْهِ",
                      reference: "صحيح البخاري (6307)، مسلم (2702)",
                      explanation: "مائة مرة. استجابة لقول النبي ﷺ: 'توبوا إلى الله فإني أتوب في اليوم مائة مرة'.",
                      count: 100,
                    ),
                    const DhikrCard(
                      text: "ذكر الخضوع",
                      fullText: "اللهم عالم الغيب والشهادة فاطر السماوات والأرض رب كل شيء ومليكه، أشهد أن لا إله إلا أنت، أعوذ بك من شر نفسي ومن شر الشيطان وشركه، وأن أقترف على نفسي سوءاً أو أجره إلى مسلم",
                      reference: "سنن الترمذي (3392) - صحيح",
                      explanation: "دعاء وقاية من شرور النفس والوساوس الشيطانية والوقوع في الخطايا.",
                      count: 1,
                    ),
                  ]),
                ),
              ),
            ],
          ),

          _buildBottomNav(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 5),
      child: Row(
        children: [
          Container(width: 4, height: 15, decoration: BoxDecoration(color: const Color(0xFFD4AF37), borderRadius: BorderRadius.circular(10))),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(color: Colors.white30, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: "Cairo", letterSpacing: 1.2),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120.0,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFD4AF37), size: 20),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          "أذكار المساء",
          style: TextStyle(
            color: const Color(0xFFD4AF37),
            fontFamily: "Cairo",
            fontWeight: FontWeight.bold,
            fontSize: 22,
            shadows: [Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 10)],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Positioned(
      bottom: 30, left: 30, right: 30,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
            ),
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: const Center(
                child: Text(
                  "إتمام أذكار المساء",
                  style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontFamily: "Cairo"),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DhikrCard extends StatefulWidget {
  final String text;
  final String fullText;
  final String reference;
  final String explanation;
  final int count;

  const DhikrCard({
    super.key,
    required this.text,
    required this.fullText,
    required this.reference,
    required this.explanation,
    required this.count,
  });

  @override
  State<DhikrCard> createState() => _DhikrCardState();
}

class _DhikrCardState extends State<DhikrCard> {
  late int remaining;
  bool isCompleted = false;

  @override
  void initState() {
    super.initState();
    remaining = widget.count;
  }

  void decrease() {
    if (remaining > 0) {
      HapticFeedback.lightImpact();
      setState(() {
        remaining--;
        if (remaining == 0) {
          isCompleted = true;
          HapticFeedback.mediumImpact();
          ZikrController.instance.add(widget.text);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double progress = remaining / widget.count;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: isCompleted ? 0.6 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Colors.white.withOpacity(0.05),
          border: Border.all(
            color: isCompleted ? Colors.green.withOpacity(0.3) : const Color(0xFFD4AF37).withOpacity(0.2),
          ),
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
                      Expanded(
                        child: Text(
                          widget.text,
                          style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "Cairo"),
                        ),
                      ),
                      _buildCounter(progress),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    widget.fullText,
                    style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.8, fontFamily: "Amiri"),
                    textAlign: TextAlign.justify,
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 20),
                  _buildActions(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCounter(double progress) {
    return GestureDetector(
      onTap: decrease,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 55, height: 55,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 3.5,
              backgroundColor: Colors.white10,
              color: isCompleted ? Colors.green : const Color(0xFFD4AF37),
            ),
          ),
          Text(
            "$remaining",
            style: TextStyle(
              color: isCompleted ? Colors.green : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        _iconLabel(Icons.auto_awesome, "التفاصيل", () => _showDetails()),
        const SizedBox(width: 25),
        _iconLabel(Icons.copy_rounded, "نسخ", () {
          Clipboard.setData(ClipboardData(text: widget.fullText));
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("تم نسخ الذكر", style: TextStyle(fontFamily: "Cairo"))));
        }),
        const SizedBox(width: 25),
        _iconLabel(Icons.share_rounded, "مشاركة", () => Share.share("${widget.fullText}\n\nالمصدر: ${widget.reference}")),
      ],
    );
  }

  Widget _iconLabel(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: Colors.white30, size: 18),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white30, fontSize: 12, fontFamily: "Cairo")),
        ],
      ),
    );
  }

  void _showDetails() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
            border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars_rounded, color: Color(0xFFD4AF37), size: 40),
                const SizedBox(height: 20),
                Text(widget.explanation, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.8, fontFamily: "Cairo")),
                const SizedBox(height: 25),
                Text(widget.reference, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 12, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
