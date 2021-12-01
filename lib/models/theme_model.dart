import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

abstract class ThemeDataWrapper {
  /// Ключи для записи/чтения тем из хранилища
  static const appThemeStorageKey = 'app_theme_storage_key';
  static const lightStorageKey = 'light';
  static const darkStorageKey = 'dark';

  ThemeDataWrapper({
    required this.textTheme,
  });

  final TextTheme textTheme;

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

  ThemeDataWrapper copyWith({required TextTheme textTheme});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeDataWrapper && runtimeType == other.runtimeType && textTheme == other.textTheme;

  @override
  int get hashCode => textTheme.hashCode;
}

//----------------------------Animated90sThemeData------------------------//
class Animated90sThemeData extends ThemeDataWrapper {
  static const appThemeStorageValue = 'Animated90s';

  Animated90sThemeData({
    required TextTheme textTheme,
  }) : super(textTheme: textTheme);

  factory Animated90sThemeData.fromGetStorage(GetStorage storage) {
    final textTheme = TextThemeCollection.fromString(storage.read<String>('textTheme'));
    return Animated90sThemeData(
      textTheme: textTheme,
    );
  }

  @override
  ThemeData get lightTheme => ThemeData(
        scaffoldBackgroundColor: Colors.yellow,
        brightness: Brightness.light,
        textTheme: textTheme,
      );

  @override
  ThemeData get darkTheme => ThemeData(
        scaffoldBackgroundColor: Colors.blueGrey,
        brightness: Brightness.dark,
        textTheme: textTheme,
      );

  @override
  String get themePrefix => Animated90sThemeData.appThemeStorageValue;

  @override
  void writeToGetStorage(GetStorage storage) {}

  @override
  Animated90sThemeData copyWith({TextTheme? textTheme}) {
    return Animated90sThemeData(
      textTheme: textTheme ?? this.textTheme,
    );
  }
}

//----------------------------MaterialThemeData--------------------------//
class MaterialThemeData extends ThemeDataWrapper {
  static const appThemeStorageValue = 'Material';

  MaterialThemeData({
    required TextTheme textTheme,
  }) : super(textTheme: textTheme);

  factory MaterialThemeData.fromGetStorage(GetStorage storage) {
    final textTheme = TextThemeCollection.fromString(storage.read<String>('textTheme'));
    return MaterialThemeData(
      textTheme: textTheme,
    );
  }

  @override
  ThemeData get lightTheme => ThemeData(
        scaffoldBackgroundColor: Colors.white,
        brightness: Brightness.light,
        textTheme: textTheme,
      );

  @override
  ThemeData get darkTheme => ThemeData(
        scaffoldBackgroundColor: Colors.grey,
        brightness: Brightness.dark,
        textTheme: textTheme,
      );

  @override
  String get themePrefix => MaterialThemeData.appThemeStorageValue;

  @override
  void writeToGetStorage(GetStorage storage) {
    // TODO: implement writeToGetStorage
  }

  @override
  MaterialThemeData copyWith({TextTheme? textTheme}) {
    return MaterialThemeData(
      textTheme: textTheme ?? this.textTheme,
    );
  }
}

//----------------------------ModernThemeData---------------------------//
class ModernThemeData extends ThemeDataWrapper {
  static const appThemeStorageValue = 'Modern';

  ModernThemeData({
    required TextTheme textTheme,
  }) : super(textTheme: textTheme);

  factory ModernThemeData.fromGetStorage(GetStorage storage) {
    final textTheme = TextThemeCollection.fromString(storage.read<String>('textTheme'));
    return ModernThemeData(
      textTheme: textTheme,
    );
  }

  @override
  ThemeData get lightTheme => ThemeData(
        scaffoldBackgroundColor: Colors.green,
        brightness: Brightness.light,
        textTheme: textTheme,
      );

  @override
  ThemeData get darkTheme => ThemeData(
        scaffoldBackgroundColor: Colors.red,
        brightness: Brightness.dark,
        textTheme: textTheme,
      );

  @override
  String get themePrefix => ModernThemeData.appThemeStorageValue;

  @override
  void writeToGetStorage(GetStorage storage) {
    // TODO: implement writeToGetStorage
  }

  @override
  ModernThemeData copyWith({TextTheme? textTheme}) {
    return ModernThemeData(
      textTheme: textTheme ?? this.textTheme,
    );
  }
}

class TextThemeCollection {
  TextThemeCollection._();

  static final Map<String, TextTheme> map = {
    rossTextThemeKey: rossTextTheme,
    androidTextThemeKey: androidTextTheme,
    androidWhiteTextThemeKey: androidWhiteTextTheme,
    androidBlackTextThemeKey: androidBlackTextTheme,
  };

  static TextTheme fromString(String? val) {
    if (val == null) {
      return rossTextTheme;
    }
    return TextThemeCollection.map[val]!;
  }

  static const rossTextThemeKey = 'RossFont';
  static const rossTextTheme = TextTheme(
    bodyText1: TextStyle(fontSize: 20, fontFamily: 'RossFont'),
    bodyText2: TextStyle(fontSize: 20, fontFamily: 'RossFont'),
    button: TextStyle(fontSize: 20, fontFamily: 'RossFont'),
    caption: TextStyle(fontSize: 18, fontFamily: 'RossFont'),
    headline1: TextStyle(fontSize: 118, fontFamily: 'RossFont'),
    headline2: TextStyle(fontSize: 62, fontFamily: 'RossFont'),
    headline3: TextStyle(fontSize: 51, fontFamily: 'RossFont'),
    headline4: TextStyle(fontSize: 40, fontFamily: 'RossFont'),
    headline5: TextStyle(fontSize: 30, fontFamily: 'RossFont'),
    headline6: TextStyle(fontSize: 26, fontFamily: 'RossFont'),
    overline: TextStyle(fontSize: 16, fontFamily: 'RossFont'),
    subtitle1: TextStyle(fontSize: 22, fontFamily: 'RossFont'),
    subtitle2: TextStyle(fontSize: 20, fontFamily: 'RossFont'),
  );

  static const androidTextThemeKey = 'Android';

  /// Скопировал тему из [Typography.whiteMountainView], только удалил обозначение цвета,
  /// переложив эту логику виджеты, таким образом само приложение будет устанавливать цвет
  /// шрифтов в зависимости от темы приложения [Brightness.light]/[Brightness.dark]
  static const androidTextTheme = TextTheme(
    headline1: TextStyle(debugLabel: 'mountainView headline1', fontFamily: 'Roboto', decoration: TextDecoration.none),
    headline2: TextStyle(debugLabel: 'mountainView headline2', fontFamily: 'Roboto', decoration: TextDecoration.none),
    headline3: TextStyle(debugLabel: 'mountainView headline3', fontFamily: 'Roboto', decoration: TextDecoration.none),
    headline4: TextStyle(debugLabel: 'mountainView headline4', fontFamily: 'Roboto', decoration: TextDecoration.none),
    headline5: TextStyle(debugLabel: 'mountainView headline5', fontFamily: 'Roboto', decoration: TextDecoration.none),
    headline6: TextStyle(debugLabel: 'mountainView headline6', fontFamily: 'Roboto', decoration: TextDecoration.none),
    bodyText1: TextStyle(debugLabel: 'mountainView bodyText1', fontFamily: 'Roboto', decoration: TextDecoration.none),
    bodyText2: TextStyle(debugLabel: 'mountainView bodyText2', fontFamily: 'Roboto', decoration: TextDecoration.none),
    subtitle1: TextStyle(debugLabel: 'mountainView subtitle1', fontFamily: 'Roboto', decoration: TextDecoration.none),
    subtitle2: TextStyle(debugLabel: 'mountainView subtitle2', fontFamily: 'Roboto', decoration: TextDecoration.none),
    caption: TextStyle(debugLabel: 'mountainView caption', fontFamily: 'Roboto', decoration: TextDecoration.none),
    button: TextStyle(debugLabel: 'mountainView button', fontFamily: 'Roboto', decoration: TextDecoration.none),
    overline: TextStyle(debugLabel: 'mountainView overline', fontFamily: 'Roboto', decoration: TextDecoration.none),
  );

  static const androidWhiteTextThemeKey = 'AndroidWhite';
  static const androidWhiteTextTheme = Typography.whiteMountainView;

  static const androidBlackTextThemeKey = 'AndroidBlack';
  static const androidBlackTextTheme = Typography.blackMountainView;
}
