import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_list/controllers/authentication_controller.dart';
import 'package:shop_list/custom_icons.dart';
import 'package:shop_list/custom_libs/advanced_drawer/flutter_advanced_drawer.dart';
import 'package:shop_list/widgets/animated90s/animated_90s_icon.dart';
import 'package:shop_list/widgets/animated90s/animated_90s_painter_circle.dart';
import 'package:shop_list/widgets/avatar.dart';

/// Drawer в отдельном файле для лучшей читаемости и гибкости кода
class AppDrawer extends StatelessWidget {
  AppDrawer({
    required this.advancedDrawerController,
    required this.child,
    this.backgroundColor = Colors.blueGrey,
    Key? key,
  }) : super(key: key);

  /// Контроллер состояния Drawer, открыт он или закрыт
  final AdvancedDrawerController advancedDrawerController;

  final Color backgroundColor;

  final Widget child;

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final Color foregroundColor =
        colorScheme.brightness == Brightness.dark ? colorScheme.onSurface : colorScheme.onPrimary;
    // Стиль отображения имени пользователя
    final titleTextStyle = theme.textTheme.headline6?.copyWith(color: foregroundColor);

    final authController = AuthenticationController.instance;
    return AdvancedDrawer(
      backdropColor: backgroundColor,
      controller: advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      rtlOpening: false,
      disabledGestures: false,
      childDecoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(32)),
      ),
      child: child,
      drawer: SafeArea(
        child: ListTileTheme(
          textColor: Colors.white,
          iconColor: Colors.white,
          // Для обеспечения корректной работы Flex/Spacer элемента использовал пример из документации
          // https://api.flutter.dev/flutter/widgets/SingleChildScrollView-class.html
          // где задается ограничение по высоте из аргумента LayoutBuilder [constrains.maxHeight]
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              controller: _scrollController,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 200,
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 34, bottom: 20),
                        child: Obx(
                          () => authController.firestoreUser.value != null
                              ? AnimatedPainterCircleWithBorder90s(
                                  boxColor: backgroundColor,
                                  child: Avatar(user: authController.firestoreUser.value!),
                                )
                              : const SizedBox(),
                        ),
                      ),
                      Obx(() => Text(
                            '${authController.firestoreUser.value?.name}',
                            style: titleTextStyle,
                          )),
                      const SizedBox(height: 50),
                      ListTile(
                        onTap: () {
                          Get.toNamed('/account');
                        },
                        leading: const AnimatedIcon90s(iconsList: CustomIcons.user),
                        title: const Text('Account'),
                      ),
                      ListTile(
                        onTap: () {},
                        leading: const AnimatedIcon90s(iconsList: CustomIcons.user),
                        title: const Text('Settings'),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: authController.signOut,
                        child: const Text('Sign out'),
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
