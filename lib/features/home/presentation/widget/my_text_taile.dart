import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:habit_tracker/core/components/app_confirmation_dialog.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';
import 'package:habit_tracker/core/theme/theme_utils.dart';
import 'package:habit_tracker/generated/l10n.dart';

/// Fully tactile Neumorphic / Soft UI Habit List Tile.
///
/// Implements authentic dual-source ambient lighting, directional gradients,
/// debossed sunken well transitions for completed habits, interactive 3D extruded
/// toggles, and sculpted Neumorphic slidable actions.
class MyTextTaile extends StatefulWidget {
  final String habitName;
  final bool habitCompleted;
  final Function(BuildContext)? onDelete;
  final Function(BuildContext)? onEdit;
  final Function(bool?)? onChanged;
  final Function()? onTap;
  final Function()? onLongPress;
  final bool isSelected;
  final bool isSelectionMode;
  final int? colorValue;

  const MyTextTaile({
    required this.habitName,
    required this.habitCompleted,
    required this.onChanged,
    required this.onDelete,
    required this.onEdit,
    required this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.colorValue,
    super.key,
  });

  @override
  State<MyTextTaile> createState() => _MyTextTaileState();
}

class _MyTextTaileState extends State<MyTextTaile>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 60),
      reverseDuration: const Duration(milliseconds: 90),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.90).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _handleTap() {
    // Call the tap callback immediately with zero delay
    widget.onTap?.call();
  }

  Color _getBaseColor(ColorScheme themeColors) {
    return widget.colorValue != null
        ? Color(widget.colorValue!)
        : themeColors.primary;
  }

  Color _getTileTextColor(ColorScheme themeColors) {
    if (widget.isSelected) {
      return themeColors.primary;
    }
    if (widget.habitCompleted) {
      return themeColors.onSurface.withValues(alpha: 0.45);
    }
    return themeColors.onSurface;
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    final theme = Theme.of(context);
    final themeColors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    AppConfirmationDialog.show(
      context: context,
      title: S.of(context).deleteHabit,
      message: S.of(context).areYouSureYouWantToDeleteThisHabit,
      icon: Icons.delete_outline_rounded,
      confirmText: S.of(context).delete,
      cancelText: S.of(context).cancel,
      isDestructive: true,
      customContent: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            themeColors.error.withValues(alpha: isDark ? 0.12 : 0.08),
            theme.cardColor,
          ),
          borderRadius: AppRadius.mdRadius,
          boxShadow: AppShadows.insetWell(isDark: isDark),
          border: Border.all(
            color: themeColors.error.withValues(alpha: isDark ? 0.30 : 0.25),
            width: 1.0,
          ),
        ),
        child: Text(
          widget.habitName,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: themeColors.error,
            fontSize: 15,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ),
      onConfirm: () => widget.onDelete?.call(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeColors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 5.5),
      child: Slidable(
        key: ValueKey(widget.habitName),
        startActionPane: _buildNeumorphicActionPane(
          icon: Icons.delete_outline_rounded,
          baseColor: themeColors.error,
          tooltip: S.of(context).delete,
          isDark: isDark,
          onPressed: widget.onDelete != null
              ? (context) => _showDeleteConfirmationDialog(context)
              : null,
        ),
        endActionPane: _buildNeumorphicActionPane(
          icon: Icons.edit_outlined,
          baseColor: themeColors.secondary,
          tooltip: 'Edit',
          isDark: isDark,
          onPressed: widget.onEdit,
        ),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: AppRadius.cardRadius,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              onTapDown: (_) {
                if (!widget.isSelectionMode) {
                  _pressController.forward();
                }
              },
              onTapUp: (_) {
                if (!widget.isSelectionMode) {
                  _pressController.reverse();
                }
              },
              onTapCancel: () {
                if (!widget.isSelectionMode) {
                  _pressController.reverse();
                }
              },
              onTap: _handleTap,
              onLongPress: widget.onLongPress,
              onHover: (hovered) {
                if (_isHovered != hovered) {
                  setState(() => _isHovered = hovered);
                }
              },
              child: _buildNeumorphicTile(theme, themeColors, textTheme, isDark),
            ),
          ),
        ),
      ),
    );
  }

  /// Sculpted Neumorphic Action Pane for swipe actions.
  ActionPane _buildNeumorphicActionPane({
    required IconData icon,
    required Color baseColor,
    required String tooltip,
    required bool isDark,
    required Function(BuildContext)? onPressed,
  }) {
    return ActionPane(
      motion: const ScrollMotion(),
      extentRatio: 0.22,
      children: [
        CustomSlidableAction(
          onPressed: onPressed,
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Tooltip(
            message: tooltip,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                borderRadius: AppRadius.mdRadius,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(
                      baseColor,
                      Colors.white,
                      isDark ? 0.08 : 0.40,
                    )!,
                    Color.lerp(
                      baseColor,
                      isDark ? Colors.black : const Color(0xFFA3B1C6),
                      isDark ? 0.20 : 0.08,
                    )!,
                  ],
                ),
                boxShadow: [
                  ...AppShadows.buttonResting(isDark: isDark),
                  BoxShadow(
                    color: baseColor.withValues(alpha: isDark ? 0.35 : 0.20),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.white.withValues(alpha: 0.90),
                  width: 1.0,
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 22,
                  color: ThemeUtils.getContrastColor(baseColor),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Neumorphic Main Tile Surface
  Widget _buildNeumorphicTile(
    ThemeData theme,
    ColorScheme themeColors,
    TextTheme textTheme,
    bool isDark,
  ) {
    final habitColor = _getBaseColor(themeColors);
    final cardBase = theme.cardColor;

    // ── 1. Calculate Neumorphic Surface Base Color ─────────────────────────────
    Color surfaceColor;
    if (widget.isSelected) {
      surfaceColor = Color.alphaBlend(
        themeColors.primary.withValues(alpha: isDark ? 0.20 : 0.12),
        cardBase,
      );
    } else if (widget.habitCompleted) {
      surfaceColor = Color.alphaBlend(
        habitColor.withValues(alpha: isDark ? 0.10 : 0.05),
        cardBase,
      );
    } else if (_isHovered) {
      surfaceColor = Color.alphaBlend(
        themeColors.onSurface.withValues(alpha: isDark ? 0.05 : 0.025),
        cardBase,
      );
    } else {
      surfaceColor = widget.colorValue != null
          ? Color.alphaBlend(
              habitColor.withValues(alpha: isDark ? 0.06 : 0.025),
              cardBase,
            )
          : cardBase;
    }

    // ── 2. Dual Lighting Directional Gradients ────────────────────────────────
    final Gradient gradient;
    if (widget.isSelected) {
      gradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(surfaceColor, Colors.white, isDark ? 0.06 : 0.35)!,
          Color.lerp(
            surfaceColor,
            isDark ? Colors.black : const Color(0xFFA3B1C6),
            isDark ? 0.14 : 0.08,
          )!,
        ],
      );
    } else if (widget.habitCompleted) {
      // Signature Neumorphic Inverted (Concave / Debossed) gradient for pressed item
      gradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(
            surfaceColor,
            isDark ? Colors.black : const Color(0xFFA3B1C6),
            isDark ? 0.14 : 0.09,
          )!,
          Color.lerp(surfaceColor, Colors.white, isDark ? 0.03 : 0.35)!,
        ],
      );
    } else {
      // Signature Neumorphic Convex (Elevated / Extruded) gradient for resting item
      gradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(surfaceColor, Colors.white, isDark ? 0.05 : 0.45)!,
          Color.lerp(
            surfaceColor,
            isDark ? Colors.black : const Color(0xFFA3B1C6),
            isDark ? 0.14 : 0.08,
          )!,
        ],
      );
    }

    // ── 3. Tactile Dual Shadows ────────────────────────────────────────────────
    List<BoxShadow> shadows;
    if (widget.isSelected) {
      shadows = AppShadows.selectedCard(
        primary: themeColors.primary,
        isDark: isDark,
      );
    } else if (widget.habitCompleted) {
      // Sunken recessed well shadows + soft ambient color bloom
      shadows = [
        ...AppShadows.wellDual(isDark: isDark),
        ...AppShadows.bloom(
          color: habitColor,
          isDark: isDark,
          blur: 10,
          spread: -1,
          offset: const Offset(0, 2),
        ),
      ];
    } else if (_isHovered) {
      shadows = AppShadows.softCard(isDark: isDark);
    } else {
      shadows = AppShadows.subtleCard(isDark: isDark);
    }

    // ── 4. Specular Bevel Border ──────────────────────────────────────────────
    final Border border;
    if (widget.isSelected) {
      border = Border.all(
        color: themeColors.primary.withValues(alpha: isDark ? 0.85 : 0.75),
        width: 1.5,
      );
    } else if (widget.habitCompleted) {
      border = Border.all(
        color: habitColor.withValues(alpha: isDark ? 0.30 : 0.22),
        width: 1.1,
      );
    } else {
      border = Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: _isHovered ? 0.09 : 0.05)
            : Colors.white.withValues(alpha: _isHovered ? 0.95 : 0.82),
        width: 1.1,
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: AppRadius.cardRadius,
        gradient: gradient,
        boxShadow: shadows,
        border: border,
      ),
      child: Row(
        children: [
          // Neumorphic Checkbox / Selection Toggle
          _buildNeumorphicIndicator(themeColors, isDark, habitColor, cardBase),
          const SizedBox(width: 14),

          // Habit Title with smooth style transition
          Expanded(child: _buildTitleText(themeColors, textTheme)),

          // Optional Neumorphic Accent Pill indicator for custom-colored habits
          if (widget.colorValue != null) ...[
            const SizedBox(width: 10),
            _buildHabitColorPill(habitColor, isDark),
          ],
        ],
      ),
    );
  }

  /// Neumorphic Checkbox / Toggle Indicator
  Widget _buildNeumorphicIndicator(
    ColorScheme themeColors,
    bool isDark,
    Color habitColor,
    Color cardBase,
  ) {
    if (widget.isSelectionMode) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.isSelected
              ? themeColors.primary
              : (isDark
                  ? Color.lerp(cardBase, Colors.black, 0.20)
                  : Color.lerp(cardBase, const Color(0xFFA3B1C6), 0.15)),
          boxShadow: widget.isSelected
              ? AppShadows.bloom(
                  color: themeColors.primary,
                  isDark: isDark,
                  blur: 8,
                  offset: const Offset(0, 2),
                )
              : AppShadows.insetWell(isDark: isDark),
          border: Border.all(
            color: widget.isSelected
                ? Colors.white.withValues(alpha: isDark ? 0.40 : 0.85)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.90)),
            width: 1.2,
          ),
        ),
        child: widget.isSelected
            ? const Icon(
                Icons.check_rounded,
                size: 17,
                color: Colors.white,
              )
            : null,
      );
    }

    final isChecked = widget.habitCompleted;

    // Tactile Neumorphic Soft UI Squircle Checkbox
    return GestureDetector(
      onTap: () => widget.onChanged?.call(!widget.habitCompleted),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: isChecked
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(habitColor, Colors.white, 0.15)!,
                    Color.lerp(habitColor, Colors.black, 0.10)!,
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(cardBase, Colors.white, isDark ? 0.06 : 0.60)!,
                    Color.lerp(
                      cardBase,
                      isDark ? Colors.black : const Color(0xFFA3B1C6),
                      isDark ? 0.18 : 0.12,
                    )!,
                  ],
                ),
          boxShadow: isChecked
              ? [
                  ...AppShadows.bloom(
                    color: habitColor,
                    isDark: isDark,
                    blur: 8,
                    spread: 0.5,
                    offset: const Offset(0, 2),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: isDark ? 0.20 : 0.50),
                    offset: const Offset(-1, -1),
                    blurRadius: 3,
                  ),
                ]
              : AppShadows.buttonResting(isDark: isDark),
          border: Border.all(
            color: isChecked
                ? Colors.white.withValues(alpha: isDark ? 0.35 : 0.70)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.95)),
            width: 1.1,
          ),
        ),
        child: isChecked
            ? AnimatedScale(
                scale: 1.0,
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOutBack,
                child: Icon(
                  Icons.check_rounded,
                  size: 19,
                  color: ThemeUtils.getContrastColor(habitColor),
                ),
              )
            : (widget.colorValue != null
                ? Center(
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: habitColor.withValues(alpha: 0.65),
                        boxShadow: AppShadows.dotIndicator(isDark: isDark),
                      ),
                    ),
                  )
                : null),
      ),
    );
  }

  /// Neumorphic Habit Accent Pill (displays custom habit color subtly)
  Widget _buildHabitColorPill(Color habitColor, bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      width: 5,
      height: 22,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        color: widget.habitCompleted
            ? habitColor.withValues(alpha: isDark ? 0.35 : 0.30)
            : habitColor,
        boxShadow: widget.habitCompleted
            ? null
            : [
                BoxShadow(
                  color: habitColor.withValues(alpha: isDark ? 0.40 : 0.30),
                  blurRadius: 5,
                  spreadRadius: 0.5,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
    );
  }

  /// Habit Title Text Widget with animated style transition
  Widget _buildTitleText(ColorScheme themeColors, TextTheme textTheme) {
    final textColor = _getTileTextColor(themeColors);
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      style: (textTheme.titleMedium ?? const TextStyle()).copyWith(
        fontWeight: widget.habitCompleted ? FontWeight.w500 : FontWeight.w600,
        fontSize: 15.5,
        letterSpacing: 0.2,
        color: textColor,
        decoration: widget.habitCompleted
            ? TextDecoration.lineThrough
            : TextDecoration.none,
        decorationColor: textColor.withValues(alpha: 0.55),
        decorationThickness: 2,
      ),
      child: Text(
        widget.habitName,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}


