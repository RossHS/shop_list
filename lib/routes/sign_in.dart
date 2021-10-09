import 'package:flutter/material.dart';
import 'package:shop_list/controllers/authentication_controller.dart';
import 'package:shop_list/widgets/animated90s/animated_90s_painter_square.dart';
import 'package:shop_list/widgets/custom_text_field.dart';

/// Экран с формой логина в аккаунт
class SignIn extends StatelessWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: AnimatedPainterSquare90s(
            child: SizedBox(
              width: 500,
              height: 190,
              child: _CustomForm(),
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomForm extends StatelessWidget {
  _CustomForm({Key? key}) : super(key: key);
  final _formStateKey = GlobalKey<FormState>();
  final _authController = AuthenticationController.instance;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: RepaintBoundary(
        child: Form(
          key: _formStateKey,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  CustomTextField(
                    controller: _authController.emailController,
                    hint: 'email',
                  ),
                  CustomTextField(
                    controller: _authController.passwordController,
                    hint: 'password',
                    obscureText: true,
                  ),
                  const SizedBox(height: 30),
                  TextButton(
                    onPressed: () => _authController.signInWithEmail(context),
                    child: const Text('SIGN IN'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
