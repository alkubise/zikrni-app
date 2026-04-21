import 'package:flutter_test/flutter_test.dart';
import 'package:azkar_app/main.dart';

void main() {
  testWidgets('Splash Screen smoke test', (WidgetTester tester) async {
    // بناء التطبيق وإرسال إطار (Frame)
    await tester.pumpWidget(const AzkarApp());

    // التحقق من وجود التطبيق (اختبار بسيط للتأكد من التشغيل)
    expect(find.byType(AzkarApp), findsOneWidget);
  });
}
