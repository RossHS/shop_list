import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_list/controllers/controllers.dart';
import 'package:shop_list/widgets/themes_widgets/theme_dep.dart';
import 'package:shop_list/widgets/todo_route_base.dart';

class CreateTodo extends StatelessWidget {
  const CreateTodo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Гарантированная инициализация контроллера TodoEditCreatorController
    return GetBuilder<TodoEditCreateController>(
      init: TodoEditCreateController(),
      builder: (controller) => TodoRouteBase(
        widgetButton: ThemeDepButton(
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
