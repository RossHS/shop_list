import 'package:flutter/material.dart';
import 'package:shop_list/models/models.dart';
import 'package:shop_list/widgets/widget_size.dart';

// TODO 10.01.2022 ДОПИЛИТЬ!
class DragAndSetOffset extends StatefulWidget {
  const DragAndSetOffset({
    Key? key,
    required this.children,
  }) : super(key: key);
  final List<DragOffsetChild> children;

  @override
  State<DragAndSetOffset> createState() => _DragAndSetOffsetState();
}

class _DragAndSetOffsetState extends State<DragAndSetOffset> {
  Size? size;
  static const double _childRadius = 30;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(_childRadius / 2),
      child: GestureDetector(
        onHorizontalDragStart: (_) {},
        onVerticalDragStart: (_) {},
        child: WidgetSize(
          onSizeChange: (size) {
            if (size != null) {
              setState(() {
                this.size = size;
              });
            }
          },
          child: AspectRatio(
            aspectRatio: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.canvasColor,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  ...widget.children.map<Positioned>(
                    (element) => Positioned(
                      // В конце минус половина от радиуса ребенка, чтобы подогнать параметры left и top под центр
                      left: _calcPosition(size?.width ?? 0, element.offset.dx, element.diapason) - _childRadius / 2,
                      top: _calcPosition(size?.height ?? 0, element.offset.dy, element.diapason) - _childRadius / 2,
                      child: Listener(
                        behavior: HitTestBehavior.deferToChild,
                        onPointerDown: (details) {
                          _updateOffset(element, details.delta);
                        },
                        onPointerMove: (details) {
                          _updateOffset(element, details.delta);
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
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _updateOffset(DragOffsetChild element, Offset newOffset) {
    // TODO 11.01.2022 - написать реализцаия, данный вариант зависит от скорости перемещения по экрану
    final offset = Offset(_calcPosition(size!.width, element.offset.dx, element.diapason) + newOffset.dx,
        _calcPosition(size!.height, element.offset.dy, element.diapason) + newOffset.dy);
    element.callback(Offset(
      _lerpCoordinate(size!.width, offset.dx, element.diapason),
      _lerpCoordinate(size!.height, offset.dy, element.diapason),
    ));
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
