import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIInsight {
  final String motivationalMessage;
  final String bestTime;
  final bool hasDecline;
  final String declineNote;
  final int suggestedDailyGoal;
  final String todayPlan;

  const AIInsight({
    required this.motivationalMessage,
    required this.bestTime,
    required this.hasDecline,
    required this.declineNote,
    required this.suggestedDailyGoal,
    required this.todayPlan,
  });

  factory AIInsight.fromJson(Map<String, dynamic> json) {
    return AIInsight(
      motivationalMessage:
      (json['motivational_message'] ?? 'استمر، نورك يتصاعد ✨').toString(),
      bestTime: (json['best_time'] ?? 'الصباح').toString(),
      hasDecline: json['has_decline'] == true,
      declineNote: (json['decline_note'] ?? 'أداؤك مستقر').toString(),
      suggestedDailyGoal:
      _safeInt(json['suggested_daily_goal'], fallback: 33),
      todayPlan: (json['today_plan'] ?? 'ابدأ بـ 10 أذكار صباحًا و10 مساءً.')
          .toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'motivational_message': motivationalMessage,
      'best_time': bestTime,
      'has_decline': hasDecline,
      'decline_note': declineNote,
      'suggested_daily_goal': suggestedDailyGoal,
      'today_plan': todayPlan,
    };
  }

  static int _safeInt(dynamic value, {required int fallback}) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }
}

class AIService {
  static String get apiKey => dotenv.env['OPENAI_API_KEY'] ?? "YOUR_OPENAI_API_KEY";
  static const String _endpoint = "https://api.openai.com/v1/chat/completions";
  static const String _model = "gpt-4o-mini";

  static Future<AIInsight> generateInsight({
    required int today,
    required int weekly,
    required int total,
    int? yesterday,
    int? last7DaysAverage,
  }) async {
    try {
      if (apiKey == "YOUR_OPENAI_API_KEY" || apiKey.isEmpty) {
        return _buildFallbackInsight(
          today: today,
          weekly: weekly,
          total: total,
          yesterday: yesterday ?? 0,
          last7DaysAverage: last7DaysAverage ?? _estimateAverage(weekly),
        );
      }

      final int safeYesterday = yesterday ?? 0;
      final int safeAverage = last7DaysAverage ?? _estimateAverage(weekly);

      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $apiKey",
        },
        body: jsonEncode({
          "model": _model,
          "temperature": 0.7,
          "messages": [
            {
              "role": "system",
              "content": """
أنت مساعد ذكي داخل تطبيق أذكار.
حلل نشاط المستخدم بروح لطيفة وعملية.
أعد النتيجة بصيغة JSON فقط دون أي نص إضافي.
المفاتيح المطلوبة بالضبط:
motivational_message
best_time
has_decline
decline_note
suggested_daily_goal
today_plan

قواعد الإخراج:
- best_time يكون نصًا قصيرًا مثل: الفجر، الصباح، بعد العصر، المساء
- has_decline قيمة منطقية true أو false
- suggested_daily_goal رقم صحيح مناسب وغير مبالغ فيه
- today_plan جملة عربية قصيرة عملية جدًا
- motivational_message قصيرة وملهمة
- decline_note قصيرة وواضحة
"""
            },
            {
              "role": "user",
              "content": """
هذه بيانات المستخدم:
- عدد أذكار اليوم: $today
- عدد أذكار الأمس: $safeYesterday
- مجموع الأسبوع: $weekly
- متوسط آخر 7 أيام: $safeAverage
- المجموع الكلي: $total

المطلوب:
1) اقترح أفضل وقت للذكر لهذا المستخدم
2) اكتشف هل هناك تراجع في النشاط
3) اقترح هدفًا يوميًا مناسبًا
4) أعط خطة اليوم
5) أعط رسالة تحفيزية قصيرة

أعد JSON فقط.
"""
            }
          ]
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return _buildFallbackInsight(
          today: today,
          weekly: weekly,
          total: total,
          yesterday: safeYesterday,
          last7DaysAverage: safeAverage,
        );
      }

      final Map<String, dynamic> data =
      jsonDecode(utf8.decode(response.bodyBytes));

      final String raw =
      ((data["choices"]?[0]?["message"]?["content"]) ?? "").toString();

      final Map<String, dynamic> parsed = _extractJsonObject(raw);

      return AIInsight.fromJson(parsed);
    } catch (_) {
      return _buildFallbackInsight(
        today: today,
        weekly: weekly,
        total: total,
        yesterday: yesterday ?? 0,
        last7DaysAverage: last7DaysAverage ?? _estimateAverage(weekly),
      );
    }
  }

  static Future<String> generateInsightText({
    required int today,
    required int weekly,
    required int total,
    int? yesterday,
    int? last7DaysAverage,
  }) async {
    final insight = await generateInsight(
      today: today,
      weekly: weekly,
      total: total,
      yesterday: yesterday,
      last7DaysAverage: last7DaysAverage,
    );

    return """
${insight.motivationalMessage}
أفضل وقت لك: ${insight.bestTime}
هدفك اليوم: ${insight.suggestedDailyGoal} ذكر
خطة اليوم: ${insight.todayPlan}
""".trim();
  }

  static AIInsight _buildFallbackInsight({
    required int today,
    required int weekly,
    required int total,
    required int yesterday,
    required int last7DaysAverage,
  }) {
    final bool hasDecline =
        today < yesterday || today < (last7DaysAverage * 0.6);

    final String bestTime = _bestTimeSuggestion(today, weekly);
    final int goal = _smartGoal(today, weekly, total);

    return AIInsight(
      motivationalMessage: _fallbackMotivation(today, total),
      bestTime: bestTime,
      hasDecline: hasDecline,
      declineNote: hasDecline
          ? "يوجد هدوء بسيط في نشاطك اليوم، والعودة السريعة سهلة."
          : "أداؤك مستقر ويتقدم بشكل جميل.",
      suggestedDailyGoal: goal,
      todayPlan: _fallbackPlan(goal),
    );
  }

  static int _estimateAverage(int weekly) {
    if (weekly <= 0) return 0;
    return (weekly / 7).round();
  }

  static int _smartGoal(int today, int weekly, int total) {
    final avg = _estimateAverage(weekly);

    if (total < 50) return 20;
    if (avg < 15) return 33;
    if (avg < 40) return 50;
    if (today >= 80) return 100;
    return 70;
  }

  static String _bestTimeSuggestion(int today, int weekly) {
    if (today == 0 && weekly < 20) return "بعد الفجر";
    if (weekly < 80) return "الصباح";
    if (weekly < 200) return "بعد العصر";
    return "المساء";
  }

  static String _fallbackMotivation(int today, int total) {
    if (today == 0) return "ابدأ اليوم بخطوة خفيفة، فالثبات الصغير يصنع نورًا كبيرًا 🌱";
    if (today < 30) return "إيقاعك هادئ وجميل، فقط استمر قليلًا اليوم ✨";
    if (today < 100) return "أنت في مسار متوازن ومشرق، حافظ على هذا النسق 🌟";
    if (total > 500) return "رحلتك أصبحت واضحة الأثر، ونورك يتراكم يومًا بعد يوم 🔥";
    return "أحسنت، تقدمك ملحوظ جدًا اليوم 🤍";
  }

  static String _fallbackPlan(int goal) {
    if (goal <= 20) {
      return "ابدأ بـ 10 أذكار صباحًا و10 مساءً.";
    }
    if (goal <= 33) {
      return "قسّم ذكرك إلى 3 دفعات خفيفة خلال اليوم.";
    }
    if (goal <= 50) {
      return "ابدأ بعد الفجر، ثم دفعة بعد العصر، ثم ختمة قصيرة قبل النوم.";
    }
    if (goal <= 70) {
      return "اجعل لك 4 محطات: صباحًا، ظهرًا، مساءً، وقبل النوم.";
    }
    return "قسّم يومك إلى 5 محطات قصيرة حتى تصل لهدفك بسهولة.";
  }

  static Map<String, dynamic> _extractJsonObject(String raw) {
    final trimmed = raw.trim();

    try {
      return jsonDecode(trimmed) as Map<String, dynamic>;
    } catch (_) {
      final start = trimmed.indexOf('{');
      final end = trimmed.lastIndexOf('}');
      if (start != -1 && end != -1 && end > start) {
        final slice = trimmed.substring(start, end + 1);
        return jsonDecode(slice) as Map<String, dynamic>;
      }
      return {};
    }
  }
}
