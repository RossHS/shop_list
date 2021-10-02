import 'package:flutter/material.dart';
import 'package:shop_list/controllers/authentication_controller.dart';

/// Главный экран пользователя, где отображаются все актуальные списки покупок
class Home extends StatelessWidget {
  Home({Key? key}) : super(key: key);
  final _authController = AuthenticationController.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Center(
          child: TextButton(
            onPressed: () {
              _authController.signOut();
            },
            child: const Text('SIGN OUT'),
          ),
        ),
      ),
    );
  }
}
