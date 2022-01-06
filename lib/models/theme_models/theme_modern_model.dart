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
  Map<String, GradientBackground> get lightColorSchemesWrapperMap => _getLightColorSchemesWrapperMap;

  @override
  Map<String, GradientBackground> get darkColorSchemesWrapperMap => _getDarkColorSchemesWrapperMap;

  @override
  String get themePrefix => ModernThemeDataWrapper.appThemeStorageValue;

  @override
  GradientBackground getColorSchemeWrapper(BuildContext context) {
    return super.getColorSchemeWrapper(context) as GradientBackground;
  }

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
      colorScheme: ThemeWrapperUtils.createLightColorScheme(Colors.black, Colors.black),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Colors.blue,
            Colors.red,
          ],
        ),
      ),
    ),
    'default light 2': GradientBackground(
      colorScheme: ThemeWrapperUtils.createLightColorScheme(Colors.blue, Colors.blue),
      decoration: const BoxDecoration(color: Colors.green),
    ),
    'custom light': GradientBackground(
      colorScheme: ThemeWrapperUtils.loadCustomColorSchemeFromStorage(
        GetStorage(),
        '${ModernThemeDataWrapper.appThemeStorageValue}-custom-light',
        defMainColor: Colors.greenAccent,
        defBackgroundColor: Colors.greenAccent,
      ),
      decoration: const BoxDecoration(color: Colors.pink),
    ),
  };
  assert(_lightColorSchemesWrapperMap != null && _lightColorSchemesWrapperMap!.isNotEmpty);
  return _lightColorSchemesWrapperMap!;
}

Map<String, GradientBackground> get _getDarkColorSchemesWrapperMap {
  _darkColorSchemesWrapperMap ??= {
    'default dark 1': GradientBackground.withDefault(
      keyPrefix: '${ModernThemeDataWrapper.appThemeStorageValue} default dark 1',
      defaultGradientBackground: GradientBackground(
        colorScheme: ThemeWrapperUtils.createDarkColorScheme(Colors.white, Colors.white),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.white,
              Colors.black,
            ],
          ),
        ),
      ),
    ),
    'default dark 2': GradientBackground.withDefault(
      keyPrefix: '${ModernThemeDataWrapper.appThemeStorageValue} default dark 2',
      defaultGradientBackground: GradientBackground(
        colorScheme: ThemeWrapperUtils.createDarkColorScheme(Colors.blueGrey, Colors.blueGrey),
        decoration: const BoxDecoration(color: Colors.red),
      ),
    ),
    'custom dark': GradientBackground.withDefault(
      keyPrefix: '${ModernThemeDataWrapper.appThemeStorageValue}-custom-dark',
      defaultGradientBackground: GradientBackground(
        colorScheme: ThemeWrapperUtils.createDarkColorScheme(Colors.black, Colors.black),
        decoration: const BoxDecoration(color: Colors.red),
      ),
    ),
  };
  assert(_darkColorSchemesWrapperMap != null && _darkColorSchemesWrapperMap!.isNotEmpty);
  return _darkColorSchemesWrapperMap!;
}

@immutable
class GradientBackground extends ColorSchemeWrapper {
  const GradientBackground({
    required ColorScheme colorScheme,
    required this.decoration,
    this.defaultGradientBackground,
  }) : super(colorScheme);

  // TODO 06.01.2022 различные типы boxDecoration
  final BoxDecoration decoration;

  /// Дефолтное значение [GradientBackground] необходимое в случае сброса значений
  /// TODO 06.01.2022 стоит вынести в отдельный класс, дабы не нарушать принципы SOLID
  final GradientBackground? defaultGradientBackground;

  /// Создание обертки на основе записи в хранилище по ключу [keyPrefix],
  /// если записи нет, то используется значение по умолчанию [defaultGradientBackground]
  factory GradientBackground.withDefault({
    required GradientBackground defaultGradientBackground,
    required String keyPrefix,
  }) {
    final colorScheme = ThemeWrapperUtils.loadCustomColorSchemeFromStorage(
      GetStorage(),
      keyPrefix,
      defMainColor: defaultGradientBackground.colorScheme.primary,
      defBackgroundColor: defaultGradientBackground.colorScheme.background,
    );
    // final decoration =_decorationLoadFromGetStorage
    return GradientBackground(
      colorScheme: colorScheme,
      decoration: defaultGradientBackground.decoration,
      defaultGradientBackground: defaultGradientBackground,
    );
  }

  @override
  GradientBackground copyWith({
    ColorScheme? colorScheme,
    BoxDecoration? decoration,
    GradientBackground? defaultGradientBackground,
  }) {
    return GradientBackground(
      colorScheme: colorScheme ?? this.colorScheme,
      decoration: decoration ?? this.decoration,
      defaultGradientBackground: defaultGradientBackground ?? this.defaultGradientBackground,
    );
  }

  @override
  void writeToGetStorage(GetStorage storage, {required String keyPrefix}) {
    super.writeToGetStorage(storage, keyPrefix: keyPrefix);
    _decorationWriteToGetStorage(storage, decoration, keyPrefix);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is GradientBackground &&
          runtimeType == other.runtimeType &&
          decoration == other.decoration;

  @override
  int get hashCode => super.hashCode ^ decoration.hashCode;

  static void _decorationWriteToGetStorage(
    GetStorage storage,
    BoxDecoration decoration,
    String keyPrefix,
  ) {
    if (decoration.color != null) {}
  }

// static BoxDecoration _decorationLoadFromGetStorage(GetStorage storage,
//     BoxDecoration decoration,
//     String keyPrefix,) {}
}
