import 'package:flutter/material.dart';
import 'package:shop_list/models/theme_model.dart';
import 'package:shop_list/widgets/animated90s/animated_90s_painter_square.dart';
import 'package:shop_list/widgets/themes_widgets/theme_base_widget.dart';

class ThemeDepCommonItemBox extends ThemeDepWidgetBase {
  const ThemeDepCommonItemBox({
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
        key: key,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(themeWrapper.rounded),
          color: theme.canvasColor,
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(0.0, 1.0), //(x,y)
              blurRadius: 6.0,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
