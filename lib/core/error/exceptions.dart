class ServerException implements Exception {
  final String message;
  const ServerException(this.message);

  @override
  String toString() => message;
}

class CacheException implements Exception {
  final String message;
  const CacheException(this.message);

  @override
  String toString() => message;
}

class NetworkException implements Exception {
  final String? message;
  const NetworkException([this.message]);
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

class TimeoutAppException implements Exception {
  final String message;
  const TimeoutAppException([this.message = 'Operation timed out']);

  @override
  String toString() => message;
}

class ParsingException implements Exception {
  final String message;
  const ParsingException([this.message = 'Failed to process data payload']);

  @override
  String toString() => message;
}

