import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:habit_tracker/core/config/app_config.dart';
import 'package:habit_tracker/core/error/exceptions.dart';
import 'package:http/http.dart' as http;

abstract class AppUpdateRemoteDataSource {
  Future<Map<String, dynamic>> fetchLatestRelease();
}

class AppUpdateRemoteDataSourceImpl implements AppUpdateRemoteDataSource {
  final http.Client client;

  AppUpdateRemoteDataSourceImpl({http.Client? client})
    : client = client ?? http.Client();

  static const Duration _requestTimeout = Duration(seconds: 10);
  static const Duration _isolateTimeout = Duration(seconds: 5);

  @override
  Future<Map<String, dynamic>> fetchLatestRelease() async {
    final uri = Uri.parse(
      'https://api.github.com/repos/${AppConfig.githubOwner}/${AppConfig.githubRepo}/releases/latest',
    );

    try {
      final response = await client
          .get(
            uri,
            headers: {
              'Accept': 'application/vnd.github.v3+json',
              'User-Agent': 'HabitTracker-App',
            },
          )
          .timeout(
            _requestTimeout,
            onTimeout: () {
              throw const TimeoutAppException(
                'GitHub update request timed out',
              );
            },
          );

      if (response.statusCode == 200) {
        // Offload large JSON payload and markdown release body parsing to an Isolate
        return await compute(
          _isolateParseReleasePayload,
          response.body,
        ).timeout(
          _isolateTimeout,
          onTimeout: () {
            throw const TimeoutAppException(
              'Parsing release payload timed out',
            );
          },
        );
      } else {
        throw ServerException(
          'GitHub API responded with status ${response.statusCode}',
        );
      }
    } on TimeoutAppException {
      rethrow;
    } on ServerException {
      rethrow;
    } on ParsingException {
      rethrow;
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }

  static Map<String, dynamic> _isolateParseReleasePayload(String responseBody) {
    try {
      final decoded = json.decode(responseBody);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
      throw const ParsingException('Unexpected release JSON format');
    } on FormatException catch (e) {
      throw ParsingException('Corrupted GitHub response JSON: ${e.message}');
    }
  }
}
