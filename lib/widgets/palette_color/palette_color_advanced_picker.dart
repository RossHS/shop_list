import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class PaletteColorAdvancedPicker extends StatefulWidget {
  const PaletteColorAdvancedPicker({
    Key? key,
    required this.colors,
    required this.onChange,
    this.min = 2,
    this.max = 6,
  })  : assert(colors.length >= min && colors.length <= max, 'incorrect length - ${colors.length}'),
        super(key: key);

  /// Обратный вызов при изменении цветов
  final void Function(List<Color> colors) onChange;

  /// Цвета для настроек
  final List<Color> colors;

  /// Минимальное количество цветов
  final double min;

  /// Максимальное количество цветов
  final double max;

  @override
  State<PaletteColorAdvancedPicker> createState() => _PaletteColorAdvancedPickerState();
}

class _PaletteColorAdvancedPickerState extends State<PaletteColorAdvancedPicker> {
  /// Позиция выбранного цвета
  int _index = 0;

  /// Вывел в отдельную переменную коллекцию цветов (копия [widget.colors]), т.к. считаю не лучшей практикой менять
  /// передаваемый список в виджет в качестве аргумента напрямую, ведь это может потенциально
  /// привести к трудноуловимым ошибкам, хоть и прямое использование более производительное.
  late List<Color> _colors;

  @override
  void initState() {
    super.initState();
    _colors = [...widget.colors];
  }

  @override
  void didUpdateWidget(covariant PaletteColorAdvancedPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Если списки виджетов не равны - создаем новый список [_colors]
    if (!(const ListEquality<Color>().equals(widget.colors, oldWidget.colors))) {
      _colors = [...widget.colors];
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        children: [
          Row(
            children: [],
          ),
          ColorPicker(
            labelTypes: const [],
            enableAlpha: false,
            displayThumbColor: false,
            colorPickerWidth: 300,
            paletteType: PaletteType.hueWheel,
            pickerColor: _colors[_index],
            onColorChanged: (color) {
              _colors[_index] = color;
              widget.onChange(_colors);
            },
          ),
        ],
      ),
    );
  }
}
