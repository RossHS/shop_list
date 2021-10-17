import 'package:flutter/material.dart';
import 'package:shop_list/controllers/authentication_controller.dart';
import 'package:shop_list/custom_icons.dart';
import 'package:shop_list/widgets/animated90s/animated_90s_icon.dart';
import 'package:shop_list/widgets/animated90s/animated_90s_painter_circle.dart';

/// Главный экран пользователя, где отображаются все актуальные списки покупок
class Home extends StatelessWidget {
  Home({Key? key}) : super(key: key);
  final _authController = AuthenticationController.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () {
            _authController.signOut();
          },
          child: const Text('SIGN OUT'),
        ),
      ),
      floatingActionButton: AnimatedCircleButton90s(
        onPressed: () {},
        child: const AnimatedIcon90s(
          iconsList: CustomIcons.create,
        ),
      ),
    );
  }
}
