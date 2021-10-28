import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shop_list/models/models.dart';

/// Класс с бизнес-логикой добавления/обновления/удаления списков дел
class TodoService {
  /// Аргумент _db (Dependency injection) необходим, чтобы вынести контекст
  /// за пределы класса, таким образом делая класс тестируемым
  /// при помощи Mock зависимостей
  /// В продакшн коде достаточно использовать FirebaseStorage.instance
  TodoService([
    FirebaseFirestore? db,
  ]) : _db = db ?? FirebaseFirestore.instance;

  /// База данных firestore
  final FirebaseFirestore _db;

  /// Путь к коллекции списка дел
  CollectionReference<Map<String, dynamic>> get _collectionRef => _db.collection('todos');

  /// Проверка, имеется ли в БД по указанному пути документ
  Future<bool> isDocExists(String docId) async {
    var snap = await _collectionRef.doc(docId).get();
    return snap.exists;
  }

  /// Добавление в БД нового todoModel
  Future<DocumentReference<Map<String, dynamic>>> addTodo(TodoModel todoModel) {
    return _collectionRef.add(todoModel.toJson());
  }

  /// Чтение списка дел по указанному ID документа
  Future<TodoModel> findTodo(String docId) async {
    var result = await _collectionRef.doc(docId).get();
    assert(result.data() != null);
    return TodoModel.fromJson(result.data()!);
  }

  /// Удаление todoModel по id документа
  Future<void> deleteTodo(String docId) async {
    _collectionRef.doc(docId).delete();
  }

  /// Обновление todoModel по id документа
  Future<void> updateTodo(String docId, TodoModel todoModel) async {
    _collectionRef.doc(docId).update(todoModel.toJson());
  }
}
