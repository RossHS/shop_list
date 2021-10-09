import 'package:flutter/material.dart';
import 'package:shop_list/controllers/authentication_controller.dart';
import 'package:shop_list/custom_icons.dart';
import 'package:shop_list/widgets/animated90s/animated_90s_icon.dart';
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
          child: _CustomForm(),
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
        child: Center(
          child: AnimatedPainterSquare90s(
            child: SizedBox(
              width: 400,
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      CustomTextField(
                        controller: _authController.emailController,
                        hint: 'email',
                        prefixIcon: const AnimatedIcon90s(iconsList: CustomIcons.user),
                      ),
                      CustomTextField(
                        controller: _authController.passwordController,
                        hint: 'password',
                        prefixIcon: const AnimatedIcon90s(iconsList: CustomIcons.lock),
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
        ),
      ),
    );
  }
}
