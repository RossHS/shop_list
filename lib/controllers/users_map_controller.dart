import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shop_list/models/models.dart';

/// Контроллер необходимый для отображения имени пользователя по его id.
/// Так как в документах списков дел пишется id, а пользователь может менять свой никнейм в приложении.
/// Работа происходит по следующему принципу.
class UsersMapController extends GetxController {
  UsersMapController({
    FirebaseFirestore? db,
  }) : _usersMapService = _UsersMapService(db);

  final _UsersMapService _usersMapService;

  /// Мапа, где ключ - id пользователя, значение его имя
  var usersMap = <String, UserModel>{}.obs;

  Future<void> readId({required String userId}) async {
    if (!usersMap.containsKey(userId)) {
      try {
        usersMap[userId] = await _usersMapService.findUser(userId);
      } catch (e) {
        print(e);
      }
    }
  }

  Future<void> readIds({required List<String> usersId}) async {
    try {
      usersId.where((e) => !usersMap.containsKey(e)).forEach((e) async {
        usersMap[e] = await _usersMapService.findUser(e);
      });
    } catch (e) {
      print(e);
    }
  }
}

/// Сервис для обеспечения запросов к БД
class _UsersMapService {
  _UsersMapService([
    FirebaseFirestore? db,
  ]) : _db = db ?? FirebaseFirestore.instance;

  /// База данных
  final FirebaseFirestore _db;

  /// Путь к коллекции списка дел
  CollectionReference<Map<String, dynamic>> get _collectionRef => _db.collection('users');

  /// Поиск имени пользователя по его id
  Future<UserModel> findUser(String userId) async {
    final result = await _collectionRef.doc(userId).get();
    return UserModel.fromJson(result.data()!);
  }
}
