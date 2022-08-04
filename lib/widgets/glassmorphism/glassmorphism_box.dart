import 'dart:ui';

import 'package:flutter/material.dart';

/// Матовый контейнер, основан на стиле Glassmorphism. В качестве основы взял код с
/// https://medium.com/@felipe_santos75/glassmorphism-in-flutter-56e9dc040c54 , который я чуть изменил -
/// Оптимизировал дерево, заменив излишний Container на обычный DecoratedBox
/// Задаю параметры радиуса для ClipRRect, дабы "подрезать" углы bloor эффекта
/// Добавил различные параметры для кастомизации
class GlassmorphismBox extends StatelessWidget {
  const GlassmorphismBox({
    super.key,
    this.borderRadius = 24,
    this.glassColor = Colors.white,
    this.opacityStart = 0.7,
    this.opacityEnd = 0.4,
    this.child,
  });

  /// Радиус скругления краев "стекла"
  final double borderRadius;

  /// Цвет "стекла"
  final Color glassColor;

  /// Начальное значение прозрачности для цвета [glassColor]
  final double opacityStart;

  /// Конечное значение прозрачности для цвета [glassColor]
  final double opacityEnd;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                glassColor.withOpacity(opacityStart),
                glassColor.withOpacity(opacityEnd),
              ],
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              width: 1.5,
              color: glassColor.withOpacity(0.2),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
