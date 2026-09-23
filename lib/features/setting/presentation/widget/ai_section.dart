import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/features/setting/presentation/controllers/ai_settings_controller.dart';
import 'package:habit_tracker/features/setting/presentation/widget/animated_setting_tile.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

Widget buildAiSection(AnimationController animationController) {
  final aiController = Get.find<AiSettingsController>();

  return Builder(
    builder: (context) {
      return Obx(() {
        final isCustom = aiController.isCustom.value;
        final subtitleText = isCustom
            ? '${S.current.customApiKeyActive} (${aiController.maskedKey})'
            : S.current.defaultApiKeyActive;

        return Column(
          children: [
            AnimatedSettingTile(
              animationController: animationController,
              index: 7,
              icon: Icons.auto_awesome_rounded,
              title: S.current.aiApiKeyTitle,
              subtitle: subtitleText,
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isCustom
                      ? Colors.teal.withValues(alpha: 0.15)
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isCustom
                        ? Colors.teal.withValues(alpha: 0.4)
                        : Colors.transparent,
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
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isCustom
                          ? S.current.customApiKeyActive
                          : S.current.tapToEdit,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isCustom
                            ? Colors.teal
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () => _showAiApiKeyDialog(context, aiController),
            ),
          ],
        );
      });
    },
  );
}

void _showAiApiKeyDialog(
  BuildContext context,
  AiSettingsController controller,
) {
  final textController = TextEditingController(
    text: controller.customApiKey.value,
  );
  final obscureRx = true.obs;

  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        actionsPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: Theme.of(context).primaryColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                S.current.customApiKeyDialogTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.current.customApiKeyDialogDesc,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 14),
              // Helper info container linking to Google AI Studio
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () async {
                    final Uri url = Uri.parse(
                      'https://aistudio.google.com/app/apikey',
                    );
                    try {
                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                    } catch (e) {
                      debugPrint('Could not launch $url: $e');
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            S.current.getKeyInfo,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.open_in_new_rounded,
                          size: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // API Key text input
              Obx(
                () => TextField(
                  controller: textController,
                  obscureText: obscureRx.value,
                  decoration: InputDecoration(
                    labelText: S.current.aiApiKeyTitle,
                    hintText: S.current.apiKeyHint,
                    prefixIcon: const Icon(Icons.key_rounded),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: obscureRx.value ? 'Show' : 'Hide',
                          icon: Icon(
                            obscureRx.value
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            size: 20,
                          ),
                          onPressed: () => obscureRx.value = !obscureRx.value,
                        ),
                        IconButton(
                          tooltip: S.current.paste,
                          icon: const Icon(
                            Icons.paste_rounded,
                            size: 20,
                          ),
                          onPressed: () async {
                            final data = await Clipboard.getData(
                              Clipboard.kTextPlain,
                            );
                            if (data != null && data.text != null) {
                              textController.text = data.text!.trim();
                            }
                          },
                        ),
                      ],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Reset to default button (if custom key active)
          Obx(() {
            if (!controller.isCustom.value) return const SizedBox.shrink();
            return TextButton.icon(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await controller.clearApiKey();
              },
              icon: const Icon(
                Icons.restore_rounded,
                size: 16,
                color: Colors.redAccent,
              ),
              label: Text(
                S.current.resetToDefault,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            );
          }),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.shadow.withValues(alpha: 0.3),
                    blurRadius: 3,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
              S.current.cancel,
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final newKey = textController.text.trim();
              if (newKey.isEmpty) {
                // If user cleared the input, treat as clearing custom key
                Navigator.of(dialogContext).pop();
                await controller.clearApiKey();
                return;
              }
              final success = await controller.saveApiKey(newKey);
              if (success && dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.shadow.withValues(alpha: 0.3),
                    blurRadius: 3,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
              S.current.save,
            ),
          ),
        ],
      );
    },
  );
}
