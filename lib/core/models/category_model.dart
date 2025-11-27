import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 2)
class CategoryModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? description;

  @HiveField(3)
  int colorIndex; // Index to map to a predefined color

  @HiveField(4)
  String? icon; // Icon name or emoji

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime? updatedAt;

  @HiveField(7)
  bool isDefault; // System default categories can't be deleted

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.colorIndex = 0,
    this.icon,
    required this.createdAt,
    this.updatedAt,
    this.isDefault = false,
  });

  // Copy with method
  CategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    int? colorIndex,
    String? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDefault,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      colorIndex: colorIndex ?? this.colorIndex,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'colorIndex': colorIndex,
      'icon': icon,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isDefault': isDefault,
    };
  }

  // Create from JSON
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      colorIndex: json['colorIndex'] ?? 0,
      icon: json['icon'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      isDefault: json['isDefault'] ?? false,
    );
  }

  @override
  String toString() {
    return 'CategoryModel(id: $id, name: $name, isDefault: $isDefault)';
  }
}
