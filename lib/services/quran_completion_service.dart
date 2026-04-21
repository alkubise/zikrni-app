import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class QuranCompletionPlan {
  final int days;
  final DateTime startDate;
  int currentPage;

  QuranCompletionPlan({
    required this.days,
    required this.startDate,
    this.currentPage = 1,
  });

  Map<String, dynamic> toJson() => {
    'days': days,
    'startDate': startDate.toIso8601String(),
    'currentPage': currentPage,
  };

  factory QuranCompletionPlan.fromJson(Map<String, dynamic> json) => QuranCompletionPlan(
    days: json['days'],
    startDate: DateTime.parse(json['startDate']),
    currentPage: json['currentPage'],
  );
}

class QuranCompletionService {
  static const String _key = 'quran_completion_plan';

  static Future<void> savePlan(QuranCompletionPlan plan) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json.encode(plan.toJson()));
  }

  static Future<QuranCompletionPlan?> getPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_key);
    if (data == null) return null;
    return QuranCompletionPlan.fromJson(json.decode(data));
  }

  static Future<void> updateProgress(int page) async {
    final plan = await getPlan();
    if (plan != null) {
      plan.currentPage = page;
      await savePlan(plan);
    }
  }

  static Future<void> deletePlan() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  // حساب الورد اليومي (عدد الصفحات المطلوبة يومياً)
  static int calculateDailyPages(int totalDays) {
    return (604 / totalDays).ceil();
  }

  // حساب اليوم الحالي في الخطة
  static int getCurrentDay(DateTime startDate) {
    return DateTime.now().difference(startDate).inDays + 1;
  }
}
