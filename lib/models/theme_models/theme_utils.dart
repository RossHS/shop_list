import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class ThemeWrapperUtils {
  ThemeWrapperUtils._();

  static ColorScheme loadCustomColorSchemeFromStorage(GetStorage storage, String key) {
    final mainColor = Color(storage.read<int>('$key-mainColor') ?? Colors.blue.value);
    final backgroundColor = Color(storage.read<int>('$key-backgroundColor') ?? Colors.pink.value);
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
      primaryContainer: mainColor,
      secondary: mainColor,
      secondaryContainer: mainColor,
      background: backgroundColor,
      surface: mainColor,
      error: Colors.redAccent,
    );
  }

  static ColorScheme createDarkColorScheme(Color mainColor, Color backgroundColor) {
    return ColorScheme.dark(
      primary: mainColor,
      primaryContainer: mainColor,
      secondary: mainColor,
      secondaryContainer: mainColor,
      background: backgroundColor,
      surface: mainColor,
      error: Colors.redAccent,
    );
  }
}
