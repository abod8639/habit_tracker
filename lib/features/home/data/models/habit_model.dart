import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/habit_entity.dart';

@HiveType(typeId: 0)
class HabitModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final bool isCompleted;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final DateTime? completedAt;

  @HiveField(5)
  final int? colorValue;

  @HiveField(6)
  final int? index;

  @HiveField(7)
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

class HabitModelAdapter extends TypeAdapter<HabitModel> {
  @override
  final int typeId = 0;

  @override
  HabitModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitModel(
      id: fields[0] as String,
      name: fields[1] as String,
      isCompleted: fields[2] as bool,
      createdAt: fields[3] as DateTime,
      completedAt: fields[4] as DateTime?,
      colorValue: fields[5] as int?,
      index: fields[6] as int?,
      updatedAt: numOfFields > 7 ? fields[7] as DateTime? : null,
    );
  }

  @override
  void write(BinaryWriter writer, HabitModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.isCompleted)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.completedAt)
      ..writeByte(5)
      ..write(obj.colorValue)
      ..writeByte(6)
      ..write(obj.index)
      ..writeByte(7)
      ..write(obj.updatedAt);
  }
}
