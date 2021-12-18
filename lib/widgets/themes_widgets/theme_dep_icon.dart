import 'package:flutter/material.dart';
import 'package:shop_list/custom_icons.dart';
import 'package:shop_list/models/theme_model.dart';
import 'package:shop_list/widgets/animated90s/animated_90s_icon.dart';
import 'package:shop_list/widgets/themes_widgets/theme_base_widget.dart';

/// TODO 18.12.2021 - подумать об оптимизации
class ThemeDepIcon extends ThemeDepWidgetBase {
  const ThemeDepIcon._({
    Key? key,
    this.animated90s = _defIcon,
    this.material = _defIcon,
    this.modern = _defIcon,
  }) : super(key: key);

  final Widget Function(Animated90sThemeDataWrapper themeWrapper) animated90s;
  final Widget Function(MaterialThemeDataWrapper themeWrapper) material;
  final Widget Function(ModernThemeDataWrapper themeWrapper) modern;

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

  /// Просто вспомогательный метод для упрощения вызова
  static AnimatedIcon90s _createIcon(List<IconData> iconsData, Animated90sThemeDataWrapper themeWrapper) {
    return AnimatedIcon90s(
      iconsList: iconsData,
      duration: themeWrapper.animationDuration,
    );
  }

  static Widget get create => ThemeDepIcon._(
        material: (_) => const Icon(Icons.create),
        animated90s: (themeWrapper) => _createIcon(CustomIcons.create, themeWrapper),
      );

  static Widget get user => ThemeDepIcon._(
        material: (_) => const Icon(Icons.account_circle),
        animated90s: (themeWrapper) => _createIcon(CustomIcons.user, themeWrapper),
      );

  static Widget get lock => ThemeDepIcon._(
        material: (_) => const Icon(Icons.lock),
        animated90s: (themeWrapper) => _createIcon(CustomIcons.lock, themeWrapper),
      );

  static Widget get sort => ThemeDepIcon._(
        material: (_) => const Icon(Icons.sort),
        animated90s: (themeWrapper) => _createIcon(CustomIcons.sort, themeWrapper),
      );

  static Widget get close => ThemeDepIcon._(
        material: (_) => const Icon(Icons.close),
        animated90s: (themeWrapper) => _createIcon(CustomIcons.close, themeWrapper),
      );

  static Widget get dehaze => ThemeDepIcon._(
        material: (_) => const Icon(Icons.dehaze),
        animated90s: (themeWrapper) => _createIcon(CustomIcons.dehaze, themeWrapper),
      );

  static Widget get settings => ThemeDepIcon._(
        material: (_) => const Icon(Icons.settings),
        animated90s: (themeWrapper) => _createIcon(CustomIcons.settings, themeWrapper),
      );

  // ignore: non_constant_identifier_names
  static Widget get file_upload => ThemeDepIcon._(
        material: (_) => const Icon(Icons.file_upload),
        animated90s: (themeWrapper) => _createIcon(CustomIcons.file_upload, themeWrapper),
      );

  static Widget get send => ThemeDepIcon._(
        material: (_) => const Icon(Icons.send),
        animated90s: (themeWrapper) => _createIcon(CustomIcons.send, themeWrapper),
      );
}
