import 'package:flutter/material.dart';

import '../controllers/home_controller.dart';
import '../core/ui/app_layout.dart';
import '../services/theme_service.dart';
import '../constants/app_colors.dart';

import 'widgets/home_dynamic_background.dart';
import 'widgets/home_header.dart';
import 'widgets/hijri_hero_card.dart';
import 'widgets/prayer_hero_card.dart';
import 'widgets/quick_actions_grid.dart';
import 'widgets/smart_insights_carousel.dart';
import 'widgets/quran_orb_button.dart';
import 'widgets/home_bottom_dock.dart';
import 'widgets/home_drawer.dart';
import 'widgets/now_session_card.dart';
import 'widgets/daily_name_card.dart';
import 'widgets/customize_ui_sheet.dart';
import 'widgets/drawer_action_helpers.dart';

import 'rotating_icons_3d.dart';
import 'about_app_screen.dart';
import 'developer_screen.dart';
import 'contact_us_screen.dart';
import 'share_app_screen.dart';
import 'qibla_screen.dart';
import 'prayer_times_screen.dart';
import 'names_of_allah_screen.dart';
import 'surah_index_screen.dart';
import 'sunnah_tracker_screen.dart';
import 'spiritual_id_screen.dart';
import 'achievements_screen.dart';
import 'admin_dashboard_screen.dart';
import 'profile_customization_screen.dart';
import 'app_preferences_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';
import 'report_problem_screen.dart';
import 'notifications_screen.dart';

// تم تغييرها إلى StatelessWidget لتصحيح الخطأ
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HomeScreenContent();
  }
}

class _HomeScreenContent extends StatefulWidget {
  const _HomeScreenContent();

  @override
  State<_HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<_HomeScreenContent> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final HomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HomeController()..initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navTo(Widget screen, {bool closeDrawer = false}) {
    if (closeDrawer && Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    ).then((_) => _controller.refreshAll());
  }

  @override
  Widget build(BuildContext context) {
    final layout = AppLayout(context);
    final theme = ThemeService.instance;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          key: _scaffoldKey,
          endDrawer: HomeDrawer(
            userName: _controller.userName,
            userId: _controller.userId,
            userLevel: _controller.userLevel,
            hijriText: _controller.hijriText,
            progress: _controller.todayProgress,
            visualState: _controller.visualState,
            drawerMessage: _controller.drawerMessage,
            selectedProfileSymbol: _controller.selectedProfileSymbol,
            isAdmin: _controller.isAdmin,
            onAdminTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
              );
            },
            onEditProfile: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileCustomizationScreen(
                    currentName: _controller.userName,
                    currentSymbolKey: _controller.selectedProfileSymbolKey,
                    onSave: (name, symbol) async {
                      await _controller.saveProfileData(
                        name: name,
                        symbolKey: symbol,
                      );
                    },
                  ),
                ),
              );
            },
            onSettings: () {
              _navTo(AppPreferencesScreen(controller: _controller), closeDrawer: true);
            },
            onCustomizeUi: () async {
              Navigator.pop(context);
              await showCustomizeUiSheet(context, _controller);
            },
            onNotifications: () => _navTo(NotificationsScreen(controller: _controller), closeDrawer: true),
            onPrivacy: () => _navTo(const PrivacyPolicyScreen(), closeDrawer: true),
            onBackup: () async {
              Navigator.pop(context);
              await _controller.setBackup(!_controller.backupEnabled);
              if (!mounted) return;
              await showInfoDialog(
                context: context,
                title: "النسخ الاحتياطي",
                message: _controller.backupEnabled
                    ? "تم تفعيل النسخ الاحتياطي المحلي للتفضيلات."
                    : "تم إيقاف النسخ الاحتياطي المحلي.",
              );
            },
            onShare: () => _navTo(const ShareAppScreen(), closeDrawer: true),
            onRate: () async {
              Navigator.pop(context);
              await requestInAppReviewOrStore();
            },
            onBugReport: () => _navTo(const ReportProblemScreen(), closeDrawer: true),
            onContact: () => _navTo(const ContactUsScreen(), closeDrawer: true),
            onAppVision: () => _navTo(const AboutAppScreen(), closeDrawer: true),
            onDeveloper: () => _navTo(const DeveloperScreen(), closeDrawer: true),
            onPrivacyPolicy: () => _navTo(const PrivacyPolicyScreen(), closeDrawer: true),
            onTerms: () => _navTo(const TermsOfServiceScreen(), closeDrawer: true),
          ),
          body: Stack(
            children: [
              HomeDynamicBackground(
                backgroundImage: theme.backgroundImage,
                themeMode: _controller.visualState,
                zikrEnergy: _controller.todayProgress,
                qiblaAngle: _controller.qiblaAngle,
              ),
              SafeArea(
                child: RefreshIndicator(
                  onRefresh: _controller.refreshAll,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              HomeHeader(
                                userName: _controller.userName,
                                aiMessage: _controller.currentInsight,
                                progress: _controller.todayProgress,
                                level: _controller.userLevel,
                                onMenuTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                              ),
                              const SizedBox(height: 14),
                              HijriHeroCard(
                                hijriDay: _controller.hijriDay,
                                hijriMonth: _controller.hijriMonth,
                                gregorianText: _controller.gregorianText,
                                milestoneText: _controller.hijriMilestone,
                              ),
                              const SizedBox(height: 14),
                              PrayerHeroCard(
                                nextPrayerName: _controller.nextPrayerName,
                                nextPrayerCountdown: _controller.nextPrayerCountdown,
                                progress: _controller.prayerProgress,
                                sacredTimeline: _controller.sacredTimeline,
                                onOpenPrayerTimes: () => _navTo(const PrayerTimesScreen()),
                                onOpenQibla: () => _navTo(const QiblaScreen()),
                              ),
                              const SizedBox(height: 14),
                              QuickActionsGrid(
                                onQuran: () => _navTo(const SurahIndexScreen()),
                                onQibla: () => _navTo(const QiblaScreen()),
                                onPrayer: () => _navTo(const PrayerTimesScreen()),
                                onSunnah: () => _navTo(const SunnahTrackerScreen()),
                                onNames: () => _navTo(const NamesOfAllahScreen()),
                                onAchievements: () => _navTo(const AchievementsScreen()),
                              ),
                              const SizedBox(height: 14),
                              NowSessionCard(
                                title: _controller.sessionTitle,
                                subtitle: _controller.sessionSubtitle,
                                icon: _controller.sessionIcon,
                              ),
                              const SizedBox(height: 14),
                              DailyNameCard(
                                title: _controller.dailyNameTitle,
                                meaning: _controller.dailyNameMeaning,
                                action: _controller.dailyNameAction,
                              ),
                              const SizedBox(height: 18),
                              
                              SizedBox(
                                height: 400,
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final orbitWidth = (constraints.maxWidth - 8).clamp(300.0, 360.0);

                                    return Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Transform.translate(
                                          offset: const Offset(0, 8),
                                          child: RotatingIcons3D(
                                            orbitWidth: orbitWidth,
                                            orbitHeight: 250,
                                            iconSize: 72,
                                            animateEntrance: true,
                                          ),
                                        ),
                                        Hero(
                                          tag: 'quran_orb',
                                          child: QuranOrbButton(
                                            title: "القرآن الكريم",
                                            subtitle: "المصحف",
                                            progressGlow: _controller.todayProgress,
                                            onTap: () => _navTo(const SurahIndexScreen()),
                                            size: 102,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(height: 14),
                              SmartInsightsCarousel(
                                items: _controller.insights,
                                weeklyHeatmap: _controller.weeklyHeatmap,
                              ),
                              const SizedBox(height: 150),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: layout.bottomSafe(16),
                left: 16,
                right: 16,
                child: HomeBottomDock(
                  todayCount: _controller.todayZikrCount,
                  streakCount: _controller.streakCount,
                  prayerText: _controller.nextPrayerCountdown,
                  onHomeTap: () {},
                  onQuranTap: () => _navTo(const SurahIndexScreen()),
                  onTasbihTap: () {},
                  onQiblaTap: () => _navTo(const QiblaScreen()),
                  onProfileTap: () => _navTo(const SpiritualIdScreen()),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
