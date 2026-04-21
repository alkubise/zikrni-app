import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../data/azkar_data.dart';
import 'notification_scheduler_service.dart';
import 'notification_service.dart';

class FridaySunnahService {
  FridaySunnahService._();

  static const int fridayId = 4001;

  static Future<void> scheduleFridaySunnah() async {
    final item = _pickFridayItem();

    await NotificationService.zonedSchedule(
      id: fridayId,
      title: item['title'] ?? '🕋 سنن الجمعة',
      body: _body(item),
      scheduledDate: NotificationSchedulerService.nextFridayAt(
        hour: 9,
        minute: 0,
      ),
      payload: 'friday_sunnah',
    );
  }

  static Future<void> cancelFridaySunnah() async {
    await NotificationService.cancel(fridayId);
  }

  static Map<String, String> _pickFridayItem() {
    final items = AzkarData.data.where((e) => e['type'] == 'friday').toList();
    if (items.isEmpty) {
      return {
        'title': '🕋 سنن الجمعة',
        'text': 'لا تنس الصلاة على النبي وقراءة سورة الكهف.',
      };
    }
    items.shuffle();
    return items.first;
  }

  static String _body(Map<String, String> item) {
    final text = item['text'] ?? '';
    final ref = item['ref'] ?? '';
    return ref.isNotEmpty ? '$text\n$ref' : text;
  }
}