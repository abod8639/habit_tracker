import 'package:dartz/dartz.dart';
import 'package:habit_tracker/core/config/app_config.dart';
import 'package:habit_tracker/core/error/failures.dart';
import 'package:habit_tracker/core/error/network_error_handler.dart';
import 'package:habit_tracker/features/setting/data/datasources/app_update_remote_datasource.dart';
import 'package:habit_tracker/features/setting/domain/entities/app_update_info.dart';
import 'package:habit_tracker/features/setting/domain/repositories/app_update_repository.dart';

class AppUpdateRepositoryImpl implements AppUpdateRepository {
  final AppUpdateRemoteDataSource remoteDataSource;

  AppUpdateRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AppUpdateInfo>> checkForUpdate({
    String? currentVersion,
  }) {
    return NetworkErrorHandler.guard(() async {
      final releaseData = await remoteDataSource.fetchLatestRelease();
      final current = currentVersion ?? AppConfig.appVersion;

      final rawTag = (releaseData['tag_name'] as String? ?? '').trim();
      final latest = rawTag.replaceAll(RegExp(r'^[vV]'), '');
      final releaseUrl =
          releaseData['html_url'] as String? ?? AppConfig.githubReleasesUrl;
      final releaseNotes = releaseData['body'] as String?;

      String downloadUrl = AppConfig.fallbackApkUrl;
      final assets = releaseData['assets'];
      if (assets is List && assets.isNotEmpty) {
        for (final asset in assets) {
          try {
            if (asset is Map) {
              final name = (asset['name'] as String? ?? '').toLowerCase();
              final url = asset['browser_download_url'] as String?;
              if (name.endsWith('.apk') && url != null && url.isNotEmpty) {
                downloadUrl = url;
                break;
              }
            }
          } catch (_) {
            // Skip corrupted asset entries
          }
        }
      }

      final hasUpdate = AppUpdateInfo.isRemoteNewer(current, rawTag);

      return AppUpdateInfo(
        hasUpdate: hasUpdate,
        currentVersion: current,
        latestVersion: latest.isNotEmpty ? latest : rawTag,
        releaseUrl: releaseUrl,
        downloadUrl: downloadUrl,
        releaseNotes: releaseNotes,
      );
    });
  }
}
