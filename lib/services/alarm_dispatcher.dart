import 'package:flutter/widgets.dart';
import 'notification_service.dart';
import 'reminder_engine.dart';

@pragma('vm:entry-point')
Future<void> alarmCallback() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  await ReminderEngine.initialize();
  await ReminderEngine.sendOneNow();
}