import 'package:hive/hive.dart';

part 'tag_model.g.dart';

@HiveType(typeId: 3)
class TagModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? description;

  @HiveField(3)
  int colorIndex; // Index to map to a predefined color

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime? updatedAt;

  @HiveField(6)
  int usageCount; // Track how many tasks use this tag

  TagModel({
    required this.id,
    required this.name,
    this.description,
    this.colorIndex = 0,
    required this.createdAt,
    this.updatedAt,
    this.usageCount = 0,
  });

  // Copy with method
  TagModel copyWith({
    String? id,
    String? name,
    String? description,
    int? colorIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? usageCount,
  }) {
    return TagModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      colorIndex: colorIndex ?? this.colorIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      usageCount: usageCount ?? this.usageCount,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'colorIndex': colorIndex,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'usageCount': usageCount,
    };
  }

  // Create from JSON
  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      colorIndex: json['colorIndex'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      usageCount: json['usageCount'] ?? 0,
    );
  }

  @override
  String toString() {
    return 'TagModel(id: $id, name: $name, usageCount: $usageCount)';
  }
}
