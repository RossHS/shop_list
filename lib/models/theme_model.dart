import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

abstract class ThemeDataWrapper {
  /// Ключи для записи/чтения тем из хранилища
  static const appThemeStorageKey = 'app_theme_storage_key';

  static const lightStorageKey = 'light';
  static const darkStorageKey = 'dark';

  ThemeData get lightTheme;

  ThemeData get darkTheme;

  /// Наименование темы, а также префикс ключей по которым будет производится запись и чтение в хранилище
  String get themePrefix;

  /// Префикс ключа для сохранения значений в хранилище со светлой темой
  String get _lightThemeStorageKey => '$themePrefix-$lightStorageKey';

  /// Префикс ключа для сохранения значений в хранилище с темной темой
  String get _darkThemeStorageKey => '$themePrefix-$darkStorageKey';

  /// Запись собранной темы в хранилище
  void writeToGetStorage(GetStorage storage);
}

//----------------------------Animated90sThemeData------------------------//
class Animated90sThemeData extends ThemeDataWrapper {
  static const appThemeStorageValue = 'Animated90s';

  Animated90sThemeData();

  factory Animated90sThemeData.fromGetStorage(GetStorage storage) {
    return Animated90sThemeData();
  }

  @override
  ThemeData get lightTheme => ThemeData(
        scaffoldBackgroundColor: Colors.yellow,
        brightness: Brightness.light,
      );

  @override
  ThemeData get darkTheme => ThemeData(
        scaffoldBackgroundColor: Colors.blueGrey,
        brightness: Brightness.dark,
      );

  @override
  String get themePrefix => Animated90sThemeData.appThemeStorageValue;

  @override
  void writeToGetStorage(GetStorage storage) {}

  // TODO: implement
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Animated90sThemeData && runtimeType == other.runtimeType;

  // TODO: implement
  @override
  int get hashCode => 0;
}

//----------------------------MaterialThemeData--------------------------//
class MaterialThemeData extends ThemeDataWrapper {
  static const appThemeStorageValue = 'Material';

  MaterialThemeData();

  factory MaterialThemeData.fromGetStorage(GetStorage storage) {
    return MaterialThemeData();
  }

  @override
  ThemeData get lightTheme => ThemeData(
        scaffoldBackgroundColor: Colors.white,
        brightness: Brightness.light,
      );

  @override
  ThemeData get darkTheme => ThemeData(
        scaffoldBackgroundColor: Colors.grey,
        brightness: Brightness.dark,
      );

  @override
  String get themePrefix => MaterialThemeData.appThemeStorageValue;

  @override
  void writeToGetStorage(GetStorage storage) {
    // TODO: implement writeToGetStorage
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MaterialThemeData && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}

//----------------------------ModernThemeData---------------------------//
class ModernThemeData extends ThemeDataWrapper {
  static const appThemeStorageValue = 'Modern';

  ModernThemeData();

  factory ModernThemeData.fromGetStorage(GetStorage storage) {
    return ModernThemeData();
  }

  @override
  ThemeData get lightTheme => ThemeData(
        scaffoldBackgroundColor: Colors.green,
        brightness: Brightness.light,
      );

  @override
  ThemeData get darkTheme => ThemeData(
        scaffoldBackgroundColor: Colors.red,
        brightness: Brightness.dark,
      );

  @override
  String get themePrefix => ModernThemeData.appThemeStorageValue;

  @override
  void writeToGetStorage(GetStorage storage) {
    // TODO: implement writeToGetStorage
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ModernThemeData && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}
