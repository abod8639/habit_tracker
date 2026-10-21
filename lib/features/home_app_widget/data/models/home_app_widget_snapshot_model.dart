import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habit_tracker/core/error/exceptions.dart';
import 'package:habit_tracker/features/home/data/models/habit_model.dart';
import '../../domain/entities/home_app_widget_data_entity.dart';

/// Serializable data model for storing and restoring Home App Widget snapshot data
/// with defensive, safe parsing for zero-crash resilience against corrupted payloads.
class HomeAppWidgetSnapshotModel {
  final List<HabitModel> uncompletedHabits;
  final Map<DateTime, int> heatmapDatasets;
  final int totalCount;
  final int completedCount;
  final DateTime lastUpdated;

  const HomeAppWidgetSnapshotModel({
    required this.uncompletedHabits,
    required this.heatmapDatasets,
    required this.totalCount,
    required this.completedCount,
    required this.lastUpdated,
  });

  /// Factory providing safe, uninitialized fallback state to prevent NullPointer exceptions.
  factory HomeAppWidgetSnapshotModel.empty() {
    return HomeAppWidgetSnapshotModel(
      uncompletedHabits: const [],
      heatmapDatasets: const {},
      totalCount: 0,
      completedCount: 0,
      lastUpdated: DateTime.now(),
    );
  }

  static String _parseString(dynamic value, {required String fallback}) {
    if (value == null) return fallback;
    final str = value.toString().trim();
    return str.isEmpty ? fallback : str;
  }

  static int _parseInt(dynamic value, {int fallback = 0}) {
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

  factory HomeAppWidgetSnapshotModel.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) {
      return HomeAppWidgetSnapshotModel.empty();
    }

    try {
      final rawHabits = map['uncompletedHabits'] as List? ?? [];
      final List<HabitModel> parsedHabits = [];
      for (final item in rawHabits) {
        try {
          if (item is HabitModel) {
            parsedHabits.add(item);
          } else if (item is Map) {
            parsedHabits.add(
              HabitModel.fromMap(Map<String, dynamic>.from(item)),
            );
          } else if (item is List) {
            parsedHabits.add(HabitModel.fromLocalFormat(item));
          }
        } catch (_) {
          // Gracefully skip corrupted habit items without failing the entire snapshot
        }
      }

      final rawHeatmap = map['heatmapDatasets'] as Map? ?? {};
      final Map<DateTime, int> parsedHeatmap = {};
      for (final entry in rawHeatmap.entries) {
        try {
          final key = entry.key;
          final value = _parseInt(entry.value, fallback: 0);
          if (key is DateTime) {
            parsedHeatmap[key] = value;
          } else if (key is String) {
            final parsedDate = DateTime.tryParse(key);
            if (parsedDate != null) {
              parsedHeatmap[parsedDate] = value;
            }
          }
        } catch (_) {
          // Gracefully skip corrupted heatmap entries
        }
      }

      final lastUpdatedRaw = map['lastUpdated'];
      final lastUpdated = _parseDate(
        lastUpdatedRaw is String
            ? _parseString(lastUpdatedRaw, fallback: '')
            : lastUpdatedRaw,
      );

      return HomeAppWidgetSnapshotModel(
        uncompletedHabits: parsedHabits,
        heatmapDatasets: parsedHeatmap,
        totalCount: _parseInt(map['totalCount'], fallback: parsedHabits.length),
        completedCount: _parseInt(map['completedCount'], fallback: 0),
        lastUpdated: lastUpdated,
      );
    } catch (e) {
      throw ParsingException(
        'Failed to parse HomeAppWidgetSnapshotModel: ${e.toString()}',
      );
    }
  }

  factory HomeAppWidgetSnapshotModel.fromJson(String jsonStr) {
    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is Map) {
        return HomeAppWidgetSnapshotModel.fromMap(decoded);
      }
      throw const ParsingException(
        'Expected Map root object in HomeAppWidgetSnapshotModel JSON',
      );
    } on FormatException catch (e) {
      throw ParsingException('Corrupted JSON string: ${e.message}');
    }
  }

  static HomeAppWidgetSnapshotModel? tryParseJson(String? jsonStr) {
    if (jsonStr == null || jsonStr.trim().isEmpty) return null;
    try {
      return HomeAppWidgetSnapshotModel.fromJson(jsonStr);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'uncompletedHabits': uncompletedHabits.map((h) => h.toMap()).toList(),
      'heatmapDatasets': {
        for (final entry in heatmapDatasets.entries)
          entry.key.toIso8601String(): entry.value,
      },
      'totalCount': totalCount,
      'completedCount': completedCount,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  String toJson() => jsonEncode(toMap());

  factory HomeAppWidgetSnapshotModel.fromEntity(HomeAppWidgetDataEntity entity) {
    return HomeAppWidgetSnapshotModel(
      uncompletedHabits: entity.uncompletedHabits
          .map((e) => HabitModel.fromEntity(e))
          .toList(),
      heatmapDatasets: Map<DateTime, int>.from(entity.heatmapDatasets),
      totalCount: entity.totalCount,
      completedCount: entity.completedCount,
      lastUpdated: entity.lastUpdated,
    );
  }

  HomeAppWidgetDataEntity toEntity() {
    return HomeAppWidgetDataEntity(
      uncompletedHabits: uncompletedHabits.map((m) => m.toEntity()).toList(),
      heatmapDatasets: Map<DateTime, int>.from(heatmapDatasets),
      totalCount: totalCount,
      completedCount: completedCount,
      lastUpdated: lastUpdated,
    );
  }
}
