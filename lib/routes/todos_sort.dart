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
    return ListView(
      children: <Widget>[
        _BoxItemWidget(
          children: [
            const _Title('Отображение списков'),
            CheckboxListTile(
              onChanged: (_) {},
              value: false,
              title: const Text('Все списки'),
            ),
            const _Divider(),
            CheckboxListTile(
              onChanged: (_) {},
              value: false,
              title: const Text('Открытые'),
            ),
            const _Divider(),
            CheckboxListTile(
              onChanged: (_) {},
              value: false,
              title: const Text('Завершенные'),
            ),
          ],
        ),
        _BoxItemWidget(
          children: [
            const _Title('Авторство списков'),
            CheckboxListTile(
              onChanged: (_) {},
              value: false,
              title: const Text('Все авторы'),
            ),
            const _Divider(),
            CheckboxListTile(
              onChanged: (_) {},
              value: false,
              title: const Text('Мои списки'),
            ),
            const _Divider(),
            CheckboxListTile(
              onChanged: (_) {},
              value: false,
              title: const Text('Чужие'),
            ),
          ],
        ),
        _BoxItemWidget(
          children: [
            const _Title('Сортировка по'),
            CheckboxListTile(
              onChanged: (_) {},
              value: false,
              title: const Text('По дате'),
              secondary: const Icon(Icons.arrow_downward),
            ),
            const _Divider(),
            CheckboxListTile(
              onChanged: (_) {},
              value: false,
              title: const Text('По дате'),
              secondary: const Icon(Icons.arrow_upward),
            ),
          ],
        ),
      ],
    );
  }
}

class _BoxItemWidget extends StatelessWidget {
  const _BoxItemWidget({required this.children, Key? key}) : super(key: key);
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    const config = Paint90sConfig();
    final padding = 24.0 + config.offset;
    return Padding(
      padding: EdgeInsets.only(left: padding, right: padding, top: padding),
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
    return const Divider(
      indent: 20,
      endIndent: 20,
      thickness: 2,
    );
  }
}

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
