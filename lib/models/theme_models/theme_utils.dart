import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class ThemeWrapperUtils {
  ThemeWrapperUtils._();

  static ColorScheme loadCustomColorSchemeFromStorage(
    GetStorage storage,
    String key, {
    Color defMainColor = Colors.blue,
    Color defBackgroundColor = Colors.pink,
  }) {
    final mainColor = _createColor(storage.read<int>('$key-mainColor')) ?? defMainColor;
    final backgroundColor = _createColor(storage.read<int>('$key-backgroundColor')) ?? defBackgroundColor;
    if (key.contains('light')) {
      return createLightColorScheme(mainColor, backgroundColor);
    } else if (key.contains('dark')) {
      return createDarkColorScheme(mainColor, backgroundColor);
    }
    throw ArgumentError('Incorrect storage key! $key');
  }

  static ColorScheme createLightColorScheme(Color mainColor, Color backgroundColor) {
    return ColorScheme.light(
      primary: mainColor,
      primaryVariant: mainColor,
      secondary: mainColor,
      secondaryVariant: mainColor,
      background: backgroundColor,
      surface: mainColor,
      error: Colors.redAccent,
    );
  }

  static ColorScheme createDarkColorScheme(Color mainColor, Color backgroundColor) {
    return ColorScheme.dark(
      primary: mainColor,
      primaryVariant: mainColor,
      secondary: mainColor,
      secondaryVariant: mainColor,
      background: backgroundColor,
      surface: mainColor,
      error: Colors.redAccent,
    );
  }

  /// [colorValue] - численное представление цвета
  static Color? _createColor(int? colorValue) => colorValue != null ? Color(colorValue) : null;
}
