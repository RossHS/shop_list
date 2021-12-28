import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_list/controllers/controllers.dart';
import 'package:shop_list/models/models.dart';
import 'package:shop_list/routes/home/home_material.dart';
import 'package:shop_list/routes/home/home_modern.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Написал так, а не через ThemeDepBuilder, т.к. это просто чуть более
    // производительный подход из-за наличия Helper Methods в ThemeDepBuilder,
    // но он более чреват потенциальными ошибками из-за state machine
    return Obx(() {
      final appTheme = ThemeController.to.appTheme.value;
      if (appTheme is ModernThemeDataWrapper) {
        return const HomeModern();
      } else {
        return const HomeMaterial();
      }
    });
  }
}