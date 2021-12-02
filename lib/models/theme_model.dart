import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shop_list/widgets/animated90s/animated_90s_painter.dart';

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
class Animated90sThemeDataWrapper extends ThemeDataWrapper {
  static const appThemeStorageValue = 'Animated90s';

  Animated90sThemeDataWrapper({
    required TextTheme textTheme,
    required this.paint90sConfig,
  }) : super(textTheme: textTheme);

  factory Animated90sThemeDataWrapper.fromGetStorage(GetStorage storage) {
    final textTheme = TextThemeCollection.fromString(storage.read<String>('textTheme'));
    final paint90sConfig = Paint90sConfig(
      offset: storage.read<int>('$appThemeStorageValue-paintConfig-offset'),
      strokeWidth: storage.read<double>('$appThemeStorageValue-paintConfig-strokeWidth'),
    );
    return Animated90sThemeDataWrapper(
      textTheme: textTheme,
      paint90sConfig: paint90sConfig,
    );
  }

  /// Стандартный кофиг для темы Animated90sThemeDataWrapper,
  /// на его основе абстрактная фабрика [Animated90sFactory] создает виджеты
  final Paint90sConfig paint90sConfig;

  @override
  ThemeData get lightTheme => ThemeData(
        scaffoldBackgroundColor: Colors.yellow,
        primarySwatch: Colors.pink,
        brightness: Brightness.light,
        textTheme: textTheme,
      );

  @override
  ThemeData get darkTheme => ThemeData(
        scaffoldBackgroundColor: Colors.blueGrey,
        primarySwatch: Colors.pink,
        brightness: Brightness.dark,
        textTheme: textTheme,
      );

  @override
  String get themePrefix => Animated90sThemeDataWrapper.appThemeStorageValue;

  @override
  void writeToGetStorage(GetStorage storage) {
    storage.write('$appThemeStorageValue-paintConfig-offset', paint90sConfig.offset);
    storage.write('$appThemeStorageValue-paintConfig-strokeWidth', paint90sConfig.strokeWidth);
  }

  @override
  Animated90sThemeDataWrapper copyWith({
    TextTheme? textTheme,
    Paint90sConfig? paint90sConfig,
  }) {
    return Animated90sThemeDataWrapper(
      textTheme: textTheme ?? this.textTheme,
      paint90sConfig: paint90sConfig ?? this.paint90sConfig,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is Animated90sThemeDataWrapper &&
          runtimeType == other.runtimeType &&
          paint90sConfig == other.paint90sConfig;

  @override
  int get hashCode => super.hashCode ^ paint90sConfig.hashCode;
}

//----------------------------MaterialThemeData--------------------------//
class MaterialThemeDataWrapper extends ThemeDataWrapper {
  static const appThemeStorageValue = 'Material';

  MaterialThemeDataWrapper({
    required TextTheme textTheme,
  }) : super(textTheme: textTheme);

  factory MaterialThemeDataWrapper.fromGetStorage(GetStorage storage) {
    final textTheme = TextThemeCollection.fromString(storage.read<String>('textTheme'));
    return MaterialThemeDataWrapper(
      textTheme: textTheme,
    );
  }

  @override
  ThemeData get lightTheme => ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.light,
        textTheme: textTheme,
      );

  @override
  ThemeData get darkTheme => ThemeData(
        scaffoldBackgroundColor: Colors.grey,
        primarySwatch: Colors.teal,
        brightness: Brightness.dark,
        textTheme: textTheme,
      );

  @override
  String get themePrefix => MaterialThemeDataWrapper.appThemeStorageValue;

  @override
  void writeToGetStorage(GetStorage storage) {
    // TODO: implement writeToGetStorage
  }

  @override
  MaterialThemeDataWrapper copyWith({TextTheme? textTheme}) {
    return MaterialThemeDataWrapper(
      textTheme: textTheme ?? this.textTheme,
    );
  }
}

//----------------------------ModernThemeData---------------------------//
class ModernThemeDataWrapper extends ThemeDataWrapper {
  static const appThemeStorageValue = 'Modern';

  ModernThemeDataWrapper({
    required TextTheme textTheme,
  }) : super(textTheme: textTheme);

  factory ModernThemeDataWrapper.fromGetStorage(GetStorage storage) {
    final textTheme = TextThemeCollection.fromString(storage.read<String>('textTheme'));
    return ModernThemeDataWrapper(
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
  String get themePrefix => ModernThemeDataWrapper.appThemeStorageValue;

  @override
  void writeToGetStorage(GetStorage storage) {
    // TODO: implement writeToGetStorage
  }

  @override
  ModernThemeDataWrapper copyWith({TextTheme? textTheme}) {
    return ModernThemeDataWrapper(
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
