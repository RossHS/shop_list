import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_list/controllers/info_overlay_controller.dart';
import 'package:shop_list/controllers/theme_controller.dart';
import 'package:shop_list/models/models.dart';
import 'package:shop_list/utils/routes_transition.dart';
import 'package:shop_list/widgets/animated90s/animated_90s_painter_square.dart';
import 'package:shop_list/widgets/animated_decorated_box.dart';
import 'package:shop_list/widgets/custom_settings/glassmorphism_custom_settings.dart';
import 'package:shop_list/widgets/custom_settings/material_custom_settings.dart';
import 'package:shop_list/widgets/glassmorphism/glassmorphism.dart';
import 'package:shop_list/widgets/palette_color/palette_color_customizer_picker.dart';
import 'package:shop_list/widgets/palette_color/palette_color_selector.dart';
import 'package:shop_list/widgets/themes_widgets/theme_dep.dart';

/// Маршрут настройки тем приложения
class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

/// Виджет stateful, т.к. я использую [GlobalKey], который не рекомендуется создавать внутри метода build,
/// комментарии из исходного кода :
///
/// ## Pitfalls
///
/// GlobalKeys should not be re-created on every build. They should usually be
/// long-lived objects owned by a [State] object, for example.
///
/// Creating a new GlobalKey on every build will throw away the state of the
/// subtree associated with the old key and create a new fresh subtree for the
/// new key. Besides harming performance, this can also cause unexpected
/// behavior in widgets in the subtree. For example, a [GestureDetector] in the
/// subtree will be unable to track ongoing gestures since it will be recreated
/// on each build.
class _SettingsState extends State<Settings> {
  final scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return ThemeDepScaffold(
      scaffoldGlobalKey: scaffoldKey,
      appBar: ThemeDepAppBar(
        title: const Text('Настройка темы'),
      ),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final controller = ThemeController.to;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        ListTile(
          title: const Text('Стиль'),
          trailing: Obx(
            () => ThemeDepDropdownButton<String>(
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
            () => ThemeDepDropdownButton<TextTheme>(
              value: controller.textTheme.value,
              items: TextThemeCollection.map.entries.map<DropdownMenuItem<TextTheme>>((entry) {
                final entryTextStyle = entry.value.subtitle1!;
                var style = TextStyle(
                  fontSize: entryTextStyle.fontSize ?? 15,
                  fontFamily: entryTextStyle.fontFamily,
                );
                return DropdownMenuItem(
                  value: entry.value,
                  child: Text(
                    entry.key,
                    style: style,
                  ),
                );
              }).toList(),
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
            () => ThemeDepDropdownButton<ThemeMode>(
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
        const _ColorPaletteBox(),
        const SizedBox(height: 20),
        const _SpecificThemeSettings(),
      ],
    );
  }
}

/// Ряд с кнопками для вызова различных контекстных виджетов (оповещение/snackbar/dialog)
class _ButtonsRow extends StatelessWidget {
  const _ButtonsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ThemeDepButton(
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
          child: ThemeDepButton(
              onPressed: () {
                ThemeDepDialog(
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
  }
}

/// Виджет содержащий в себе все варианты цветовых схем для каждой из тем [ThemeDataWrapper]
class _ColorPaletteBox extends StatelessWidget {
  const _ColorPaletteBox();

  final paletteDiameter = 44.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Цветовые схемы дневных тем
        ConstrainedBox(
          constraints: BoxConstraints.expand(width: double.infinity, height: paletteDiameter),
          child: Obx(() {
            // Переписал код ListView с использованием Padding на ListView.separated
            final widgets = <Widget>[
              _CircleContainer(
                diameter: paletteDiameter,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.wb_sunny,
                  color: Colors.orange.shade600,
                ),
              ),
              // Те, в которых можно настраивать цвета
              ...ThemeController.to.appTheme.value.lightColorSchemesMap.entries
                  .where((element) => element.key.contains('custom'))
                  .map<Widget>((entry) => _ColorPaletteItem(
                        key: ValueKey<ColorScheme>(entry.value),
                        colorScheme: entry.value,
                        paletteDiameter: paletteDiameter,
                        isSelected: ThemeController.to.appTheme.value.lightColorScheme == entry.value,
                        onPressed: (colorScheme) {
                          _customizeLightColorSchemeAction(colorScheme, entry.key);
                        },
                        child: const Icon(Icons.settings_outlined),
                      ))
                  .toList(),
              ...ThemeController.to.appTheme.value.lightColorSchemesMap.entries
                  .where((element) => element.key.contains('default'))
                  .map<Widget>((entry) => _ColorPaletteItem(
                        key: ValueKey<ColorScheme>(entry.value),
                        colorScheme: entry.value,
                        paletteDiameter: paletteDiameter,
                        isSelected: ThemeController.to.appTheme.value.lightColorScheme == entry.value,
                        onPressed: ThemeController.to.setLightColorScheme,
                      ))
                  .toList(),
            ];
            return ListView.separated(
              scrollDirection: Axis.horizontal,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemCount: widgets.length,
              itemBuilder: (context, index) => widgets[index],
            );
          }),
        ),
        const SizedBox(height: 10),
        // Цветовые схемы ночных тем
        ConstrainedBox(
          constraints: BoxConstraints.expand(width: double.infinity, height: paletteDiameter),
          child: Obx(() {
            final widgets = <Widget>[
              _CircleContainer(
                diameter: paletteDiameter,
                backgroundColor: const Color(0xFF303030),
                child: const Icon(
                  Icons.mode_night,
                  color: Colors.white,
                ),
              ),
              // Те, в которых можно настраивать цвета
              ...ThemeController.to.appTheme.value.darkColorSchemesMap.entries
                  .where((element) => element.key.contains('custom'))
                  .map<Widget>((entry) => _ColorPaletteItem(
                        key: ValueKey<ColorScheme>(entry.value),
                        colorScheme: entry.value,
                        paletteDiameter: paletteDiameter,
                        isSelected: ThemeController.to.appTheme.value.darkColorScheme == entry.value,
                        onPressed: (colorScheme) {
                          _customizeDarkColorSchemeAction(colorScheme, entry.key);
                        },
                        child: const Icon(Icons.settings_outlined),
                      ))
                  .toList(),
              // Обычные цветовые схемы
              ...ThemeController.to.appTheme.value.darkColorSchemesMap.entries
                  .where((element) => element.key.contains('default'))
                  .map<Widget>((entry) => _ColorPaletteItem(
                        key: ValueKey<ColorScheme>(entry.value),
                        colorScheme: entry.value,
                        paletteDiameter: paletteDiameter,
                        isSelected: ThemeController.to.appTheme.value.darkColorScheme == entry.value,
                        onPressed: ThemeController.to.setDarkColorScheme,
                      ))
                  .toList(),
            ];
            return ListView.separated(
              scrollDirection: Axis.horizontal,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemCount: widgets.length,
              itemBuilder: (context, index) => widgets[index],
            );
          }),
        ),
      ],
    );
  }

  void _customizeDarkColorSchemeAction(ColorScheme? colorScheme, String key) {
    if (colorScheme == null) return;
    final themeWrapper = ThemeController.to.appTheme.value;
    if (themeWrapper.darkColorScheme != colorScheme) {
      ThemeController.to.setDarkColorScheme(colorScheme, key: key);
    } else {
      _changeColorDialog(
        onColorSave: (newColorScheme) {
          ThemeController.to.setDarkColorScheme(newColorScheme, key: key);
        },
        colorScheme: ThemeController.to.appTheme.value.darkColorScheme,
      );
    }
  }

  void _customizeLightColorSchemeAction(ColorScheme? colorScheme, String key) {
    if (colorScheme == null) return;
    final themeWrapper = ThemeController.to.appTheme.value;
    if (themeWrapper.lightColorScheme != colorScheme) {
      ThemeController.to.setLightColorScheme(colorScheme, key: key);
    } else {
      ThemeController.to.appTheme.value.lightColorScheme;
      _changeColorDialog(
        onColorSave: (newColorScheme) {
          ThemeController.to.setLightColorScheme(newColorScheme, key: key);
        },
        colorScheme: ThemeController.to.appTheme.value.lightColorScheme,
      );
    }
  }

  void _changeColorDialog({
    required void Function(ColorScheme newColorScheme) onColorSave,
    required ColorScheme colorScheme,
  }) {
    final appTheme = ThemeController.to.appTheme.value;
    // Хотел создать отдельный класс с билдером, оберткой и т.п. (все по правильному),
    // но не стал ради одного участка кода совершать Overkill
    ColorChangeController colorController;
    ColorScheme Function() generateColorScheme;
    if (appTheme is GlassmorphismThemeDataWrapper) {
      colorController = ColorChangeController(
        colors: {
          'Основной': colorScheme.primary,
        },
      );
      generateColorScheme = () {
        final mainColor = colorController.colors['Основной']!.color;
        return colorScheme.copyWith(
          primary: mainColor,
          primaryContainer: mainColor,
          secondary: mainColor,
          secondaryContainer: mainColor,
          background: mainColor,
          surface: mainColor,
          error: Colors.redAccent,
        );
      };
    } else {
      colorController = ColorChangeController(
        colors: {
          'Основной': colorScheme.primary,
          'Фон': colorScheme.background,
        },
      );
      generateColorScheme = () {
        final mainColor = colorController.colors['Основной']!.color;
        final backgroundColor = colorController.colors['Фон']!.color;
        return colorScheme.copyWith(
          primary: mainColor,
          primaryContainer: mainColor,
          secondary: mainColor,
          secondaryContainer: mainColor,
          background: backgroundColor,
          surface: mainColor,
          error: Colors.redAccent,
        );
      };
    }

    ThemeDepDialog(
      // т.к. создается отдельное дерево в котором требуется определение Material виджета,
      // если его не задать тут, то получим исключение
      content: Material(
        color: Colors.transparent,
        child: PaletteColorCustomizerPicker(
          controller: colorController,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            onColorSave(generateColorScheme());
            Get.back();
          },
          child: const Text('Сохранить'),
        ),
        TextButton(
          onPressed: Get.back,
          child: const Text('Отменить'),
        ),
      ],
    );
  }
}

/// Виджет выбора цвета
class _ColorPaletteItem extends StatelessWidget {
  const _ColorPaletteItem({
    super.key,
    required this.colorScheme,
    required this.paletteDiameter,
    required this.onPressed,
    required this.isSelected,
    this.child,
  });

  final ColorScheme colorScheme;
  final double paletteDiameter;
  final void Function(ColorScheme? colorScheme) onPressed;
  final bool isSelected;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return AnimatedDecoration(
      duration: const Duration(milliseconds: 200),
      decoration: isSelected
          ? BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 10,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary,
                  blurRadius: 10.0,
                ),
              ],
            )
          : const BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  spreadRadius: 0,
                  color: Colors.transparent,
                  blurRadius: 0,
                ),
              ],
            ),
      child: PaletteColorSelector(
        onPressed: () {
          onPressed(colorScheme);
        },
        paletteDiameter: paletteDiameter,
        mainColor: colorScheme.background,
        additionColor: colorScheme.primary,
        child: child,
      ),
    );
  }
}

class _CircleContainer extends StatelessWidget {
  const _CircleContainer({
    this.child,
    this.backgroundColor,
    this.diameter,
  });

  final Color? backgroundColor;
  final Widget? child;
  final double? diameter;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: diameter,
      width: diameter,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: child,
      ),
    );
  }
}

/// Панель с настройками для специфичных параметров тем, т.е. с каждой выбранной темой [ThemeDataWrapper],
/// будет отображаться свой уникальный набор настроек
class _SpecificThemeSettings extends StatelessWidget {
  const _SpecificThemeSettings();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Для анимирования размеров box, т.к. окна с настройками тем имеют различные размеры,
    // соответственно необходимо использовать анимацию, чтобы избежать "прыжок" в размере
    final textColor = theme.canvasColor.calcTextColor;
    // На основании уже существующей стандартной темы формируем новую с учетом цвета фона родителя,
    // так, чтобы текст не сливался с фоном
    final adaptedTextTheme = theme.textTheme.apply(bodyColor: textColor);
    final controller = ThemeController.to;
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ThemeDepAnimatedSwitcher(
          duration: const Duration(seconds: 1),
          switchInCurve: Curves.bounceOut,
          switchOutCurve: Curves.easeOutQuint,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          animated90s: (_, themeWrapper, __) {
            // Как бы не хотелось использоваться виджет [ThemeDepCommonItemBox], но не выйдет,
            // т.к. он внутри имеет GetX<ThemeController>, который сменит отображение внешнего
            // контейнера до окончания анимации
            final config = themeWrapper.paint90sConfig.copyWith(backgroundColor: theme.canvasColor);
            return DefaultTextStyle(
              key: const ValueKey('animated'),
              style: adaptedTextTheme.bodyText2!,
              child: AnimatedPainterSquare90s(
                duration: themeWrapper.animationDuration,
                config: config,
                child: Column(
                  children: [
                    Text(
                      'Настройки стиля',
                      style: adaptedTextTheme.headline5,
                    ),
                    const SizedBox(height: 10),
                    // Установка параметра StrokeWidth в теме [Animated90sThemeDataWrapper]
                    Text('Толщина - ${themeWrapper.paint90sConfig.strokeWidth.toStringAsFixed(2)}'),
                    Slider(
                      value: themeWrapper.paint90sConfig.strokeWidth,
                      min: 1,
                      max: 10,
                      onChanged: (double strokeWidth) {
                        controller.updateAnimated90sThemeData(strokeWidth: strokeWidth);
                      },
                    ),
                    Text('Отступ - ${themeWrapper.paint90sConfig.offset}'),
                    Slider(
                      value: themeWrapper.paint90sConfig.offset.toDouble(),
                      min: 5,
                      max: 20,
                      onChanged: (double offset) {
                        controller.updateAnimated90sThemeData(offset: offset.toInt());
                      },
                    ),
                    Text('Анимация - ${themeWrapper.animationDuration.inMilliseconds}'),
                    Slider(
                      value: themeWrapper.animationDuration.inMilliseconds.toDouble(),
                      min: 40,
                      max: 300,
                      onChanged: (double millisDuration) {
                        controller.updateAnimated90sThemeData(
                          animationDuration: Duration(milliseconds: millisDuration.toInt()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
          material: (context, themeWrapper, __) {
            return DefaultTextStyle(
              key: const ValueKey('material'),
              style: adaptedTextTheme.bodyText2!,
              child: Container(
                decoration: themeWrapper.buildDefaultBoxDecoration(context),
                child: Column(
                  children: [
                    Text(
                      'Настройки стиля',
                      style: adaptedTextTheme.headline5,
                    ),
                    const SizedBox(height: 10),
                    Text('Скругление - ${themeWrapper.rounded.toStringAsFixed(2)}'),
                    Slider(
                      value: themeWrapper.rounded,
                      min: 0,
                      max: 30,
                      onChanged: (double rounded) {
                        controller.updateMaterialThemeData(rounded: rounded);
                      },
                    ),
                    Text('Радиус тени - ${themeWrapper.shadowBlurRadius.toStringAsFixed(2)}'),
                    Slider(
                      value: themeWrapper.shadowBlurRadius,
                      min: 0,
                      max: 20,
                      onChanged: (double shadowBlurRadius) {
                        controller.updateMaterialThemeData(shadowBlurRadius: shadowBlurRadius);
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      // Вызов диалогового окна настройки параметров темы
                      child: ElevatedButton(
                        onPressed: () {
                          final controller = MaterialCustomSettingsController(proxyThemeWrapper: themeWrapper);
                          ThemeDepDialog(
                            content: Material(
                              color: Colors.transparent,
                              child: MaterialCustomSettings(
                                controller: controller,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Get.back();
                                  controller.acceptChanges();
                                },
                                child: const Text('Сохранить'),
                              ),
                              TextButton(
                                onPressed: Get.back,
                                child: const Text('Отменить'),
                              ),
                            ],
                          );
                        },
                        child: const Text('Настройка теней'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          glassmorphism: (_, themeWrapper, __) {
            return GlassmorphismBox(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Text(
                      'Настройки стиля',
                      style: theme.textTheme.headline5,
                    ),
                    const SizedBox(height: 20),
                    TouchGetterProvider(
                      child: TextButton.icon(
                        onPressed: () {
                          Get.to(() => GlassmorphismCustomSettings(
                                themeWrapper: themeWrapper,
                              ));
                        },
                        icon: const GlassmorphismIcon(Icons.settings),
                        label: const Text('Настройка фона'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
