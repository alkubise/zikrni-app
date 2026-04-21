import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../core/ui/app_layout.dart';
import '../services/theme_service.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> with SingleTickerProviderStateMixin {
  final String email = "Layth@mein.gmx";
  final String telegram = "https://t.me/Thikrni_App";
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=اقتراح ميزة - تطبيق ذكّرني',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchTelegram() async {
    final Uri url = Uri.parse(telegram);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final layout = AppLayout(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 🌌 الخلفية السينمائية
          Positioned.fill(
            child: Image.asset(
              ThemeService.instance.backgroundImage,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(color: Colors.black.withOpacity(0.75)),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(context, layout),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: layout.scale(24)),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          SizedBox(height: layout.scale(20)),
                          _buildVisualIcon(layout),
                          SizedBox(height: layout.scale(30)),
                          _buildSuggestionIntro(layout),
                          SizedBox(height: layout.scale(30)),
                          _buildContactMethod(
                            layout: layout,
                            icon: Icons.alternate_email_rounded,
                            title: "راسلنا بالبريد",
                            subtitle: "للاقتراحات المفصلة والتعاون",
                            value: email,
                            color: AppColors.gold,
                            onTap: _launchEmail,
                          ),
                          SizedBox(height: layout.scale(16)),
                          _buildContactMethod(
                            layout: layout,
                            icon: Icons.telegram_rounded,
                            title: "مجتمع تيليجرام",
                            subtitle: "ناقش ميزاتك مع المستخدمين",
                            value: "@Thikrni_App",
                            color: const Color(0xFF229ED9),
                            onTap: _launchTelegram,
                          ),
                          SizedBox(height: layout.scale(30)),
                          _buildCommunityBadge(layout),
                        ],
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

  Widget _buildHeader(BuildContext context, AppLayout layout) {
    return Padding(
      padding: EdgeInsets.all(layout.scale(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.gold, size: layout.scale(18)),
            style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.05)),
          ),
          Text(
            "اقتراح ميزة",
            style: TextStyle(color: Colors.white, fontSize: layout.scale(18), fontWeight: FontWeight.bold, fontFamily: "Cairo"),
          ),
          SizedBox(width: layout.scale(48)),
        ],
      ),
    );
  }

  Widget _buildVisualIcon(AppLayout layout) {
    return Container(
      padding: EdgeInsets.all(layout.scale(20)),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.gold.withOpacity(0.05),
        border: Border.all(color: AppColors.gold.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: AppColors.gold.withOpacity(0.1), blurRadius: 40, spreadRadius: 2)
        ],
      ),
      child: Icon(Icons.tips_and_updates_rounded, color: AppColors.gold, size: layout.scale(50)),
    );
  }

  Widget _buildSuggestionIntro(AppLayout layout) {
    return Column(
      children: [
        Text(
          "شاركنا في بناء الخير ✨",
          style: TextStyle(color: Colors.white, fontSize: layout.scale(20), fontWeight: FontWeight.w900, fontFamily: "Cairo"),
        ),
        SizedBox(height: layout.scale(10)),
        Text(
          "هل لديك فكرة تجعل تجربة الذكر أجمل؟ نحن نؤمن بأن أفضل الميزات تأتي من قلوب مستخدمينا.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white38, fontSize: layout.scale(13), height: 1.6, fontFamily: "Cairo"),
        ),
      ],
    );
  }

  Widget _buildContactMethod({
    required AppLayout layout,
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.all(layout.scale(18)),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(layout.scale(22)),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(layout.scale(12)),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: layout.scale(22)),
            ),
            SizedBox(width: layout.scale(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: Colors.white, fontSize: layout.scale(15), fontWeight: FontWeight.bold, fontFamily: "Cairo")),
                  Text(subtitle, style: TextStyle(color: Colors.white30, fontSize: layout.scale(11), fontFamily: "Cairo")),
                ],
              ),
            ),
            Icon(Icons.chevron_left_rounded, color: Colors.white12, size: layout.scale(20)),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityBadge(AppLayout layout) {
    return Container(
      padding: EdgeInsets.all(layout.scale(16)),
      decoration: BoxDecoration(
        color: AppColors.gold.withOpacity(0.05),
        borderRadius: BorderRadius.circular(layout.scale(18)),
        border: Border.all(color: AppColors.gold.withOpacity(0.1), style: BorderStyle.solid),
      ),
      child: Row(
        children: [
          Icon(Icons.stars_rounded, color: AppColors.gold, size: layout.scale(20)),
          SizedBox(width: layout.scale(12)),
          Expanded(
            child: Text(
              "اقتراحاتك تساهم في تطوير بيت المسلم الرقمي، ولك أجر كل من انتفع بها بإذن الله.",
              style: TextStyle(color: AppColors.gold.withOpacity(0.8), fontSize: layout.scale(11), height: 1.5, fontFamily: "Cairo", fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(AppLayout layout) {
    return Padding(
      padding: EdgeInsets.only(bottom: layout.bottomSafe(20)),
      child: Column(
        children: [
          Text("ذكّرني v1.0.0", style: TextStyle(color: Colors.white10, fontSize: layout.scale(10), fontFamily: "monospace")),
          SizedBox(height: 4),
          Text("صُنع بصدقة جارية عن جميع المسلمين", style: TextStyle(color: Colors.white24, fontSize: layout.scale(9), fontFamily: "Cairo")),
        ],
      ),
    );
  }
}
