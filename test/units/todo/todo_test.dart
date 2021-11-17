import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shop_list/controllers/controllers.dart';
import 'package:shop_list/controllers/todo/todo_service.dart';
import 'package:shop_list/models/models.dart';

/// Тестирование по нескольким пунктам
/// 1) Проверка работы двух методов == и hashCode в TodoModel для идентичных объектов
/// 2) Создание, запаковка списка в JSON и запись в БД
/// 3) Прочтение документа по id, парсинг JSON в объект и сравнение
/// 4) Проверка изменения записи в БД
/// 5) Удаление документа по id
void main() async {
  group('Todos mock firestore testing', () {
    // mock зависимость firestore
    // https://pub.dev/packages/fake_cloud_firestore
    final service = TodoService(FakeFirebaseFirestore());
    // Тестовый объект над которым будем проводить операции
    final todoModel = TodoModel(authorId: 'AdminTest', title: 'Test TODO', elements: [
      TodoElement(name: 'First task', completed: true),
      TodoElement(name: 'Seconds task'),
    ]);

    test('Check correct implementation TodoModel == and hashCode methods', () async {
      final equalModel = todoModel.copyWith();
      final nonEqualModel = todoModel.copyWith(title: 'DIF', elements: []);
      expect(todoModel == equalModel, true);
      expect(todoModel == nonEqualModel, false);
      expect(todoModel.hashCode == equalModel.hashCode, true);
      expect(todoModel.hashCode == nonEqualModel.hashCode, false);
    });

    // Ссылка на загруженный документ
    var docId = '';
    test('Writing todo data to the database', () async {
      var ref = await service.addTodo(todoModel);
      docId = ref.id;
      // После записи полный получить не пустой ID созданного документа
      expect(docId.isNotEmpty, true);
    });

    test('Reading data from the database using id. Comparing TodoModels', () async {
      var readModel = await service.findTodo(docId);
      // Сравнение созданной в коде модели и созданной на основе записи в БД
      expect(todoModel, readModel);
    });

    test(
        'Overwriting the existing data in the db, '
        'then reading and comparing results.', () async {
      final updatedTodoModel = TodoModel(
        authorId: 'AdminTest',
        title: 'Updated TODO',
      );
      service.updateTodo(docId, updatedTodoModel);
      var readModel = await service.findTodo(docId);
      expect(readModel, updatedTodoModel);
      // Проверка, что модель обновилась
      expect(readModel == todoModel, false);
    });

    test('Deleting doc by id test', () async {
      // Проверяем наличие документа до удаления и после
      var ref = await service.addTodo(todoModel);
      expect(await service.isDocExists(ref.id), true);
      await service.deleteTodo(ref.id);
      expect(await service.isDocExists(ref.id), false);
    });
  });

  // Тестирование оберточного класса
  group('FirestoreRefTodoModel testing', () {
    test('== and hashSet test', () {
      // Создаем два одинаковых объекта
      final origin = FirestoreRefTodoModel(
        idRef: 'ref',
        todoModel: TodoModel(
          authorId: 'author',
          title: 'title',
          isPublic: false,
          completedTimestamp: 222,
          elements: [
            TodoElement(name: 'element_1', uid: 'uid1'),
            TodoElement(name: 'element_2', uid: 'uid2'),
          ],
        ),
      );

      final copy = FirestoreRefTodoModel(
        idRef: 'ref',
        todoModel: TodoModel(
          authorId: 'author',
          title: 'title',
          isPublic: false,
          completedTimestamp: 222,
          elements: [
            TodoElement(name: 'element_1', uid: 'uid1'),
            TodoElement(name: 'element_2', uid: 'uid2'),
          ],
        ),
      );

      final dif = FirestoreRefTodoModel(
        idRef: 'dif',
        todoModel: TodoModel(
          authorId: 'author',
          title: 'title',
          isPublic: false,
          completedTimestamp: 222,
          elements: [
            TodoElement(name: 'element_1', uid: 'uid1'),
            TodoElement(name: 'element_2', uid: 'uid2'),
          ],
        ),
      );

      expect(origin == copy, true);
      expect(origin == dif, false);
      expect(origin.hashCode == copy.hashCode, true);
      expect(origin.hashCode == dif.hashCode, false);
    });
  });

  // Все связанное с тестированием потока данных БД firestore
  group('Todos firestore stream testing', () {
    // Повторная инициализация всех сервисом, чтобы не возникало
    // случайных "ошибок" от предыдущих тестов
    final mockFirestore = FakeFirebaseFirestore();
    final service = TodoService(mockFirestore);

    const userId = 'test_user_ID';
    const firstRandomUserId = 'random_user_1_ID';
    const secondRandomUserId = 'random_user_2_ID';

    // Проверка на количество элементов удовлетворяющим условиям -
    // id пользователя создавшего запись и публичные записи от других пользователей
    // Проверка работы именно
    test('Testing TodoService Stream merge working by elements in list', () async {
      // Для более широкой проверки сначала добавляем пару записей ДО начала создания стрима
      service.addTodo(TodoModel(authorId: userId, title: 'PRE_1'));
      service.addTodo(TodoModel(authorId: userId, title: 'PRE_2'));
      service.addTodo(TodoModel(authorId: firstRandomUserId, title: 'PRE_RANDOM_USER_PUBLIC', isPublic: true));
      service.addTodo(TodoModel(authorId: firstRandomUserId, title: 'PRE_RANDOM_USER_PRIVATE', isPublic: false));

      final stream = service.createStream(userId);
      // Заголовки
      final set = <String>{};
      final list = <TodoModel>[];
      stream.listen((event) {
        for (var element in event.docChanges) {
          if (element.type == DocumentChangeType.added) {
            set.add(TodoModel.fromJson(element.doc.data()!).title);
            list.add(TodoModel.fromJson(element.doc.data()!));
          }
        }
      });

      // Добавление записей после создания потока
      service.addTodo(TodoModel(authorId: userId, title: 'POST_1'));
      service.addTodo(TodoModel(authorId: userId, title: 'POST_2'));
      service.addTodo(TodoModel(authorId: secondRandomUserId, title: 'POST_RANDOM_USER_PUBLIC', isPublic: true));
      service.addTodo(TodoModel(authorId: firstRandomUserId, title: 'POST_RANDOM_USER_PRIVATE', isPublic: false));

      // Небольшая задержка так как stream работает в асинхронном режиме
      await Future.delayed(const Duration(seconds: 1));
      // Проверка заголовков списков, которые должны находиться в коллекции
      expect(set, {
        'PRE_1',
        'PRE_2',
        'PRE_RANDOM_USER_PUBLIC',
        'POST_1',
        'POST_2',
        'POST_RANDOM_USER_PUBLIC',
      });
    });
  });

  // Группа тестов TodosController
  group('TodosController tests', () {
    final fakeFirebaseFirestore = FakeFirebaseFirestore();
    test('Checking stream creation with an auth user', () {
      // Оболочка Rxn - чтобы корректно работал с контроллером
      final userModel = Rxn(const UserModel(
        name: 'name',
        email: 'email',
        photoUrl: 'photoUrl',
        uid: 'uid',
      ));

      // Инициализация в GetX чтобы приблизить тестовые условия к реальным.
      // Использую тег, чтобы гарантировать инициализацию разных контроллеров,
      final todosController = Get.put(
        TodosController(user: userModel, db: fakeFirebaseFirestore),
        tag: 'auth_user',
      );
      expect(todosController.todoStreamSubscriber, isNotNull);
    });

    test('Checking stream creation with delayed user auth', () async {
      final userModel = Rxn<UserModel>();
      final todosController = Get.put(
        TodosController(user: userModel, db: fakeFirebaseFirestore),
        tag: 'null_user',
      );
      expect(todosController.isTodoStreamSubscribedNonNull, false);

      // Добавление объекта пользователя, после которого должен создаться стрим всех допустимых списков дел.
      // Гарантией создание является наличие подписчика
      userModel.value = const UserModel(name: 'name', email: 'email', photoUrl: 'photoUrl', uid: 'uid');
      expect(todosController.isTodoStreamSubscribedNonNull, true);
    });

    test('AllTodosList check', () async {
      final fakeFirebaseFirestore = FakeFirebaseFirestore();
      final service = TodoService(fakeFirebaseFirestore);
      // Оболочка Rxn - чтобы корректно работал с контроллером
      final realAuthor = Rxn(const UserModel(
        name: 'name',
        email: 'email',
        photoUrl: 'photoUrl',
        uid: 'uid',
      ));

      service.addTodo(TodoModel(authorId: realAuthor.value!.uid, title: 'PRE_first_ADD'));

      final todosController = Get.put(
        TodosController(user: realAuthor, db: fakeFirebaseFirestore),
        tag: 'all_todos_list',
      );

      service.addTodo(TodoModel(authorId: realAuthor.value!.uid, title: 'POST_second_ADD'));
      service.addTodo(TodoModel(authorId: realAuthor.value!.uid, title: 'POST_third_ADD'));
      service.addTodo(TodoModel(authorId: 'dif_user', title: 'POST_dif_user_private_ADD', isPublic: false));
      service.addTodo(TodoModel(authorId: 'dif_user', title: 'POST_dif_user_ADD', isPublic: true));

      // К сожалению, в библиотеке https://pub.dev/packages/fake_cloud_firestore  на данном этапе не поддерживаются
      // в query.docChanges другие типы DocumentChangeType кроме как added, который ставится независимо
      // от производимой операции над данными в ДБ, что делает невозможным полный объем тестирования алгоритма.
      // Ссылка на исходный код класса, который отвечает на этот участок
      //
      // https://github.com/atn832/fake_cloud_firestore/blob/146ba743ad8efb19aff30d1263437266a2a16071/lib/src/mock_query_snapshot.dart
      // Где сам автор пишет
      // TD: support another change type (removed, modified).
      // ref: https://pub.dev/documentation/cloud_firestore_platform_interface/latest/cloud_firestore_platform_interface/DocumentChangeType-class.html

      // После небольшой задержки проверяем коллекцию списка дел
      await Future.delayed(const Duration(milliseconds: 200));
      expect(todosController.allTodosList.length, 4);
      // Проверка заголовков
      expect(todosController.allTodosList.map((element) => element.todoModel.title), [
        'PRE_first_ADD',
        'POST_second_ADD',
        'POST_third_ADD',
        'POST_dif_user_ADD',
      ]);
    });

    test('completeTodo method test', () async {
      final service = TodoService(fakeFirebaseFirestore);
      // Штатный режим обновления
      final todoController = TodosController(
          user: Rxn(const UserModel(
            name: 'name',
            email: 'email',
            photoUrl: 'photo',
            uid: 'uid',
          )),
          db: fakeFirebaseFirestore);
      final todoModel = TodoModel(authorId: 'complete_test', title: 'complete_test', completed: false);
      final ref = await service.addTodo(todoModel);
      await todoController.completeTodo(docId: ref.id, completedAuthorUid: 'completedAuthor');
      final findTodo = await service.findTodo(ref.id);
      expect(findTodo.completed, true);
      // После простановки статуса завершено ставится временная метка окончания задачи
      expect(findTodo.completedTimestamp, greaterThan(0));

      // Повторное закрытие не должно сработать, проверить это можно по неизменившийся временной метки закрытия задачи
      await Future.delayed(const Duration(milliseconds: 300));
      await todoController.completeTodo(docId: ref.id, completedAuthorUid: 'completedAuthor');
      final doubleComplete = await service.findTodo(ref.id);
      expect(doubleComplete.completedTimestamp, findTodo.completedTimestamp);
    });

    test('filteredTodoList and validations tests', () async {
      const currentUser = UserModel(
        name: 'Author',
        email: 'email',
        photoUrl: 'photoUrl',
        uid: 'author_uid',
      );
      final db = FakeFirebaseFirestore();
      final service = TodoService(db);

      final todosController = Get.put(
        TodosController(db: db, user: Rxn<UserModel>(currentUser)),
        tag: 'filteredTodoList and validations tests',
      );
      todosController.setValidation(
        authorValidation: AuthorValidation.all,
        completedValidation: CompletedValidation.all,
      );

      // Загрузка тестовых данных
      Future<FirestoreRefTodoModel> addTodo(TodoModel todoModel) async {
        final ref = await service.addTodo(todoModel);
        return FirestoreRefTodoModel(todoModel: todoModel, idRef: ref.id);
      }

      final cuNonCompleted = await addTodo(
        TodoModel(
          authorId: currentUser.uid,
          title: 'currentUser_non_completed',
          completed: false,
          isPublic: true,
          createdTimestamp: 1,
        ),
      );
      final cuCompleted = await addTodo(
        TodoModel(
          authorId: currentUser.uid,
          title: 'currentUser_completed',
          completed: true,
          isPublic: true,
          createdTimestamp: 2,
        ),
      );
      final duNonCompleted = await addTodo(
        TodoModel(
          authorId: 'Dif_user',
          title: 'difUser_non_completed',
          completed: false,
          isPublic: true,
          createdTimestamp: 3,
        ),
      );
      final duCompleted = await addTodo(
        TodoModel(
          authorId: 'Dif_user',
          title: 'difUser_completed',
          completed: true,
          isPublic: true,
          createdTimestamp: 4,
        ),
      );

      // В текущем состоянии validator должен пропускать все приходящие данные
      expect(todosController.filteredTodoList, todosController.allTodosList);

      // Валидация списков только текущего пользователя
      todosController.setValidation(
        authorValidation: AuthorValidation.myLists,
        completedValidation: CompletedValidation.all,
      );
      await Future.delayed(const Duration(milliseconds: 200));
      expect(todosController.filteredTodoList, [
        cuNonCompleted,
        cuCompleted,
      ]);

      // Валидация только закрытых задач от текущего пользователя
      todosController.setValidation(
        authorValidation: AuthorValidation.myLists,
        completedValidation: CompletedValidation.closed,
      );
      await Future.delayed(const Duration(milliseconds: 200));
      expect(todosController.filteredTodoList, [
        cuCompleted,
      ]);

      // Валидация только открытых задач ото всех пользователей
      todosController.setValidation(
        authorValidation: AuthorValidation.all,
        completedValidation: CompletedValidation.opened,
      );
      await Future.delayed(const Duration(milliseconds: 200));
      expect(todosController.filteredTodoList, [
        cuNonCompleted,
        duNonCompleted,
      ]);

      // Валидация только открытых задач ото всех других пользователей
      todosController.setValidation(
        authorValidation: AuthorValidation.otherLists,
        completedValidation: CompletedValidation.opened,
      );
      await Future.delayed(const Duration(milliseconds: 200));
      expect(todosController.filteredTodoList, [
        duNonCompleted,
      ]);

      // Проверка корректности сортировки по времени
      todosController.setValidation(
        authorValidation: AuthorValidation.all,
        completedValidation: CompletedValidation.all,
      );
      todosController.sortFilteredList.value = SortFilteredList.dateUp;
      await Future.delayed(const Duration(milliseconds: 200));
      expect(todosController.filteredTodoList, [
        duCompleted,
        duNonCompleted,
        cuCompleted,
        cuNonCompleted,
      ]);
    });
  });

  // Тестирование TodoViewController контроллера
  group('TodoViewController tests', () {
    final db = FakeFirebaseFirestore();
    final service = TodoService(db);
    // Желаемый сценарий работы (загрузка реальной модели по корректному id)
    test('loadTodoModel test correct data', () async {
      final controller = TodoViewController(db: db);
      final todoModel = TodoModel(title: 'title', authorId: 'author');
      final ref = await service.addTodo(todoModel);

      controller.loadTodoModel(ref.id);
      await Future.delayed(const Duration(milliseconds: 200));
      expect(controller.todoModel, todoModel);
      expect(controller.state, TodoViewCurrentState.loaded);
    });

    // Ошибочный сценарий (некорректное id документа)
    test('loadTodoModel test incorrect doc id', () async {
      final controller = TodoViewController(db: db);

      controller.loadTodoModel('error_id');
      await Future.delayed(const Duration(milliseconds: 200));
      expect(controller.todoModel, null);
      expect(controller.state, TodoViewCurrentState.error);
    });

    // Заготовка списка дел с двумя элементами, где в конце теста у каждого должен стоять статус - завершено
    test('changeTodoElementCompleteStatus test', () async {
      final controller = TodoViewController(db: db);
      // Формирование модели для проведения тестирования
      final firstElement = TodoElement(name: 'first_element', completed: true);
      final secondElement = TodoElement(name: 'second_element', completed: false);
      final todoModel = TodoModel(
        authorId: 'changeTodoElementCompleteStatus_test',
        title: 'changeTodoElementCompleteStatus_test',
        elements: [firstElement, secondElement],
      );
      final docRef = await service.addTodo(todoModel);

      // Загрузка модели в контроллер, смена статуса элемента в списке на завершенный
      controller.loadTodoModel(docRef.id);
      await Future.delayed(const Duration(milliseconds: 200));
      await controller.changeTodoElementCompleteStatus(
        isCompleted: true,
        todoElementUid: firstElement.uid,
      );
      await controller.changeTodoElementCompleteStatus(
        isCompleted: true,
        todoElementUid: secondElement.uid,
      );
      final resTodo = await service.findTodo(docRef.id);

      for (var element in resTodo.elements) {
        expect(element.completed, true);
      }
    });
  });
}
