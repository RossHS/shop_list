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
    selectedColor = widget.controller.colors.values.first;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...widget.controller.colors.entries.map<Widget>((entry) {
          return RadioListTile<_ColorMutableWrapper>(
            title: Text(entry.key),
            value: entry.value,
            groupValue: selectedColor,
            controlAffinity: ListTileControlAffinity.trailing,
            onChanged: (_) {
              setState(() {
                selectedColor = entry.value;
              });
            },
            secondary: Container(
              height: 100,
              width: 100,
              color: entry.value.color,
            ),
          );
        }).toList(),
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
          },
        ),
      ],
    );
  }
}

/// Конечно лучше было бы использовать GetX/GetxController и т.п.,
/// но захотелось попробовать написать так, без участия сторонних библиотек
class ColorChangeController {
  ColorChangeController({
    required Map<String, Color> colors,
  })  : assert(colors.isNotEmpty, 'Коллекция цветов не должна быть пустой'),
        colors = colors.map((key, value) => MapEntry(key, _ColorMutableWrapper(value)));

  /// Все цвета под настройку
  /// Обертка над цветом, зачем нужна? - в комментариях к классу [_ColorMutableWrapper]
  /// Где ключ, имя расположения цвета (основной, фоновый и т.п.), а значение - сам цвет
  // ignore: library_private_types_in_public_api
  final Map<String, _ColorMutableWrapper> colors;
}

/// так как объект [Color] immutable, то создал обертку над цветом,
/// чтобы определять выбранный цвет (фон/основной) по ссылке на [_ColorMutableWrapper]
class _ColorMutableWrapper {
  _ColorMutableWrapper(this.color);

  Color color;
}
