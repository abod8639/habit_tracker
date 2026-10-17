import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/error/exceptions.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/features/setting/data/datasources/app_update_remote_datasource.dart';
import 'package:habit_tracker/features/setting/data/repositories/app_update_repository_impl.dart';
import 'package:habit_tracker/features/setting/domain/entities/app_update_info.dart';
import 'package:habit_tracker/features/setting/domain/usecases/check_app_update_usecase.dart';

class MockAppUpdateRemoteDataSource implements AppUpdateRemoteDataSource {
  final Map<String, dynamic>? mockResponse;
  final Exception? exceptionToThrow;

  MockAppUpdateRemoteDataSource({this.mockResponse, this.exceptionToThrow});

  @override
  Future<Map<String, dynamic>> fetchLatestRelease() async {
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    return mockResponse ?? {};
  }
}

void main() {
  group('AppUpdateInfo.isRemoteNewer', () {
    test('returns true when remote minor version is greater', () {
      expect(AppUpdateInfo.isRemoteNewer('1.4.0', '1.5.0'), isTrue);
      expect(AppUpdateInfo.isRemoteNewer('1.4.0', 'V1.5.0'), isTrue);
      expect(AppUpdateInfo.isRemoteNewer('1.4.0', 'v1.5.0'), isTrue);
    });

    test('returns true when remote patch version is greater', () {
      expect(AppUpdateInfo.isRemoteNewer('1.4.0', '1.4.1'), isTrue);
      expect(AppUpdateInfo.isRemoteNewer('1.4.0', 'V1.4.2'), isTrue);
    });

    test('returns true when remote major version is greater', () {
      expect(AppUpdateInfo.isRemoteNewer('1.4.0', '2.0.0'), isTrue);
    });

    test('returns false when versions are equal', () {
      expect(AppUpdateInfo.isRemoteNewer('1.4.0', '1.4.0'), isFalse);
      expect(AppUpdateInfo.isRemoteNewer('1.4.0', 'V1.4.0'), isFalse);
      expect(AppUpdateInfo.isRemoteNewer('1.4.0', 'v1.4.0'), isFalse);
    });

    test('returns false when remote version is older', () {
      expect(AppUpdateInfo.isRemoteNewer('1.4.0', '1.3.9'), isFalse);
      expect(AppUpdateInfo.isRemoteNewer('1.4.0', 'V1.2.0'), isFalse);
      expect(AppUpdateInfo.isRemoteNewer('2.0.0', '1.9.9'), isFalse);
    });

    test('handles edge case strings and suffixes safely', () {
      expect(AppUpdateInfo.isRemoteNewer('1.4.0', 'V1.4.0-beta'), isFalse);
      expect(AppUpdateInfo.isRemoteNewer('1.4.0', 'V1.4.1-alpha'), isTrue);
      expect(AppUpdateInfo.isRemoteNewer('1.4.0', ''), isFalse);
    });
  });

  group('AppUpdateRepositoryImpl', () {
    test('returns AppUpdateInfo with hasUpdate = true when release is newer', () async {
      final mockDataSource = MockAppUpdateRemoteDataSource(
        mockResponse: {
          'tag_name': 'V1.5.0',
          'html_url': 'https://github.com/abod8639/habit_tracker/releases/tag/V1.5.0',
          'body': 'Exciting new features and fixes',
          'assets': [
            {
              'name': 'app-release.apk',
              'browser_download_url':
                  'https://github.com/abod8639/habit_tracker/releases/download/V1.5.0/app-release.apk',
            }
          ],
        },
      );

      final repository = AppUpdateRepositoryImpl(remoteDataSource: mockDataSource);
      final result = await repository.checkForUpdate(currentVersion: '1.4.0');

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Should succeed'),
        (info) {
          expect(info.hasUpdate, isTrue);
          expect(info.latestVersion, equals('1.5.0'));
          expect(info.currentVersion, equals('1.4.0'));
          expect(
            info.downloadUrl,
            equals(
              'https://github.com/abod8639/habit_tracker/releases/download/V1.5.0/app-release.apk',
            ),
          );
        },
      );
    });

    test('returns AppUpdateInfo with hasUpdate = false when release is equal', () async {
      final mockDataSource = MockAppUpdateRemoteDataSource(
        mockResponse: {
          'tag_name': 'V1.4.0',
          'html_url': 'https://github.com/abod8639/habit_tracker/releases/tag/V1.4.0',
          'body': 'Current release',
          'assets': [],
        },
      );

      final repository = AppUpdateRepositoryImpl(remoteDataSource: mockDataSource);
      final result = await repository.checkForUpdate(currentVersion: '1.4.0');

      expect(result.isRight(), isTrue);
      result.fold(
        (failure) => fail('Should succeed'),
        (info) {
          expect(info.hasUpdate, isFalse);
          expect(info.latestVersion, equals('1.4.0'));
        },
      );
    });

    test('returns NetworkFailure on NetworkException', () async {
      final mockDataSource = MockAppUpdateRemoteDataSource(
        exceptionToThrow: const NetworkException('Connection failed'),
      );

      final repository = AppUpdateRepositoryImpl(remoteDataSource: mockDataSource);
      final result = await repository.checkForUpdate(currentVersion: '1.4.0');

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Should fail with NetworkFailure'),
      );
    });
  });

  group('CheckAppUpdateUseCase', () {
    test('delegates update check to repository', () async {
      final mockDataSource = MockAppUpdateRemoteDataSource(
        mockResponse: {
          'tag_name': 'V1.6.0',
          'html_url': 'https://github.com/example/release',
          'assets': [],
        },
      );
      final repository = AppUpdateRepositoryImpl(remoteDataSource: mockDataSource);
      final useCase = CheckAppUpdateUseCase(repository);

      final result = await useCase(currentVersion: '1.4.0');
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Should succeed'),
        (info) => expect(info.hasUpdate, isTrue),
      );
    });
  });
}
