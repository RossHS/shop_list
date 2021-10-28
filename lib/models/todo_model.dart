import 'package:json_annotation/json_annotation.dart';

part 'todo_model.g.dart';

/// Модель данных TodoModel из коллекции firestore todos
@JsonSerializable()
class TodoModel {
  TodoModel({
    required this.authorId,
    required this.title,
    this.isPublic = false,
    int? createdTimestamp,
    this.completed = false,
    this.completedTimestamp = 0,
  })  : assert(createdTimestamp == null || createdTimestamp > 0, 'incorrect createdTimestamp $createdTimestamp'),
        createdTimestamp = createdTimestamp ?? DateTime.now().millisecondsSinceEpoch;

  final String authorId;
  final String title;
  final bool isPublic;
  final int createdTimestamp;
  final bool completed;
  final int completedTimestamp;

  factory TodoModel.fromJson(Map<String, dynamic> json) => _$TodoModelFromJson(json);

  Map<String, dynamic> toJson() => _$TodoModelToJson(this);

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
          completedTimestamp == other.completedTimestamp;

  @override
  int get hashCode => Object.hashAll([authorId, title, isPublic, createdTimestamp, completed, completedTimestamp]);
}
