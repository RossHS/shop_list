import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_list/controllers/controllers.dart';
import 'package:shop_list/widgets/animated90s/animated_90s_painter.dart';
import 'package:shop_list/widgets/animated90s/animated_90s_painter_circle.dart';
import 'package:shop_list/widgets/themes_factories/abstract_theme_factory.dart';

/// Индикация того, выбрал ли пользователь фотографию для загрузки
class ImageSelectedIndicator extends StatelessWidget {
  const ImageSelectedIndicator({
    required this.userInfoUpdateController,
    Key? key,
  }) : super(key: key);
  final UserInfoUpdateController userInfoUpdateController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (userInfoUpdateController.photoSelectedState.value) {
        case PhotoSelectionState.error:
          return const _AnimatedIconWrapper(Icon(Icons.error));
        case PhotoSelectionState.nonSelected:
          return const SizedBox();
        case PhotoSelectionState.loading:
          return const _AnimatedIconWrapper(Icon(Icons.timer));
        case PhotoSelectionState.loaded:
          return const _AnimatedIconWrapper(Icon(Icons.check));
      }
    });
  }
}

/// Оболочка для иконок, чтобы не дублировать код
class _AnimatedIconWrapper extends StatelessWidget {
  const _AnimatedIconWrapper(
    this.icon, {
    Key? key,
  }) : super(key: key);
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final floatingActionButtonTheme = theme.floatingActionButtonTheme;
    final colorScheme = theme.colorScheme;
    final foregroundColor = (colorScheme.brightness == Brightness.dark ? colorScheme.onSurface : colorScheme.onPrimary);
    final overallIconTheme = theme.iconTheme.copyWith(color: foregroundColor);

    const height = 42.0;
    const width = 42.0;
    final themeFactory = ThemeFactory.instance(ThemeController.to.appTheme.value);
    return themeFactory.buildWidget(
      animated90s: () {
        final paintConfig = Paint90sConfig(
          backgroundColor: floatingActionButtonTheme.backgroundColor ?? theme.colorScheme.secondary,
        );
        return AnimatedPainterCircle90s(
          config: paintConfig,
          child: SizedBox(
            height: height,
            width: width,
            child: IconTheme.merge(
              data: overallIconTheme,
              child: icon,
            ),
          ),
        );
      },
      material: () => Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: floatingActionButtonTheme.backgroundColor ?? theme.colorScheme.secondary,
        ),
        child: IconTheme.merge(
          data: overallIconTheme,
          child: icon,
        ),
      ),
      modern: () => Container(
        height: height,
        width: width,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: icon,
      ),
    );
  }
}
