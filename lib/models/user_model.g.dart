// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      name: json['name'] as String,
      email: json['email'] as String,
      photoUrl: json['photoUrl'] as String,
      uid: json['uid'] as String,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'photoUrl': instance.photoUrl,
      'uid': instance.uid,
    };
