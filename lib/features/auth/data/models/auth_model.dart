import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/auth_entity.dart';

/// Data model representing authenticated user credentials with defensive parsing
/// and safe fallback values.
class AuthModel extends AuthEntity {
  const AuthModel({
    required super.uid,
    super.email,
    super.displayName,
    super.photoUrl,
  });

  /// Safely creates an [AuthModel] from a Firebase [User] instance.
  factory AuthModel.fromFirebaseUser(User user) {
    return AuthModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  /// Defensive JSON deserializer with guaranteed non-null fallbacks preventing TypeErrors.
  factory AuthModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AuthModel(uid: '');
    }

    return AuthModel(
      uid: _parseString(json['uid']),
      email: _parseNullableString(json['email']),
      displayName: _parseNullableString(json['displayName']),
      photoUrl: _parseNullableString(json['photoUrl']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
    };
  }

  static String _parseString(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  static String? _parseNullableString(dynamic value) {
    if (value == null) return null;
    final str = value.toString().trim();
    return str.isEmpty ? null : str;
  }
}
