import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shop_list/models/theme_model.dart';

@immutable
abstract class ThemeDataWrapper {
  /// Ключи для записи/чтения тем из хранилища
  static const appThemeStorageKey = 'app_theme_storage_key';

  const ThemeDataWrapper({
    required this.textTheme,
    required this.lightColorSchemeWrapper,
    required this.darkColorSchemeWrapper,
  });

  final TextTheme textTheme;

  /// Текущая темная цветовая схема
  final ColorSchemeWrapper lightColorSchemeWrapper;

  /// Текущая светлая цветовая схема
  final ColorSchemeWrapper darkColorSchemeWrapper;

  /// Все допустимы цветовые схемы в светлой теме
  Map<String, ColorSchemeWrapper> get lightColorSchemesWrapperMap;

  /// Все допустимы цветовые схемы в темной теме
  Map<String, ColorSchemeWrapper> get darkColorSchemesWrapperMap;

  ThemeData get lightTheme => _generateThemeData(lightColorSchemeWrapper.colorScheme);

  ThemeData get darkTheme => _generateThemeData(darkColorSchemeWrapper.colorScheme);

  ThemeData _generateThemeData(ColorScheme colorScheme) {
    final mainTextColor = colorScheme.primary.calcTextColor;
    final backgroundTextColor = colorScheme.background.calcTextColor;
    return ThemeData(
      scaffoldBackgroundColor: colorScheme.background,
      // Не формирую ColorScheme заранее, т.к. при инициализации
      // пришлось бы рассчитывать дорогостоящий метод Color.computeLuminance
      // для каждой доступной ColorsScheme. Т.е. "пожертвовал" чистотой кода в угоду оптимизации
      colorScheme: colorScheme.copyWith(
        onPrimary: mainTextColor,
        onSecondary: mainTextColor,
        onSurface: mainTextColor,
        onBackground: backgroundTextColor,
      ),
      brightness: colorScheme.brightness,
      textTheme: textTheme.apply(
        bodyColor: backgroundTextColor,
      ),
    );
  }

  /// Наименование темы, а также префикс ключей по которым будет производится запись и чтение в хранилище
  String get themePrefix;

  /// Префикс ключа для сохранения значений в хранилище со светлой темой
  String get _lightThemeStorageKey => '$themePrefix-light';

  /// Префикс ключа для сохранения значений в хранилище с темной темой
  String get _darkThemeStorageKey => '$themePrefix-dark';

  /// Запись собранной темы в хранилище
  @mustCallSuper
  void writeToGetStorage(GetStorage storage) {
    // Запись названий текущих цветовых тем
    storage.write(
      _lightThemeStorageKey,
      lightColorSchemesWrapperMap.entries.firstWhere((element) => element.value == lightColorSchemeWrapper).key,
    );
    storage.write(
      _darkThemeStorageKey,
      darkColorSchemesWrapperMap.entries.firstWhere((element) => element.value == darkColorSchemeWrapper).key,
    );

    // Запись кастомных цветов светлой темы и темной. Не очень нравится идея разбивать кастомную цветовую схему
    // по строковым константам и отталкиваться от типа ключа при использовании в виджетах, как мне кажется,
    // лучше было бы использовать систему классов с наследованием (полиморфизм), но пока оставлю как есть.
    storage.write(
      '$themePrefix-custom-light-mainColor',
      lightColorSchemesWrapperMap['custom light']!.colorScheme.primary.value,
    );
    storage.write(
      '$themePrefix-custom-light-backgroundColor',
      lightColorSchemesWrapperMap['custom light']!.colorScheme.background.value,
    );
    storage.write(
      '$themePrefix-custom-dark-mainColor',
      darkColorSchemesWrapperMap['custom dark']!.colorScheme.primary.value,
    );
    storage.write(
      '$themePrefix-custom-dark-backgroundColor',
      darkColorSchemesWrapperMap['custom dark']!.colorScheme.background.value,
    );
  }

  ThemeDataWrapper copyWith({
    TextTheme? textTheme,
    ColorSchemeWrapper? lightColorSchemeWrapper,
    ColorSchemeWrapper? darkColorSchemeWrapper,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeDataWrapper &&
          runtimeType == other.runtimeType &&
          textTheme == other.textTheme &&
          lightColorSchemeWrapper == other.lightColorSchemeWrapper &&
          darkColorSchemeWrapper == other.darkColorSchemeWrapper;

  @override
  int get hashCode => textTheme.hashCode ^ lightColorSchemeWrapper.hashCode ^ darkColorSchemeWrapper.hashCode;
}

/// Класс обертка над ColorScheme, расширяя которую можно добавлять новые поля
@immutable
class ColorSchemeWrapper {
  const ColorSchemeWrapper(this.colorScheme);

  final ColorScheme colorScheme;

  ColorSchemeWrapper copyWith({
    ColorScheme? colorScheme,
  }) {
    return ColorSchemeWrapper(colorScheme ?? this.colorScheme);
  }
}
