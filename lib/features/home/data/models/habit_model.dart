import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/habit_entity.dart';

class HabitModel {
  final String id;
  final String name;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int? colorValue;
  final int? index;
  final DateTime? updatedAt;

  const HabitModel({
    required this.id,
    required this.name,
    required this.isCompleted,
    required this.createdAt,
    this.completedAt,
    this.colorValue,
    this.index,
    this.updatedAt,
  });

  static DateTime _parseDate(dynamic dateData, {DateTime? fallback}) {
    if (dateData == null) return fallback ?? DateTime.now();
    if (dateData is Timestamp) return dateData.toDate();
    if (dateData is String) {
      try {
        return DateTime.parse(dateData);
      } catch (e) {
        return fallback ?? DateTime.now();
      }
    }
    return fallback ?? DateTime.now();
  }

  factory HabitModel.fromMap(Map<String, dynamic> map) {
    return HabitModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Unnamed Habit',
      isCompleted: map['isCompleted'] ?? map['is_completed'] ?? false,
      createdAt: _parseDate(map['createdAt'] ?? map['created_at']),
      completedAt: map['completedAt'] != null || map['completed_at'] != null
          ? _parseDate(map['completedAt'] ?? map['completed_at'])
          : null,
      colorValue: map['colorValue'] ?? map['color_value'],
      index: map['index'] ?? 0,
      updatedAt: map['updatedAt'] != null || map['updated_at'] != null
          ? _parseDate(map['updatedAt'] ?? map['updated_at'])
          : null,
    );
  }

  // Modern Firestore-specific factory
  factory HabitModel.fromFirestore(DocumentSnapshot doc) {
    final map = doc.data() as Map<String, dynamic>? ?? {};
    return HabitModel(
      id: doc.id,
      name: map['name']?.toString() ?? 'Unnamed Habit',
      isCompleted: map['isCompleted'] ?? false,
      createdAt: _parseDate(map['createdAt']),
      completedAt: map['completedAt'] != null
          ? _parseDate(map['completedAt'])
          : null,
      colorValue: map['colorValue'] as int?,
      index: map['index'] as int? ?? 0,
      updatedAt: map['updatedAt'] != null ? _parseDate(map['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'colorValue': colorValue,
      'index': index,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Professional Firestore map conversion
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
      'colorValue': colorValue,
      'index': index,
      'updatedAt':
          FieldValue.serverTimestamp(), // Always use server time for updates
    };
  }

  HabitEntity toEntity() {
    return HabitEntity(
      id: id,
      name: name,
      isCompleted: isCompleted,
      createdAt: createdAt,
      completedAt: completedAt,
      colorValue: colorValue,
      index: index,
      updatedAt: updatedAt,
    );
  }

  factory HabitModel.fromEntity(HabitEntity entity) {
    return HabitModel(
      id: entity.id,
      name: entity.name,
      isCompleted: entity.isCompleted,
      createdAt: entity.createdAt,
      completedAt: entity.completedAt,
      colorValue: entity.colorValue,
      index: entity.index,
      updatedAt: entity.updatedAt,
    );
  }

  // Deprecated: Used for migration from old list format
  factory HabitModel.fromLocalFormat(List<dynamic> data) {
    return HabitModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: data[0],
      isCompleted: data[1],
      createdAt: DateTime.now(),
    );
  }
}
