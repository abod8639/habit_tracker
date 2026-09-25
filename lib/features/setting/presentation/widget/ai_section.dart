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
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isCustom
                      ? [
                          BoxShadow(
                            color: Colors.teal
                                .withValues(alpha: isDark ? 0.30 : 0.20),
                            offset: const Offset(0, 2),
                            blurRadius: 6,
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.03)
                                : Colors.white.withValues(alpha: 0.75),
                            offset: const Offset(-1.5, -1.5),
                            blurRadius: 2.5,
                          ),
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.3)
                                : const Color(0xFFA3B1C6)
                                    .withValues(alpha: 0.25),
                            offset: const Offset(1.5, 1.5),
                            blurRadius: 2.5,
                          ),
                        ],
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
  final s = S.of(context);
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final isDark = theme.brightness == Brightness.dark;
  final baseSurface = theme.cardColor;
  final primaryColor = theme.primaryColor;

  showDialog(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          decoration: BoxDecoration(
            color: baseSurface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.045)
                    : Colors.white.withValues(alpha: 0.90),
                offset: const Offset(-4, -4),
                blurRadius: 10,
              ),
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.55)
                    : const Color(0xFFA3B1C6).withValues(alpha: 0.45),
                offset: const Offset(4, 4),
                blurRadius: 12,
              ),
            ],
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
                        borderRadius: BorderRadius.circular(13),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.035)
                                : Colors.white.withValues(alpha: 0.85),
                            offset: const Offset(-2, -2),
                            blurRadius: 3,
                          ),
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.35)
                                : const Color(0xFFA3B1C6).withValues(alpha: 0.30),
                            offset: const Offset(2, 2),
                            blurRadius: 3,
                          ),
                        ],
                        border: Border.all(
                          color: primaryColor.withValues(alpha: isDark ? 0.25 : 0.18),
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
                    borderRadius: BorderRadius.circular(14),
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
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.03)
                                : Colors.white.withValues(alpha: 0.75),
                            offset: const Offset(-1.5, -1.5),
                            blurRadius: 2.5,
                          ),
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.3)
                                : const Color(0xFFA3B1C6).withValues(alpha: 0.25),
                            offset: const Offset(1.5, 1.5),
                            blurRadius: 2.5,
                          ),
                        ],
                        border: Border.all(
                          color: primaryColor.withValues(alpha: isDark ? 0.22 : 0.15),
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
                        colorScheme.onSurface.withValues(alpha: isDark ? 0.04 : 0.02),
                        baseSurface,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.35)
                              : const Color(0xFFA3B1C6).withValues(alpha: 0.25),
                          offset: const Offset(1.5, 1.5),
                          blurRadius: 3,
                        ),
                        BoxShadow(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.02)
                              : Colors.white.withValues(alpha: 0.7),
                          offset: const Offset(-1.5, -1.5),
                          blurRadius: 3,
                        ),
                      ],
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
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : Colors.black.withValues(alpha: 0.06),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : Colors.black.withValues(alpha: 0.06),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
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
                            Navigator.of(dialogContext).pop();
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
                      onTap: () => Navigator.of(dialogContext).pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Color.alphaBlend(
                            colorScheme.onSurface
                                .withValues(alpha: isDark ? 0.05 : 0.03),
                            baseSurface,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.03)
                                  : Colors.white.withValues(alpha: 0.75),
                              offset: const Offset(-1.5, -1.5),
                              blurRadius: 2.5,
                            ),
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withValues(alpha: 0.3)
                                  : const Color(0xFFA3B1C6)
                                      .withValues(alpha: 0.25),
                              offset: const Offset(1.5, 1.5),
                              blurRadius: 2.5,
                            ),
                          ],
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
                          Navigator.of(dialogContext).pop();
                          await controller.clearApiKey();
                          return;
                        }
                        final success = await controller.saveApiKey(newKey);
                        if (success && dialogContext.mounted) {
                          Navigator.of(dialogContext).pop();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor
                                  .withValues(alpha: isDark ? 0.40 : 0.30),
                              offset: const Offset(0, 3),
                              blurRadius: 8,
                            ),
                          ],
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
    },
  );
}
