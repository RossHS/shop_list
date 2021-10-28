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

  /// Общая ли задача
  var isPublicTodo = false.obs;

  @override
  void onClose() {
    todoTitleTextController.dispose();
    super.onClose();
  }

  /// Переключение флага публичный/приватный список
  void isPublicCheckBoxToggle(bool? value) {
    if (value != null) {
      isPublicTodo.value = value;
    }
  }

  /// Создание и запись списка дел в базу данных
  void createAndAddTodo() {
    var userModel = AuthenticationController.instance.firestoreUser.value;
    if (userModel != null) {
      final todoModel = TodoModel(
        authorId: userModel.uid,
        title: todoTitleTextController.text,
        isPublic: isPublicTodo.value,
      );
      _todoService.addTodo(todoModel);
    }
  }
}
