import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shop_list/controllers/authentication_controller.dart';
import 'package:shop_list/custom_icons.dart';
import 'package:shop_list/custom_libs/advanced_drawer/flutter_advanced_drawer.dart';
import 'package:shop_list/widgets/animated90s/animated_90s_app_bar.dart';
import 'package:shop_list/widgets/animated90s/animated_90s_icon.dart';
import 'package:shop_list/widgets/animated90s/animated_90s_painter_circle.dart';
import 'package:shop_list/widgets/animated90s/animated_90s_painter_square.dart';

/// Главный экран пользователя, где отображаются все актуальные списки покупок
class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _authController = AuthenticationController.instance;

  @override
  Widget build(BuildContext context) {
    final _advancedDrawerController = AdvancedDrawerController();
    return AdvancedDrawer(
        backdropColor: Colors.blueGrey,
        controller: _advancedDrawerController,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        animateChildDecoration: true,
        rtlOpening: false,
        disabledGestures: false,
        childDecoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: Scaffold(
          appBar: AnimatedAppBar90s(
            actions: [
              IconButton(
                onPressed: _authController.signOut,
                icon: const Icon(Icons.remove_circle),
              )
            ],
            title: const Text('Список дел'),
          ),
          body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              var rowCount = 2;
              for (var width = 500; width < 3000; rowCount++, width += 400) {
                if (constraints.maxWidth < width) {
                  return Stagged(key: ValueKey<int>(rowCount), rowCount: rowCount);
                }
              }
              return Stagged(key: ValueKey<int>(rowCount), rowCount: rowCount);
            },
          ),
          floatingActionButton: AnimatedCircleButton90s(
            onPressed: () {},
            child: const AnimatedIcon90s(
              color: Colors.white,
              iconsList: CustomIcons.create,
            ),
          ),
        ),
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
                  const Padding(
                    padding: EdgeInsets.only(top: 34, bottom: 54),
                    child: AnimatedPainterCircleWithBorder90s(
                      boxColor: Colors.blueGrey,
                      child: SizedBox(
                        width: 128.0,
                        height: 128.0,
                        child: FlutterLogo(),
                      ),
                    ),
                  ),
                  ListTile(
                    onTap: () {},
                    leading: const AnimatedIcon90s(iconsList: CustomIcons.user),
                    title: const Text('Account'),
                  ),
                  ListTile(
                    onTap: () {},
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings'),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _authController.signOut,
                    child: const Text('Sign out'),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

const nums = [10, 2, 3, 4, 5, 6, 7, 9, 2, 19, 10, 11, 12, 13, 15, 16, 17];

class Stagged extends StatelessWidget {
  const Stagged({required this.rowCount, Key? key}) : super(key: key);
  final int rowCount;

  @override
  Widget build(BuildContext context) {
    return StaggeredGridView.countBuilder(
      crossAxisCount: rowCount,
      itemCount: nums.length,
      itemBuilder: (context, index) => AnimatedPainterSquare90s(
        child: SizedBox(
          height: nums[index] * 20,
          width: nums[index] * 10,
          child: Center(
            child: Text('$index ПЕПЕ МОЛОКО ХЫХЫХЫ БУЛДЫГА'),
          ),
        ),
      ),
      staggeredTileBuilder: (int index) => const StaggeredTile.fit(1),
      mainAxisSpacing: 25.0,
      crossAxisSpacing: 25.0,
      padding: const EdgeInsets.all(25.0),
    );
  }
}
