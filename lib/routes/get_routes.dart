import 'package:get/get.dart';
import 'package:shop_list/routes/account.dart';
import 'package:shop_list/routes/create_todo.dart';
import 'package:shop_list/routes/home.dart';
import 'package:shop_list/routes/sign_in.dart';
import 'package:shop_list/routes/splash.dart';

/// Все константные маршруты
class GetRoutes {
  GetRoutes._();

  static final routes = [
    GetPage(name: '/', page: () => const Splash()),
    GetPage(name: '/home', page: () => const Home()),
    GetPage(name: '/signIn', page: () => const SignIn()),
    GetPage(name: '/account', page: () => const Account()),
    GetPage(name: '/createTodo', page: () => const CreateTodo()),
    // GetPage(name: '/settings', page: page),
    // GetPage(name: '/list/:id/edit', page: page),
  ];
}
