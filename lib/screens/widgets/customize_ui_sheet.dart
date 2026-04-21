import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../controllers/home_controller.dart';

Future<void> showCustomizeUiSheet(
    BuildContext context,
    HomeController controller,
    ) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _CustomizeUiSheet(controller: controller),
  );
}

class _CustomizeUiSheet extends StatefulWidget {
  final HomeController controller;

  const _CustomizeUiSheet({required this.controller});

  @override
  State<_CustomizeUiSheet> createState() => _CustomizeUiSheetState();
}

class _CustomizeUiSheetState extends State<_CustomizeUiSheet> {
  @override
  Widget build(BuildContext context) {
    final c = widget.controller;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: AppColors.gold.withOpacity(0.18)),
      ),
      child: SafeArea(
        top: false,
        child: Wrap(
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              "تخصيص الواجهة",
              style: TextStyle(
                color: Colors.white,
                fontFamily: "Cairo",
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 14),
            SwitchListTile(
              value: c.largeTextEnabled,
              activeColor: AppColors.gold,
              title: const Text("تكبير النص", style: TextStyle(color: Colors.white, fontFamily: "Cairo")),
              subtitle: Text("وضع أكثر راحة للقراءة", style: TextStyle(color: Colors.white.withOpacity(0.6), fontFamily: "Cairo")),
              onChanged: (v) async {
                await c.setLargeText(v);
                setState(() {});
              },
            ),
            SwitchListTile(
              value: c.showGlassEffects,
              activeColor: AppColors.gold,
              title: const Text("تأثيرات الزجاج", style: TextStyle(color: Colors.white, fontFamily: "Cairo")),
              subtitle: Text("تقليل أو تفعيل المؤثرات البصرية", style: TextStyle(color: Colors.white.withOpacity(0.6), fontFamily: "Cairo")),
              onChanged: (v) async {
                await c.setShowGlassEffects(v);
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
}