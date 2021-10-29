import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_list/controllers/todo/todo_service.dart';
import 'package:shop_list/models/models.dart';

/// Тестирование по нескольким пунктам
/// 1) Проверка работы двух методов == и hashCode в TodoModel для идентичных объектов
/// 2) Создание, запаковка списка в JSON и запись в БД
/// 3) Прочтение документа по id, парсинг JSON в объект и сравнение
/// 4) Проверка изменения записи в БД
/// 5) Удаление документа по id
void main() async {
  // mock зависимость firestore
  // https://pub.dev/packages/fake_cloud_firestore
  final mockFirestore = FakeFirebaseFirestore();
  final service = TodoService(mockFirestore);

  group('Todos mock firestore testing', () {
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
}
