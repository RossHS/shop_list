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
  int _currentColorIndex = 0;

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
    final theme = Theme.of(context);
    return RepaintBoundary(
      child: Column(
        children: [
          Row(
            children: [
              ..._colors.mapIndexed<Widget>((index, color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_currentColorIndex != index) {
                        _currentColorIndex = index;
                      } else if (_currentColorIndex == index && _colors.length > widget.min) {
                        // TODO утром проверить
                        _colors.removeAt(index);
                        widget.onChange(_colors);
                        setState(() {
                          _currentColorIndex = _colors.length - 1;
                        });
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: _currentColorIndex == index
                            ? Border.all(
                                color: Colors.black,
                                width: 2,
                              )
                            : null,
                        color: color,
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox.square(
                        dimension: 40,
                        child: _currentColorIndex == index && _colors.length > widget.min
                            ? const Icon(Icons.close, color: Colors.redAccent)
                            : null,
                      ),
                    ),
                  ),
                );
              }),
              if (_colors.length < 6)
                GestureDetector(
                  onTap: () {
                    _colors.add(Colors.white);
                    widget.onChange(_colors);
                    setState(() {
                      _currentColorIndex = _colors.length - 1;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: theme.canvasColor,
                        shape: BoxShape.circle,
                      ),
                      child: const SizedBox.square(
                        dimension: 40,
                        child: Icon(Icons.add),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          ColorPicker(
            labelTypes: const [],
            enableAlpha: false,
            displayThumbColor: false,
            colorPickerWidth: 300,
            paletteType: PaletteType.hueWheel,
            pickerColor: _colors[_currentColorIndex],
            onColorChanged: (color) {
              _colors[_currentColorIndex] = color;
              widget.onChange(_colors);
            },
          ),
        ],
      ),
    );
  }
}
