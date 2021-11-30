import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_list/controllers/controllers.dart';
import 'package:shop_list/utils/text_validators.dart' as validators;
import 'package:shop_list/widgets/themes_factories/abstract_theme_factory.dart';

/// Экран с формой логина в аккаунт
class SignIn extends StatelessWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(50.0),
          child: _CustomForm(),
        ),
      ),
    );
  }
}

class _CustomForm extends StatefulWidget {
  const _CustomForm({Key? key}) : super(key: key);

  @override
  State<_CustomForm> createState() => _CustomFormState();
}

class _CustomFormState extends State<_CustomForm> {
  final _formStateKey = GlobalKey<FormState>();
  final _authController = AuthenticationController.instance;

  @override
  Widget build(BuildContext context) {
    final themeFactory = ThemeFactory.instance(ThemeController.to.appTheme.value);
    return RepaintBoundary(
      child: Form(
        key: _formStateKey,
        child: Center(
          child: themeFactory.commonItemBox(
            child: SizedBox(
              width: 400,
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      themeFactory.textField(
                        controller: _authController.emailController,
                        hint: 'email',
                        inputValidator: validators.email,
                        maxLines: 1,
                        prefixIcon: themeFactory.icons.user,
                      ),
                      themeFactory.textField(
                        controller: _authController.passwordController,
                        hint: 'password',
                        inputValidator: validators.password,
                        maxLines: 1,
                        prefixIcon: themeFactory.icons.lock,
                        obscureText: true,
                      ),
                      const SizedBox(height: 15),
                      Obx(() => _authController.authErrorMessage.value != null
                          ? Text(_authController.authErrorMessage.value!)
                          : const SizedBox()),
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
