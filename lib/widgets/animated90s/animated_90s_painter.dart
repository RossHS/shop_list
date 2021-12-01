import 'dart:async';
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

  /// Содержит в себе значение для сида Random(), чтобы управлять случайной
  /// составляющей отрисовки и производить видимую перестройку только лишь
  /// при смене ValueNotifier<int>
  late final ValueNotifier<int> notifier;

  /// Предзадержка инициализации повторения анимации. Необходим для того,
  /// чтобы переключение анимации всех элементов унаследованных от этого
  /// класса не происходило одновременно, а происходило выраженно для каждого
  /// элемента на экране по отдельности.
  /// Находится в диапазоне 0 < delay < widget.duration
  late final Timer preDelay;

  @override
  void initState() {
    notifier = ValueNotifier(_random.nextInt(1000000));
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    preDelay = Timer(
      Duration(microseconds: _random.nextInt(widget.duration.inMicroseconds)),
      _repeater,
    );
  }

  @override
  void dispose() {
    preDelay.cancel();
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
  // приходится неоправданно раздувать вызывающий код, чтобы это гарантировать
  const Paint90sConfig({
    int? offset,
    double? strokeWidth,
    Color? backgroundColor,
    Color? outLineColor,
  })  : assert(offset == null || (offset > 0 && offset <= 50), 'incorrect offset $offset'),
        assert(strokeWidth == null || (strokeWidth > 0 && strokeWidth <= 25), 'incorrect strokeWidth $strokeWidth'),
        offset = offset ?? 10,
        strokeWidth = strokeWidth ?? 3,
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

  Paint90sConfig copyWith({
    double? strokeWidth,
    int? offset,
    Color? backgroundColor,
    Color? outLineColor,
  }) {
    return Paint90sConfig(
      strokeWidth: strokeWidth ?? this.strokeWidth,
      offset: offset ?? this.offset,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      outLineColor: outLineColor ?? this.outLineColor,
    );
  }
}
