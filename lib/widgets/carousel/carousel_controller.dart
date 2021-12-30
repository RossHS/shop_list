import 'package:flutter/cupertino.dart';

/// Обертка над контроллером PageController используемом в PageView
/// TODO 30.12.2021 скорее всего перенесу в carousel_widget, дабы не нарушать инкапсуляцию
class CarouselController {
  PageController? pageController;
  var realPage = 100000;
  var initialPage = 0;
}
