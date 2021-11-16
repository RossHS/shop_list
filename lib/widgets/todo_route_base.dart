// ignore_for_file: invalid_use_of_protected_member

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:implicitly_animated_reorderable_list/implicitly_animated_reorderable_list.dart';
import 'package:implicitly_animated_reorderable_list/transitions.dart';
import 'package:shop_list/controllers/controllers.dart';
import 'package:shop_list/custom_icons.dart';
import 'package:shop_list/models/models.dart';
import 'package:shop_list/widgets/animated90s/animated_90s.dart';
import 'package:shop_list/widgets/custom_text_field.dart';

/// Так как маршруты изменения и формирования маршрутов отличаются одной лишь кнопкой,
/// то имеет смысл выделить единую часть в отдельный виджет, дабы не дублировать код
class TodoRouteBase extends StatelessWidget {
  const TodoRouteBase({
    required this.widgetButton,
    Key? key,
  }) : super(key: key);
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
    final controller = Get.find<TodoEditCreateController>();
    // Гарантированная инициализация контроллера TodoEditCreatorController
    return Scaffold(
      appBar: AnimatedAppBar90s(
        leading: IconButton(
          onPressed: Get.back,
          icon: const AnimatedIcon90s(
            iconsList: CustomIcons.arrow,
          ),
        ),
        title: SizedBox(
          width: _Body._width,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Theme(
              data: appBarTheme,
              child: CustomTextField(
                controller: controller.todoTitleTextController,
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
    Key? key,
  }) : super(key: key);
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
  const _AnimatedElementsList({Key? key}) : super(key: key);

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
    Key? key,
  }) : super(key: key);

  final TodoEditCreateController controller;
  final TodoElement item;
  final Animation<double> animation;
  final Animation<double> dragAnimation;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color foregroundColor = theme.colorScheme.secondary;
    final t = dragAnimation.value;
    final color = Color.lerp(foregroundColor, foregroundColor.withOpacity(0.8), t);
    final elevation = lerpDouble(0, 8, t);

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

    //TODO проработать установку цветов
    return SizeFadeTransition(
      sizeFraction: 0.7,
      curve: Curves.easeInOut,
      animation: animation,
      child: Material(
        elevation: elevation!,
        color: color,
        child: Slidable(
          child: ListTile(
            title: Text(
              item.name,
              style: const TextStyle(color: Colors.white),
            ),
            trailing: const Handle(
              delay: Duration(milliseconds: 100),
              child: Icon(
                Icons.list,
                color: Colors.white,
              ),
            ),
          ),
          startActionPane: actions,
          endActionPane: actions,
        ),
      ),
    );
  }
}

/// Поле ввода текста элемента списка и его добавление
class _TodoElementsMsgInput extends StatelessWidget {
  const _TodoElementsMsgInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TodoEditCreateController>();

    return AnimatedPainterSquare90s(
      borderPaint: const BorderPaint.top(),
      config: const Paint90sConfig(backgroundColor: Colors.white),
      child: Material(
        color: Colors.transparent,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: CustomTextField(
                controller: controller.todoElementNameTextController,
                minLines: 1,
                maxLines: 5,
                drawUnderLine: false,
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
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
