import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/zikr_controller.dart';
import '../services/theme_service.dart';
import '../services/auth_service.dart';
import '../constants/app_colors.dart';

import 'achievements_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';
import 'login_or_guest_screen.dart';
import 'widgets/premium_page_shell.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool _smartMode = true;
  bool _aiAssistantEnabled = true;
  bool _focusMode = true;
  bool _compactMode = false;
  bool _showNameOnShare = true;
  String _visualMode = "balanced";

  bool _isResetting = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _loadSettings();
    ThemeService.instance.addListener(_themeListener);
  }

  @override
  void dispose() {
    ThemeService.instance.removeListener(_themeListener);
    _controller.dispose();
    super.dispose();
  }

  void _themeListener() {
    if (mounted) setState(() {});
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _smartMode = prefs.getBool("smart_mode") ?? true;
    _aiAssistantEnabled = prefs.getBool("ai_assistant_enabled") ?? true;
    _focusMode = prefs.getBool("focus_mode") ?? true;
    _compactMode = prefs.getBool("compact_mode") ?? false;
    _showNameOnShare = prefs.getBool("show_name_on_share") ?? true;
    _visualMode = prefs.getString("visual_mode") ?? "balanced";

    await _applyFocusMode(_focusMode, save: false);

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<void> _applyFocusMode(bool enabled, {bool save = true}) async {
    if (save) {
      await _saveBool("focus_mode", enabled);
    }

    if (enabled) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ));
    }
  }

  Future<void> _updateCompactMode(bool value) async {
    await _saveBool("compact_mode", value);
    if (!mounted) return;
    setState(() => _compactMode = value);
    _showSnackBar(value ? "تم تفعيل الوضع المضغوط" : "تم إيقاف الوضع المضغوط");
  }

  Future<void> _updateSmartMode(bool value) async {
    await _saveBool("smart_mode", value);
    if (!mounted) return;
    setState(() => _smartMode = value);
    _showSnackBar(value ? "تم تفعيل النمط الذكي" : "تم إيقاف النمط الذكي");
  }

  Future<void> _updateAiAssistant(bool value) async {
    await _saveBool("ai_assistant_enabled", value);
    if (!mounted) return;
    setState(() => _aiAssistantEnabled = value);
    _showSnackBar(value ? "تم تفعيل المرشد الذكي" : "تم إيقاف المرشد الذكي");
  }

  Future<void> _updateShowNameOnShare(bool value) async {
    await _saveBool("show_name_on_share", value);
    if (!mounted) return;
    setState(() => _showNameOnShare = value);
    _showSnackBar(value ? "سيظهر الاسم في المشاركة" : "تم إخفاء الاسم في المشاركة");
  }

  Future<void> _updateFocusMode(bool value) async {
    await _applyFocusMode(value);
    if (!mounted) return;
    setState(() => _focusMode = value);
    _showSnackBar(value ? "تم تفعيل وضع التركيز" : "تم إيقاف وضع التركيز");
  }

  Future<void> _updateDarkMode(bool value) async {
    await ThemeService.instance.setDarkMode(value);
    if (!mounted) return;
    setState(() {});
    _showSnackBar(value ? "تم تفعيل الوضع الداكن" : "تم تفعيل الوضع النهاري");
  }

  Future<void> _updateFont(String fontKey) async {
    await ThemeService.instance.setFont(fontKey);
    if (!mounted) return;
    Navigator.pop(context);
    setState(() {});
    _showSnackBar("تم تغيير الخط بنجاح");
  }

  Future<void> _updateLocale(String locale) async {
    await ThemeService.instance.setLocale(locale);
    if (!mounted) return;
    Navigator.pop(context);
    setState(() {});
    _showSnackBar("تم تغيير لغة التطبيق");
  }

  Future<void> _updateVisualMode(String value) async {
    await _saveString("visual_mode", value);
    await ThemeService.instance.setVisualMode(value);
    if (!mounted) return;
    setState(() => _visualMode = value);
    Navigator.pop(context);
    _showSnackBar("تم تغيير النمط البصري");
  }

  Future<void> _resetAppData() async {
    if (_isResetting) return;
    setState(() => _isResetting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      ZikrController.instance.reset();
      await ThemeService.instance.init();
      await _loadSettings();

      if (!mounted) return;
      HapticFeedback.heavyImpact();
      _showSnackBar("تم تصفير التطبيق بنجاح");
    } catch (_) {
      if (!mounted) return;
      _showSnackBar("تعذر تصفير التطبيق");
    } finally {
      if (mounted) setState(() => _isResetting = false);
    }
  }

  Future<void> _handleDeleteAccount() async {
    if (_isDeleting) return;
    setState(() => _isDeleting = true);

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
      );

      await AuthService.deleteAccount();

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginOrGuestScreen()),
            (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _showSnackBar("فشل حذف الحساب: $e");
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  double get _cardRadius => _compactMode ? 18 : 22;
  double get _cardPadding => _compactMode ? 14 : 18;
  double get _sectionSpacing => _compactMode ? 10 : 15;

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService.instance;
    final total = ZikrController.instance.total;

    return PremiumPageShell(
      title: "الإعدادات",
      topLabel: "SETTINGS HUB",
      goHomeOnBack: false,
      child: FadeTransition(
        opacity: _controller,
        child: RefreshIndicator(
          color: AppColors.gold,
          onRefresh: _loadSettings,
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              _compactMode ? 14 : 20,
              6,
              _compactMode ? 14 : 20,
              40,
            ),
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            children: [
              _buildHeroCard(total, themeService),
              SizedBox(height: _sectionSpacing + 6),

              _buildSectionTitle("التحكم الذكي"),
              _buildSettingCard(
                title: "النمط الذكي للذكر",
                subtitle: _smartMode
                    ? "التذكير يتماشى مع نشاطك وسلوكك"
                    : "نمط ثابت أبسط",
                icon: Icons.psychology_alt_rounded,
                trailing: _buildCustomSwitch(
                  _smartMode,
                      (val) async => _updateSmartMode(val),
                ),
              ),
              _buildSettingCard(
                title: "المرشد الذكي",
                subtitle: _aiAssistantEnabled
                    ? "الاقتراحات والتحليل اليومي مفعّلان"
                    : "متوقف حاليًا",
                icon: Icons.auto_awesome_rounded,
                trailing: _buildCustomSwitch(
                  _aiAssistantEnabled,
                      (val) async => _updateAiAssistant(val),
                ),
              ),
              _buildSettingCard(
                title: "وضع التركيز",
                subtitle: _focusMode
                    ? "ملء الشاشة لتجربة أكثر هدوءًا"
                    : "شريط النظام ظاهر",
                icon: Icons.fullscreen_rounded,
                trailing: _buildCustomSwitch(
                  _focusMode,
                      (val) async => _updateFocusMode(val),
                ),
              ),

              _buildSectionTitle("المظهر واللغة"),
              _buildSettingCard(
                title: "لغة التطبيق",
                subtitle:
                "اللغة الحالية: ${_getLanguageName(themeService.selectedLocale)}",
                icon: Icons.language_rounded,
                onTap: _showLanguagePicker,
              ),
              _buildSettingCard(
                title: "الوضع الداكن",
                subtitle: themeService.isDarkMode
                    ? "مفعّل لإضاءة هادئة"
                    : "الوضع النهاري المشرق",
                icon: themeService.isDarkMode
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                trailing: _buildCustomSwitch(
                  themeService.isDarkMode,
                      (val) async => _updateDarkMode(val),
                ),
              ),
              _buildSettingCard(
                title: "خط التطبيق",
                subtitle: "الخط الحالي: ${themeService.selectedFont}",
                icon: Icons.text_fields_rounded,
                onTap: () => _showFontPicker(themeService),
              ),
              _buildSettingCard(
                title: "النمط البصري",
                subtitle: _visualModeLabel(_visualMode),
                icon: Icons.blur_on_rounded,
                onTap: _showVisualModePicker,
              ),
              _buildSettingCard(
                title: "الوضع المضغوط",
                subtitle: _compactMode
                    ? "تباعد أقل وعرض أكثر كثافة"
                    : "وضع مريح ومتوازن",
                icon: Icons.view_compact_alt_rounded,
                trailing: _buildCustomSwitch(
                  _compactMode,
                      (val) async => _updateCompactMode(val),
                ),
              ),

              _buildSectionTitle("البيانات والتقدم"),
              _buildSettingCard(
                title: "مركز الإنجازات",
                subtitle: "اعرض رحلتك والأوسمة التي حققتها",
                icon: Icons.workspace_premium_rounded,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AchievementsScreen(),
                  ),
                ),
              ),
              _buildSettingCard(
                title: "إظهار الاسم في المشاركة",
                subtitle: _showNameOnShare
                    ? "مفعّل عند مشاركة الصور والمنشورات"
                    : "المشاركة بدون اسم",
                icon: Icons.badge_rounded,
                trailing: _buildCustomSwitch(
                  _showNameOnShare,
                      (val) async => _updateShowNameOnShare(val),
                ),
              ),

              _buildSectionTitle("الخصوصية والإدارة"),
              _buildSettingCard(
                title: "سياسة الخصوصية",
                subtitle: "كيف نحمي بياناتك ونحترم خصوصيتك",
                icon: Icons.privacy_tip_rounded,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PrivacyPolicyScreen(),
                  ),
                ),
              ),
              _buildSettingCard(
                title: "الشروط والأحكام",
                subtitle: "الضوابط العامة لاستخدام التطبيق",
                icon: Icons.article_outlined,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TermsOfServiceScreen(),
                  ),
                ),
              ),

              _buildSectionTitle("إجراءات متقدمة"),
              _buildSettingCard(
                title: "حذف الحساب نهائيًا",
                subtitle: _isDeleting
                    ? "جارٍ تنفيذ العملية..."
                    : "مسح بيانات الحساب من النظام بشكل دائم",
                icon: Icons.person_remove_rounded,
                isDanger: true,
                onTap: _confirmDeleteAccount,
              ),
              _buildSettingCard(
                title: "تصفير التطبيق",
                subtitle: _isResetting
                    ? "جارٍ تصفير البيانات..."
                    : "حذف الإعدادات والتقدم المحلي",
                icon: Icons.delete_forever_rounded,
                isDanger: true,
                onTap: _confirmReset,
              ),

              _buildSectionTitle("معلومات التطبيق"),
              _buildInfoCard(themeService),
            ],
          ),
        ),
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'ar':
        return 'العربية';
      case 'en':
        return 'English';
      case 'ur':
        return 'اردو';
      case 'id':
        return 'Bahasa Indonesia';
      case 'tr':
        return 'Türkçe';
      case 'fr':
        return 'Français';
      default:
        return 'العربية';
    }
  }

  Widget _buildHeroCard(int total, ThemeService themeService) {
    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 6),
      padding: EdgeInsets.all(_compactMode ? 16 : 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.gold.withOpacity(0.18),
            Colors.white.withOpacity(0.05),
            Colors.transparent,
          ],
        ),
        border: Border.all(color: AppColors.gold.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: _compactMode ? 56 : 64,
            height: _compactMode ? 56 : 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold.withOpacity(0.10),
              border: Border.all(color: AppColors.gold.withOpacity(0.35)),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: AppColors.gold,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "مركز التحكم",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Cairo",
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "إجمالي إنجازك: $total ذكر",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.68),
                    fontSize: 12,
                    fontFamily: "Cairo",
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "اللغة: ${_getLanguageName(themeService.selectedLocale)} • الخط: ${themeService.selectedFont}",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.48),
                    fontSize: 10.5,
                    fontFamily: "Cairo",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(ThemeService themeService) {
    return Container(
      margin: EdgeInsets.only(bottom: _compactMode ? 10 : 15),
      padding: EdgeInsets.all(_cardPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_cardRadius),
        color: Colors.white.withOpacity(0.04),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "حالة التخصيص الحالية",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              fontFamily: "Cairo",
            ),
          ),
          const SizedBox(height: 10),
          _infoLine("اللغة", _getLanguageName(themeService.selectedLocale)),
          _infoLine("الخط", themeService.selectedFont),
          _infoLine("النمط البصري", _visualModeLabel(_visualMode)),
          _infoLine("الوضع الداكن", themeService.isDarkMode ? "مفعّل" : "متوقف"),
          _infoLine("وضع التركيز", _focusMode ? "مفعّل" : "متوقف"),
        ],
      ),
    );
  }

  Widget _infoLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              color: AppColors.gold.withOpacity(0.9),
              fontFamily: "Cairo",
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white.withOpacity(0.72),
                fontFamily: "Cairo",
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: _sectionSpacing, horizontal: 5),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.gold.withOpacity(0.9),
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
          fontFamily: "Cairo",
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required IconData icon,
    Widget? trailing,
    bool isDanger = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: EdgeInsets.only(bottom: _compactMode ? 10 : 15),
        padding: EdgeInsets.all(_cardPadding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_cardRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isDanger
                  ? Colors.red.withOpacity(0.14)
                  : Colors.white.withOpacity(0.08),
              isDanger
                  ? Colors.red.withOpacity(0.05)
                  : Colors.white.withOpacity(0.02),
            ],
          ),
          border: Border.all(
            color: isDanger
                ? Colors.red.withOpacity(0.35)
                : Colors.white.withOpacity(0.10),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(_compactMode ? 8 : 10),
              decoration: BoxDecoration(
                color: isDanger
                    ? Colors.red.withOpacity(0.1)
                    : AppColors.gold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDanger ? Colors.redAccent : AppColors.gold,
                size: _compactMode ? 22 : 26,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: _compactMode ? 15 : 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Cairo",
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.55),
                      fontSize: _compactMode ? 11 : 12,
                      fontFamily: "Cairo",
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            trailing ??
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white24,
                  size: 14,
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomSwitch(bool value, Function(bool) onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 52,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: value ? AppColors.gold.withOpacity(0.5) : Colors.white12,
          border: Border.all(
            color: value ? AppColors.gold : Colors.white24,
            width: 1.5,
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value ? AppColors.gold : Colors.grey.shade400,
            ),
          ),
        ),
      ),
    );
  }

  void _showFontPicker(ThemeService themeService) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.96),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(color: AppColors.gold.withOpacity(0.30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            const Text(
              "اختر الخط العربي",
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 18,
                fontFamily: "Cairo",
              ),
            ),
            const Divider(color: Colors.white12),
            _fontOption(themeService, "الخط الكوفي الحديث", "ReemKufi"),
            _fontOption(themeService, "الخط الأميري الكلاسيكي", "Amiri"),
            _fontOption(themeService, "خط القاهرة الافتراضي", "Cairo"),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _fontOption(ThemeService themeService, String name, String fontKey) {
    return ListTile(
      title: Text(
        name,
        style: TextStyle(color: Colors.white, fontFamily: fontKey),
      ),
      trailing: themeService.selectedFont == fontKey
          ? const Icon(Icons.check_circle, color: AppColors.gold)
          : null,
      onTap: () async => _updateFont(fontKey),
    );
  }

  void _showLanguagePicker() {
    final theme = ThemeService.instance;

    _showChoiceSheet(
      title: "اختر لغة التطبيق",
      options: const [
        _SheetOption("ar", "العربية", "اللغة الأم للتطبيق"),
        _SheetOption("en", "English", "Universal language support"),
        _SheetOption("ur", "اردو", "اسلامی دنیا کی بڑی زبان"),
        _SheetOption("id", "Bahasa Indonesia", "Dukungan untuk muslim Indonesia"),
        _SheetOption("tr", "Türkçe", "Türk kardeşlerimiz için"),
        _SheetOption("fr", "Français", "Support pour les francophones"),
      ],
      currentValue: theme.selectedLocale,
      onSelected: _updateLocale,
    );
  }

  void _showVisualModePicker() {
    _showChoiceSheet(
      title: "اختر النمط البصري",
      options: const [
        _SheetOption("soft", "هادئ", "ضبابية أخف ومساحة أنظف"),
        _SheetOption("balanced", "متوازن", "الإعداد الافتراضي"),
        _SheetOption("cinematic", "سينمائي", "تأثيرات أعمق وأفخم"),
      ],
      currentValue: _visualMode,
      onSelected: _updateVisualMode,
    );
  }

  void _showChoiceSheet({
    required String title,
    required List<_SheetOption> options,
    required String currentValue,
    required Future<void> Function(String value) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.96),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(color: AppColors.gold.withOpacity(0.25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.gold,
                fontSize: 18,
                fontFamily: "Cairo",
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(color: Colors.white12),
            ...options.map(
                  (option) => ListTile(
                onTap: () => onSelected(option.value),
                leading: Icon(
                  currentValue == option.value
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: currentValue == option.value
                      ? AppColors.gold
                      : Colors.white30,
                ),
                title: Text(
                  option.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: "Cairo",
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  option.subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontFamily: "Cairo",
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _visualModeLabel(String value) {
    switch (value) {
      case "soft":
        return "هادئ • ضبابية أقل";
      case "cinematic":
        return "سينمائي • تأثيرات أعمق";
      default:
        return "متوازن • أفضل مزيج";
    }
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
          side: const BorderSide(color: Colors.red, width: 2),
        ),
        title: const Row(
          children: [
            Icon(Icons.person_remove_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text(
              "حذف الحساب نهائيًا",
              style: TextStyle(color: Colors.red, fontFamily: "Cairo"),
            ),
          ],
        ),
        content: const Text(
          "سيتم مسح كافة سجلاتك من خوادمنا. هل أنت متأكد؟",
          style: TextStyle(color: Colors.white70, fontFamily: "Cairo"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("تراجع", style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await _handleDeleteAccount();
            },
            child: const Text(
              "حذف حسابي الآن",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: "Cairo",
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
          side: const BorderSide(color: Colors.red, width: 2),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text(
              "إجراء خطير",
              style: TextStyle(color: Colors.red, fontFamily: "Cairo"),
            ),
          ],
        ),
        content: const Text(
          "سيتم مسح كافة الإعدادات والتقدم. هل أنت متأكد؟",
          style: TextStyle(color: Colors.white70, fontFamily: "Cairo"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("تراجع", style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await _resetAppData();
            },
            child: const Text(
              "نعم، تصفير الآن",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: "Cairo",
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text, style: const TextStyle(fontFamily: "Cairo")),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _SheetOption {
  final String value;
  final String title;
  final String subtitle;
  const _SheetOption(this.value, this.title, this.subtitle);
}