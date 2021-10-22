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
  const AppDrawer({
    required this.advancedDrawerController,
    required this.child,
    this.backgroundColor = Colors.blueGrey,
    Key? key,
  }) : super(key: key);

  /// Контроллер состояния Drawer, открыт он или закрыт
  final AdvancedDrawerController advancedDrawerController;

  final Color backgroundColor;

  final Widget child;

  @override
  Widget build(BuildContext context) {
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
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: child,
      drawer: SafeArea(
        child: ListTileTheme(
          textColor: Colors.white,
          iconColor: Colors.white,
          child: ConstrainedBox(
            constraints: const BoxConstraints.tightFor(
              width: 200,
              height: double.infinity,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 34, bottom: 54),
                  child: AnimatedPainterCircleWithBorder90s(
                    boxColor: backgroundColor,
                    child: Obx(() => authController.firestoreUser.value != null
                        ? Avatar(user: authController.firestoreUser.value!)
                        : const SizedBox()),
                  ),
                ),
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
    );
  }
}
