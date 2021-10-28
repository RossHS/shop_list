import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_list/controllers/todo/todo_service.dart';
import 'package:shop_list/models/models.dart';

/// Тестирование по нескольким пунктам
/// 1) Создание, запаковка списка в JSON и запись в БД
/// 2) Прочтение документа по id, парсинг JSON в объект и сравнение
/// 3) Проверка изменения записи в БД
/// 4) Удаление документа по id
void main() async {
  // mock зависимость firestore
  // https://pub.dev/packages/fake_cloud_firestore
  final mockFirestore = FakeFirebaseFirestore();
  final service = TodoService(mockFirestore);

  group('Todos mock firestore testing', () {
    // Тестовый объект над которым будем проводить операции
    final todoModel = TodoModel(
      authorId: 'AdminTest',
      title: 'Test TODO',
    );
    // Ссылка на загруженный документ
    var docId = '';
    test('Writing todo data to the database', () async {
      var ref = await service.addTodo(todoModel);
      docId = ref.id;
      // После записи полный получить не пустой ID созданного документа
      expect(true, docId.isNotEmpty);
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
      expect(updatedTodoModel, readModel);
      // Проверка, что модель обновилась
      expect(false, readModel == todoModel);
    });

    test('Deleting doc by id test', () async {
      // Проверяем наличие документа до удаления и после
      var ref = await service.addTodo(todoModel);
      expect(true, await service.isDocExists(ref.id));
      await service.deleteTodo(ref.id);
      expect(false, await service.isDocExists(ref.id));
    });
  });
}
