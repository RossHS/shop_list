import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_list/controllers/controllers.dart';
import 'package:shop_list/models/theme_model.dart';
import 'package:shop_list/widgets/custom_settings/base_custom_settings.dart';
import 'package:shop_list/widgets/modern/modern.dart';
import 'package:shop_list/widgets/themes_widgets/theme_dep.dart';

class ModernCustomSettings extends StatefulWidget {
  const ModernCustomSettings({
    Key? key,
    required this.controller,
  }) : super(key: key);
  final ModernCustomSettingsController controller;

  @override
  State<ModernCustomSettings> createState() => _ModernCustomSettingsState();
}

class _ModernCustomSettingsState extends State<ModernCustomSettings> {
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
            child: Center(
              child: ModernGlassMorph(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: _ModernDecorationTypeSelector(widget.controller),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ModernButton(
              onPressed: () {
                Get.back();
                widget.controller.acceptChanges();
              },
              child: const Text('Сохранить'),
            ),
          ),
        ],
      ),
    );
    return Obx(() => DecoratedBox(
          decoration: widget.controller.proxyDataWrapper.value.backgroundDecoration,
          child: child,
        ));
  }
}

/// Выбор типа декорации
class _ModernDecorationTypeSelector extends StatefulWidget {
  const _ModernDecorationTypeSelector(
    this.controller, {
    Key? key,
  }) : super(key: key);
  final ModernCustomSettingsController controller;

  @override
  State<_ModernDecorationTypeSelector> createState() => _ModernDecorationTypeSelectorState();
}

/// Все допустимые варианты стиля DecorationBox
enum DecorationType { color, linearGradient, radialGradient }

class _ModernDecorationTypeSelectorState extends State<_ModernDecorationTypeSelector> {
  late final Map<DecorationType, BoxDecoration> decorations;
  late DecorationType selectedType;

  @override
  void initState() {
    super.initState();
    decorations = const <DecorationType, BoxDecoration>{
      DecorationType.color: BoxDecoration(
        color: Colors.red,
      ),
      DecorationType.linearGradient: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [Colors.red, Colors.blue],
        ),
      ),
      DecorationType.radialGradient: BoxDecoration(
        gradient: RadialGradient(
          colors: [Colors.red, Colors.blue],
        ),
      ),
    };

    final initDecoration = widget.controller.proxyDataWrapper.value.backgroundDecoration;
    if (initDecoration.color != null) {
      selectedType = DecorationType.color;
    } else if (initDecoration.gradient is LinearGradient) {
      selectedType = DecorationType.linearGradient;
    } else if (initDecoration.gradient is RadialGradient) {
      selectedType = DecorationType.radialGradient;
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
            widget.controller.proxyDataWrapper.value =
                widget.controller.proxyDataWrapper.value.copyWith(backgroundDecoration: decorations[newType]);
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
