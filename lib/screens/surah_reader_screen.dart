import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import '../services/theme_service.dart';
import '../constants/app_colors.dart';

class SurahReaderScreen extends StatefulWidget {
  final int surahNumber;
  final String surahName;

  const SurahReaderScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
  });

  @override
  State<SurahReaderScreen> createState() => _SurahReaderScreenState();
}

class _SurahReaderScreenState extends State<SurahReaderScreen> with WidgetsBindingObserver {
  double _fontSize = 28.0;
  bool _showBars = true;
  bool _showTafsirInline = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSettings();
  }

  @override
  void dispose() {
    _saveLastRead();
    _scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _fontSize = prefs.getDouble('quran_font_size') ?? 28.0;
      _showTafsirInline = prefs.getBool('show_tafsir_inline') ?? false;
    });
  }

  Future<void> _saveLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_surah_num', widget.surahNumber);
    await prefs.setString('last_surah_name', widget.surahName);
  }

  String _getSafeTafsir(int surah, int verse) {
    try {
      return quran.getVerseTranslation(surah, verse, translation: quran.Translation.enSaheeh);
    } catch (e) {
      return "جاري تحميل التفسير...";
    }
  }

  void _showTafsirDialog(int verseNumber) {
    _showGlassSheet(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "سورة ${widget.surahName} - آية $verseNumber",
              style: const TextStyle(color: AppColors.gold, fontFamily: "Cairo", fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            quran.getVerse(widget.surahNumber, verseNumber),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontFamily: "Amiri", height: 1.6),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Divider(color: Colors.white10),
          ),
          const Text(
            "معنى الآية:",
            style: TextStyle(color: AppColors.gold, fontSize: 14, fontFamily: "Cairo"),
          ),
          const SizedBox(height: 10),
          Text(
            _getSafeTafsir(widget.surahNumber, verseNumber),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 16, fontFamily: "Cairo", height: 1.5),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              minimumSize: const Size(120, 45),
            ),
            child: const Text("إغلاق", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: "Cairo")),
          ),
        ],
      ),
    );
  }

  void _showGlassSheet(BuildContext context, Widget content) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.85),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
              border: Border.all(color: AppColors.gold.withOpacity(0.2)),
            ),
            padding: const EdgeInsets.fromLTRB(25, 15, 25, 40),
            child: content,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    int verseCount = quran.getVerseCount(widget.surahNumber);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(theme.backgroundImage, fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.85)),
          ),

          GestureDetector(
            onTap: () => setState(() => _showBars = !_showBars),
            child: ListView.builder(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 100, 20, 150),
              itemCount: 1,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    _buildSurahHeaderFrame(),
                    const SizedBox(height: 30),
                    if (widget.surahNumber != 1 && widget.surahNumber != 9)
                      _buildBasmala(),
                    
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: RichText(
                        textAlign: TextAlign.justify,
                        text: TextSpan(
                          children: List.generate(verseCount, (idx) {
                            int vNum = idx + 1;
                            return TextSpan(
                              children: [
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.middle,
                                  child: InkWell(
                                    onTap: () => _showTafsirDialog(vNum),
                                    child: Text(
                                      quran.getVerse(widget.surahNumber, vNum, verseEndSymbol: false),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: _fontSize,
                                        fontFamily: "Amiri",
                                        height: 2.2,
                                      ),
                                    ),
                                  ),
                                ),
                                TextSpan(
                                  text: " ${quran.getVerseEndSymbol(vNum, arabicNumeral: true)} ",
                                  style: TextStyle(
                                    color: AppColors.gold,
                                    fontSize: _fontSize * 0.75,
                                    fontFamily: "Amiri",
                                  ),
                                ),
                                if (_showTafsirInline)
                                  TextSpan(
                                    text: "\n${_getSafeTafsir(widget.surahNumber, vNum)}\n",
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 15,
                                      fontFamily: "Cairo",
                                      height: 1.6,
                                    ),
                                  ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    _buildSadaqa(),
                  ],
                );
              },
            ),
          ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            top: _showBars ? 0 : -150,
            left: 0, right: 0,
            child: _buildTopBar(),
          ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            bottom: _showBars ? 0 : -120,
            left: 0, right: 0,
            child: _buildBottomBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 15),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            border: Border(bottom: BorderSide(color: AppColors.gold.withOpacity(0.2))),
          ),
          child: Row(
            children: [
              const SizedBox(width: 15),
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.gold, size: 20),
                onPressed: () => Navigator.pop(context),
                style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.05)),
              ),
              const Spacer(),
              Text(
                widget.surahName,
                style: const TextStyle(color: Colors.white, fontFamily: "Cairo", fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.tune_rounded, color: AppColors.gold, size: 22),
                onPressed: _showDisplaySettings,
                style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.05)),
              ),
              const SizedBox(width: 15),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSurahHeaderFrame() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.gold.withOpacity(0.3)),
        gradient: LinearGradient(
          colors: [AppColors.gold.withOpacity(0.1), Colors.transparent, AppColors.gold.withOpacity(0.1)],
        ),
      ),
      child: Column(
        children: [
          Text(
            "سورة ${widget.surahName}",
            style: const TextStyle(color: AppColors.gold, fontSize: 28, fontFamily: "Amiri", fontWeight: FontWeight.bold),
          ),
          Text(
            "آياتها: ${quran.getVerseCount(widget.surahNumber)} • ترتيبها: ${widget.surahNumber}",
            style: const TextStyle(color: Colors.white60, fontSize: 13, fontFamily: "Cairo"),
          ),
        ],
      ),
    );
  }

  Widget _buildBasmala() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Text(
        quran.basmala,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.gold,
          fontSize: _fontSize + 5,
          fontFamily: "Amiri",
        ),
      ),
    );
  }

  Widget _buildSadaqa() {
    return Column(
      children: [
        const SizedBox(height: 10),
        const Text(
          "تقبل الله منا ومنكم صالح الأعمال",
          style: TextStyle(color: Colors.white38, fontSize: 12, fontFamily: "Cairo"),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            border: Border(top: BorderSide(color: AppColors.gold.withOpacity(0.2))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.bookmark_outline_rounded, "حفظ الموضع", () {
                _saveLastRead();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("تم حفظ موضع القراءة ✨", textAlign: TextAlign.center, style: TextStyle(fontFamily: "Cairo"))),
                );
              }),
              _navItem(Icons.share_rounded, "مشاركة", () {
                Share.share("أقرأ الآن سورة ${widget.surahName} من تطبيق ذكرني.");
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.gold, size: 24),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontFamily: "Cairo")),
        ],
      ),
    );
  }

  void _showDisplaySettings() {
    _showGlassSheet(
      context,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("إعدادات الخط", style: TextStyle(color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "Cairo")),
          const Divider(color: Colors.white10, height: 30),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("حجم الخط", style: TextStyle(color: Colors.white, fontFamily: "Cairo")),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: AppColors.gold),
                    onPressed: () => setState(() { if(_fontSize > 20) _fontSize -= 2; _saveSettingsToPrefs(); }),
                  ),
                  Text(_fontSize.toInt().toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: AppColors.gold),
                    onPressed: () => setState(() { if(_fontSize < 44) _fontSize += 2; _saveSettingsToPrefs(); }),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "اضغط على أي آية لعرض التفسير والمعنى.",
            style: TextStyle(color: Colors.white38, fontSize: 11, fontFamily: "Cairo"),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSettingsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('quran_font_size', _fontSize);
  }
}
