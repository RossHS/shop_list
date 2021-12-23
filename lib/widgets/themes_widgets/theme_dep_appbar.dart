import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shop_list/custom_icons.dart';
import 'package:shop_list/models/theme_model.dart';
import 'package:shop_list/utils/routes_transition.dart';
import 'package:shop_list/widgets/animated90s/animated_90s.dart';
import 'package:shop_list/widgets/themes_widgets/theme_dep_cached.dart';

class ThemeDepAppBar extends ThemeDepCached<PreferredSizeWidget> implements PreferredSizeWidget {
  ThemeDepAppBar({
    Key? key,
    this.leading,
    this.title,
    this.actions,
    this.bottom,
  }) : super(key: key);

  final Widget? leading;
  final Widget? title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;

  @override
  PreferredSizeWidget animated90sWidgetImp(BuildContext context, Animated90sThemeDataWrapper themeWrapper) {
    final leading = this.leading ??
        // Обеспечение начальной точки обратной анимации круга [CustomCircleTransition]
        TouchGetterProvider(
          child: IconButton(
            onPressed: Get.back,
            icon: AnimatedIcon90s(
              duration: themeWrapper.animationDuration,
              iconsList: CustomIcons.arrow,
            ),
          ),
        );

    final appbar = AnimatedAppBar90s(
      leading: leading,
      title: title,
      actions: actions,
      bottom: bottom,
      duration: themeWrapper.animationDuration,
      config: themeWrapper.paint90sConfig,
    );
    return appbar;
  }

  @override
  PreferredSizeWidget materialWidgetImp(BuildContext context, MaterialThemeDataWrapper themeWrapper) {
    // Не сдал выделять в отдельный метод одинаковый код,
    // т.к. такой маленький кусок весьма запутывает чтение кода
    final leading = this.leading ??
        // Обеспечение начальной точки обратной анимации круга [CustomCircleTransition]
        const TouchGetterProvider(
          child: BackButton(),
        );

    final appbar = AppBar(
      leading: leading,
      title: title,
      actions: actions,
      bottom: bottom,
    );
    return appbar;
  }

  @override
  PreferredSizeWidget modernWidgetImp(BuildContext context, ModernThemeDataWrapper themeWrapper) {
    // TODO 23.12.2021 implement modernWidgetImp
    return materialWidgetImp(context, MaterialThemeDataWrapper.fromGetStorage(GetStorage()));
  }

  @override
  Size get preferredSize => cachedWidget.widget.preferredSize;
}
