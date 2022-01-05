import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shop_list/models/theme_model.dart';

class ModernThemeDataWrapper extends ThemeDataWrapper {
  static const appThemeStorageValue = 'Modern';

  const ModernThemeDataWrapper({
    required TextTheme textTheme,
    required ColorSchemeWrapper lightColorSchemeWrapper,
    required ColorSchemeWrapper darkColorSchemeWrapper,
  }) : super(
          textTheme: textTheme,
          lightColorSchemeWrapper: lightColorSchemeWrapper,
          darkColorSchemeWrapper: darkColorSchemeWrapper,
        );

  factory ModernThemeDataWrapper.fromGetStorage(GetStorage storage) {
    final textTheme = TextThemeCollection.fromString(storage.read<String>('textTheme'));
    final String lightThemeKey = storage.read<String>('$appThemeStorageValue-light') ?? 'default light 1';
    final String darkThemeKey = storage.read<String>('$appThemeStorageValue-dark') ?? 'default dark 1';
    return ModernThemeDataWrapper(
      textTheme: textTheme,
      lightColorSchemeWrapper: _getLightColorSchemesWrapperMap[lightThemeKey]!,
      darkColorSchemeWrapper: _getDarkColorSchemesWrapperMap[darkThemeKey]!,
    );
  }

  @override
  Map<String, ColorSchemeWrapper> get lightColorSchemesWrapperMap => _getLightColorSchemesWrapperMap;

  @override
  Map<String, ColorSchemeWrapper> get darkColorSchemesWrapperMap => _getDarkColorSchemesWrapperMap;

  @override
  String get themePrefix => ModernThemeDataWrapper.appThemeStorageValue;

  @override
  ModernThemeDataWrapper copyWith({
    TextTheme? textTheme,
    ColorSchemeWrapper? lightColorSchemeWrapper,
    ColorSchemeWrapper? darkColorSchemeWrapper,
  }) {
    return ModernThemeDataWrapper(
      textTheme: textTheme ?? this.textTheme,
      lightColorSchemeWrapper: lightColorSchemeWrapper ?? this.lightColorSchemeWrapper,
      darkColorSchemeWrapper: darkColorSchemeWrapper ?? this.darkColorSchemeWrapper,
    );
  }
}

/// Почему так, объяснение в комментариях [Animated90sThemeDataWrapper._lightColorSchemesMap]
Map<String, GradientBackground>? _lightColorSchemesWrapperMap;
Map<String, GradientBackground>? _darkColorSchemesWrapperMap;

Map<String, GradientBackground> get _getLightColorSchemesWrapperMap {
  _lightColorSchemesWrapperMap ??= {
    'default light 1': GradientBackground(
      colorScheme: ThemeWrapperUtils.createLightColorScheme(Colors.green, Colors.green),
      background: Colors.black,
    ),
    'default light 2': GradientBackground(
      colorScheme: ThemeWrapperUtils.createLightColorScheme(Colors.blue, Colors.blue),
      background: Colors.green,
    ),
    'custom light': GradientBackground(
      colorScheme: ThemeWrapperUtils.loadCustomColorSchemeFromStorage(
          GetStorage(), '${ModernThemeDataWrapper.appThemeStorageValue}-custom-light'),
      background: Colors.white,
    ),
  };
  assert(_lightColorSchemesWrapperMap != null && _lightColorSchemesWrapperMap!.isNotEmpty);
  return _lightColorSchemesWrapperMap!;
}

Map<String, GradientBackground> get _getDarkColorSchemesWrapperMap {
  _darkColorSchemesWrapperMap ??= {
    'default dark 1': GradientBackground(
      colorScheme: ThemeWrapperUtils.createDarkColorScheme(Colors.redAccent, Colors.redAccent),
      background: Colors.red,
    ),
    'default dark 2': GradientBackground(
      colorScheme: ThemeWrapperUtils.createDarkColorScheme(Colors.blueGrey, Colors.blueGrey),
      background: Colors.red,
    ),
    'custom dark': GradientBackground(
      colorScheme: ThemeWrapperUtils.loadCustomColorSchemeFromStorage(
          GetStorage(), '${ModernThemeDataWrapper.appThemeStorageValue}-custom-dark'),
      background: Colors.red,
    ),
  };
  assert(_darkColorSchemesWrapperMap != null && _darkColorSchemesWrapperMap!.isNotEmpty);
  return _darkColorSchemesWrapperMap!;
}

@immutable
class GradientBackground extends ColorSchemeWrapper {
  const GradientBackground({
    required ColorScheme colorScheme,
    required this.background,
  }) : super(colorScheme);

  final Color background;

  @override
  GradientBackground copyWith({
    ColorScheme? colorScheme,
    Color? background,
  }) {
    return GradientBackground(
      colorScheme: colorScheme ?? this.colorScheme,
      background: background ?? this.background,
    );
  }
}
