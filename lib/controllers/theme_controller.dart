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
  late final List<ThemeDataWrapper> appThemeList = [
    Animated90sThemeData.fromGetStorage(storage),
    MaterialThemeData.fromGetStorage(storage),
    ModernThemeData.fromGetStorage(storage),
  ];

  /// Тип темы приложения системная/светлая/темная
  late final Rx<ThemeMode> themeMode;

  // final fontFamily = 'RossFont'.obs;

  @override
  void onInit() {
    super.onInit();
    // Инициализация темы приложения
    appTheme = _initParseAppTheme().obs;
    themeMode = _initParseThemeMode().obs;

    ever<ThemeMode>(themeMode, _onThemeModeChangeState);
    ever<ThemeDataWrapper>(appTheme, _onAppThemeStateChangeEvent);
  }

  /// Парсинг темы при инициализации контроллера из хранилища
  ThemeDataWrapper _initParseAppTheme() {
    ThemeDataWrapper? themeWrapper;
    final appThemeValue =
        storage.read<String>(ThemeDataWrapper.appThemeStorageKey) ?? Animated90sThemeData.appThemeStorageValue;
    // Определение глобального стиля
    switch (appThemeValue) {
      case Animated90sThemeData.appThemeStorageValue:
        themeWrapper = Animated90sThemeData.fromGetStorage(storage);
        break;
      case MaterialThemeData.appThemeStorageValue:
        themeWrapper = ModernThemeData.fromGetStorage(storage);
        break;
      case ModernThemeData.appThemeStorageValue:
        themeWrapper = ModernThemeData.fromGetStorage(storage);
        break;
    }
    return themeWrapper!;
  }

  /// Инициализация темы приложения [ThemeMode] при запуске приложения
  ThemeMode _initParseThemeMode() {
    // Чтение ранее записанного значения в хранилище, если ничего нет по ключу, то используем системные тему
    final themeModeValue = storage.read<String>('themeMode') ?? ThemeMode.system.name;
    return ThemeMode.values.firstWhere((mode) => mode.name == themeModeValue);
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
  void _onThemeModeChangeState(ThemeMode themeMode) {
    _log.fine('changed themeMode to ${themeMode.name}');
    Get.changeThemeMode(themeMode);
    storage.write('themeMode', themeMode.name);
  }
}
