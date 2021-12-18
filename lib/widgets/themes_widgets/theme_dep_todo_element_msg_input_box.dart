import 'package:flutter/material.dart';
import 'package:shop_list/models/theme_model.dart';
import 'package:shop_list/widgets/animated90s/animated_90s.dart';
import 'package:shop_list/widgets/themes_widgets/theme_base_widget.dart';

class ThemeDepTodoElementMsgInputBox extends ThemeDepWidgetBase {
  const ThemeDepTodoElementMsgInputBox({
    Key? key,
    required this.child,
  }) : super(key: key);
  final Widget child;

  @override
  Widget animated90sWidget(BuildContext context, Animated90sThemeDataWrapper themeWrapper) {
    final theme = Theme.of(context);
    final config = themeWrapper.paint90sConfig.copyWith(backgroundColor: theme.canvasColor);
    return Theme(
      data: theme.copyWith(
        textTheme: theme.textTheme.apply(bodyColor: theme.canvasColor.calcTextColor),
      ),
      child: AnimatedPainterSquare90s(
        key: key,
        duration: themeWrapper.animationDuration,
        config: config,
        borderPaint: const BorderPaint.top(),
        child: child,
      ),
    );
  }

  @override
  Widget materialWidget(BuildContext context, MaterialThemeDataWrapper themeWrapper) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        textTheme: theme.textTheme.apply(bodyColor: theme.canvasColor.calcTextColor),
      ),
      child: Container(
        color: theme.canvasColor,
        child: child,
      ),
    );
  }
}
