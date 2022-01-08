import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logging/logging.dart';
import 'package:shop_list/models/theme_model.dart';

final _log = Logger('ModernThemeDataWrapper');

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

const _decorationTypeKey = '${ModernThemeDataWrapper.appThemeStorageValue}-decoration-type';
const _decorationMapKey = '${ModernThemeDataWrapper.appThemeStorageValue}-decoration-map';

void _writeToGetStorageDecoration(GetStorage storage, BoxDecoration decoration) {
  if (decoration.color != null) {
    storage.write(_decorationTypeKey, 'just_color');
    storage.write(_decorationMapKey, ThemeWrapperUtils.justColorToJson(decoration));
  } else if (decoration.gradient is LinearGradient) {
    storage.write(_decorationTypeKey, 'linear_gradient');
    storage.write(_decorationMapKey, ThemeWrapperUtils.linearGradientToJson(decoration));
  } else if (decoration.gradient is RadialGradient) {
    storage.write(_decorationTypeKey, 'radial_gradient');
    storage.write(_decorationMapKey, ThemeWrapperUtils.radialGradientToJson(decoration));
  } else {
    _log.shout('Unsupported BoxDecoration type - $decoration');
    throw ArgumentError.value(decoration, 'Unsupported BoxDecoration type');
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
      return ThemeWrapperUtils.justColorFromJson(decorationMap);
    case 'linear_gradient':
      return ThemeWrapperUtils.linearGradientFromJson(decorationMap);
    case 'radial_gradient':
      return ThemeWrapperUtils.radialGradientFromJson(decorationMap);
    default:
      _log.shout('Unknown decorationType value - $decorationType');
      throw ArgumentError.value(decorationType, 'Unknown decorationType value');
  }
}
