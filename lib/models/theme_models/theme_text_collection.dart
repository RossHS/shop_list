import 'package:flutter/material.dart';

class TextThemeCollection {
  TextThemeCollection._();

  static final Map<String, TextTheme> map = {
    rossTextThemeKey: rossTextTheme,
    androidTextThemeKey: androidTextTheme,
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
}
