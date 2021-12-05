import 'package:flutter/material.dart';

/// Кнопка выбора цветой схемы [ColorScheme] приложения
class PaletteColorSelector extends StatefulWidget {
  const PaletteColorSelector({
    Key? key,
    required this.onPressed,
    this.paletteDiameter = 44,
    this.mainColor = Colors.black,
    this.additionColor = Colors.white,
  }) : super(key: key);

  /// Событие при нажатии на кнопку
  final void Function() onPressed;

  /// Диаметр кнопки выбора схема
  final double paletteDiameter;

  /// Основной цвет палитры
  final Color mainColor;

  /// Второстепенный цвет
  final Color additionColor;

  @override
  State<PaletteColorSelector> createState() => _PaletteColorSelectorState();
}

class _PaletteColorSelectorState extends State<PaletteColorSelector> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    // Использую связь TweenSequence т.к. анимации требовалось "выйти за рамки диаметра кнопки",
    // а после с 0 вернуться на исходную позицию
    _animation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 5, end: widget.paletteDiameter / 2),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 5),
        weight: 50.0,
      ),
    ]).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutQuart,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ConstrainedBox(
        constraints: BoxConstraints.expand(
          width: widget.paletteDiameter,
          height: widget.paletteDiameter,
        ),
        child: CustomPaint(
          painter: _ColorPalettePainter(
            mainColor: widget.mainColor,
            additionColor: widget.additionColor,
            innerCircleRadius: _animation,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                widget.onPressed();
                // При нажатии на кнопку запускаем с 0 анимацию внутреннего круга
                _animationController.forward(from: 0);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorPalettePainter extends CustomPainter {
  const _ColorPalettePainter({
    required this.mainColor,
    required this.additionColor,
    required this.innerCircleRadius,
  }) : super(repaint: innerCircleRadius);

  final Color mainColor;
  final Color additionColor;

  final Animation<double> innerCircleRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final mainColorPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = mainColor
      ..strokeWidth = 10;

    final additionColorPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = additionColor;

    // Основной цвет = фону scaffold, то в качестве внешнего круга он не подходит,
    // т.к. сливается с фоном, хотя логичнее его было бы поставить на внешний круг
    // => я сделал его внутренней окружностью
    canvas.drawCircle(center, size.height / 2, additionColorPaint);
    canvas.drawCircle(center, innerCircleRadius.value, mainColorPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
