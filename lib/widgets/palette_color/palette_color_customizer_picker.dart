import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shop_list/models/theme_model.dart';

/// Виджет настройки цветов [ColorScheme] кастомной темы в [ThemeDataWrapper]
class PaletteColorCustomizerPicker extends StatefulWidget {
  const PaletteColorCustomizerPicker({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final ColorChangeController controller;

  @override
  State<PaletteColorCustomizerPicker> createState() => _PaletteColorCustomizerPickerState();
}

class _PaletteColorCustomizerPickerState extends State<PaletteColorCustomizerPicker> {
  /// Ссылка на выбранный цвет
  late _ColorMutableWrapper selectedColor;

  @override
  void initState() {
    super.initState();
    selectedColor = widget.controller.backgroundColor;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RadioListTile<_ColorMutableWrapper>(
          title: const Text('Основной'),
          value: widget.controller.mainColor,
          groupValue: selectedColor,
          controlAffinity: ListTileControlAffinity.trailing,
          onChanged: (_) {
            setState(() {
              selectedColor = widget.controller.mainColor;
            });
          },
          secondary: Container(
            height: 100,
            width: 100,
            color: widget.controller.mainColor.color,
          ),
        ),
        RadioListTile<_ColorMutableWrapper>(
          title: const Text('Фон'),
          value: widget.controller.backgroundColor,
          groupValue: selectedColor,
          controlAffinity: ListTileControlAffinity.trailing,
          onChanged: (_) {
            setState(() {
              selectedColor = widget.controller.backgroundColor;
            });
          },
          secondary: Container(
            height: 100,
            width: 100,
            color: widget.controller.backgroundColor.color,
          ),
        ),
        ColorPicker(
            enableAlpha: false,
            displayThumbColor: false,
            colorPickerWidth: 300,
            paletteType: PaletteType.hueWheel,
            pickerColor: selectedColor.color,
            onColorChanged: (value) {
              setState(() {
                selectedColor.color = value;
              });
            }),
      ],
    );
  }
}

/// Конечно лучше было бы использовать GetX/GetxController и т.п.,
/// но захотелось попробовать написать так, без участия сторонних библиотек
class ColorChangeController {
  ColorChangeController({required this.colorScheme})
      : mainColor = _ColorMutableWrapper(colorScheme.primary),
        backgroundColor = _ColorMutableWrapper(colorScheme.background);

  ColorScheme colorScheme;

  /// Обертка над цветом, зачем нужна? - в комментариях к классу [_ColorMutableWrapper]
  final _ColorMutableWrapper mainColor;
  final _ColorMutableWrapper backgroundColor;

  /// Генерация новой цветовой схемы на основе базовой [colorScheme],
  /// с учетом новых цветов из mainColor и backgroundColor
  ColorScheme get generateColor => colorScheme.copyWith(
        primary: mainColor.color,
        primaryVariant: mainColor.color,
        secondary: mainColor.color,
        secondaryVariant: mainColor.color,
        background: backgroundColor.color,
        surface: mainColor.color,
        error: Colors.redAccent,
      );
}

/// так как объект [Color] immutable, то создал обертку над цветом,
/// чтобы определять выбранный цвет (фон/основной) по ссылке на [_ColorMutableWrapper]
class _ColorMutableWrapper {
  _ColorMutableWrapper(this.color);

  Color color;
}
