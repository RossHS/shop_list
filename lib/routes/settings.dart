import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_list/controllers/theme_controller.dart';
import 'package:shop_list/custom_icons.dart';
import 'package:shop_list/models/models.dart';
import 'package:shop_list/widgets/animated90s/animated_90s.dart';

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
          // TODO 24.11.2021 придумать способ организации виджетов зависящих от темы. Скорее всего просто использовать фабрику, фабричный метод или что-то на подобии
          PreferredSizeWidget appBar = controller.appTheme.value is Animated90sThemeData
              ? AnimatedAppBar90s(
                  title: const Text('Настройки темы'),
                  leading: IconButton(
                    onPressed: Get.back,
                    icon: const AnimatedIcon90s(
                      iconsList: CustomIcons.arrow,
                    ),
                  ),
                )
              : AppBar(
                  title: const Text('Настройки темы'),
                );
          return Scaffold(
            appBar: appBar,
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
          title: const _Title('Стиль'),
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
          title: const _Title('Шрифт'),
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
          title: const _Title('Тема'),
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
