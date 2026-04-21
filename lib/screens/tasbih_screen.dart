import 'dart:ui';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/zikr_controller.dart';
import '../core/ui/app_layout.dart';
import '../constants/app_colors.dart';
import '../services/theme_service.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen>
    with TickerProviderStateMixin {
  int index = 0;
  List<int> targets = [33, 100, 1000];
  int targetIndex = 0;
  bool isFocusMode = false;

  int dailyGoal = 500;
  int currentStreak = 7;

  final List<String> azkar = [
    "سُبْحَانَ اللَّهِ",
    "الْحَمْدُ لِلَّهِ",
    "اللَّهُ أَكْبَرُ",
    "لَا إِلَهَ إِلَّا اللَّهُ",
    "أَسْتَغْفِرُ اللَّهَ"
  ];

  Map<int, int> counters = {};
  int sessionCount = 0;
  int sessionMilestones = 0;

  late AnimationController scaleController;
  late AnimationController starsController;
  late AnimationController glowController;

  List<Star> stars = [];

  @override
  void initState() {
    super.initState();
    loadData();

    final random = Random();
    stars = List.generate(
      60,
          (index) => Star(
        random.nextDouble(),
        random.nextDouble(),
        random.nextDouble() * 2 + 0.5,
        random.nextDouble() * 0.4 + 0.1,
        random.nextDouble() * 0.7 + 0.2,
      ),
    );

    scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.90,
      upperBound: 1.0,
    )..value = 1;

    starsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  int get target => targets[targetIndex];
  int get counter => counters[index] ?? 0;
  int get completedCycles => counter ~/ target;
  int get remainingToTarget => target - (counter % target == 0 ? target : counter % target);

  String get currentZikr => azkar[index];

  Map<String, int> _calculateRealStats() {
    final controller = ZikrController.instance;
    Map<String, int> stats = {};
    for (var zikr in controller.leafTexts) {
      stats[zikr] = (stats[zikr] ?? 0) + 1;
    }
    return stats;
  }

  String _getBestRealTime() {
    int hour = DateTime.now().hour;
    if (hour >= 3 && hour <= 6) return "الفجر والضحى";
    if (hour > 6 && hour <= 12) return "الصباح الباكر";
    if (hour > 12 && hour <= 16) return "الظهر والعصر";
    if (hour > 16 && hour <= 20) return "المساء والغروب";
    return "جوف الليل";
  }

  String _smartHint() {
    if (counter == 0) return "ابدأ الآن بنية صادقة ✨";
    if (counter % target == 0) return "أكملت دورة كاملة.. نور على نور 🌟";
    if (remainingToTarget <= 5) return "باقي $remainingToTarget وتكمل الدورة 🎯";
    if (counter >= 1000) return "مقام عالٍ من الثبات، استمر 🌌";
    if (completedCycles >= 1) return "أنت في تدفق جميل.. واصل 🤍";
    return "ذكرٌ قليل دائم خير من كثير منقطع";
  }

  String _sessionMood() {
    if (sessionCount == 0) return "بداية هادئة";
    if (sessionCount < 33) return "تدفّق لطيف";
    if (sessionCount < 100) return "حضور جميل";
    return "توهج روحاني";
  }

  void _showStatistics() {
    final realStats = _calculateRealStats();
    final bestTime = _getBestRealTime();
    final totalZikr = ZikrController.instance.total;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.78,
          decoration: BoxDecoration(
            color: AppColors.black.withValues(alpha: 0.86),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
            border: Border.all(
              color: AppColors.gold.withValues(alpha: 0.3),
            ),
          ),
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "تقريرك الإيماني التفصيلي",
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Cairo",
                ),
              ),
              const SizedBox(height: 25),
              _buildRankingCard(totalZikr),
              const SizedBox(height: 20),
              _buildSessionSummaryCard(),
              const SizedBox(height: 25),
              const Text(
                "توزيع أذكارك الحقيقي:",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontFamily: "Cairo",
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: ListView(
                  children: [
                    if (realStats.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            "ابدأ بالذكر لتظهر بياناتك هنا 🌱",
                            style: TextStyle(
                              color: Colors.white24,
                              fontFamily: "Cairo",
                            ),
                          ),
                        ),
                      )
                    else
                      ...realStats.entries.map(
                            (entry) => _buildDetailStatTile(
                          entry.key,
                          entry.value,
                          totalZikr,
                        ),
                      ),
                    const Divider(color: Colors.white10, height: 40),
                    _buildStatTile(
                      "أكثر وقت تذكر فيه الله",
                      bestTime,
                      Icons.access_time_filled_rounded,
                    ),
                    _buildStatTile(
                      "سلسلة الاستمرار",
                      "$currentStreak أيام متتالية",
                      Icons.local_fire_department_rounded,
                    ),
                    _buildStatTile(
                      "الذكر الحالي",
                      currentZikr,
                      Icons.auto_awesome_rounded,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _miniMetric("جلسة اليوم", "$sessionCount", Icons.bubble_chart_rounded),
          ),
          Expanded(
            child: _miniMetric("دورات مكتملة", "$sessionMilestones", Icons.emoji_events_rounded),
          ),
          Expanded(
            child: _miniMetric("الذكر الحالي", "$counter", Icons.repeat_rounded),
          ),
        ],
      ),
    );
  }

  Widget _miniMetric(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.gold, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            fontFamily: "Cairo",
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 10,
            fontFamily: "Cairo",
          ),
        ),
      ],
    );
  }

  Widget _buildRankingCard(int total) {
    String rank = "ذاكر مبتدئ";
    double percent = 12.5;
    if (total > 100) {
      rank = "مسبّح مخلص";
      percent = 68.2;
    }
    if (total > 500) {
      rank = "قانت نوراني";
      percent = 89.7;
    }
    if (total > 2000) {
      rank = "سلطان الذاكرين";
      percent = 99.4;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.gold.withValues(alpha: 0.15),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "ترتيبك العالمي الحالي",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontFamily: "Cairo",
                ),
              ),
              Text(
                rank,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Cairo",
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "أفضل من $percent%",
                style: const TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Text(
                "من مجتمع ذكّرني",
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontFamily: "Cairo",
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDetailStatTile(String name, int count, int total) {
    double barWidth = total > 0 ? (count / total).clamp(0.0, 1.0) : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 15,
                  fontFamily: "Cairo",
                ),
              ),
              Text(
                "$count مرة",
                style: const TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: barWidth,
              backgroundColor: AppColors.white.withValues(alpha: 0.05),
              color: AppColors.gold.withValues(alpha: 0.6),
              minHeight: 7,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatTile(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.gold.withValues(alpha: 0.6),
            size: 28,
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  fontFamily: "Cairo",
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Cairo",
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void increment() {
    final current = counter;

    if ((current + 1) % target == 0) {
      HapticFeedback.vibrate();
      _showMilestoneEffect();
      sessionMilestones++;
    } else {
      HapticFeedback.lightImpact();
    }

    scaleController.forward().then((_) => scaleController.reverse());

    setState(() {
      counters[index] = current + 1;
      sessionCount++;
      ZikrController.instance.add(azkar[index]);
    });

    saveData();
  }

  void _showMilestoneEffect() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: AppColors.black.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppColors.gold,
              width: 1.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  color: AppColors.gold,
                  size: 60,
                ),
                const SizedBox(height: 15),
                const Text(
                  "إنجاز نوراني!",
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Cairo",
                  ),
                ),
                Text(
                  "لقد أتممت $target تسبيحة بنجاح",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontFamily: "Cairo",
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "استمر",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void resetCurrentZikr() {
    HapticFeedback.mediumImpact();
    setState(() {
      counters[index] = 0;
    });
    saveData();
  }

  void nextZikr() {
    HapticFeedback.selectionClick();
    setState(() {
      index = (index + 1) % azkar.length;
    });
    saveData();
  }

  void previousZikr() {
    HapticFeedback.selectionClick();
    setState(() {
      index = (index - 1 + azkar.length) % azkar.length;
    });
    saveData();
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();

    final countersJson = jsonEncode(
      counters.map((key, value) => MapEntry(key.toString(), value)),
    );

    await prefs.setString("tasbih_counters_map", countersJson);
    await prefs.setInt("tasbih_index", index);
    await prefs.setInt("tasbih_target_index", targetIndex);
    await prefs.setInt("tasbih_session_count", sessionCount);
    await prefs.setInt("tasbih_session_milestones", sessionMilestones);
    await prefs.setBool("tasbih_focus_mode", isFocusMode);
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString("tasbih_counters_map");
    Map<int, int> loaded = {};

    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      loaded = decoded.map((key, value) => MapEntry(
        int.tryParse(key) ?? 0,
        (value as num).toInt(),
      ));
    }

    if (!mounted) return;

    setState(() {
      counters = loaded;
      index = prefs.getInt("tasbih_index") ?? 0;
      targetIndex = prefs.getInt("tasbih_target_index") ?? 0;
      sessionCount = prefs.getInt("tasbih_session_count") ?? 0;
      sessionMilestones = prefs.getInt("tasbih_session_milestones") ?? 0;
      isFocusMode = prefs.getBool("tasbih_focus_mode") ?? false;
    });
  }

  @override
  void dispose() {
    scaleController.dispose();
    starsController.dispose();
    glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final layout = AppLayout(context);
    final progress = (counter % target) / target;
    final dailyProgress =
    (ZikrController.instance.total / dailyGoal).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(seconds: 1),
              color: isFocusMode ? AppColors.black : Colors.transparent,
              child: isFocusMode
                  ? null
                  : Image.asset(
                ThemeService.instance.backgroundImage,
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (!isFocusMode)
            AnimatedBuilder(
              animation: starsController,
              builder: (_, __) => CustomPaint(
                painter: StarsPainter(starsController.value, stars),
                child: Container(),
              ),
            ),
          Positioned.fill(
            child: Container(
              color: AppColors.black.withValues(alpha: isFocusMode ? 0.8 : 0.4),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: layout.bottomSafe(20)),
                        child: Column(
                          children: [
                            if (!isFocusMode) _buildTopStatus(layout, dailyProgress),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: layout.scale(20),
                                vertical: layout.scale(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _topBtn(
                                    layout,
                                    isFocusMode ? Icons.visibility_off : Icons.visibility,
                                        () {
                                      setState(() => isFocusMode = !isFocusMode);
                                      saveData();
                                    },
                                  ),
                                  if (!isFocusMode)
                                    _topBtn(
                                      layout,
                                      Icons.close,
                                          () => Navigator.pop(context),
                                    ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            
                            /// 🪟 الذكر (يمكن للمستخدم الضغط عليه لتغيير الذكر)
                            _buildGlassWindow(
                              layout: layout,
                              child: InkWell( 
                                onTap: nextZikr,
                                borderRadius: BorderRadius.circular(layout.scale(15)),
                                child: Padding(
                                  padding: EdgeInsets.all(layout.scale(10)),
                                  child: Text(
                                    currentZikr,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.gold,
                                      fontSize: layout.scale(34),
                                      fontFamily: "Amiri",
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: layout.scale(15)),

                            /// ✨ كارد الحالة المضاف
                            if (!isFocusMode)
                              _buildGlassWindow(
                                layout: layout,
                                padding: EdgeInsets.symmetric(
                                  horizontal: layout.scale(18),
                                  vertical: layout.scale(14),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _smallInfoTile(
                                        layout,
                                        "الحالة",
                                        _sessionMood(),
                                        Icons.auto_graph_rounded,
                                      ),
                                    ),
                                    SizedBox(width: layout.scale(10)),
                                    Expanded(
                                      child: _smallInfoTile(
                                        layout,
                                        "باقي للدورة",
                                        "${remainingToTarget == target ? 0 : remainingToTarget}",
                                        Icons.flag_rounded,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            SizedBox(height: layout.scale(15)),

                            /// 🔵 المسبحة الدائرية (التفاعل الرئيسي)
                            Center(
                              child: GestureDetector(
                                onTap: increment,
                                onLongPress: resetCurrentZikr,
                                child: Container(
                                  width: layout.scale(220),
                                  height: layout.scale(220),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.white.withValues(alpha: 0.05),
                                    border: Border.all(
                                      color: AppColors.gold.withValues(alpha: 0.2),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.gold.withValues(alpha: 0.1),
                                        blurRadius: 30,
                                        spreadRadius: 5,
                                      )
                                    ],
                                  ),
                                  child: ScaleTransition(
                                    scale: scaleController,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        CustomPaint(
                                          size: Size(layout.scale(200), layout.scale(200)),
                                          painter: ElegantCirclePainter(
                                            progress: progress,
                                            isFocus: isFocusMode,
                                          ),
                                        ),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "$counter",
                                              style: TextStyle(
                                                fontSize: layout.scale(60),
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: "Cairo",
                                              ),
                                            ),
                                            if (!isFocusMode)
                                              Text(
                                                "تَسْبِيحَة",
                                                style: TextStyle(
                                                  color: AppColors.white.withValues(alpha: 0.4),
                                                  fontSize: layout.scale(12),
                                                  fontFamily: "Cairo",
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: layout.scale(15)),

                            /// 💡 التلميح
                            _buildGlassWindow(
                              layout: layout,
                              child: Text(
                                _smartHint(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: layout.scale(12),
                                  fontFamily: "Cairo",
                                ),
                              ),
                            ),

                            const Spacer(),

                            if (!isFocusMode)
                              Padding(
                                padding: EdgeInsets.only(bottom: layout.scale(10)),
                                child: Text(
                                  "🌍",
                                  style: TextStyle(
                                    color: AppColors.white.withValues(alpha: 0.3),
                                    fontSize: layout.scale(10),
                                    fontFamily: "Cairo",
                                  ),
                                ),
                              ),

                            if (!isFocusMode)
                              _buildGlassWindow(
                                layout: layout,
                                padding: EdgeInsets.symmetric(vertical: layout.scale(15)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _actionBtn(layout, Icons.refresh, "إعادة", resetCurrentZikr),
                                    _actionBtn(layout, Icons.track_changes, "الهدف", () {
                                      setState(() {
                                        targetIndex = (targetIndex + 1) % targets.length;
                                      });
                                      saveData();
                                    }),
                                    _actionBtn(layout, Icons.bar_chart, "إحصائيات", _showStatistics),
                                  ],
                                ),
                              ),
                            SizedBox(height: layout.scale(20)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopStatus(AppLayout layout, double dailyProgress) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 3,
          margin: EdgeInsets.symmetric(
            horizontal: layout.scale(50),
            vertical: layout.scale(10),
          ),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerRight,
            widthFactor: dailyProgress,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.2),
                    blurRadius: 5,
                  )
                ],
              ),
            ),
          ),
        ),
        Text(
          "الورد اليومي: ${(dailyProgress * 100).toInt()}%",
          style: TextStyle(
            color: AppColors.white.withValues(alpha: 0.24),
            fontSize: layout.scale(9),
            fontFamily: "Cairo",
          ),
        ),
      ],
    );
  }

  Widget _smallInfoTile(
      AppLayout layout,
      String title,
      String value,
      IconData icon,
      ) {
    return Container(
      padding: EdgeInsets.all(layout.scale(12)),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(layout.scale(18)),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.gold.withValues(alpha: 0.85),
            size: layout.scale(20),
          ),
          SizedBox(height: layout.scale(6)),
          Text(
            title,
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.38),
              fontSize: layout.scale(10),
              fontFamily: "Cairo",
            ),
          ),
          SizedBox(height: layout.scale(4)),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.white,
              fontSize: layout.scale(12),
              fontWeight: FontWeight.bold,
              fontFamily: "Cairo",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassWindow({
    required AppLayout layout,
    required Widget child,
    bool isMain = false,
    EdgeInsets? padding,
    double opacity = 0.05,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      margin: EdgeInsets.symmetric(horizontal: layout.scale(25)),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(
          isMain ? layout.scale(40) : layout.scale(25),
        ),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: opacity == 0 ? 0 : 0.15),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          isMain ? layout.scale(40) : layout.scale(25),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: opacity == 0 ? 0 : 15,
            sigmaY: opacity == 0 ? 0 : 15,
          ),
          child: Padding(
            padding: padding ?? EdgeInsets.all(layout.scale(20)),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _topBtn(AppLayout layout, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(layout.scale(10)),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.05),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.white.withValues(alpha: 0.12)),
        ),
        child: Icon(
          icon,
          color: Colors.white70,
          size: layout.scale(20),
        ),
      ),
    );
  }

  Widget _actionBtn(
      AppLayout layout,
      IconData icon,
      String label,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.gold.withValues(alpha: 0.8),
            size: layout.scale(24),
          ),
          SizedBox(height: layout.scale(5)),
          Text(
            label,
            style: TextStyle(
              color: Colors.white38,
              fontSize: layout.scale(10),
              fontFamily: "Cairo",
            ),
          ),
        ],
      ),
    );
  }
}

class ElegantCirclePainter extends CustomPainter {
  final double progress;
  final bool isFocus;

  ElegantCirclePainter({
    required this.progress,
    required this.isFocus,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = isFocus
          ? AppColors.white.withValues(alpha: 0.02)
          : AppColors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isFocus ? 2 : 4;

    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.gold,
          AppColors.gold.withValues(alpha: 0.3),
        ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isFocus ? 4 : 8
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi * (progress <= 0 ? 0.001 : progress),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Star {
  final double x, y, size, speed, opacity;
  Star(this.x, this.y, this.size, this.speed, this.opacity);
}

class StarsPainter extends CustomPainter {
  final double animationValue;
  final List<Star> stars;

  StarsPainter(this.animationValue, this.stars);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (var star in stars) {
      final offset = Offset(
        star.x * size.width,
        (star.y * size.height + animationValue * star.speed * 100) %
            size.height,
      );
      paint.color = AppColors.white.withValues(alpha: star.opacity);
      canvas.drawCircle(offset, star.size, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
