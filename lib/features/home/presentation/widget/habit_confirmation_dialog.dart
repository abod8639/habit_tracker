import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/components/neumorphic_button.dart';
import 'package:habit_tracker/core/components/neumorphic_checkbox.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';
import 'package:habit_tracker/features/home/presentation/providers/habit_providers.dart';
import 'package:habit_tracker/generated/l10n.dart';

class HabitConfirmationDialog extends ConsumerStatefulWidget {
  final List<String> extractedHabits;

  const HabitConfirmationDialog({required this.extractedHabits, super.key});

  @override
  ConsumerState<HabitConfirmationDialog> createState() =>
      _HabitConfirmationDialogState();
}

class _HabitConfirmationDialogState
    extends ConsumerState<HabitConfirmationDialog> {
  final Map<int, bool> _selectedHabits = {};

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.extractedHabits.length; i++) {
      _selectedHabits[i] = true;
    }
  }

  void _saveSelectedHabits() {
    final selectedHabits = <String>[];
    for (int i = 0; i < widget.extractedHabits.length; i++) {
      if (_selectedHabits[i] == true) {
        selectedHabits.add(widget.extractedHabits[i]);
      }
    }

    if (selectedHabits.isNotEmpty) {
      ref
          .read(habitNotifierProvider.notifier)
          .addMultipleHabits(selectedHabits);
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(S.of(context).addedSelectedHabitsSuccess),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final baseColor = theme.cardColor;

    if (widget.extractedHabits.isEmpty) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: AppRadius.dialogRadius,
            boxShadow: AppShadows.softCard(isDark: isDark),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.8),
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 48,
                color: colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                S.of(context).noHabitsDetected,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                S.of(context).noHabitsDetectedDesc,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 20),
              NeumorphicButton(
                text: S.of(context).close,
                onPressed: () => Navigator.of(context).pop(),
                width: 140,
                height: 44,
              ),
            ],
          ),
        ),
      );
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: AppRadius.dialogRadius,
          boxShadow: AppShadows.softCard(isDark: isDark),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.8),
            width: 1.2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    S.of(context).detectedHabits,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 320),
                decoration: BoxDecoration(
                  color: isDark
                      ? (Color.lerp(baseColor, Colors.black, 0.22) ?? baseColor)
                      : (Color.lerp(baseColor, const Color(0xFFDCE2EC), 0.30) ??
                            baseColor),
                  borderRadius: AppRadius.cardRadius,
                  boxShadow: AppShadows.wellDual(isDark: isDark),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: widget.extractedHabits.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.05),
                  ),
                  itemBuilder: (context, index) {
                    final isChecked = _selectedHabits[index] ?? false;
                    return InkWell(
                      borderRadius: AppRadius.mdRadius,
                      onTap: () {
                        setState(() {
                          _selectedHabits[index] = !isChecked;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            NeumorphicCheckbox(
                              value: isChecked,
                              onChanged: (val) {
                                setState(() {
                                  _selectedHabits[index] = val;
                                });
                              },
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.extractedHabits[index],
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: isChecked
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: NeumorphicButton(
                    text: S.of(context).cancel,
                    isPrimary: false,
                    height: 46,
                    borderRadius: AppRadius.mdRadius,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NeumorphicButton(
                    text: S.of(context).saveSelected,
                    isPrimary: true,
                    height: 46,
                    borderRadius: AppRadius.mdRadius,
                    onPressed: _saveSelectedHabits,
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
