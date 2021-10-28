import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:shop_list/custom_icons.dart';
import 'package:shop_list/custom_libs/advanced_drawer/flutter_advanced_drawer.dart';
import 'package:shop_list/widgets/animated90s/animated_90s_app_bar.dart';
import 'package:shop_list/widgets/animated90s/animated_90s_icon.dart';
import 'package:shop_list/widgets/animated90s/animated_90s_painter_circle.dart';
import 'package:shop_list/widgets/animated90s/animated_90s_painter_square.dart';
import 'package:shop_list/widgets/drawer.dart';

/// Главный экран пользователя, где отображаются все актуальные списки покупок
class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _advancedDrawerController = AdvancedDrawerController();

  @override
  Widget build(BuildContext context) {
    return AppDrawer(
      advancedDrawerController: _advancedDrawerController,
      child: Scaffold(
        appBar: AnimatedAppBar90s(
          title: const Text('Список дел'),
          leading: IconButton(
            onPressed: _advancedDrawerController.showDrawer,
            icon: ValueListenableBuilder<AdvancedDrawerValue>(
              valueListenable: _advancedDrawerController,
              builder: (_, value, __) {
                return AnimatedIcon90s(
                  iconsList: value.visible ? CustomIcons.create : CustomIcons.arrow,
                  key: ValueKey<bool>(value.visible),
                );
              },
            ),
          ),
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
          onPressed: _openCreateTodo,
          child: const AnimatedIcon90s(
            iconsList: CustomIcons.create,
          ),
        ),
      ),
    );
  }

  void _openCreateTodo() {
    Get.toNamed('/createTodo');
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
