import 'dart:ui';
import 'package:flutter/material.dart';

import '../core/ui/app_layout.dart';
import '../constants/app_colors.dart';
import '../services/theme_service.dart';

class AboutAppScreen extends StatefulWidget {
  const AboutAppScreen({super.key});

  @override
  State<AboutAppScreen> createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends State<AboutAppScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goHome() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final layout = AppLayout(context);

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
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.72),
                      Colors.black.withOpacity(0.95),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: -40,
            right: -20,
            child: _glowBubble(170, AppColors.gold.withOpacity(0.08)),
          ),
          Positioned(
            bottom: 120,
            left: -30,
            child: _glowBubble(140, Colors.white.withOpacity(0.04)),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(layout),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: layout.scale(24)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeroSection(layout),
                          SizedBox(height: layout.scale(32)),
                          _buildIntroCard(layout),
                          SizedBox(height: layout.scale(32)),
                          _buildSectionTitle("فلسفة ذكرني", layout),
                          _buildParagraph(
                            "لم يُبنَ ذكرني ليكون مجرد تطبيق أذكار تقليدي، بل صُمم ليكون مساحة رقمية هادئة تقرّب العبادة من حياة المسلم اليومية بأسلوب يراعي الذوق البصري، ويحترم التركيز، ويجعل الذكر أكثر حضورًا في اليوم لا أكثر ازدحامًا على الشاشة.",
                            layout,
                          ),
                          SizedBox(height: layout.scale(28)),
                          _buildVisionGrid(layout),
                          SizedBox(height: layout.scale(34)),
                          _buildSectionTitle("الركائز الأربعة", layout),
                          _buildPillarItem(
                            Icons.auto_awesome_outlined,
                            "الجمال البصري",
                            "نؤمن أن الذكر يستحق تجربة جميلة، راقية، ومطمئنة. لذلك لا يُستخدم التصميم هنا كزينة، بل كوسيلة لصناعة سكينة بصرية تساعد على الحضور والتركيز.",
                            layout,
                          ),
                          _buildPillarItem(
                            Icons.psychology_outlined,
                            "الذكاء الروحاني",
                            "لا يكتفي ذكرني بعرض المحتوى، بل يسعى إلى تقديمه في اللحظة الأنسب وبالطريقة الأقرب لحالة المستخدم، ليصبح التطبيق رفيقًا ذكيًا لا قائمة جامدة من الصفحات.",
                            layout,
                          ),
                          _buildPillarItem(
                            Icons.shield_outlined,
                            "الخصوصية والاحترام",
                            "التجربة الروحانية شخصية جدًا، ولهذا صُمم التطبيق ليحترم خصوصية المستخدم، ويقلل الاعتماد على جمع البيانات، ويحافظ على بساطة الاستخدام ووضوحه.",
                            layout,
                          ),
                          _buildPillarItem(
                            Icons.favorite_border_rounded,
                            "الإخلاص والغاية",
                            "هذا المشروع مبني بروح الصدقة الجارية التقنية، وهدفه الارتقاء بجودة التطبيقات الإسلامية حتى تنافس بصريًا ووظيفيًا أفضل التطبيقات في العالم.",
                            layout,
                          ),
                          SizedBox(height: layout.scale(34)),
                          _buildThinkingSection(layout),
                          SizedBox(height: layout.scale(34)),
                          _buildDifferenceSection(layout),
                          SizedBox(height: layout.scale(34)),
                          _buildDetailedStory(layout),
                          SizedBox(height: layout.scale(34)),
                          _buildFutureDirection(layout),
                          SizedBox(height: layout.scale(48)),
                          _buildFooter(layout),
                          SizedBox(height: layout.scale(30)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _glowBubble(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
        ),
      ),
    );
  }

  Widget _buildAppBar(AppLayout layout) {
    return Padding(
      padding: EdgeInsets.all(layout.scale(16)),
      child: Row(
        children: [
          IconButton(
            onPressed: _goHome,
            icon: Icon(
              Icons.home_rounded,
              color: AppColors.gold,
              size: layout.scale(20),
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.05),
            ),
          ),
          const Spacer(),
          Text(
            "عن التطبيق",
            style: TextStyle(
              color: AppColors.gold,
              fontFamily: "Cairo",
              fontSize: layout.scale(16),
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          SizedBox(width: layout.scale(48)),
        ],
      ),
    );
  }

  Widget _buildHeroSection(AppLayout layout) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(layout.scale(20)),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gold.withOpacity(0.28)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withOpacity(0.10),
                  blurRadius: 36,
                  spreadRadius: 4,
                ),
              ],
              gradient: RadialGradient(
                colors: [
                  AppColors.gold.withOpacity(0.10),
                  Colors.transparent,
                ],
              ),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.gold,
              size: layout.scale(50),
            ),
          ),
          SizedBox(height: layout.scale(18)),
          Text(
            "ذَكِّرْنِي",
            style: TextStyle(
              color: Colors.white,
              fontSize: layout.scale(31),
              fontWeight: FontWeight.w900,
              fontFamily: "Cairo",
              letterSpacing: 3,
            ),
          ),
          SizedBox(height: layout.scale(6)),
          Text(
            "نورٌ يرافق يومك",
            style: TextStyle(
              color: AppColors.gold.withOpacity(0.95),
              fontSize: layout.scale(14),
              fontFamily: "Cairo",
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroCard(AppLayout layout) {
    return Container(
      padding: EdgeInsets.all(layout.scale(22)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.025),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "فكرة التطبيق في سطر واحد",
            style: TextStyle(
              color: AppColors.gold.withOpacity(0.92),
              fontFamily: "Cairo",
              fontWeight: FontWeight.w800,
              fontSize: layout.scale(14),
            ),
          ),
          SizedBox(height: layout.scale(12)),
          Text(
            "ذكرني هو تجربة روحانية رقمية حيّة، تجمع بين الذكر، الجمال، والذكاء الوظيفي في مساحة واحدة هادئة.",
            style: TextStyle(
              color: Colors.white.withOpacity(0.78),
              fontSize: layout.scale(14),
              height: 1.8,
              fontFamily: "Cairo",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, AppLayout layout) {
    return Padding(
      padding: EdgeInsets.only(bottom: layout.scale(16)),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          SizedBox(width: layout.scale(12)),
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: layout.scale(20),
              fontWeight: FontWeight.bold,
              fontFamily: "Cairo",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParagraph(String text, AppLayout layout) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withOpacity(0.72),
        fontSize: layout.scale(15),
        height: 1.9,
        fontFamily: "Cairo",
      ),
    );
  }

  Widget _buildVisionGrid(AppLayout layout) {
    return Container(
      padding: EdgeInsets.all(layout.scale(20)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          _visionRow(
            "الرسالة",
            "خلق تجربة تعبدية ذكية تساعد المسلم على الثبات على الذكر بطريقة أكثر قربًا وهدوءًا.",
            layout,
          ),
          Divider(color: Colors.white.withOpacity(0.05), height: 30),
          _visionRow(
            "الهدف",
            "أن يكون ذكرني من أفضل التطبيقات الروحانية من حيث الجودة، الهوية، وسهولة الاستخدام.",
            layout,
          ),
          Divider(color: Colors.white.withOpacity(0.05), height: 30),
          _visionRow(
            "القيم",
            "الإتقان، الهدوء، الذكاء، والخصوصية، مع احترام المستخدم ووقته وتركيزه.",
            layout,
          ),
        ],
      ),
    );
  }

  Widget _visionRow(String label, String value, AppLayout layout) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label: ",
          style: TextStyle(
            color: AppColors.gold,
            fontWeight: FontWeight.bold,
            fontFamily: "Cairo",
            fontSize: layout.scale(14),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.white70,
              fontFamily: "Cairo",
              fontSize: layout.scale(14),
              height: 1.65,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPillarItem(
      IconData icon,
      String title,
      String desc,
      AppLayout layout,
      ) {
    return Padding(
      padding: EdgeInsets.only(bottom: layout.scale(24)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(layout.scale(10)),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.gold,
              size: layout.scale(22),
            ),
          ),
          SizedBox(width: layout.scale(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: layout.scale(16),
                    fontWeight: FontWeight.bold,
                    fontFamily: "Cairo",
                  ),
                ),
                SizedBox(height: layout.scale(6)),
                Text(
                  desc,
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: layout.scale(13),
                    height: 1.75,
                    fontFamily: "Cairo",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThinkingSection(AppLayout layout) {
    return Container(
      padding: EdgeInsets.all(layout.scale(22)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.025),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "كيف يفكر التطبيق؟",
            style: TextStyle(
              color: AppColors.gold.withOpacity(0.92),
              fontFamily: "Cairo",
              fontWeight: FontWeight.w800,
              fontSize: layout.scale(15),
            ),
          ),
          SizedBox(height: layout.scale(14)),
          _bulletLine("لا يدفع المستخدم إلى الازدحام، بل يدعوه إلى الهدوء."),
          _bulletLine("لا يقدّم المحتوى بصورة جامدة، بل في سياق بصري وروحاني متوازن."),
          _bulletLine("لا يركّز على كثرة العناصر، بل على جودة اللحظة التي يعيشها المستخدم."),
        ],
      ),
    );
  }

  Widget _buildDifferenceSection(AppLayout layout) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("لماذا يختلف ذكرني؟", layout),
        _buildParagraph(
          "الاختلاف في ذكرني لا يقوم على جمع عدد أكبر من الصفحات، بل على طريقة تقديم التجربة كلها: حركة هادئة، هوية متناسقة، عمق بصري مدروس، ورسائل ذكية تحترم حساسية اللحظة الروحانية. التطبيق لا يحاول أن يملأ الشاشة، بل أن يمنحها معنى.",
          layout,
        ),
      ],
    );
  }

  Widget _buildDetailedStory(AppLayout layout) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("لماذا ذكرني؟", layout),
        _buildParagraph(
          "في عالم تمتلئ شاشاته بالتنبيهات المشتتة والإيقاع السريع، بُني ذكرني ليكون نقيض هذا الضجيج. الفكرة ليست فقط أن يذكّرك التطبيق، بل أن يفعل ذلك بلطف، وبجمال، وبوعي بالسياق الذي تعيشه خلال يومك.",
          layout,
        ),
        SizedBox(height: layout.scale(18)),
        _buildParagraph(
          "من الأذكار إلى السنن، ومن المواقيت إلى الأسماء الحسنى، صُممت كل زاوية في التطبيق لتقود المستخدم من التشتت إلى السكينة، ومن التعامل الآلي مع المحتوى إلى تفاعل حيّ يشعره بالقرب، لا بالثقل.",
          layout,
        ),
        SizedBox(height: layout.scale(18)),
        _buildParagraph(
          "نحن لا نعرض النصوص فقط، بل نبني إحساسًا كاملًا حولها: الوقت، الألوان، الضوء، الحركة، وترتيب العناصر، كلها تعمل معًا لتجعل التجربة أقرب إلى المعنى الذي تحمله العبادة نفسها.",
          layout,
        ),
      ],
    );
  }

  Widget _buildFutureDirection(AppLayout layout) {
    return Container(
      padding: EdgeInsets.all(layout.scale(22)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "إلى أين يتجه ذكرني؟",
            style: TextStyle(
              color: AppColors.gold.withOpacity(0.92),
              fontFamily: "Cairo",
              fontWeight: FontWeight.w800,
              fontSize: layout.scale(15),
            ),
          ),
          SizedBox(height: layout.scale(12)),
          Text(
            "يتجه ذكرني إلى بناء عالم روحاني رقمي أكثر عمقًا، حيث تمتزج الفائدة مع الجمال، والذكاء مع السكينة، ليكون التطبيق رفيقًا يوميًا يزداد نضجًا واتساعًا مع كل تطوير جديد.",
            style: TextStyle(
              color: Colors.white.withOpacity(0.74),
              fontSize: layout.scale(14),
              height: 1.8,
              fontFamily: "Cairo",
            ),
          ),
        ],
      ),
    );
  }

  Widget _bulletLine(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            color: AppColors.gold.withOpacity(0.85),
            size: 16,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.75),
                fontFamily: "Cairo",
                fontSize: 12.5,
                height: 1.7,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(AppLayout layout) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 60,
            height: 1,
            color: AppColors.gold.withOpacity(0.3),
          ),
          SizedBox(height: layout.scale(20)),
          Text(
            "ذكرني — الإصدار الثالث",
            style: TextStyle(
              color: Colors.white24,
              fontSize: layout.scale(12),
              fontFamily: "Cairo",
            ),
          ),
          SizedBox(height: layout.scale(8)),
          Text(
            "بُني بعناية ليرتقي بتجربتك الإيمانية",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white12,
              fontSize: layout.scale(10),
              fontFamily: "Cairo",
            ),
          ),
        ],
      ),
    );
  }
}