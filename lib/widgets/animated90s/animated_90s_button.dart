import 'package:flutter/material.dart';
import 'package:shop_list/widgets/animated90s/animated_90s.dart';

/// Кнопка внутри анимированного квадрата
/// Написал по аналогии с AnimatedCircleButton90s
class AnimatedButton90s extends StatelessWidget {
  const AnimatedButton90s({
    required this.child,
    required this.onPressed,
    this.config,
    this.duration,
    this.innerPadding = const EdgeInsets.all(8),
    Key? key,
  }) : super(key: key);

  final Widget child;
  final void Function() onPressed;
  final Paint90sConfig? config;
  final Duration? duration;

  /// Внутренние отступы для дочернего виджета child
  final EdgeInsetsGeometry innerPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final foregroundColor = (colorScheme.brightness == Brightness.dark ? colorScheme.onSurface : colorScheme.onPrimary);

    // Переопределение темы для дочернего виджета с текстом
    final childTheme = theme.copyWith(
      textTheme: theme.textTheme.apply(bodyColor: foregroundColor),
    );

    final paintConfig = Paint90sConfig(
      backgroundColor: config?.backgroundColor ?? colorScheme.secondary,
      outLineColor: config?.outLineColor,
      offset: config?.offset,
      strokeWidth: config?.strokeWidth,
    );

    // Отступ, чтобы виджет корректно смотрелся в своих рамках и не вылезал из них.
    // Иначе он может налезать на другие виджеты из "рванных граней" создаваемых AnimatedPainter90s
    return Padding(
      padding: EdgeInsets.all(paintConfig.offset.toDouble()),
      child: Theme(
        data: childTheme,
        child: RepaintBoundary(
          child: AnimatedPainterSquare90s(
            config: paintConfig,
            duration: duration,
            // Использую Material + InkWell + Container,
            // а не чистый RawMaterialButton т.к. с такой связкой можно иметь больший контроль.
            // Чистый RawMaterialButton имеет внешние отступы (Ink эффект будет не полностью
            // заполнять форму AnimatedPainter), а если использовать AnimatedPainter90s как ребенка кнопки,
            // то Ink эффект будет ЗА ребенком, т.е. для корректной работы пришлось бы делать связку из виджетов
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                highlightColor: Colors.transparent,
                child: Container(
                  alignment: Alignment.center,
                  padding: innerPadding,
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
