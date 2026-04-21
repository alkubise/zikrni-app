import 'dart:ui';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../controllers/home_controller.dart';

class HomeDrawer extends StatelessWidget {
  final String userName;
  final String userId;
  final String userLevel;
  final String hijriText;
  final double progress;
  final HomeVisualState visualState;
  final String drawerMessage;
  final IconData selectedProfileSymbol;
  
  final bool isAdmin; // إضافة خاصية الأدمن
  final VoidCallback? onAdminTap; // إضافة أكشن لوحة الإدارة

  final VoidCallback onEditProfile;
  final VoidCallback onSettings;
  final VoidCallback onCustomizeUi;
  final VoidCallback onNotifications;
  final VoidCallback onPrivacy;
  final VoidCallback onBackup;
  final VoidCallback onShare;
  final VoidCallback onRate;
  final VoidCallback onBugReport;
  final VoidCallback onContact;
  final VoidCallback onAppVision;
  final VoidCallback onDeveloper;
  final VoidCallback onPrivacyPolicy;
  final VoidCallback onTerms;

  const HomeDrawer({
    super.key,
    required this.userName,
    required this.userId,
    required this.userLevel,
    required this.hijriText,
    required this.progress,
    required this.visualState,
    required this.drawerMessage,
    required this.selectedProfileSymbol,
    this.isAdmin = false,
    this.onAdminTap,
    required this.onEditProfile,
    required this.onSettings,
    required this.onCustomizeUi,
    required this.onNotifications,
    required this.onPrivacy,
    required this.onBackup,
    required this.onShare,
    required this.onRate,
    required this.onBugReport,
    required this.onContact,
    required this.onAppVision,
    required this.onDeveloper,
    required this.onPrivacyPolicy,
    required this.onTerms,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.84;

    return SizedBox(
      width: width,
      child: Drawer(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            bottomLeft: Radius.circular(30),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                border: Border(
                  left: BorderSide(
                    color: AppColors.gold.withOpacity(0.14),
                    width: 1.5,
                  ),
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(14, 8, 14, 18),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          // إذا كان المستخدم أدمن، نظهر له لوحة التحكم في البداية
                          if (isAdmin) ...[
                            _buildSectionTitle("الإدارة والتحكم"),
                            _drawerItem(
                              icon: Icons.admin_panel_settings_rounded,
                              title: "لوحة تحكم الإدارة",
                              subtitle: "إدارة المستخدمين، النظام، والإشعارات",
                              onTap: onAdminTap ?? () {},
                              isSpecial: true,
                            ),
                            const SizedBox(height: 12),
                          ],

                          _buildSectionTitle("التحكم والتخصيص"),
                          _drawerItem(
                            icon: Icons.tune_rounded,
                            title: "الإعدادات",
                            subtitle: "الثيم، اللغة، الخط، العرض",
                            onTap: onSettings,
                          ),
                          _drawerItem(
                            icon: Icons.dashboard_customize_rounded,
                            title: "تخصيص الواجهة",
                            subtitle: "رتب التجربة حسب تفضيلاتك",
                            onTap: onCustomizeUi,
                          ),
                          _drawerItem(
                            icon: Icons.shield_moon_outlined,
                            title: "الخصوصية والبيانات",
                            subtitle: "الأذونات والموقع والاستخدام",
                            onTap: onPrivacy,
                          ),
                          _drawerItem(
                            icon: Icons.cloud_sync_outlined,
                            title: "النسخ الاحتياطي",
                            subtitle: "حفظ البيانات والمزامنة مستقبلًا",
                            onTap: onBackup,
                          ),

                          const SizedBox(height: 18),
                          _buildSectionTitle("المجتمع والانتشار"),
                          _drawerItem(
                            icon: Icons.campaign_outlined,
                            title: "نشر التطبيق",
                            subtitle: "شارك ذكرني مع من تحب",
                            onTap: onShare,
                          ),
                          _drawerItem(
                            icon: Icons.star_rate_rounded,
                            title: "تقييم التطبيق",
                            subtitle: "قيّم تجربتك وساعدنا على التطوير",
                            onTap: onRate,
                          ),
                          _drawerItem(
                            icon: Icons.bug_report_outlined,
                            title: "الإبلاغ عن مشكلة",
                            subtitle: "أخبرنا بأي خلل أو ملاحظة",
                            onTap: onBugReport,
                          ),
                          _drawerItem(
                            icon: Icons.forum_outlined,
                            title: "تواصل معنا",
                            subtitle: "قناة مباشرة للدعم والرسائل",
                            onTap: onContact,
                          ),

                          const SizedBox(height: 18),
                          _buildMessageCard(),

                          const SizedBox(height: 18),
                          _buildSectionTitle("عن التطبيق"),
                          _drawerItem(
                            icon: Icons.visibility_outlined,
                            title: "رؤية ذكرني",
                            subtitle: "كيف نجعل الذكر تجربة حيّة",
                            onTap: onAppVision,
                          ),
                          _drawerItem(
                            icon: Icons.code_off_rounded,
                            title: "المطور",
                            subtitle: "نبذة عن صاحب الفكرة ورسالة البناء",
                            onTap: onDeveloper,
                          ),
                          _drawerItem(
                            icon: Icons.gpp_good_outlined,
                            title: "سياسة الخصوصية",
                            subtitle: "حماية البيانات والاستخدام",
                            onTap: onPrivacyPolicy,
                          ),
                          _drawerItem(
                            icon: Icons.article_outlined,
                            title: "الشروط والأحكام",
                            subtitle: "تفاصيل الاستخدام العامة",
                            onTap: onTerms,
                          ),
                        ],
                      ),
                    ),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white.withOpacity(0.05),
          border: Border.all(
            color: AppColors.gold.withOpacity(0.14),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.gold.withOpacity(0.28),
                        ),
                      ),
                      child: Icon(
                        selectedProfileSymbol,
                        color: AppColors.gold,
                        size: 32,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: onEditProfile,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.gold,
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            size: 14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName.isEmpty ? "عابد لله" : userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: "Cairo",
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userId.isEmpty ? "ID-USER" : userId,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.34),
                          fontFamily: "monospace",
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "رحلة نورك مستمرة",
                        style: TextStyle(
                          color: AppColors.gold,
                          fontFamily: "Cairo",
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _smallInfoChip(
                    icon: Icons.workspace_premium_outlined,
                    text: userLevel.isEmpty ? "مستوى روحاني" : userLevel,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _smallInfoChip(
                    icon: Icons.calendar_month_outlined,
                    text: hijriText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: progress.clamp(0.0, 1.0),
                backgroundColor: Colors.white.withOpacity(0.08),
                valueColor: AlwaysStoppedAnimation(AppColors.gold.withOpacity(0.8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallInfoChip({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: "Cairo",
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 4, 6, 10),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.gold.withOpacity(0.9),
          fontFamily: "Cairo",
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isSpecial = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSpecial 
            ? AppColors.gold.withOpacity(0.12)
            : Colors.white.withOpacity(0.025),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSpecial 
              ? AppColors.gold.withOpacity(0.3)
              : Colors.white.withOpacity(0.04),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: AppColors.gold.withOpacity(isSpecial ? 0.2 : 0.08),
            border: Border.all(
              color: AppColors.gold.withOpacity(0.12),
            ),
          ),
          child: Icon(icon, color: AppColors.gold, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontFamily: "Cairo",
            fontSize: 14,
            fontWeight: isSpecial ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withOpacity(0.48),
            fontFamily: "Cairo",
            fontSize: 11,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: Colors.white.withOpacity(0.18),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildMessageCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.gold.withOpacity(0.05),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.14),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold.withOpacity(0.1),
            ),
            child: const Icon(
              Icons.wb_incandescent_outlined,
              color: AppColors.gold,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "رسالة من ذكرني",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Cairo",
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  drawerMessage,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.74),
                    fontFamily: "Cairo",
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Column(
        children: [
          Container(
            height: 1,
            margin: const EdgeInsets.only(bottom: 14),
            color: Colors.white.withOpacity(0.06),
          ),
          const Text(
            "ذكرني",
            style: TextStyle(
              color: AppColors.gold,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "نورٌ يرافق يومك",
            style: TextStyle(
              color: Colors.white.withOpacity(0.42),
              fontFamily: "Cairo",
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "v1.0.0",
            style: TextStyle(
              color: Colors.white.withOpacity(0.24),
              fontFamily: "monospace",
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
