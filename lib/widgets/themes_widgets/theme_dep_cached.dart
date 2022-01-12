import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_list/controllers/theme_controller.dart';
import 'package:shop_list/models/theme_model.dart';
import 'package:shop_list/widgets/themes_widgets/theme_base_widget.dart';

/// Виджет обертка, кэширующий виджет текущей темы
/// Изначально не планировалось создавать подобный класс. Он появился как решение (которое мне не очень нравится)
/// конкретной проблемы - виджет расширяющий [ThemeDepWidgetBase] должен также реализовывать какой-либо интерфейс [T],
/// как например [PreferredSizeWidget] для [AppBar], как создать зависимый виджет от темы, который бы еще и корректно
/// рассчитывал и отдавал preferredSize? Создавать его в конструкторе и кешировать в [_CachedWidget](получился какой-то синтез
/// делегирования и наследования)!
///
/// Почему мне не нравится текущая реализация -
/// 1) Не до конца понятно как это скажется на производительности
/// 2) Дублирование кода (см конструктор (sic!) и метод build из родителя)
/// 3) Переопределение одних методов и ввод новых с идентичным предназначением
///
/// Но были и другие варианты решения, которые в разы хуже, так что текущая реализация - наименьшее зло, что мне пришло на ум
abstract class ThemeDepCached<T extends Widget> extends ThemeDepWidgetBase {
  ThemeDepCached({Key? key}) : super(key: key) {
    final appTheme = ThemeController.to.appTheme.value;
    if (appTheme is Animated90sThemeDataWrapper) {
      _cachedWidget = _CachedWidget<T>(animated90sWidgetImp(Get.context!, appTheme), appTheme);
    } else if (appTheme is MaterialThemeDataWrapper) {
      _cachedWidget = _CachedWidget(materialWidgetImp(Get.context!, appTheme), appTheme);
    } else if (appTheme is GlassmorphismThemeDataWrapper) {
      _cachedWidget = _CachedWidget(glassmorphismWidgetImp(Get.context!, appTheme), appTheme);
    }
  }

  @protected
  late final _CachedWidget<T> _cachedWidget;

  _CachedWidget<T> get cachedWidget => _cachedWidget;

  /// Метод для обновления кэшируемого виджета.
  ///
  /// Использую Function() [producer], чтобы избежать лишних созданий объектов и создавать объект лишь
  /// при необходимости обновления кэшируемого виджета. Так если бы я использовал просто аргумент T widget,
  /// и вызывал данный метод к примеру:
  ///  _updateCachedWidget(type: _animated, producer: animated90sWidgetImp(context, themeWrapper));
  /// то это бы привело к созданию объекта каждый раз при вызове метода [_updateCachedWidget],
  /// что, очевидно, не есть хорошо
  void _updateCachedWidget({required ThemeDataWrapper themeWrapper, required T Function() producer}) {
    if (_cachedWidget._themeWrapper != themeWrapper) {
      _cachedWidget.widget = producer();
      _cachedWidget._themeWrapper = themeWrapper;
    }
  }

  @override
  T animated90sWidget(BuildContext context, Animated90sThemeDataWrapper themeWrapper) {
    _updateCachedWidget(themeWrapper: themeWrapper, producer: () => animated90sWidgetImp(context, themeWrapper));
    return _cachedWidget.widget;
  }

  @override
  T materialWidget(BuildContext context, MaterialThemeDataWrapper themeWrapper) {
    _updateCachedWidget(themeWrapper: themeWrapper, producer: () => materialWidgetImp(context, themeWrapper));
    return _cachedWidget.widget;
  }

  @override
  T glassmorphismWidget(BuildContext context, GlassmorphismThemeDataWrapper themeWrapper) {
    _updateCachedWidget(themeWrapper: themeWrapper, producer: () => glassmorphismWidgetImp(context, themeWrapper));
    return _cachedWidget.widget;
  }

  T animated90sWidgetImp(BuildContext context, Animated90sThemeDataWrapper themeWrapper);

  T materialWidgetImp(BuildContext context, MaterialThemeDataWrapper themeWrapper);

  T glassmorphismWidgetImp(BuildContext context, GlassmorphismThemeDataWrapper themeWrapper);
}

/// Кэширование виджета [widget] в соответствии с установленной темой [_themeWrapper]
class _CachedWidget<T extends Widget> {
  _CachedWidget(this.widget, this._themeWrapper);

  ThemeDataWrapper _themeWrapper;
  T widget;
}
