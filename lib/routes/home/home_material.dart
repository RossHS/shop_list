import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shop_list/controllers/controllers.dart';
import 'package:shop_list/custom_libs/advanced_drawer/flutter_advanced_drawer.dart';
import 'package:shop_list/models/models.dart';
import 'package:shop_list/utils/routes_transition.dart';
import 'package:shop_list/widgets/drawer.dart';
import 'package:shop_list/widgets/themes_widgets/theme_dep.dart';

/// Главный экран пользователя, где отображаются все актуальные списки покупок
class HomeMaterial extends StatefulWidget {
  const HomeMaterial({super.key});

  @override
  State<HomeMaterial> createState() => _HomeMaterialState();
}

class _HomeMaterialState extends State<HomeMaterial> {
  final _advancedDrawerController = AdvancedDrawerController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppDrawer(
      advancedDrawerController: _advancedDrawerController,
      backgroundColor: theme.canvasColor,
      child: Scaffold(
        appBar: ThemeDepAppBar(
          title: const Text('Список дел'),
          leading: IconButton(
            onPressed: _advancedDrawerController.showDrawer,
            icon: ValueListenableBuilder<AdvancedDrawerValue>(
              valueListenable: _advancedDrawerController,
              builder: (_, value, __) {
                return value.visible ? ThemeDepIcon.close : ThemeDepIcon.dehaze;
              },
            ),
          ),
          actions: <Widget>[
            TouchGetterProvider(
              child: Tooltip(
                message: 'Отображение списков',
                child: IconButton(
                  onPressed: () => Get.toNamed('/todosOrder'),
                  icon: ThemeDepIcon.sort,
                ),
              ),
            ),
          ],
        ),
        // Проверка, что основное тело маршрута будет работать при наличии авторизированного пользователя
        body: Obx(() {
          final auth = Get.find<AuthenticationController>();
          return auth.firestoreUser.value == null ? const CircularProgressIndicator() : const _Body();
        }),
        floatingActionButton: TouchGetterProvider(
          child: ThemeDepFloatingActionButton(
            onPressed: _openCreateTodo,
            child: ThemeDepIcon.create,
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
  const _Body();

  @override
  Widget build(BuildContext context) {
    final todosController = Get.find<TodosController>();
    return Obx(() {
      if (!todosController.isTodoStreamSubscribedNonNull) return const Center(child: CircularProgressIndicator());
      if (todosController.filteredTodoList.isEmpty) {
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
    });
  }
}

class _ItemGrid extends StatelessWidget {
  const _ItemGrid({
    required this.rowCount,
    super.key,
  });

  final int rowCount;

  @override
  Widget build(BuildContext context) {
    final todosController = Get.find<TodosController>();
    return MasonryGridView.count(
      crossAxisCount: rowCount,
      itemCount: todosController.filteredTodoList.length,
      itemBuilder: (context, index) {
        final todo = todosController.filteredTodoList[index];
        return _TodoItem(
          key: ObjectKey(todo),
          refModel: todo,
        );
      },
      mainAxisSpacing: 25.0,
      crossAxisSpacing: 25.0,
      padding: const EdgeInsets.all(25.0),
    );
  }
}

/// Виджет элемента записи списка дел
class _TodoItem extends StatefulWidget {
  const _TodoItem({
    super.key,
    required this.refModel,
  });

  final FirestoreRefTodoModel refModel;

  @override
  State<_TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends State<_TodoItem> with TickerProviderStateMixin {
  /// Укороченная ссылка на элемент списка дел, чьи данные здесь и визуализированы
  late final TodoModel _todoModel;

  /// Есть ли на экране панель управления списком дел с командами - удаление, изменение, закрытие
  var _isControlPanelInserted = false;

  /// Контроллер анимации прозрачности панели управления списком дел
  late final AnimationController _opacityController;

  /// Контроллер Bouncing эффекта при нажатии виджет
  late final AnimationController _bouncingEffectController;
  late final Animation<double> _animation;

  final formatter = DateFormat('dd MM yyyy');

  @override
  void initState() {
    super.initState();
    _todoModel = widget.refModel.todoModel;
    _opacityController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _bouncingEffectController = AnimationController(
      duration: const Duration(milliseconds: 50),
      vsync: this,
    );

    _animation = Tween<double>(begin: 1, end: 0.9).animate(
      CurvedAnimation(
        parent: _bouncingEffectController,
        curve: Curves.ease,
      ),
    );
  }

  @override
  void dispose() {
    _opacityController.dispose();
    _bouncingEffectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = ScaleTransition(
      scale: _animation,
      child: ThemeDepCommonItemBox(
        // Так как в фабрике commonItemBox определяется своя Theme, то для получения
        // ссылки на нее использую виджет Builder, который может вернуть ближайший context
        child: Builder(
          builder: (context) {
            final theme = Theme.of(context);
            final textTheme = theme.textTheme;
            // Стиль для дополнительной информации
            final textStyleAdditionsInfo = TextStyle(
              fontSize: 15,
              color: textTheme.bodyText2?.color?.withOpacity(0.3),
            );
            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          _todoModel.title,
                          style: textTheme.bodyText1,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (var element in _todoModel.elements.take(5))
                        Text(
                          ' ${element.name}',
                          style: textTheme.bodyText2?.copyWith(
                            fontSize: 18,
                            decoration: element.completed ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      if (_todoModel.elements.length > 5) const Center(child: Text('...')),
                      const SizedBox(height: 15),
                      Text(
                        formatter.format(DateTime.fromMillisecondsSinceEpoch(_todoModel.createdTimestamp)),
                        style: textStyleAdditionsInfo,
                      ),
                      Obx(() => Text(
                            '${Get.find<UsersMapController>().getUserModel(_todoModel.authorId)?.name}',
                            style: textStyleAdditionsInfo,
                          )),
                      if (!_todoModel.isPublic)
                        Text(
                          'Приватный',
                          style: textStyleAdditionsInfo,
                        ),
                    ],
                  ),
                ),

                // Вынес "наверх" виджет обработки нажатий, чтобы виджет
                // индикации завершенности работы не загораживал нажатия
                Positioned.fill(
                  child: Builder(builder: (context) {
                    // Костыльное задание формы Ink эффекта
                    final themeWrapper = ThemeController.to.appTheme.value;
                    ShapeBorder shape = themeWrapper is MaterialThemeDataWrapper
                        ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(themeWrapper.rounded))
                        : const RoundedRectangleBorder();
                    return TouchGetterProvider(
                      child: RawMaterialButton(
                        shape: shape,
                        onLongPress: _longPressed,
                        onPressed: _onPressed,
                      ),
                    );
                  }),
                ),

                // Панель управления с командами (закрыть/Удалить/Редактировать список дел)
                if (_isControlPanelInserted)
                  _ItemControlPanel(
                    refModel: widget.refModel,
                    opacityController: _opacityController,
                    todoModel: _todoModel,
                  ),
              ],
            );
          },
        ),
      ),
    );

    // Если задание завершено, то поверх будет отображаться индикация закрытия задачи
    if (_todoModel.completed) {
      child = RepaintBoundary(
        child: CustomPaint(
          foregroundPainter: _CrossLinePainter(),
          child: child,
        ),
      );
    }

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      child: child,
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
    } else {
      Get.toNamed('/todo/${widget.refModel.idRef}/view');
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

  /// Перехватчик нажатия на виджет, который запускает анимацию "уменьшения" виджета при нажатии
  void _onPointerDown(PointerDownEvent event) {
    _bouncingEffectController.forward();
  }

  /// При отпускании кнопки на экране запускает в обратную сторону анимацию нажатия
  void _onPointerUp(PointerUpEvent event) {
    _bouncingEffectController.reverse();
  }
}

/// Панель управления списком дел. Где пользователь может быстро удалить/изменить/закрыть задачу.
/// Панель вызывается по длинному нажатию на предмете
class _ItemControlPanel extends StatelessWidget {
  const _ItemControlPanel({
    required FirestoreRefTodoModel refModel,
    required AnimationController opacityController,
    required TodoModel todoModel,
  })  : _refModel = refModel,
        _opacityController = opacityController,
        _todoModel = todoModel;

  final FirestoreRefTodoModel _refModel;
  final AnimationController _opacityController;
  final TodoModel _todoModel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foregroundColor = theme.floatingActionButtonTheme.foregroundColor ?? theme.colorScheme.onSecondary;
    final todosController = Get.find<TodosController>();
    final authController = Get.find<AuthenticationController>();
    return Positioned.fill(
      key: ValueKey(_refModel),
      child: FadeTransition(
        opacity: _opacityController,
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconTheme.merge(
              data: IconThemeData(color: foregroundColor),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Если список дел не закрыт, то у пользователя есть
                  // возможность его быстро закрыть по шорт-кату
                  if (!_todoModel.completed)
                    Expanded(
                      child: RawMaterialButton(
                        onPressed: () => ThemeDepDialog(
                          text: 'Завершить задачу?',
                          actions: [
                            TextButton(
                                onPressed: () {
                                  todosController.completeTodo(
                                    docId: _refModel.idRef,
                                    completedAuthorUid: authController.firestoreUser.value!.uid,
                                  );
                                  Get.back();
                                },
                                child: const Text('ОК')),
                            TextButton(
                              onPressed: Get.back,
                              child: const Text('Отмена'),
                            )
                          ],
                        ),
                        child: const Icon(Icons.check),
                      ),
                    ),
                  // Только автор списка может его менять или удалять
                  if (authController.firestoreUser.value?.uid == _todoModel.authorId && !_todoModel.completed)
                    Expanded(
                      child: TouchGetterProvider(
                        child: RawMaterialButton(
                          onPressed: () => Get.toNamed('/todo/${_refModel.idRef}/edit'),
                          child: const Icon(Icons.edit),
                        ),
                      ),
                    ),
                  if (authController.firestoreUser.value?.uid == _todoModel.authorId)
                    Expanded(
                      child: RawMaterialButton(
                        onPressed: () => ThemeDepDialog(
                          text: 'Удалить задачу?',
                          actions: [
                            TextButton(
                                onPressed: () {
                                  todosController.deleteTodo(_refModel.idRef);
                                  Get.back();
                                },
                                child: const Text('ОК')),
                            TextButton(
                              onPressed: Get.back,
                              child: const Text('Отмена'),
                            )
                          ],
                        ),
                        child: const Icon(Icons.delete),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CrossLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 3
      ..color = Colors.black
      ..style = PaintingStyle.stroke;
    const offsetConst = 10.0;
    canvas.drawLine(
      const Offset(-offsetConst, -offsetConst),
      Offset(size.width + offsetConst, size.height + offsetConst),
      paint,
    );

    canvas.drawLine(
      Offset(size.width + offsetConst, -offsetConst),
      Offset(-offsetConst, size.height + offsetConst),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
