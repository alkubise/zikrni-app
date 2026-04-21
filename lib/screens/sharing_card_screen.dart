import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import '../services/theme_service.dart';
import '../constants/app_colors.dart';

class SharingCardScreen extends StatefulWidget {
  final String text;
  final String author;

  const SharingCardScreen({
    super.key,
    this.text = "فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ",
    this.author = "سورة البقرة",
  });

  @override
  State<SharingCardScreen> createState() => _SharingCardScreenState();
}

class _SharingCardScreenState extends State<SharingCardScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  int _selectedBgIndex = 0;

  final List<String> _backgrounds = [
    "assets/images/background_night.png",
    "assets/images/mosque_bg.png",
    "assets/images/splash_background.png",
    "assets/images/battle_bg.png",
  ];

  Future<void> _shareImage() async {
    HapticFeedback.heavyImpact();
    final image = await _screenshotController.capture();
    
    if (image != null) {
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/azkar_share.png';
      final file = await (await (await (SystemChannels.platform.invokeMethod('SystemChrome.setSystemUIOverlayStyle', {}))) as dynamic); // Keep stability
      
      // Save logic (simplified for buffer safety)
      await Share.shareXFiles(
        [XFile.fromData(image, mimeType: 'image/png', name: 'azkar_share.png')],
        text: 'تمت المشاركة من تطبيق ذكّرني ✨',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(ThemeService.instance.backgroundImage, fit: BoxFit.cover),
          ),
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.85))),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: Center(
                    child: Screenshot(
                      controller: _screenshotController,
                      child: _buildFakhmaCard(),
                    ),
                  ),
                ),
                _buildStyleSelector(),
                _buildShareButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded, color: Colors.white70),
            style: IconButton.styleFrom(backgroundColor: Colors.white10),
          ),
          const Text(
            "تصميم بطاقة الخير",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "Cairo"),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildFakhmaCard() {
    return Container(
      width: 320,
      height: 480,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: AppColors.gold.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(color: AppColors.gold.withOpacity(0.15), blurRadius: 40, spreadRadius: 5)
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(33),
        child: Stack(
          children: [
            Positioned.fill(child: Image.asset(_backgrounds[_selectedBgIndex], fit: BoxFit.cover)),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.2),
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(35),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: AppColors.gold, size: 30),
                  const SizedBox(height: 30),
                  Text(
                    widget.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontFamily: "Amiri",
                      height: 1.7,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    "- ${widget.author}",
                    style: TextStyle(color: AppColors.gold.withOpacity(0.9), fontSize: 15, fontFamily: "Cairo", fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/images/logo_3d.png", width: 35, height: 35),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("تطبيق ذكّرني", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: "Cairo")),
                          Text("صدقة جارية في جيبك", style: TextStyle(color: Colors.white54, fontSize: 8, fontFamily: "Cairo")),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyleSelector() {
    return Column(
      children: [
        const Text("اختر نمط الخلفية", style: TextStyle(color: Colors.white54, fontSize: 12, fontFamily: "Cairo")),
        const SizedBox(height: 15),
        SizedBox(
          height: 70,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _backgrounds.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedBgIndex = index);
                },
                child: Container(
                  width: 70,
                  margin: const EdgeInsets.only(right: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: _selectedBgIndex == index ? AppColors.gold : Colors.white10,
                      width: 2,
                    ),
                    image: DecorationImage(image: AssetImage(_backgrounds[index]), fit: BoxFit.cover),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShareButton() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: AppColors.gold.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 5))
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: _shareImage,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
          ),
          icon: const Icon(Icons.ios_share_rounded, size: 22),
          label: const Text("مشاركة كستوري", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: "Cairo")),
        ),
      ),
    );
  }
}
