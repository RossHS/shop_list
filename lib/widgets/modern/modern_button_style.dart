import 'package:flutter/material.dart';
import 'package:shop_list/widgets/modern/modern.dart';

/// Вспомогательный класс задающий константный стиль. Применяется для конфигурации
/// внешнего вида кнопок [ModernButton] и т.п., создал дабы не дублировать значения
/// при построении GUI и изменять внешний вид при помощи данного класса.
@immutable
class ModernButtonStyle {
  ModernButtonStyle({
    BorderRadius? borderRadius,
  }) : borderRadius = BorderRadius.circular(200);

  final BorderRadius borderRadius;

  BoxShadow shadow(Color shadowColor) {
    return BoxShadow(
      color: shadowColor,
      blurRadius: 15,
      spreadRadius: 1,
      offset: const Offset(0, 0),
    );
  }
}
