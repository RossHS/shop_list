import 'package:flutter/material.dart';

const fontFamily = 'RossFont';
const textTheme = TextTheme(
  bodyText1: TextStyle(fontSize: 20),
  bodyText2: TextStyle(fontSize: 20),
  button: TextStyle(fontSize: 20),
  caption: TextStyle(fontSize: 18),
  headline1: TextStyle(fontSize: 118),
  headline2: TextStyle(fontSize: 62),
  headline3: TextStyle(fontSize: 51),
  headline4: TextStyle(fontSize: 40),
  headline5: TextStyle(fontSize: 30),
  headline6: TextStyle(fontSize: 26),
  overline: TextStyle(fontSize: 16),
  subtitle1: TextStyle(fontSize: 22),
  subtitle2: TextStyle(fontSize: 20),
);

final ThemeData lightTheme = ThemeData(
  scaffoldBackgroundColor: Colors.yellow,
  primarySwatch: Colors.pink,
  fontFamily: fontFamily,
  textTheme: textTheme,
);

final ThemeData darkTheme = ThemeData(
  scaffoldBackgroundColor: Colors.black,
  primarySwatch: Colors.green,
  fontFamily: fontFamily,
  textTheme: textTheme,
);
