import 'dart:math';

import 'package:flutter/material.dart';

/// Класс анимированной иконки, которая переключается между элементами списка [_iconsList]
/// с заданной задержкой [_duration]
class AnimatedIcon90s extends StatefulWidget {
  const AnimatedIcon90s({
    required List<IconData> iconsList,
    Duration? duration,
    this.color,
    Key? key,
  })  : _iconsList = iconsList,
        _duration = duration ?? const Duration(milliseconds: 80),
        super(key: key);

  /// Список допустимых иконок
  final List<IconData> _iconsList;

  /// Задержка переключения анимации между элементами [iconList]
  final Duration _duration;

  /// Цвет отображаемой иконки
  final Color? color;

  @override
  _AnimatedIcon90sState createState() => _AnimatedIcon90sState();
}

class _AnimatedIcon90sState extends State<AnimatedIcon90s> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final _rnd = Random();

  /// Индекс элемента из списка конфигурации
  var _oldIndex = 0;

  /// Объект слушателя, по изменению которого обновляется отображение
  late final _notifier = ValueNotifier<IconData>(_getIcon());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget._duration,
      vsync: this,
    );
    // Запуск цикла анимации
    _repeater();
  }

  @override
  void didUpdateWidget(AnimatedIcon90s oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget._duration != widget._duration) {
      _controller.duration = widget._duration;
    }
  }

  @override
  void dispose() {
    _controller
      ..stop()
      ..dispose();
    super.dispose();
  }

  /// Метод перезапуска анимации по ее окончанию
  void _repeater() {
    _controller.forward(from: 0).whenComplete(() {
      _notifier.value = _getIcon();
      _repeater();
    });
  }

  /// Возвращает случайную иконку из массива конфигурации
  IconData _getIcon() {
    int newIndex;
    do {
      newIndex = _rnd.nextInt(widget._iconsList.length);
    } while (newIndex == _oldIndex);
    _oldIndex = newIndex;

    return widget._iconsList[newIndex];
  }

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final iconSize = iconTheme.size;
    final iconColor = iconTheme.color!;

    return SizedBox(
      height: iconSize,
      width: iconSize,
      child: Center(
        child: RepaintBoundary(
          child: ValueListenableBuilder<IconData>(
            valueListenable: _notifier,
            builder: (_, icon, child) => RichText(
              overflow: TextOverflow.visible, // Never clip.
              text: TextSpan(
                text: String.fromCharCode(icon.codePoint),
                style: TextStyle(
                  inherit: false,
                  color: iconColor,
                  fontSize: iconSize,
                  fontFamily: icon.fontFamily,
                  package: icon.fontPackage,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
