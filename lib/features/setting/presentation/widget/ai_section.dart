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
      final subtitleText = isCustom
          ? '${s.customApiKeyActive} (${aiController.maskedKey})'
          : s.defaultApiKeyActive;

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
                color: isCustom
                    ? Color.alphaBlend(
                        Colors.teal.withValues(alpha: isDark ? 0.18 : 0.10),
                        baseSurface,
                      )
                    : Color.alphaBlend(
                        theme.colorScheme.onSurface
                            .withValues(alpha: isDark ? 0.05 : 0.03),
                        baseSurface,
                      ),
                borderRadius: AppRadius.badgeRadius,
                boxShadow: isCustom
                    ? AppShadows.bloom(
                        color: Colors.teal,
                        isDark: isDark,
                        blur: 6,
                        offset: const Offset(0, 2),
                      )
                    : AppShadows.dotIndicator(isDark: isDark),
                border: Border.all(
                  color: isCustom
                      ? Colors.teal.withValues(alpha: isDark ? 0.35 : 0.25)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : Colors.white.withValues(alpha: 0.6)),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isCustom
                        ? Icons.check_circle_rounded
                        : Icons.tune_rounded,
                    size: 14,
                    color: isCustom
                        ? Colors.teal
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    isCustom ? s.customApiKeyActive : s.tapToEdit,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isCustom
                          ? Colors.teal
                          : theme.colorScheme.onSurfaceVariant,
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
