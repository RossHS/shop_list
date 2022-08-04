import 'package:flutter/material.dart';

/// Сделал анимированную декорацию по аналогии с анимированными классами типа [ImplicitlyAnimated].
/// Безусловно, команда Flutter в случае отсутствия стандартной "неявной" анимации (AnimatedAlign и т.п.)
/// рекомендует использовать виджет [TweenAnimationBuilder]. Но я не стал им пользоваться из-за того,
/// что он немного запутывает код.
/// Пример использования из [Settings._ColorPaletteBox] с [TweenAnimationBuilder]
///
/// ```dart
/// TweenAnimationBuilder>(
///   (entry) => TweenAnimationBuilder<Decoration>(
///     duration: Duration(seconds: 3),
///     tween: DecorationTween(
///         begin: null,
///         end: BoxDecoration(
///           color: ThemeController.to.appTheme.value.darkColorScheme == entry.value
///               ? Colors.black
///               : null,
///           shape: BoxShape.circle,
///         )),
///     builder: (context, value, child) {
///       return DecoratedBox(
///         decoration: value,
///         child: child,
///       );
///     },
///     child: IconButton(
///       onPressed: () => ThemeController.to.setDarkColorScheme(entry.value),
///       icon: const Icon(Icons.eleven_mp_outlined),
///     ),
///   ),
/// )
/// ```
///
///
/// И использование [AnimatedDecoration]
///
/// ```dart
/// AnimatedDecoration(
///   duration: Duration(milliseconds: 300),
///   decoration: BoxDecoration(
///     color:
///         ThemeController.to.appTheme.value.lightColorScheme == entry.value ? Colors.black : null,
///     shape: BoxShape.circle,
///   ),
///   child: IconButton(
///     onPressed: () => ThemeController.to.setLightColorScheme(entry.value),
///     icon: const Icon(
///       Icons.eleven_mp_outlined,
///     ),
///   ),
/// ),
/// ```
///
/// Одинаковые по своему применению виджеты, но второй вариант короче и понятней
class AnimatedDecoration extends ImplicitlyAnimatedWidget {
  const AnimatedDecoration({
    super.key,
    required this.decoration,
    this.child,
    required super.duration,
    super.curve,
  });

  final Decoration decoration;
  final Widget? child;

  @override
  ImplicitlyAnimatedWidgetState<ImplicitlyAnimatedWidget> createState() => _AnimatedDecoration();
}

class _AnimatedDecoration extends AnimatedWidgetBaseState<AnimatedDecoration> {
  DecorationTween? _decoration;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _decoration =
        visitor(_decoration, widget.decoration, (dynamic value) => DecorationTween(begin: value as Decoration))
            as DecorationTween?;
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: _decoration!.evaluate(animation),
      child: widget.child,
    );
  }
}
