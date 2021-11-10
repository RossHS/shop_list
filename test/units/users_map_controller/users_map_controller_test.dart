import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_list/controllers/controllers.dart';
import 'package:shop_list/models/models.dart';

/// Тестирование работы класса-контроллера UsersMapController
void main() async {
  final db = FakeFirebaseFirestore();
  final collection = db.collection('users');
  final controller = UsersMapController(db: db);

  // Модель пользователя, которую добавим в БД и по ссылке попытаемся распарсить ее назад и сравнить результат
  const user1 = UserModel(name: 'User1', email: 'email', photoUrl: 'photoUrl', uid: 'uid1');
  final user1Ref = await collection.add(user1.toJson());

  // Проверка формирования списка пользователя по единичному запросу
  test('Single id query', () async {
    await controller.readId(userId: user1Ref.id);
    expect(controller.usersMap[user1Ref.id], user1);
  });

  // Проверка формирования списка пользователя по группе запросов id
  test('Group ids query', () async {
    // Модель пользователя, которую добавим в БД и по ссылке попытаемся распарсить ее назад и сравнить результат
    const user2 = UserModel(name: 'User2', email: 'email', photoUrl: 'photoUrl', uid: 'uid2');
    final user2Ref = await collection.add(user2.toJson());
    await controller.readIds(usersId: [user2Ref.id, user2Ref.id]);
    expect(const ListEquality().equals(controller.usersMap.values.toList(), [user1, user2]), true);
  });

  // Запрос id пользователя, которого нет в БД
  test('Error id query', () async {
    // При запросе id, которого нет в БД. Размер коллекции должен остаться прежним
    final length = controller.usersMap.length;
    await controller.readId(userId: 'error_id');
    expect(controller.usersMap.length, length);
  });
}
