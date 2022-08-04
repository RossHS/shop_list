import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_list/controllers/controllers.dart';
import 'package:shop_list/utils/text_validators.dart' as validators;
import 'package:shop_list/widgets/themes_widgets/theme_dep.dart';

/// Экран с формой логина в аккаунт
class SignIn extends StatelessWidget {
  const SignIn({super.key});

  @override
  Widget build(BuildContext context) {
    return const ThemeDepScaffold(
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
  const _CustomForm();

  @override
  State<_CustomForm> createState() => _CustomFormState();
}

class _CustomFormState extends State<_CustomForm> {
  final _formStateKey = GlobalKey<FormState>();
  final _authController = AuthenticationController.instance;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Form(
        key: _formStateKey,
        child: Center(
          child: ThemeDepCommonItemBox(
            child: SizedBox(
              width: 400,
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      ThemeDepTextField(
                        controller: _authController.emailController,
                        hint: 'email',
                        inputValidator: validators.email,
                        maxLines: 1,
                        prefixIcon: ThemeDepIcon.user,
                      ),
                      ThemeDepTextField(
                        controller: _authController.passwordController,
                        hint: 'password',
                        inputValidator: validators.password,
                        maxLines: 1,
                        prefixIcon: ThemeDepIcon.lock,
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
