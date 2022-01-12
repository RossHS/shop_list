import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_list/controllers/controllers.dart';
import 'package:shop_list/models/models.dart';
import 'package:shop_list/routes/home/home_glassmorphism.dart';
import 'package:shop_list/routes/home/home_material.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(TodosController(usersMapController: UsersMapController()));
    // Написал так, а не через ThemeDepBuilder, т.к. это просто чуть более
    // производительный подход из-за наличия Helper Methods в ThemeDepBuilder,
    // но он более чреват потенциальными ошибками из-за state machine
    return Obx(() {
      final appTheme = ThemeController.to.appTheme.value;
      if (appTheme is GlassmorphismThemeDataWrapper) {
        return const HomeGlassmorphism();
      } else {
        return const HomeMaterial();
      }
    });
  }
}
