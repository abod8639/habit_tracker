import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/components/neumorphic_button.dart';
import 'package:habit_tracker/core/components/neumorphic_input.dart';
import 'package:habit_tracker/core/components/neumorphic_selection_tile.dart';
import 'package:habit_tracker/core/components/soft_card.dart';
import 'package:habit_tracker/core/services/gemini_service.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';
import 'package:habit_tracker/features/setting/presentation/providers/setting_providers.dart';
import 'package:habit_tracker/generated/l10n.dart';

class _ModelItem {
  final String id;
  final String title;
  final String Function(S s) getSubtitle;
  final IconData icon;

  const _ModelItem({
    required this.id,
    required this.title,
    required this.getSubtitle,
    required this.icon,
  });
}

const List<_ModelItem> _presetModels = [
  _ModelItem(
    id: 'gemini-3.5-flash-lite',
    title: 'Gemini 3.5 Flash Lite',
    getSubtitle: _getFastestSubtitle,
    icon: Icons.bolt_rounded,
  ),
  _ModelItem(
    id: 'gemini-3.5-flash',
    title: 'Gemini 3.5 Flash',
    getSubtitle: _getBalancedSubtitle,
    icon: Icons.speed_rounded,
  ),
  _ModelItem(
    id: 'gemini-3.8-flash',
    title: 'Gemini 3.8 Flash',
    getSubtitle: _getSmartestSubtitle,
    icon: Icons.auto_awesome_rounded,
  ),
  _ModelItem(
    id: 'gemini-3.7-flash',
    title: 'Gemini 3.7 Flash',
    getSubtitle: _getReasoningSubtitle,
    icon: Icons.psychology_rounded,
  ),
  _ModelItem(
    id: 'gemini-3.6-flash',
    title: 'Gemini 3.6 Flash',
    getSubtitle: _getVersatileSubtitle,
    icon: Icons.widgets_rounded,
  ),
  _ModelItem(
    id: 'gemini-flash-lite-latest',
    title: 'Gemini Flash Lite (Latest)',
    getSubtitle: _getLatestLiteSubtitle,
    icon: Icons.update_rounded,
  ),
  _ModelItem(
    id: 'gemini-flash-latest',
    title: 'Gemini Flash (Latest)',
    getSubtitle: _getLatestSubtitle,
    icon: Icons.update_rounded,
  ),
];

String _getFastestSubtitle(S s) => s.fastestModel;
String _getBalancedSubtitle(S s) => s.balancedModel;
String _getSmartestSubtitle(S s) => s.smartestModel;
String _getReasoningSubtitle(S s) => s.reasoningModel;
String _getVersatileSubtitle(S s) => 'Versatile Performance';
String _getLatestLiteSubtitle(S s) => 'Auto-updating Flash Lite';
String _getLatestSubtitle(S s) => 'Auto-updating Flash';

/// Neumorphic Dialog for choosing the active Gemini AI model.
/// Reuses core UI components from `lib/core/components/`.
class AiModelSelectionDialog extends ConsumerStatefulWidget {
  const AiModelSelectionDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (dialogContext) => const AiModelSelectionDialog(),
    );
  }

  @override
  ConsumerState<AiModelSelectionDialog> createState() =>
      _AiModelSelectionDialogState();
}

class _AiModelSelectionDialogState
    extends ConsumerState<AiModelSelectionDialog> {
  late String _selectedModel;
  bool _isCustom = false;
  late TextEditingController _customController;

  @override
  void initState() {
    super.initState();
    final current = ref.read(aiSettingsNotifierProvider).selectedModel;
    _selectedModel = current.isNotEmpty
        ? current
        : GeminiService.effectiveModelName;

    final isKnown = _presetModels.any((m) => m.id == _selectedModel);
    _isCustom = !isKnown && _selectedModel != GeminiService.defaultModelName;
    _customController = TextEditingController(
      text: _isCustom ? _selectedModel : '',
    );
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final s = S.of(context);
    String targetModel;
    if (_isCustom) {
      targetModel = _customController.text.trim();
      if (targetModel.isEmpty) {
        targetModel = GeminiService.defaultModelName;
      }
    } else {
      targetModel = _selectedModel;
    }

    final success = await ref
        .read(aiSettingsNotifierProvider.notifier)
        .saveModel(targetModel);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? s.modelSavedSuccess : s.somethingWentWrong,
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleReset() async {
    final s = S.of(context);
    await ref.read(aiSettingsNotifierProvider.notifier).resetModelToDefault();

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s.modelResetSuccess),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseSurface = theme.cardColor;
    final primaryColor = theme.primaryColor;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
          maxWidth: 480,
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: Sculpted Icon + Title
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
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
                    Icons.tune_rounded,
                    color: primaryColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.aiModelDialogTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.5,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        s.aiModelSubtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withValues(
                            alpha: 0.7,
                          ),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                  splashRadius: 20,
                  tooltip: s.close,
                ),
              ],
            ),
            const SizedBox(height: 14),

            // SoftCard Tip/Description Banner (reused from lib/core)
            SoftCard(
              borderRadius: AppRadius.sm,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      s.aiModelDialogDesc,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11.5,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Scrollable Models List
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ..._presetModels.map((item) {
                      final isSelected =
                          !_isCustom && _selectedModel == item.id;
                      return NeumorphicSelectionTile(
                        key: ValueKey(item.id),
                        isSelected: isSelected,
                        titleText: item.title,
                        subtitleText: item.getSubtitle(s),
                        accentColor: primaryColor,
                        margin: const EdgeInsets.only(bottom: 8),
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Color.alphaBlend(
                              primaryColor.withValues(
                                alpha: isSelected
                                    ? (isDark ? 0.25 : 0.15)
                                    : (isDark ? 0.08 : 0.04),
                              ),
                              baseSurface,
                            ),
                            borderRadius: AppRadius.smRadius,
                          ),
                          child: Icon(
                            item.icon,
                            size: 18,
                            color: isSelected
                                ? primaryColor
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedModel = item.id;
                            _isCustom = false;
                          });
                        },
                      );
                    }),

                    // Custom Model Selection Option
                    NeumorphicSelectionTile(
                      key: const ValueKey('custom_model_option'),
                      isSelected: _isCustom,
                      titleText: s.customModel,
                      subtitleText: s.customModelDesc,
                      accentColor: primaryColor,
                      margin: const EdgeInsets.only(bottom: 8),
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Color.alphaBlend(
                            primaryColor.withValues(
                              alpha: _isCustom
                                  ? (isDark ? 0.25 : 0.15)
                                  : (isDark ? 0.08 : 0.04),
                            ),
                            baseSurface,
                          ),
                          borderRadius: AppRadius.smRadius,
                        ),
                        child: Icon(
                          Icons.edit_rounded,
                          size: 18,
                          color: _isCustom
                              ? primaryColor
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _isCustom = true;
                        });
                      },
                    ),

                    // Custom Model Input field (reused NeumorphicInput from lib/core)
                    if (_isCustom)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 4,
                          bottom: 10,
                          left: 4,
                          right: 4,
                        ),
                        child: NeumorphicInput(
                          controller: _customController,
                          hintText: s.customModelHint,
                          prefixIcon: Icons.code_rounded,
                          accentColor: primaryColor,
                          autofocus: true,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          onChanged: (val) {
                            setState(() {
                              _selectedModel = val.trim();
                            });
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons (reused NeumorphicButton from lib/core)
            Row(
              children: [
                Expanded(
                  child: NeumorphicButton(
                    text: s.resetToDefault,
                    icon: Icons.restore_rounded,
                    isPrimary: false,
                    height: 44,
                    onPressed: _handleReset,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NeumorphicButton(
                    text: s.save,
                    icon: Icons.check_rounded,
                    isPrimary: true,
                    height: 44,
                    onPressed: _handleSave,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
