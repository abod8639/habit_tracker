import 'dart:async';
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:habit_tracker/core/services/gemini_service.dart';
import 'exceptions.dart';
import 'failures.dart';

/// Centralized error handler and mapper for network, service, and data operations.
/// Prevents unhandled exceptions, converts low-level system errors to user-safe [Failure]s,
/// and eliminates duplicated try-catch boilerplate across repositories.
class NetworkErrorHandler {
  NetworkErrorHandler._();

  /// Centralized mapping of any caught exception/error into an architectural [Failure]
  static Failure handle(Object error, [StackTrace? stackTrace]) {
    if (kDebugMode && stackTrace != null) {
      debugPrint('[NetworkErrorHandler] Caught error: $error\n$stackTrace');
    }

    if (error is Failure) {
      return error;
    }

    if (error is SocketException) {
      return const NetworkFailure('No Internet Connection. Please check your network.');
    }

    if (error is TimeoutException || error is TimeoutAppException) {
      return const TimeoutFailure('Request timed out. Please check your connection and try again.');
    }

    if (error is FormatException || error is ParsingException) {
      return const ParsingFailure('Invalid or corrupted data payload.');
    }

    if (error is NetworkException) {
      return NetworkFailure(error.message ?? 'Network connection error');
    }

    if (error is CacheException) {
      return CacheFailure(error.message);
    }

    if (error is AuthException) {
      return AuthFailure(error.message);
    }

    if (error is ServerException) {
      return ServerFailure(error.message);
    }

    if (error is GeminiException) {
      return ServerFailure(error.message);
    }

    final errorStr = error.toString().toLowerCase();
    if (errorStr.contains('socket') ||
        errorStr.contains('network') ||
        errorStr.contains('connection refused') ||
        errorStr.contains('failed host lookup') ||
        errorStr.contains('clientexception')) {
      return const NetworkFailure('Unable to connect to server. Please check your connection.');
    }

    if (errorStr.contains('timeout') || errorStr.contains('timed out')) {
      return const TimeoutFailure('Connection timed out. Please try again.');
    }

    if (errorStr.contains('quota') ||
        errorStr.contains('limit') ||
        errorStr.contains('429') ||
        errorStr.contains('resource exhausted')) {
      return const ServerFailure('Service rate limit reached. Please wait a moment and try again.');
    }

    return ServerFailure(GeminiService.getErrorMessage(error));
  }

  /// Guards a Future action and maps any thrown exception to [Left(Failure)]
  static Future<Either<Failure, T>> guard<T>(
    Future<T> Function() action,
  ) async {
    try {
      final result = await action();
      return Right(result);
    } catch (e, stack) {
      return Left(handle(e, stack));
    }
  }
}
