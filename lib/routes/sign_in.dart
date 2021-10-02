import 'package:flutter/material.dart';
import 'package:shop_list/controllers/authentication_controller.dart';
import 'package:shop_list/utils/text_validators.dart' as validator;

/// Экран с формой логина в аккаунт
class SignIn extends StatelessWidget {
  SignIn({Key? key}) : super(key: key);

  final _formStateKey = GlobalKey<FormState>();
  final _authController = AuthenticationController.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
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
