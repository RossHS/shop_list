import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

part 'todo_model.g.dart';

/// Модель данных TodoModel из коллекции firestore todos
@JsonSerializable(explicitToJson: true)
class TodoModel {
  TodoModel({
    required this.authorId,
    required this.title,
    this.isPublic = false,
    int? createdTimestamp,
    this.completed = false,
    this.completedTimestamp = 0,
    List<TodoElement>? elements,
  })  : assert(createdTimestamp == null || createdTimestamp > 0, 'incorrect createdTimestamp $createdTimestamp'),
        createdTimestamp = createdTimestamp ?? DateTime.now().millisecondsSinceEpoch,
        elements = elements ?? <TodoElement>[];

  final String authorId;
  final String title;
  final bool isPublic;
  final int createdTimestamp;
  final bool completed;
  final int completedTimestamp;
  final List<TodoElement> elements;

  factory TodoModel.fromJson(Map<String, dynamic> json) => _$TodoModelFromJson(json);

  Map<String, dynamic> toJson() => _$TodoModelToJson(this);

  TodoModel copyWith({
    String? authorId,
    String? title,
    bool? isPublic,
    int? createdTimestamp,
    bool? completed,
    int? completedTimestamp,
    List<TodoElement>? elements,
  }) {
    return TodoModel(
      authorId: authorId ?? this.authorId,
      title: title ?? this.title,
      isPublic: isPublic ?? this.isPublic,
      createdTimestamp: createdTimestamp ?? this.createdTimestamp,
      completed: completed ?? this.completed,
      completedTimestamp: completedTimestamp ?? this.completedTimestamp,
      elements: elements ?? [...this.elements],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoModel &&
          runtimeType == other.runtimeType &&
          authorId == other.authorId &&
          title == other.title &&
          isPublic == other.isPublic &&
          createdTimestamp == other.createdTimestamp &&
          completed == other.completed &&
          completedTimestamp == other.completedTimestamp &&
          const ListEquality().equals(elements, other.elements);

  @override
  int get hashCode =>
      Object.hashAll([authorId, title, isPublic, createdTimestamp, completed, completedTimestamp, hashList(elements)]);
}

/// Элемент в списке дел
@JsonSerializable()
class TodoElement {
  TodoElement({
    required this.name,
    this.completed = false,
  });

  final String name;
  final bool completed;

  factory TodoElement.fromJson(Map<String, dynamic> json) => _$TodoElementFromJson(json);

  Map<String, dynamic> toJson() => _$TodoElementToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoElement && runtimeType == other.runtimeType && name == other.name && completed == other.completed;

  @override
  int get hashCode => Object.hashAll([name, completed]);
}
