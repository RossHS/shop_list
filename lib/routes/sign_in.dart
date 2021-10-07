import 'package:flutter/material.dart';
import 'package:shop_list/controllers/authentication_controller.dart';
import 'package:shop_list/utils/text_validators.dart' as validator;
import 'package:shop_list/widgets/animated90s/animated_90s_painter_square.dart';

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
              height: 250,
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
    return RepaintBoundary(
      child: Form(
        key: _formStateKey,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _authController.emailController,
                    validator: validator.email,
                  ),
                  TextFormField(
                    controller: _authController.passwordController,
                    validator: validator.password,
                    obscureText: true,
                  ),
                  const SizedBox(height: 50),
                  TextButton(
                    onPressed: () {
                      if (_formStateKey.currentState!.validate()) {
                        _authController.signInWithEmail(context);
                      }
                    },
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
