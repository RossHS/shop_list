import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_list/controllers/theme_controller.dart';
import 'package:shop_list/models/models.dart';
import 'package:shop_list/widgets/animated90s/animated_90s.dart';

/// Маршрут настройки тем приложения
class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: AnimatedAppBar90s(
        title: Text('Настройки темы'),
      ),
      body: _Body(),
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
        Obx(
          () => ListTile(
            title: const _Title('Стиль'),
            trailing: DropdownButton<ThemeDataWrapper>(
              value: controller.appTheme.value,
              items: controller.appThemeList
                  .map<DropdownMenuItem<ThemeDataWrapper>>((value) => DropdownMenuItem(
                        value: value,
                        child: Text(value.themePrefix),
                      ))
                  .toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  controller.appTheme.value = newValue;
                }
              },
            ),
          ),
        ),
        Obx(() => ListTile(
              title: const _Title('Тема'),
              trailing: DropdownButton<ThemeMode>(
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
            )),
      ],
    );
  }
}

/// Заголовок в ListTile с настройкой
/// TODO 23.11.2021 если не придумаю толкового применения то удалю
class _Title extends StatelessWidget {
  const _Title(this.title, {Key? key}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    return Text(
      title,
      // style: theme.textTheme.headline5,
      // textAlign: TextAlign.center,
    );
  }
}
