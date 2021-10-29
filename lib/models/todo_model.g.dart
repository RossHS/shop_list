// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TodoModel _$TodoModelFromJson(Map<String, dynamic> json) => TodoModel(
      authorId: json['authorId'] as String,
      title: json['title'] as String,
      isPublic: json['isPublic'] as bool? ?? false,
      createdTimestamp: json['createdTimestamp'] as int?,
      completed: json['completed'] as bool? ?? false,
      completedTimestamp: json['completedTimestamp'] as int? ?? 0,
      elements: (json['elements'] as List<dynamic>?)
          ?.map((e) => TodoElement.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TodoModelToJson(TodoModel instance) => <String, dynamic>{
      'authorId': instance.authorId,
      'title': instance.title,
      'isPublic': instance.isPublic,
      'createdTimestamp': instance.createdTimestamp,
      'completed': instance.completed,
      'completedTimestamp': instance.completedTimestamp,
      'elements': instance.elements.map((e) => e.toJson()).toList(),
    };

TodoElement _$TodoElementFromJson(Map<String, dynamic> json) => TodoElement(
      name: json['name'] as String,
      completed: json['completed'] as bool? ?? false,
    );

Map<String, dynamic> _$TodoElementToJson(TodoElement instance) =>
    <String, dynamic>{
      'name': instance.name,
      'completed': instance.completed,
    };
