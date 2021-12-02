import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_list/controllers/info_overlay_controller.dart';
import 'package:shop_list/controllers/theme_controller.dart';
import 'package:shop_list/models/models.dart';
import 'package:shop_list/widgets/animated90s/animated_90s_painter_square.dart';
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
        const SizedBox(height: 20),
        const _SpecificThemeSettings(),
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

/// Панель с настройками для специфичных параметров тем, т.е. с каждой выбранной темой [ThemeDataWrapper],
/// будет отображаться свой уникальный набор настроек
/// TODO 02.12.2021 написать механизм настройки уникальных параметров тем!!!
class _SpecificThemeSettings extends StatefulWidget {
  const _SpecificThemeSettings({Key? key}) : super(key: key);

  @override
  State<_SpecificThemeSettings> createState() => _SpecificThemeSettingsState();
}

class _SpecificThemeSettingsState extends State<_SpecificThemeSettings> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Для анимирования размеров box, т.к. окна с настройками тем имеют различные размеры,
    // соответственно необходимо использовать анимацию, чтобы избежать "прыжок" в размере
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: GetX<ThemeController>(
        builder: (controller) {
          final themeFactory = ThemeFactory.instance(controller.appTheme.value);
          return AnimatedSwitcher(
            duration: const Duration(seconds: 1),
            switchInCurve: Curves.bounceOut,
            switchOutCurve: Curves.easeOutQuint,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(child: child, scale: animation);
            },
            // Использую метод buildWidget, а не определяю отдельный метод построения виджетов "настройки стиля"
            // в абстрактной фабрике, так как тесты показали, что Get.theme отдает не актуальный объект [ThemeData],
            // т.е. выглядит это так, что все "опаздывает" на один фрейм, к примеру, при установки текста в черный цвет
            // (когда изначально был белый), цвет в данных полях останется белым, а при изменении цвета темы со светлой на темную,
            // текст станет черным, а тема останется светлой, а при изменении следующего поля тема станет темной и т.д.
            // (hot reload обновляет тему до актуальной/верной)
            // Причем данная проблема наблюдается только на окне настройки, где необходим максимально быстрый отклик на изменения темы.
            // Мне кажется, что проблема кроется в том, что Get.theme где-то под капотом использует future
            // и я таким образом пролетаю до обновления ThemeData в Get.theme.
            //
            // Варианты решения.
            // 1) Глубоко разобраться с устройством внутреннего строения алгоритма Get.theme, возможно добавить callback,
            //  когда тема 100% обновилась, потом перестраивать нужные мне виджеты
            // 2) Использовать актуальный ThemeData из BuildContext.
            // 2.1) Переписать все методы абстрактной фабрики и передавать в каждый context в качестве аргумента.
            // 2.2) Использовать метод themeFactory.buildWidget и только тут использовать BuildContext.
            //  Или же создать отдельный виджеты, и не пользоваться фабрикой вовсе.
            //
            // Т.к. эта проблема беспокоит только лишь на окне настройки, то первый вариант отпадает из своей
            // излишней сложности. 2.1. тоже можно отбросить по этой же причине, плюс понадобиться изменять уже существующий рабочий код,
            // ради уникальной проблемы. Таким образом остается вариант 2.2, который я и реализовал.
            child: themeFactory.buildWidget(animated90s: (_, factory) {
              final themeWrapper = factory.themeWrapper;
              final config = themeWrapper.paint90sConfig.copyWith(backgroundColor: theme.canvasColor);
              return Padding(
                // Ключ, чтобы виджет AnimatedSwitcher понимал, когда запускать анимацию
                key: ValueKey<String>(controller.appTheme.value.themePrefix),
                padding: const EdgeInsets.all(10.0),
                child: AnimatedPainterSquare90s(
                  config: config,
                  child: Column(
                    children: [
                      Text(
                        'Настройки стиля',
                        style: theme.textTheme.headline5,
                      ),
                      const SizedBox(height: 10),
                      // Установка параметра StrokeWidth в теме [Animated90sThemeDataWrapper]
                      Text('Толщина - ${themeWrapper.paint90sConfig.strokeWidth.toStringAsFixed(2)}'),
                      Slider(
                        value: themeWrapper.paint90sConfig.strokeWidth,
                        min: 1,
                        max: 10,
                        onChanged: (double value) {
                          // По-хорошему следует вынести данную логику в [ThemeController], но не хочется его раздувать
                          // мелкими методами на каждый параметр
                          if (controller.appTheme.value is! Animated90sThemeDataWrapper) return;
                          final wrapper = factory.themeWrapper;
                          controller.appTheme.value = wrapper.copyWith(
                            paint90sConfig: wrapper.paint90sConfig.copyWith(strokeWidth: value),
                          );
                        },
                      ),
                      Text('Отступ - ${themeWrapper.paint90sConfig.offset}'),
                      Slider(
                        value: themeWrapper.paint90sConfig.offset.toDouble(),
                        min: 5,
                        max: 20,
                        onChanged: (double value) {
                          if (controller.appTheme.value is! Animated90sThemeDataWrapper) return;
                          final wrapper = factory.themeWrapper;
                          controller.appTheme.value = wrapper.copyWith(
                            paint90sConfig: wrapper.paint90sConfig.copyWith(offset: value.toInt()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }, material: (_, factory) {
              final themeWrapper = factory.themeWrapper;
              return Padding(
                key: ValueKey<String>(controller.appTheme.value.themePrefix),
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  height: 100,
                  width: 100,
                  color: Colors.red,
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
