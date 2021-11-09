import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shop_list/controllers/controllers.dart';
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

class _Body extends StatelessWidget {
  const _Body({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TodosController>(
      init: TodosController(),
      builder: (todosController) => Obx(() {
        if (!todosController.isTodoStreamSubscribedNonNull) return const Center(child: CircularProgressIndicator());
        if (todosController.allTodosList.isEmpty) {
          return const Center(child: Text('Нет данных'));
        } else {
          return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              var rowCount = 2;
              for (var width = 500; width < 3000; rowCount++, width += 400) {
                if (constraints.maxWidth < width) {
                  return _ItemGrid(
                    key: ValueKey<int>(rowCount),
                    rowCount: rowCount,
                  );
                }
              }
              return _ItemGrid(
                key: ValueKey<int>(rowCount),
                rowCount: rowCount,
              );
            },
          );
        }
      }),
    );
  }
}

class _ItemGrid extends StatelessWidget {
  const _ItemGrid({
    required this.rowCount,
    Key? key,
  }) : super(key: key);
  final int rowCount;

  @override
  Widget build(BuildContext context) {
    final todosController = Get.find<TodosController>();
    return StaggeredGridView.countBuilder(
      crossAxisCount: rowCount,
      itemCount: todosController.allTodosList.length,
      itemBuilder: (context, index) {
        return _TodoItem(
          key: ObjectKey(todosController.allTodosList[index]),
          refModel: todosController.allTodosList[index],
        );
      },
      staggeredTileBuilder: (int index) => const StaggeredTile.fit(1),
      mainAxisSpacing: 25.0,
      crossAxisSpacing: 25.0,
      padding: const EdgeInsets.all(25.0),
    );
  }
}

/// Виджет элемента записи списка дел
class _TodoItem extends StatefulWidget {
  const _TodoItem({
    required this.refModel,
    Key? key,
  }) : super(key: key);
  final FirestoreRefTodoModel refModel;

  @override
  State<_TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends State<_TodoItem> with SingleTickerProviderStateMixin {
  /// Укороченная ссылка на элемент списка дел, чьи данные здесь и визуализированы
  late final TodoModel _todoModel;

  /// Контроллер управлением списка дел
  late final TodosController _todosController;

  /// Есть ли на экране панель управления списком дел с командами - удаление, изменение, закрытие
  var _isControlPanelInserted = false;

  /// Контроллер анимации прозрачности панели управления списком дел
  late final AnimationController _opacityController;

  final formatter = DateFormat('dd MM yyyy');

  @override
  void initState() {
    super.initState();
    _todoModel = widget.refModel.todoModel;
    _todosController = Get.find<TodosController>();
    _opacityController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _opacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedPainterSquare90s(
      child: Stack(
        children: [
          RawMaterialButton(
            onLongPress: _longPressed,
            onPressed: _onPressed,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Text(_todoModel.title)),
                  for (var element in _todoModel.elements.take(5)) Text('• ${element.name}'),
                  const SizedBox(height: 15),
                  Text(
                    formatter.format(DateTime.fromMillisecondsSinceEpoch(_todoModel.createdTimestamp)),
                    style: TextStyle(fontSize: 15, color: Colors.black.withOpacity(0.3)),
                  ),
                  // TODO дописать функцию получения по ID пользователя в БД его имя. Скорее всего потребуется контроллер с прослушиванием коллекции пользователей
                  Text(
                    _todoModel.authorId,
                    style: TextStyle(fontSize: 15, color: Colors.black.withOpacity(0.3)),
                  )
                ],
              ),
            ),
          ),
          if (_isControlPanelInserted)
            Positioned.fill(
              key: ValueKey(widget.refModel),
              child: FadeTransition(
                opacity: _opacityController,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: RawMaterialButton(
                            onPressed: () {},
                            shape: const CircleBorder(),
                            child: const Icon(Icons.check),
                          ),
                        ),
                        Expanded(
                          child: RawMaterialButton(
                            onPressed: () {},
                            shape: const CircleBorder(),
                            child: const Icon(Icons.edit),
                          ),
                        ),
                        Expanded(
                          child: RawMaterialButton(
                            onPressed: () => _todosController.deleteTodo(widget.refModel.idRef),
                            shape: const CircleBorder(),
                            child: const Icon(Icons.remove),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Обработка долгого нажатия на списке дел.
  /// Открывает/закрывает опции управления списков (удалить/редактировать)
  void _longPressed() {
    _opacityController.stop();
    _animationControl(isForward: !_isControlPanelInserted);
  }

  /// Обычное нажатие. Если открыта панель редактирования списка, то закрывает ее
  void _onPressed() {
    if (_isControlPanelInserted) {
      _animationControl(isForward: false);
      return;
    }
  }

  /// Метод контроля анимации и состояния виджетов. Вынес код в отдельный метод, чтобы избежать
  /// дублирование кода в методах обработки нажатий на RawMaterialButton
  void _animationControl({required bool isForward}) {
    if (isForward) {
      setState(() {
        _isControlPanelInserted = true;
        _opacityController.forward();
      });
    } else {
      _opacityController.reverse().whenCompleteOrCancel(() {
        setState(() {
          _isControlPanelInserted = false;
        });
      });
    }
  }
}
