import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logging/logging.dart';
import 'package:shop_list/models/theme_model.dart';

@immutable
abstract class ThemeDataWrapper {
  static final _log = Logger('ThemeDataWrapper');

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

  /// Возвращает текущую обертку над ColorSchemeWrapper
  ColorSchemeWrapper getColorSchemeWrapper(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (colorScheme.brightness) {
      case Brightness.light:
        return lightColorSchemeWrapper;
      case Brightness.dark:
        return darkColorSchemeWrapper;
      default:
        // На случай, если в будущем появится еще один вариант [Brightness],
        // то в лог пропишется ошибка, но приложение будут исполняться
        _log.warning('undefined colorScheme.brightness - ${colorScheme.brightness.name}');
        return lightColorSchemeWrapper;
    }
  }

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
    // Запись названий текущих цветовых тем, для последующей загрузки установленной цветовой схемы
    storage.write(
      _lightThemeStorageKey,
      lightColorSchemesWrapperMap.entries.firstWhere((element) => element.value == lightColorSchemeWrapper).key,
    );
    storage.write(
      _darkThemeStorageKey,
      darkColorSchemesWrapperMap.entries.firstWhere((element) => element.value == darkColorSchemeWrapper).key,
    );

    // Запись кастомных оберток цветовых схем.
    final customDark = darkColorSchemesWrapperMap['custom dark'];
    final customLight = lightColorSchemesWrapperMap['custom light'];
    assert(customDark != null && customLight != null);
    customDark!.writeToGetStorage(storage, keyPrefix: '$themePrefix-custom-dark');
    customLight!.writeToGetStorage(storage, keyPrefix: '$themePrefix-custom-light');
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

  @mustCallSuper
  void writeToGetStorage(GetStorage storage, {required String keyPrefix}) {
    // Записываю цифровое представление цвета, т.к. объект Color не сериализуем
    storage.write('$keyPrefix-mainColor', colorScheme.primary.value);
    storage.write('$keyPrefix-backgroundColor', colorScheme.background.value);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColorSchemeWrapper && runtimeType == other.runtimeType && colorScheme == other.colorScheme;

  @override
  int get hashCode => colorScheme.hashCode;
}
