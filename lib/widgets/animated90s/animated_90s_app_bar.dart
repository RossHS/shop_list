import 'package:flutter/material.dart';
import 'package:shop_list/widgets/animated90s/animated_90s_painter.dart';
import 'package:shop_list/widgets/animated90s/animated_90s_painter_square.dart';

/// Реализация аналога AppBar с наличием анимации 90х
class AnimatedAppBar90s extends StatelessWidget implements PreferredSizeWidget {
  const AnimatedAppBar90s({
    this.leading,
    this.title,
    this.actions,
    Key? key,
  }) : super(key: key);

  /// Виджет предшествующий заголовку
  final Widget? leading;

  final Widget? title;

  /// Список виджетов, которые будут располагаться после [title]
  final List<Widget>? actions;

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
        (colorScheme.brightness == Brightness.dark ? colorScheme.onSurface : colorScheme.onPrimary);

    TextStyle? titleTextStyle =
        appBarTheme.titleTextStyle ?? theme.textTheme.headline6?.copyWith(color: foregroundColor);

    IconThemeData overallIconTheme = appBarTheme.iconTheme ?? theme.iconTheme.copyWith(color: foregroundColor);

    IconThemeData actionsIconTheme = appBarTheme.actionsIconTheme ?? overallIconTheme;

    // Установка темы для виджета перед заголовком
    Widget? leading = this.leading;
    if (leading != null) {
      leading = IconTheme.merge(
        data: actionsIconTheme,
        child: leading,
      );
    }

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

    // Создание ряда с виджетами из списка активностей
    Widget? actions;
    if (this.actions != null && this.actions!.isNotEmpty) {
      actions = Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: this.actions!,
      );

      // Установка тем для иконок
      actions = IconTheme.merge(
        data: actionsIconTheme,
        child: actions,
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
          leading: leading,
          middle: title,
          trailing: actions,
          centerMiddle: true,
        ),
      ),
    );
  }
}
