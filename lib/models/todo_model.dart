import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'todo_model.g.dart';

/// Модель данных TodoModel из коллекции firestore todos
@JsonSerializable(explicitToJson: true)
@immutable
class TodoModel {
  TodoModel({
    required this.authorId,
    required this.title,
    this.isPublic = false,
    int? createdTimestamp,
    this.completed = false,
    this.completedAuthorId = '',
    this.completedTimestamp = 0,
    List<TodoElement>? elements,
  })  : assert(createdTimestamp == null || createdTimestamp > 0, 'incorrect createdTimestamp $createdTimestamp'),
        createdTimestamp = createdTimestamp ?? DateTime.now().millisecondsSinceEpoch,
        elements = elements ?? <TodoElement>[];

  factory TodoModel.fromJson(Map<String, dynamic> json) => _$TodoModelFromJson(json);

  final String authorId;
  final String title;
  final bool isPublic;
  final int createdTimestamp;
  final bool completed;
  final String completedAuthorId;
  final int completedTimestamp;
  final List<TodoElement> elements;

  Map<String, dynamic> toJson() => _$TodoModelToJson(this);

  TodoModel copyWith({
    String? authorId,
    String? title,
    bool? isPublic,
    int? createdTimestamp,
    bool? completed,
    String? completedAuthorId,
    int? completedTimestamp,
    List<TodoElement>? elements,
  }) {
    return TodoModel(
      authorId: authorId ?? this.authorId,
      title: title ?? this.title,
      isPublic: isPublic ?? this.isPublic,
      createdTimestamp: createdTimestamp ?? this.createdTimestamp,
      completed: completed ?? this.completed,
      completedAuthorId: completedAuthorId ?? this.completedAuthorId,
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
  int get hashCode => Object.hashAll([
        authorId,
        title,
        isPublic,
        createdTimestamp,
        completed,
        completedTimestamp,
        Object.hashAll(elements),
      ]);
}

/// Элемент в списке дел
@JsonSerializable()
@immutable
class TodoElement {
  TodoElement({
    required this.name,
    this.completed = false,
    String? uid,
  }) : uid = uid ?? const Uuid().v4();

  factory TodoElement.fromJson(Map<String, dynamic> json) => _$TodoElementFromJson(json);

  final String name;
  final bool completed;

  /// UID для работы с одинаковыми элементами в рамках одного списка дел
  final String uid;

  Map<String, dynamic> toJson() => _$TodoElementToJson(this);

  TodoElement copyWith({
    String? name,
    bool? completed,
    String? uid,
  }) {
    return TodoElement(
      name: name ?? this.name,
      completed: completed ?? this.completed,
      uid: uid ?? this.uid,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoElement &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          completed == other.completed &&
          uid == other.uid;

  @override
  int get hashCode => Object.hashAll([name, completed, uid]);
}

/// Класс обертка над обычным [TodoModel], но содержащий ссылку на документ firestore,
/// по которой находится TodoModel. Необходим чтобы совершать операции обновления,
/// удаления существующих записей
@immutable
class FirestoreRefTodoModel {
  const FirestoreRefTodoModel({
    required this.idRef,
    required this.todoModel,
  });

  /// Id документа в коллекции списка дел Todos
  final String idRef;

  /// Модель списка дел
  final TodoModel todoModel;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FirestoreRefTodoModel &&
          runtimeType == other.runtimeType &&
          todoModel == other.todoModel &&
          idRef == other.idRef;

  @override
  int get hashCode => Object.hashAll([idRef, todoModel]);
}
