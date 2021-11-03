import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_list/widgets/animated90s/animated_90s.dart';

/// Класс для вызова SnackBar библиотеки GetX.
/// TODO написать контроллер темы, который будет использоваться в цветах SnackBar
class CustomSnackBar {
  /// Отображает SnackBar с заданным заголовком и сообщением
  static void show({
    String? title,
    required String msg,
  }) async {
      return Get.showSnackbar(_resolveTheme(title, msg))!;
  }

  /// В зависимости от темы будет создаваться определенный GetBar
  /// TODO когда закончу с контроллером тем, вернусь сюда
  static GetBar _resolveTheme(String? title, String msg) {
    final textTheme = Get.theme.textTheme;
    // TODO определять в контроллере тем стандартный Paint90sConfig
    Paint90sConfig config = const Paint90sConfig();
    return _CustomGetBar(
      child: SafeArea(
        // Отступы, чтобы SnackBar не выходил за границы экрана из-за AnimatedPainterSquare
        child: Padding(
          padding: EdgeInsets.all(10.0 + config.offset),
          child: AnimatedPainterSquare90s(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null) Text(title, style: textTheme.headline5),
                  Text(msg, style: textTheme.bodyText1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Из-за ограничений в API GetX SnackBar, а именно, используется аргумент типа [GetBar] в методе [Get.showSnackBar],
/// который вызывает определенные поля в неабстрактном виджете [GetBar], хотя для лучшей (масштабируемой) архитектуры
/// разработчику GetX следовало бы создать отдельный интерфейс на подобии абстрактного класса [PreferredSizeWidget],
/// таким образом не пришлось бы нарушать принципы SOLID (Принцип разделения интерфейса)
/// и не тянуть с собой магический код
///
/// В итоге было два вариант - разобраться целиком во всей цепочке вызовов [Get.showSnackBar] и написать
/// что-то на подобии этой системы, что конечно более верный и надежный подход. Или наследоваться от класса GetBar,
/// т.е. оставляя все как есть, но чуть расширяя существующий функционал, это не совсем корректный подход т.к.
/// это не открытое API и при возможных изменениях родителя в новых версиях библиотеки все может сломаться
/// (принцип открытости/закрытости из SOLID).
///
/// Но так как мне нужно было расширить существующий [GetBar] парой виджетов в его поддереве (не трогая функционал)
/// и SnackBar нужен лишь для отображения текста, то я выбрал второй вариант - наследование.
class _CustomGetBar extends GetBar {
  _CustomGetBar({
    required this.child,
    Duration duration = const Duration(seconds: 5),
    SnackPosition snackPosition = SnackPosition.TOP,
    Key? key,
  }) : super(
          snackPosition: snackPosition,
          duration: duration,
          key: key,
        );

  /// Виджет того как он будет выглядеть SnackBar
  final Widget child;

  @override
  State<StatefulWidget> createState() => _CustomGetBarState();
}

class _CustomGetBarState extends State<_CustomGetBar> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Класс для упрощения создания SnackBar с составным сообщением
class SnackBarBuilder {
  SnackBarBuilder({this.title});

  /// Заголовок SnackBar
  final String? title;
  final List<String> _msgList = <String>[];

  String get msg => _msgList.join('\n');

  /// Метод добавления сообщения
  void addMsg(String msg) {
    _msgList.add(msg);
  }

  /// Отобразить на экране собранный SnackBar
  void show() {
    CustomSnackBar.show(title: title, msg: msg);
  }
}
