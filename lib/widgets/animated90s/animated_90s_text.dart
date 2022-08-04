import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class AnimatedText90s extends StatefulWidget {
  const AnimatedText90s(
    this.text, {
    super.key,
    this.duration = const Duration(milliseconds: 250),
    this.fontFamilies = const [
      'pepega font',
      'A Childish Wonders',
    ],
  });

  final String text;
  final Duration duration;
  final List<String> fontFamilies;

  @override
  State<AnimatedText90s> createState() => _AnimatedText90sState();
}

class _AnimatedText90sState extends State<AnimatedText90s> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final _rnd = Random();
  var _oldIndex = 0;

  late TextStyle style = TextStyle(
    fontFamily: widget.fontFamilies.first,
    fontFeatures: const [FontFeature.randomize()],
  );

  late final _notifier = ValueNotifier(_getStyle());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _repeater();
  }

  @override
  void dispose() {
    _controller
      ..stop
      ..dispose();
    super.dispose();
  }

  TextStyle _getStyle() {
    int newIndex;
    do {
      newIndex = _rnd.nextInt(widget.fontFamilies.length);
    } while (newIndex == _oldIndex);
    _oldIndex = newIndex;
    return style.copyWith(fontFamily: widget.fontFamilies[newIndex]);
  }

  /// Метод перезапуска анимации по ее окончанию
  void _repeater() {
    _controller.forward(from: 0).whenComplete(() {
      _notifier.value = _getStyle();
      _repeater();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ValueListenableBuilder<TextStyle>(
        valueListenable: _notifier,
        builder: (_, value, __) => Text(
          widget.text,
          style: value,
        ),
      ),
    );
  }
}
