import 'package:flutter/material.dart';

/// Используется для определения цвета текста в зависимости от цвета фона,
extension CalculateTextColor on Color {
  /// Для оптимизации кеширую уже рассчитанные цвета текста
  static final _cache = <Color, Color>{};

  /// Расчет цвета, который бы не сливался с текущим
  Color get calcTextColor => _cache.putIfAbsent(this, () => computeLuminance() > .5 ? Colors.black : Colors.white);
}
