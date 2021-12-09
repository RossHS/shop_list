import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_list/models/theme_model.dart';
import 'package:shop_list/widgets/custom_text_field.dart';
import 'package:shop_list/widgets/themes_factories/abstract_theme_factory.dart';

/// Фабрика классической темы дизайна Material
class MaterialThemeFactory extends ThemeFactory {
  MaterialThemeFactory(this._materialThemeData) : super(_materialThemeData);
  final MaterialThemeDataWrapper _materialThemeData;

  @override
  MaterialThemeDataWrapper get themeWrapper => _materialThemeData;

  @override
  Material90IconsFactory get icons => const Material90IconsFactory();

  @override
  PreferredSizeWidget appBar({
    Key? key,
    Widget? leading,
    Widget? title,
    List<Widget>? actions,
    PreferredSizeWidget? bottom,
  }) {
    return AppBar(
      leading: leading,
      title: title,
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Widget floatingActionButton({
    Key? key,
    required void Function() onPressed,
    required Widget child,
  }) {
    return FloatingActionButton(
      key: key,
      onPressed: onPressed,
      child: child,
    );
  }

  @override
  Widget button({
    Key? key,
    required void Function() onPressed,
    required Widget child,
  }) {
    return ElevatedButton(
      key: key,
      onPressed: onPressed,
      child: child,
    );
  }

  @override
  Widget commonItemBox({Key? key, required Widget child}) {
    final theme = Get.theme;
    return Theme(
      data: theme.copyWith(
        textTheme: theme.textTheme.apply(bodyColor: theme.canvasColor.calcTextColor),
      ),
      child: Container(
        key: key,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color: theme.canvasColor,
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(0.0, 1.0), //(x,y)
              blurRadius: 6.0,
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  @override
  Widget todoElementMsgInputBox({Key? key, required Widget child}) {
    return Container(
      color: Get.theme.canvasColor,
      child: child,
    );
  }

  @override
  Widget infoOverlay({String? title, required String msg, Widget? child}) {
    final theme = Get.theme;
    // Адаптация цвета текста к фону
    final adaptedTextTheme = theme.textTheme.apply(bodyColor: theme.canvasColor.calcTextColor);
    return SafeArea(
      // Отступы, чтобы SnackBar не выходил за границы экрана из-за AnimatedPainterSquare
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: theme.canvasColor,
            boxShadow: [
              BoxShadow(
                color: theme.brightness == Brightness.light ? Colors.grey : Colors.black,
                offset: const Offset(0.0, 1.0), //(x,y)
                blurRadius: 6.0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (title != null)
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: adaptedTextTheme.headline5,
                ),
              Text(msg, style: adaptedTextTheme.bodyText1),
              if (child != null) child
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget textField({
    Key? key,
    required TextEditingController controller,
    bool Function(String p1)? inputValidator,
    String? hint,
    int? maxLines,
    int? minLines,
    Widget? prefixIcon,
    bool obscureText = false,
  }) {
    return MaterialCustomTextField(
      key: key,
      controller: controller,
      inputValidator: inputValidator,
      hint: hint,
      maxLines: maxLines,
      minLines: minLines,
      prefixIcon: prefixIcon,
      obscureText: obscureText,
    );
  }

  @override
  void showDialog({
    String? text,
    Widget? content,
    List<Widget>? actions,
  }) {
    // Продублировал код из Animated90sThemeFactory
    showGeneralDialog(
      context: Get.context!,
      pageBuilder: (context, animation, secondaryAnimation) {
        final theme = Get.theme;
        // Адаптация цвета текста к фону
        final adaptedTheme = theme.copyWith(
          textTheme: theme.textTheme.apply(bodyColor: theme.canvasColor.calcTextColor),
        );
        Widget? titleWidget;
        Widget? actionsWidget;

        if (text != null) {
          titleWidget = Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              text,
              style: adaptedTheme.textTheme.headline6,
            ),
          );
        }

        if (actions != null) {
          actionsWidget = Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: actions,
          );
        }

        return Theme(
          data: adaptedTheme,
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: theme.canvasColor,
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0, bottom: 8.0),
                child: IntrinsicWidth(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (titleWidget != null) titleWidget,
                      if (content != null) content,
                      if (actionsWidget != null) actionsWidget,
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 600),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return Transform.scale(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeInOutQuint).value,
          child: child,
        );
      },
      barrierDismissible: true,
      barrierLabel: '',
    );
  }
}

class Material90IconsFactory extends IconsFactory {
  const Material90IconsFactory();

  @override
  Widget get create => const Icon(Icons.create);

  @override
  Widget get user => const Icon(Icons.account_circle);

  @override
  Widget get lock => const Icon(Icons.lock);
}
