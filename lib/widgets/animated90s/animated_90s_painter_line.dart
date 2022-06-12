import 'dart:math';

import 'package:flutter/material.dart';

import 'animated_90s_painter.dart';

class AnimatedPainterLine90s extends AnimatedPainter90s {
  const AnimatedPainterLine90s({
    required Widget child,
    Duration? duration,
    Paint90sConfig? config,
    this.paintSide = PaintSide.bottom,
    Key? key,
  }) : super(
          child: child,
          duration: duration ?? const Duration(milliseconds: 80),
          config: config ?? const Paint90sConfig(),
          key: key,
        );

  final PaintSide paintSide;

  @override
  AnimatedPainter90sState<AnimatedPainterLine90s> createState() => _AnimatedPainterLine90sState();
}

class _AnimatedPainterLine90sState extends AnimatedPainter90sState<AnimatedPainterLine90s> {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _Painter(
          config: widget.config,
          paintSide: widget.paintSide,
          notifier: notifier,
        ),
        child: widget.child,
      ),
    );
  }
}

class _Painter extends CustomPainter {
  _Painter({
    required this.paintSide,
    required this.config,
    required this.notifier,
  }) : super(repaint: notifier);

  final PaintSide paintSide;
  Paint90sConfig config;
  ValueNotifier<int> notifier;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _generatePath(size);

    var outLine = Paint()
      ..strokeWidth = config.strokeWidth
      ..color = config.outLineColor
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, outLine);
  }

  Path _generatePath(Size size) {
    Path path = Path();
    // Для гарантии перерисовки только по событию от notifier,
    // иначе создается новый Random() каждый раз, что приводит
    // к кардинально новым рисункам
    var random = Random(notifier.value);

    // Определение стороны куда следует рисовать линию,
    // также выбирается случайная точка начала, чтобы не стартовать с условной 0,0
    switch (paintSide) {
      case PaintSide.top:
        path.moveTo(
          size.width - random.nextInt(config.offset).toDouble(),
          -random.nextInt(config.offset).toDouble(),
        );
        var x = size.width;
        var y = 0.0;
        do {
          x -= random.nextInt(config.offset);
          y = -random.nextInt(config.offset).toDouble();
          path.lineTo(x, y);
        } while (x > 0);
        break;
      case PaintSide.bottom:
        path.moveTo(
          -random.nextInt(config.offset).toDouble(),
          size.height + random.nextInt(config.offset).toDouble(),
        );
        var x = 0.0;
        var y = 0.0;
        do {
          x += random.nextInt(config.offset);
          y = size.height + random.nextInt(config.offset);
          path.lineTo(x, y);
        } while (x < size.width);
        break;
      case PaintSide.left:
        path.moveTo(
          -random.nextInt(config.offset).toDouble(),
          -random.nextInt(config.offset).toDouble(),
        );
        var x = 0.0;
        var y = 0.0;
        do {
          y += random.nextInt(config.offset);
          x = -random.nextInt(config.offset).toDouble();
          path.lineTo(x, y);
        } while (y < size.height);
        break;
      case PaintSide.right:
        path.moveTo(
          size.width - random.nextInt(config.offset).toDouble(),
          size.height - random.nextInt(config.offset).toDouble(),
        );
        var x = 0.0;
        var y = size.height;
        do {
          y -= random.nextInt(config.offset);
          x = size.width + random.nextInt(config.offset).toDouble();
          path.lineTo(x, y);
        } while (y > 0);
        break;
    }

    return path;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

enum PaintSide { top, bottom, left, right }
