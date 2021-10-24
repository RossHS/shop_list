import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

/// Класс описывающий модель пользователя из Firebase
///
/// Для генерации кода
/// flutter pub run build_runner build
///
/// Для автоматического обновления сгенерированного кода достаточно написать
/// flutter pub run build_runner watch
/// и после каждого изменения класса будет автоматически вызван build
@JsonSerializable()
class UserModel {
  UserModel({
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.uid,
  });

  final String name;
  final String email;
  final String photoUrl;
  final String uid;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith({
    String? name,
    String? email,
    String? photoUrl,
    String? uid,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      uid: uid ?? this.uid,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          email == other.email &&
          photoUrl == other.photoUrl &&
          uid == other.uid;

  @override
  int get hashCode => Object.hashAll([name, email, photoUrl, uid]);
}
