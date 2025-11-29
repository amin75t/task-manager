import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime? updatedAt;

  @HiveField(5)
  bool isCompleted;

  @HiveField(6)
  DateTime? completedAt;

  @HiveField(7)
  TaskPriority priority;

  @HiveField(8)
  DateTime? dueDate;

  @HiveField(9)
  String? category;

  @HiveField(10)
  List<String>? tags;

  @HiveField(11)
  int? time; // Estimated time in minutes

  @HiveField(12)
  bool withAiFlag; // Flag indicating if task was created with AI

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
    this.updatedAt,
    this.isCompleted = false,
    this.completedAt,
    this.priority = TaskPriority.medium,
    this.dueDate,
    this.category,
    this.tags,
    this.time,
    this.withAiFlag = false,
  });

  // Copy with method for easy updates
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isCompleted,
    DateTime? completedAt,
    TaskPriority? priority,
    DateTime? dueDate,
    String? category,
    List<String>? tags,
    int? time,
    bool? withAiFlag,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      time: time ?? this.time,
      withAiFlag: withAiFlag ?? this.withAiFlag,
    );
  }

  // Convert to JSON (for backup/export)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'priority': priority.name,
      'dueDate': dueDate?.toIso8601String(),
      'category': category,
      'tags': tags,
      'time': time,
      'withAiFlag': withAiFlag,
    };
  }

  // Convert to API format (for server requests)
  Map<String, dynamic> toApiJson() {
    return {
      'title': title,
      'description': description ?? '',
      'proprietary': _priorityToApi(priority),
      'tags': tags ?? [],
      'time': time ?? 0,
      'deadline': dueDate?.toIso8601String(),
      'with_ai_flag': withAiFlag,
    };
  }

  // Map priority enum to API format
  static String _priorityToApi(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }

  // Map API priority string to enum
  static TaskPriority _priorityFromApi(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'low':
        return TaskPriority.low;
      case 'medium':
        return TaskPriority.medium;
      case 'high':
        return TaskPriority.high;
      case 'urgent':
        return TaskPriority.urgent;
      default:
        return TaskPriority.medium;
    }
  }

  // Create from JSON (for restore/import)
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    // Handle both String and int for ID (server returns int, local uses String)
    String parseId(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is int) return value.toString();
      return value.toString();
    }

    // Handle both created_at and createdAt formats
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          print('Error parsing date: $value');
          return null;
        }
      }
      return null;
    }

    return TaskModel(
      id: parseId(json['id']),
      title: json['title'] ?? '',
      description: json['description'],
      createdAt: parseDateTime(json['createdAt'] ?? json['created_at']) ?? DateTime.now(),
      updatedAt: parseDateTime(json['updatedAt'] ?? json['updated_at']),
      isCompleted: json['isCompleted'] ?? json['is_completed'] ?? false,
      completedAt: parseDateTime(json['completedAt'] ?? json['completed_at']),
      priority: json['priority'] != null
          ? TaskPriority.values.firstWhere(
              (e) => e.name == json['priority'],
              orElse: () => TaskPriority.medium,
            )
          : _priorityFromApi(json['proprietary']),
      dueDate: parseDateTime(json['dueDate'] ?? json['deadline']),
      category: json['category'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      time: json['time'] is int ? json['time'] : null,
      withAiFlag: json['withAiFlag'] ?? json['with_ai_flag'] ?? false,
    );
  }

  @override
  String toString() {
    return 'TaskModel(id: $id, title: $title, isCompleted: $isCompleted, priority: $priority)';
  }
}

@HiveType(typeId: 1)
enum TaskPriority {
  @HiveField(0)
  low,

  @HiveField(1)
  medium,

  @HiveField(2)
  high,

  @HiveField(3)
  urgent,
}
