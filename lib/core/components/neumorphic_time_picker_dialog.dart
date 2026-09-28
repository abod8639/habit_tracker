import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';
import 'package:habit_tracker/core/theme/theme_utils.dart';
import 'package:habit_tracker/generated/l10n.dart';

/// Shows a deeply tactile Neumorphic / Soft UI Time Picker Dialog.
Future<TimeOfDay?> showNeumorphicTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) {
  return showDialog<TimeOfDay>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (dialogContext) => NeumorphicTimePickerDialog(
      initialTime: initialTime,
    ),
  );
}

/// A tactile Neumorphic / Soft UI Time Picker Dialog.
/// Features dual-source ambient lighting, a recessed time well,
/// physical stepper buttons, AM/PM toggle, quick presets, and soft action buttons.
class NeumorphicTimePickerDialog extends StatefulWidget {
  final TimeOfDay initialTime;

  const NeumorphicTimePickerDialog({
    super.key,
    required this.initialTime,
  });

  @override
  State<NeumorphicTimePickerDialog> createState() =>
      _NeumorphicTimePickerDialogState();
}

class _NeumorphicTimePickerDialogState extends State<NeumorphicTimePickerDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  late int _selectedHour; // 1..12 or 0..23
  late int _selectedMinute; // 0..59
  late DayPeriod _selectedPeriod;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _selectedMinute = widget.initialTime.minute;
    _selectedPeriod = widget.initialTime.period;

    // Convert to 12-hour representation for 12h display
    final hourOfPeriod = widget.initialTime.hourOfPeriod;
    _selectedHour = hourOfPeriod == 0 ? 12 : hourOfPeriod;

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _incrementHour(bool is24Hour) {
    setState(() {
      if (is24Hour) {
        _selectedHour = (_selectedHour + 1) % 24;
      } else {
        _selectedHour = _selectedHour >= 12 ? 1 : _selectedHour + 1;
      }
    });
  }

  void _decrementHour(bool is24Hour) {
    setState(() {
      if (is24Hour) {
        _selectedHour = (_selectedHour - 1 + 24) % 24;
      } else {
        _selectedHour = _selectedHour <= 1 ? 12 : _selectedHour - 1;
      }
    });
  }

  void _incrementMinute() {
    setState(() {
      _selectedMinute = (_selectedMinute + 5) % 60;
    });
  }

  void _decrementMinute() {
    setState(() {
      _selectedMinute = (_selectedMinute - 5 + 60) % 60;
    });
  }

  void _applyPreset(int hour24, int minute) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedMinute = minute;
      if (hour24 >= 12) {
        _selectedPeriod = DayPeriod.pm;
        _selectedHour = hour24 == 12 ? 12 : hour24 - 12;
      } else {
        _selectedPeriod = DayPeriod.am;
        _selectedHour = hour24 == 0 ? 12 : hour24;
      }
    });
  }

  TimeOfDay _calculateFinalTime(bool is24Hour) {
    if (is24Hour) {
      return TimeOfDay(hour: _selectedHour, minute: _selectedMinute);
    }
    final int hour24;
    if (_selectedPeriod == DayPeriod.pm) {
      hour24 = _selectedHour == 12 ? 12 : _selectedHour + 12;
    } else {
      hour24 = _selectedHour == 12 ? 0 : _selectedHour;
    }
    return TimeOfDay(hour: hour24, minute: _selectedMinute);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = theme.cardColor;
    final is24Hour = MediaQuery.of(context).alwaysUse24HourFormat;
    final localizations = MaterialLocalizations.of(context);

    final Color surfaceGradientStart = isDark
        ? (Color.lerp(baseColor, Colors.white, 0.04) ?? baseColor)
        : (Color.lerp(baseColor, Colors.white, 0.45) ?? baseColor);

    final Color surfaceGradientEnd = isDark
        ? (Color.lerp(baseColor, Colors.black, 0.15) ?? baseColor)
        : (Color.lerp(baseColor, const Color(0xFFA3B1C6), 0.08) ?? baseColor);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 380),
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
            decoration: BoxDecoration(
              borderRadius: AppRadius.dialogRadius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [surfaceGradientStart, surfaceGradientEnd],
              ),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : Colors.white.withValues(alpha: 0.85),
                width: 1.2,
              ),
              boxShadow: AppShadows.softCard(isDark: isDark),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Tactile Header Badge ─────────────────────────────────────
                // Container(
                //   width: 50,
                //   height: 50,
                //   decoration: BoxDecoration(
                //     shape: BoxShape.circle,
                //     color: Color.alphaBlend(
                //       colorScheme.primary.withValues(alpha: isDark ? 0.16 : 0.10),
                //       baseColor,
                //     ),
                //     border: Border.all(
                //       color: isDark
                //           ? Colors.white.withValues(alpha: 0.08)
                //           : Colors.white.withValues(alpha: 0.90),
                //       width: 1.0,
                //     ),
                //     boxShadow: [
                //       ...AppShadows.badge(isDark: isDark),
                //       ...AppShadows.bloom(
                //         color: colorScheme.primary,
                //         isDark: isDark,
                //         blur: 8,
                //         offset: const Offset(0, 2),
                //       ),
                //     ],
                //   ),
                //   child: Center(
                //     child: Icon(
                //       Icons.alarm_rounded,
                //       color: colorScheme.primary,
                //       size: 24,
                //       shadows: AppShadows.buttonPressed(isDark: isDark),
                //     ),
                //   ),
                // ),
                // const SizedBox(height: 12),

                // ── Dialog Title ──────────────────────────────────────────────
                Text(
                  S.of(context).dailyReminder,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                    fontSize: 18,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  S.of(context).setDailyReminder,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),

                // ── Deep Recessed Time Display Basin ──────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? (Color.lerp(baseColor, Colors.black, 0.25) ??
                              baseColor)
                        : (Color.lerp(
                                baseColor,
                                const Color(0xFFDCE2EC),
                                0.35,
                              ) ??
                              baseColor),
                    borderRadius: BorderRadius.circular(AppRadius.well),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.white.withValues(alpha: 0.70),
                      width: 1.0,
                    ),
                    boxShadow: AppShadows.wellDual(isDark: isDark),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Hour Stepper
                      _TimeStepperColumn(
                        valueText: _selectedHour.toString().padLeft(2, '0'),
                        onIncrement: () => _incrementHour(is24Hour),
                        onDecrement: () => _decrementHour(is24Hour),
                      ),
                      const SizedBox(width: 8),

                      // Animated Colon Divider
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          ':',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Minute Stepper
                      _TimeStepperColumn(
                        valueText: _selectedMinute.toString().padLeft(2, '0'),
                        onIncrement: _incrementMinute,
                        onDecrement: _decrementMinute,
                      ),

                      // AM/PM Toggle (if 12h format)
                      if (!is24Hour) ...[
                        const SizedBox(width: 14),
                        _buildPeriodSelector(
                          context,
                          isDark,
                          colorScheme,
                          localizations,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Quick Presets ─────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPresetChip(
                      context,
                      icon: Icons.wb_sunny_outlined,
                      label: '07:00',
                      onTap: () => _applyPreset(7, 0),
                    ),
                    _buildPresetChip(
                      context,
                      icon: Icons.light_mode_outlined,
                      label: '12:00',
                      onTap: () => _applyPreset(12, 0),
                    ),
                    _buildPresetChip(
                      context,
                      icon: Icons.nights_stay_outlined,
                      label: '18:00',
                      onTap: () => _applyPreset(18, 0),
                    ),
                    _buildPresetChip(
                      context,
                      icon: Icons.bedtime_outlined,
                      label: '21:00',
                      onTap: () => _applyPreset(21, 0),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Action Buttons ────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _NeumorphicDialogButton(
                        label: S.of(context).cancel,
                        icon: Icons.close_rounded,
                        isPrimary: false,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _NeumorphicDialogButton(
                        label: S.of(context).save,
                        icon: Icons.check_rounded,
                        isPrimary: true,
                        primaryColor: colorScheme.primary,
                        onPressed: () {
                          final result = _calculateFinalTime(is24Hour);
                          Navigator.of(context).pop(result);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(
    BuildContext context,
    bool isDark,
    ColorScheme colorScheme,
    MaterialLocalizations localizations,
  ) {
    final amLabel = localizations.anteMeridiemAbbreviation;
    final pmLabel = localizations.postMeridiemAbbreviation;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withValues(alpha: 0.22)
            : const Color(0xFFDCE2EC).withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.white.withValues(alpha: 0.70),
          width: 0.8,
        ),
        boxShadow: AppShadows.wellDual(isDark: isDark),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPeriodButton(
            label: amLabel,
            isSelected: _selectedPeriod == DayPeriod.am,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedPeriod = DayPeriod.am);
            },
            colorScheme: colorScheme,
            isDark: isDark,
          ),
          const SizedBox(height: 4),
          _buildPeriodButton(
            label: pmLabel,
            isSelected: _selectedPeriod == DayPeriod.pm,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedPeriod = DayPeriod.pm);
            },
            colorScheme: colorScheme,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [colorScheme.primary, colorScheme.secondary],
                )
              : null,
          boxShadow: isSelected
              ? [
                  ...AppShadows.buttonResting(isDark: isDark),
                  BoxShadow(
                    color: colorScheme.primary.withValues(
                      alpha: isDark ? 0.40 : 0.25,
                    ),
                    blurRadius: 5,
                    offset: const Offset(0, 1.5),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected
                ? colorScheme.onPrimary
                : colorScheme.onSurfaceVariant,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildPresetChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final baseSurface = theme.cardColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            colorScheme.onSurface.withValues(alpha: isDark ? 0.04 : 0.02),
            baseSurface,
          ),
          borderRadius: BorderRadius.circular(AppRadius.badge),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.70),
            width: 0.9,
          ),
          boxShadow: AppShadows.badge(isDark: isDark),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A vertical stepper column displaying an increment button,
/// an embossed digit box, and a decrement button.
class _TimeStepperColumn extends StatelessWidget {
  final String valueText;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _TimeStepperColumn({
    required this.valueText,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = theme.cardColor;

    final Color surfaceStart = isDark
        ? (Color.lerp(baseColor, Colors.white, 0.06) ?? baseColor)
        : (Color.lerp(baseColor, Colors.white, 0.65) ?? baseColor);

    final Color surfaceEnd = isDark
        ? (Color.lerp(baseColor, Colors.black, 0.18) ?? baseColor)
        : (Color.lerp(baseColor, const Color(0xFFA3B1C6), 0.12) ?? baseColor);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepperButton(
          icon: Icons.keyboard_arrow_up_rounded,
          onTap: onIncrement,
        ),
        const SizedBox(height: 6),
        Container(
          width: 64,
          height: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [surfaceStart, surfaceEnd],
            ),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.90),
              width: 1.0,
            ),
            boxShadow: AppShadows.buttonResting(isDark: isDark),
          ),
          child: Text(
            valueText,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurface,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 6),
        _StepperButton(
          icon: Icons.keyboard_arrow_down_rounded,
          onTap: onDecrement,
        ),
      ],
    );
  }
}

/// A compact tactile stepper button with press-in depth.
class _StepperButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepperButton({
    required this.icon,
    required this.onTap,
  });

  @override
  State<_StepperButton> createState() => _StepperButtonState();
}

class _StepperButtonState extends State<_StepperButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = theme.cardColor;

    final Color surfaceStart = isDark
        ? (Color.lerp(baseColor, Colors.white, 0.05) ?? baseColor)
        : (Color.lerp(baseColor, Colors.white, 0.55) ?? baseColor);

    final Color surfaceEnd = isDark
        ? (Color.lerp(baseColor, Colors.black, 0.16) ?? baseColor)
        : (Color.lerp(baseColor, const Color(0xFFA3B1C6), 0.10) ?? baseColor);

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        width: 48,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          gradient: _isPressed
              ? null
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [surfaceStart, surfaceEnd],
                ),
          color: _isPressed
              ? (isDark
                    ? Colors.black.withValues(alpha: 0.32)
                    : const Color(0xFFD3DCE8))
              : null,
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: _isPressed ? 0.03 : 0.06)
                : Colors.white.withValues(alpha: _isPressed ? 0.40 : 0.85),
            width: 1.0,
          ),
          boxShadow: _isPressed
              ? AppShadows.buttonPressed(isDark: isDark)
              : AppShadows.buttonResting(isDark: isDark),
        ),
        child: Center(
          child: Icon(
            widget.icon,
            size: 20,
            color: colorScheme.onSurface,
            shadows: _isPressed
                ? AppShadows.buttonPressed(isDark: isDark)
                : null,
          ),
        ),
      ),
    );
  }
}

/// Tactile Neumorphic Button with press-in physical depth feedback.
class _NeumorphicDialogButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final Color? primaryColor;
  final VoidCallback onPressed;

  const _NeumorphicDialogButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    this.primaryColor,
    required this.onPressed,
  });

  @override
  State<_NeumorphicDialogButton> createState() =>
      _NeumorphicDialogButtonState();
}

class _NeumorphicDialogButtonState extends State<_NeumorphicDialogButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = theme.cardColor;

    final primaryColor = widget.primaryColor ?? colorScheme.primary;

    final Color surfaceColor;
    if (widget.isPrimary) {
      surfaceColor = primaryColor;
    } else {
      surfaceColor = isDark
          ? (Color.lerp(baseColor, Colors.white, 0.04) ?? baseColor)
          : (Color.lerp(baseColor, Colors.white, 0.50) ?? baseColor);
    }

    final Color textColor = widget.isPrimary
        ? ThemeUtils.getContrastColor(primaryColor)
        : colorScheme.onSurfaceVariant;

    final Color iconColor = widget.isPrimary
        ? textColor
        : colorScheme.onSurfaceVariant;

    final List<BoxShadow> shadows;
    if (_isPressed) {
      shadows = AppShadows.buttonPressed(isDark: isDark);
    } else if (widget.isPrimary) {
      shadows = [
        ...AppShadows.bloom(
          color: primaryColor,
          isDark: isDark,
          blur: 8,
          spread: 0.5,
          offset: const Offset(0, 2.5),
        ),
        BoxShadow(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.white.withValues(alpha: 0.85),
          offset: const Offset(-2, -2),
          blurRadius: 4,
        ),
      ];
    } else {
      shadows = AppShadows.buttonResting(isDark: isDark);
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: surfaceColor,
          gradient: widget.isPrimary
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryColor, colorScheme.secondary],
                )
              : null,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: widget.isPrimary
                ? Colors.white.withValues(alpha: isDark ? 0.25 : 0.85)
                : (isDark
                      ? Colors.white.withValues(alpha: _isPressed ? 0.03 : 0.06)
                      : Colors.white.withValues(
                          alpha: _isPressed ? 0.40 : 0.85,
                        )),
            width: 1.0,
          ),
          boxShadow: shadows,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              size: 20,
              color: iconColor,
              shadows: _isPressed
                  ? AppShadows.buttonPressed(isDark: isDark)
                  : null,
            ),
            const SizedBox(width: 6),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
