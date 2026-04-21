import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ProfileCustomizationScreen extends StatefulWidget {
  final String currentName;
  final String currentSymbolKey;
  final Function(String name, String symbolKey) onSave;

  const ProfileCustomizationScreen({
    super.key,
    required this.currentName,
    required this.currentSymbolKey,
    required this.onSave,
  });

  @override
  State<ProfileCustomizationScreen> createState() =>
      _ProfileCustomizationScreenState();
}

class _ProfileCustomizationScreenState
    extends State<ProfileCustomizationScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _nameController;
  late String selectedSymbol;
  late final AnimationController _pulseController;

  final List<Map<String, dynamic>> symbols = [
    {"key": "moon", "icon": Icons.nights_stay_outlined, "label": "هلال"},
    {"key": "quran", "icon": Icons.menu_book_rounded, "label": "مصحف"},
    {"key": "mosque", "icon": Icons.mosque_outlined, "label": "مسجد"},
    {"key": "star", "icon": Icons.auto_awesome_outlined, "label": "نور"},
    {"key": "light", "icon": Icons.light_mode_outlined, "label": "ضياء"},
    {"key": "dua", "icon": Icons.pan_tool_alt_outlined, "label": "دعاء"},
    {"key": "seal", "icon": Icons.workspace_premium_outlined, "label": "ختم"},
    {"key": "compass", "icon": Icons.explore_outlined, "label": "قبلة"},
    {"key": "sun", "icon": Icons.wb_sunny_outlined, "label": "شروق"},
    {"key": "night", "icon": Icons.dark_mode_outlined, "label": "ليل"},
    {"key": "tasbih", "icon": Icons.blur_circular_outlined, "label": "تسبيح"},
    {"key": "peace", "icon": Icons.self_improvement_outlined, "label": "سكينة"},
    {"key": "energy", "icon": Icons.local_fire_department_outlined, "label": "نشاط"},
    {"key": "goal", "icon": Icons.gps_fixed, "label": "هدف"},
    {"key": "calm", "icon": Icons.spa_outlined, "label": "هدوء"},
    {"key": "heart", "icon": Icons.favorite_border, "label": "نية"},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    selectedSymbol = widget.currentSymbolKey;

    _nameController.addListener(() {
      setState(() {});
    });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  IconData _iconForKey(String key) {
    switch (key) {
      case "moon":
        return Icons.nights_stay_outlined;
      case "quran":
        return Icons.menu_book_rounded;
      case "mosque":
        return Icons.mosque_outlined;
      case "star":
        return Icons.auto_awesome_outlined;
      case "light":
        return Icons.light_mode_outlined;
      case "dua":
        return Icons.pan_tool_alt_outlined;
      case "seal":
        return Icons.workspace_premium_outlined;
      case "compass":
        return Icons.explore_outlined;
      case "sun":
        return Icons.wb_sunny_outlined;
      case "night":
        return Icons.dark_mode_outlined;
      case "tasbih":
        return Icons.blur_circular_outlined;
      case "peace":
        return Icons.self_improvement_outlined;
      case "energy":
        return Icons.local_fire_department_outlined;
      case "goal":
        return Icons.gps_fixed;
      case "calm":
        return Icons.spa_outlined;
      case "heart":
        return Icons.favorite_border;
      default:
        return Icons.auto_awesome_outlined;
    }
  }

  String _labelForKey(String key) {
    final item = symbols.cast<Map<String, dynamic>>().firstWhere(
          (e) => e["key"] == key,
      orElse: () => symbols.first,
    );
    return item["label"] as String;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0B0F14),
                    Color(0xFF121014),
                    Color(0xFF0C1220),
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
            ),
          ),
          Positioned(
            top: -60,
            right: -30,
            child: _glowBubble(180, AppColors.gold.withOpacity(0.10)),
          ),
          Positioned(
            bottom: 120,
            left: -20,
            child: _glowBubble(140, Colors.white.withOpacity(0.05)),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildContent()),
                _buildSaveButton(),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 8),
          const Text(
            "تخصيص الهوية",
            style: TextStyle(
              color: Colors.white,
              fontFamily: "Cairo",
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      children: [
        const SizedBox(height: 6),
        _buildPreviewCard(),
        const SizedBox(height: 24),

        const Text(
          "الاسم",
          style: TextStyle(
            color: Colors.white70,
            fontFamily: "Cairo",
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white.withOpacity(0.04),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: TextField(
            controller: _nameController,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: "Cairo",
            ),
            decoration: const InputDecoration(
              hintText: "أدخل اسمك",
              hintStyle: TextStyle(color: Colors.white38),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          "اختر الرمز الشخصي",
          style: TextStyle(
            color: Colors.white70,
            fontFamily: "Cairo",
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: symbols.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.92,
          ),
          itemBuilder: (_, i) {
            final item = symbols[i];
            final isSelected = selectedSymbol == item["key"];

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedSymbol = item["key"] as String;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: isSelected
                      ? AppColors.gold.withOpacity(0.12)
                      : Colors.white.withOpacity(0.03),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.gold
                        : Colors.white.withOpacity(0.05),
                    width: isSelected ? 1.4 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: AppColors.gold.withOpacity(0.30),
                      blurRadius: 14,
                    )
                  ]
                      : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item["icon"] as IconData,
                      color: isSelected ? AppColors.gold : Colors.white70,
                      size: 26,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item["label"] as String,
                      style: TextStyle(
                        color: isSelected ? AppColors.gold : Colors.white54,
                        fontSize: 10,
                        fontFamily: "Cairo",
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPreviewCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Colors.white.withOpacity(0.06),
                AppColors.gold.withOpacity(0.05),
              ],
            ),
            border: Border.all(
              color: AppColors.gold.withOpacity(0.16),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withOpacity(0.07),
                blurRadius: 18,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                "المعاينة المباشرة",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "Cairo",
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final pulse = 1 + (_pulseController.value * 0.04);
                  final glow = 0.18 + (_pulseController.value * 0.12);

                  return Transform.scale(
                    scale: pulse,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.gold.withOpacity(glow),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: 108,
                          height: 108,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.14),
                                Colors.black.withOpacity(0.36),
                              ],
                            ),
                            border: Border.all(
                              color: AppColors.gold.withOpacity(0.32),
                              width: 1.3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.gold.withOpacity(0.18),
                                blurRadius: 24,
                              ),
                            ],
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withOpacity(0.08),
                                  const Color(0xFF101010).withOpacity(0.96),
                                ],
                              ),
                            ),
                            child: Icon(
                              _iconForKey(selectedSymbol),
                              color: AppColors.gold,
                              size: 42,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                _nameController.text.trim().isEmpty
                    ? "عابد لله"
                    : _nameController.text.trim(),
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: "Cairo",
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _labelForKey(selectedSymbol),
                style: TextStyle(
                  color: AppColors.gold.withOpacity(0.92),
                  fontFamily: "Cairo",
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "رحلة نورك مستمرة",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.62),
                  fontFamily: "Cairo",
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: GestureDetector(
        onTap: () {
          widget.onSave(
            _nameController.text.trim(),
            selectedSymbol,
          );
          Navigator.pop(context);
        },
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                AppColors.gold.withOpacity(0.9),
                AppColors.gold.withOpacity(0.6),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withOpacity(0.25),
                blurRadius: 16,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Text(
            "حفظ التغييرات",
            style: TextStyle(
              color: Colors.black,
              fontFamily: "Cairo",
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
