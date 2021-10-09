import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'animated_90s_painter.dart';

/// кнопка внутри анимированного круга
class AnimatedCircleButton90s extends StatelessWidget {
  const AnimatedCircleButton90s({
    required this.child,
    required this.onPressed,
    this.config,
    this.duration,
    Key? key,
  }) : super(key: key);

  final Widget child;
  final void Function() onPressed;
  final Paint90sConfig? config;
  final Duration? duration;

  @override
  Widget build(BuildContext context) {
    return AnimatedPainterCircle90s(
      config: config,
      duration: duration,
      child: ConstrainedBox(
        constraints: const BoxConstraints.tightFor(height: 56.0, width: 56.0),
        child: RepaintBoundary(
          child: RawMaterialButton(
            shape: const CircleBorder(),
            onPressed: onPressed,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Анимированный круг
class AnimatedPainterCircle90s extends AnimatedPainter90s {
  const AnimatedPainterCircle90s({
    required Widget child,
    Duration? duration,
    Paint90sConfig? config,
    Key? key,
  }) : super(
          child: child,
          duration: duration ?? const Duration(milliseconds: 80),
          config: config ?? const Paint90sConfig(backgroundColor: Colors.lightBlueAccent),
          key: key,
        );

  @override
  _AnimatedPainterCircle90sState createState() => _AnimatedPainterCircle90sState();
}

class _AnimatedPainterCircle90sState extends AnimatedPainter90sState<AnimatedPainterCircle90s> {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _Painter(
          config: widget.config,
          notifier: notifier,
        ),
        child: widget.child,
      ),
    );
  }
}

/// Отрисовщик круга
class _Painter extends CustomPainter {
  const _Painter({
    required this.config,
    required this.notifier,
  }) : super(repaint: notifier);

  final Paint90sConfig config;
  final ValueNotifier<int> notifier;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _generatePath(size);

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

  /// Генерация круга с "помехами" по краям
  Path _generatePath(Size size) {
    final path = Path();
    var random = math.Random(notifier.value);
    final center = size / 2;

    final radius = center.width;

    var rotateAngle = 0.0;
    path.moveTo(center.width + random.nextInt(config.offset), size.height + random.nextInt(config.offset));
    do {
      rotateAngle += random.nextInt(config.offset) + config.offset;
      if (rotateAngle > 360) rotateAngle = 360;

      var radian = rotateAngle * math.pi / 180;
      var rndX = random.nextInt(config.offset);
      var rndY = random.nextInt(config.offset);
      var x = radius + radius * math.sin(radian);
      var y = radius + radius * math.cos(radian);

      // корректное "увеличение" круга в зависимости от квадранта
      if (rotateAngle >= 0 && rotateAngle <= 90) {
        x += rndX;
        y += rndY;
      } else if (rotateAngle >= 90 && rotateAngle <= 180) {
        x += rndX;
        y -= rndY;
      } else if (rotateAngle >= 180 && rotateAngle <= 270) {
        x -= rndX;
        y -= rndY;
      } else if (rotateAngle >= 270 && rotateAngle <= 360) {
        x -= rndX;
        y += rndY;
      }

      path.lineTo(x, y);
    } while (rotateAngle < 360);

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
