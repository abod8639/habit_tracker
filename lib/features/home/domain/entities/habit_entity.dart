import 'package:equatable/equatable.dart';

class HabitEntity extends Equatable {
  final String id;
  final String name;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int? colorValue;
  final int? index;
  final DateTime? updatedAt;

  const HabitEntity({
    required this.id,
    required this.name,
    required this.isCompleted,
    required this.createdAt,
    this.completedAt,
    this.colorValue,
    this.index,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    isCompleted,
    createdAt,
    completedAt,
    colorValue,
    index,
    updatedAt,
  ];

  HabitEntity copyWith({
    String? id,
    String? name,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
    int? colorValue,
    int? index,
    DateTime? updatedAt,
  }) {
    return HabitEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      colorValue: colorValue ?? this.colorValue,
      index: index ?? this.index,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
