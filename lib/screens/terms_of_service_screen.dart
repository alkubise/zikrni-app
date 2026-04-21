import 'package:flutter/material.dart';
import '../core/ui/app_layout.dart';
import '../constants/app_colors.dart';
import 'widgets/premium_page_shell.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final layout = AppLayout(context);

    return PremiumPageShell(
      title: "الشروط والأحكام",
      topLabel: "TERMS OF SERVICE",
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
            _buildSection(
              icon: Icons.gavel_rounded,
              title: "اتفاقية الاستخدام",
              content:
              "باستخدامك لتطبيق ذكرني، فإنك توافق على استخدامه ضمن غايته التعبدية والتعليمية، والالتزام بالشروط التي تنظم الاستفادة من ميزاته بصورة آمنة ومحترمة.",
              layout: layout,
            ),
            _buildSection(
              icon: Icons.verified_user_outlined,
              title: "الاستخدام العادل",
              content:
              "يُسمح باستخدام التطبيق للأغراض الشخصية، التعبدية، والتعليمية. ويُمنع استغلاله في أنشطة تجارية غير مصرح بها أو العبث بوظائفه أو محاولة إساءة استخدام خدماته.",
              layout: layout,
            ),
            _buildSection(
              icon: Icons.copyright_rounded,
              title: "الملكية الفكرية",
              content:
              "التصميمات، البنية البرمجية، والهوية البصرية لذكرني تُعد جزءًا من الملكية الفكرية الخاصة بالتطبيق. أما النصوص الشرعية والأذكار فهي ميراث عام للأمة، وطريقة تقديمها داخل التطبيق هي جزء من العمل الإبداعي الخاص بالمشروع.",
              layout: layout,
            ),
            _buildSection(
              icon: Icons.update_rounded,
              title: "التحديثات والتغييرات",
              content:
              "قد تُحدّث ميزات التطبيق أو واجهاته أو هذه الشروط نفسها بهدف التحسين والتطوير. استمرار استخدامك للتطبيق بعد التحديثات يعني قبولك بالنسخة الأحدث من الشروط.",
              layout: layout,
            ),
            _buildSection(
              icon: Icons.report_problem_outlined,
              title: "إخلاء المسؤولية",
              content:
              "نسعى إلى أعلى قدر من الدقة في مواقيت الصلاة واتجاه القبلة، لكن بعض النتائج قد تتأثر بعوامل تقنية مثل الموقع، أذونات الجهاز، أو دقة المستشعرات. لذلك تبقى مسؤولية التحقق النهائي على المستخدم عند الحاجة.",
              layout: layout,
            ),
            SizedBox(height: layout.scale(30)),
            _buildSummaryCard(layout),
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
            Icons.description_outlined,
            color: AppColors.gold,
            size: layout.scale(40),
          ),
          SizedBox(width: layout.scale(18)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "وضوح وشفافية",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: layout.scale(18),
                    fontWeight: FontWeight.bold,
                    fontFamily: "Cairo",
                  ),
                ),
                SizedBox(height: layout.scale(4)),
                Text(
                  "شروط واضحة تحمي المستخدم وتحافظ على هوية التطبيق واحترامه.",
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
        const PremiumSectionTitle("فهمنا للشروط"),
        SizedBox(height: layout.scale(14)),
        Text(
          "الشروط في ذكرني ليست مكتوبة للتعقيد، بل لتنظيم العلاقة بين التطبيق والمستخدم بشكل واضح وعادل ومحترم، وبما يحفظ حق الجميع.",
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

  Widget _buildSection({
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
      child: Center(
        child: Text(
          "باستخدامك للتطبيق، فأنت توافق على هذه الشروط ضمن إطار الاحترام، الاستخدام العادل، والغاية التي بُني من أجلها ذكرني.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.72),
            fontSize: layout.scale(13),
            height: 1.8,
            fontFamily: "Cairo",
          ),
        ),
      ),
    );
  }
}