import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:shop_list/controllers/controllers.dart';
import 'package:shop_list/models/theme_model.dart';
import 'package:shop_list/utils/optional.dart';
import 'package:shop_list/utils/routes_transition.dart';
import 'package:shop_list/widgets/custom_settings/base_custom_settings.dart';
import 'package:shop_list/widgets/drag_and_set_offset.dart';
import 'package:shop_list/widgets/glassmorphism/glassmorphism.dart';
import 'package:shop_list/widgets/palette_color/palette_color_advanced_picker.dart';
import 'package:shop_list/widgets/slider_with_label.dart';
import 'package:shop_list/widgets/themes_widgets/theme_dep.dart';

class GlassmorphismCustomSettings extends StatefulWidget {
  const GlassmorphismCustomSettings({
    Key? key,
    required this.themeWrapper,
  }) : super(key: key);
  final GlassmorphismThemeDataWrapper themeWrapper;

  @override
  State<GlassmorphismCustomSettings> createState() => _GlassmorphismCustomSettingsState();
}

class _GlassmorphismCustomSettingsState extends State<GlassmorphismCustomSettings> {
  late final GlassmorphismCustomSettingsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(GlassmorphismCustomSettingsController(proxyThemeWrapper: widget.themeWrapper));
  }

  @override
  Widget build(BuildContext context) {
    // Вывел в локальную переменную, дабы не пересоздавать неизменяемые виджеты
    final child = Scaffold(
      backgroundColor: Colors.transparent,
      appBar: ThemeDepAppBar(
        title: const Text('Настройка фона'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: GlassmorphismBox(
                  child: ListView(
                    padding: const EdgeInsets.all(24.0),
                    addRepaintBoundaries: true,
                    shrinkWrap: true,
                    children: const [
                      Center(child: _GlassmorphismDecorationTypeSelector()),
                      SizedBox(height: 24),
                      AnimatedSize(
                        duration: Duration(milliseconds: 200),
                        curve: Curves.easeInOutCubic,
                        child: _GlassmorphismDecorationBody(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TouchGetterProvider(
              child: GlassmorphismButton(
                onPressed: () {
                  Get.back();
                  controller.acceptChanges();
                },
                child: const Text('Сохранить'),
              ),
            ),
          ),
        ],
      ),
    );
    return Obx(() => DecoratedBox(
          decoration: controller.proxyDataWrapper.value.backgroundDecoration,
          child: child,
        ));
  }
}

class _GlassmorphismDecorationBody extends StatelessWidget {
  const _GlassmorphismDecorationBody({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GlassmorphismCustomSettingsController>();
    final theme = Theme.of(context);
    return Obx(() {
      final glassmorphismProxy = controller.proxyDataWrapper.value;
      final Widget child;

      /// Набор потенциальных настроек
      if (_isJustColor(glassmorphismProxy.backgroundDecoration)) {
        child = ColorPicker(
          labelTypes: const [],
          enableAlpha: false,
          displayThumbColor: false,
          colorPickerWidth: 300,
          paletteType: PaletteType.hueWheel,
          pickerColor: glassmorphismProxy.backgroundDecoration.color!,
          onColorChanged: (color) => controller._updateJustColor(color: color),
        );
      } else if (_isLinearGradient(glassmorphismProxy.backgroundDecoration)) {
        final linearGradient = glassmorphismProxy.backgroundDecoration.gradient as LinearGradient;
        child = Column(
          key: const ValueKey('linear'),
          children: [
            ListTile(
              title: const Text('TileMode'),
              trailing: ThemeDepDropdownButton(
                value: linearGradient.tileMode,
                items: TileMode.values
                    .map<DropdownMenuItem<TileMode>>((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                    .toList(),
                onChanged: (TileMode? tileMode) => controller._updateLinearGradient(tileMode: tileMode!),
              ),
            ),
            // Перехватка скролл событий, чтоб нельзя было прокрутить [ListView]
            // случайно промахнувшись и схватившись за поле, а не за элемент
            GestureDetector(
              onHorizontalDragStart: (_) {},
              onVerticalDragStart: (_) {},
              child: DragAndSetOffset(
                backgroundColor: theme.canvasColor.withOpacity(0.24),
                children: [
                  DragOffsetChild.alignment(
                    alignment: linearGradient.begin as Alignment,
                    callback: (alignment) {
                      controller._updateLinearGradient(begin: alignment);
                    },
                  ),
                  DragOffsetChild.alignment(
                    alignment: linearGradient.end as Alignment,
                    callback: (alignment) {
                      controller._updateLinearGradient(end: alignment);
                    },
                  ),
                ],
              ),
            ),
            PaletteColorAdvancedPicker(
              colors: linearGradient.colors,
              onChange: (colors) {
                controller._updateLinearGradient(colors: colors);
              },
            ),
          ],
        );
      } else if (_isRadialGradient(glassmorphismProxy.backgroundDecoration)) {
        final radialGradient = glassmorphismProxy.backgroundDecoration.gradient as RadialGradient;
        child = Column(
          key: const ValueKey('radial'),
          children: [
            ListTile(
              title: const Text('TileMode'),
              trailing: ThemeDepDropdownButton(
                value: radialGradient.tileMode,
                items: TileMode.values
                    .map<DropdownMenuItem<TileMode>>((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                    .toList(),
                onChanged: (TileMode? tileMode) => controller._updateRadialGradient(tileMode: tileMode!),
              ),
            ),
            CheckboxListTile(
              title: const Text('Фокус'),
              value: radialGradient.focal != null,
              onChanged: (value) {
                controller._updateRadialGradient(
                  focal: Optional(value == true ? Alignment.center : null),
                );
              },
            ),
            // Перехватка скролл событий, чтоб нельзя было прокрутить [ListView]
            // случайно промахнувшись и схватившись за поле, а не за элемент
            GestureDetector(
              onHorizontalDragStart: (_) {},
              onVerticalDragStart: (_) {},
              child: DragAndSetOffset(
                backgroundColor: theme.canvasColor.withOpacity(0.24),
                children: [
                  DragOffsetChild.alignment(
                    alignment: radialGradient.center as Alignment,
                    callback: (alignment) {
                      controller._updateRadialGradient(center: alignment);
                    },
                  ),
                  if (radialGradient.focal != null)
                    DragOffsetChild.alignment(
                      alignment: (radialGradient.focal as Alignment),
                      callback: (alignment) {
                        controller._updateRadialGradient(
                          focal: Optional<Alignment>(alignment),
                        );
                      },
                    ),
                ],
              ),
            ),
            SliderWithLabel(
              label: const Text('Радиус'),
              value: radialGradient.radius,
              min: 0,
              max: 1,
              onChange: (radius) {
                controller._updateRadialGradient(radius: radius);
              },
            ),
            const SizedBox(height: 5),
            SliderWithLabel(
              label: const Text('Фоксн. радиус'),
              value: radialGradient.focalRadius,
              min: 0,
              max: 5,
              onChange: (focalRadius) {
                controller._updateRadialGradient(focalRadius: focalRadius);
              },
            ),
            PaletteColorAdvancedPicker(
              colors: radialGradient.colors,
              onChange: (colors) {
                controller._updateRadialGradient(colors: colors);
              },
            ),
          ],
        );
      } else {
        child = const SizedBox(width: 300, height: 10);
      }

      return AnimatedSwitcher(
        duration: const Duration(seconds: 1),
        switchInCurve: Curves.easeOutCirc,
        switchOutCurve: Curves.easeInCirc,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(child: child, scale: animation);
        },
        child: child,
      );
    });
  }
}

/// Выбор типа декорации
class _GlassmorphismDecorationTypeSelector extends StatefulWidget {
  const _GlassmorphismDecorationTypeSelector({
    Key? key,
  }) : super(key: key);

  @override
  State<_GlassmorphismDecorationTypeSelector> createState() => _GlassmorphismDecorationTypeSelectorState();
}

/// Все допустимые варианты стиля DecorationBox
enum _DecorationType { color, linearGradient, radialGradient }

class _GlassmorphismDecorationTypeSelectorState extends State<_GlassmorphismDecorationTypeSelector> {
  late final Map<_DecorationType, BoxDecoration> decorations;
  late _DecorationType selectedType;
  late final GlassmorphismCustomSettingsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<GlassmorphismCustomSettingsController>();
    decorations = const <_DecorationType, BoxDecoration>{
      _DecorationType.color: BoxDecoration(
        color: Colors.red,
      ),
      _DecorationType.linearGradient: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [Colors.red, Colors.blue],
        ),
      ),
      _DecorationType.radialGradient: BoxDecoration(
        gradient: RadialGradient(
          colors: [Colors.red, Colors.blue],
        ),
      ),
    };

    final initDecoration = controller.proxyDataWrapper.value.backgroundDecoration;
    if (_isJustColor(initDecoration)) {
      selectedType = _DecorationType.color;
    } else if (_isLinearGradient(initDecoration)) {
      selectedType = _DecorationType.linearGradient;
    } else if (_isRadialGradient(initDecoration)) {
      selectedType = _DecorationType.radialGradient;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ToggleButtons(
        children: decorations.values
            .map((decoration) => Ink(
                  width: 70,
                  height: 50,
                  decoration: decoration,
                ))
            .toList(),
        borderRadius: BorderRadius.circular(20),
        borderWidth: 3,
        selectedBorderColor: Theme.of(context).canvasColor,
        isSelected: decorations.keys.map((type) => type == selectedType).toList(),
        onPressed: (index) {
          final newType = decorations.keys.toList()[index];
          if (selectedType != newType) {
            controller.proxyDataWrapper.value =
                controller.proxyDataWrapper.value.copyWith(backgroundDecoration: decorations[newType]);
            setState(() {
              selectedType = newType;
            });
          }
        },
      ),
    );
  }
}

/// Контроллер тонкой настройки темы [GlassmorphismThemeDataWrapper], содержащий в себе временные изменения темы.
/// Для принятия изменений следует вызывать метод [acceptChanges]
class GlassmorphismCustomSettingsController extends CustomSettingsController {
  GlassmorphismCustomSettingsController({
    required GlassmorphismThemeDataWrapper proxyThemeWrapper,
  }) : proxyDataWrapper = proxyThemeWrapper.obs;

  final Rx<GlassmorphismThemeDataWrapper> proxyDataWrapper;

  @override
  void acceptChanges() {
    final themeController = Get.find<ThemeController>();
    final proxy = proxyDataWrapper.value;
    themeController.updateGlassmorphismThemeData(
      backgroundDecoration: proxy.backgroundDecoration,
    );
  }

  /// Обновление цвета [BoxDecoration]
  void _updateJustColor({Color? color}) {
    // Проверка служит защитой от того, что пользователь в момент переключения
    // анимации виджетов может залочить их в полу-позиции
    if (_isJustColor(proxyDataWrapper.value.backgroundDecoration)) {
      proxyDataWrapper.value = proxyDataWrapper.value.copyWith(
        backgroundDecoration: BoxDecoration(color: color),
      );
    }
  }

  /// Установка [LinearGradient] градиенты в [BoxDecoration]
  void _updateLinearGradient({
    AlignmentGeometry? begin,
    AlignmentGeometry? end,
    List<Color>? colors,
    List<double>? stops,
    TileMode? tileMode,
  }) {
    if (_isLinearGradient(proxyDataWrapper.value.backgroundDecoration)) {
      final gradient = proxyDataWrapper.value.backgroundDecoration.gradient as LinearGradient;
      proxyDataWrapper.value = proxyDataWrapper.value.copyWith(
        backgroundDecoration: BoxDecoration(
          gradient: LinearGradient(
            begin: begin ?? gradient.begin,
            end: end ?? gradient.end,
            colors: colors ?? gradient.colors,
            stops: stops ?? gradient.stops,
            tileMode: tileMode ?? gradient.tileMode,
          ),
        ),
      );
    }
  }

  /// Установка [RadialGradient] градиенты в [BoxDecoration]
  ///
  /// Использую [Optional], т.к. иногда требуется перезаписать значение на null,
  /// но стандартная форма использования Alignment? не подходит, т.к. при наличии
  /// null аргумента [focal] будет использоваться значение из клонируемого объекта,
  /// что закрывает нам возможность обнуления поля
  void _updateRadialGradient({
    Alignment? center,
    Optional<Alignment?>? focal,
    double? focalRadius,
    double? radius,
    List<Color>? colors,
    TileMode? tileMode,
  }) {
    if (_isRadialGradient(proxyDataWrapper.value.backgroundDecoration)) {
      final gradient = proxyDataWrapper.value.backgroundDecoration.gradient as RadialGradient;
      proxyDataWrapper.value = proxyDataWrapper.value.copyWith(
        backgroundDecoration: BoxDecoration(
          gradient: RadialGradient(
            center: center ?? gradient.center,
            focal: focal != null ? focal.value : gradient.focal,
            focalRadius: focalRadius ?? gradient.focalRadius,
            radius: radius ?? gradient.radius,
            colors: colors ?? gradient.colors,
            tileMode: tileMode ?? gradient.tileMode,
          ),
        ),
      );
    }
  }
}

///Специально не делаю доп проверки внутри (на наличие цвета и градиенты), т.к. документация [BoxDecoration]
/// явно гласит - наличие одновременно параметров color и gradient недопустимо - возникнет runtime error
bool _isJustColor(BoxDecoration decoration) => decoration.color != null;

bool _isLinearGradient(BoxDecoration decoration) => decoration.gradient is LinearGradient;

bool _isRadialGradient(BoxDecoration decoration) => decoration.gradient is RadialGradient;
