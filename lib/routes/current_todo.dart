import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shop_list/controllers/controllers.dart';
import 'package:shop_list/models/models.dart';
import 'package:shop_list/widgets/animated90s/animated_90s.dart';
import 'package:shop_list/widgets/avatar.dart';
import 'package:shop_list/widgets/themes_widgets/theme_dep.dart';

final dateTimeFormatter = DateFormat('dd MM yyyy HH:mm:ss');

/// Окно текущей задачи, которую выбрал пользователь
class CurrentTodo extends StatelessWidget {
  const CurrentTodo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appBarTheme = AppBarTheme.of(context);
    final colorScheme = theme.colorScheme;
    final additionInfoAppBarTextColor = appBarTheme.foregroundColor ??
        (colorScheme.brightness == Brightness.dark ? colorScheme.onSurface : colorScheme.onPrimary);

    final docId = Get.parameters['id'];
    final TodoViewController viewController = TodoViewController();
    final userMapController = Get.find<UsersMapController>();
    return GetBuilder<TodoViewController>(
        init: viewController,
        initState: (_) {
          viewController.loadTodoModel(docId!);
        },
        builder: (controller) => Obx(() {
              Widget? body;
              String appBarTitle = '';
              // В зависимости от текущего статуса загрузки списка дел строится подобающее дерево
              switch (controller.state) {
                case TodoViewCurrentState.unknown:
                  appBarTitle = 'Неизвестно';
                  body = const Center(
                    child: CircularProgressIndicator(),
                  );
                  break;
                case TodoViewCurrentState.loading:
                  appBarTitle = 'Загрузка';
                  body = const Center(
                    child: CircularProgressIndicator(),
                  );
                  break;
                case TodoViewCurrentState.error:
                  appBarTitle = 'Ошибка';
                  body = const Center(
                    child: Text('Ошибка загрузки'),
                  );
                  break;
                case TodoViewCurrentState.loaded:
                  appBarTitle = '${controller.todoModel?.title}';
                  body = const _LoadedWidget();
              }
              UserModel? authorModel;
              if (controller.todoModel != null) {
                authorModel = userMapController.getUserModel(controller.todoModel!.authorId);
              }
              return ThemeDepScaffold(
                appBar: ThemeDepAppBar(
                  title: Text(appBarTitle),
                  bottom: controller.todoModel != null && authorModel != null
                      ? PreferredSize(
                          preferredSize: const Size.fromHeight(75),
                          child: SizedBox(
                            height: 80,
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: ThemeDepBuilder(
                                    animated90s: (_, themeWrapper, child) => AnimatedPainterCircleWithBorder90s(
                                      duration: themeWrapper.animationDuration,
                                      config: themeWrapper.paint90sConfig,
                                      boxColor: appBarTheme.backgroundColor ?? theme.colorScheme.primary,
                                      child: child!,
                                    ),
                                    material: (_, __, child) => ConstrainedBox(
                                      constraints: const BoxConstraints.expand(height: 50, width: 50),
                                      child: ClipOval(
                                        child: child,
                                      ),
                                    ),
                                    glassmorphism: (_, __, child) => ConstrainedBox(
                                      constraints: const BoxConstraints.expand(height: 50, width: 50),
                                      child: ClipOval(
                                        child: child,
                                      ),
                                    ),
                                    child: Avatar(diameter: 70, user: authorModel),
                                  ),
                                ),
                                DefaultTextStyle(
                                  style: theme.textTheme.apply(bodyColor: additionInfoAppBarTextColor).bodyText1!,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(authorModel.name),
                                      Text(
                                        dateTimeFormatter.format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                            controller.todoModel!.createdTimestamp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : null,
                ),
                body: body,
              );
            }));
  }
}

/// Основное тело виджета при успешной загрузки модели списка дел
class _LoadedWidget extends StatefulWidget {
  const _LoadedWidget();

  @override
  State<_LoadedWidget> createState() => _LoadedWidgetState();
}

class _LoadedWidgetState extends State<_LoadedWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final CurvedAnimation _crossLineAnimation;
  late final CurvedAnimation _textInfoScaleAnimation;
  late final Animation<double> _textInfoRotateAnimation;

  /// Флаг для перезапуска анимации, т.е. если в другом месте изменили статус завершенности задачи, а мы поставим
  /// его вновь на завершенный, мы захотим увидеть анимацию с 0, вот для этого этот флаг и существует.
  /// Он следит за переключением статуса задачи
  bool _isFirstTodoCompletedStatus = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _crossLineAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.1, 0.6, curve: Curves.elasticOut),
    );
    _textInfoScaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.5, 1, curve: Curves.elasticOut),
    );
    _textInfoRotateAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi + math.pi / 6,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.5, 1, curve: Curves.elasticOut),
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return GetBuilder<TodoViewController>(
      builder: (controller) {
        if (!controller.isTodoCompleted) {
          _isFirstTodoCompletedStatus = true;
        }
        if (controller.isTodoCompleted && _isFirstTodoCompletedStatus) {
          _isFirstTodoCompletedStatus = false;
          _animationController.forward(from: 0);
        }
        return Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: controller.todoModel!.elements.length,
                    itemBuilder: (context, index) {
                      final element = controller.todoModel!.elements[index];
                      return ListTile(
                        // Используем uid в качестве ключа, а не сам элемент, так как при изменении
                        // элемента (к примеру, смена статуса на выполнено) => ключ тоже меняется
                        // и создается новый виджет.
                        key: ValueKey(element.uid),
                        onTap: () {
                          _changeTodoElementCompleteStatus(element);
                        },
                        leading: Checkbox(
                            value: element.completed,
                            onChanged: (_) {
                              _changeTodoElementCompleteStatus(element);
                            }),
                        title: Text(
                          element.name,
                          style: textTheme.bodyText2?.copyWith(
                            fontSize: 18,
                            decoration: element.completed ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: double.infinity),
                    child: ThemeDepButton(
                      onPressed: () => ThemeDepDialog(
                        text: 'Завершить задачу?',
                        actions: [
                          TextButton(
                            onPressed: () async {
                              await _completeTodo();
                              Get.back();
                            },
                            child: const Text('Ok'),
                          ),
                          TextButton(
                            onPressed: Get.back,
                            child: const Text('Отмена'),
                          ),
                        ],
                      ),
                      child: const Text('Завершить'),
                    ),
                  ),
                )
              ],
            ),
            if (controller.isTodoCompleted)
              Positioned.fill(
                child: CustomPaint(
                  painter: _CustomPainterCrossLine(_crossLineAnimation),
                  willChange: true,
                  child: ScaleTransition(
                    scale: _textInfoScaleAnimation,
                    child: AnimatedBuilder(
                      builder: (BuildContext context, Widget? child) {
                        return Transform.rotate(
                          angle: _textInfoRotateAnimation.value,
                          child: child,
                        );
                      },
                      animation: _textInfoRotateAnimation,
                      child: Center(
                        child: _CompletedInformation(),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Метод закрытия задачи
  Future<void> _completeTodo() async {
    // Не стал дублировать код из контроллера TodosController в TodoViewController.
    // А решил просто использовать контроллер, в котором уже реализован данный код
    final todoViewController = Get.find<TodoViewController>();
    final todosController = Get.find<TodosController>();
    final authController = Get.find<AuthenticationController>();
    todosController.completeTodo(
      docId: todoViewController.docId!,
      completedAuthorUid: authController.firestoreUser.value!.uid,
    );
  }

  /// Смена статуса элемента списка дел
  void _changeTodoElementCompleteStatus(TodoElement element) {
    final controller = Get.find<TodoViewController>();
    controller.changeTodoElementCompleteStatus(isCompleted: !element.completed, todoElementUid: element.uid);
  }
}

class _CustomPainterCrossLine extends CustomPainter {
  _CustomPainterCrossLine(this.width) : super(repaint: width);

  Animation<double> width;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 3
      ..color = Colors.black
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      const Offset(0, 0),
      Offset(width.value * size.width, size.height),
      paint,
    );

    canvas.drawLine(
      Offset(size.width, 0),
      Offset(size.width - (width.value * size.width), size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class _CompletedInformation extends StatelessWidget {
  _CompletedInformation();

  final formatterDate = DateFormat('dd MM yyyy');
  final formatterTime = DateFormat('HH:mm:ss');

  @override
  Widget build(BuildContext context) {
    final todoViewController = Get.find<TodoViewController>();
    final userMapController = Get.find<UsersMapController>();
    assert(todoViewController.todoModel != null);
    final completedAuthor = userMapController.getUserModel(todoViewController.todoModel!.completedAuthorId);
    final completedDateTime = DateTime.fromMillisecondsSinceEpoch(todoViewController.todoModel!.completedTimestamp);
    return ThemeDepCommonItemBox(
      child: Builder(
        builder: (context) {
          // Builder для получения актуального контекста
          final textTheme = Theme.of(context).textTheme;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ЗАКРЫТО!',
                  style: textTheme.headline5,
                ),
                const SizedBox(height: 10),
                Text(completedAuthor?.name ?? ''),
                Text(
                  formatterDate.format(completedDateTime),
                  style: TextStyle(fontSize: 15, color: textTheme.bodyText2?.color?.withOpacity(0.3)),
                ),
                Text(
                  formatterTime.format(completedDateTime),
                  style: TextStyle(fontSize: 15, color: textTheme.bodyText2?.color?.withOpacity(0.3)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
