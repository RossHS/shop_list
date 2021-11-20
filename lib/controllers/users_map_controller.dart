import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:logging/logging.dart';
import 'package:shop_list/models/models.dart';

/// Контроллер необходимый для отображения имени пользователя по его id.
/// Так как в документах списков дел пишется id, а пользователь может менять свой никнейм в приложении.
/// Работа происходит по следующему принципу.
class UsersMapController extends GetxController {
  UsersMapController({
    FirebaseFirestore? db,
  }) : _usersMapService = _UsersMapService(db);

  static final _log = Logger('UsersMapController');

  final _UsersMapService _usersMapService;

  /// Мапа, где ключ - id пользователя, значение его имя
  final _usersMap = <String, UserModel>{}.obs;

  Map<String, UserModel> get usersMap => Map<String, UserModel>.unmodifiable(_usersMap);

  UserModel? getUserModel(String key) => _usersMap[key];

  Future<void> readId({required String userId}) async {
    if (!_usersMap.containsKey(userId)) {
      try {
        _usersMap[userId] = await _usersMapService.findUser(userId);
      } catch (error) {
        _log.shout(error);
      }
    }
  }

  Future<void> readIds({required List<String> usersId}) async {
    try {
      usersId.where((e) => !_usersMap.containsKey(e)).forEach((e) async {
        _usersMap[e] = await _usersMapService.findUser(e);
      });
    } catch (error) {
      _log.shout(error);
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
