import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/theme_service.dart';
import '../constants/app_colors.dart';

class SunnahTrackerScreen extends StatefulWidget {
  const SunnahTrackerScreen({super.key});

  @override
  State<SunnahTrackerScreen> createState() => _SunnahTrackerScreenState();
}

class _SunnahTrackerScreenState extends State<SunnahTrackerScreen> {
  final List<Map<String, dynamic>> _sunnahs = [
    {"id": "duha", "title": "صلاة الضحى", "desc": "صلاة الأوابين ووقتها من بعد الشروق بـ 15 دقيقة", "icon": Icons.wb_sunny_rounded},
    {"id": "rawatib", "title": "السنن الرواتب", "desc": "12 ركعة في اليوم يبنى لك بها بيت في الجنة", "icon": Icons.mosque_rounded},
    {"id": "qiyam", "title": "قيام الليل", "icon": Icons.nightlight_round, "desc": "شرف المؤمن ومن أعظم القربات"},
    {"id": "siwak", "title": "السواك", "icon": Icons.clean_hands_rounded, "desc": "مطهرة للفم مرضاة للرب"},
    {"id": "fasting", "title": "الصيام", "icon": Icons.restaurant_menu_rounded, "desc": "صيام الإثنين والخميس أو الأيام البيض"},
    {"id": "wudu", "title": "وضوء قبل النوم", "icon": Icons.water_drop_rounded, "desc": "بات معه ملك يستغفر له"},
    {"id": "surah_mulk", "title": "سورة الملك", "icon": Icons.menu_book_rounded, "desc": "المنجية من عذاب القبر"},
    {"id": "smile", "title": "الابتسامة", "icon": Icons.sentiment_very_satisfied_rounded, "desc": "تبسمك في وجه أخيك صدقة"},
    {"id": "charity", "title": "الصدقة اليومية", "icon": Icons.volunteer_activism_rounded, "desc": "ولو بشق تمرة أو كلمة طيبة"},
  ];

  Map<String, bool> _trackingData = {};
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    String dateKey = _getTodayKey();
    int completedCount = 0;
    
    Map<String, bool> tempData = {};
    for (var sunnah in _sunnahs) {
      bool status = prefs.getBool("${dateKey}_${sunnah['id']}") ?? false;
      tempData[sunnah['id']] = status;
      if (status) completedCount++;
    }

    setState(() {
      _trackingData = tempData;
      _progress = completedCount / _sunnahs.length;
    });
  }

  String _getTodayKey() {
    final now = DateTime.now();
    return "sunnah_${now.year}-${now.month}-${now.day}";
  }

  Future<void> _toggleSunnah(String id, bool value) async {
    HapticFeedback.lightImpact();
    final prefs = await SharedPreferences.getInstance();
    String dateKey = _getTodayKey();
    await prefs.setBool("${dateKey}_$id", value);
    
    await _loadProgress(); // إعادة حساب التقدم
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              theme.backgroundImage,
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.25),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                _buildProgressHeader(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _sunnahs.length,
                    itemBuilder: (context, index) {
                      final sunnah = _sunnahs[index];
                      bool isDone = _trackingData[sunnah['id']] ?? false;
                      return _buildSunnahCard(sunnah, isDone);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.gold, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.05),
              padding: const EdgeInsets.all(12),
            ),
          ),
          const Text(
            "إحياء السنن",
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, fontFamily: "Cairo"),
          ),
          const SizedBox(width: 45),
        ],
      ),
    );
  }

  Widget _buildProgressHeader() {
    int doneCount = _trackingData.values.where((v) => v).length;
    String message = "ابدأ يومك بإحياء سنة ✨";
    if (_progress > 0.3) message = "بداية مباركة، استمر 🌿";
    if (_progress > 0.7) message = "أنت تحيي سنته ﷺ.. طوبى لك 🌟";
    if (_progress == 1.0) message = "ما شاء الله! يومك مليء بالسنن 🏆";

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.gold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.gold.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: CircularProgressIndicator(
                  value: _progress,
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withOpacity(0.05),
                  valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                ),
              ),
              Text(
                "${(_progress * 100).toInt()}%",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$doneCount من ${_sunnahs.length} سنن",
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, fontFamily: "Cairo"),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12, fontFamily: "Cairo"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSunnahCard(Map<String, dynamic> sunnah, bool isDone) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: isDone ? AppColors.gold.withOpacity(0.12) : Colors.white.withOpacity(0.03),
        border: Border.all(
          color: isDone ? AppColors.gold.withOpacity(0.5) : Colors.white.withOpacity(0.05),
          width: 1.5,
        ),
        boxShadow: isDone ? [
          BoxShadow(color: AppColors.gold.withOpacity(0.1), blurRadius: 15, spreadRadius: 1)
        ] : [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            onTap: () => _toggleSunnah(sunnah['id'], !isDone),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDone ? AppColors.gold.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(sunnah['icon'], color: isDone ? AppColors.gold : Colors.white24, size: 26),
            ),
            title: Text(
              sunnah['title'],
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                fontFamily: "Cairo",
                decoration: isDone ? TextDecoration.lineThrough : null,
                decorationColor: AppColors.gold.withOpacity(0.5),
              ),
            ),
            subtitle: sunnah['desc'] != null ? Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                sunnah['desc'],
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11, fontFamily: "Cairo"),
              ),
            ) : null,
            trailing: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDone ? AppColors.gold : Colors.white24,
                  width: 2,
                ),
                color: isDone ? AppColors.gold : Colors.transparent,
              ),
              child: isDone ? const Icon(Icons.check, color: Colors.black, size: 18) : null,
            ),
          ),
        ),
      ),
    );
  }
}
