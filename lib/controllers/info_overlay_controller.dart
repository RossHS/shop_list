// ignore_for_file: unused_element

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_list/widgets/themes_widgets/theme_dep.dart';

/// Класс для вызова оверлея на подобии SnackBar библиотеки GetX.
class CustomInfoOverlay {
  CustomInfoOverlay({
    this.title,
    required this.msg,
    this.child,
  });

  /// Заголовок сообщения
  String? title;

  /// Само сообщение
  String msg;

  /// Дополнительный виджет для отображения в оверлее
  Widget? child;

  /// Следует ли удалять оверлей
  final overlayToRemove = ValueNotifier<bool>(false);

  OverlayEntry? overlayEntry;

  /// Отображает оверлей на подобии SnackBar с заданным заголовком и сообщением
  static void show({
    String? title,
    required String msg,
    Widget? child,
  }) async {
    final toastOverlay = CustomInfoOverlay(
      title: title,
      msg: msg,
      child: child,
    );
    toastOverlay._init();
  }

  /// Запуск оверлея
  void _init() {
    // Подписываемся на событие поднятия флага к удалению оверлея
    overlayToRemove.addListener(_checkForDelete);
    final navigationState = Navigator.of(Get.overlayContext!, rootNavigator: false);
    final overlayState = navigationState.overlay!;
    overlayEntry = OverlayEntry(
      builder: (context) {
        return _CustomOverlay(
          overlayToRemoveNotifier: overlayToRemove,
          child: ThemeDepInfoOverlay(
            title: title,
            msg: msg,
            child: child,
          ),
        );
      },
    );
    overlayState.insert(overlayEntry!);
  }

  /// Проверка, следует ли удалять оверлей с экрана
  void _checkForDelete() {
    if (overlayToRemove.value == true) {
      overlayEntry!.remove();
      overlayToRemove.removeListener(_checkForDelete);
      overlayToRemove.dispose();
    }
  }
}

/// Виджет, который будет отображаться в оверлее. По прошествии времени [animationDuration]
/// или пользовательскому событию поднимет флаг в переменной [overlayToRemoveNotifier] о готовности к удалению.
/// После чего будет вызван слушатель в [CustomInfoOverlay], который очистит OverlayEntry.
class _CustomOverlay extends StatefulWidget {
  const _CustomOverlay({
    super.key,
    required this.child,
    required this.overlayToRemoveNotifier,
    this.animationDuration = const Duration(seconds: 5),
  });

  /// Виджет того как он будет выглядеть оверлей
  final Widget child;

  /// Продолжительность входа и выхода оверлея
  final Duration animationDuration;

  /// Флаг со значением, следует ли удалять оверлей
  final ValueNotifier<bool> overlayToRemoveNotifier;

  @override
  State<StatefulWidget> createState() => _CustomOverlayState();
}

class _CustomOverlayState extends State<_CustomOverlay> with SingleTickerProviderStateMixin {
  /// Контроллер анимации, который используется в AlignTransition
  late final AnimationController _controller;
  late final Animation<Alignment> _alignmentTween;

  /// Таймер для автоматического удаления оверлея использовал RestartableTimer,
  /// т.к. в будущем может потребоваться операция сброса таймера
  late final RestartableTimer _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _alignmentTween = AlignmentTween(
      begin: const Alignment(-1.0, -2.0),
      end: const Alignment(-1.0, -1.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCirc,
    ));

    _controller.forward();

    _timer = RestartableTimer(widget.animationDuration, () async {
      await _controller.reverse();
      _dismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlignTransition(
      alignment: _alignmentTween,
      child: Dismissible(
        key: ValueKey(this),
        direction: DismissDirection.up,
        onDismissed: (_) {
          _dismiss();
        },
        child: widget.child,
      ),
    );
  }

  /// Обратный вызов с информацией о том, что оверлей готов к удалению
  void _dismiss() {
    widget.overlayToRemoveNotifier.value = true;
    _timer.cancel();
  }
}

/// Класс для упрощения создания оверлея с составным сообщением
class OverlayBuilder {
  OverlayBuilder({
    this.title,
    this.child,
  });

  /// Заголовок сообщения
  final String? title;
  final List<String> _msgList = <String>[];
  final Widget? child;

  String get msg => _msgList.join('\n');

  /// Метод добавления сообщения
  void addMsg(String msg) {
    _msgList.add(msg);
  }

  /// Отобразить на экране собранный SnackBar
  void show() {
    CustomInfoOverlay.show(title: title, msg: msg);
  }
}
