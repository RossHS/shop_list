import 'package:flutter/material.dart';

/// Обычный [Slider] совмещенный с заголовком и отображающий текущее значение
class SliderWithLabel extends StatelessWidget {
  const SliderWithLabel({
    super.key,
    required this.value,
    this.label,
    required this.onChange,
    this.min = 0,
    this.max = 1,
  })  : assert(value >= min && value <= max, 'incorrect value - $value');

  final double value;
  final void Function(double value) onChange;

  /// Виджет заголовка
  final Widget? label;

  /// Минимальное и максимальное допустимые отклонения [value]
  final double min;
  final double max;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget valueBlock = FittedBox(
      child: Text(
        value.toStringAsFixed(2),
        style: theme.textTheme.subtitle1,
      ),
    );

    if (label != null) {
      valueBlock = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          valueBlock,
          Expanded(
            child: FittedBox(fit: BoxFit.fitWidth, child: label!),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChange,
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: theme.canvasColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SizedBox(
            width: 80,
            height: 50,
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: valueBlock,
            ),
          ),
        ),
      ],
    );
  }
}
