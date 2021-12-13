import 'package:flutter/material.dart';
import 'package:shop_list/models/theme_model.dart';
import 'package:shop_list/widgets/themes_factories/animated90s_theme_factory.dart';
import 'package:shop_list/widgets/themes_factories/material_theme_factory.dart';
import 'package:shop_list/widgets/themes_factories/modern_theme_factory.dart';

/// Абстрактная фабрика, которая отображает интерфейс в зависимости от установленной темы
/// TODO 11.12.2021 Давно знал, что лучше не использовать helpers method, а создавать отдельные классы виджетов - из книги
/// TODO https://www.amazon.com/Flutter-Complete-Reference-Create-beautiful-ebook/dp/B08KHKK8TR и статьи
/// TODO https://blog.codemagic.io/how-to-improve-the-performance-of-your-flutter-app./#dont-split-your-widgets-into-methods,
/// TODO но все равно решил использовать helper methods в реализации абстрактной фабрики (т.к. это просто удобней,
/// TODO к тому же, сами создатели Flutter используют helper method в реализации [Slider]).
/// TODO Но из-за этого подхода наткнулся на пару проблем в использовании (Context/Theme), странных багов и отсутствие механизмов оптимизации со стороны фреймворка
/// TODO то есть какой был бы смысл в StatelessWidget, если все можно просто раскидать по методам (helper methods).
/// TODO К этой же теме меня вернул ролик с ютюб канала flutter https://www.youtube.com/watch?v=IOyq-eTRhvo
/// TODO и развернутый ответ Rémi Rousselet (создатель Provider), который объяснил как это работает и почему именно так
/// TODO https://stackoverflow.com/questions/53234825/what-is-the-difference-between-functions-and-classes-to-create-reusable-widgets/53234826#53234826
/// TODO https://github.com/flutter/flutter/issues/19269
///
/// TODO Написал все в todo, т.к. планирую большой рефакторинг всей фабрики
abstract class ThemeFactory {
  static ThemeFactory instance(ThemeDataWrapper themeDataWrapper) {
    if (themeDataWrapper is Animated90sThemeDataWrapper) {
      return Animated90sFactory(themeDataWrapper);
    } else if (themeDataWrapper is MaterialThemeDataWrapper) {
      return MaterialThemeFactory(themeDataWrapper);
    } else if (themeDataWrapper is ModernThemeDataWrapper) {
      // TODO 27.11.2021 пока возвращаем материал тему
      return MaterialThemeFactory(const MaterialThemeDataWrapper(
        textTheme: TextTheme(),
        lightColorScheme: ColorScheme.light(),
        darkColorScheme: ColorScheme.dark(),
      ));
    }
    throw Exception('Unsupported type of ThemeDataWrapper - $themeDataWrapper');
  }

  ThemeFactory(ThemeDataWrapper themeDataWrapper);

  /// Обертка над темой приложения, которая добавляет новые поля в уже существующую тему
  ThemeDataWrapper get themeWrapper;

  /// Получить фабрику создания иконок
  IconsFactory get icons;

  /// Метод создания виджета [AppBar] маршрута
  PreferredSizeWidget appBar({
    Key? key,
    Widget? leading,
    Widget? title,
    List<Widget>? actions,
    PreferredSizeWidget? bottom,
  });

  /// Создание виджета [FloatingActionButton]
  Widget floatingActionButton({
    Key? key,
    required void Function() onPressed,
    required Widget child,
  });

  /// Самая распространенная кнопка - [ElevatedButton]
  Widget button({
    Key? key,
    required void Function() onPressed,
    required Widget child,
  });

  /// Самая распространенная форма - выделяет виджеты в определенный "контейнер"
  Widget commonItemBox({Key? key, required Widget child});

  /// Фон для поля ввода элементов списка дел из [TodoRouteBase]
  Widget todoElementMsgInputBox({Key? key, required Widget child});

  /// Оверлей с оповещением
  Widget infoOverlay({
    String? title,
    required String msg,
    Widget? child,
  });

  /// Поле текстового ввода
  Widget textField({
    Key? key,
    required TextEditingController controller,
    bool Function(String)? inputValidator,
    String? hint,
    int? maxLines,
    int? minLines,
    Widget? prefixIcon,
    bool obscureText = false,
  });

  /// Диалоговое окно c текстом [text] и перечнем виджетов [actions],
  /// как правило используются виджеты кнопки 'OK' и 'Отмена'
  void showDialog({String? text, Widget? content, List<Widget>? actions});

  /// Динамически возвращает один из прописанных виджетов аргумента в зависимости от типа текущей реализации фабрики.
  /// Полезен, когда необходимо создавать действительно уникальные виджеты в одном конкретном месте,
  /// не загружая абстрактную фабрику гигантским числом мелких методов
  /// Метод выходящий за принципы паттерна "абстрактной фабрики" и отчасти нарушающий их и полиморфизм
  Widget buildWidget({
    Widget Function(Widget? child, Animated90sFactory factory) animated90s = _defaultBuildWidgetFunction,
    Widget Function(Widget? child, MaterialThemeFactory factory) material = _defaultBuildWidgetFunction,
    Widget Function(Widget? child, ModernThemeFactory factory) modern = _defaultBuildWidgetFunction,
    Widget? child,
  }) {
    if (this is Animated90sFactory) return animated90s(child, this as Animated90sFactory);
    if (this is MaterialThemeFactory) return material(child, this as MaterialThemeFactory);
    if (this is ModernThemeFactory) return modern(child, this as ModernThemeFactory);
    throw Exception('Unsupported type of factory - $runtimeType');
  }

  /// Костыль к [buildWidget], так как синтаксис Dart не позволяет напрямую указывать в именованном параметре дефолтную функцию.
  /// Т.е. вместо того чтобы разрешить использовать const к типу Function https://github.com/dart-lang/language/issues/1048
  /// и писать напрямую
  /// Widget Function(Widget? child) animated90s = const (child) => SizedBox(child: child),
  /// Приходится создавать приватную статическую функцию
  static Widget _defaultBuildWidgetFunction(Widget? child, ThemeFactory factory) {
    return SizedBox(
      child: child,
    );
  }
}

/// Фабрика для получения иконок в зависимости от установленной темы
abstract class IconsFactory {
  const IconsFactory();

  Widget get create;

  Widget get user;

  Widget get lock;

  Widget get sort;

  Widget get close;

  Widget get dehaze;

  Widget get settings;

  // ignore: non_constant_identifier_names
  Widget get file_upload;

  Widget get send;
}
