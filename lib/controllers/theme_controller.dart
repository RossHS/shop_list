import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logging/logging.dart';
import 'package:shop_list/models/models.dart';

/// Контроллер темы приложения
class ThemeController extends GetxController {
  static ThemeController get to => Get.find<ThemeController>();
  static final _log = Logger('ThemeController');
  final storage = GetStorage();

  /// Оболочка над темой приложения, так как надо использовать дополнительные параметры,
  /// которых нет в стандартном класса [ThemeData] и его нельзя расширить, то использую
  /// композицию (обертку) [ThemeDataWrapper] для добавления различных уникальных свойств темы
  late final Rx<ThemeDataWrapper> appTheme;

  /// Список всех доступных тем на выбор
  late final List<String> appThemeList = [
    Animated90sThemeDataWrapper.appThemeStorageValue,
    MaterialThemeDataWrapper.appThemeStorageValue,
    GlassmorphismThemeDataWrapper.appThemeStorageValue,
  ];

  /// Тип темы приложения системная/светлая/темная
  late final Rx<ThemeMode> themeMode;

  /// Тема текста
  late final Rx<TextTheme> textTheme;

  @override
  void onInit() {
    super.onInit();
    // Инициализация темы приложения
    themeMode = _initParseThemeMode().obs;
    textTheme = _initParseTextTheme().obs;
    appTheme = _initParseAppTheme().obs;
    ever<ThemeMode>(themeMode, _onThemeModeStateChange);
    ever<TextTheme>(textTheme, _onTextThemeStateChange);
    ever<ThemeDataWrapper>(appTheme, _onAppThemeStateChangeEvent);
  }

  /// Парсинг темы при инициализации контроллера из хранилища
  ThemeDataWrapper _initParseAppTheme() {
    final appThemeValue = storage.read<String>(ThemeDataWrapper.appThemeStorageKey);
    _log.fine('init AppTheme - $appThemeValue');
    return _getThemeDataWrapperFromString(appThemeValue);
  }

  /// Инициализация темы приложения [ThemeMode] при запуске приложения
  ThemeMode _initParseThemeMode() {
    // Чтение ранее записанного значения в хранилище, если ничего нет по ключу, то используем системные тему
    final themeModeValue = storage.read<String>('themeMode') ?? ThemeMode.system.name;
    _log.fine('init ThemeMode - $themeModeValue');
    return ThemeMode.values.firstWhere((mode) => mode.name == themeModeValue);
  }

  /// Инициализация темы текста [TextTheme]
  TextTheme _initParseTextTheme() {
    final textThemeValue = storage.read<String>('textTheme');
    _log.fine('init TextTheme - $textThemeValue');
    return TextThemeCollection.fromString(textThemeValue);
  }

  /// Callback, который вызывается при каждом изменении значения в переменной [appTheme]
  void _onAppThemeStateChangeEvent(ThemeDataWrapper themeDataWrapper) {
    _log.fine('changed themeDataWrapper ${themeDataWrapper.themePrefix}');
    // Сохранение выбранной темы
    final materialController = Get.find<GetMaterialController>();
    // Установка светлой темы
    materialController.theme = themeDataWrapper.lightTheme;
    materialController.darkTheme = themeDataWrapper.darkTheme;
    materialController.update();
    storage.write(ThemeDataWrapper.appThemeStorageKey, themeDataWrapper.themePrefix);
    themeDataWrapper.writeToGetStorage(storage);
  }

  /// Callback, вызывается при смене типа темы приложения системная/светлая/темная в переменной [themeMode]
  void _onThemeModeStateChange(ThemeMode themeMode) {
    _log.fine('changed themeMode to ${themeMode.name}');
    Get.changeThemeMode(themeMode);
    storage.write('themeMode', themeMode.name);
  }

  void _onTextThemeStateChange(TextTheme textTheme) {
    final textThemeKey =
        TextThemeCollection.map.keys.firstWhere((theme) => TextThemeCollection.map[theme] == textTheme);
    _log.fine('changed textTheme to $textThemeKey');
    appTheme.value = appTheme.value.copyWith(textTheme: textTheme);
    storage.write('textTheme', textThemeKey);
  }

  ThemeDataWrapper _getThemeDataWrapperFromString(String? themePrefix) {
    final toParse = themePrefix;
    _log.fine('parse AppTheme from $toParse');
    switch (toParse) {
      case Animated90sThemeDataWrapper.appThemeStorageValue:
        return Animated90sThemeDataWrapper.fromGetStorage(storage);
      case MaterialThemeDataWrapper.appThemeStorageValue:
        return MaterialThemeDataWrapper.fromGetStorage(storage);
      case GlassmorphismThemeDataWrapper.appThemeStorageValue:
        return GlassmorphismThemeDataWrapper.fromGetStorage(storage);
      default:
        return Animated90sThemeDataWrapper.fromGetStorage(storage);
    }
  }

  /// Установка стиля приложения
  void setAppTheme(String? themePrefix) {
    _log.fine('set AppTheme from GUI to $themePrefix');
    appTheme.value = _getThemeDataWrapperFromString(themePrefix);
  }

  /// Установка палитры светлой темы
  /// Параметр key необходим для обновления цвета в коллекции цветовых схем,
  /// по сути нужен только для кастомных цветов, которые можно изменять,
  /// в остальных случаях указывать не обязательно
  void setLightColorScheme(ColorScheme? colorScheme, {String? key}) {
    _log.fine('set light ColorScheme - $colorScheme');
    if (key != null && colorScheme != null) appTheme.value.lightColorSchemesMap[key] = colorScheme;
    appTheme.value = appTheme.value.copyWith(
      lightColorScheme: colorScheme,
    );
  }

  /// Установка палитры темной темы
  /// Параметр key необходим для обновления цвета в коллекции цветовых схем,
  /// по сути нужен только для кастомных цветов, которые можно изменять,
  /// в остальных случаях указывать не обязательно
  void setDarkColorScheme(ColorScheme? colorScheme, {String? key}) {
    _log.fine('set dark ColorScheme - $colorScheme');
    if (key != null && colorScheme != null) appTheme.value.darkColorSchemesMap[key] = colorScheme;
    appTheme.value = appTheme.value.copyWith(
      darkColorScheme: colorScheme,
    );
  }

  /// Обновление параметров темы [Animated90sThemeDataWrapper]
  void updateAnimated90sThemeData({
    Duration? animationDuration,
    double? strokeWidth,
    int? offset,
  }) {
    if (appTheme.value is! Animated90sThemeDataWrapper) return;
    final wrapper = appTheme.value as Animated90sThemeDataWrapper;
    appTheme.value = wrapper.copyWith(
      animationDuration: animationDuration,
      paint90sConfig: wrapper.paint90sConfig.copyWith(
        strokeWidth: strokeWidth,
        offset: offset,
      ),
    );
  }

  void updateMaterialThemeData({
    double? rounded,
    double? shadowBlurRadius,
    Color? shadowColor,
    Offset? shadowOffset,
  }) {
    if (appTheme.value is! MaterialThemeDataWrapper) return;
    final wrapper = appTheme.value as MaterialThemeDataWrapper;
    appTheme.value = wrapper.copyWith(
      rounded: rounded,
      shadowBlurRadius: shadowBlurRadius,
      shadowColor: shadowColor,
      shadowOffset: shadowOffset,
    );
  }

  void updateGlassmorphismThemeData({
    BoxDecoration? backgroundDecoration,
  }) {
    if (appTheme.value is! GlassmorphismThemeDataWrapper) return;
    final wrapper = appTheme.value as GlassmorphismThemeDataWrapper;
    appTheme.value = wrapper.copyWith(
      backgroundDecoration: backgroundDecoration,
    );
  }
}
