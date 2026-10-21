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

  static String _parseString(dynamic value, {required String fallback}) {
    if (value == null) return fallback;
    final str = value.toString().trim();
    return str.isEmpty ? fallback : str;
  }

  static bool _parseBool(dynamic value, {required bool fallback}) {
    if (value == null) return fallback;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final lower = value.trim().toLowerCase();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    return fallback;
  }

  static int? _parseInt(dynamic value, {int? fallback}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? fallback;
    }
    return fallback;
  }

  static DateTime _parseDate(dynamic dateData, {DateTime? fallback}) {
    if (dateData == null) return fallback ?? DateTime.now();
    if (dateData is Timestamp) return dateData.toDate();
    if (dateData is DateTime) return dateData;
    if (dateData is String) {
      final parsed = DateTime.tryParse(dateData);
      if (parsed != null) return parsed;
    }
    return fallback ?? DateTime.now();
  }

  factory HabitModel.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) {
      final now = DateTime.now();
      return HabitModel(
        id: '',
        name: 'Unnamed Habit',
        isCompleted: false,
        createdAt: now,
      );
    }

    return HabitModel(
      id: _parseString(map['id'], fallback: ''),
      name: _parseString(map['name'], fallback: 'Unnamed Habit'),
      isCompleted: _parseBool(
        map['isCompleted'] ?? map['is_completed'],
        fallback: false,
      ),
      createdAt: _parseDate(map['createdAt'] ?? map['created_at']),
      completedAt: (map['completedAt'] != null || map['completed_at'] != null)
          ? _parseDate(map['completedAt'] ?? map['completed_at'])
          : null,
      colorValue: _parseInt(map['colorValue'] ?? map['color_value']),
      index: _parseInt(map['index'], fallback: 0) ?? 0,
      updatedAt: (map['updatedAt'] != null || map['updated_at'] != null)
          ? _parseDate(map['updatedAt'] ?? map['updated_at'])
          : null,
    );
  }

  // Modern Firestore-specific factory with safe parsing
  factory HabitModel.fromFirestore(DocumentSnapshot doc) {
    final rawData = doc.data();
    final map = rawData is Map<String, dynamic> ? rawData : <String, dynamic>{};

    return HabitModel(
      id: doc.id,
      name: _parseString(map['name'], fallback: 'Unnamed Habit'),
      isCompleted: _parseBool(map['isCompleted'], fallback: false),
      createdAt: _parseDate(map['createdAt']),
      completedAt:
          map['completedAt'] != null ? _parseDate(map['completedAt']) : null,
      colorValue: _parseInt(map['colorValue']),
      index: _parseInt(map['index'], fallback: 0) ?? 0,
      updatedAt:
          map['updatedAt'] != null ? _parseDate(map['updatedAt']) : null,
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
      'updatedAt': FieldValue.serverTimestamp(),
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

  // Deprecated: Used for migration from old list format with safety bounds
  factory HabitModel.fromLocalFormat(List<dynamic> data) {
    final name = data.isNotEmpty ? data[0]?.toString() ?? 'Unnamed Habit' : 'Unnamed Habit';
    final isCompleted = data.length > 1 ? _parseBool(data[1], fallback: false) : false;

    return HabitModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      isCompleted: isCompleted,
      createdAt: DateTime.now(),
    );
  }
}
