import 'package:flutter/material.dart';

// TODO 10.01.2022 ДОПИЛИТЬ!
class DragAndSetOffset extends StatefulWidget {
  const DragAndSetOffset({
    Key? key,
  }) : super(key: key);

  @override
  State<DragAndSetOffset> createState() => _DragAndSetOffsetState();
}

class _DragAndSetOffsetState extends State<DragAndSetOffset> {
  late Offset offset = Offset(0, 0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AspectRatio(
      aspectRatio: 1,
      // Костыль закрывающий проблему, когда можно было начать
      // скролл родительского ListView при зажатии дочерних
      // элементов этой части дерева
      // IgnorePointer/AbsorbPointer не подходят для такого типа задачи
      child: GestureDetector(
        onHorizontalDragStart: (_) {},
        onVerticalDragStart: (_) {},
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            color: theme.canvasColor,
          ),
          child: Stack(
            children: [
              Positioned.fill(
                  child: Container(
                color: Colors.green,
              )),
              Positioned(
                left: offset.dx,
                top: offset.dy,
                child: Listener(
                  behavior: HitTestBehavior.deferToChild,
                  onPointerDown: (details) {
                    print('on PointerDOWN');
                    setState(() {
                      offset = Offset(offset.dx + details.delta.dx, offset.dy + details.delta.dy);
                    });
                  },
                  onPointerMove: (details) {
                    print('on PointerMove');
                    setState(() {
                      offset = Offset(offset.dx + details.delta.dx, offset.dy + details.delta.dy);
                    });
                  },
                  child: SizedBox.square(
                    dimension: 50,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Colors.red),
                      child: Icon(Icons.add),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
