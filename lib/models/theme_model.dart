import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shop_list/widgets/animated90s/animated_90s_painter.dart';

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

//----------------------------Animated90sThemeData------------------------//
class Animated90sThemeDataWrapper extends ThemeDataWrapper {
  static const appThemeStorageValue = 'Animated90s';

  const Animated90sThemeDataWrapper({
    required TextTheme textTheme,
    required this.paint90sConfig,
    required ColorScheme lightColorScheme,
    required ColorScheme darkColorScheme,
  }) : super(
          textTheme: textTheme,
          lightColorScheme: lightColorScheme,
          darkColorScheme: darkColorScheme,
        );

  factory Animated90sThemeDataWrapper.fromGetStorage(GetStorage storage) {
    final textTheme = TextThemeCollection.fromString(storage.read<String>('textTheme'));
    final paint90sConfig = Paint90sConfig(
      offset: storage.read<int>('$appThemeStorageValue-paintConfig-offset'),
      strokeWidth: storage.read<double>('$appThemeStorageValue-paintConfig-strokeWidth'),
    );
    // Вычитываем название сохраненной темы из хранилища
    final String lightThemeKey = storage.read<String>('$appThemeStorageValue-light') ?? 'default light 1';
    final String darkThemeKey = storage.read<String>('$appThemeStorageValue-dark') ?? 'default dark 1';
    return Animated90sThemeDataWrapper(
      textTheme: textTheme,
      paint90sConfig: paint90sConfig,
      lightColorScheme: _getLightColorSchemesMap[lightThemeKey]!,
      darkColorScheme: _getDarkColorSchemesMap[darkThemeKey]!,
    );
  }

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
      'default light 1': _createLightColorScheme(Colors.green, Colors.red),
      'default light 2': _createLightColorScheme(Colors.blue, Colors.white),
      'custom light': _loadCustomColorSchemeFromStorage(GetStorage(), '$appThemeStorageValue-custom-light'),
    };
    assert(_lightColorSchemesMap != null && _lightColorSchemesMap!.isNotEmpty);
    return _lightColorSchemesMap!;
  }

  static Map<String, ColorScheme> get _getDarkColorSchemesMap {
    _darkColorSchemesMap ??= {
      'default dark 1': _createDarkColorScheme(Colors.yellow, Colors.purple),
      'default dark 2': _createDarkColorScheme(Colors.blueGrey, Colors.pink),
      'custom dark': _loadCustomColorSchemeFromStorage(GetStorage(), '$appThemeStorageValue-custom-dark'),
    };
    assert(_darkColorSchemesMap != null && _darkColorSchemesMap!.isNotEmpty);
    return _darkColorSchemesMap!;
  }

  /// Стандартный кофиг для темы Animated90sThemeDataWrapper,
  /// на его основе абстрактная фабрика [Animated90sFactory] создает виджеты
  final Paint90sConfig paint90sConfig;

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
  }

  @override
  Animated90sThemeDataWrapper copyWith({
    TextTheme? textTheme,
    Paint90sConfig? paint90sConfig,
    ColorScheme? lightColorScheme,
    ColorScheme? darkColorScheme,
  }) {
    return Animated90sThemeDataWrapper(
      textTheme: textTheme ?? this.textTheme,
      paint90sConfig: paint90sConfig ?? this.paint90sConfig,
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
          paint90sConfig == other.paint90sConfig;

  @override
  int get hashCode => super.hashCode ^ paint90sConfig.hashCode;
}

//----------------------------MaterialThemeData--------------------------//
class MaterialThemeDataWrapper extends ThemeDataWrapper {
  static const appThemeStorageValue = 'Material';

  const MaterialThemeDataWrapper({
    required TextTheme textTheme,
    required ColorScheme lightColorScheme,
    required ColorScheme darkColorScheme,
  }) : super(
          textTheme: textTheme,
          lightColorScheme: lightColorScheme,
          darkColorScheme: darkColorScheme,
        );

  factory MaterialThemeDataWrapper.fromGetStorage(GetStorage storage) {
    final textTheme = TextThemeCollection.fromString(storage.read<String>('textTheme'));
    // Вычитываем название сохраненной темы из хранилища
    final String lightThemeKey = storage.read<String>('$appThemeStorageValue-light') ?? 'default light 1';
    final String darkThemeKey = storage.read<String>('$appThemeStorageValue-dark') ?? 'default dark 1';
    return MaterialThemeDataWrapper(
      textTheme: textTheme,
      lightColorScheme: _getLightColorSchemesMap[lightThemeKey]!,
      darkColorScheme: _getDarkColorSchemesMap[darkThemeKey]!,
    );
  }

  /// Почему так, объяснение в комментариях [Animated90sThemeDataWrapper._lightColorSchemesMap]
  static Map<String, ColorScheme>? _lightColorSchemesMap;
  static Map<String, ColorScheme>? _darkColorSchemesMap;

  static Map<String, ColorScheme> get _getLightColorSchemesMap {
    _lightColorSchemesMap ??= {
      'default light 1': _createLightColorScheme(Colors.green, Colors.red),
      'default light 2': _createLightColorScheme(Colors.blue, Colors.white),
      'custom light': _loadCustomColorSchemeFromStorage(GetStorage(), '$appThemeStorageValue-custom-light'),
    };
    assert(_lightColorSchemesMap != null && _lightColorSchemesMap!.isNotEmpty);
    return _lightColorSchemesMap!;
  }

  static Map<String, ColorScheme> get _getDarkColorSchemesMap {
    _darkColorSchemesMap ??= {
      'default dark 1': _createDarkColorScheme(Colors.blueGrey, Colors.brown),
      'default dark 2': _createDarkColorScheme(Colors.blueGrey, Colors.pink),
      'custom dark': _loadCustomColorSchemeFromStorage(GetStorage(), '$appThemeStorageValue-custom-dark'),
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
  MaterialThemeDataWrapper copyWith({
    TextTheme? textTheme,
    ColorScheme? lightColorScheme,
    ColorScheme? darkColorScheme,
  }) {
    return MaterialThemeDataWrapper(
      textTheme: textTheme ?? this.textTheme,
      lightColorScheme: lightColorScheme ?? this.lightColorScheme,
      darkColorScheme: darkColorScheme ?? this.darkColorScheme,
    );
  }
}

//----------------------------ModernThemeData---------------------------//
class ModernThemeDataWrapper extends ThemeDataWrapper {
  static const appThemeStorageValue = 'Modern';

  const ModernThemeDataWrapper({
    required TextTheme textTheme,
    required ColorScheme lightColorScheme,
    required ColorScheme darkColorScheme,
  }) : super(
          textTheme: textTheme,
          lightColorScheme: lightColorScheme,
          darkColorScheme: darkColorScheme,
        );

  factory ModernThemeDataWrapper.fromGetStorage(GetStorage storage) {
    final textTheme = TextThemeCollection.fromString(storage.read<String>('textTheme'));
    final String lightThemeKey = storage.read<String>('$appThemeStorageValue-light') ?? 'default light 1';
    final String darkThemeKey = storage.read<String>('$appThemeStorageValue-dark') ?? 'default dark 1';
    return ModernThemeDataWrapper(
      textTheme: textTheme,
      lightColorScheme: _getLightColorSchemesMap[lightThemeKey]!,
      darkColorScheme: _getDarkColorSchemesMap[darkThemeKey]!,
    );
  }

  /// Почему так, объяснение в комментариях [Animated90sThemeDataWrapper._lightColorSchemesMap]
  static Map<String, ColorScheme>? _lightColorSchemesMap;
  static Map<String, ColorScheme>? _darkColorSchemesMap;

  static Map<String, ColorScheme> get _getLightColorSchemesMap {
    _lightColorSchemesMap ??= {
      'default light 1': _createLightColorScheme(Colors.green, Colors.red),
      'default light 2': _createLightColorScheme(Colors.blue, Colors.white),
      'custom light': _loadCustomColorSchemeFromStorage(GetStorage(), '$appThemeStorageValue-custom-light'),
    };
    assert(_lightColorSchemesMap != null && _lightColorSchemesMap!.isNotEmpty);
    return _lightColorSchemesMap!;
  }

  static Map<String, ColorScheme> get _getDarkColorSchemesMap {
    _darkColorSchemesMap ??= {
      'default dark 1': _createDarkColorScheme(Colors.redAccent, Colors.lightGreen),
      'default dark 2': _createDarkColorScheme(Colors.blueGrey, Colors.pink),
      'custom dark': _loadCustomColorSchemeFromStorage(GetStorage(), '$appThemeStorageValue-custom-dark'),
    };
    assert(_darkColorSchemesMap != null && _darkColorSchemesMap!.isNotEmpty);
    return _darkColorSchemesMap!;
  }

  @override
  Map<String, ColorScheme> get lightColorSchemesMap => _getLightColorSchemesMap;

  @override
  Map<String, ColorScheme> get darkColorSchemesMap => _getDarkColorSchemesMap;

  @override
  String get themePrefix => ModernThemeDataWrapper.appThemeStorageValue;

  @override
  ModernThemeDataWrapper copyWith({
    TextTheme? textTheme,
    ColorScheme? lightColorScheme,
    ColorScheme? darkColorScheme,
  }) {
    return ModernThemeDataWrapper(
      textTheme: textTheme ?? this.textTheme,
      lightColorScheme: lightColorScheme ?? this.lightColorScheme,
      darkColorScheme: darkColorScheme ?? this.darkColorScheme,
    );
  }
}

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

ColorScheme _loadCustomColorSchemeFromStorage(GetStorage storage, String key) {
  final mainColor = Color(storage.read<int>('$key-mainColor') ?? Colors.blue.value);
  final backgroundColor = Color(storage.read<int>('$key-backgroundColor') ?? Colors.pink.value);
  if (key.contains('light')) {
    return _createLightColorScheme(mainColor, backgroundColor);
  } else if (key.contains('dark')) {
    return _createDarkColorScheme(mainColor, backgroundColor);
  }
  throw ArgumentError('Incorrect storage key! $key');
}

ColorScheme _createLightColorScheme(Color mainColor, Color backgroundColor) {
  return ColorScheme.light(
    primary: mainColor,
    primaryVariant: mainColor,
    secondary: mainColor,
    secondaryVariant: mainColor,
    background: backgroundColor,
    surface: mainColor,
    error: Colors.redAccent,
  );
}

ColorScheme _createDarkColorScheme(Color mainColor, Color backgroundColor) {
  return ColorScheme.dark(
    primary: mainColor,
    primaryVariant: mainColor,
    secondary: mainColor,
    secondaryVariant: mainColor,
    background: backgroundColor,
    surface: mainColor,
    error: Colors.redAccent,
  );
}

/// Используется для определения цвета текста в зависимости от цвета фона,
/// TODO 09.21.2021 метод весьма затратный для расчета, используется в основном для определения цвета текста на поверхности canvasColor. Возможно вынести его в отдельное поле, чтобы убрать постоянный перерасчет в методе build()
extension CalculateTextColor on Color {
  Color get calcTextColor => computeLuminance() > .5 ? Colors.black : Colors.white;
}
