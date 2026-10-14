import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';
import 'package:habit_tracker/features/setting/presentation/providers/setting_providers.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

/// Neumorphic Dialog for managing Gemini Custom AI API Key.
class AiApiKeyDialog extends ConsumerStatefulWidget {
  const AiApiKeyDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (dialogContext) => const AiApiKeyDialog(),
    );
  }

  @override
  ConsumerState<AiApiKeyDialog> createState() => _AiApiKeyDialogState();
}

class _AiApiKeyDialogState extends ConsumerState<AiApiKeyDialog> {
  late TextEditingController _textController;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    final initialKey = ref.read(aiSettingsNotifierProvider).customApiKey;
    _textController = TextEditingController(text: initialKey);
  }


  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiSettingsNotifierProvider);
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

              // Description
              Text(
                s.customApiKeyDialogDesc,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withValues(
                    alpha: 0.75,
                  ),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),

              // Get Key Link Well (Neumorphic recessed)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    final uri = Uri.parse('https://aistudio.google.com/app/apikey');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  borderRadius: AppRadius.mdRadius,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Color.alphaBlend(
                        primaryColor.withValues(alpha: isDark ? 0.12 : 0.07),
                        baseSurface,
                      ),
                      borderRadius: AppRadius.mdRadius,
                      boxShadow: AppShadows.insetWell(isDark: isDark),
                      border: Border.all(
                        color: primaryColor.withValues(
                          alpha: isDark ? 0.22 : 0.15,
                        ),
                        width: 0.8,
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
              Container(
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
                  controller: _textController,
                  obscureText: _obscureText,
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
                          tooltip: _obscureText ? 'Show' : 'Hide',
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscureText = !_obscureText),
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
                              _textController.text = data.text!.trim();
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
              const SizedBox(height: 20),

              // Neumorphic Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Reset to default button (if custom key active)
                  if (aiState.isCustom)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: TextButton.icon(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await ref.read(aiSettingsNotifierProvider.notifier).clearApiKey();
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
                    ),
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
                    onTap: aiState.isValidating
                        ? null
                        : () async {
                            final newKey = _textController.text.trim();
                            if (newKey.isEmpty) {
                              Navigator.of(context).pop();
                              await ref.read(aiSettingsNotifierProvider.notifier).clearApiKey();
                              return;
                            }
                            final success = await ref
                                .read(aiSettingsNotifierProvider.notifier)
                                .saveApiKey(newKey);
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
                        boxShadow: AppShadows.buttonResting(isDark: isDark),
                      ),
                      child: aiState.isValidating
                          ? const SizedBox(
                              width: 23,
                              height: 23,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
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
