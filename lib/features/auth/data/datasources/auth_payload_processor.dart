import 'package:flutter/foundation.dart';
import '../models/auth_model.dart';

/// Top-level worker for background Isolate execution.
AuthModel _parseAuthModelWorker(Map<String, dynamic> json) {
  return AuthModel.fromJson(json);
}

Map<String, dynamic> _serializeAuthModelWorker(AuthModel model) {
  return model.toJson();
}

/// Helper service that offloads Auth JSON parsing and serialization to an Isolate.
class AuthPayloadProcessor {
  AuthPayloadProcessor._();

  /// Offloads AuthModel deserialization to background Isolate via [compute].
  static Future<AuthModel> parseAuthModel(Map<String, dynamic> json) {
    return compute(_parseAuthModelWorker, json);
  }

  /// Offloads AuthModel serialization to background Isolate via [compute].
  static Future<Map<String, dynamic>> serializeAuthModel(AuthModel model) {
    return compute(_serializeAuthModelWorker, model);
  }
}
