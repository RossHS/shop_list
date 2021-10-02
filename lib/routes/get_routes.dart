import 'package:get/get.dart';
import 'package:shop_list/routes/home.dart';
import 'package:shop_list/routes/sign_in.dart';
import 'package:shop_list/routes/splash.dart';

/// Все константные маршруты
class GetRoutes {
  GetRoutes._();

  static final routes = [
    GetPage(name: '/', page: () => const Splash()),
    GetPage(name: '/home', page: () => Home()),
    GetPage(name: '/signIn', page: () => SignIn()),
    // GetPage(name: '/settings', page: page),
    // GetPage(name: '/list/:id/edit', page: page),
  ];
}
