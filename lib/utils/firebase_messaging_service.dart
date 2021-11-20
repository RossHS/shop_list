import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logging/logging.dart';
import 'package:shop_list/controllers/info_overlay_controller.dart';
import 'package:shop_list/controllers/todo/todo_service.dart';

/// Сервис обработки приходящих оповещений
class FirebaseMessagingService {
  static final _log = Logger('FirebaseMessagingService');

  /// Инициализация работы сервиса
  static void init() {
    // Код, исполняющийся при состоянии, когда приложение полностью закрыто или работает в фоне
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    // Код, который исполнится при открытии приложения из оповещения,
    // должен произойти переход к списку дел из сообщения
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _log.fine('open app from message with title - ${message.notification?.title}, '
          'body - ${message.notification?.body}');
      if (_checkNotificationMessage(message)) {
        _log.fine('the message has the correct structure');
        Get.toNamed('/todo/${message.data['todoIdRef']}/view');
      } else {
        _log.shout('error msgID - ${message.messageId}');
      }
    });
    // Исполняется при появлении оповещения во время пользования приложение
    FirebaseMessaging.onMessage.listen((message) async {
      _log.fine('onMessage triggered! - ${message.notification?.title}, '
          'body - ${message.notification?.body}');
      if (_checkNotificationMessage(message)) {
        final todoModel = await TodoService().findTodo(message.data['todoIdRef']);
        CustomInfoOverlay.show(
          title: 'Пользователь ${message.data['username']} создал новый список',
          msg: todoModel.title,
          child: TextButton(
            onPressed: () => Get.toNamed('/todo/${message.data['todoIdRef']}/view'),
            child: const Text('Показать!'),
          ),
        );
      } else {
        _log.shout('error msgID - ${message.messageId}');
      }
    });
  }

  /// Проверка, есть ли необходимый объем информации, чтобы оповещение корректно сработало
  static bool _checkNotificationMessage(RemoteMessage message) {
    return message.data['click_action'] == 'FLUTTER_NOTIFICATION_CLICK' &&
        message.data['todoIdRef'] != null &&
        message.data['username'] != null;
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}
