import 'package:flutter/material.dart';

/// Прозрачный AppBar написанный по аналогии с [AppBar], но с учетом особенности, прозрачный фон.
/// Решил не использовать [AppBar] с backgroundColor: Colors.transparent, т.к. хочу иметь больший
/// контроль над виджетом
class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  ModernAppBar({
    Key? key,
    this.leading,
    this.title,
    this.actions,
    this.bottom,
  })  : preferredSize = _calcPrefSize(bottom),
        super(key: key);
  static const toolBarHeight = 56.0;

  final Widget? leading;
  final Widget? title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appBarTheme = AppBarTheme.of(context);

    // Т.к. AppBar прозрачный, то следует отталкиваться от цвета фона
    final foregroundColor = colorScheme.onBackground;
    final titleTextStyle = theme.textTheme.headline6?.copyWith(color: foregroundColor);
    final bodyTextStyle = theme.textTheme.bodyText2?.copyWith(color: foregroundColor);
    final overallIconTheme = appBarTheme.iconTheme ?? theme.iconTheme.copyWith(color: foregroundColor);
    final actionsIconTheme = appBarTheme.actionsIconTheme ?? overallIconTheme;

    var leading = this.leading ?? const BackButton();
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

    return SafeArea(
      bottom: false,
      child: appBarBody,
    );
  }

  /// Функция расчета размеров PreferredSizeWidget
  static Size _calcPrefSize(PreferredSizeWidget? bottom) {
    return Size.fromHeight(toolBarHeight + (bottom?.preferredSize.height ?? 0));
  }
}
