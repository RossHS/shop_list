import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:shop_list/controllers/controllers.dart';
import 'package:shop_list/models/theme_model.dart';
import 'package:shop_list/utils/routes_transition.dart';
import 'package:shop_list/widgets/custom_settings/base_custom_settings.dart';
import 'package:shop_list/widgets/drag_and_set_offset.dart';
import 'package:shop_list/widgets/modern/modern.dart';
import 'package:shop_list/widgets/themes_widgets/theme_dep.dart';

class ModernCustomSettings extends StatefulWidget {
  const ModernCustomSettings({
    Key? key,
    required this.themeWrapper,
  }) : super(key: key);
  final ModernThemeDataWrapper themeWrapper;

  @override
  State<ModernCustomSettings> createState() => _ModernCustomSettingsState();
}

class _ModernCustomSettingsState extends State<ModernCustomSettings> {
  late final ModernCustomSettingsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ModernCustomSettingsController(proxyThemeWrapper: widget.themeWrapper));
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
                child: ModernGlassMorph(
                  child: ListView(
                    padding: const EdgeInsets.all(24.0),
                    addRepaintBoundaries: true,
                    shrinkWrap: true,
                    children: const [
                      Center(child: _ModernDecorationTypeSelector()),
                      SizedBox(height: 24),
                      AnimatedSize(
                        duration: Duration(milliseconds: 200),
                        curve: Curves.easeInOutCubic,
                        child: _ModernDecorationBody(),
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
              child: ModernButton(
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

class _ModernDecorationBody extends StatelessWidget {
  const _ModernDecorationBody({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ModernCustomSettingsController>();
    return Obx(() {
      final modernProxy = controller.proxyDataWrapper.value;
      final Widget child;

      /// Набор потенциальных настроек
      if (_isJustColor(modernProxy.backgroundDecoration)) {
        child = ColorPicker(
          labelTypes: const [],
          enableAlpha: false,
          displayThumbColor: false,
          colorPickerWidth: 300,
          paletteType: PaletteType.hueWheel,
          pickerColor: modernProxy.backgroundDecoration.color!,
          onColorChanged: (color) => controller._updateJustColor(color: color),
        );
      } else if (_isLinearGradient(modernProxy.backgroundDecoration)) {
        final linearGradient = modernProxy.backgroundDecoration.gradient as LinearGradient;
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
          ],
        );
      } else if (_isRadialGradient(modernProxy.backgroundDecoration)) {
        child = Column(
          key: const ValueKey('radial'),
          children: [
            Container(width: 400, height: 244, color: Colors.green),
            Container(width: 299, height: 244, color: Colors.red),
            Container(width: 100, height: 244, color: Colors.black),
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
class _ModernDecorationTypeSelector extends StatefulWidget {
  const _ModernDecorationTypeSelector({
    Key? key,
  }) : super(key: key);

  @override
  State<_ModernDecorationTypeSelector> createState() => _ModernDecorationTypeSelectorState();
}

/// Все допустимые варианты стиля DecorationBox
enum _DecorationType { color, linearGradient, radialGradient }

class _ModernDecorationTypeSelectorState extends State<_ModernDecorationTypeSelector> {
  late final Map<_DecorationType, BoxDecoration> decorations;
  late _DecorationType selectedType;
  late final ModernCustomSettingsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ModernCustomSettingsController>();
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

/// Контроллер тонкой настройки темы [ModernThemeDataWrapper], содержащий в себе временные изменения темы.
/// Для принятия изменений следует вызывать метод [acceptChanges]
class ModernCustomSettingsController extends CustomSettingsController {
  ModernCustomSettingsController({
    required ModernThemeDataWrapper proxyThemeWrapper,
  }) : proxyDataWrapper = proxyThemeWrapper.obs;

  final Rx<ModernThemeDataWrapper> proxyDataWrapper;

  @override
  void acceptChanges() {
    final themeController = Get.find<ThemeController>();
    final proxy = proxyDataWrapper.value;
    themeController.updateModernThemeData(
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

  /// установка [LinearGradient] градиенты в [BoxDecoration]
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
}

///Специально не делаю доп проверки внутри (на наличие цвета и градиенты), т.к. документация [BoxDecoration]
/// явно гласит - наличие одновременно параметров color и gradient недопустимо - возникнет runtime error
bool _isJustColor(BoxDecoration decoration) => decoration.color != null;

bool _isLinearGradient(BoxDecoration decoration) => decoration.gradient is LinearGradient;

bool _isRadialGradient(BoxDecoration decoration) => decoration.gradient is RadialGradient;
