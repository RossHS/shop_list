import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:shop_list/controllers/controllers.dart';
import 'package:shop_list/controllers/todo/todo_service.dart';
import 'package:shop_list/custom_icons.dart';
import 'package:shop_list/custom_libs/advanced_drawer/flutter_advanced_drawer.dart';
import 'package:shop_list/models/models.dart';
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
        // Проверка, что основное тело маршрута будет работать при наличии авторизированного пользователя
        body: Obx(() {
          final auth = Get.find<AuthenticationController>();
          return auth.firestoreUser.value == null ? const CircularProgressIndicator() : const _Body();
        }),
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

class _Body extends StatefulWidget {
  const _Body({Key? key}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final AuthenticationController controller = AuthenticationController.instance;
  late final Stream<QuerySnapshot<Map<String, dynamic>>> stream;

  @override
  void initState() {
    super.initState();
    stream = TodoService().createStream(controller.firestoreUser.value!.uid);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('ERROR'));
          } else if (snapshot.hasData) {
            final data = snapshot.data;
            if (data != null) {
              return LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  var rowCount = 2;
                  for (var width = 500; width < 3000; rowCount++, width += 400) {
                    if (constraints.maxWidth < width) {
                      return _ItemGrid(
                        key: ValueKey<int>(rowCount),
                        rowCount: rowCount,
                        data: data,
                      );
                    }
                  }
                  return _ItemGrid(
                    key: ValueKey<int>(rowCount),
                    rowCount: rowCount,
                    data: data,
                  );
                },
              );
            } else {
              return const Center(child: Text('Non Data'));
            }
          }
          return const Center(child: CircularProgressIndicator());
        });
  }
}

class _ItemGrid extends StatelessWidget {
  const _ItemGrid({
    required this.rowCount,
    required this.data,
    Key? key,
  }) : super(key: key);
  final QuerySnapshot<Map<String, dynamic>> data;
  final int rowCount;

  @override
  Widget build(BuildContext context) {
    return StaggeredGridView.countBuilder(
      crossAxisCount: rowCount,
      itemCount: data.docs.length,
      itemBuilder: (context, index) {
        final todoModel = TodoModel.fromJson(data.docs[index].data());
        return _TodoItem(
          key: ObjectKey(todoModel),
          model: todoModel,
        );
      },
      staggeredTileBuilder: (int index) => const StaggeredTile.fit(1),
      mainAxisSpacing: 25.0,
      crossAxisSpacing: 25.0,
      padding: const EdgeInsets.all(25.0),
    );
  }
}

class _TodoItem extends StatelessWidget {
  const _TodoItem({
    required this.model,
    Key? key,
  }) : super(key: key);
  final TodoModel model;

  @override
  Widget build(BuildContext context) {
    return AnimatedPainterSquare90s(
      child: SizedBox(
        child: Center(
          child: Text('${model.title}'),
        ),
      ),
    );
  }
}
