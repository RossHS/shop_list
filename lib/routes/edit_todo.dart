import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_list/controllers/controllers.dart';
import 'package:shop_list/controllers/todo/todo_service.dart';
import 'package:shop_list/models/models.dart';
import 'package:shop_list/widgets/themes_widgets/theme_dep.dart';
import 'package:shop_list/widgets/todo_route_base.dart';

/// Маршрут изменения списка дел
class EditTodo extends StatelessWidget {
  const EditTodo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final docId = Get.parameters['id'];
    final todoFuture = TodoService().findTodo(docId!);
    return FutureBuilder<TodoModel>(
      future: todoFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasData) {
          return GetBuilder<TodoEditCreateController>(
            init: TodoEditCreateController()..loadTodoToController(snapshot.requireData),
            builder: (controller) {
              return TodoRouteBase(
                widgetButton: ThemeDepButton(
                  onPressed: () {
                    if (controller.updateTodo(docId, snapshot.requireData)) {
                      // После создание записи возвращаемся на предыдущий экран
                      Get.back();
                    }
                  },
                  child: const Text('Обновить'),
                ),
              );
            },
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
