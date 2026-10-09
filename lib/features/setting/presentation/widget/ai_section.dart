import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/core/components/animated_setting_tile.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';
import 'package:habit_tracker/features/setting/presentation/controllers/ai_settings_controller.dart';
import 'package:habit_tracker/features/setting/presentation/widget/ai_api_key_dialog.dart';
import 'package:habit_tracker/generated/l10n.dart';

class AiSection extends StatelessWidget {
  final AnimationController animationController;

  const AiSection({super.key, required this.animationController});

  @override
  Widget build(BuildContext context) {
    final aiController = Get.find<AiSettingsController>();
    final s = S.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseSurface = theme.cardColor;

    return Obx(() {
      final isCustom = aiController.isCustom.value;
      final keyStatus = aiController.apiKeyStatus.value;

      final Color statusColor;
      final IconData statusIcon;
      final String badgeText;
      final String subtitleText;

      switch (keyStatus) {
        case ApiKeyStatus.valid:
          statusColor = Colors.teal;
          statusIcon = Icons.check_circle_rounded;
          badgeText = s.apiKeyValid;
          subtitleText = isCustom
              ? '${s.customApiKeyActive} (${aiController.maskedKey}) • ${s.apiKeyValid}'
              : '${s.defaultApiKeyActive} • ${s.apiKeyValid}';
          break;
        case ApiKeyStatus.invalid:
          statusColor = Colors.redAccent;
          statusIcon = Icons.error_outline_rounded;
          badgeText = s.apiKeyNotWorking;
          subtitleText = isCustom
              ? '${s.customApiKeyActive} (${aiController.maskedKey}) • ${s.apiKeyNotWorking}'
              : s.apiKeyRequired;
          break;
        case ApiKeyStatus.validating:
          statusColor = Colors.amber;
          statusIcon = Icons.sync_rounded;
          badgeText = s.apiKeyChecking;
          subtitleText = s.apiKeyChecking;
          break;
        case ApiKeyStatus.unknown:
          statusColor = theme.colorScheme.onSurfaceVariant;
          statusIcon = isCustom ? Icons.check_circle_rounded : Icons.tune_rounded;
          badgeText = isCustom ? s.customApiKeyActive : s.tapToEdit;
          subtitleText = isCustom
              ? '${s.customApiKeyActive} (${aiController.maskedKey})'
              : s.defaultApiKeyActive;
          break;
      }

      return Column(
        children: [
          AnimatedSettingTile(
            animationController: animationController,
            index: 7,
            icon: Icons.auto_awesome_rounded,
            title: s.aiApiKeyTitle,
            subtitle: subtitleText,
            trailing: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: Color.alphaBlend(
                  statusColor.withValues(alpha: isDark ? 0.18 : 0.10),
                  baseSurface,
                ),
                borderRadius: AppRadius.badgeRadius,
                boxShadow: AppShadows.dotIndicator(isDark: isDark),
                border: Border.all(
                  color: statusColor.withValues(alpha: isDark ? 0.35 : 0.25),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (keyStatus == ApiKeyStatus.validating)
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: statusColor,
                      ),
                    )
                  else
                    Icon(
                      statusIcon,
                      size: 14,
                      color: statusColor,
                    ),
                  const SizedBox(width: 5),
                  Text(
                    badgeText,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
            onTap: () => AiApiKeyDialog.show(context, aiController),
          ),
        ],
      );
    });
  }
}

Widget buildAiSection(AnimationController animationController) {
  return AiSection(animationController: animationController);
}
