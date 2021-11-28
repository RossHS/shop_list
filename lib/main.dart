import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logging/logging.dart';
import 'package:shop_list/controllers/controllers.dart';
import 'package:shop_list/routes/get_routes.dart';
import 'package:shop_list/utils/firebase_messaging_service.dart';

void main() async {
  // Настройка логгера. Просто выводит в консоль сообщение в определенном формате
  Logger.root.level = Level.FINE; // defaults to Level.INFO
  Logger.root.onRecord.listen((log) {
    // ignore: avoid_print
    print('[${log.level.name}] ${log.loggerName} \t ${log.time} \t ${log.message}');
  });

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();
  Get.put(AuthenticationController());
  Get.put(ThemeController());
  FirebaseMessagingService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: '/',
      getPages: GetRoutes.routes,
      themeMode: ThemeController.to.themeMode.value,
      theme: ThemeController.to.appTheme.value.lightTheme,
      darkTheme: ThemeController.to.appTheme.value.darkTheme,
    );
  }
}
