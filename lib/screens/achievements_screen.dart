import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../controllers/zikr_controller.dart';
import '../services/stats_service.dart';
import '../services/ai_service.dart';
import '../services/user_service.dart';
import '../services/theme_service.dart';
import '../core/ui/app_layout.dart';
import '../constants/app_colors.dart';

class OrbitNode {
  final String text;
  final bool isGolden;
  final bool isHundredStar;
  final int orbitIndex;
  final double angle;
  final double sizeFactor;

  OrbitNode({
    required this.text,
    required this.isGolden,
    required this.isHundredStar,
    required this.orbitIndex,
    required this.angle,
    required this.sizeFactor,
  });
}

class AchievementBadge {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool unlocked;

  AchievementBadge({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.unlocked,
  });
}

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with TickerProviderStateMixin {
  final ScreenshotController screenshotController = ScreenshotController();

  late final AnimationController _pulseController;
  late final AnimationController _rotationController;
  late final AnimationController _twinkleController;

  bool _showStats = false;
  bool _isCapturing = false;

  bool _aiEnabled = true;
  bool _showNameOnShare = true;

  String _aiInsightText = "جارٍ تحليل رحلتك الروحية...";
  String _aiBestTime = "--";
  String _aiPlan = "--";
  String _aiDeclineNote = "--";
  int _aiGoal = 33;
  bool _aiHasDecline = false;

  List<OrbitNode> _dailyNodes = [];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();

    _twinkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _initScreen();
    ZikrController.instance.addListener(_onZikrChanged);
    StatsService.loadFromController(ZikrController.instance.events);
  }

  Future<void> _initScreen() async {
    await _loadSettings();
    _buildConstellations();
    _loadAI();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _aiEnabled = prefs.getBool("ai_assistant_enabled") ?? true;
    _showNameOnShare = prefs.getBool("show_name_on_share") ?? true;

    if (!mounted) return;
    setState(() {});
  }

  void _onZikrChanged() {
    if (mounted) {
      setState(() {
        _buildConstellations();
      });
      _loadAI();
    }
  }

  void _loadAI() async {
    final total = ZikrController.instance.total;
    final today = StatsService.getTodayCount();
    final week = StatsService.getWeekCount();

    if (!_aiEnabled) {
      if (!mounted) return;
      setState(() {
        _aiInsightText = "المرشد الذكي متوقف من الإعدادات";
        _aiBestTime = "--";
        _aiPlan = "--";
        _aiDeclineNote = "--";
        _aiGoal = 0;
        _aiHasDecline = false;
      });
      return;
    }

    final insight = await AIService.generateInsight(
      today: today,
      weekly: week,
      total: total,
    );

    if (mounted) {
      setState(() {
        _aiInsightText = insight.motivationalMessage;
        _aiBestTime = insight.bestTime;
        _aiPlan = insight.todayPlan;
        _aiDeclineNote = insight.declineNote;
        _aiGoal = insight.suggestedDailyGoal;
        _aiHasDecline = insight.hasDecline;
      });
    }
  }

  void _buildConstellations() {
    final controller = ZikrController.instance;
    final source = controller.events;

    const int limit = 60;
    final int visibleCount = source.length > limit ? limit : source.length;

    _dailyNodes = [];
    if (visibleCount == 0) return;

    final recent = source.sublist(source.length - visibleCount, source.length);

    for (int i = 0; i < recent.length; i++) {
      final orbitIndex = i % 3;
      final angle = ((2 * pi) / max(1, recent.length)) * i;

      final countIndex = i + 1;
      final isHundredStar = countIndex % 100 == 0;
      final isGolden = countIndex % 10 == 0 || isHundredStar;

      final sizeFactor = isHundredStar
          ? 1.9
          : isGolden
          ? 1.35
          : (0.85 + (i % 4) * 0.06);

      _dailyNodes.add(
        OrbitNode(
          text: recent[i].text,
          isGolden: isGolden,
          isHundredStar: isHundredStar,
          orbitIndex: orbitIndex,
          angle: angle,
          sizeFactor: sizeFactor,
        ),
      );
    }
  }

  String _nextGoal(int total) {
    int next = ((total ~/ 100) + 1) * 100;
    return "$next ذكر";
  }

  String _rankTitle(int total) {
    if (total < 50) return "المنطلق";
    if (total < 150) return "الذاكر الصاعد";
    if (total < 300) return "رفيق النور";
    if (total < 600) return "صاحب السكينة";
    if (total < 1000) return "سفير الذكر";
    return "نجم الأذكار";
  }

  List<AchievementBadge> _buildBadges(
      int total, int today, int week, int month) {
    return [
      AchievementBadge(
        title: "البداية",
        subtitle: "أول 10 أذكار",
        icon: Icons.star_rounded,
        unlocked: total >= 10,
      ),
      AchievementBadge(
        title: "نور المئة",
        subtitle: "وصلت 100 ذكر",
        icon: Icons.auto_awesome_rounded,
        unlocked: total >= 100,
      ),
      AchievementBadge(
        title: "يوم قوي",
        subtitle: "100 ذكر في يوم واحد",
        icon: Icons.local_fire_department_rounded,
        unlocked: today >= 100,
      ),
      AchievementBadge(
        title: "ثبات أسبوعي",
        subtitle: "200 ذكر هذا الأسبوع",
        icon: Icons.workspace_premium_rounded,
        unlocked: week >= 200,
      ),
      AchievementBadge(
        title: "ازدهار شهري",
        subtitle: "500 ذكر هذا الشهر",
        icon: Icons.diamond_rounded,
        unlocked: month >= 500,
      ),
    ];
  }

  @override
  void dispose() {
    ZikrController.instance.removeListener(_onZikrChanged);
    _pulseController.dispose();
    _rotationController.dispose();
    _twinkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final layout = AppLayout(context);
    final total = ZikrController.instance.total;
    final today = StatsService.getTodayCount();
    final week = StatsService.getWeekCount();
    final month = StatsService.getMonthCount();
    final level = (total ~/ 100) + 1;
    final stars100 = total ~/ 100;

    final theme = ThemeService.instance;
    final compactMode = theme.compactMode;
    final visualMode = theme.visualMode;

    double glowOpacity = today > 100 ? 0.9 : today > 50 ? 0.6 : 0.3;
    if (visualMode == "soft") glowOpacity *= 0.85;
    if (visualMode == "cinematic") glowOpacity *= 1.15;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Screenshot(
        controller: screenshotController,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                "assets/images/background_nightan.png",
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _twinkleController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: StarFieldPainter(
                      shimmer: _twinkleController.value,
                      accent: AppColors.gold,
                      densityFactor: visualMode == "soft"
                          ? 0.70
                          : visualMode == "cinematic"
                          ? 1.20
                          : 1.0,
                    ),
                  );
                },
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.05),
                    radius: 1.0,
                    colors: [
                      AppColors.gold.withValues(alpha: 0.05 * glowOpacity),
                      AppColors.black.withValues(alpha: 0.45),
                      AppColors.black.withValues(alpha: 0.88),
                    ],
                  ),
                ),
              ),
            ),
            if (!_isCapturing)
              _buildTopHud(
                layout,
                level,
                total,
                stars100,
                AppColors.gold,
                _rankTitle(total),
                _nextGoal(total),
                compactMode,
              ),
            Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _pulseController,
                  _rotationController,
                ]),
                builder: (context, child) {
                  return _buildConstellationCore(
                    context: context,
                    layout: layout,
                    accent: AppColors.gold,
                    todayCount: today,
                    compactMode: compactMode,
                  );
                },
              ),
            ),
            if (_showStats)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.25),
                  child: _buildModernAchievementsPanel(
                    layout: layout,
                    total: total,
                    today: today,
                    week: week,
                    month: month,
                    level: level,
                    stars100: stars100,
                    accent: AppColors.gold,
                    compactMode: compactMode,
                  ),
                ),
              ),
            if (!_isCapturing) _buildBottomActions(layout, AppColors.gold),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHud(
      AppLayout layout,
      int level,
      int total,
      int stars100,
      Color accent,
      String rank,
      String nextGoal,
      bool compactMode,
      ) {
    return Positioned(
      top: layout.topSafe(8),
      left: layout.scale(16),
      right: layout.scale(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _glassInfoBox(layout, "المستوى $level", accent,
                  compactMode: compactMode),
              _glassInfoBox(layout, "⭐ نجوم المئة: $stars100", accent,
                  compactMode: compactMode),
              _glassInfoBox(layout, "الإجمالي: $total", accent,
                  compactMode: compactMode),
            ],
          ),
          SizedBox(height: layout.scale(compactMode ? 8 : 12)),
          _glassInfoBox(
            layout,
            "رتبتك: $rank • الهدف القادم: $nextGoal",
            accent,
            wide: true,
            compactMode: compactMode,
          ),
        ],
      ),
    );
  }

  Widget _glassInfoBox(
      AppLayout layout,
      String text,
      Color accent, {
        bool wide = false,
        bool compactMode = false,
      }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(layout.scale(compactMode ? 14 : 16)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: wide ? double.infinity : null,
          padding: EdgeInsets.symmetric(
            horizontal: layout.scale(compactMode ? 10 : 14),
            vertical: layout.scale(compactMode ? 7 : 9),
          ),
          decoration: BoxDecoration(
            color: AppColors.black.withValues(alpha: 0.36),
            borderRadius:
            BorderRadius.circular(layout.scale(compactMode ? 14 : 16)),
            border: Border.all(color: accent.withValues(alpha: 0.45)),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontFamily: "Cairo",
              fontSize: layout.scale(compactMode ? 10 : 11),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanets(double size, double rotation) {
    const days = 7;
    return Stack(
      children: List.generate(days, (i) {
        double angle = (2 * pi / days) * i + rotation;
        double radius = size * 0.38;
        return Positioned(
          left: size / 2 + radius * cos(angle) - 10,
          top: size / 2 + radius * sin(angle) - 10,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [
                  Colors.orangeAccent,
                  Colors.deepOrange,
                  Colors.transparent
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.orangeAccent.withValues(alpha: 0.8),
                  blurRadius: 20,
                  spreadRadius: 3,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSun(Color accent, int todayCount) {
    double glow = todayCount > 100 ? 0.5 : todayCount > 50 ? 0.35 : 0.2;

    return Transform.scale(
      scale: 1 + (glow * 0.4),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.white,
              accent.withValues(alpha: 0.8),
              accent.withValues(alpha: 0.15),
              Colors.transparent,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: glow),
              blurRadius: 35,
              spreadRadius: 6,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoon(int todayCount, AppLayout layout) {
    IconData moon;
    if (todayCount < 20) {
      moon = Icons.brightness_2;
    } else if (todayCount < 60) {
      moon = Icons.brightness_3;
    } else {
      moon = Icons.brightness_7;
    }
    return Icon(moon, color: AppColors.white, size: layout.scale(42));
  }

  Widget _buildConstellationCore({
    required BuildContext context,
    required AppLayout layout,
    required Color accent,
    required int todayCount,
    required bool compactMode,
  }) {
    final base = min(layout.width, layout.height) * 0.72;
    final rotation = _rotationController.value * 2 * pi;

    return SizedBox(
      width: base,
      height: base,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(base, base),
            painter: OrbitPainter(rotation: rotation, accent: accent),
          ),
          _buildPlanets(base, rotation),
          _buildSun(accent, todayCount),
          Positioned(
            top: layout.scale(40),
            child: _buildMoon(todayCount, layout),
          ),
          ..._dailyNodes.map(
                (node) => _buildOrbitNode(
              node: node,
              centerSize: base,
              rotation: rotation,
              accent: accent,
            ),
          ),
          Text(
            "$todayCount",
            style: TextStyle(
              color: AppColors.white,
              fontSize: layout.scale(compactMode ? 22 : 24),
              fontWeight: FontWeight.bold,
              fontFamily: "Cairo",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrbitNode({
    required OrbitNode node,
    required double centerSize,
    required double rotation,
    required Color accent,
  }) {
    final orbitRadii = [
      centerSize * 0.20,
      centerSize * 0.30,
      centerSize * 0.40
    ];
    final radius = orbitRadii[node.orbitIndex];
    final angle = node.angle + (rotation * (0.35 + node.orbitIndex * 0.18));
    final dx = radius * cos(angle);
    final dy = radius * sin(angle);
    final nodeSize = node.isHundredStar ? 16.0 : 8.0;

    return Positioned(
      left: (centerSize / 2) + dx - (nodeSize / 2),
      top: (centerSize / 2) + dy - (nodeSize / 2),
      child: Transform.scale(
        scale: node.sizeFactor * (1 + (_pulseController.value * 0.2)),
        child: Container(
          width: nodeSize,
          height: nodeSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: node.isHundredStar
                ? AppColors.white
                : (node.isGolden ? accent : AppColors.white),
            boxShadow: [
              BoxShadow(
                color:
                (node.isGolden ? accent : AppColors.white).withValues(alpha: 0.52),
                blurRadius: 10,
              ),
            ],
          ),
          child: node.isHundredStar
              ? Icon(Icons.auto_awesome, size: 12, color: AppColors.gold)
              : null,
        ),
      ),
    );
  }

  Widget _buildModernAchievementsPanel({
    required AppLayout layout,
    required int total,
    required int today,
    required int week,
    required int month,
    required int level,
    required int stars100,
    required Color accent,
    required bool compactMode,
  }) {
    final progress = ((total % 100) / 100).clamp(0.0, 1.0);
    final nextGoal = _nextGoal(total);
    final rank = _rankTitle(total);
    final badges = _buildBadges(total, today, week, month);

    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: layout.scale(16),
            vertical: layout.scale(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(layout.scale(34)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: layout.scale(355),
                  maxHeight: layout.height * 0.86,
                ),
                child: Container(
                  width: layout.scale(355),
                  padding: EdgeInsets.all(layout.scale(compactMode ? 16 : 20)),
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(layout.scale(34)),
                    border: Border.all(color: accent.withValues(alpha: 0.45)),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.18),
                        blurRadius: 28,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.workspace_premium_rounded,
                          color: accent,
                          size: layout.scale(42),
                        ),
                        SizedBox(height: layout.scale(10)),
                        Text(
                          "مركز الإنجازات",
                          style: TextStyle(
                            color: accent,
                            fontSize: layout.scale(22),
                            fontWeight: FontWeight.bold,
                            fontFamily: "Cairo",
                          ),
                        ),
                        SizedBox(height: layout.scale(6)),
                        Text(
                          "رحلتك، رتبتك، وتحليل الذكر الذكي",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.white.withValues(alpha: 0.45),
                            fontSize: layout.scale(11),
                            fontFamily: "Cairo",
                          ),
                        ),
                        SizedBox(height: layout.scale(18)),
                        _heroProgressCard(
                          layout,
                          total,
                          level,
                          nextGoal,
                          progress,
                          accent,
                          rank,
                          compactMode,
                        ),
                        SizedBox(height: layout.scale(18)),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "الأوسمة المفتوحة",
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: layout.scale(14),
                              fontWeight: FontWeight.bold,
                              fontFamily: "Cairo",
                            ),
                          ),
                        ),
                        SizedBox(height: layout.scale(12)),
                        SizedBox(
                          height: layout.scale(104),
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: badges.length,
                            separatorBuilder: (_, __) =>
                                SizedBox(width: layout.scale(10)),
                            itemBuilder: (_, i) =>
                                _badgeCard(layout, badges[i], accent),
                          ),
                        ),
                        SizedBox(height: layout.scale(18)),
                        _aiCoachCard(layout, accent),
                        SizedBox(height: layout.scale(18)),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => setState(() => _showStats = false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              minimumSize:
                              Size(double.infinity, layout.scale(54)),
                            ),
                            child: Text(
                              "إغلاق",
                              style: TextStyle(
                                color: AppColors.black,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Cairo",
                                fontSize: layout.scale(15),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _heroProgressCard(
      AppLayout layout,
      int total,
      int level,
      String nextGoal,
      double progress,
      Color accent,
      String rank,
      bool compactMode,
      ) {
    return Container(
      padding: EdgeInsets.all(layout.scale(compactMode ? 14 : 16)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(layout.scale(22)),
        color: AppColors.white.withValues(alpha: 0.04),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "رتبتك الحالية",
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha: 0.45),
                        fontSize: layout.scale(10),
                        fontFamily: "Cairo",
                      ),
                    ),
                    SizedBox(height: layout.scale(6)),
                    Text(
                      rank,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: layout.scale(compactMode ? 16 : 18),
                        fontWeight: FontWeight.bold,
                        fontFamily: "Cairo",
                      ),
                    ),
                    SizedBox(height: layout.scale(4)),
                    Text(
                      "المستوى $level",
                      style: TextStyle(
                        color: accent,
                        fontSize: layout.scale(12),
                        fontWeight: FontWeight.bold,
                        fontFamily: "Cairo",
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: layout.scale(62),
                height: layout.scale(62),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accent.withValues(alpha: 0.45),
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Text(
                    "${(progress * 100).toInt()}%",
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Cairo",
                      fontSize: layout.scale(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: layout.scale(16)),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.white.withValues(alpha: 0.05),
              valueColor: AlwaysStoppedAnimation(accent),
            ),
          ),
          SizedBox(height: layout.scale(10)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "الإجمالي: $total",
                style: TextStyle(
                  color: AppColors.white.withValues(alpha: 0.60),
                  fontFamily: "Cairo",
                  fontSize: layout.scale(11),
                ),
              ),
              Text(
                "الهدف القادم: $nextGoal",
                style: TextStyle(
                  color: accent,
                  fontFamily: "Cairo",
                  fontWeight: FontWeight.bold,
                  fontSize: layout.scale(11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badgeCard(
      AppLayout layout,
      AchievementBadge badge,
      Color accent,
      ) {
    final active = badge.unlocked;

    return Container(
      width: layout.scale(120),
      padding: EdgeInsets.all(layout.scale(12)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(layout.scale(20)),
        color: active
            ? accent.withValues(alpha: 0.10)
            : AppColors.white.withValues(alpha: 0.03),
        border: Border.all(
          color: active
              ? accent.withValues(alpha: 0.45)
              : AppColors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            badge.icon,
            color: active
                ? accent
                : AppColors.white.withValues(alpha: 0.22),
            size: layout.scale(26),
          ),
          SizedBox(height: layout.scale(10)),
          Text(
            badge.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active
                  ? AppColors.white
                  : AppColors.white.withValues(alpha: 0.35),
              fontWeight: FontWeight.bold,
              fontFamily: "Cairo",
              fontSize: layout.scale(12),
            ),
          ),
          SizedBox(height: layout.scale(5)),
          Text(
            badge.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.35),
              fontFamily: "Cairo",
              fontSize: layout.scale(9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _aiCoachCard(AppLayout layout, Color accent) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(layout.scale(14)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(layout.scale(18)),
        color: accent.withValues(alpha: 0.08),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.psychology_alt_rounded,
                color: accent,
                size: layout.scale(22),
              ),
              SizedBox(width: layout.scale(10)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "المرشد الذكي",
                      style: TextStyle(
                        color: accent,
                        fontSize: layout.scale(13),
                        fontWeight: FontWeight.bold,
                        fontFamily: "Cairo",
                      ),
                    ),
                    SizedBox(height: layout.scale(6)),
                    Text(
                      _aiInsightText,
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha: 0.90),
                        fontSize: layout.scale(12),
                        fontFamily: "Cairo",
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: layout.scale(14)),
          if (_aiEnabled) ...[
            _miniAiRow(
              layout,
              icon: Icons.schedule_rounded,
              label: "أفضل وقت لك",
              value: _aiBestTime,
              accent: accent,
            ),
            _miniAiRow(
              layout,
              icon: Icons.flag_rounded,
              label: "هدفك اليوم",
              value: "$_aiGoal ذكر",
              accent: accent,
            ),
            _miniAiRow(
              layout,
              icon: Icons.route_rounded,
              label: "خطة اليوم",
              value: _aiPlan,
              accent: accent,
            ),
          ],
          if (_aiHasDecline) ...[
            SizedBox(height: layout.scale(10)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(layout.scale(10)),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(layout.scale(14)),
                color: Colors.orange.withValues(alpha: 0.08),
                border: Border.all(
                  color: Colors.orange.withValues(alpha: 0.22),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.trending_down_rounded,
                    color: Colors.orangeAccent,
                    size: layout.scale(18),
                  ),
                  SizedBox(width: layout.scale(8)),
                  Expanded(
                    child: Text(
                      _aiDeclineNote,
                      style: TextStyle(
                        color: AppColors.white.withValues(alpha: 0.82),
                        fontSize: layout.scale(11),
                        fontFamily: "Cairo",
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _miniAiRow(
      AppLayout layout, {
        required IconData icon,
        required String label,
        required String value,
        required Color accent,
      }) {
    return Container(
      margin: EdgeInsets.only(bottom: layout.scale(8)),
      padding: EdgeInsets.symmetric(
        horizontal: layout.scale(10),
        vertical: layout.scale(10),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(layout.scale(14)),
        color: AppColors.white.withValues(alpha: 0.03),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: accent, size: layout.scale(16)),
          SizedBox(width: layout.scale(8)),
          Text(
            "$label: ",
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.55),
              fontSize: layout.scale(11),
              fontFamily: "Cairo",
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.white,
                fontSize: layout.scale(11),
                fontWeight: FontWeight.bold,
                fontFamily: "Cairo",
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(AppLayout layout, Color accent) {
    return Positioned(
      bottom: layout.bottomSafe(14),
      left: layout.scale(20),
      right: layout.scale(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _circleBtn(layout, Icons.share_rounded, _handleShare, accent),
          _circleBtn(
            layout,
            Icons.workspace_premium_rounded,
                () => setState(() => _showStats = !_showStats),
            accent,
          ),
          _circleBtn(
            layout,
            Icons.arrow_back_ios_new_rounded,
                () => Navigator.pop(context),
            accent,
          ),
        ],
      ),
    );
  }

  Widget _circleBtn(
      AppLayout layout,
      IconData icon,
      VoidCallback onTap,
      Color accent,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(layout.scale(15)),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.black.withValues(alpha: 0.5),
          border: Border.all(color: accent.withValues(alpha: 0.48)),
        ),
        child: Icon(icon, color: accent, size: layout.scale(24)),
      ),
    );
  }

  void _handleShare() async {
    HapticFeedback.mediumImpact();

    setState(() => _isCapturing = true);
    await Future.delayed(const Duration(milliseconds: 300));
    final image = await screenshotController.capture();
    setState(() => _isCapturing = false);

    if (image != null) {
      final username = UserService.userName.trim();
      final shareText = _showNameOnShare && username.isNotEmpty
          ? "رحلتي في الذكر داخل تطبيق ذكرني ✨\nالذاكر: $username"
          : "رحلتي في الذكر داخل تطبيق ذكرني ✨";

      await Share.shareXFiles(
        [
          XFile.fromData(
            image,
            mimeType: "image/png",
            name: "constellation.png",
          ),
        ],
        text: shareText,
      );
    }
  }
}

class OrbitPainter extends CustomPainter {
  final double rotation;
  final Color accent;

  OrbitPainter({
    required this.rotation,
    required this.accent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final orbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = accent.withValues(alpha: 0.18);

    final radii = [size.width * 0.20, size.width * 0.30, size.width * 0.40];
    for (final r in radii) {
      canvas.drawCircle(center, r, orbitPaint);
    }
  }

  @override
  bool shouldRepaint(covariant OrbitPainter oldDelegate) =>
      oldDelegate.rotation != rotation || oldDelegate.accent != accent;
}

class StarFieldPainter extends CustomPainter {
  final double shimmer;
  final Color accent;
  final double densityFactor;

  StarFieldPainter({
    required this.shimmer,
    required this.accent,
    this.densityFactor = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(77);
    final count = max(24, (70 * densityFactor).round());

    for (int i = 0; i < count; i++) {
      final offset = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      );

      final paint = Paint()
        ..color = (i % 9 == 0 ? accent : AppColors.white).withValues(
          alpha: (0.18 + (random.nextDouble() * 0.45)) *
              (0.75 + shimmer * 0.25),
        );

      canvas.drawCircle(offset, 0.8 + random.nextDouble() * 1.8, paint);
    }
  }

  @override
  bool shouldRepaint(covariant StarFieldPainter oldDelegate) => true;
}