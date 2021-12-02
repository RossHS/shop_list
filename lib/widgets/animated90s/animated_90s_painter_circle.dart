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
    final theme = Theme.of(context);
    final floatingActionButtonTheme = theme.floatingActionButtonTheme;
    final colorScheme = theme.colorScheme;
    final foregroundColor = floatingActionButtonTheme.foregroundColor ?? colorScheme.onSecondary;

    var config = this.config ?? const Paint90sConfig();
    config = config.copyWith(backgroundColor: floatingActionButtonTheme.backgroundColor ?? colorScheme.secondary);

    return AnimatedPainterCircle90s(
      config: config,
      duration: duration,
      child: ConstrainedBox(
        constraints: const BoxConstraints.tightFor(height: 56.0, width: 56.0),
        child: RepaintBoundary(
          child: RawMaterialButton(
            shape: const CircleBorder(),
            onPressed: onPressed,
            child: IconTheme.merge(
              data: IconThemeData(color: foregroundColor),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

//-------------------------------------------------------------------------------------------//

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
          config: config ?? const Paint90sConfig(),
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
        painter: _CirclePainter(
          config: widget.config,
          notifier: notifier,
        ),
        child: widget.child,
      ),
    );
  }
}

/// Отрисовщик круга
class _CirclePainter extends CustomPainter {
  const _CirclePainter({
    required this.config,
    required this.notifier,
  }) : super(repaint: notifier);

  final Paint90sConfig config;
  final ValueNotifier<int> notifier;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size / 2;
    final path = _generatePath(
      center: center,
      radius: center.width,
      notifier: notifier,
      config: config,
    );

    final outLine = Paint()
      ..strokeWidth = config.strokeWidth
      ..color = config.outLineColor
      ..style = PaintingStyle.stroke;

    final background = Paint()
      ..style = PaintingStyle.fill
      ..color = config.backgroundColor;

    canvas.drawPath(path, background);
    canvas.drawPath(path, outLine);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

//-------------------------------------------------------------------------------------------------//

/// Так как использование PathClipper слишком затратное, а использовать его придется часто -
/// было принято решение создать рамку с "вырезанным" кругом, где цвет рамки совпадает со цветом
/// фона.
/// НЕ РЕКОМЕНДУЕТСЯ К ПРИМЕНЕНИЮ! Т.к. это решение для узкой задачи
class AnimatedPainterCircleWithBorder90s extends AnimatedPainter90s {
  const AnimatedPainterCircleWithBorder90s({
    required Widget child,
    Duration? duration,
    Paint90sConfig? config,
    this.boxColor,
    Key? key,
  }) : super(
          child: child,
          duration: duration ?? const Duration(milliseconds: 80),
          config: config ?? const Paint90sConfig(),
          key: key,
        );

  final Color? boxColor;

  @override
  State<StatefulWidget> createState() => _AnimatedPainterCircleWithBorder90sState();
}

class _AnimatedPainterCircleWithBorder90sState extends AnimatedPainter90sState<AnimatedPainterCircleWithBorder90s> {
  @override
  Widget build(BuildContext context) {
    var backgroundColor = widget.boxColor ?? Colors.black;

    return RepaintBoundary(
      child: CustomPaint(
        foregroundPainter: _CircleWithBorderPainter(
          config: widget.config,
          notifier: notifier,
          boxColor: backgroundColor,
        ),
        child: widget.child,
      ),
    );
  }
}

class _CircleWithBorderPainter extends CustomPainter {
  const _CircleWithBorderPainter({
    required this.config,
    required this.notifier,
    required this.boxColor,
  }) : super(repaint: notifier);

  final Paint90sConfig config;
  final ValueNotifier<int> notifier;
  final Color boxColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size / 2;
    final path = _generatePath(
      center: center,
      radius: center.width - config.offset,
      notifier: notifier,
      config: config,
    );

    // Небольшой отступ для квадрата, чтобы он не ложился пиксель в пиксель на ребенка
    const rectOffset = 3.0;
    final outPath = Path()
      ..addPath(path, Offset.zero)
      ..addRect(Rect.fromCenter(
          center: Offset(center.width, center.height),
          width: size.width + rectOffset,
          height: size.height + rectOffset))
      ..fillType = PathFillType.evenOdd;

    final outLine = Paint()
      ..strokeWidth = config.strokeWidth
      ..color = config.outLineColor
      ..style = PaintingStyle.stroke;

    final background = Paint()
      ..style = PaintingStyle.fill
      ..color = boxColor;

    canvas.drawPath(outPath, background);
    canvas.drawPath(path, outLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

//--------------------------------------------------------------------------------------------------//

/// Генерация круга с "помехами" по краям. Минимальный отступ равен размеру [size],
/// а максимальный определяется [config.offset]
Path _generatePath({
  required Size center,
  required double radius,
  required ValueNotifier<int> notifier,
  required Paint90sConfig config,
}) {
  final path = Path();
  var random = math.Random(notifier.value);

  var rotateAngle = 0.0;
  path.moveTo(radius + random.nextInt(config.offset), center.height + radius + random.nextInt(config.offset));
  do {
    rotateAngle += random.nextInt(config.offset) + config.offset;
    if (rotateAngle > 360) rotateAngle = 360;

    var radian = rotateAngle * math.pi / 180;
    var rndX = random.nextInt(config.offset);
    var rndY = random.nextInt(config.offset);
    var x = center.width + radius * math.sin(radian);
    var y = center.height + radius * math.cos(radian);

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
