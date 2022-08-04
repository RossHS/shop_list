import 'package:flutter/material.dart';
import 'package:shop_list/models/models.dart';
import 'package:shop_list/widgets/widget_size.dart';

/// Виджет перемещение [DragOffsetChild] внутри [Stack]
class DragAndSetOffset extends StatefulWidget {
  const DragAndSetOffset({
    super.key,
    required this.children,
    this.backgroundColor = Colors.blueGrey,
  });

  final List<DragOffsetChild> children;

  /// Цвет заднего фона полотна
  final Color backgroundColor;

  @override
  State<DragAndSetOffset> createState() => _DragAndSetOffsetState();
}

class _DragAndSetOffsetState extends State<DragAndSetOffset> {
  Size? size;
  static const double _childRadius = 30;

  /// Вспомогательное состояние для захвата координат начала перетаскивания по экрану
  final _DragRecognizer _dragRecognizer = _DragRecognizer();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WidgetSize(
      onSizeChange: (size) {
        if (size != null) {
          setState(() {
            this.size = Size(size.width - _childRadius, size.height - _childRadius);
          });
        }
      },
      child: RepaintBoundary(
        child: AspectRatio(
          aspectRatio: 1,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(_childRadius / 2),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: widget.backgroundColor,
                    ),
                  ),
                ),
              ),
              ...widget.children.map<Positioned>(
                (element) {
                  final left = _calcPosition(size?.width ?? 0, element.offset.dx, element.diapason);
                  final top = _calcPosition(size?.height ?? 0, element.offset.dy, element.diapason);
                  return Positioned(
                    // В конце минус половина от радиуса ребенка, чтобы подогнать параметры left и top под центр
                    left: left,
                    top: top,
                    child: Listener(
                      behavior: HitTestBehavior.deferToChild,
                      onPointerDown: (details) {
                        _dragRecognizer.x = left;
                        _dragRecognizer.y = top;
                      },
                      onPointerMove: (details) {
                        element.callback(
                          Offset(
                            _lerpCoordinate(
                              size!.width,
                              _dragRecognizer.x + details.localPosition.dx - _childRadius / 2,
                              element.diapason,
                            ),
                            _lerpCoordinate(
                              size!.height,
                              _dragRecognizer.y + details.localPosition.dy - _childRadius / 2,
                              element.diapason,
                            ),
                          ),
                        );
                      },
                      child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 2,
                              color: theme.canvasColor.calcTextColor,
                            ),
                          ),
                          child: const SizedBox.square(dimension: _childRadius)),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Масштабный коэффициент
  double _calcFactor(double side, double diapason) => (side / 2) / diapason;

  /// Перерасчет в координаты для отображения внутри [Stack]
  double _calcPosition(double side, double point, double diapason) {
    if (point < -diapason) {
      point = -diapason;
    } else if (point > diapason) {
      point = diapason;
    }
    return point * _calcFactor(side, diapason) + side / 2;
  }

  /// Обратная операция преобразования координат [Stack] в значения для пользователя
  double _lerpCoordinate(double side, double localCoordinate, double diapason) {
    // Защита, чтобы не выходить на границы допустимые величиной offset
    if (localCoordinate < 0) {
      localCoordinate = 0;
    } else if (localCoordinate > side) {
      localCoordinate = side;
    }
    return (localCoordinate - (side / 2)) / _calcFactor(side, diapason);
  }
}

/// Вспомогательный класс для фиксации начальной точки перетаскивания по экрану.
/// Изначально хотел просто использовать Details.delta для расчета перемещений,
/// но данный способ оказался зависимым от частоты кадров,
/// т.е. чем быстрее ведешь палец, тем больше точка будет от него отставать.
/// Таким образом пришел к решению захватывать координату нажатия на экран в методе [Listener.onPointerDown] ,
/// а после использовать ее при перемещениях в методе [Listener.onPointerMove].
class _DragRecognizer {
  double x = 0.0;
  double y = 0.0;
}

/// Точка, которую мы будем перемещать по полю [DragAndSetOffset]
@immutable
class DragOffsetChild {
  const DragOffsetChild({
    required this.offset,
    required this.callback,
    required this.diapason,
  });

  /// Обертка для работы со значениями [Alignment]. По сути, разница
  /// лишь в допустимом диапазоне, у Alignment он равен -1;1
  factory DragOffsetChild.alignment({
    required Alignment alignment,
    required Function(Alignment alignment) callback,
  }) {
    return DragOffsetChild(
      offset: Offset(alignment.x, alignment.y),
      callback: (offset) {
        callback(Alignment(offset.dx, offset.dy));
      },
      diapason: 1,
    );
  }

  /// Текущая позиция [DragOffsetChild] внутри [DragAndSetOffset]
  final Offset offset;

  /// Передает в качестве аргумента измененное значение [offset]
  final void Function(Offset offset) callback;

  /// Диапазон, в котором может изменяться значение [offset]
  final double diapason;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DragOffsetChild &&
          runtimeType == other.runtimeType &&
          offset == other.offset &&
          diapason == other.diapason;

  @override
  int get hashCode => offset.hashCode ^ diapason.hashCode;
}
