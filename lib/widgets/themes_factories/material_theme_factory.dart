import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_list/widgets/themes_factories/abstract_theme_factory.dart';

/// Фабрика классической темы дизайна Material
class MaterialThemeFactory extends ThemeFactory {
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
  Widget todoItemBox({Key? key, required Widget child}) {
    return Container(
      key: key,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(0.0, 1.0), //(x,y)
            blurRadius: 6.0,
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget infoOverlay({String? title, required String msg, Widget? child}) {
    final theme = Get.theme;
    final textTheme = theme.textTheme;
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
                  style: textTheme.headline5,
                ),
              Text(msg, style: textTheme.bodyText1),
              if (child != null) child
            ],
          ),
        ),
      ),
    );
  }
}

class Material90IconsFactory extends IconsFactory {
  const Material90IconsFactory();

  @override
  Widget get create => const Icon(Icons.create);

  @override
  Widget get user => const Icon(Icons.account_circle);
}
