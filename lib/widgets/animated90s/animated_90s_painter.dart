import 'dart:math';

import 'package:flutter/material.dart';

abstract class AnimatedPainter90s extends StatefulWidget {
  const AnimatedPainter90s({
    required this.child,
    this.duration = const Duration(milliseconds: 120),
    this.config = const Paint90sConfig(),
    Key? key,
  }) : super(key: key);

  final Widget child;
  final Duration duration;
  final Paint90sConfig config;
}

abstract class AnimatedPainter90sState<T extends AnimatedPainter90s> extends State<T>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final _random = Random();
  late final ValueNotifier<int> notifier;

  @override
  void initState() {
    notifier = ValueNotifier(_random.nextInt(1000000));
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _repeater();
  }

  @override
  void dispose() {
    _controller
      ..stop()
      ..dispose();
    super.dispose();
  }

  void _repeater() {
    _controller.forward(from: 0).whenComplete(() {
      notifier.value = _random.nextInt(1000000);
      _repeater();
    });
  }
}

/// Конфигурация для рисования.
class Paint90sConfig {
  // Сделал поля nullable, чтобы упростить вызов конструктора и придать большей гибкости,
  // т.е. можно передавать null в качестве аргумента, и он спокойно преобразуется
  // в осмысленное значение. Иначе, если писать напрямую через this.outLineColor = Colors.black
  // в конструкторе, то при вызове конструктора нужно гарантировать non-null, и тогда
  // приходится неоправдано раздувать вызывающий код, чтобы это гарантировать
  const Paint90sConfig({
    int? offset,
    double? strokeWidth,
    Color? backgroundColor,
    Color? outLineColor,
  })  : strokeWidth = 3,
        offset = offset ?? 10,
        backgroundColor = backgroundColor ?? Colors.white,
        outLineColor = outLineColor ?? Colors.black;

  /// Толщина линии контура
  final double strokeWidth;

  /// Отступы для генерации "помех" рисунка
  final int offset;

  /// Цвет фона
  final Color backgroundColor;

  /// Цвет линии
  final Color outLineColor;
}
