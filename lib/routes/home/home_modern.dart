import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_list/controllers/controllers.dart';
import 'package:shop_list/models/models.dart';
import 'package:shop_list/utils/routes_transition.dart';
import 'package:shop_list/widgets/avatar.dart';
import 'package:shop_list/widgets/modern/modern.dart';
import 'package:shop_list/widgets/themes_widgets/theme_dep.dart';

/// Основное рабочее окно в теме [ModernThemeDataWrapper]
class HomeModern extends StatelessWidget {
  const HomeModern({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ThemeDepScaffold(
      body: const _Body(),
      // Т.к. данный маршрут уникальный для темы Modern, то и буду стараться использовать ее виджеты,
      // а не универсальные, ради повышения производительности
      floatingActionButton: TouchGetterProvider(
        child: ModernFloatingActionButton(
          onPressed: _openCreateTodo,
          child: const ModernIcon(Icons.create),
        ),
      ),
    );
  }

  void _openCreateTodo() {
    Get.toNamed('/createTodo');
  }
}

class _Body extends StatelessWidget {
  const _Body({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: const [
          Positioned(
            left: 20,
            top: 20,
            child: _ControlPanel(),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 100,
            ),
            child: Center(
              child: _TodoItem(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Панель с шорт-катами к маршрутам (Пользователя/Настройки/Сортировка)
class _ControlPanel extends StatelessWidget {
  const _ControlPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = AuthenticationController.instance;

    return TouchGetterProvider(
      child: ThemeDepCommonItemBox(
        child: Material(
          type: MaterialType.transparency,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Obx(() => authController.firestoreUser.value != null
                    ? GestureDetector(
                        onTap: () => Get.toNamed('/account'),
                        child: ClipOval(
                          child: Avatar(
                            diameter: 40,
                            user: authController.firestoreUser.value!,
                          ),
                        ),
                      )
                    : const SizedBox()),
              ),
              IconButton(
                onPressed: () => Get.toNamed('/settings'),
                icon: ThemeDepIcon.settings,
              ),
              IconButton(
                onPressed: () => Get.toNamed('/todosOrder'),
                icon: ThemeDepIcon.sort,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodoItem extends StatelessWidget {
  const _TodoItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ThemeDepCommonItemBox(
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }
}
