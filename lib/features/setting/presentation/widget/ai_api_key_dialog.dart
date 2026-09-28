import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';
import 'package:habit_tracker/features/setting/presentation/controllers/ai_settings_controller.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

/// Neumorphic Dialog for managing Gemini Custom AI API Key.
class AiApiKeyDialog extends StatelessWidget {
  final AiSettingsController controller;

  const AiApiKeyDialog({super.key, required this.controller});

  static Future<void> show(
    BuildContext context,
    AiSettingsController controller,
  ) {
    return showDialog(
      context: context,
      builder: (dialogContext) => AiApiKeyDialog(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController(
      text: controller.customApiKey.value,
    );
    final obscureRx = true.obs;
    final s = S.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final baseSurface = theme.cardColor;
    final primaryColor = theme.primaryColor;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        decoration: BoxDecoration(
          color: baseSurface,
          borderRadius: AppRadius.cardRadius,
          boxShadow: AppShadows.softCard(isDark: isDark),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.8),
            width: 1,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Neumorphic Title Header
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Color.alphaBlend(
                        primaryColor.withValues(alpha: isDark ? 0.16 : 0.10),
                        baseSurface,
                      ),
                      borderRadius: AppRadius.mdRadius,
                      boxShadow: AppShadows.dotIndicator(isDark: isDark),
                      border: Border.all(
                        color: primaryColor.withValues(
                          alpha: isDark ? 0.25 : 0.18,
                        ),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: primaryColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      s.customApiKeyDialogTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.5,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                s.customApiKeyDialogDesc,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.65),
                  height: 1.35,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 14),

              // Neumorphic Helper info container linking to Google AI Studio
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: AppRadius.mdRadius,
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
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Color.alphaBlend(
                        primaryColor.withValues(alpha: isDark ? 0.08 : 0.04),
                        baseSurface,
                      ),
                      borderRadius: AppRadius.mdRadius,
                      boxShadow: AppShadows.dotIndicator(isDark: isDark),
                      border: Border.all(
                        color: primaryColor.withValues(
                          alpha: isDark ? 0.22 : 0.15,
                        ),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            s.getKeyInfo,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.open_in_new_rounded,
                          size: 16,
                          color: primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Neumorphic Sunken TextField
              Obx(
                () => Container(
                  decoration: BoxDecoration(
                    color: Color.alphaBlend(
                      colorScheme.onSurface.withValues(
                        alpha: isDark ? 0.04 : 0.02,
                      ),
                      baseSurface,
                    ),
                    borderRadius: AppRadius.lgRadius,
                    boxShadow: AppShadows.insetWell(isDark: isDark),
                  ),
                  child: TextField(
                    controller: textController,
                    obscureText: obscureRx.value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                    decoration: InputDecoration(
                      labelText: s.aiApiKeyTitle,
                      hintText: s.apiKeyHint,
                      prefixIcon: Icon(Icons.key_rounded, color: primaryColor),
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
                            tooltip: s.paste,
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
                        borderRadius: AppRadius.lgRadius,
                        borderSide: BorderSide(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : Colors.black.withValues(alpha: 0.06),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppRadius.lgRadius,
                        borderSide: BorderSide(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : Colors.black.withValues(alpha: 0.06),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppRadius.lgRadius,
                        borderSide: BorderSide(
                          color: primaryColor,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Neumorphic Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Reset to default button (if custom key active)
                  Obx(() {
                    if (!controller.isCustom.value) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: TextButton.icon(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await controller.clearApiKey();
                        },
                        icon: const Icon(
                          Icons.restore_rounded,
                          size: 16,
                          color: Colors.redAccent,
                        ),
                        label: Text(
                          s.resetToDefault,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }),
                  const Spacer(),

                  // Cancel button
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Color.alphaBlend(
                          colorScheme.onSurface.withValues(
                            alpha: isDark ? 0.05 : 0.03,
                          ),
                          baseSurface,
                        ),
                        borderRadius: AppRadius.mdRadius,
                        boxShadow: AppShadows.dotIndicator(isDark: isDark),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.04)
                              : Colors.white.withValues(alpha: 0.6),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        s.cancel,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface.withValues(alpha: 0.75),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Save button (Neumorphic raised primary)
                  GestureDetector(
                    onTap: () async {
                      final newKey = textController.text.trim();
                      if (newKey.isEmpty) {
                        Navigator.of(context).pop();
                        await controller.clearApiKey();
                        return;
                      }
                      final success = await controller.saveApiKey(newKey);
                      if (success && context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: AppRadius.mdRadius,
                        boxShadow: AppShadows.bloom(
                          color: primaryColor,
                          isDark: isDark,
                          blur: 8,
                          offset: const Offset(0, 3),
                        ),
                      ),
                      child: Text(
                        s.save,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
