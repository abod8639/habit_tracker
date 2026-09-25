import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:habit_tracker/core/components/app_confirmation_dialog.dart';
import 'package:habit_tracker/features/theme/data/datasources/theme_utils.dart';
import 'package:habit_tracker/generated/l10n.dart';

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

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      reverseDuration: const Duration(milliseconds: 140),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.90).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _handleTap() async {
    if (widget.isSelectionMode) {
      widget.onTap?.call();
      return;
    }

    // Smooth press feedback animation
    await _pressController.forward();
    if (mounted) {
      await _pressController.reverse();
    }
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
      return themeColors.onSurface.withValues(alpha: 0.50);
    }
    return themeColors.onSurface;
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    final themeColors = Theme.of(context).colorScheme;

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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: themeColors.errorContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: themeColors.error.withValues(alpha: 0.2),
            width: 1,
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
      child: Slidable(
        startActionPane: _buildActionPane(
          icon: Icons.delete_outline_rounded,
          color: themeColors.errorContainer,
          foregroundColor: themeColors.onErrorContainer,
          onPressed: widget.onDelete != null
              ? (context) => _showDeleteConfirmationDialog(context)
              : null,
        ),
        endActionPane: _buildActionPane(
          icon: Icons.edit_outlined,
          color: themeColors.secondaryContainer,
          foregroundColor: themeColors.onSecondaryContainer,
          onPressed: widget.onEdit,
        ),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: _handleTap,
              onLongPress: widget.onLongPress,
              child: _buildNeumorphicTile(theme, themeColors, textTheme),
            ),
          ),
        ),
      ),
    );
  }

  ActionPane _buildActionPane({
    required IconData icon,
    required Color color,
    Color? foregroundColor,
    required Function(BuildContext)? onPressed,
  }) {
    return ActionPane(
      motion: const ScrollMotion(),
      children: [
        SlidableAction(
          borderRadius: BorderRadius.circular(20),
          backgroundColor: color,
          foregroundColor: foregroundColor,
          onPressed: onPressed,
          icon: icon,
        ),
      ],
    );
  }

  Widget _buildNeumorphicTile(
    ThemeData theme,
    ColorScheme themeColors,
    TextTheme textTheme,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = _getBaseColor(themeColors);

    // Neumorphic surface base color
    Color surfaceColor;
    if (widget.isSelected) {
      surfaceColor = Color.alphaBlend(
        themeColors.primary.withValues(alpha: isDark ? 0.20 : 0.12),
        themeColors.surface,
      );
    } else if (widget.habitCompleted) {
      surfaceColor = Color.alphaBlend(
        baseColor.withValues(alpha: isDark ? 0.14 : 0.07),
        themeColors.surface,
      );
    } else {
      surfaceColor = widget.colorValue != null
          ? Color.alphaBlend(
              baseColor.withValues(alpha: isDark ? 0.08 : 0.035),
              themeColors.surface,
            )
          : themeColors.surface;
    }

    // Soft UI Shadows
    List<BoxShadow> shadows;
    if (widget.isSelected) {
      shadows = [
        BoxShadow(
          color: themeColors.primary.withValues(alpha: isDark ? 0.35 : 0.25),
          offset: const Offset(0, 4),
          blurRadius: 14,
          spreadRadius: 1,
        ),
      ];
    } else if (widget.habitCompleted) {
      // Completed state: recessed/soft indented feel
      shadows = [
        // Subtle top-left light
        BoxShadow(
          color: isDark
              ? Colors.white.withValues(alpha: 0.02)
              : Colors.white.withValues(alpha: 0.6),
          offset: const Offset(-2, -2),
          blurRadius: 4,
        ),
        // Subtle bottom-right shadow
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.35)
              : const Color(0xFFA3B1C6).withValues(alpha: 0.25),
          offset: const Offset(2, 2),
          blurRadius: 5,
        ),
        // Soft colored accent glow
        BoxShadow(
          color: baseColor.withValues(alpha: isDark ? 0.18 : 0.12),
          offset: const Offset(0, 2),
          blurRadius: 8,
          spreadRadius: -1,
        ),
      ];
    } else {
      // Uncompleted state: elevated/extruded Soft UI feel
      shadows = [
        // Top-left ambient highlight
        BoxShadow(
          color: isDark
              ? Colors.white.withValues(alpha: 0.055)
              : Colors.white.withValues(alpha: 0.90),
          offset: const Offset(-4, -4),
          blurRadius: 8,
        ),
        // Bottom-right depth shadow
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.50)
              : const Color(0xFFA3B1C6).withValues(alpha: 0.40),
          offset: const Offset(4, 4),
          blurRadius: 8,
        ),
      ];
    }

    // Soft UI subtle gradients
    final Gradient? gradient;
    if (widget.isSelected) {
      gradient = null;
    } else if (widget.habitCompleted) {
      // Inverted gradient to enhance depressed/pressed depth
      gradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.alphaBlend(
            isDark
                ? Colors.black.withValues(alpha: 0.10)
                : Colors.black.withValues(alpha: 0.03),
            surfaceColor,
          ),
          surfaceColor,
        ],
      );
    } else {
      // Convex subtle gradient for raised element
      gradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          surfaceColor,
          Color.alphaBlend(
            isDark
                ? Colors.black.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.03),
            surfaceColor,
          ),
        ],
      );
    }

    // Border styling
    final Border border;
    if (widget.isSelected) {
      border = Border.all(
        color: themeColors.primary.withValues(alpha: 0.8),
        width: 1.5,
      );
    } else if (widget.habitCompleted) {
      border = Border.all(
        color: baseColor.withValues(alpha: isDark ? 0.25 : 0.20),
        width: 1,
      );
    } else {
      border = Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.white.withValues(alpha: 0.65),
        width: 1,
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        gradient: gradient,
        boxShadow: shadows,
        border: border,
      ),
      child: Row(
        children: [
          _buildNeumorphicIndicator(themeColors, isDark, baseColor),
          const SizedBox(width: 14),
          Expanded(child: _buildTitleText(themeColors, textTheme)),
        ],
      ),
    );
  }

  Widget _buildNeumorphicIndicator(
    ColorScheme themeColors,
    bool isDark,
    Color baseColor,
  ) {
    if (widget.isSelectionMode) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.isSelected
              ? themeColors.primary
              : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04)),
          border: Border.all(
            color: widget.isSelected
                ? themeColors.primary
                : themeColors.onSurfaceVariant.withValues(alpha: 0.35),
            width: 1.5,
          ),
        ),
        child: widget.isSelected
            ? const Icon(
                Icons.check_rounded,
                size: 16,
                color: Colors.white,
              )
            : null,
      );
    }

    // Neumorphic Checkbox / Toggle
    final isChecked = widget.habitCompleted;

    return GestureDetector(
      onTap: () => widget.onChanged?.call(!widget.habitCompleted),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutCubic,
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          color: isChecked
              ? baseColor
              : (isDark
                  ? Color.alphaBlend(Colors.white.withValues(alpha: 0.04), themeColors.surface)
                  : Color.alphaBlend(Colors.black.withValues(alpha: 0.02), themeColors.surface)),
          boxShadow: isChecked
              ? [
                  BoxShadow(
                    color: baseColor.withValues(alpha: isDark ? 0.40 : 0.30),
                    offset: const Offset(0, 2),
                    blurRadius: 6,
                  ),
                ]
              : [
                  BoxShadow(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.white.withValues(alpha: 0.9),
                    offset: const Offset(-1.5, -1.5),
                    blurRadius: 3,
                  ),
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.4)
                        : const Color(0xFFA3B1C6).withValues(alpha: 0.45),
                    offset: const Offset(1.5, 1.5),
                    blurRadius: 3,
                  ),
                ],
          border: Border.all(
            color: isChecked
                ? Colors.transparent
                : (isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.white.withValues(alpha: 0.8)),
            width: 1,
          ),
        ),
        child: AnimatedScale(
          scale: isChecked ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: Icon(
            Icons.check_rounded,
            size: 18,
            color: ThemeUtils.getContrastColor(baseColor),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleText(ColorScheme themeColors, TextTheme textTheme) {
    final textColor = _getTileTextColor(themeColors);
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOutCubic,
      style: (textTheme.titleMedium ?? const TextStyle()).copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 15.5,
        letterSpacing: 0.2,
        color: textColor,
        decoration: widget.habitCompleted
            ? TextDecoration.lineThrough
            : TextDecoration.none,
        decorationColor: textColor.withValues(alpha: 0.5),
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

