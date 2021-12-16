import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_list/controllers/theme_controller.dart';
import 'package:shop_list/models/theme_model.dart';

/// Создание виджета на основе темы приложения [ThemeDataWrapper]
/// Является переделкой абстрактной фабрики, которая использовалась в проекте раньше.
///
/// Мотивацией для рефакторинга послужило как минимум 4 причины:
/// 1) Вся фабрика была построенная на принципе helpers method, без использования StatelessWidget вовсе:
///   Комментарий в абстрактной фабрике от 11.12.2021 - Изначально знал, что лучше не использовать helpers method,
///   а создавать отдельные классы виджетов - знал из книги
///   https://www.amazon.com/Flutter-Complete-Reference-Create-beautiful-ebook/dp/B08KHKK8TR и статьи
///   https://blog.codemagic.io/how-to-improve-the-performance-of-your-flutter-app./#dont-split-your-widgets-into-methods,
///   но все равно решил использовать helper methods в реализации абстрактной фабрики (т.к. это просто удобней,
///   к тому же, сами создатели Flutter используют helper method в реализации [Slider]).
///   Но из-за этого подхода наткнулся на пару проблем в использовании (Context/Theme), странных багов и отсутствие механизмов оптимизации со стороны фреймворка
///   то есть, какой был бы смысл в StatelessWidget, если все можно просто раскидать по методам (helper methods).
///   К этой же теме меня вернул ролик с ютюб канала flutter https://www.youtube.com/watch?v=IOyq-eTRhvo
///   и развернутый ответ Rémi Rousselet (создатель Provider), который объяснил как это работает и почему именно так
///   https://stackoverflow.com/questions/53234825/what-is-the-difference-between-functions-and-classes-to-create-reusable-widgets/53234826#53234826
///   https://github.com/flutter/flutter/issues/19269
///
/// 2) Приходилось писать лишний код - каждый раз создавать абстрактную фабрику по типу
///    final themeFactory = ThemeFactory.instance(controller.appTheme.value);
///    потом уже создавать необходимый виджет, и так каждый раз. Теперь же, я могу напрямую вызывать нужный мне виджет
///    без создания фабрики, к примеру просто создать [ThemeDepButton] и все.
///
/// 3) Нет необходимости оборачивать каждую абстрактную фабрику в Obx/GetX<ThemeController> в вызывающем коде,
///   дабы StreamBuilder корректно реагировал на изменения темы и перестраивал виджеты с учетом изменений,
///   теперь же обертка в GetX<ThemeController> происходит внутри абстрактного [ThemeWidgetBase],
///   что должно лучше сказаться на производительности (т.к. GetX<ThemeController> находится максимально близко к зависимому виджету)
///   и улучшить вызывающий код (т.к. нет необходимости при каждом использовании абстрактной фабрики использовать GetX<ThemeController>)
///
/// 4) Ну и совсем мелочь, лично мне было не очень удобно вносить точечные изменения в одну и в другую фабрику
///   одновременно. Иногда запутывался в куче методов, или просто забывал произвести изменения во всех фабриках сразу
///   (т.к. это сразу несколько максимально похожих файлов с кучей одинаковых методов).
///   Теперь же (условно) каждый старый метод фабрики - это отдельный класс, все находится максимально
///   близко друг к другу и запутаться/что-то забыть гораздо сложнее
abstract class ThemeWidgetBase extends StatelessWidget {
  const ThemeWidgetBase({Key? key}) : super(key: key);

  @mustCallSuper
  @override
  Widget build(BuildContext context) {
    return GetX<ThemeController>(
      builder: (controller) {
        final appTheme = controller.appTheme.value;
        if (appTheme is Animated90sThemeDataWrapper) {
          return animated90sWidget(context, appTheme);
        } else if (appTheme is MaterialThemeDataWrapper) {
          return materialWidget(context, appTheme);
        } else if (appTheme is ModernThemeDataWrapper) {
          /// TODO 16.12.2021 пока возвращается material, т.к. не определился с modern стилем
          return materialWidget(
              context,
              const MaterialThemeDataWrapper(
                textTheme: TextTheme(),
                lightColorScheme: ColorScheme.light(),
                darkColorScheme: ColorScheme.dark(),
              ));
        }
        return throw UnsupportedError('Unsupported theme - ${appTheme.runtimeType}');
      },
    );
  }

  @protected
  Widget animated90sWidget(BuildContext context, Animated90sThemeDataWrapper themeWrapper);

  @protected
  Widget materialWidget(BuildContext context, MaterialThemeDataWrapper themeWrapper);

  /// TODO 16.12.2021 Закомментировал - т.к. нет еще представлению о том, как должна выглядеть данная тема
// Widget moderWidget(BuildContext context, ModernThemeDataWrapper themeWrapper);
}

/// Т.к. нам не всегда необходим именно виджет, как пример - вызов диалогового окна [ThemeDepDialog].
/// Именно для таких целей существует данный класс
abstract class ThemeBaseClass {
  ThemeBaseClass() {
    _call();
  }

  void _call() {
    final appTheme = ThemeController.to.appTheme.value;
    if (appTheme is Animated90sThemeDataWrapper) {
      animated90s(appTheme);
    } else if (appTheme is MaterialThemeDataWrapper) {
      material(appTheme);
    } else if (appTheme is ModernThemeDataWrapper) {
      /// TODO 16.12.2021 пока вызываем material, т.к. не определился с modern стилем
      material(
        const MaterialThemeDataWrapper(
          textTheme: TextTheme(),
          lightColorScheme: ColorScheme.light(),
          darkColorScheme: ColorScheme.dark(),
        ),
      );
    } else {
      throw UnsupportedError('Unsupported theme - ${appTheme.runtimeType}');
    }
  }

  void animated90s(Animated90sThemeDataWrapper themeWrapper);

  void material(MaterialThemeDataWrapper themeWrapper);

// void modern(ModernThemeDataWrapper themeWrapper);
}
