import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../data/dua_data.dart';
import '../services/theme_service.dart';
import 'dua_details_screen.dart';

class DuaScreen extends StatefulWidget {
  const DuaScreen({super.key});

  @override
  State<DuaScreen> createState() => _DuaScreenState();
}

class _DuaScreenState extends State<DuaScreen> {
  List<Map<String, String>> _myDuas = [];

  @override
  void initState() {
    super.initState();
    _loadMyDuas();
  }

  Future<void> _loadMyDuas() async {
    final prefs = await SharedPreferences.getInstance();
    final String? saved = prefs.getString('my_custom_duas');
    if (saved != null) {
      setState(() {
        _myDuas = List<Map<String, String>>.from(
          json.decode(saved).map((item) => Map<String, String>.from(item))
        );
      });
    }
  }

  Future<void> _addDua() async {
    String title = "";
    String content = "";

    await showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: Colors.black.withOpacity(0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFD4AF37), width: 1),
          ),
          title: const Text("إضافة دعاء خاص", textAlign: TextAlign.right, style: TextStyle(color: Color(0xFFD4AF37), fontFamily: "Cairo")),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (v) => title = v,
                textAlign: TextAlign.right,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(hintText: "عنوان الدعاء", hintStyle: TextStyle(color: Colors.white38)),
              ),
              const SizedBox(height: 10),
              TextField(
                onChanged: (v) => content = v,
                textAlign: TextAlign.right,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(hintText: "نص الدعاء", hintStyle: TextStyle(color: Colors.white38)),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء", style: TextStyle(color: Colors.white60))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD4AF37)),
              onPressed: () async {
                if (title.isNotEmpty && content.isNotEmpty) {
                  setState(() {
                    _myDuas.add({"title": title, "dua": content, "ref": "دعاء خاص"});
                  });
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('my_custom_duas', json.encode(_myDuas));
                  if (!mounted) return;
                  Navigator.pop(context);
                }
              },
              child: const Text("حفظ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
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
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.5))),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 120.0,
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    "حصن المسلم المطور",
                    style: TextStyle(
                      color: const Color(0xFFD4AF37),
                      fontFamily: "Cairo",
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      shadows: [Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 10)],
                    ),
                  ),
                ),
              ),

              if (_myDuas.isNotEmpty)
                _buildSectionTitle("أدعيتي الخاصة"),
              
              if (_myDuas.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildDuaCard(context, _myDuas[index], isCustom: true),
                      childCount: _myDuas.length,
                    ),
                  ),
                ),

              _buildSectionTitle("الأدعية المأثورة"),
              
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildDuaCard(context, DuaData.data[index]),
                    childCount: DuaData.data.length,
                  ),
                ),
              ),
            ],
          ),

          // أزرار التحكم السفلية
          _buildBottomActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(25, 25, 25, 10),
        child: Text(title, textAlign: TextAlign.right, style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 14, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildDuaCard(BuildContext context, Map<String, String> item, {bool isCustom = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => DuaDetailsScreen(data: item)));
            },
            title: Text(item["title"] ?? "", textDirection: TextDirection.rtl, style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: "Cairo")),
            leading: isCustom ? const Icon(Icons.star_rounded, color: Color(0xFFD4AF37), size: 20) : null,
            trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActionButtons(BuildContext context) {
    return Positioned(
      bottom: 30, left: 30, right: 30,
      child: Row(
        children: [
          Expanded(
            child: _glassButton(
              onTap: () => Navigator.pop(context),
              text: "رجوع",
              icon: Icons.arrow_back_rounded,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _glassButton(
              onTap: _addDua,
              text: "أضف دعاء",
              icon: Icons.add_rounded,
              isPrimary: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassButton({required VoidCallback onTap, required String text, required IconData icon, bool isPrimary = false}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: 55,
            decoration: BoxDecoration(
              color: isPrimary ? const Color(0xFFD4AF37).withOpacity(0.2) : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: const Color(0xFFD4AF37), size: 20),
                const SizedBox(width: 8),
                Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: "Cairo")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
