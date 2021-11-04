import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shop_list/controllers/controllers.dart';
import 'package:shop_list/controllers/info_overlay_controller.dart';
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
  /// Возвращает успешность операции
  bool createAndAddTodo() {
    var userModel = AuthenticationController.instance.firestoreUser.value;
    var todoTitle = todoTitleTextController.text.trim();

    // Формирование данных для SnackBarBuilder
    final snackBarBuilder = OverlayBuilder(title: 'Создание списка');

    if (userModel == null) snackBarBuilder.addMsg('Нет активного пользователя!');
    if (todoTitle.isEmpty) snackBarBuilder.addMsg('Не указано название списка!');
    if (todoElements.isEmpty) snackBarBuilder.addMsg('Пустой список!');

    if (userModel != null && todoTitle.isNotEmpty && todoElements.isNotEmpty) {
      final todoModel = TodoModel(
        authorId: userModel.uid,
        title: todoTitle,
        isPublic: isPublicTodo.value,
        elements: todoElements,
      );
      _todoService.addTodo(todoModel);
      snackBarBuilder.addMsg('Список успешно создан!');
      snackBarBuilder.show();
      return true;
    } else {
      snackBarBuilder.show();
      return false;
    }
  }
}
