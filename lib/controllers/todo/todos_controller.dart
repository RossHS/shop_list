import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shop_list/controllers/controllers.dart';
import 'package:shop_list/controllers/todo/todo_service.dart';
import 'package:shop_list/models/models.dart';

/// Контроллер списков дел. Содержит в себе полную коллекцию доступных списков,
/// а также их отфильтрованный вариант по различным критериям.
class TodosController extends GetxController {
  /// Создаем конструктор с таким перечнем параметров, чтобы сделать класс тестируемым,
  /// т.к. будем работать с реальной базой данных. По дефолту используется значение из контроллера аутентификации,
  /// который инициализируется при старте приложения
  TodosController({
    Rxn<UserModel>? user,
    TodoService? todoService,
  })  : user = user ?? AuthenticationController.instance.firestoreUser,
        todoService = todoService ?? TodoService();

  late final UsersMapController _usersMapController;

  /// Ссылка на текущего пользователя, чтобы знать чьи приватные списки мы можем читать
  final Rxn<UserModel> user;

  /// Сервис с бизнес-логикой создания потока данных списка дел
  final TodoService todoService;

  /// Подписчик на события в модели пользователя
  late final StreamSubscription userStreamSubscriber;
  StreamSubscription? todoStreamSubscriber;

  /// Все доступные списки дел с указанием id документа из БД - Id пользователя из [user]
  /// совпадает с Id автора или список является публичным.
  /// Оболочка нужна, чтобы без перезапросов к БД проводить операции изменения, удаления документа
  final allTodosList = <FirestoreRefTodoModel>[].obs;

  /// Отфильтрованный список дел, которым следует пользоваться - строится на основании [allTodosList]
  /// с определенными условиями. Закрытая ли задача, сортировка по дате и т.п.
  /// Именно его и следует использовать при построении GUI
  final filteredTodoList = <FirestoreRefTodoModel>[].obs;

  bool get isTodoStreamSubscribedNonNull => todoStreamSubscriber != null;

  @override
  void onInit() {
    super.onInit();
    // Так как UsersMapController идет в связке с текущим контроллером, то имеет смысл
    // инициализировать его совместно с этим контроллером
    _usersMapController = Get.put(UsersMapController());
    // При инициализации вычитываем значение текущего пользователя, т.к. возможна ситуация,
    // когда пользователь уже есть, мы подписываемся на стрим, а слушатель реагирует только
    // на изменения, поэтому следует сделать начальную синхронизацию
    _userModelChangesListener(user.value);
    userStreamSubscriber = user.listen(_userModelChangesListener);
  }

  @override
  void onClose() {
    userStreamSubscriber.cancel();
    todoStreamSubscriber?.cancel();
    super.onClose();
  }

  void deleteTodo(String docId) {
    // TODO прописать появление оверлея с инфой при работе с этим методом
    todoService.deleteTodo(docId);
  }

  void _userModelChangesListener(UserModel? userModel) {
    if (userModel != null) {
      // Отмена предыдущего подписчика
      todoStreamSubscriber?.cancel();
      allTodosList.clear();
      // TODO написать работу с фильтром
      todoStreamSubscriber = todoService.createStream(userModel.uid).listen((query) {
        for (var docChanges in query.docChanges) {
          final jsonData = docChanges.doc.data();

          if (jsonData != null) {
            final refModel = FirestoreRefTodoModel(
              idRef: docChanges.doc.id,
              todoModel: TodoModel.fromJson(jsonData),
            );
            // При чтении списка дел отправляем id автора на проверку в мапу,
            // если такого пользователя нет, то вычитываем его из БД
            _usersMapController.readId(userId: refModel.todoModel.authorId);
            switch (docChanges.type) {
              case DocumentChangeType.added:
                if (!allTodosList.contains(refModel)) {
                  allTodosList.add(refModel);
                }
                break;
              case DocumentChangeType.modified:
                allTodosList.removeWhere((e) => e.idRef == refModel.idRef);
                allTodosList.add(refModel);
                break;
              case DocumentChangeType.removed:
                allTodosList.removeWhere((e) => e.idRef == refModel.idRef);
                break;
            }
          }
        }
        allTodosList.sort((a, b) => a.todoModel.createdTimestamp - b.todoModel.createdTimestamp);
      });
    }
  }
}
