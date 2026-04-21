import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/ui/app_layout.dart';
import '../constants/app_colors.dart';

class ReportProblemScreen extends StatefulWidget {
  const ReportProblemScreen({super.key});

  @override
  State<ReportProblemScreen> createState() => _ReportProblemScreenState();
}

class _ReportProblemScreenState extends State<ReportProblemScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = "خلل تقني";

  final List<String> _categories = [
    "خلل تقني",
    "خطأ في النصوص",
    "اقتراح تحسين",
    "مشكلة في الإشعارات",
    "أخرى",
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitReport() {
    if (_subjectController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("يرجى ملء جميع الحقول")),
      );
      return;
    }
    
    // تم استبدال successImpact بـ lightImpact لتجنب خطأ التجميع
    HapticFeedback.lightImpact();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("شكراً لك، تم إرسال البلاغ وسنراجعه قريباً")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final layout = AppLayout(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Image.asset(
                "assets/images/background_night.png",
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(color: Colors.black.withOpacity(0.8)),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, layout),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: layout.scale(24)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHero(layout),
                        SizedBox(height: layout.scale(30)),
                        _buildLabel("نوع المشكلة", layout),
                        _buildCategorySelector(layout),
                        SizedBox(height: layout.scale(20)),
                        _buildLabel("العنوان", layout),
                        _buildTextField(
                          controller: _subjectController,
                          hint: "مثلاً: لا تظهر أذكار المساء",
                          layout: layout,
                        ),
                        SizedBox(height: layout.scale(20)),
                        _buildLabel("التفاصيل", layout),
                        _buildTextField(
                          controller: _descriptionController,
                          hint: "يرجى شرح المشكلة بالتفصيل لنتمكن من مساعدتك...",
                          maxLines: 6,
                          layout: layout,
                        ),
                        SizedBox(height: layout.scale(40)),
                        _buildSubmitButton(layout),
                        SizedBox(height: layout.scale(30)),
                        _buildContactInfo(layout),
                        SizedBox(height: layout.scale(40)),
                      ],
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

  Widget _buildAppBar(BuildContext context, AppLayout layout) {
    return Padding(
      padding: EdgeInsets.all(layout.scale(16)),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close_rounded, color: Colors.white, size: layout.scale(24)),
            style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.05)),
          ),
          const Spacer(),
          Text(
            "الإبلاغ عن مشكلة",
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

  Widget _buildHero(AppLayout layout) {
    return Column(
      children: [
        Icon(Icons.bug_report_outlined, color: AppColors.gold, size: layout.scale(60)),
        SizedBox(height: layout.scale(16)),
        const Text(
          "نحن نسمعك",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            fontFamily: "Cairo",
          ),
        ),
        SizedBox(height: layout.scale(8)),
        Text(
          "ملاحظاتك تساعدنا في تحسين 'ذكرني' ليكون رفيقاً أفضل للجميع.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 13,
            fontFamily: "Cairo",
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text, AppLayout layout) {
    return Padding(
      padding: EdgeInsets.only(bottom: layout.scale(8), right: 4),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.gold.withOpacity(0.9),
          fontSize: 14,
          fontWeight: FontWeight.bold,
          fontFamily: "Cairo",
        ),
      ),
    );
  }

  Widget _buildCategorySelector(AppLayout layout) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          dropdownColor: Colors.grey[900],
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.gold),
          isExpanded: true,
          items: _categories.map((c) {
            return DropdownMenuItem(
              value: c,
              child: Text(
                c,
                style: const TextStyle(color: Colors.white, fontFamily: "Cairo", fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedCategory = val!),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    required AppLayout layout,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white, fontFamily: "Cairo"),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 13),
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSubmitButton(AppLayout layout) {
    return GestureDetector(
      onTap: _submitReport,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.gold, AppColors.gold.withOpacity(0.7)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: AppColors.gold.withOpacity(0.2), blurRadius: 20, spreadRadius: 1),
          ],
        ),
        child: const Center(
          child: Text(
            "إرسال البلاغ",
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              fontFamily: "Cairo",
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactInfo(AppLayout layout) {
    return Center(
      child: Column(
        children: [
          Text(
            "أو تواصل معنا مباشرة عبر البريد:",
            style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11, fontFamily: "Cairo"),
          ),
          const SizedBox(height: 8),
          const Text(
            "support@zikrni.app",
            style: TextStyle(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
