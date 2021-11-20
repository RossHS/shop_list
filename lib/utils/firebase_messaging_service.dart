import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:logging/logging.dart';

/// Сервис обработки приходящих оповещений
class FirebaseMessagingService {
  static final _log = Logger('FirebaseMessagingService');

  /// Инициализация работы сервиса
  static void init() {
    // Set the background messaging handler early on, as a named top-level function
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _log.fine('open app from message with title - ${message.notification?.title}, '
          'body - ${message.notification?.body}');

      if (message.data['click_action'] == 'FLUTTER_NOTIFICATION_CLICK' && message.data['todoIdRef'] != null) {
        _log.fine('the message has the correct structure');
        Get.toNamed('/todo/${message.data['todoIdRef']}/view');
      }
    });
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}
