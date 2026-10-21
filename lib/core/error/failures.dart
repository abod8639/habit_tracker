sealed class Failure {
  final String message;
  const Failure(this.message);

  String toMessage() => message;

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No Internet Connection']);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Connection timed out. Please try again.']);
}

class ParsingFailure extends Failure {
  const ParsingFailure([super.message = 'Failed to process response data.']);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

