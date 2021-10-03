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
  late AnimationController _controller;

  late final ValueNotifier<CustomPainter> notifier;

  @override
  void initState() {
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
      updateValue();
      _repeater();
    });
  }

  void updateValue();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ValueListenableBuilder<CustomPainter>(
        valueListenable: notifier,
        builder: (_, value, child) => CustomPaint(
          painter: value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

/// Конфигурация для рисования.
class Paint90sConfig {
  const Paint90sConfig({
    this.offset = 10,
    this.backgroundColor = Colors.white,
  });

  /// Отступы для генерации "помех" рисунка
  final int offset;

  /// Цвет фона
  final Color backgroundColor;
}
