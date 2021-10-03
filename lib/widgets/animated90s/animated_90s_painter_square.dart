import 'dart:math';

import 'package:flutter/material.dart';

import 'animated_90s_painter.dart';

class AnimatedPainterSquare90s extends AnimatedPainter90s {
  const AnimatedPainterSquare90s({
    required Widget child,
    Duration? duration,
    Paint90sConfig? config,
    this.borderPaint = const BorderPaint.all(),
    Key? key,
  }) : super(
          child: child,
          duration: duration ?? const Duration(milliseconds: 80),
          config: config ?? const Paint90sConfig(),
          key: key,
        );

  final BorderPaint borderPaint;

  @override
  _AnimatedPainterSquare90sState createState() => _AnimatedPainterSquare90sState();
}

class _AnimatedPainterSquare90sState extends AnimatedPainter90sState<AnimatedPainterSquare90s> {
  @override
  void initState() {
    super.initState();
    notifier = ValueNotifier<CustomPainter>(_Painter(
      borderPaint: widget.borderPaint,
      config: widget.config,
    ));
  }

  @override
  void updateValue() {
    notifier.value = _Painter(
      borderPaint: widget.borderPaint,
      config: widget.config,
    );
  }
}

class _Painter extends CustomPainter {
  _Painter({required this.borderPaint, required this.config});

  final BorderPaint borderPaint;
  Paint90sConfig config;

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();
    var random = Random();

    if (borderPaint.left) {
      // Задаю начальную точку не (0,0). А со случайным смещением,
      // чтобы фигура не имела "плоский" край в левом верхнем углу
      path.moveTo(
        -random.nextInt(config.offset).toDouble(),
        -random.nextInt(config.offset).toDouble(),
      );
      var x = 0.0;
      var y = 0.0;
      do {
        y += random.nextInt(config.offset);
        x = -random.nextInt(config.offset).toDouble();
        if (y > size.height) y = size.height;
        path.lineTo(x, y);
      } while (y < size.height);
    } else {
      path.lineTo(0, size.height);
    }

    if (borderPaint.bottom) {
      var x = 0.0;
      var y = 0.0;
      do {
        x += random.nextInt(config.offset);
        y = size.height + random.nextInt(config.offset);
        if (x > size.width) x = size.width;
        path.lineTo(x, y);
      } while (x < size.width);
    } else {
      path.lineTo(size.width, size.height);
    }

    if (borderPaint.right) {
      var x = 0.0;
      var y = size.height;
      do {
        y -= random.nextInt(config.offset);
        x = size.width + random.nextInt(config.offset).toDouble();
        if (y < 0) y = 0;
        path.lineTo(x, y);
      } while (y > 0);
    } else {
      path.lineTo(size.width, 0.0);
    }

    if (borderPaint.top) {
      var x = size.width;
      var y = 0.0;
      do {
        x -= random.nextInt(config.offset);
        y = -random.nextInt(config.offset).toDouble();
        if (x < 0) x = 0;
        path.lineTo(x, y);
      } while (x > 0);
    }

    path.close();

    var outLine = Paint()
      ..strokeWidth = 3
      ..color = Colors.black
      ..style = PaintingStyle.stroke;

    var background = Paint()
      ..style = PaintingStyle.fill
      ..color = config.backgroundColor;

    canvas.drawPath(path, background);
    canvas.drawPath(path, outLine);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return this != oldDelegate;
  }
}

/// Перечень сторон по которым следует рисовать
class BorderPaint {
  const BorderPaint({
    this.top = false,
    this.bottom = false,
    this.left = false,
    this.right = false,
  });

  const BorderPaint.all()
      : this(
          top: true,
          bottom: true,
          left: true,
          right: true,
        );

  const BorderPaint.bottom()
      : this(
          top: false,
          bottom: true,
          left: false,
          right: false,
        );

  final bool top;
  final bool bottom;
  final bool left;
  final bool right;
}
