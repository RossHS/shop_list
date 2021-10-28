// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TodoModel _$TodoModelFromJson(Map<String, dynamic> json) => TodoModel(
      authorId: json['authorId'] as String,
      completed: json['completed'] as bool,
      createdTimestamp: json['createdTimestamp'] as int,
      completedTimestamp: json['completedTimestamp'] as int,
      title: json['title'] as String,
      isPublic: json['isPublic'] as bool,
    );

Map<String, dynamic> _$TodoModelToJson(TodoModel instance) => <String, dynamic>{
      'authorId': instance.authorId,
      'completed': instance.completed,
      'completedTimestamp': instance.completedTimestamp,
      'createdTimestamp': instance.createdTimestamp,
      'title': instance.title,
      'isPublic': instance.isPublic,
    };
