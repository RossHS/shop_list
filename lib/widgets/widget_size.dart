import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Виджет для определения размеров RenderObject в рантайме
class WidgetSize extends StatefulWidget {
  const WidgetSize({
    Key? key,
    required this.onSizeChange,
    required this.child,
  }) : super(key: key);

  final Widget child;
  final void Function(Size? size) onSizeChange;

  @override
  State<WidgetSize> createState() => _WidgetSizeState();
}

class _WidgetSizeState extends State<WidgetSize> {
  var widgetKey = GlobalKey();
  Size? oldSize;

  void postFrameCallback(_) {
    var context = widgetKey.currentContext;
    if (context == null) return;

    var newSize = context.size;
    if (oldSize == newSize) return;

    oldSize = newSize;
    widget.onSizeChange(newSize);
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback(postFrameCallback);
    return SizedBox(
      key: widgetKey,
      child: widget.child,
    );
  }
}
