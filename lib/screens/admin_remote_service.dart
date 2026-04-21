import 'package:cloud_functions/cloud_functions.dart';

class AdminRemoteService {
  AdminRemoteService._();
  static final instance = AdminRemoteService._();

  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<void> updateSystemConfig({
    required String key,
    required dynamic value,
  }) async {
    await _functions.httpsCallable('updateSystemConfig').call({
      'key': key,
      'value': value,
    });
  }

  Future<void> sendBroadcast({
    required String message,
    required String targetType,
    String? targetUser,
  }) async {
    await _functions.httpsCallable('sendBroadcast').call({
      'message': message,
      'targetType': targetType,
      'targetUser': targetUser,
    });
  }

  Future<void> updateDailyContent({
    required String title,
    required String content,
  }) async {
    await _functions.httpsCallable('updateDailyContent').call({
      'title': title,
      'content': content,
    });
  }
}