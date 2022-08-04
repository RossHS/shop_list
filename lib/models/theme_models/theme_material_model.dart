import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shop_list/models/theme_model.dart';

class MaterialThemeDataWrapper extends ThemeDataWrapper {
  const MaterialThemeDataWrapper({
    required super.textTheme,
    double? rounded,
    double? shadowBlurRadius,
    Color? shadowColor,
    Offset? shadowOffset,
    required super.lightColorScheme,
    required super.darkColorScheme,
  })  : assert(rounded == null || (rounded >= 0 && rounded <= 30)),
        assert(shadowBlurRadius == null || (shadowBlurRadius >= 0 && shadowBlurRadius <= 20)),
        rounded = rounded ?? 10,
        shadowBlurRadius = shadowBlurRadius ?? 6,
        shadowColor = shadowColor ?? Colors.grey,
        shadowOffset = shadowOffset ?? const Offset(0, 1);

  factory MaterialThemeDataWrapper.fromGetStorage(GetStorage storage) {
    final textTheme = TextThemeCollection.fromString(storage.read<String>('textTheme'));
    // Вычитываем название сохраненной темы из хранилища
    final String lightThemeKey = storage.read<String>('$appThemeStorageValue-light') ?? 'default light 1';
    final String darkThemeKey = storage.read<String>('$appThemeStorageValue-dark') ?? 'default dark 1';
    final rounded = storage.read<double>('$appThemeStorageValue-rounded');
    final shadowBlurRadius = storage.read<double>('$appThemeStorageValue-shadowBlurRadius');
    final shadowColor = Color(storage.read<int>('$appThemeStorageValue-shadowColor') ?? Colors.grey.value);
    final offsetX = storage.read<double>('$appThemeStorageValue-shadowOffsetX');
    final offsetY = storage.read<double>('$appThemeStorageValue-shadowOffsetY');

    Offset? offset;
    if (offsetX != null && offsetY != null) {
      offset = Offset(offsetX, offsetY);
    }

    return MaterialThemeDataWrapper(
      textTheme: textTheme,
      rounded: rounded,
      shadowBlurRadius: shadowBlurRadius,
      shadowColor: shadowColor,
      shadowOffset: offset,
      lightColorScheme: _getLightColorSchemesMap[lightThemeKey]!,
      darkColorScheme: _getDarkColorSchemesMap[darkThemeKey]!,
    );
  }

  static const appThemeStorageValue = 'Material';

  /// Скругление основных виджетов material
  final double rounded;

  /// Радиус тени в [BoxShadow]
  final double shadowBlurRadius;

  /// Цвет тени в [BoxShadow]
  final Color shadowColor;

  /// Отступ тени
  final Offset shadowOffset;

  /// Генерация стандартного объекта [BoxDecoration]
  BoxDecoration buildDefaultBoxDecoration(BuildContext context) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(rounded),
      color: Theme.of(context).canvasColor,
      boxShadow: [
        BoxShadow(
          color: shadowColor,
          offset: shadowOffset, //(x,y)
          blurRadius: shadowBlurRadius,
        ),
      ],
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
      'default dark 1': ThemeWrapperUtils.createDarkColorScheme(Colors.blueGrey, Colors.brown),
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
  String get themePrefix => MaterialThemeDataWrapper.appThemeStorageValue;

  @override
  void writeToGetStorage(GetStorage storage) {
    super.writeToGetStorage(storage);
    storage.write('$appThemeStorageValue-rounded', rounded);
    storage.write('$appThemeStorageValue-shadowBlurRadius', shadowBlurRadius);
    storage.write('$appThemeStorageValue-shadowColor', shadowColor.value);
    storage.write('$appThemeStorageValue-shadowOffsetX', shadowOffset.dx);
    storage.write('$appThemeStorageValue-shadowOffsetY', shadowOffset.dy);
  }

  @override
  MaterialThemeDataWrapper copyWith({
    TextTheme? textTheme,
    double? rounded,
    double? shadowBlurRadius,
    Color? shadowColor,
    Offset? shadowOffset,
    ColorScheme? lightColorScheme,
    ColorScheme? darkColorScheme,
  }) {
    return MaterialThemeDataWrapper(
      textTheme: textTheme ?? this.textTheme,
      rounded: rounded ?? this.rounded,
      shadowBlurRadius: shadowBlurRadius ?? this.shadowBlurRadius,
      shadowColor: shadowColor ?? this.shadowColor,
      shadowOffset: shadowOffset ?? this.shadowOffset,
      lightColorScheme: lightColorScheme ?? this.lightColorScheme,
      darkColorScheme: darkColorScheme ?? this.darkColorScheme,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is MaterialThemeDataWrapper &&
          runtimeType == other.runtimeType &&
          rounded == other.rounded &&
          shadowBlurRadius == other.shadowBlurRadius &&
          shadowColor == other.shadowColor &&
          shadowOffset == other.shadowOffset;

  @override
  int get hashCode =>
      super.hashCode ^ rounded.hashCode ^ shadowBlurRadius.hashCode ^ shadowColor.hashCode ^ shadowOffset.hashCode;
}
