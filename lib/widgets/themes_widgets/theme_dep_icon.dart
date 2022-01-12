// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:shop_list/custom_icons.dart';
import 'package:shop_list/models/theme_model.dart';
import 'package:shop_list/widgets/animated90s/animated_90s_icon.dart';
import 'package:shop_list/widgets/glassmorphism/glassmorphism.dart';
import 'package:shop_list/widgets/themes_widgets/theme_base_widget.dart';

/// TODO 18.12.2021 - подумать об оптимизации
class ThemeDepIcon extends ThemeDepWidgetBase {
  const ThemeDepIcon._({
    Key? key,
    this.animated90s = _defIcon,
    this.material = _defIcon,
    this.glassmorphism = _defIcon,
  }) : super(key: key);

  final Widget Function(Animated90sThemeDataWrapper themeWrapper) animated90s;
  final Widget Function(MaterialThemeDataWrapper themeWrapper) material;
  final Widget Function(GlassmorphismThemeDataWrapper themeWrapper) glassmorphism;

  static Widget _defIcon(ThemeDataWrapper themeWrapper) {
    return const Icon(Icons.warning_amber_rounded);
  }

  @override
  Widget animated90sWidget(BuildContext context, Animated90sThemeDataWrapper themeWrapper) {
    return animated90s(themeWrapper);
  }

  @override
  Widget materialWidget(BuildContext context, MaterialThemeDataWrapper themeWrapper) {
    return material(themeWrapper);
  }

  @override
  Widget glassmorphismWidget(BuildContext context, GlassmorphismThemeDataWrapper themeWrapper) {
    return glassmorphism(themeWrapper);
  }

  /// Просто вспомогательный метод для упрощения создания [AnimatedIcon90s]
  static AnimatedIcon90s _createAnimatedIcon(List<IconData> iconsData, Animated90sThemeDataWrapper themeWrapper) {
    return AnimatedIcon90s(
      iconsList: iconsData,
      duration: themeWrapper.animationDuration,
    );
  }

  static Widget get create => ThemeDepIcon._(
        material: (_) => const Icon(Icons.create),
        animated90s: (themeWrapper) => _createAnimatedIcon(CustomIcons.create, themeWrapper),
        glassmorphism: (_) => const GlassmorphismIcon(Icons.create),
      );

  static Widget get user => ThemeDepIcon._(
        material: (_) => const Icon(Icons.account_circle),
        animated90s: (themeWrapper) => _createAnimatedIcon(CustomIcons.user, themeWrapper),
        glassmorphism: (_) => const GlassmorphismIcon(Icons.account_circle),
      );

  static Widget get lock => ThemeDepIcon._(
        material: (_) => const Icon(Icons.lock),
        animated90s: (themeWrapper) => _createAnimatedIcon(CustomIcons.lock, themeWrapper),
        glassmorphism: (_) => const GlassmorphismIcon(Icons.lock),
      );

  static Widget get sort => ThemeDepIcon._(
        material: (_) => const Icon(Icons.sort),
        animated90s: (themeWrapper) => _createAnimatedIcon(CustomIcons.sort, themeWrapper),
        glassmorphism: (_) => const GlassmorphismIcon(Icons.sort),
      );

  static Widget get close => ThemeDepIcon._(
        material: (_) => const Icon(Icons.close),
        animated90s: (themeWrapper) => _createAnimatedIcon(CustomIcons.close, themeWrapper),
        glassmorphism: (_) => const GlassmorphismIcon(Icons.close),
      );

  static Widget get dehaze => ThemeDepIcon._(
        material: (_) => const Icon(Icons.dehaze),
        animated90s: (themeWrapper) => _createAnimatedIcon(CustomIcons.dehaze, themeWrapper),
        glassmorphism: (_) => const GlassmorphismIcon(Icons.dehaze),
      );

  static Widget get settings => ThemeDepIcon._(
        material: (_) => const Icon(Icons.settings),
        animated90s: (themeWrapper) => _createAnimatedIcon(CustomIcons.settings, themeWrapper),
        glassmorphism: (_) => const GlassmorphismIcon(Icons.settings),
      );

  static Widget get file_upload => ThemeDepIcon._(
        material: (_) => const Icon(Icons.file_upload),
        animated90s: (themeWrapper) => _createAnimatedIcon(CustomIcons.file_upload, themeWrapper),
        glassmorphism: (_) => const GlassmorphismIcon(Icons.file_upload),
      );

  static Widget get send => ThemeDepIcon._(
        material: (_) => const Icon(Icons.send),
        animated90s: (themeWrapper) => _createAnimatedIcon(CustomIcons.send, themeWrapper),
        glassmorphism: (_) => const GlassmorphismIcon(Icons.send),
      );

  static Widget get exit_to_app => ThemeDepIcon._(
        material: (_) => const Icon(Icons.exit_to_app),
        animated90s: (themeWrapper) => _createAnimatedIcon(CustomIcons.exit_to_app, themeWrapper),
        glassmorphism: (_) => const GlassmorphismIcon(Icons.exit_to_app),
      );
}
