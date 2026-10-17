import 'dart:convert';
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

  @override
  Future<Map<String, dynamic>> fetchLatestRelease() async {
    final uri = Uri.parse(
      'https://api.github.com/repos/${AppConfig.githubOwner}/${AppConfig.githubRepo}/releases/latest',
    );

    try {
      final response = await client.get(
        uri,
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'HabitTracker-App',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw ServerException(
          'GitHub API responded with status ${response.statusCode}',
        );
      }
    } on Exception catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException(e.toString());
    }
  }
}
