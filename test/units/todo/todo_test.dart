import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shop_list/controllers/todo/todo_service.dart';
import 'package:shop_list/controllers/todo/todos_controller.dart';
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

  // Тестирование оберточного  класса
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

  // Группа тестов
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
  });
}
