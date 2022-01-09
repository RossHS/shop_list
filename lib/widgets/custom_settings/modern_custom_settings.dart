import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:shop_list/controllers/controllers.dart';
import 'package:shop_list/models/theme_model.dart';
import 'package:shop_list/utils/routes_transition.dart';
import 'package:shop_list/widgets/custom_settings/base_custom_settings.dart';
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
  @override
  void initState() {
    super.initState();
    Get.put(ModernCustomSettingsController(proxyThemeWrapper: widget.themeWrapper));
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ModernCustomSettingsController>();
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
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        _ModernDecorationTypeSelector(),
                        AnimatedSize(
                          duration: Duration(milliseconds: 300),
                          alignment: Alignment.topCenter,
                          child: _ModernDecorationBody(),
                        ),
                      ],
                    ),
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
          enableAlpha: false,
          displayThumbColor: false,
          colorPickerWidth: 300,
          paletteType: PaletteType.hueWheel,
          pickerColor: modernProxy.backgroundDecoration.color!,
          onColorChanged: (color) {
            // Проверка служит защитой от того, что пользователь в момент переключения
            // анимации виджетов может залочить их в полу-позиции
            if (_isJustColor(controller.proxyDataWrapper.value.backgroundDecoration)) {
              controller.proxyDataWrapper.value = modernProxy.copyWith(
                backgroundDecoration: BoxDecoration(color: color),
              );
            }
          },
        );
      } else {
        child = const SizedBox(width: 300, height: 10);
      }
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
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
                  width: 100,
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
}

///Специально не делаю доп проверки внутри (на наличие цвета и градиенты), т.к. документация [BoxDecoration]
/// явно гласит - наличие одновременно параметров color и gradient недопустимо - возникнет runtime error
bool _isJustColor(BoxDecoration decoration) => decoration.color != null;

bool _isLinearGradient(BoxDecoration decoration) => decoration.gradient is LinearGradient;

bool _isRadialGradient(BoxDecoration decoration) => decoration.gradient is RadialGradient;
