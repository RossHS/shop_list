import 'package:flutter/material.dart';

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
    final pageController = widget._controller.pageController!;
    return PageView.builder(
      controller: pageController,
      onPageChanged: (page) {
        if (widget.onPageChanged != null) {
          final currentPage =
              _realIndex(page + widget._controller.initialPage, widget._controller.realPage, widget.items.length);
          widget.onPageChanged!(currentPage);
        }
      },
      itemBuilder: (context, index) {
        final calcIndex =
            _realIndex(index + widget._controller.initialPage, widget._controller.realPage, widget.items.length);
        return AnimatedBuilder(
          animation: pageController,
          builder: (context, child) {
            double itemOffset;
            // т.к. обращение к widget._controller.pageController!.page при первом построении вызывает исключение
            // Page value is only available after content dimensions are established.
            // 'package:flutter/src/widgets/page_view.dart':
            // Failed assertion: line 402 pos 7: '!hasPixels || hasContentDimensions'
            // То в ручную рассчитываем размеры
            try {
              itemOffset = pageController.page! - index;
            } catch (e) {
              itemOffset = widget._controller.realPage.toDouble() - index;
            }
            final scale = (1 - (itemOffset.abs() * 0.3)).clamp(0.0, 1.0);
            return Transform.scale(
              scale: scale,
              child: child!,
            );
          },
          child: widget.items[calcIndex % (widget.items.length)],
        );
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
int _realIndex(int position, int base, int length) {
  if (length == 0) return 0;
  final offset = position - base;
  final res = offset % length;
  return res < 0 ? length + res : res;
}

/// Обертка над контроллером PageController используемом в PageView
/// TODO 30.12.2021 скорее всего перенесу в carousel_widget, дабы не нарушать инкапсуляцию
class CarouselController {
  CarouselController({
    this.pageController,
    this.realPage = 100000,
    this.initialPage = 0,
  });

  PageController? pageController;
  final int realPage;
  final int initialPage;

  int calcPageIndex(int length) {
    return _realIndex(pageController?.page?.toInt() ?? 0 + initialPage, realPage, length);
  }
}
