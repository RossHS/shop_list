import 'package:flutter/material.dart';
import 'package:shop_list/widgets/animated90s/animated_90s_painter.dart';
import 'package:shop_list/widgets/animated90s/animated_90s_painter_square.dart';

/// Реализация аналога AppBar с наличием анимации 90х
class AnimatedAppBar90s extends StatelessWidget implements PreferredSizeWidget {
  const AnimatedAppBar90s({
    this.title,
    Key? key,
  }) : super(key: key);

  final Widget? title;

  /// Прописал значение размера стандартное для SDK Flutter AppBar.
  /// Не стал производить самостоятельный расчет, т.к. высота не динамическая
  @override
  Size get preferredSize => const Size(0, 56);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final AppBarTheme appBarTheme = AppBarTheme.of(context);

    final Color foregroundColor = appBarTheme.foregroundColor ??
        (colorScheme.brightness == Brightness.dark
            ? colorScheme.onSurface
            : colorScheme.onPrimary);

    TextStyle? titleTextStyle = appBarTheme.titleTextStyle ??
        theme.textTheme.headline6?.copyWith(color: foregroundColor);

    // Оборачиваем виджет заголовка в виджет стиля текста,
    // чтобы придать тексту необходимы вид во всем поддереве
    Widget? title = this.title;
    if (title != null) {
      title = DefaultTextStyle(
        style: titleTextStyle!,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        child: title,
      );
    }

    var config = Paint90sConfig(
      backgroundColor: appBarTheme.backgroundColor ?? theme.primaryColor,
    );

    return AnimatedPainterSquare90s(
      config: config,
      borderPaint: const BorderPaint.bottom(),
      // Специальный виджет для 3 элементов в ряду
      child: SafeArea(
        bottom: false,
        child: NavigationToolbar(
          middle: title,
          centerMiddle: true,
        ),
      ),
    );
  }
}
