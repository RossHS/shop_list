import 'package:flutter/material.dart';
import 'package:shop_list/widgets/carousel/carousel_controller.dart';

/// Виджет прокручивающейся "карусели"
class Carousel extends StatefulWidget {
  Carousel({
    Key? key,
    required this.items,
    this.onPageChanged,
    CarouselController? controller,
  })  : _controller = controller ?? CarouselController(),
        super(key: key);

  final List<Widget> items;

  /// Callback вызываемый при переключении страницы
  final void Function(int page)? onPageChanged;
  final CarouselController _controller;

  @override
  State<Carousel> createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  @override
  void initState() {
    super.initState();
    widget._controller.pageController = PageController(
      viewportFraction: 0.7,
      initialPage: widget._controller.realPage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: widget._controller.pageController,
      onPageChanged: (page) {
        if (widget.onPageChanged != null) {
          final currentPage =
              realIndex(page + widget._controller.initialPage, widget._controller.realPage, widget.items.length);
          widget.onPageChanged!(currentPage);
        }
      },
      itemBuilder: (context, index) {
        index = realIndex(index + widget._controller.initialPage, widget._controller.realPage, widget.items.length);
        return widget.items[index % (widget.items.length)];
      },
    );
  }
}

/// Т.к. надо организовать бесконечно прокручивающийся список,
/// то в отображаемой позиции прячем реальную.
/// т.е. на самом деле мы начинаем прокрутку не с 0 стартовой позиции,
/// а с константы определенной в контроллере
/// где
/// [position] - текущая позиция,
/// [base] - реальная (не 0) позиция в контроллере,
/// [length] - длина отображаемой коллекции
int realIndex(int position, int base, int length) {
  if (length == 0) return 0;
  final offset = position - base;
  final res = offset % length;
  return res < 0 ? length + res : res;
}
