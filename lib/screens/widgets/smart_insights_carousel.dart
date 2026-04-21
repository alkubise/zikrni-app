import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import 'tilt_glass_card.dart';

class SmartInsightsCarousel extends StatelessWidget {
  final List<String> items;
  final List<int> weeklyHeatmap;

  const SmartInsightsCarousel({
    super.key,
    required this.items,
    required this.weeklyHeatmap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ...items.map(
                (item) => Padding(
              padding: const EdgeInsets.only(left: 10),
              child: SizedBox(
                width: 260,
                child: TiltGlassCard(
                  maxTilt: 0.02,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.auto_awesome, color: AppColors.gold, size: 18),
                          SizedBox(width: 8),
                          Text(
                            "رؤية ذكية",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: "Cairo",
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Text(
                          item,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: "Cairo",
                            fontSize: 13,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: SizedBox(
              width: 260,
              child: TiltGlassCard(
                maxTilt: 0.02,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.local_fire_department, color: AppColors.gold, size: 18),
                        SizedBox(width: 8),
                        Text(
                          "النشاط الأسبوعي",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "Cairo",
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: weeklyHeatmap.map((v) => _cell(v)).toList(),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "كلما زاد الذكر زادت حرارة النور في الأسبوع",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                        fontFamily: "Cairo",
                        fontSize: 11,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cell(int value) {
    final opacity = (0.10 + (value / 10) * 0.90).clamp(0.10, 1.0);
    return Container(
      width: 24,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.gold.withOpacity(opacity * 0.65),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
    );
  }
}