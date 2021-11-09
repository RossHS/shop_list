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

  /// Загрузка в контроллер данных списка дел, с которыми можно в последствии работать
  void loadTodoToController(TodoModel todoModel) async {
    todoTitleTextController.text = todoModel.title;
    isPublicTodo.value = todoModel.isPublic;
    todoElements.value = todoModel.elements;
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
    return _todoCEHelper(
      todoBuilder: () {
        final todoModel = TodoModel(
          authorId: AuthenticationController.instance.firestoreUser.value!.uid,
          title: todoTitleTextController.text.trim(),
          isPublic: isPublicTodo.value,
          elements: todoElements,
        );
        _todoService.addTodo(todoModel);
      },
      overlayTitleString: 'Создание списка',
      overlaySuccessString: 'Список успешно создан!',
    );
  }

  /// Обновление списка дел в БД
  bool updateTodo(String docId, TodoModel todoModel) {
    return _todoCEHelper(
      todoBuilder: () {
        final editedTodo = todoModel.copyWith(
          authorId: AuthenticationController.instance.firestoreUser.value!.uid,
          title: todoTitleTextController.text.trim(),
          isPublic: isPublicTodo.value,
          elements: todoElements,
        );
        _todoService.updateTodo(docId, editedTodo);
      },
      overlayTitleString: 'Обновление списка',
      overlaySuccessString: 'Список успешно обновлен!',
    );
  }

  /// Вспомогательный метод, т.к. методы создания и обновления записи в БД имеют
  /// практически идентичную структуру, вынес код в отдельный метод, чтобы избежать дублирования
  bool _todoCEHelper({
    required void Function() todoBuilder,
    required String overlayTitleString,
    required String overlaySuccessString,
  }) {
    var userModel = AuthenticationController.instance.firestoreUser.value;
    var todoTitle = todoTitleTextController.text.trim();

    // Формирование данных для SnackBarBuilder
    final snackBarBuilder = OverlayBuilder(title: overlayTitleString);

    if (userModel == null) snackBarBuilder.addMsg('Нет активного пользователя!');
    if (todoTitle.isEmpty) snackBarBuilder.addMsg('Не указано название списка!');
    if (todoElements.isEmpty) snackBarBuilder.addMsg('Пустой список!');

    if (userModel != null && todoTitle.isNotEmpty && todoElements.isNotEmpty) {
      todoBuilder();
      snackBarBuilder.addMsg(overlaySuccessString);
      snackBarBuilder.show();
      return true;
    } else {
      snackBarBuilder.show();
      return false;
    }
  }
}
