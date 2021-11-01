import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shop_list/controllers/controllers.dart';
import 'package:shop_list/controllers/todo/todo_service.dart';
import 'package:shop_list/models/models.dart';

/// Контроллер создания, обновления записи TodoModel
class TodoEditCreateController extends GetxController {
  final _todoService = TodoService();

  /// Контроллер поля ввода заголовка списка
  final todoTitleTextController = TextEditingController();

  /// Контроллер текущего элемента для списка
  final todoElementNameTextController = TextEditingController();

  /// Общая ли задача
  var isPublicTodo = false.obs;

  /// перечень задач в списке
  var todoElements = <TodoElement>[].obs;

  @override
  void onClose() {
    todoTitleTextController.dispose();
    todoElementNameTextController.dispose();
    super.onClose();
  }

  /// Переключение флага публичный/приватный список
  void isPublicCheckBoxToggle(bool? value) {
    if (value != null) {
      isPublicTodo.value = value;
    }
  }

  /// Метод формирования TodoElement и добавление его в коллекцию
  void addTodoElementToList() {
    final elementsMsg = todoElementNameTextController.text.trim();
    if (elementsMsg.isEmpty) return;

    todoElements.add(TodoElement(name: elementsMsg));
    todoElementNameTextController.clear();
  }

  /// Создание и запись списка дел в базу данных
  void createAndAddTodo() {
    var userModel = AuthenticationController.instance.firestoreUser.value;
    if (userModel != null) {
      final todoModel = TodoModel(
        authorId: userModel.uid,
        title: todoTitleTextController.text,
        isPublic: isPublicTodo.value,
        elements: todoElements,
      );
      _todoService.addTodo(todoModel);
    }
  }
}
