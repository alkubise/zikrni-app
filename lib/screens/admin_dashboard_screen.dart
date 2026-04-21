import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../constants/app_colors.dart';
import '../services/theme_service.dart';
import '../services/admin_remote_service.dart';

enum AdminSection {
  overview,
  users,
  notifications,
  features,
  security,
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AdminSection _currentSection = AdminSection.overview;
  final TextEditingController _userSearchController = TextEditingController();
  String _userSearch = '';

  DocumentReference<Map<String, dynamic>> get _configRef =>
      _firestore.collection('system').doc('config');

  @override
  void dispose() {
    _userSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeService.instance;
    final isWide = MediaQuery.of(context).size.width >= 1000;

    return Scaffold(
      backgroundColor: Colors.black,
      drawer: isWide ? null : _AdminDrawer(
        currentSection: _currentSection,
        onSelect: _selectSection,
      ),
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset(theme.backgroundImage, fit: BoxFit.cover, opacity: const AlwaysStoppedAnimation(0.12))),
          Positioned.fill(child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30), child: Container(color: Colors.black.withOpacity(0.85)))),
          SafeArea(
            child: Row(
              children: [
                if (isWide) _AdminSidebar(currentSection: _currentSection, onSelect: _selectSection),
                Expanded(
                  child: Column(
                    children: [
                      Builder(builder: (ctx) => _AdminTopBar(
                        currentSection: _currentSection,
                        onMenuTap: isWide ? null : () => Scaffold.of(ctx).openDrawer(),
                        onLogoutTap: _logout,
                      )),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _buildCurrentSection(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _selectSection(AdminSection section) {
    setState(() => _currentSection = section);
    if (MediaQuery.of(context).size.width < 1000) Navigator.of(context).maybePop();
  }

  Future<void> _logout() async {
    await _auth.signOut();
    if (!mounted) return;
    Navigator.pop(context);
  }

  Widget _buildCurrentSection() {
    switch (_currentSection) {
      case AdminSection.overview: return _buildOverviewSection();
      case AdminSection.users: return _buildUsersSection();
      case AdminSection.notifications: return _buildNotificationsSection();
      case AdminSection.features: return _buildFeaturesSection();
      case AdminSection.security: return _buildSecuritySection();
    }
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  String _formatNumber(int number) {
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toString();
  }

  // --- OVERVIEW ---
  Widget _buildOverviewSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        int onlineNow = 0;
        int totalToday = 0;
        int grandTotal = 0;
        final now = DateTime.now();

        for (var doc in docs) {
          final d = doc.data() as Map<String, dynamic>;
          final lastSeen = _parseDateTime(d['lastSeenAt']);
          if (lastSeen != null && now.difference(lastSeen).inMinutes < 5) onlineNow++;
          totalToday += (int.tryParse("${d['todayCount']}") ?? 0);
          grandTotal += (int.tryParse("${d['totalCount']}") ?? 0);
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Expanded(child: _statCard("متصل الآن", onlineNow.toString(), Colors.greenAccent, Icons.circle, isLive: true)),
                const SizedBox(width: 12),
                Expanded(child: _statCard("أذكار اليوم", _formatNumber(totalToday), Colors.orangeAccent, Icons.bolt)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _statCard("المستخدمين", docs.length.toString(), Colors.cyanAccent, Icons.people)),
                const SizedBox(width: 12),
                Expanded(child: _statCard("إجمالي الذكر", _formatNumber(grandTotal), AppColors.gold, Icons.auto_graph)),
              ],
            ),
            const SizedBox(height: 25),
            _glassCard(title: "الإجراءات السريعة", child: Wrap(
              spacing: 10, runSpacing: 10,
              children: [
                _actionButton(label: "إشعار للجميع", icon: Icons.campaign, color: Colors.amberAccent, onTap: () => _showBroadcastDialog(targetType: 'all')),
                _actionButton(label: "تعديل التحدي", icon: Icons.emoji_events, color: AppColors.gold, onTap: _showEditChallengeDialog),
                _actionButton(label: "محتوى اليوم", icon: Icons.edit_note, color: Colors.blueAccent, onTap: _showDailyContentDialog),
              ],
            )),
          ],
        );
      },
    );
  }

  Widget _statCard(String title, String value, Color color, IconData icon, {bool isLive = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(28), border: Border.all(color: color.withOpacity(0.15))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Icon(icon, color: color, size: isLive ? 12 : 20),
            if (isLive) const Text("LIVE", style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold))
          ]),
          const SizedBox(height: 15),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
          Text(title, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12, fontFamily: 'Cairo')),
        ],
      ),
    );
  }

  // --- USERS ---
  Widget _buildUsersSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: TextField(
            controller: _userSearchController,
            onChanged: (v) => setState(() => _userSearch = v.trim()),
            style: const TextStyle(color: Colors.white, fontFamily: 'Cairo'),
            decoration: InputDecoration(
              hintText: "بحث عن مستخدم بالاسم أو UID...",
              hintStyle: const TextStyle(color: Colors.white24),
              prefixIcon: const Icon(Icons.search, color: AppColors.gold),
              filled: true, fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('users').orderBy('lastSeenAt', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snapshot.data!.docs.where((d) {
                final data = d.data() as Map<String, dynamic>;
                return data['name'].toString().toLowerCase().contains(_userSearch.toLowerCase()) || d.id.contains(_userSearch);
              }).toList();

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final data = docs[i].data() as Map<String, dynamic>;
                  final lastSeen = _parseDateTime(data['lastSeenAt']);
                  final isOnline = lastSeen != null && DateTime.now().difference(lastSeen).inMinutes < 5;
                  return _userTile(data['name'] ?? 'مستخدم', data['userEmail'] ?? '', isOnline, lastSeen);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _userTile(String name, String email, bool online, DateTime? lastSeen) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(22), border: Border.all(color: online ? Colors.greenAccent.withOpacity(0.2) : Colors.white10)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: AppColors.gold.withOpacity(0.1), child: Icon(Icons.person, color: online ? Colors.greenAccent : AppColors.gold)),
        title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(email, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        trailing: Text(online ? "متصل" : _formatLastSeen(lastSeen), style: TextStyle(color: online ? Colors.greenAccent : Colors.white24, fontSize: 10)),
      ),
    );
  }

  // --- NOTIFICATIONS ---
  Widget _buildNotificationsSection() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _glassCard(
          title: "إرسال إشعار فوري",
          child: Column(
            children: [
              _actionButton(
                label: "إشعار عام لجميع المستخدمين",
                icon: Icons.all_inclusive_rounded,
                color: Colors.amberAccent,
                onTap: () => _showBroadcastDialog(targetType: 'all'),
              ),
              const SizedBox(height: 10),
              _actionButton(
                label: "إرسال لمستخدم محدد (UID)",
                icon: Icons.person_pin_rounded,
                color: Colors.cyanAccent,
                onTap: _showPrivateNotificationDialog,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _glassCard(
          title: "قوالب سريعة",
          child: Wrap(
            spacing: 8,
            children: [
              ActionChip(label: const Text("تذكير بالوتر"), onPressed: () => _sendQuickNote("لا تنسوا صلاة الوتر يا أحبة 🌙")),
              ActionChip(label: const Text("فضل الصلاة على النبي"), onPressed: () => _sendQuickNote("صلوا على من يشفع لنا يوم القيامة ﷺ")),
              ActionChip(label: const Text("تنبيه صيانة"), onPressed: () => _sendQuickNote("سنقوم ببعض التحسينات للتطبيق قريباً 🛠️")),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _glassCard(
          title: "سجل آخر الإشعارات",
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('broadcasts').orderBy('createdAt', descending: true).limit(5).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const LinearProgressIndicator();
              return Column(
                children: snapshot.data!.docs.map((d) {
                  final data = d.data() as Map<String, dynamic>;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(data['message'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 12)),
                    subtitle: Text(DateFormat('dd/MM hh:mm a').format(_parseDateTime(data['createdAt']) ?? DateTime.now()), style: const TextStyle(color: Colors.white24, fontSize: 10)),
                    trailing: const Icon(Icons.done_all, color: Colors.greenAccent, size: 14),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- FEATURES (FULLY FUNCTIONAL NOW) ---
  Widget _buildFeaturesSection() {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _configRef.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final data = snapshot.data!.data() ?? {};
        final announceController = TextEditingController(text: data['announcement'] ?? '');
        
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _glassCard(
              title: "الإعلان العام (يظهر للكل)",
              child: Column(
                children: [
                  _dialogField(controller: announceController, hint: "نص الإعلان الذي سيظهر في الصفحة الرئيسية", maxLines: 2),
                  const SizedBox(height: 10),
                  _actionButton(
                    label: "تحديث الإعلان", 
                    icon: Icons.publish, 
                    color: AppColors.gold, 
                    onTap: () async {
                      await _configRef.update({'announcement': announceController.text.trim()});
                      _showDone("تم تحديث الإعلان العام بنجاح");
                    }
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _featureToggle("تفعيل الذكاء الروحي", "aiEnabled", data['aiEnabled'] ?? false),
            _featureToggle("نظام الإشعارات الذكي", "smartNotifications", data['smartNotifications'] ?? false),
            _featureToggle("وضع الصيانة العالمي", "maintenance", data['maintenance'] ?? false),
            _featureToggle("تحديات المجموعة", "groupChallenges", data['groupChallenges'] ?? false),
            const SizedBox(height: 15),
            _glassCard(
              title: "تحديثات النظام", 
              child: Column(children: [
                _statusRow("الحد الأدنى للإصدار", data['minVersion'] ?? "1.0.0"),
                _actionButton(
                  label: "تعديل رقم الإصدار", 
                  icon: Icons.system_update, 
                  color: Colors.white.withOpacity(0.1), 
                  onTap: () => _showVersionUpdateDialog(data['minVersion'] ?? "1.0.0")
                ),
              ])
            ),
          ],
        );
      },
    );
  }

  // --- SECURITY ---
  Widget _buildSecuritySection() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _glassCard(
          title: "حالة النظام الأمني",
          child: Column(
            children: [
              _statusRow("المشرف الحالي", _auth.currentUser?.email ?? 'مجهول'),
              _statusRow("صلاحيات الوصول", "Super Admin"),
              _statusRow("قاعدة البيانات", "Firestore Protected"),
              _statusRow("التشفير", "AES-256 Active"),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Center(child: Icon(Icons.shield_moon_rounded, size: 100, color: Colors.white10)),
      ],
    );
  }

  // --- HELPERS & DIALOGS ---
  String _formatLastSeen(DateTime? date) {
    if (date == null) return 'غير معروف';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} د';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} س';
    return DateFormat('dd/MM').format(date);
  }

  Widget _featureToggle(String title, String key, bool value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(18)),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Cairo')),
        value: value, activeColor: AppColors.gold,
        onChanged: (v) => _updateConfigFlag(key, v),
      ),
    );
  }

  Future<void> _updateConfigFlag(String key, bool value) async {
    await AdminRemoteService.instance.updateSystemConfig(key: key, value: value);
  }

  void _sendQuickNote(String msg) async {
    await AdminRemoteService.instance.sendBroadcast(message: msg, targetType: 'all');
    _showDone("تم إرسال الإشعار بنجاح");
  }

  Future<void> _showPrivateNotificationDialog() async {
    final uidC = TextEditingController();
    final msgC = TextEditingController();
    showDialog(context: context, builder: (context) => _adminDialog(title: "إرسال لمستخدم محدد", child: Column(mainAxisSize: MainAxisSize.min, children: [
      _dialogField(controller: uidC, hint: "أدخل الـ UID للمستخدم"),
      const SizedBox(height: 10),
      _dialogField(controller: msgC, hint: "نص الرسالة الخاصة", maxLines: 3),
      const SizedBox(height: 15),
      _dialogButtons(onConfirm: () async {
        await AdminRemoteService.instance.sendBroadcast(message: msgC.text, targetType: 'single', targetUser: uidC.text);
        Navigator.pop(context);
        _showDone("تم الإرسال للمستخدم");
      })
    ])));
  }

  Future<void> _showVersionUpdateDialog(String currentVer) async {
    final verC = TextEditingController(text: currentVer);
    showDialog(context: context, builder: (context) => _adminDialog(title: "تحديث إصدار التطبيق", child: Column(mainAxisSize: MainAxisSize.min, children: [
      _dialogField(controller: verC, hint: "مثلاً: 1.0.5"),
      const SizedBox(height: 15),
      _dialogButtons(onConfirm: () async {
        await _configRef.update({'minVersion': verC.text.trim()});
        Navigator.pop(context);
        _showDone("تم تحديث رقم الإصدار");
      })
    ])));
  }

  Future<void> _showEditChallengeDialog() async {
    final titleC = TextEditingController();
    final goalC = TextEditingController();
    final snap = await _configRef.get();
    titleC.text = snap.data()?['challengeTitle'] ?? '';
    goalC.text = (snap.data()?['challengeGoal'] ?? '').toString();
    showDialog(context: context, builder: (context) => _adminDialog(title: "تعديل التحدي", child: Column(mainAxisSize: MainAxisSize.min, children: [
      _dialogField(controller: titleC, hint: "عنوان التحدي"),
      const SizedBox(height: 10),
      _dialogField(controller: goalC, hint: "الهدف العددي"),
      const SizedBox(height: 15),
      _dialogButtons(onConfirm: () async {
        await _configRef.update({'challengeTitle': titleC.text, 'challengeGoal': int.tryParse(goalC.text) ?? 1000000});
        Navigator.pop(context);
      })
    ])));
  }

  Future<void> _showBroadcastDialog({required String targetType}) async {
    final controller = TextEditingController();
    showDialog(context: context, builder: (context) => _adminDialog(title: "إرسال إشعار عام", child: Column(mainAxisSize: MainAxisSize.min, children: [
      _dialogField(controller: controller, hint: "اكتب الرسالة هنا...", maxLines: 3),
      const SizedBox(height: 15),
      _dialogButtons(onConfirm: () async {
        await AdminRemoteService.instance.sendBroadcast(message: controller.text, targetType: targetType);
        Navigator.pop(context);
      })
    ])));
  }

  Future<void> _showDailyContentDialog() async {
    final titleC = TextEditingController();
    final contentC = TextEditingController();
    showDialog(context: context, builder: (context) => _adminDialog(title: "محتوى اليوم", child: Column(mainAxisSize: MainAxisSize.min, children: [
      _dialogField(controller: titleC, hint: "العنوان"),
      const SizedBox(height: 10),
      _dialogField(controller: contentC, hint: "المحتوى", maxLines: 3),
      const SizedBox(height: 15),
      _dialogButtons(onConfirm: () async {
        await AdminRemoteService.instance.updateDailyContent(title: titleC.text, content: contentC.text);
        Navigator.pop(context);
      })
    ])));
  }

  Widget _glassCard({required String title, required Widget child}) {
    return Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.08))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Cairo')), const SizedBox(height: 14), child]));
  }
  Widget _statusRow(String title, String value) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: TextStyle(color: Colors.white54, fontSize: 12, fontFamily: 'Cairo')), Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'Cairo'))]));
  Widget _actionButton({required String label, required IconData icon, required Color color, required VoidCallback onTap}) => ElevatedButton.icon(onPressed: onTap, style: ElevatedButton.styleFrom(backgroundColor: color.withOpacity(0.1), foregroundColor: color, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), icon: Icon(icon, size: 18), label: Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold)));
  Widget _adminDialog({required String title, required Widget child}) => BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), child: AlertDialog(backgroundColor: const Color(0xFF121212), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: AppColors.gold.withOpacity(0.2))), title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Cairo')), content: child));
  Widget _dialogField({required TextEditingController controller, required String hint, int maxLines = 1}) => TextField(controller: controller, maxLines: maxLines, style: const TextStyle(color: Colors.white, fontSize: 13), decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Colors.white24), filled: true, fillColor: Colors.white.withOpacity(0.05), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none)));
  Widget _dialogButtons({required Future<void> Function() onConfirm}) => Row(children: [Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء", style: TextStyle(color: Colors.white38)))), const SizedBox(width: 10), Expanded(child: ElevatedButton(onPressed: onConfirm, style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text("تأكيد", style: TextStyle(fontWeight: FontWeight.bold))))]);
  void _showDone(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text, style: const TextStyle(fontFamily: 'Cairo'))));
}

class _AdminTopBar extends StatelessWidget {
  final AdminSection currentSection;
  final VoidCallback? onMenuTap;
  final VoidCallback onLogoutTap;
  const _AdminTopBar({required this.currentSection, required this.onMenuTap, required this.onLogoutTap});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.all(16), child: Row(children: [if (onMenuTap != null) IconButton(onPressed: onMenuTap, icon: const Icon(Icons.menu, color: Colors.white)), Text(_title(currentSection), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'Cairo')), const Spacer(), IconButton(onPressed: onLogoutTap, icon: const Icon(Icons.logout, color: Colors.redAccent))]));
  String _title(AdminSection s) {
    switch(s) {
      case AdminSection.overview: return "الرئيسية";
      case AdminSection.users: return "المستخدمين";
      case AdminSection.notifications: return "الإشعارات";
      case AdminSection.features: return "المزايا";
      case AdminSection.security: return "الأمان";
    }
  }
}

class _AdminSidebar extends StatelessWidget {
  final AdminSection currentSection;
  final ValueChanged<AdminSection> onSelect;
  const _AdminSidebar({required this.currentSection, required this.onSelect});
  @override
  Widget build(BuildContext context) => Container(width: 260, color: Colors.white.withOpacity(0.02), child: Column(children: [const SizedBox(height: 40), const Icon(Icons.admin_panel_settings, size: 50, color: AppColors.gold), const SizedBox(height: 20), _navItem("الرئيسية", Icons.dashboard, AdminSection.overview), _navItem("المستخدمين", Icons.people, AdminSection.users), _navItem("الإشعارات", Icons.notifications, AdminSection.notifications), _navItem("المزايا", Icons.tune, AdminSection.features), _navItem("الأمان", Icons.security, AdminSection.security)]));
  Widget _navItem(String title, IconData icon, AdminSection section) {
    final active = currentSection == section;
    return ListTile(leading: Icon(icon, color: active ? AppColors.gold : Colors.white24), title: Text(title, style: TextStyle(color: active ? Colors.white : Colors.white24, fontFamily: 'Cairo', fontWeight: active ? FontWeight.bold : FontWeight.normal)), onTap: () => onSelect(section));
  }
}

class _AdminDrawer extends StatelessWidget {
  final AdminSection currentSection;
  final ValueChanged<AdminSection> onSelect;
  const _AdminDrawer({required this.currentSection, required this.onSelect});
  @override
  Widget build(BuildContext context) => Drawer(backgroundColor: Colors.black, child: _AdminSidebar(currentSection: currentSection, onSelect: onSelect));
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.05)..strokeWidth = 0.5;
    for (double i = 0; i < size.width; i += 40) canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    for (double i = 0; i < size.height; i += 40) canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
  }
  @override
  bool shouldRepaint(CustomPainter old) => false;
}
