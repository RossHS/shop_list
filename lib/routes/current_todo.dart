import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_list/controllers/controllers.dart';
import 'package:shop_list/custom_icons.dart';
import 'package:shop_list/widgets/animated90s/animated_90s.dart';

/// Окно текущей задачи, которую выбрал пользователь
class CurrentTodo extends StatelessWidget {
  const CurrentTodo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final docId = Get.parameters['id'];
    final TodoViewController viewController = TodoViewController();
    return GetBuilder<TodoViewController>(
        init: viewController,
        initState: (_) {
          viewController.loadTodoModel(docId!);
        },
        builder: (controller) => Obx(() {
              Widget? body;
              String appBarTitle = '';
              // В зависимости от текущего статуса загрузки списка дел строится подобающее дерево
              switch (controller.state) {
                case TodoViewCurrentState.unknown:
                  appBarTitle = 'Неизвестно';
                  body = const Center(
                    child: CircularProgressIndicator(),
                  );
                  break;
                case TodoViewCurrentState.loading:
                  appBarTitle = 'Загрузка';
                  body = const Center(
                    child: CircularProgressIndicator(),
                  );
                  break;
                case TodoViewCurrentState.error:
                  appBarTitle = 'Ошибка';
                  body = const Center(
                    child: Text('Ошибка загрузки'),
                  );
                  break;
                case TodoViewCurrentState.loaded:
                  appBarTitle = '${controller.todoModel?.title}';
                  body = const _LoadedWidget();
              }
              return Scaffold(
                appBar: AnimatedAppBar90s(
                  title: Text(appBarTitle),
                  leading: IconButton(
                    onPressed: Get.back,
                    icon: const AnimatedIcon90s(
                      iconsList: CustomIcons.arrow,
                    ),
                  ),
                ),
                body: body,
              );
            }));
  }
}

/// Основное тело виджета при успешной загрузки модели списка дел
class _LoadedWidget extends StatelessWidget {
  const _LoadedWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Column(
      children: [
        Expanded(
          child: GetBuilder<TodoViewController>(
            builder: (controller) => ListView.builder(
              shrinkWrap: true,
              itemCount: controller.todoModel!.elements.length,
              itemBuilder: (context, index) {
                final element = controller.todoModel!.elements[index];
                return ListTile(
                  key: ObjectKey(element),
                  onTap: () {
                    controller.changeTodoElementCompleteStatus(isCompleted: !element.completed, uid: element.uid);
                  },
                  title: Text(
                    element.name,
                    style: textTheme.bodyText2?.copyWith(
                      decoration: element.completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  trailing: element.completed ? const FlutterLogo() : null,
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: AnimatedButton90s(
            onPressed: _completeTodo,
            child: const Text('Завершить'),
          ),
        ),
      ],
    );
  }

  void _completeTodo() {}
}
