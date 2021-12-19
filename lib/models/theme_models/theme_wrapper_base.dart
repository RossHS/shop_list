import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shop_list/models/theme_model.dart';

@immutable
abstract class ThemeDataWrapper {
  /// Ключи для записи/чтения тем из хранилища
  static const appThemeStorageKey = 'app_theme_storage_key';

  const ThemeDataWrapper({
    required this.textTheme,
    required this.lightColorScheme,
    required this.darkColorScheme,
  });

  final TextTheme textTheme;

  /// Текущая темная цветовая схема
  final ColorScheme lightColorScheme;

  /// Текущая светлая цветовая схема
  final ColorScheme darkColorScheme;

  /// Все допустимы цветовые схемы в светлой теме
  Map<String, ColorScheme> get lightColorSchemesMap;

  /// Все допустимы цветовые схемы в темной теме
  Map<String, ColorScheme> get darkColorSchemesMap;

  ThemeData get lightTheme => _generateColorScheme(lightColorScheme);

  ThemeData get darkTheme => _generateColorScheme(darkColorScheme);

  ThemeData _generateColorScheme(ColorScheme colorScheme) {
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
      lightColorSchemesMap.entries.firstWhere((element) => element.value == lightColorScheme).key,
    );
    storage.write(
      _darkThemeStorageKey,
      darkColorSchemesMap.entries.firstWhere((element) => element.value == darkColorScheme).key,
    );

    // Запись кастомных цветов светлой темы и темной. Не очень нравится идея разбивать кастомную цветовую схему
    // по строковым константам и отталкиваться от типа ключа при использовании в виджетах, как мне кажется,
    // лучше было бы использовать систему классов с наследованием (полиморфизм), но пока оставлю как есть.
    // TODO 07.12.2021 подумать об идеи с классами цветовых схем (обертками над ColorScheme)
    storage.write('$themePrefix-custom-light-mainColor', lightColorSchemesMap['custom light']!.primary.value);
    storage.write('$themePrefix-custom-light-backgroundColor', lightColorSchemesMap['custom light']!.background.value);
    storage.write('$themePrefix-custom-dark-mainColor', darkColorSchemesMap['custom dark']!.primary.value);
    storage.write('$themePrefix-custom-dark-backgroundColor', darkColorSchemesMap['custom dark']!.background.value);
  }

  ThemeDataWrapper copyWith({
    TextTheme? textTheme,
    ColorScheme? lightColorScheme,
    ColorScheme? darkColorScheme,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeDataWrapper &&
          runtimeType == other.runtimeType &&
          textTheme == other.textTheme &&
          lightColorScheme == other.lightColorScheme &&
          darkColorScheme == other.darkColorScheme;

  @override
  int get hashCode => textTheme.hashCode ^ lightColorScheme.hashCode ^ darkColorScheme.hashCode;
}
