import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_list/custom_icons.dart';
import 'package:shop_list/widgets/animated90s/animated_90s.dart';

/// Реализация аналога AppBar с наличием анимации 90х
class AnimatedAppBar90s extends StatelessWidget implements PreferredSizeWidget {
  AnimatedAppBar90s({
    this.leading,
    this.title,
    this.actions,
    this.bottom,
    this.config,
    this.duration,
    Key? key,
  })  : preferredSize = _calcPrefSize(bottom),
        super(key: key);

  /// Виджет предшествующий заголовку
  final Widget? leading;

  final Widget? title;

  /// Список виджетов, которые будут располагаться после [title]
  final List<Widget>? actions;

  /// Виджет находящийся под основной частью appBar
  final PreferredSizeWidget? bottom;

  final Paint90sConfig? config;

  final Duration? duration;

  static const toolBarHeight = 56.0;

  /// Прописал значение размера стандартное для SDK Flutter AppBar.
  /// Не стал производить самостоятельный расчет, т.к. высота не динамическая
  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appBarTheme = AppBarTheme.of(context);

    final foregroundColor = appBarTheme.foregroundColor ??
        (colorScheme.brightness == Brightness.dark ? colorScheme.onSurface : colorScheme.onPrimary);

    final titleTextStyle = appBarTheme.titleTextStyle ?? theme.textTheme.headline6?.copyWith(color: foregroundColor);

    final bodyTextStyle = theme.textTheme.bodyText2?.copyWith(color: foregroundColor);

    final overallIconTheme = appBarTheme.iconTheme ?? theme.iconTheme.copyWith(color: foregroundColor);

    final actionsIconTheme = appBarTheme.actionsIconTheme ?? overallIconTheme;

    // Если явно не задан leading виджет,
    // то будет отображаться кнопка перехода на предыдущий маршрут
    var leading = this.leading ??
        IconButton(
          onPressed: Get.back,
          icon: AnimatedIcon90s(
            duration: duration,
            iconsList: CustomIcons.arrow,
          ),
        );
    // Установка темы для виджета перед заголовком
    leading = IconTheme.merge(
      data: actionsIconTheme,
      child: leading,
    );

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

    Widget appBarBody = NavigationToolbar(
      leading: leading,
      middle: title,
      trailing: actions,
      centerMiddle: true,
    );

    if (bottom != null) {
      appBarBody = Column(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: toolBarHeight),
              child: appBarBody,
            ),
          ),
          DefaultTextStyle(
            style: bodyTextStyle!,
            child: bottom!,
          ),
        ],
      );
    }

    var config = this.config ?? const Paint90sConfig();
    config = config.copyWith(
      backgroundColor: appBarTheme.backgroundColor ?? colorScheme.primary,
    );

    return AnimatedPainterSquare90s(
      config: config,
      borderPaint: const BorderPaint.bottom(),
      duration: duration,
      child: SafeArea(
        bottom: false,
        // Чтобы Ink эффект был над AnimatedPainterSquare90s, а не под ним
        child: Material(
          type: MaterialType.transparency,
          // Специальный виджет для 3 элементов в ряду
          child: appBarBody,
        ),
      ),
    );
  }

  /// Вспомогательный метод расчета размеров AppBar
  static Size _calcPrefSize(PreferredSizeWidget? bottom) {
    return Size.fromHeight(toolBarHeight + (bottom?.preferredSize.height ?? 0));
  }
}
