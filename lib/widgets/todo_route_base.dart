// ignore_for_file: invalid_use_of_protected_member
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';
import 'package:shop_list/controllers/controllers.dart';
import 'package:shop_list/models/models.dart';
import 'package:shop_list/widgets/custom_text_field.dart';
import 'package:shop_list/widgets/themes_widgets/theme_dep.dart';

/// Так как маршруты изменения и формирования списков дел отличаются одной лишь кнопкой,
/// то имеет смысл выделить единую часть в отдельный виджет, дабы не дублировать код
class TodoRouteBase extends StatelessWidget {
  const TodoRouteBase({
    required this.widgetButton,
    super.key,
  });

  final Widget widgetButton;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    // TODO временная установка цвета для поля ввода в AppBar
    final appBarTheme = theme.copyWith(
      textSelectionTheme: theme.textSelectionTheme.copyWith(cursorColor: Colors.white),
      textTheme: theme.textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
        decorationColor: Colors.white,
      ),
      hintColor: Colors.white,
    );
    final todoEditController = Get.find<TodoEditCreateController>();
    // Гарантированная инициализация контроллера TodoEditCreatorController
    return ThemeDepScaffold(
      appBar: ThemeDepAppBar(
        title: SizedBox(
          width: _Body._width,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Theme(
              data: appBarTheme,
              child: CustomTextField(
                controller: todoEditController.todoTitleTextController,
                drawUnderLine: false,
                maxLines: 1,
                decoration: const InputDecoration(
                  labelText: 'Название списка...',
                  isCollapsed: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(8),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                ),
              ),
            ),
          ),
        ),
      ),
      body: _Body(
        buttonWidget: widgetButton,
      ),
    );
  }
}

/// Основное тело экрана
class _Body extends StatelessWidget {
  const _Body({
    required this.buttonWidget,
  });

  static const _width = 400.0;
  final Widget buttonWidget;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TodoEditCreateController>();
    return Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: _width,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Obx(() => CheckboxListTile(
                          title: const Text('Общий'),
                          value: controller.isPublicTodo.value,
                          onChanged: controller.isPublicCheckBoxToggle,
                        )),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: buttonWidget,
                  ),
                ],
              ),
            ),
          ),
          // Список элементов
          const _AnimatedElementsList(),
          // Формирование элементов списка
          const _TodoElementsMsgInput(),
        ],
      ),
    );
  }
}

/// Анимированный список элементов
class _AnimatedElementsList extends StatelessWidget {
  const _AnimatedElementsList();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TodoEditCreateController>();
    return Expanded(
      child: Obx(
        () => ImplicitlyAnimatedReorderableList<TodoElement>(
          // Пишем controller.todoElements.value с value на конце т.к.
          // Obx выкидывает исключение о не нахождении стрима
          items: controller.todoElements.value,
          areItemsTheSame: (a, b) => a == b,
          onReorderFinished: (item, from, to, newItems) {
            controller.todoElements.value
              ..clear()
              ..addAll(newItems);
          },
          itemBuilder: (context, animation, item, index) {
            return Reorderable(
              key: ValueKey(item),
              builder: (context, dragAnimation, inDrag) => _TileItem(
                controller: controller,
                item: item,
                animation: animation,
                dragAnimation: dragAnimation,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Графическое представление элемента
class _TileItem extends StatelessWidget {
  const _TileItem({
    required this.controller,
    required this.item,
    required this.animation,
    required this.dragAnimation,
  });

  final TodoEditCreateController controller;
  final TodoElement item;
  final Animation<double> animation;
  final Animation<double> dragAnimation;

  @override
  Widget build(BuildContext context) {
    // Список элементов находящихся "за" элементом
    final actions = ActionPane(
      motion: const ScrollMotion(),
      children: <Widget>[
        SlidableAction(
          onPressed: (_) => controller.todoElements.remove(item),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          label: 'Удалить',
          icon: Icons.delete,
        ),
      ],
    );

    return SizeFadeTransition(
      sizeFraction: 0.7,
      curve: Curves.easeInOut,
      animation: animation,
      child: Slidable(
        startActionPane: actions,
        endActionPane: actions,
        child: ListTile(
          title: Text(item.name),
          trailing: const Handle(
            delay: Duration(milliseconds: 100),
            child: Icon(Icons.list),
          ),
        ),
      ),
    );
  }
}

/// Поле ввода текста элемента списка и его добавление
class _TodoElementsMsgInput extends StatelessWidget {
  const _TodoElementsMsgInput();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TodoEditCreateController>();
    return ThemeDepTodoElementMsgInputBox(
      child: Material(
        color: Colors.transparent,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller.todoElementNameTextController,
                minLines: 1,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Текст задачи...',
                  isCollapsed: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(8),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                ),
              ),
            ),
            IconButton(
              onPressed: controller.addTodoElementToList,
              icon: ThemeDepIcon.send,
            ),
          ],
        ),
      ),
    );
  }
}
