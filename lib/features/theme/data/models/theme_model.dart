import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:habit_tracker/core/error/exceptions.dart';
import '../../domain/entities/theme_entity.dart';

class ThemeModel extends ThemeEntity {
  const ThemeModel({
    required super.themeName,
    required super.themeMode,
    required super.useCustomBackground,
    super.customBackgroundColor,
  });

  factory ThemeModel.empty() {
    return const ThemeModel(
      themeName: ThemeEntity.defaultTheme,
      themeMode: ThemeMode.dark,
      useCustomBackground: false,
      customBackgroundColor: null,
    );
  }

  factory ThemeModel.fromEntity(ThemeEntity entity) {
    return ThemeModel(
      themeName: entity.themeName,
      themeMode: entity.themeMode,
      useCustomBackground: entity.useCustomBackground,
      customBackgroundColor: entity.customBackgroundColor,
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

  static Color? _parseColor(dynamic val) {
    if (val == null) return null;
    if (val is Color) return val;
    if (val is int) return Color(val);
    if (val is num) return Color(val.toInt());
    if (val is String) {
      final trimmed = val.trim();
      final directInt = int.tryParse(trimmed);
      if (directInt != null) return Color(directInt);
      if (trimmed.startsWith('#')) {
        final hex = trimmed.substring(1);
        final parsed = int.tryParse(hex, radix: 16);
        if (parsed != null) {
          return Color(hex.length == 6 ? (0xFF000000 | parsed) : parsed);
        }
      }
    }
    return null;
  }

  static ThemeMode _parseThemeMode(dynamic mode) {
    if (mode == null) return ThemeMode.system;
    if (mode is ThemeMode) return mode;
    if (mode is int) {
      if (mode >= 0 && mode < ThemeMode.values.length) {
        return ThemeMode.values[mode];
      }
    } else if (mode is String) {
      final lower = mode.toLowerCase();
      if (lower.contains('dark')) return ThemeMode.dark;
      if (lower.contains('light')) return ThemeMode.light;
      if (lower.contains('system')) return ThemeMode.system;
    }
    return ThemeMode.system;
  }

  factory ThemeModel.fromJson(Map<dynamic, dynamic>? json) {
    if (json == null) {
      return ThemeModel.empty();
    }

    try {
      final name = _parseString(
        json['themeName'],
        fallback: ThemeEntity.defaultTheme,
      );
      final mode = _parseThemeMode(json['themeMode']);
      final useCustom = _parseBool(json['useCustomBg'], fallback: false);
      final bgColor = _parseColor(json['customBgColor']);

      return ThemeModel(
        themeName: name,
        themeMode: mode,
        useCustomBackground: useCustom,
        customBackgroundColor: bgColor,
      );
    } catch (e) {
      throw ParsingException('Failed to parse ThemeModel: $e');
    }
  }

  factory ThemeModel.fromJsonString(String jsonStr) {
    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is Map) {
        return ThemeModel.fromJson(decoded);
      }
      throw const ParsingException('Expected Map in ThemeModel JSON');
    } on FormatException catch (e) {
      throw ParsingException('Corrupted ThemeModel JSON: ${e.message}');
    }
  }

  static ThemeModel? tryParseJson(String? jsonStr) {
    if (jsonStr == null || jsonStr.trim().isEmpty) return null;
    try {
      return ThemeModel.fromJsonString(jsonStr);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'themeName': themeName,
      'themeMode': themeMode.index,
      'useCustomBg': useCustomBackground,
      'customBgColor': customBackgroundColor?.toARGB32(),
    };
  }

  String toJsonString() => jsonEncode(toJson());
}
