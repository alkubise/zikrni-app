import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:quran/quran.dart' as quran;
import '../services/theme_service.dart';
import 'surah_reader_screen.dart';

class SurahIndexScreen extends StatefulWidget {
  const SurahIndexScreen({super.key});

  @override
  State<SurahIndexScreen> createState() => _SurahIndexScreenState();
}

class _SurahIndexScreenState extends State<SurahIndexScreen> {
  String _searchQuery = "";

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
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.65)),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                _buildSearchBox(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: 114,
                    itemBuilder: (context, index) {
                      int surahNumber = index + 1;
                      String surahName = quran.getSurahNameArabic(surahNumber);
                      
                      if (_searchQuery.isNotEmpty && !surahName.contains(_searchQuery)) {
                        return const SizedBox.shrink();
                      }

                      return _buildSurahCard(surahNumber, surahName);
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
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFD4AF37)),
            style: IconButton.styleFrom(backgroundColor: Colors.white10),
          ),
          const Expanded(
            child: Center(
              child: Text(
                "القرآن الكريم",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Cairo",
                ),
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2)),
            ),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white, fontFamily: "Cairo"),
              decoration: const InputDecoration(
                hintText: "ابحث عن سورة...",
                hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Color(0xFFD4AF37)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSurahCard(int number, String name) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SurahReaderScreen(surahNumber: number, surahName: name),
                ),
              );
            },
            tileColor: Colors.white.withOpacity(0.05),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: const Color(0xFFD4AF37).withOpacity(0.1)),
            ),
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFD4AF37).withOpacity(0.2),
              child: Text(
                number.toString(),
                style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              name,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: "Amiri",
              ),
            ),
            subtitle: Text(
              "${quran.getVerseCount(number)} آية • ${quran.getPlaceOfRevelation(number) == 'Meccan' ? 'مكية' : 'مدنية'}",
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white38, fontSize: 12, fontFamily: "Cairo"),
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 16),
          ),
        ),
      ),
    );
  }
}
