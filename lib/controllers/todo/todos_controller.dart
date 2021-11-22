import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logging/logging.dart';
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
    FirebaseFirestore? db,
    UsersMapController? usersMapController,
  })  : user = user ?? AuthenticationController.instance.firestoreUser,
        todoService = TodoService(db),
        _usersMapController = usersMapController;

  static final _log = Logger('TodosController');
  final storage = GetStorage();

  final UsersMapController? _usersMapController;

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

  /// То, по каким параметрам следует фильтровать приходящий список дел
  late final Rx<Validator> validator;

  /// Критерий сортировки списка дел
  late final Rx<SortFilteredList> sortFilteredList;

  bool get isTodoStreamSubscribedNonNull => todoStreamSubscriber != null;

  @override
  void onInit() {
    super.onInit();
    validator = Validator.fromGetStorage(storage).obs;
    sortFilteredList = SortFilteredList.fromGetStorage(storage).obs;

    // Так как UsersMapController идет в связке с текущим контроллером, то имеет смысл
    // инициализировать его совместно с этим контроллером
    if (_usersMapController != null) Get.put(_usersMapController!);
    // При инициализации вычитываем значение текущего пользователя, т.к. возможна ситуация,
    // когда пользователь уже есть, мы подписываемся на стрим, а слушатель реагирует только
    // на изменения, поэтому следует сделать начальную синхронизацию
    _userModelChangesListener(user.value);
    userStreamSubscriber = user.listen(_userModelChangesListener);

    // При смене фильтра - производится перерасчет коллекции отфильтрованной
    // коллекции на базе коллекции со всеми элементами
    ever<Validator>(validator, (changedValidator) {
      _log.fine('validator changes');
      filteredTodoList.clear();
      for (var element in allTodosList) {
        filteredTodoList.addIf(changedValidator.validate(element.todoModel, user.value!), element);
      }
      sortFilteredList.value.sort(filteredTodoList);
      Future(() => changedValidator.writeToGetStorage(storage));
    });
    // Применение нового способа сортировки списка
    ever<SortFilteredList>(sortFilteredList, (changedSortFilteredList) {
      changedSortFilteredList.sort(filteredTodoList);
      Future(() => changedSortFilteredList.writeToGetStorage(storage));
    });
  }

  @override
  void onClose() {
    userStreamSubscriber.cancel();
    todoStreamSubscriber?.cancel();
    super.onClose();
  }

  Future<void> deleteTodo(String docId) async {
    // TODO прописать появление оверлея с инфой при работе с этим методом
    todoService.deleteTodo(docId);
  }

  /// Метод смены статуса на завершенный
  ///
  /// В качестве аргумента функции используется ссылка на документ со
  /// списком дел в БД, а не сам объект [TodoModel] обернутый в [FirestoreRefTodoModel],
  /// чтобы избежать ситуаций рассогласования локальной модели и той, что хранится в БД,
  /// которая безусловно имеет приоритет на локальной
  Future<void> completeTodo({
    required String docId,
    required String completedAuthorUid,
  }) async {
    final todoModel = await todoService.findTodo(docId);
    if (!todoModel.completed) {
      try {
        _log.fine('Updating todo $docId');
        final editedModel = todoModel.copyWith(
          completed: true,
          completedTimestamp: DateTime.now().millisecondsSinceEpoch,
          completedAuthorId: completedAuthorUid,
        );
        await todoService.updateTodo(docId, editedModel);
        _log.fine('Update completed! $docId');
      } catch (error) {
        _log.shout(error);
      }
    }
  }

  void _userModelChangesListener(UserModel? userModel) {
    if (userModel != null) {
      // Отмена предыдущего подписчика
      todoStreamSubscriber?.cancel();
      allTodosList.clear();
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
            _usersMapController?.readId(userId: refModel.todoModel.authorId);
            // Для оптимизации продублировал код добавления элементов в коллекции,
            // т.к. если условно делать привязку к коллекции путем метода ever,
            // то на любые изменения в коллекции allTodosList будет возвращаться
            // полная коллекция => придется стирать и составлять целиком с нуля
            // коллекцию filteredTodosList, что плохо может сказаться на производительности

            switch (docChanges.type) {
              case DocumentChangeType.added:
                allTodosList.addIf(!allTodosList.contains(refModel), refModel);
                filteredTodoList.addIf(
                  !filteredTodoList.contains(refModel) && validator.value.validate(refModel.todoModel, userModel),
                  refModel,
                );
                break;
              case DocumentChangeType.modified:
                allTodosList.removeWhere((e) => e.idRef == refModel.idRef);
                allTodosList.add(refModel);
                filteredTodoList.removeWhere((e) => e.idRef == refModel.idRef);
                filteredTodoList.addIf(validator.value.validate(refModel.todoModel, userModel), refModel);
                break;
              case DocumentChangeType.removed:
                allTodosList.removeWhere((e) => e.idRef == refModel.idRef);
                filteredTodoList.removeWhere((e) => e.idRef == refModel.idRef);
                break;
            }
          }
        }
        sortFilteredList.value.sort(filteredTodoList);
      });
    }
  }

  /// Установка новых параметров валидации приходящих списков дел
  void setValidation({CompletedValidation? completedValidation, AuthorValidation? authorValidation}) {
    validator.value = validator.value.copyWith(
      completedValidation: completedValidation,
      authorValidation: authorValidation,
    );
  }
}

/// Валидатор, то, по каким параметрам фильтруются списки дел для отображения пользователю
class Validator {
  Validator({
    CompletedValidation? completedValidation,
    AuthorValidation? authorValidation,
  })  : completedValidation = completedValidation ?? CompletedValidation.all,
        authorValidation = authorValidation ?? AuthorValidation.all;

  static const validatorCompletedKey = 'validator_completed_key';
  static const validatorAuthorKey = 'validator_author_key';

  final CompletedValidation completedValidation;
  final AuthorValidation authorValidation;

  bool validate(TodoModel todoModel, UserModel currentUser) {
    return completedValidation.valid(todoModel) && authorValidation.valid(todoModel, currentUser);
  }

  /// Создание объекта валидатора на основе записи в устройстве
  factory Validator.fromGetStorage(GetStorage storage) {
    final completed = storage.read<String>(validatorCompletedKey);
    final author = storage.read<String>(validatorAuthorKey);

    CompletedValidation? parsedCompletedValidation;
    if (completed == CompletedValidation.all._debugName) {
      parsedCompletedValidation = CompletedValidation.all;
    } else if (completed == CompletedValidation.opened._debugName) {
      parsedCompletedValidation = CompletedValidation.opened;
    } else if (completed == CompletedValidation.closed._debugName) {
      parsedCompletedValidation = CompletedValidation.closed;
    }

    AuthorValidation? parsedAuthorValidation;
    if (author == AuthorValidation.all._debugName) {
      parsedAuthorValidation = AuthorValidation.all;
    } else if (author == AuthorValidation.myLists._debugName) {
      parsedAuthorValidation = AuthorValidation.myLists;
    } else if (author == AuthorValidation.otherLists._debugName) {
      parsedAuthorValidation = AuthorValidation.otherLists;
    }

    return Validator(
      completedValidation: parsedCompletedValidation,
      authorValidation: parsedAuthorValidation,
    );
  }

  void writeToGetStorage(GetStorage storage) {
    storage.write(validatorCompletedKey, completedValidation._debugName);
    storage.write(validatorAuthorKey, authorValidation._debugName);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Validator &&
          runtimeType == other.runtimeType &&
          completedValidation == other.completedValidation &&
          authorValidation == other.authorValidation;

  @override
  int get hashCode => Object.hashAll([completedValidation, authorValidation]);

  Validator copyWith({
    CompletedValidation? completedValidation,
    AuthorValidation? authorValidation,
  }) {
    return Validator(
      completedValidation: completedValidation ?? this.completedValidation,
      authorValidation: authorValidation ?? this.authorValidation,
    );
  }
}

/// Валидация списков из коллекции [allTodosList] по критерию открыта/закрыта задача
class CompletedValidation {
  static final CompletedValidation all = CompletedValidation._('all', (_) => true);
  static final CompletedValidation opened = CompletedValidation._('opened', (todoModel) => !todoModel.completed);
  static final CompletedValidation closed = CompletedValidation._('closed', (todoModel) => todoModel.completed);

  CompletedValidation._(this._debugName, this.valid);

  final bool Function(TodoModel todoModel) valid;
  final String _debugName;
}

/// Валидация по авторству списков дел, все авторы/только мои списки/только чужие
class AuthorValidation {
  static final all = AuthorValidation._(
    'all',
    (_, __) => true,
  );
  static final myLists = AuthorValidation._(
    'myLists',
    (todoModel, currentUser) {
      return todoModel.authorId == currentUser.uid;
    },
  );
  static final otherLists = AuthorValidation._(
    'otherLists',
    (todoModel, currentUser) {
      return todoModel.authorId != currentUser.uid;
    },
  );

  AuthorValidation._(this._debugName, this.valid);

  final bool Function(TodoModel todoModel, UserModel currentUser) valid;
  final String _debugName;
}

/// Способы сортировки списков дел
class SortFilteredList {
  static final dateDown = SortFilteredList._(
    'dateDown',
    (a, b) => b.todoModel.createdTimestamp - a.todoModel.createdTimestamp,
  );
  static final dateUp = SortFilteredList._(
    'dateUp',
    (a, b) => a.todoModel.createdTimestamp - b.todoModel.createdTimestamp,
  );
  static const sortFilteredListKey = 'sortFiltered_key';

  SortFilteredList._(this._debugName, this._comparator);

  final int Function(FirestoreRefTodoModel a, FirestoreRefTodoModel b) _comparator;
  final String _debugName;

  factory SortFilteredList.fromGetStorage(GetStorage storage) {
    final sortAlg = storage.read<String>(sortFilteredListKey);
    if (sortAlg == null || sortAlg == dateDown._debugName) {
      return dateDown;
    } else if (sortAlg == dateUp._debugName) {
      return dateUp;
    }
    throw Exception('Error while parsing SortFilteredList.fromGetStorage - key $sortFilteredListKey - $sortAlg');
  }

  void writeToGetStorage(GetStorage storage) {
    storage.write(sortFilteredListKey, _debugName);
  }

  void sort(List<FirestoreRefTodoModel> list) {
    list.sort(_comparator);
  }
}
