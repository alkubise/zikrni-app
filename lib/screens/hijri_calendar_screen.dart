import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import '../services/theme_service.dart';
import '../constants/app_colors.dart';

class HijriCalendarScreen extends StatefulWidget {
  const HijriCalendarScreen({super.key});

  @override
  State<HijriCalendarScreen> createState() => _HijriCalendarScreenState();
}

class _HijriCalendarScreenState extends State<HijriCalendarScreen> {
  late HijriCalendar _today;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _today = HijriCalendar.now();
    _now = DateTime.now();
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
              opacity: const AlwaysStoppedAnimation(0.2),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.9),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      children: [
                        _buildCurrentDateHero(),
                        const SizedBox(height: 25),
                        _buildSectionTitle("مواعيد الأيام البيض"),
                        _buildWhiteDaysCard(),
                        const SizedBox(height: 25),
                        _buildSectionTitle("المناسبات الإسلامية 1446هـ"),
                        _buildIslamicEvents(),
                        const SizedBox(height: 30),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold.withOpacity(0.3)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.gold, size: 20),
            ),
          ),
          const Text(
            "التقويم الهجري",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              fontFamily: "Cairo",
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildCurrentDateHero() {
    String dayName = DateFormat('EEEE', 'ar').format(_now);
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(35),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(35),
            border: Border.all(color: AppColors.gold.withOpacity(0.25)),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withOpacity(0.05),
                blurRadius: 30,
                spreadRadius: 2,
              )
            ],
          ),
          child: Column(
            children: [
              Text(
                dayName,
                style: const TextStyle(color: AppColors.gold, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "Cairo"),
              ),
              const SizedBox(height: 5),
              Text(
                _today.hDay.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 85, fontWeight: FontWeight.w900, height: 1.1),
              ),
              Text(
                _today.getLongMonthName(),
                style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, fontFamily: "Cairo"),
              ),
              Text(
                "${_today.hYear} هـ",
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 18, fontFamily: "Cairo"),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(color: Colors.white10, thickness: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_today_rounded, color: Colors.white38, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('dd MMMM yyyy', 'ar').format(_now),
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 15, fontFamily: "Cairo"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(right: 5, bottom: 15),
      child: Row(
        children: [
          Container(width: 4, height: 20, decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold, fontFamily: "Cairo")),
        ],
      ),
    );
  }

  Widget _buildWhiteDaysCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37).withOpacity(0.08),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.gold.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wb_sunny_rounded, color: AppColors.gold, size: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("صيام الأيام البيض لهذا الشهر", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: "Cairo")),
                const SizedBox(height: 4),
                Text(
                  "13، 14، 15 ${_today.getLongMonthName()}",
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13, fontFamily: "Cairo"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIslamicEvents() {
    final List<Map<String, String>> events = [
      {"title": "بداية شهر رمضان", "date": "1 رمضان 1446", "left": "مبارك"},
      {"title": "عيد الفطر المبارك", "date": "1 شوال 1446", "left": "فرحة"},
      {"title": "يوم عرفة", "date": "9 ذو الحجة 1446", "left": "دعاء"},
      {"title": "عيد الأضحى", "date": "10 ذو الحجة 1446", "left": "نحر"},
      {"title": "رأس السنة الهجرية", "date": "1 محرم 1447", "left": "بداية"},
      {"title": "يوم عاشوراء", "date": "10 محرم 1447", "left": "صيام"},
    ];

    return Column(
      children: events.map((event) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(event['left']!, style: const TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: "Cairo")),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event['title']!, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: "Cairo")),
                  Text(event['date']!, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12, fontFamily: "Cairo")),
                ],
              ),
            ),
            const Icon(Icons.event_available_rounded, color: Colors.white12, size: 20),
          ],
        ),
      )).toList(),
    );
  }
}
