import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_list/controllers/info_overlay_controller.dart';
import 'package:shop_list/controllers/theme_controller.dart';
import 'package:shop_list/models/models.dart';
import 'package:shop_list/widgets/themes_factories/abstract_theme_factory.dart';

/// Маршрут настройки тем приложения
class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (controller) {
        // Obx - для перестроения темы маршрута. Нужен только здесь,
        // так как в других частях приложения не будет динамически изменяться тема
        return Obx(() {
          return Scaffold(
            appBar: ThemeFactory.instance(controller.appTheme.value).appBar(
              title: const Text('Настройка темы'),
            ),
            body: const _Body(),
          );
        });
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = ThemeController.to;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        ListTile(
          title: const Text('Стиль'),
          trailing: Obx(
            () => DropdownButton<String>(
              value: controller.appTheme.value.themePrefix,
              items: controller.appThemeList
                  .map<DropdownMenuItem<String>>((value) => DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      ))
                  .toList(),
              onChanged: controller.setAppTheme,
            ),
          ),
        ),
        ListTile(
          title: const Text('Шрифт'),
          trailing: Obx(
            () => DropdownButton<TextTheme>(
              value: controller.textTheme.value,
              items: TextThemeCollection.map.entries
                  .map<DropdownMenuItem<TextTheme>>((entry) => DropdownMenuItem(
                        value: entry.value,
                        child: Text(entry.key),
                      ))
                  .toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  controller.textTheme.value = newValue;
                }
              },
            ),
          ),
        ),
        ListTile(
          title: const Text('Тема'),
          trailing: Obx(
            () => DropdownButton<ThemeMode>(
              value: controller.themeMode.value,
              items: ThemeMode.values
                  .map<DropdownMenuItem<ThemeMode>>((themeMode) => DropdownMenuItem(
                        value: themeMode,
                        child: Text(themeMode.name),
                      ))
                  .toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  controller.themeMode.value = newValue;
                }
              },
            ),
          ),
        ),
        const _ButtonsRow(),
      ],
    );
  }
}

/// Ряд с кнопками для вызова различных контекстных виджетов (оповещение/snackbar/dialog)
class _ButtonsRow extends StatelessWidget {
  const _ButtonsRow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<ThemeController>(
      builder: (controller) {
        final themeFactory = ThemeFactory.instance(controller.appTheme.value);
        return Row(
          children: [
            Expanded(
              child: themeFactory.button(
                  onPressed: () {
                    CustomInfoOverlay.show(
                      title: 'Заголовок',
                      msg: 'Текст Сообщения',
                      child: TextButton(onPressed: () {}, child: const Text('Кнопка')),
                    );
                  },
                  child: const Text('Оповещение')),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: themeFactory.button(
                  onPressed: () {
                    themeFactory.showDialog(
                      text: 'Заголовок диалога',
                      actions: [
                        TextButton(onPressed: () {}, child: const Text('OK')),
                        TextButton(onPressed: () {}, child: const Text('Отменить')),
                      ],
                    );
                  },
                  child: const Text('Диалог')),
            ),
          ],
        );
      },
    );
  }
}
