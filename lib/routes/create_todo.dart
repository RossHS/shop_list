
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
    // Гарантированная инициализация контроллера TodoEditCreatorController
    return GetBuilder<TodoEditCreateController>(
      init: TodoEditCreateController(),
      builder: (controller) => Scaffold(
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
              child: CustomTextField(
                controller: controller.todoTitleTextController,
              ),
            ),
          ),
        ),
        body: const _Body(),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({Key? key}) : super(key: key);
  static const _width = 400.0;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TodoEditCreateController>();
    return Center(
      child: Column(children: [
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
                  child: ElevatedButton(
                    onPressed: () {
                      controller.createAndAddTodo();
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
        Expanded(
          child: Obx(() => ListView.builder(
                    itemCount: controller.todoElements.length,
                    itemBuilder: (context, index) => Container(
                      color: Colors.blue,
                      child: Text(controller.todoElements[index].name),
                    ),
                  )

              // TODO Разобраться с кодом, почему не хочет работать с Obx
              //  ImplicitlyAnimatedReorderableList<TodoElement>(
              //   shrinkWrap: true,
              //   items: controller.todoElements,
              //   areItemsTheSame: (oldItem, newItem) => oldItem == newItem,
              //   onReorderFinished: (item, from, to, newItems) {
              //     controller.todoElements.first;
              //   },
              //   itemBuilder: (context, animation, item, i) => Reorderable(
              //     key: ValueKey(item),
              //     builder: (context, animation, inDrag) {
              //       final t = animation.value;
              //       final elevation = lerpDouble(0, 8, t);
              //       final color = Color.lerp(Colors.white, Colors.white.withOpacity(0.8), t);
              //       return SizeFadeTransition(
              //         sizeFraction: 0.7,
              //         curve: Curves.easeInOut,
              //         animation: animation,
              //         child: Material(
              //           color: color,
              //           elevation: elevation ?? 1,
              //           type: MaterialType.transparency,
              //           child: ListTile(
              //             title: Text(item.name),
              //             // The child of a Handle can initialize a drag/reorder.
              //             // This could for example be an Icon or the whole item itself. You can
              //             // use the delay parameter to specify the duration for how long a pointer
              //             // must press the child, until it can be dragged.
              //             trailing: Handle(
              //               delay: const Duration(milliseconds: 100),
              //               child: Icon(
              //                 Icons.list,
              //                 color: Colors.grey,
              //               ),
              //             ),
              //           ),
              //         ),
              //       );
              //     },
              //   ),
              // ),

              ),
        ),
        const Spacer(),
        CustomTextField(
          controller: controller.todoElementNameTextController,
        ),
        ElevatedButton(
          onPressed: controller.addTodoElementToList,
          child: const Text('add element'),
        ),
      ]),
    );
  }
}
