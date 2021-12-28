import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_list/controllers/controllers.dart';
import 'package:shop_list/custom_libs/advanced_drawer/flutter_advanced_drawer.dart';
import 'package:shop_list/models/theme_model.dart';
import 'package:shop_list/routes/routing_for_test.dart';
import 'package:shop_list/utils/routes_transition.dart';
import 'package:shop_list/widgets/animated90s/animated_90s_painter_circle.dart';
import 'package:shop_list/widgets/avatar.dart';
import 'package:shop_list/widgets/themes_widgets/theme_dep.dart';

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
    final onBackgroundColor = backgroundColor.calcTextColor;
    // Стиль отображения имени пользователя
    final titleTextStyle = theme.textTheme.headline6?.copyWith(color: onBackgroundColor);

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
          textColor: onBackgroundColor,
          iconColor: onBackgroundColor,
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
                          // Аватар
                          () => authController.firestoreUser.value != null
                              ? ThemeDepBuilder(
                                  animated90s: (_, themeWrapper, child) => AnimatedPainterCircleWithBorder90s(
                                    duration: themeWrapper.animationDuration,
                                    config: themeWrapper.paint90sConfig,
                                    boxColor: backgroundColor,
                                    child: child!,
                                  ),
                                  material: (_, __, child) => Hero(
                                    tag: 'avatar',
                                    child: Material(
                                      elevation: 20,
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(300),
                                      child: ClipOval(
                                        child: Container(child: child),
                                      ),
                                    ),
                                  ),
                                  modern: (_, __, child) => Material(
                                    elevation: 20,
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(300),
                                    child: ClipOval(
                                      child: Container(child: child),
                                    ),
                                  ),
                                  child: TouchGetterProvider(
                                    child: GestureDetector(
                                      onTap: () => Get.toNamed('/account'),
                                      child: Avatar(user: authController.firestoreUser.value!),
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                        ),
                      ),
                      Obx(() => Text(
                            '${authController.firestoreUser.value?.name}',
                            style: titleTextStyle,
                          )),
                      const SizedBox(height: 50),
                      TouchGetterProvider(
                        child: ListTile(
                          onTap: () => Get.toNamed('/account'),
                          leading: ThemeDepIcon.user,
                          title: const Text('Account'),
                        ),
                      ),
                      TouchGetterProvider(
                        child: ListTile(
                          onTap: () => Get.toNamed('/settings'),
                          leading: ThemeDepIcon.settings,
                          title: const Text('Settings'),
                        ),
                      ),
                      TouchGetterProvider(
                        child: ListTile(
                          onTap: () => Get.to(const RoutingForTest()),
                          leading: const Icon(Icons.warning_amber_rounded),
                          title: const Text('TEST'),
                        ),
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
