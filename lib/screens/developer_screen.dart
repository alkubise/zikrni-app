import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../core/ui/app_layout.dart';
import '../constants/app_colors.dart';
import '../services/theme_service.dart';

class DeveloperScreen extends StatefulWidget {
  const DeveloperScreen({super.key});

  @override
  State<DeveloperScreen> createState() => _DeveloperScreenState();
}

class _DeveloperScreenState extends State<DeveloperScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint("Could not launch $url");
    }
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
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.38),
                      Colors.black.withOpacity(0.95),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: -40,
            right: -30,
            child: _glowBubble(170, AppColors.gold.withOpacity(0.08)),
          ),
          Positioned(
            bottom: 120,
            left: -20,
            child: _glowBubble(130, Colors.white.withOpacity(0.04)),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(layout),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: AnimationLimiter(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: layout.scale(24),
                        ),
                        children: AnimationConfiguration.toStaggeredList(
                          duration: const Duration(milliseconds: 600),
                          childAnimationBuilder: (widget) => SlideAnimation(
                            verticalOffset: 50,
                            child: FadeInAnimation(child: widget),
                          ),
                          children: [
                            SizedBox(height: layout.scale(10)),
                            _buildProfileCard(layout),
                            SizedBox(height: layout.scale(24)),
                            _buildPersonalMessage(layout),
                            SizedBox(height: layout.scale(24)),
                            _buildExpertiseGrid(layout),
                            SizedBox(height: layout.scale(24)),
                            _buildGoalsCard(layout),
                            SizedBox(height: layout.scale(24)),
                            _buildContactSection(layout),
                            SizedBox(height: layout.scale(60)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                _buildFooter(layout),
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

  Widget _buildHeader(AppLayout layout) {
    return Padding(
      padding: EdgeInsets.all(layout.scale(16)),
      child: Row(
        children: [
          IconButton(
            onPressed: _goHome,
            icon: Icon(
              Icons.home_rounded,
              color: AppColors.gold,
              size: 20,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.05),
            ),
          ),
          SizedBox(width: layout.scale(10)),
          Expanded(
            child: Text(
              "رسالة المطور",
              style: TextStyle(
                color: Colors.white,
                fontSize: layout.scale(18),
                fontWeight: FontWeight.w800,
                fontFamily: "Cairo",
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              "SPIRITUAL DESIGN",
              style: TextStyle(
                color: Colors.white.withOpacity(0.28),
                fontSize: layout.scale(9),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                fontFamily: "monospace",
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(AppLayout layout) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(layout.scale(30)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(layout.scale(36)),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.20),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.05),
            blurRadius: 60,
            spreadRadius: -10,
          ),
        ],
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                padding: EdgeInsets.all(layout.scale(4)),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.gold.withOpacity(
                      0.10 + (_pulseController.value * 0.20),
                    ),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withOpacity(
                        0.04 + (_pulseController.value * 0.06),
                      ),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: child,
              );
            },
            child: CircleAvatar(
              radius: layout.scale(55),
              backgroundColor: Colors.black26,
              backgroundImage:
              const AssetImage("assets/images/company_mark.png"),
            ),
          ),
          SizedBox(height: layout.scale(24)),
          Text(
            "ليث الكبيسي",
            style: TextStyle(
              color: Colors.white,
              fontSize: layout.scale(26),
              fontWeight: FontWeight.w900,
              fontFamily: "Cairo",
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: layout.scale(8)),
          Text(
            "مصمم ومطور تطبيق ذكرني",
            style: TextStyle(
              color: AppColors.gold.withOpacity(0.92),
              fontSize: layout.scale(11),
              fontFamily: "Cairo",
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: layout.scale(20)),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: layout.scale(10),
            runSpacing: layout.scale(10),
            children: [
              _buildMiniBadge(Icons.design_services_rounded, "واجهة هادفة"),
              _buildMiniBadge(Icons.auto_awesome_rounded, "بناء روحاني"),
              _buildMiniBadge(Icons.flutter_dash_rounded, "Flutter Architect"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.gold.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.gold, size: 12),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              fontFamily: "Cairo",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalMessage(AppLayout layout) {
    return Container(
      padding: EdgeInsets.all(layout.scale(25)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Text(
            "رسالة من المطور",
            style: TextStyle(
              color: AppColors.gold.withOpacity(0.90),
              fontSize: layout.scale(14),
              fontWeight: FontWeight.w800,
              fontFamily: "Cairo",
            ),
          ),
          SizedBox(height: layout.scale(16)),
          Icon(
            Icons.auto_awesome_rounded,
            color: AppColors.gold.withOpacity(0.5),
            size: layout.scale(24),
          ),
          SizedBox(height: layout.scale(18)),
          Text(
            "هذا العمل تم بفضل الله وتوفيقه وحده، صُمم هذا التطبيق بنية خالصة لاحتساب الأجر، وبذلت فيه الجهد مع اليقين التام بأني لا حول لي ولا قوة، وأن كل سطر برمجي كتب في هذا المشروع هو من فيض كرم الله عليّ.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontSize: layout.scale(15),
              height: 1.9,
              fontFamily: "Cairo",
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpertiseGrid(AppLayout layout) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "ما يميز هذا العمل",
          style: TextStyle(
            color: Colors.white.withOpacity(0.30),
            fontSize: layout.scale(11),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontFamily: "Cairo",
          ),
        ),
        SizedBox(height: layout.scale(18)),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.7, // جعل الخلية أطول قليلاً لمنع الـ overflow
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _expertiseCard(
              "هوية بصرية",
              "تصميم ذهبي روحاني متناسق",
              Icons.palette_outlined,
            ),
            _expertiseCard(
              "تجربة روحانية",
              "واجهات هادئة تتفاعل مع الوقت",
              Icons.animation_rounded,
            ),
            _expertiseCard(
              "بنية نظيفة",
              "هيكلة قابلة للتطوير والتوسع",
              Icons.account_tree_outlined,
            ),
            _expertiseCard(
              "تفاصيل فاخرة",
              "عناية بالحركة والضوء والعمق",
              Icons.diamond_outlined,
            ),
          ],
        ),
      ],
    );
  }

  Widget _expertiseCard(String title, String desc, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, color: AppColors.gold, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Cairo",
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white24,
                    fontSize: 9,
                    fontFamily: "Cairo",
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsCard(AppLayout layout) {
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
            "ما الذي أسعى إليه؟",
            style: TextStyle(
              color: AppColors.gold.withOpacity(0.90),
              fontFamily: "Cairo",
              fontWeight: FontWeight.w800,
              fontSize: layout.scale(14),
            ),
          ),
          SizedBox(height: layout.scale(14)),
          _goalLine("أن يكون الذكر أقرب ليوم المسلم"),
          _goalLine("أن تمنح الواجهة سكينة لا ازدحامًا"),
          _goalLine("أن يجتمع الجمال مع الفائدة"),
        ],
      ),
    );
  }

  Widget _goalLine(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
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
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(AppLayout layout) {
    return Column(
      children: [
        Text(
          "التواصل",
          style: TextStyle(
            color: Colors.white.withOpacity(0.30),
            fontSize: layout.scale(11),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontFamily: "Cairo",
          ),
        ),
        SizedBox(height: layout.scale(24)),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: layout.scale(22),
          runSpacing: layout.scale(16),
          children: [
            _contactBtn(
              Icons.alternate_email_rounded,
              "البريد",
              "mailto:layth@spiritual.com",
            ),
            _contactBtn(
              Icons.language_rounded,
              "الموقع",
              "https://layth.dev",
            ),
            _contactBtn(
              Icons.terminal_rounded,
              "GitHub",
              "https://github.com/layth",
            ),
          ],
        ),
      ],
    );
  }

  Widget _contactBtn(IconData icon, String label, String url) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.heavyImpact();
            _launchURL(url);
          },
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold.withOpacity(0.05),
              border: Border.all(
                color: AppColors.gold.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withOpacity(0.1),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.gold, size: 28),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
            fontFamily: "Cairo",
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(AppLayout layout) {
    return Padding(
      padding: EdgeInsets.only(bottom: layout.bottomSafe(20)),
      child: Column(
        children: [
          const Opacity(
            opacity: 0.45,
            child: Text(
              "لا حَوْلَ وَلا قُوَّةَ إِلَّا بِاللَّهِ الْعَلِيِّ الْعَظِيمِ",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: "Amiri",
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: layout.scale(12)),
          Text(
            "© 2026 ذكرني — الإصدار الأول",
            style: TextStyle(
              color: Colors.white10,
              fontSize: layout.scale(9),
              fontFamily: "monospace",
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}