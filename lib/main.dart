import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logging/logging.dart';
import 'package:shop_list/controllers/controllers.dart';
import 'package:shop_list/routes/get_routes.dart';
import 'package:shop_list/utils/firebase_messaging_service.dart';
import 'package:shop_list/utils/routes_transition.dart';

void main() async {
  _setUpLogging();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();
  Get.put(AuthenticationController());
  Get.put(ThemeController());
  FirebaseMessagingService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: '/',
      transitionDuration: const Duration(milliseconds: 700),
      customTransition: CustomCircleTransition(),
      getPages: GetRoutes.routes,
      themeMode: ThemeController.to.themeMode.value,
      theme: ThemeController.to.appTheme.value.lightTheme,
      darkTheme: ThemeController.to.appTheme.value.darkTheme,
    );
  }
}

/// Инициализация настроек логгера
void _setUpLogging() {
  // В сборках профилирования и релизе вывод только сообщений об ошибках/угрозах и т.п.
  if (kReleaseMode || kProfileMode) {
    Logger.root.level = Level.WARNING;
  } else if (kDebugMode) {
    Logger.root.level = Level.FINE; // defaults to Level.INFO
  }
  // Настройка логгера. Просто выводит в консоль сообщение в определенном формате
  Logger.root.onRecord.listen((log) {
    // ignore: avoid_print
    print('[${log.level.name}] ${log.loggerName} \t ${log.time} \t ${log.message}');
  });
}
