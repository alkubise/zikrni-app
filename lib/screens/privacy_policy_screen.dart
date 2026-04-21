import 'package:flutter/material.dart';
import '../core/ui/app_layout.dart';
import '../constants/app_colors.dart';
import 'widgets/premium_page_shell.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final layout = AppLayout(context);

    return PremiumPageShell(
      title: "سياسة الخصوصية",
      topLabel: "PRIVACY POLICY",
      goHomeOnBack: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: layout.scale(24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroHeader(layout),
            SizedBox(height: layout.scale(30)),
            _buildIntro(layout),
            SizedBox(height: layout.scale(30)),
            _buildPolicySection(
              icon: Icons.security_outlined,
              title: "التزامنا بالخصوصية",
              content:
              "في ذكرني، نعتبر خصوصيتك جزءًا من الأمانة. نحن لا نبيع بياناتك ولا نشارك معلوماتك الشخصية مع جهات إعلانية أو أطراف خارجية، ونسعى إلى تقديم تجربة تحترم قدسية رحلتك الإيمانية.",
              layout: layout,
            ),
            _buildPolicySection(
              icon: Icons.location_on_outlined,
              title: "بيانات الموقع",
              content:
              "يُستخدم الموقع فقط لحساب مواقيت الصلاة بدقة، وتحديد اتجاه القبلة. تتم معالجة هذه البيانات على الجهاز قدر الإمكان، ولا تُستخدم لأغراض تسويقية أو تتبعية.",
              layout: layout,
            ),
            _buildPolicySection(
              icon: Icons.storage_rounded,
              title: "التخزين المحلي",
              content:
              "الاسم المحفوظ، الإعدادات، وبعض بيانات التخصيص تُخزن محليًا على جهازك لتحسين التجربة واستمراريتها. هذا التخزين هدفه خدمتك داخل التطبيق فقط.",
              layout: layout,
            ),
            _buildPolicySection(
              icon: Icons.psychology_outlined,
              title: "الميزات الذكية",
              content:
              "قد يستخدم التطبيق أنماط استخدام عامة لتحسين الاقتراحات والواجهة، لكن دون تحويل تجربتك الروحانية إلى بيانات تعريفية حساسة أو قابلة للبيع أو الاستغلال.",
              layout: layout,
            ),
            _buildPolicySection(
              icon: Icons.delete_forever_outlined,
              title: "حقك في التحكم",
              content:
              "لك الحق في تعديل تفضيلاتك، تعطيل بعض الميزات، أو تصفير بياناتك المحلية من داخل الإعدادات. نحن نؤمن بأن السيطرة يجب أن تبقى بيد المستخدم.",
              layout: layout,
            ),
            SizedBox(height: layout.scale(30)),
            _buildSummaryCard(layout),
            SizedBox(height: layout.scale(30)),
            _buildLastUpdate(layout),
            SizedBox(height: layout.scale(40)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader(AppLayout layout) {
    return PremiumGlassCard(
      child: Row(
        children: [
          Icon(
            Icons.gpp_good_outlined,
            color: AppColors.gold,
            size: layout.scale(40),
          ),
          SizedBox(width: layout.scale(18)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "بياناتك في أمان",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: layout.scale(18),
                    fontWeight: FontWeight.bold,
                    fontFamily: "Cairo",
                  ),
                ),
                SizedBox(height: layout.scale(4)),
                Text(
                  "نحترم الخصوصية باعتبارها جزءًا من الثقة بين التطبيق والمستخدم.",
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: layout.scale(11),
                    fontFamily: "Cairo",
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

  Widget _buildIntro(AppLayout layout) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PremiumSectionTitle("فهمنا للخصوصية"),
        SizedBox(height: layout.scale(14)),
        Text(
          "سياسة الخصوصية في ذكرني لا تُكتب بصياغة قانونية فقط، بل تُبنى على مبدأ واضح: التجربة الروحانية ينبغي أن تبقى آمنة، محترمة، وبعيدة عن الاستغلال.",
          style: TextStyle(
            color: Colors.white.withOpacity(0.72),
            fontSize: layout.scale(14),
            height: 1.85,
            fontFamily: "Cairo",
          ),
        ),
      ],
    );
  }

  Widget _buildPolicySection({
    required IconData icon,
    required String title,
    required String content,
    required AppLayout layout,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: layout.scale(22)),
      child: PremiumGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.gold, size: layout.scale(20)),
                SizedBox(width: layout.scale(10)),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: layout.scale(15),
                      fontWeight: FontWeight.bold,
                      fontFamily: "Cairo",
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: layout.scale(12)),
            Text(
              content,
              style: TextStyle(
                color: Colors.white.withOpacity(0.62),
                fontSize: layout.scale(13),
                height: 1.8,
                fontFamily: "Cairo",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(AppLayout layout) {
    return PremiumGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "الخلاصة",
            style: TextStyle(
              color: AppColors.gold.withOpacity(0.92),
              fontSize: layout.scale(15),
              fontWeight: FontWeight.w800,
              fontFamily: "Cairo",
            ),
          ),
          SizedBox(height: layout.scale(12)),
          Text(
            "نحن لا نتعامل مع بياناتك باعتبارها موردًا تجاريًا، بل باعتبارها مسؤولية. كل قرار في الخصوصية داخل ذكرني ينطلق من احترام المستخدم أولًا.",
            style: TextStyle(
              color: Colors.white.withOpacity(0.74),
              fontSize: layout.scale(13),
              height: 1.8,
              fontFamily: "Cairo",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastUpdate(AppLayout layout) {
    return Center(
      child: Text(
        "آخر تحديث: يناير 2026",
        style: TextStyle(
          color: Colors.white12,
          fontSize: layout.scale(11),
          fontFamily: "Cairo",
        ),
      ),
    );
  }
}