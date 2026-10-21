import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:habit_tracker/core/error/exceptions.dart';
import '../../domain/entities/setting_entity.dart';

class SettingModel extends SettingEntity {
  const SettingModel({
    required super.languageCode,
    required super.isNotificationEnabled,
    super.notificationTime,
  });

  factory SettingModel.empty() {
    return const SettingModel(
      languageCode: SettingEntity.defaultLanguage,
      isNotificationEnabled: false,
      notificationTime: null,
    );
  }

  factory SettingModel.fromEntity(SettingEntity entity) {
    return SettingModel(
      languageCode: entity.languageCode,
      isNotificationEnabled: entity.isNotificationEnabled,
      notificationTime: entity.notificationTime,
    );
  }

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

  static TimeOfDay? _parseTimeOfDay(dynamic val) {
    if (val == null) return null;
    if (val is TimeOfDay) return val;
    if (val is String) {
      final trimmed = val.trim();
      final parts = trimmed.split(':');
      if (parts.length >= 2) {
        final h = int.tryParse(parts[0].trim());
        final m = int.tryParse(parts[1].trim());
        if (h != null && m != null && h >= 0 && h < 24 && m >= 0 && m < 60) {
          return TimeOfDay(hour: h, minute: m);
        }
      }
    }
    return null;
  }

  factory SettingModel.fromJson(Map<dynamic, dynamic>? json) {
    if (json == null) {
      return SettingModel.empty();
    }

    try {
      final language = _parseString(
        json['languageCode'],
        fallback: SettingEntity.defaultLanguage,
      );
      final isNotificationEnabled = _parseBool(
        json['isNotificationEnabled'],
        fallback: false,
      );
      final time = _parseTimeOfDay(json['notificationTime']);

      return SettingModel(
        languageCode: language,
        isNotificationEnabled: isNotificationEnabled,
        notificationTime: time,
      );
    } catch (e) {
      throw ParsingException('Failed to parse SettingModel: $e');
    }
  }

  factory SettingModel.fromJsonString(String jsonStr) {
    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is Map) {
        return SettingModel.fromJson(decoded);
      }
      throw const ParsingException('Expected Map in SettingModel JSON');
    } on FormatException catch (e) {
      throw ParsingException('Corrupted SettingModel JSON: ${e.message}');
    }
  }

  static SettingModel? tryParseJson(String? jsonStr) {
    if (jsonStr == null || jsonStr.trim().isEmpty) return null;
    try {
      return SettingModel.fromJsonString(jsonStr);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'languageCode': languageCode,
      'isNotificationEnabled': isNotificationEnabled,
      'notificationTime': notificationTime != null
          ? '${notificationTime!.hour}:${notificationTime!.minute}'
          : null,
    };
  }

  String toJsonString() => jsonEncode(toJson());
}
