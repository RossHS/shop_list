import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    final touchCenter = _TouchGetterProviderState._offset;
    final screenSize = mq.size;
    final screenCenter = screenSize / 2;

    final double x;
    final double y;
    if (touchCenter != null) {
      x = touchCenter.dx > screenCenter.width ? touchCenter.dx : screenSize.width - touchCenter.dx;
      y = touchCenter.dy > screenCenter.height ? touchCenter.dy : screenSize.height - touchCenter.dy;
    } else {
      x = screenCenter.width;
      y = screenCenter.height;
    }

    // Расчет радиуса описанной окружности по теореме пифагора
    final radius = math.sqrt(math.pow(x, 2) + math.pow(y, 2));
    return Align(
      alignment: Alignment.center,
      child: ClipPath(
        clipper: CircleClipper(
          center: touchCenter ?? Offset(screenSize.width / 2, screenSize.height / 2),
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

/// Получение координаты нажатия на экран, используется только для запуска анимации перехода [CustomCircleTransition]
/// Изначально не хотел использовать статическую переменную, т.к. из-за нее теряется "контекст" нажатия на экран,
/// да и вообще это плохая практика в использовании глобальных переменных.
///
/// Планировал использовать InheritedWidget, в котором будет содержаться точка клика, из которой будет запущена анимация,
/// но такой подход не удалась так просто реализовать из-за того, что контекст в buildTransition не может достучаться
/// до необходимого мне виджета. Для решения данной задачи скорее всего потребуется переписать вызовы маршрутов GetX,
/// на что более близкое к ванильному Flutter.
///
/// Так же есть вариант использовать StateManager GetX, но тогда этот код станет непереносимым в другие проекты,
/// т.к. там потребуется зависимость GetX в проекте
/// TODO 15.12.2021 подумать о замене глобальной переменной на InheritedWidget
class TouchGetterProvider extends StatefulWidget {
  const TouchGetterProvider({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<TouchGetterProvider> createState() => _TouchGetterProviderState();
}

class _TouchGetterProviderState extends State<TouchGetterProvider> {
  static Offset? _offset;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (details) {
        setState(() {
          _offset = details.position;
        });
      },
      child: widget.child,
    );
  }
}
