import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

/// Анимация перехода между маршрутами. Создается увеличивающийся круг, который будет расширяться до тех пор,
/// пока не перекроет весь экран (станет описанной окружностью), радиус круга определяется по теореме Пифагора,
/// где катеты треугольника - это половина ширины и высоты экрана, а гипотенуза - радиус окружности
class CustomCircleTransition extends CustomTransition {
  @override
  Widget buildTransition(
    BuildContext context,
    Curve? curve,
    Alignment? alignment,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final mq = MediaQuery.of(context);
    final screenSize = mq.size;
    // Расчет радиуса описанной окружности по теореме пифагора
    final radius = math.sqrt(math.pow(screenSize.width / 2, 2) + math.pow(screenSize.height / 2, 2));
    return Align(
      alignment: Alignment.center,
      child: ClipPath(
        clipper: CircleClipper(
          center: Offset(screenSize.width / 2, screenSize.height / 2),
          // Т.к. не нашел API средств определения curve анимации в GetX,
          // то получаю преобразованное значение кривой таким образом.
          // Когда api navigation Flutter имеет специальный класс для
          // определения кастомных переходов [PageRouteBuilder],
          // в котором можно определить и свой контроллер анимации
          // при помощи метода [PageRouteBuilder.createAnimationController]
          radius: CurvedAnimation(parent: animation, curve: Curves.easeInOutCirc).value * radius,
        ),
        child: child,
      ),
    );
  }
}

class CircleClipper extends CustomClipper<Path> {
  CircleClipper({
    required this.center,
    required this.radius,
  }) : super();

  final Offset center;
  final double radius;

  @override
  Path getClip(Size size) {
    final path = Path();
    path.addOval(Rect.fromCircle(radius: radius, center: center));
    return path;
  }

  @override
  bool shouldReclip(CircleClipper oldClipper) {
    return oldClipper.radius != radius || oldClipper.center != center;
  }
}
