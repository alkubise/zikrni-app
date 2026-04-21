import 'package:firebase_messaging/firebase_messaging.dart';
import 'overlay_service.dart';

class FirebaseService {

  static final _messaging = FirebaseMessaging.instance;

  static Future<void> init() async {

    await _messaging.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {

      final data = {
        "title": message.notification?.title ?? "",
        "text": message.notification?.body ?? "",
      };

      /// 🔥 عرض Overlay عند وصول إشعار
      OverlayService.showGlobalOverlay(data);
    });
  }
}