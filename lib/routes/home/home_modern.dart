import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shop_list/controllers/controllers.dart';
import 'package:shop_list/models/models.dart';
import 'package:shop_list/utils/routes_transition.dart';
import 'package:shop_list/widgets/avatar.dart';
import 'package:shop_list/widgets/carousel.dart';
import 'package:shop_list/widgets/modern/modern.dart';
import 'package:shop_list/widgets/themes_widgets/theme_dep.dart';

final _formatterDate = DateFormat('dd MM yyyy');
final _formatterTime = DateFormat('HH:mm:ss');

/// Основное рабочее окно в теме [ModernThemeDataWrapper]
class HomeModern extends StatelessWidget {
  const HomeModern({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ThemeDepScaffold(
      body: const _Body(),
      // Т.к. данный маршрут уникальный для темы Modern, то и буду стараться использовать ее виджеты,
      // а не универсальные, ради повышения производительности
      floatingActionButton: TouchGetterProvider(
        child: ModernFloatingActionButton(
          onPressed: _openCreateTodo,
          child: const ModernIcon(Icons.create),
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
    return SafeArea(
      child: Stack(
        children: [
          const Positioned(
            left: 20,
            top: 20,
            child: RepaintBoundary(
              child: _ControlPanel(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              top: 160,
              bottom: 100,
            ),
            child: Center(
              child: GetX<TodosController>(builder: (todosController) {
                // Здесь GetX вываливает ошибку, для закрытия ошибки использую в
                // условном операторе дополнительную RX переменную todosController.filteredTodoList
                if (!todosController.isTodoStreamSubscribedNonNull && todosController.filteredTodoList.isEmpty) {
                  return const CircularProgressIndicator();
                }
                if (todosController.filteredTodoList.isEmpty) {
                  return const Text('Нет данных');
                } else {
                  return _CarouselWithIndicator(todoList: todosController.filteredTodoList);
                }
              }),
            ),
          ),
        ],
      ),
    );
  }
}

/// Панель с шорт-катами к маршрутам (Пользователя/Настройки/Сортировка)
class _ControlPanel extends StatelessWidget {
  const _ControlPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = AuthenticationController.instance;

    return TouchGetterProvider(
      child: ThemeDepCommonItemBox(
        child: Material(
          type: MaterialType.transparency,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Obx(() => authController.firestoreUser.value != null
                    ? GestureDetector(
                        onTap: () => Get.toNamed('/account'),
                        child: ClipOval(
                          child: Avatar(
                            diameter: 40,
                            user: authController.firestoreUser.value!,
                          ),
                        ),
                      )
                    : const SizedBox()),
              ),
              IconButton(
                onPressed: () => Get.toNamed('/settings'),
                icon: ThemeDepIcon.settings,
              ),
              IconButton(
                onPressed: () => Get.toNamed('/todosOrder'),
                icon: ThemeDepIcon.sort,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Главное окно с каруселью списков задач и индикацией текущего/показываемого списка в виде точек точек
class _CarouselWithIndicator extends StatefulWidget {
  const _CarouselWithIndicator({
    Key? key,
    required this.todoList,
  }) : super(key: key);
  final List<FirestoreRefTodoModel> todoList;

  @override
  State<_CarouselWithIndicator> createState() => _CarouselWithIndicatorState();
}

class _CarouselWithIndicatorState extends State<_CarouselWithIndicator> {
  late final ValueNotifier<int> _currentPage;
  final _controller = CarouselController();

  @override
  void initState() {
    super.initState();
    _currentPage = ValueNotifier(_controller.initialPage);
  }

  @override
  void didUpdateWidget(_CarouselWithIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.todoList != widget.todoList) {
      _currentPage.value = _controller.calcPageIndex(widget.todoList.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Expanded(
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
              },
            ),
            child: Carousel(
              controller: _controller,
              items: widget.todoList
                  .map((todo) => _TodoItem(
                        key: ObjectKey(todo),
                        refModel: todo,
                      ))
                  .toList(),
              onPageChanged: (page) {
                _currentPage.value = page;
              },
            ),
          ),
        ),
        const SizedBox(height: 50),
        ValueListenableBuilder(
          valueListenable: _currentPage,
          // TODO 30.12.2021 ограничить макс кол-во элементов по ширине, установить предел отображаемых списков
          builder: (context, value, child) => RepaintBoundary(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 4,
              runSpacing: 4,
              children: [
                for (var i = 0; i < widget.todoList.length; i++)
                  AnimatedContainer(
                    key: ObjectKey(widget.todoList[i]),
                    height: 10,
                    width: i == value ? 30 : 10,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: colorScheme.primary,
                    ),
                    duration: const Duration(milliseconds: 200),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Виджет элемента записи списка дел
class _TodoItem extends StatelessWidget {
  const _TodoItem({
    Key? key,
    required this.refModel,
  }) : super(key: key);

  final FirestoreRefTodoModel refModel;

  @override
  Widget build(BuildContext context) {
    final todoModel = refModel.todoModel;
    final textTheme = Theme.of(context).textTheme;
    return RepaintBoundary(
      child: TouchGetterProvider(
        child: ThemeDepCommonItemBox(
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: () => Get.toNamed('/todo/${refModel.idRef}/view'),
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Первая строчка с информацией о создателе списка
                      _TodoItemHeader(refModel.todoModel),
                      // Заголовок списка дел
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            todoModel.title,
                            style: textTheme.headline5,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Expanded(
                        child: _TodoItemBody(refModel),
                      ),
                      // Нижняя срока шорткатов управления
                      _TodoItemFooter(refModel),
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

/// Основное тело списка задач.
/// Список - если задача открыта
/// Таблица с информацией о закрытии, если задача закрыта
class _TodoItemBody extends StatelessWidget {
  const _TodoItemBody(
    this.refModel, {
    Key? key,
  }) : super(key: key);
  final FirestoreRefTodoModel refModel;

  @override
  Widget build(BuildContext context) {
    final todoModel = refModel.todoModel;
    final textTheme = Theme.of(context).textTheme;
    // Отображение не завершенных задач
    if (!todoModel.completed) {
      // TODO Низкая производительность на слабых телефонах при наличии emoji
      return ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: todoModel.elements.length,
        itemBuilder: (context, index) {
          final element = todoModel.elements[index];
          return Text(
            element.name,
            style: textTheme.bodyText2?.copyWith(
              decoration: element.completed ? TextDecoration.lineThrough : null,
            ),
          );
        },
      );
    } else {
      // Отображение завершенных задач
      return Center(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              width: 1.5,
              color: Colors.white,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Закрыто!',
                style: textTheme.headline5,
              ),
              const SizedBox(height: 10),
              GetX<UsersMapController>(
                builder: (userMapController) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipOval(
                      child: Avatar(
                        user: userMapController.getUserModel(todoModel.completedAuthorId),
                        diameter: 40,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${userMapController.getUserModel(todoModel.completedAuthorId)?.name}'),
                        Text(_formatterDate.format(DateTime.fromMillisecondsSinceEpoch(todoModel.completedTimestamp))),
                        Text(_formatterTime.format(DateTime.fromMillisecondsSinceEpoch(todoModel.completedTimestamp))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}

/// Панель-заголовок, в которой отображается информация о создателе списка/времени создания
class _TodoItemHeader extends StatelessWidget {
  const _TodoItemHeader(
    this.todoModel, {
    Key? key,
  }) : super(key: key);
  final TodoModel todoModel;

  @override
  Widget build(BuildContext context) {
    final userMapController = Get.find<UsersMapController>();
    return Obx(
      () => Row(
        children: [
          ClipOval(
            child: Avatar(
              diameter: 40,
              user: userMapController.getUserModel(todoModel.authorId),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${userMapController.getUserModel(todoModel.authorId)?.name}'),
              Text(_formatterDate.format(DateTime.fromMillisecondsSinceEpoch(todoModel.createdTimestamp))),
            ],
          ),
          const Spacer(),
          if (!todoModel.isPublic) const Icon(Icons.lock),
        ],
      ),
    );
  }
}

/// Самая нижняя панель списка дел с кнопками шорткатами (закрытия задачи, ее изменения и удаления)
class _TodoItemFooter extends StatelessWidget {
  const _TodoItemFooter(this.refModel, {Key? key}) : super(key: key);
  final FirestoreRefTodoModel refModel;

  @override
  Widget build(BuildContext context) {
    final todoModel = refModel.todoModel;
    final todosController = Get.find<TodosController>();
    final authController = Get.find<AuthenticationController>();
    return Row(
      children: [
        if (!todoModel.completed)
          IconButton(
            onPressed: () => _dialog(
              title: 'Завершить задачу?',
              okCallback: () {
                todosController.completeTodo(
                  docId: refModel.idRef,
                  completedAuthorUid: authController.firestoreUser.value!.uid,
                );
                Get.back();
              },
            ),
            icon: const Icon(Icons.check),
          ),
        if (authController.firestoreUser.value?.uid == todoModel.authorId && !todoModel.completed)
          IconButton(
            onPressed: () => Get.toNamed('/todo/${refModel.idRef}/edit'),
            icon: const Icon(Icons.edit),
          ),
        if (authController.firestoreUser.value?.uid == todoModel.authorId)
          IconButton(
            onPressed: () => _dialog(
              title: 'Удалить задачу?',
              okCallback: () {
                todosController.deleteTodo(refModel.idRef);
                Get.back();
              },
            ),
            icon: const Icon(Icons.delete),
          )
      ],
    );
  }

  void _dialog({required String title, required void Function() okCallback}) {
    ThemeDepDialog(
      text: title,
      actions: [
        TextButton(
          onPressed: okCallback,
          child: const Text('ОК'),
        ),
        TextButton(
          onPressed: Get.back,
          child: const Text('Отмена'),
        )
      ],
    );
  }
}
