import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import '../core/ui/app_layout.dart';
import '../constants/app_colors.dart';
import '../services/user_service.dart';
import '../services/stats_service.dart';
import '../services/theme_service.dart';
import '../services/auth_service.dart';
import 'logout_screen.dart';
import 'login_or_guest_screen.dart';

class SpiritualIdScreen extends StatefulWidget {
  const SpiritualIdScreen({super.key});

  @override
  State<SpiritualIdScreen> createState() => _SpiritualIdScreenState();
}

class _SpiritualIdScreenState extends State<SpiritualIdScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _isLoggedIn = AuthService.isLoggedIn;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn(String provider) async {
    HapticFeedback.mediumImpact();
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
      );

      if (provider == "Google") {
        final user = await AuthService.signInWithGoogle();
        await UserService.bindLoggedInUser(user);
      }

      if (mounted) {
        Navigator.pop(context);
        setState(() => _isLoggedIn = true);
        _showSnackBar("تم تأمين مسيرتك الروحانية بنجاح ✨");
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showSnackBar("حدث خطأ أثناء تسجيل الدخول: $e");
      }
    }
  }

  void _goToLogout() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LogoutScreen()),
    );
  }

  void _shareID() async {
    HapticFeedback.lightImpact();
    final image = await _screenshotController.capture();
    if (image != null) {
      final directory = await getTemporaryDirectory();
      final imagePath = await File('${directory.path}/spiritual_id.png').create();
      await imagePath.writeAsBytes(image);
      await Share.shareXFiles([XFile(imagePath.path)], text: 'هذه هويتي الروحانية في تطبيق ذكّرني ✨ #ذكّرني');
    }
  }

  void _downloadData() async {
    HapticFeedback.selectionClick();
    final stats = await StatsService.getStats();
    final buffer = StringBuffer();
    buffer.writeln("سجل أذكار تطبيق ذكّرني الرسمي");
    buffer.writeln("----------------------------");
    buffer.writeln("اسم المستخدم: ${UserService.userName}");
    buffer.writeln("إجمالي التسبيحات: ${stats['total']}");
    buffer.writeln("تاريخ التقرير: ${DateTime.now()}");
    
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/thikrni_report.txt');
    await file.writeAsString(buffer.toString());
    await Share.shareXFiles([XFile(file.path)], text: 'تقرير إنجازاتي الروحانية 📿');
  }

  @override
  Widget build(BuildContext context) {
    final layout = AppLayout(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(ThemeService.instance.backgroundImage, fit: BoxFit.cover),
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
                      child: _isLoggedIn ? _buildSpiritualID(layout) : _buildAuthSection(layout),
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

  Widget _buildHeader(BuildContext context, AppLayout layout) {
    return Padding(
      padding: EdgeInsets.all(layout.scale(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.gold, size: 18),
            style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.05)),
          ),
          Text(
            _isLoggedIn ? "هويتك الروحانية" : "تأمين المسيرة",
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "Cairo"),
          ),
          _isLoggedIn 
            ? IconButton(
                onPressed: _goToLogout, 
                icon: const Icon(Icons.power_settings_new_rounded, color: Colors.redAccent, size: 20)
              )
            : const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildAuthSection(AppLayout layout) {
    return Column(
      children: [
        SizedBox(height: layout.scale(40)),
        Container(
          padding: EdgeInsets.all(layout.scale(25)),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.gold.withOpacity(0.05),
            border: Border.all(color: AppColors.gold.withOpacity(0.2)),
            boxShadow: [BoxShadow(color: AppColors.gold.withOpacity(0.1), blurRadius: 40)],
          ),
          child: Icon(Icons.cloud_sync_rounded, color: AppColors.gold, size: layout.scale(60)),
        ),
        SizedBox(height: layout.scale(30)),
        Text("احفظ أثرك في السحاب ✨", style: TextStyle(color: Colors.white, fontSize: layout.scale(22), fontWeight: FontWeight.w900, fontFamily: "Cairo")),
        SizedBox(height: layout.scale(12)),
        Text(
          "بتأمين مسيرتك الروحانية، سيتم حفظ أورادك، مستوياتك، وإنجازاتك في سحابة 'ذكّرني' لتتمكن من استعادتها في أي وقت ومن أي جهاز.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white38, fontSize: layout.scale(13), height: 1.6, fontFamily: "Cairo"),
        ),
        SizedBox(height: layout.scale(50)),
        _authButton(layout, "الاستمرار بواسطة Google", Icons.g_mobiledata_rounded, () => _handleSignIn("Google"), Colors.white),
        const SizedBox(height: 16),
        _authButton(layout, "الاستمرار بواسطة Apple", Icons.apple_rounded, () => _handleSignIn("Apple"), Colors.white, isApple: true),
      ],
    );
  }

  Widget _authButton(AppLayout layout, String text, IconData icon, VoidCallback onTap, Color textColor, {bool isApple = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: layout.scale(16)),
        decoration: BoxDecoration(
          color: isApple ? Colors.white : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(layout.scale(18)),
          border: Border.all(color: isApple ? Colors.white : Colors.white10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isApple ? Colors.black : AppColors.gold, size: 24),
            const SizedBox(width: 12),
            Text(text, style: TextStyle(color: isApple ? Colors.black : textColor, fontSize: layout.scale(14), fontWeight: FontWeight.bold, fontFamily: "Cairo")),
          ],
        ),
      ),
    );
  }

  Widget _buildSpiritualID(AppLayout layout) {
    DateTime joinDate;
    try {
      joinDate = DateTime.parse(UserService.joinDate);
    } catch (_) {
      joinDate = DateTime.now();
    }
    final statsTitle = StatsService.getSpiritualStatus();
    final currentName = UserService.userName.isEmpty ? "عابد لله" : UserService.userName;
    final userEmail = AuthService.currentFirebaseUser?.email ?? "id.user@thikrni.app";

    return Column(
      children: [
        SizedBox(height: layout.scale(20)),
        Screenshot(
          controller: _screenshotController,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.gold.withOpacity(0.2), Colors.black.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(layout.scale(30)),
              border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 1.5),
            ),
            child: Stack(
              children: [
                Positioned(top: -20, right: -20, child: Icon(Icons.auto_awesome, color: AppColors.gold.withOpacity(0.05), size: 150)),
                Padding(
                  padding: EdgeInsets.all(layout.scale(25)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("UNIVERSAL SPIRITUAL ID", style: TextStyle(color: AppColors.gold, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 2)),
                          const Icon(Icons.qr_code_2_rounded, color: Colors.white24, size: 30),
                        ],
                      ),
                      SizedBox(height: layout.scale(30)),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.gold, width: 1)),
                            child: const CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.white10,
                              child: Icon(Icons.person_rounded, color: AppColors.gold, size: 40),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(currentName, style: TextStyle(color: Colors.white, fontSize: layout.scale(20), fontWeight: FontWeight.w900, fontFamily: "Cairo")),
                                Text(userEmail, style: const TextStyle(color: Colors.white38, fontSize: 10, fontFamily: "monospace")),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: layout.scale(40)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _idStat("اللقب العالمي", statsTitle, AppColors.gold),
                          _idStat("عضو منذ", "${joinDate.year}/${joinDate.month}", Colors.white70),
                        ],
                      ),
                      SizedBox(height: layout.scale(20)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12)),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.verified_user_rounded, color: Colors.greenAccent, size: 14),
                            SizedBox(width: 8),
                            Text("مسيرة روحانية مؤمنة سحابياً", style: TextStyle(color: Colors.greenAccent, fontSize: 9, fontWeight: FontWeight.bold, fontFamily: "Cairo")),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: layout.scale(30)),
        _buildActionTile(layout, Icons.share_rounded, "مشاركة الهوية", "شارك بطاقتك مع رفقاء الدرب", _shareID),
        _buildActionTile(layout, Icons.cloud_download_rounded, "تحميل البيانات", "احصل على نسخة من سجل أذكارك", _downloadData),
      ],
    );
  }

  Widget _idStat(String label, String value, Color valColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9, fontFamily: "Cairo")),
        Text(value, style: TextStyle(color: valColor, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: "Cairo")),
      ],
    );
  }

  Widget _buildActionTile(AppLayout layout, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.gold, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: "Cairo")),
                  Text(subtitle, style: const TextStyle(color: Colors.white30, fontSize: 11, fontFamily: "Cairo")),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white10),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg, style: const TextStyle(fontFamily: "Cairo"))),
    );
  }
}
