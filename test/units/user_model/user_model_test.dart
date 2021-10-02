import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shop_list/models/user_model.dart';

/// Юнит тестирование работы класса [UserModel]
void main() {
  var user = UserModel(
    name: 'Bill',
    email: 'example@gmail.com',
    photoUrl: '',
    uid: '1234qwerty',
  );

  test('Load, parse and compare local Json with UserModel', () async {
    var file = File('test/units/user_model/user.json');
    var jsonMap = jsonDecode(await file.readAsString());
    expect(user, UserModel.fromJson(jsonMap));
  });

  test('Compare json from file and json from object UserModel', () async {
    var file = File('test/units/user_model/user.json');
    var jsonMap = jsonDecode(await file.readAsString());
    expect(user.toJson(), jsonMap);
  });
}
