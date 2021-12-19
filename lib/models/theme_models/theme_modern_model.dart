import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shop_list/models/theme_model.dart';

class ModernThemeDataWrapper extends ThemeDataWrapper {
  static const appThemeStorageValue = 'Modern';

  const ModernThemeDataWrapper({
    required TextTheme textTheme,
    required ColorScheme lightColorScheme,
    required ColorScheme darkColorScheme,
  }) : super(
          textTheme: textTheme,
          lightColorScheme: lightColorScheme,
          darkColorScheme: darkColorScheme,
        );

  factory ModernThemeDataWrapper.fromGetStorage(GetStorage storage) {
    final textTheme = TextThemeCollection.fromString(storage.read<String>('textTheme'));
    final String lightThemeKey = storage.read<String>('$appThemeStorageValue-light') ?? 'default light 1';
    final String darkThemeKey = storage.read<String>('$appThemeStorageValue-dark') ?? 'default dark 1';
    return ModernThemeDataWrapper(
      textTheme: textTheme,
      lightColorScheme: _getLightColorSchemesMap[lightThemeKey]!,
      darkColorScheme: _getDarkColorSchemesMap[darkThemeKey]!,
    );
  }

  /// Почему так, объяснение в комментариях [Animated90sThemeDataWrapper._lightColorSchemesMap]
  static Map<String, ColorScheme>? _lightColorSchemesMap;
  static Map<String, ColorScheme>? _darkColorSchemesMap;

  static Map<String, ColorScheme> get _getLightColorSchemesMap {
    _lightColorSchemesMap ??= {
      'default light 1': ThemeWrapperUtils.createLightColorScheme(Colors.green, Colors.red),
      'default light 2': ThemeWrapperUtils.createLightColorScheme(Colors.blue, Colors.white),
      'custom light':
          ThemeWrapperUtils.loadCustomColorSchemeFromStorage(GetStorage(), '$appThemeStorageValue-custom-light'),
    };
    assert(_lightColorSchemesMap != null && _lightColorSchemesMap!.isNotEmpty);
    return _lightColorSchemesMap!;
  }

  static Map<String, ColorScheme> get _getDarkColorSchemesMap {
    _darkColorSchemesMap ??= {
      'default dark 1': ThemeWrapperUtils.createDarkColorScheme(Colors.redAccent, Colors.lightGreen),
      'default dark 2': ThemeWrapperUtils.createDarkColorScheme(Colors.blueGrey, Colors.pink),
      'custom dark':
          ThemeWrapperUtils.loadCustomColorSchemeFromStorage(GetStorage(), '$appThemeStorageValue-custom-dark'),
    };
    assert(_darkColorSchemesMap != null && _darkColorSchemesMap!.isNotEmpty);
    return _darkColorSchemesMap!;
  }

  @override
  Map<String, ColorScheme> get lightColorSchemesMap => _getLightColorSchemesMap;

  @override
  Map<String, ColorScheme> get darkColorSchemesMap => _getDarkColorSchemesMap;

  @override
  String get themePrefix => ModernThemeDataWrapper.appThemeStorageValue;

  @override
  ModernThemeDataWrapper copyWith({
    TextTheme? textTheme,
    ColorScheme? lightColorScheme,
    ColorScheme? darkColorScheme,
  }) {
    return ModernThemeDataWrapper(
      textTheme: textTheme ?? this.textTheme,
      lightColorScheme: lightColorScheme ?? this.lightColorScheme,
      darkColorScheme: darkColorScheme ?? this.darkColorScheme,
    );
  }
}
