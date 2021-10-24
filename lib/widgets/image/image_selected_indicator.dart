import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_list/controllers/controllers.dart';
import 'package:shop_list/widgets/animated90s/animated_90s_painter.dart';
import 'package:shop_list/widgets/animated90s/animated_90s_painter_circle.dart';

/// Индикация того, выбрал ли пользователь фотографию для загрузки
class ImageSelectedIndicator extends StatelessWidget {
  const ImageSelectedIndicator({
    required this.userPhotoController,
    Key? key,
  }) : super(key: key);
  final UserPhotoController userPhotoController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (userPhotoController.photoSelectedState.value) {
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
    final ThemeData theme = Theme.of(context);
    final FloatingActionButtonThemeData floatingActionButtonTheme = theme.floatingActionButtonTheme;
    final ColorScheme colorScheme = theme.colorScheme;

    final Color foregroundColor =
        (colorScheme.brightness == Brightness.dark ? colorScheme.onSurface : colorScheme.onPrimary);
    final IconThemeData overallIconTheme = theme.iconTheme.copyWith(color: foregroundColor);

    Paint90sConfig paintConfig = Paint90sConfig(
      backgroundColor: floatingActionButtonTheme.backgroundColor ?? theme.colorScheme.secondary,
    );

    return AnimatedPainterCircle90s(
      config: paintConfig,
      child: SizedBox(
        height: 42,
        width: 42,
        child: IconTheme.merge(
          data: overallIconTheme,
          child: icon,
        ),
      ),
    );
  }
}
