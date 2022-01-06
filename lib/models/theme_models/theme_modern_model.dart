import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shop_list/models/theme_model.dart';

class ModernThemeDataWrapper extends ThemeDataWrapper {
  static const appThemeStorageValue = 'Modern';

  const ModernThemeDataWrapper({
    required TextTheme textTheme,
    required ColorScheme lightColorScheme,
    required ColorScheme darkColorScheme,
    required this.backgroundDecoration,
  }) : super(
          textTheme: textTheme,
          lightColorScheme: lightColorScheme,
          darkColorScheme: darkColorScheme,
        );

  factory ModernThemeDataWrapper.fromGetStorage(GetStorage storage) {
    final textTheme = TextThemeCollection.fromString(storage.read<String>('textTheme'));
    final lightThemeKey = storage.read<String>('$appThemeStorageValue-light') ?? 'default light 1';
    final darkThemeKey = storage.read<String>('$appThemeStorageValue-dark') ?? 'default dark 1';
    final boxDecoration = _parseDecorationBox(storage);
    return ModernThemeDataWrapper(
      textTheme: textTheme,
      lightColorScheme: _getLightColorSchemesMap[lightThemeKey]!,
      darkColorScheme: _getDarkColorSchemesMap[darkThemeKey]!,
      backgroundDecoration: boxDecoration,
    );
  }

  /// Почему так, объяснение в комментариях [Animated90sThemeDataWrapper._lightColorSchemesMap]
  static Map<String, ColorScheme>? _lightColorSchemesMap;
  static Map<String, ColorScheme>? _darkColorSchemesMap;

  static Map<String, ColorScheme> get _getLightColorSchemesMap {
    _lightColorSchemesMap ??= {
      'default light 1': ThemeWrapperUtils.createLightColorScheme(Colors.green, Colors.green),
      'default light 2': ThemeWrapperUtils.createLightColorScheme(Colors.blue, Colors.blue),
      'custom light': ThemeWrapperUtils.loadCustomColorSchemeFromStorage(
        GetStorage(),
        '$appThemeStorageValue-custom-light',
        defMainColor: Colors.white,
        defBackgroundColor: Colors.white,
      ),
    };
    assert(_lightColorSchemesMap != null && _lightColorSchemesMap!.isNotEmpty);
    return _lightColorSchemesMap!;
  }

  static Map<String, ColorScheme> get _getDarkColorSchemesMap {
    _darkColorSchemesMap ??= {
      'default dark 1': ThemeWrapperUtils.createDarkColorScheme(Colors.redAccent, Colors.redAccent),
      'default dark 2': ThemeWrapperUtils.createDarkColorScheme(Colors.blueGrey, Colors.blueGrey),
      'custom dark': ThemeWrapperUtils.loadCustomColorSchemeFromStorage(
        GetStorage(),
        '$appThemeStorageValue-custom-dark',
        defMainColor: Colors.black,
        defBackgroundColor: Colors.black,
      ),
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

  /// Задний фон
  final BoxDecoration backgroundDecoration;

  @override
  void writeToGetStorage(GetStorage storage) {
    super.writeToGetStorage(storage);
    _writeToGetStorageDecoration(storage, backgroundDecoration);
  }

  @override
  ModernThemeDataWrapper copyWith({
    TextTheme? textTheme,
    ColorScheme? lightColorScheme,
    ColorScheme? darkColorScheme,
    BoxDecoration? backgroundDecoration,
  }) {
    return ModernThemeDataWrapper(
      textTheme: textTheme ?? this.textTheme,
      lightColorScheme: lightColorScheme ?? this.lightColorScheme,
      darkColorScheme: darkColorScheme ?? this.darkColorScheme,
      backgroundDecoration: backgroundDecoration ?? this.backgroundDecoration,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is ModernThemeDataWrapper &&
          runtimeType == other.runtimeType &&
          backgroundDecoration == other.backgroundDecoration;

  @override
  int get hashCode => super.hashCode ^ backgroundDecoration.hashCode;
}

// TODO 06.01.2022 написать тесты
const _decorationTypeKey = '${ModernThemeDataWrapper.appThemeStorageValue}-decoration-type';
const _decorationMapKey = '${ModernThemeDataWrapper.appThemeStorageValue}-decoration-map';

void _writeToGetStorageDecoration(GetStorage storage, BoxDecoration decoration) {
  if (decoration.color != null) {
    storage.write(_decorationTypeKey, 'just_color');
    storage.write(_decorationMapKey, _justColorToJson(decoration));
  } else if (decoration.gradient is LinearGradient) {
    storage.write(_decorationTypeKey, 'linear_gradient');
    storage.write(_decorationMapKey, _linearGradientToJson(decoration));
  } else if (decoration.gradient is RadialGradient) {
    storage.write(_decorationTypeKey, 'radial_gradient');
    storage.write(_decorationMapKey, _radialGradientToJson(decoration));
  }
}

BoxDecoration _parseDecorationBox(GetStorage storage) {
  final decorationType = storage.read<String>(_decorationTypeKey);
  final decorationMap = storage.read<Map<String, dynamic>>(_decorationMapKey);
  // Если записей нет, то возвращаем стандартный BoxDecoration
  if (decorationType == null || decorationMap == null) {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Colors.blue,
          Colors.red,
        ],
      ),
    );
  }
  switch (decorationType) {
    case 'just_color':
      return _justColorFromJson(decorationMap);
    case 'linear_gradient':
      return _linearGradientFromJson(decorationMap);
    case 'radial_gradient':
      return _radialGradientFromJson(decorationMap);
    default:
      throw Exception('Unknown decorationType value - $decorationType');
  }
}

BoxDecoration _justColorFromJson(Map<String, dynamic> json) {
  return BoxDecoration(
    color: Color(json['color'] as int),
  );
}

Map<String, dynamic> _justColorToJson(BoxDecoration decoration) => <String, dynamic>{
      'color': decoration.color,
    };

BoxDecoration _linearGradientFromJson(Map<String, dynamic> json) {
  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment(json['begin_x'] as double, json['begin_y'] as double),
      end: Alignment(json['end_x'] as double, json['end_y'] as double),
      colors: (json['colors'] as List<dynamic>).map((e) => Color(e)).toList(),
    ),
  );
}

Map<String, dynamic> _linearGradientToJson(BoxDecoration decoration) {
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

// TODO 06.01.2022 дописать реализацию
BoxDecoration _radialGradientFromJson(Map<String, dynamic> json) {
  return BoxDecoration(
    gradient: RadialGradient(
      colors: (json['colors'] as List<dynamic>).map((e) => Color(e)).toList(),
    ),
  );
}

// TODO 06.01.2022 дописать реализацию
Map<String, dynamic> _radialGradientToJson(BoxDecoration decoration) {
  if (decoration.gradient is! RadialGradient) {
    throw ArgumentError('Not a RadialGradient - ${decoration.gradient.runtimeType}');
  }
  final gradient = decoration.gradient as RadialGradient;
  return <String, dynamic>{
    'colors': gradient.colors.map((e) => e.value).toList(),
  };
}
