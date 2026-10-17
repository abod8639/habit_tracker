import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/components/animated_setting_tile.dart';
import 'package:habit_tracker/core/components/app_confirmation_dialog.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/features/setting/presentation/providers/app_update_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateTile extends ConsumerWidget {
  final AnimationController animationController;

  const AppUpdateTile({
    super.key,
    required this.animationController,
  });

  Future<void> _handleUpdateTap(
    BuildContext context,
    String latestVersion,
    String currentVersion,
    String downloadUrl,
    String releaseUrl,
    bool isArabic,
  ) async {
    final confirmed = await AppConfirmationDialog.show(
      context: context,
      title: isArabic ? 'تحديث جديد متوفر' : 'New Update Available',
      message: isArabic
          ? 'يتوفر إصدار جديد (v$latestVersion) على GitHub.\nإصدارك الحالي: (v$currentVersion).\nهل ترغب بالانتقال لتحميل التحديث الآن؟'
          : 'A new version (v$latestVersion) is available on GitHub.\nCurrent version: (v$currentVersion).\nWould you like to download the update now?',
      confirmText: isArabic ? 'تحميل التحديث' : 'Download Update',
      cancelText: isArabic ? 'لاحقاً' : 'Later',
      icon: Icons.system_update_rounded,
    );

    if (confirmed == true) {
      final targetUrl = downloadUrl.isNotEmpty ? downloadUrl : releaseUrl;
      final uri = Uri.parse(targetUrl);
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        debugPrint('Could not launch $targetUrl: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updateAsync = ref.watch(appUpdateInfoProvider);

    return updateAsync.when(
      data: (updateInfo) {
        if (updateInfo == null || !updateInfo.hasUpdate) {
          return const SizedBox.shrink();
        }

        final isArabic =
            Localizations.localeOf(context).languageCode.startsWith('ar');
        final theme = Theme.of(context);
        final primaryColor = theme.primaryColor;

        return AnimatedSettingTile(
          animationController: animationController,
          index: 14,
          icon: Icons.system_update_rounded,
          title: isArabic
              ? 'تحديث جديد متوفر: v${updateInfo.latestVersion}'
              : 'New Update Available: v${updateInfo.latestVersion}',
          subtitle: isArabic
              ? 'الإصدار الحالي v${updateInfo.currentVersion} • اضغط للتحميل'
              : 'Current v${updateInfo.currentVersion} • Tap to download',
          textColor: primaryColor,
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.15),
              borderRadius: AppRadius.pillRadius,
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.download_rounded,
                  size: 15,
                  color: primaryColor,
                ),
                const SizedBox(width: 4),
                Text(
                  isArabic ? 'تحديث' : 'UPDATE',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          onTap: () => _handleUpdateTap(
            context,
            updateInfo.latestVersion,
            updateInfo.currentVersion,
            updateInfo.downloadUrl,
            updateInfo.releaseUrl,
            isArabic,
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}
