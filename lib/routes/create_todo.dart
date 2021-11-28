import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_list/controllers/controllers.dart';
import 'package:shop_list/widgets/themes_factories/abstract_theme_factory.dart';
import 'package:shop_list/widgets/todo_route_base.dart';

class CreateTodo extends StatelessWidget {
  const CreateTodo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeFactory = ThemeFactory.instance(ThemeController.to.appTheme.value);
    // Гарантированная инициализация контроллера TodoEditCreatorController
    return GetBuilder<TodoEditCreateController>(
      init: TodoEditCreateController(),
      builder: (controller) => TodoRouteBase(
        widgetButton: themeFactory.button(
          onPressed: () {
            if (controller.createAndAddTodo()) {
              // После создание записи возвращаемся на предыдущий экран
              Get.back();
            }
          },
          child: const Text('Создать'),
        ),
      ),
    );
  }
}
