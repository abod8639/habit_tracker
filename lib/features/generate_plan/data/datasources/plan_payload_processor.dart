import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/plan_suggestion_model.dart';

/// Top-level worker function executed in an isolated background thread via [compute]
/// to prevent UI freezing (jank) during JSON decoding and model mapping.
List<PlanSuggestionModel> _parsePlanPayloadWorker(String rawJson) {
  String cleaned = rawJson
      .replaceAll(RegExp(r'```json\s*'), '')
      .replaceAll(RegExp(r'```\s*'), '')
      .trim();

  final start = cleaned.indexOf('[');
  final end = cleaned.lastIndexOf(']');

  if (start != -1 && end != -1 && end >= start) {
    cleaned = cleaned.substring(start, end + 1);
  }

  final dynamic decoded = json.decode(cleaned);
  if (decoded is! List || decoded.isEmpty) {
    throw const FormatException('AI returned an empty habit list.');
  }

  final list = <PlanSuggestionModel>[];
  for (final item in decoded) {
    if (item is Map) {
      try {
        final map = Map<String, dynamic>.from(item);
        final suggestion = PlanSuggestionModel.fromJson(map);
        if (suggestion.name.trim().isNotEmpty) {
          list.add(suggestion);
        }
      } catch (_) {
        // Skip corrupted individual suggestions without failing the entire plan
      }
    }
  }

  if (list.isEmpty) {
    throw const FormatException('No valid habits parsed from response.');
  }

  return list;
}

/// Service to offload heavy JSON payload parsing of AI responses to a background Isolate.
class PlanPayloadProcessor {
  PlanPayloadProcessor._();

  /// Offloads parsing of Gemini response text to a background isolate.
  static Future<List<PlanSuggestionModel>> parsePlanResponse(String responseText) {
    if (responseText.trim().isEmpty) {
      return Future.error(const FormatException('AI response was empty.'));
    }
    return compute(_parsePlanPayloadWorker, responseText);
  }
}
