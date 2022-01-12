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
        stops: (json['stops'] as List<dynamic>?)?.map((e) => e as double).toList(),
        colors: (json['colors'] as List<dynamic>).map((e) => Color(e)).toList(),
        tileMode: TileMode.values.byName(json['tileMode'] as String),
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
      'stops': gradient.stops,
      'colors': gradient.colors.map((e) => e.value).toList(),
      'tileMode': gradient.tileMode.name,
    };
  }

  /// Формирование [BoxDecoration] по записи сформированной функцией [radialGradientToJson]
  static BoxDecoration radialGradientFromJson(Map<String, dynamic> json) {
    return BoxDecoration(
      gradient: RadialGradient(
        center: Alignment(json['center_x'] as double, json['center_y'] as double),
        focal: _createAlignment(json['focal_x'] as double?, json['focal_y'] as double?),
        focalRadius: json['focalRadius'] as double,
        radius: json['radius'] as double,
        stops: (json['stops'] as List<dynamic>?)?.map((e) => e as double).toList(),
        colors: (json['colors'] as List<dynamic>).map((e) => Color(e)).toList(),
        tileMode: TileMode.values.byName(json['tileMode'] as String),
      ),
    );
  }

  /// Формирование json из [BoxDecoration], обратная операция представлена функцией [radialGradientFromJson]
  static Map<String, dynamic> radialGradientToJson(BoxDecoration decoration) {
    if (decoration.gradient is! RadialGradient) {
      throw ArgumentError('Not a RadialGradient - ${decoration.gradient.runtimeType}');
    }
    final gradient = decoration.gradient as RadialGradient;
    return <String, dynamic>{
      'center_x': (gradient.center as Alignment).x,
      'center_y': (gradient.center as Alignment).y,
      'focal_x': (gradient.focal as Alignment?)?.x,
      'focal_y': (gradient.focal as Alignment?)?.y,
      'focalRadius': gradient.focalRadius,
      'radius': gradient.radius,
      'stops': gradient.stops,
      'colors': gradient.colors.map((e) => e.value).toList(),
      'tileMode': gradient.tileMode.name,
    };
  }

  /// Вспомогательный метод возвращающий nullable Alignment, необходим, чтобы не засорять методы парсинга JSON
  static Alignment? _createAlignment(double? x, double? y) => x != null && y != null ? Alignment(x, y) : null;
}
