import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shop_list/controllers/controllers.dart';
import 'package:shop_list/custom_icons.dart';
import 'package:shop_list/widgets/animated90s/animated_90s_app_bar.dart';
import 'package:shop_list/widgets/animated90s/animated_90s_icon.dart';
import 'package:shop_list/widgets/custom_text_field.dart';

class CreateTodo extends StatelessWidget {
  const CreateTodo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(TodoEditCreateController());

    return Scaffold(
      appBar: AnimatedAppBar90s(
        leading: IconButton(
          onPressed: Get.back,
          icon: const AnimatedIcon90s(
            iconsList: CustomIcons.arrow,
          ),
        ),
        title: const Text('Создание задачи'),
      ),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({Key? key}) : super(key: key);
  static const _width = 400.0;

  @override
  Widget build(BuildContext context) {
    final todoEditController = Get.find<TodoEditCreateController>();
    return Center(
      child: Column(children: [
        SizedBox(
          width: _width,
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: CustomTextField(
              controller: todoEditController.todoTitleTextController,
              hint: 'Заголовок списка',
            ),
          ),
        ),
        const Spacer(),
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
                        value: todoEditController.isPublicTodo.value,
                        onChanged: todoEditController.isPublicCheckBoxToggle,
                      )),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      todoEditController.createAndAddTodo();
                      // После создание записи возвращаемся на предыдущий экран
                      Get.back();
                    },
                    child: const Text('Создать'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
