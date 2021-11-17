import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_list/controllers/controllers.dart';
import 'package:shop_list/custom_icons.dart';
import 'package:shop_list/widgets/animated90s/animated_90s.dart';

/// Отображение списков дел по различным параметрам
class TodosOrder extends StatelessWidget {
  const TodosOrder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AnimatedAppBar90s(
        title: const Text('Отображение списков'),
        leading: IconButton(
          onPressed: Get.back,
          icon: const AnimatedIcon90s(
            iconsList: CustomIcons.arrow,
          ),
        ),
      ),
      body: _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final todosController = Get.find<TodosController>();
    // TODO вставить отступы из animated90sConfig
    const padding = 24.0;
    return Obx(() => ListView(
          padding: const EdgeInsets.all(padding),
          children: <Widget>[
            _BoxItemWidget(
              children: [
                const _Title('Отображение списков'),
                CheckboxListTile(
                  onChanged: (_) {
                    todosController.setValidation(completedValidation: CompletedValidation.all);
                  },
                  value: todosController.validator.value.completedValidation == CompletedValidation.all,
                  title: const Text('Все списки'),
                ),
                const _Divider(),
                CheckboxListTile(
                  onChanged: (_) {
                    todosController.setValidation(completedValidation: CompletedValidation.opened);
                  },
                  value: todosController.validator.value.completedValidation == CompletedValidation.opened,
                  title: const Text('Открытые'),
                ),
                const _Divider(),
                CheckboxListTile(
                  onChanged: (_) {
                    todosController.setValidation(completedValidation: CompletedValidation.closed);
                  },
                  value: todosController.validator.value.completedValidation == CompletedValidation.closed,
                  title: const Text('Завершенные'),
                ),
              ],
            ),
            const SizedBox(height: padding),
            _BoxItemWidget(
              children: [
                const _Title('Авторство списков'),
                CheckboxListTile(
                  onChanged: (_) {
                    todosController.setValidation(authorValidation: AuthorValidation.all);
                  },
                  value: todosController.validator.value.authorValidation == AuthorValidation.all,
                  title: const Text('Все авторы'),
                ),
                const _Divider(),
                CheckboxListTile(
                  onChanged: (_) {
                    todosController.setValidation(authorValidation: AuthorValidation.myLists);
                  },
                  value: todosController.validator.value.authorValidation == AuthorValidation.myLists,
                  title: const Text('Мои списки'),
                ),
                const _Divider(),
                CheckboxListTile(
                  onChanged: (_) {
                    todosController.setValidation(authorValidation: AuthorValidation.otherLists);
                  },
                  value: todosController.validator.value.authorValidation == AuthorValidation.otherLists,
                  title: const Text('Чужие'),
                ),
              ],
            ),
            const SizedBox(height: padding),
            _BoxItemWidget(
              children: [
                const _Title('Сортировка по'),
                CheckboxListTile(
                  onChanged: (_) {
                    todosController.sortFilteredList.value = SortFilteredList.dateDown;
                  },
                  value: todosController.sortFilteredList.value == SortFilteredList.dateDown,
                  title: const Text('По дате'),
                  secondary: const Icon(Icons.arrow_downward),
                ),
                const _Divider(),
                CheckboxListTile(
                  onChanged: (_) {
                    todosController.sortFilteredList.value = SortFilteredList.dateUp;
                  },
                  value: todosController.sortFilteredList.value == SortFilteredList.dateUp,
                  title: const Text('По дате'),
                  secondary: const Icon(Icons.arrow_upward),
                ),
              ],
            ),
          ],
        ));
  }
}

/// Блок с настройками
class _BoxItemWidget extends StatelessWidget {
  const _BoxItemWidget({required this.children, Key? key}) : super(key: key);
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    const config = Paint90sConfig();
    final padding = config.offset.toDouble();
    return Padding(
      padding: EdgeInsets.all(padding),
      child: AnimatedPainterSquare90s(
        config: config,
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 2,
        color: Colors.grey.shade300,
      ),
    );
  }
}

/// Заголовок "блока" настроек
class _Title extends StatelessWidget {
  const _Title(this.title, {Key? key}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.headline5,
      textAlign: TextAlign.center,
    );
  }
}
