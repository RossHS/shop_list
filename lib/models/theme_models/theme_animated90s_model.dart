import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shop_list/models/theme_model.dart';
import 'package:shop_list/widgets/animated90s/animated_90s.dart';

class Animated90sThemeDataWrapper extends ThemeDataWrapper {
  const Animated90sThemeDataWrapper({
    required super.textTheme,
    required this.paint90sConfig,
    this.animationDuration = const Duration(milliseconds: 80),
    required super.lightColorScheme,
    required super.darkColorScheme,
  });

  factory Animated90sThemeDataWrapper.fromGetStorage(GetStorage storage) {
    final textTheme = TextThemeCollection.fromString(storage.read<String>('textTheme'));
    final paint90sConfig = Paint90sConfig(
      offset: storage.read<int>('$appThemeStorageValue-paintConfig-offset'),
      strokeWidth: storage.read<double>('$appThemeStorageValue-paintConfig-strokeWidth'),
    );
    final animationDurationMillis = storage.read<int>('$appThemeStorageValue-animation-duration-millis');
    // Вычитываем название сохраненной цветовой темы из хранилища
    final String lightThemeKey = storage.read<String>('$appThemeStorageValue-light') ?? 'default light 1';
    final String darkThemeKey = storage.read<String>('$appThemeStorageValue-dark') ?? 'default dark 1';
    return Animated90sThemeDataWrapper(
      textTheme: textTheme,
      paint90sConfig: paint90sConfig,
      animationDuration: Duration(milliseconds: animationDurationMillis ?? 80),
      lightColorScheme: _getLightColorSchemesMap[lightThemeKey]!,
      darkColorScheme: _getDarkColorSchemesMap[darkThemeKey]!,
    );
  }

  static const appThemeStorageValue = 'Animated90s';

  /// Так как классы тем неизменяемые и нам следует динамически
  /// загружать/менять цветовую схему на основании данных из коллекций.
  /// Для соблюдений этих условий пришлось бы каждый раз создавать новые коллекции
  /// и по новой их заполнять - что не очень оптимально, т.к. лишняя, бесполезная
  /// работа процессора. Таким образом, вывел данные коллекции в
  /// статическую область и заполняю их лишь при первом обращении.
  /// Не использую единую мапу с ColorScheme, т.к. предполагается,
  /// что каждая тема имеет свой уникальный набор цветов
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
      'default dark 1': ThemeWrapperUtils.createDarkColorScheme(Colors.yellow, Colors.purple),
      'default dark 2': ThemeWrapperUtils.createDarkColorScheme(Colors.blueGrey, Colors.pink),
      'custom dark':
          ThemeWrapperUtils.loadCustomColorSchemeFromStorage(GetStorage(), '$appThemeStorageValue-custom-dark'),
    };
    assert(_darkColorSchemesMap != null && _darkColorSchemesMap!.isNotEmpty);
    return _darkColorSchemesMap!;
  }

  /// Стандартный кофиг для темы Animated90sThemeDataWrapper,
  /// на его основе абстрактная фабрика [Animated90sFactory] создает виджеты
  final Paint90sConfig paint90sConfig;

  /// Задержка между перерисовыванием Animated90sWidgets
  final Duration animationDuration;

  @override
  Map<String, ColorScheme> get lightColorSchemesMap => _getLightColorSchemesMap;

  @override
  Map<String, ColorScheme> get darkColorSchemesMap => _getDarkColorSchemesMap;

  @override
  String get themePrefix => Animated90sThemeDataWrapper.appThemeStorageValue;

  @override
  void writeToGetStorage(GetStorage storage) {
    super.writeToGetStorage(storage);
    storage.write('$appThemeStorageValue-paintConfig-offset', paint90sConfig.offset);
    storage.write('$appThemeStorageValue-paintConfig-strokeWidth', paint90sConfig.strokeWidth);
    storage.write('$appThemeStorageValue-animation-duration-millis', animationDuration.inMilliseconds);
  }

  @override
  Animated90sThemeDataWrapper copyWith({
    TextTheme? textTheme,
    Paint90sConfig? paint90sConfig,
    Duration? animationDuration,
    ColorScheme? lightColorScheme,
    ColorScheme? darkColorScheme,
  }) {
    return Animated90sThemeDataWrapper(
      textTheme: textTheme ?? this.textTheme,
      paint90sConfig: paint90sConfig ?? this.paint90sConfig,
      animationDuration: animationDuration ?? this.animationDuration,
      lightColorScheme: lightColorScheme ?? this.lightColorScheme,
      darkColorScheme: darkColorScheme ?? this.darkColorScheme,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is Animated90sThemeDataWrapper &&
          runtimeType == other.runtimeType &&
          paint90sConfig == other.paint90sConfig &&
          animationDuration == other.animationDuration;

  @override
  int get hashCode => super.hashCode ^ paint90sConfig.hashCode ^ animationDuration.hashCode;
}
