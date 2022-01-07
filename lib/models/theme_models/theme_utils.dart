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

  /// Формирование [BoxDecoration] по записи сформированной функцией [justColorToJson]
  static BoxDecoration justColorFromJson(Map<String, dynamic> json) {
    return BoxDecoration(
      color: Color(json['color'] as int),
    );
  }

  /// Формирование json из [BoxDecoration], обратная операция представлена функцией [justColorFromJson]
  static Map<String, dynamic> justColorToJson(BoxDecoration decoration) => <String, dynamic>{
        'color': decoration.color!.value,
      };

  /// Формирование [BoxDecoration] по записи сформированной функцией [linearGradientToJson]
  static BoxDecoration linearGradientFromJson(Map<String, dynamic> json) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment(json['begin_x'] as double, json['begin_y'] as double),
        end: Alignment(json['end_x'] as double, json['end_y'] as double),
        colors: (json['colors'] as List<dynamic>).map((e) => Color(e)).toList(),
      ),
    );
  }

  /// Формирование json из [BoxDecoration], обратная операция представлена функцией [linearGradientFromJson]
  static Map<String, dynamic> linearGradientToJson(BoxDecoration decoration) {
    if (decoration.gradient is! LinearGradient) {
      throw ArgumentError('Not a LinearGradient - ${decoration.gradient.runtimeType}');
    }
    final gradient = decoration.gradient as LinearGradient;
    return <String, dynamic>{
      'begin_x': (gradient.begin as Alignment).x,
      'begin_y': (gradient.begin as Alignment).y,
      'end_x': (gradient.end as Alignment).x,
      'end_y': (gradient.end as Alignment).y,
      'colors': gradient.colors.map((e) => e.value).toList(),
    };
  }

  /// Формирование [BoxDecoration] по записи сформированной функцией [radialGradientToJson]
  static BoxDecoration radialGradientFromJson(Map<String, dynamic> json) {
    // TODO 06.01.2022 дописать реализацию
    return BoxDecoration(
      gradient: RadialGradient(
        colors: (json['colors'] as List<dynamic>).map((e) => Color(e)).toList(),
      ),
    );
  }

  /// Формирование json из [BoxDecoration], обратная операция представлена функцией [radialGradientFromJson]
  static Map<String, dynamic> radialGradientToJson(BoxDecoration decoration) {
    // TODO 06.01.2022 дописать реализацию
    if (decoration.gradient is! RadialGradient) {
      throw ArgumentError('Not a RadialGradient - ${decoration.gradient.runtimeType}');
    }
    final gradient = decoration.gradient as RadialGradient;
    return <String, dynamic>{
      'colors': gradient.colors.map((e) => e.value).toList(),
    };
  }
}
