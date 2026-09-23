import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.habitCompleted) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(MyTextTaile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.habitCompleted != oldWidget.habitCompleted) {
      widget.habitCompleted
          ? _animationController.forward()
          : _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // --- Helper Methods to improve Readability ---

  Color _getTileColor(ColorScheme themeColors) {
    if (widget.isSelected) {
      return themeColors.primary.withValues(alpha: 0.16);
    }

    final baseColor = widget.colorValue != null
        ? Color(widget.colorValue!)
        : themeColors.primary;

    if (widget.habitCompleted) {
      return widget.colorValue != null
          ? baseColor.withValues(alpha: 0.85)
          : baseColor.withValues(alpha: 0.7);
    }

    return widget.colorValue != null
        ? baseColor.withValues(alpha: 0.12)
        : themeColors.surfaceContainerHighest.withValues(alpha: 0.35);
  }

  Color _getTileTextColor(ColorScheme themeColors) {
    if (widget.isSelected) {
      return themeColors.primary;
    }
    if (widget.habitCompleted) {
      return ThemeUtils.getContrastColor(_getTileColor(themeColors));
    }
    return themeColors.onSurface;
  }

  void _handleTap() {
    if (widget.isSelectionMode) {
      widget.onTap?.call();
    } else {
      if (!widget.habitCompleted) {
        _animationController.forward().then(
          (_) => _animationController.reverse(),
        );
      }
      widget.onTap?.call();
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    final themeColors = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          icon: Icon(
            Icons.delete_outline_rounded,
            size: 28,
            color: themeColors.error,
          ),
          title: Text(
            S.of(dialogContext).deleteHabit,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                S.of(dialogContext).areYouSureYouWantToDeleteThisHabit,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: themeColors.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Container(
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
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(S.of(dialogContext).cancel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                widget.onDelete?.call(context);
              },
              style: FilledButton.styleFrom(
                backgroundColor: themeColors.error,
                foregroundColor: themeColors.onError,
              ),
              child: Text(S.of(dialogContext).delete),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeColors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
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
                borderRadius: BorderRadius.circular(16),
                onTap: _handleTap,
                onLongPress: widget.onLongPress,
                child: _buildTileContent(themeColors, textTheme),
              ),
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
          borderRadius: BorderRadius.circular(16),
          backgroundColor: color,
          foregroundColor: foregroundColor,
          onPressed: onPressed,
          icon: icon,
        ),
      ],
    );
  }

  Widget _buildTileContent(ColorScheme themeColors, TextTheme textTheme) {
    final baseColor = widget.colorValue != null
        ? Color(widget.colorValue!)
        : themeColors.primary;

    final border = widget.isSelected
        ? Border.all(color: themeColors.primary, width: 2)
        : Border.all(
            color: widget.habitCompleted
                ? baseColor.withValues(alpha: 0.3)
                : themeColors.outlineVariant.withValues(alpha: 0.4),
            width: 1,
          );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _getTileColor(themeColors),
        borderRadius: BorderRadius.circular(16),
        border: border,
      ),
      child: Row(
        children: [
          _buildLeadingIcon(themeColors),
          const SizedBox(width: 14),
          Expanded(child: _buildTitleText(themeColors, textTheme)),
        ],
      ),
    );
  }

  Widget _buildLeadingIcon(ColorScheme themeColors) {
    final baseColor = widget.colorValue != null
        ? Color(widget.colorValue!)
        : themeColors.primary;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: widget.isSelectionMode
          ? Icon(
              widget.isSelected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              key: const ValueKey('selection_icon'),
              color: widget.isSelected
                  ? themeColors.primary
                  : themeColors.onSurfaceVariant,
            )
          : Checkbox(
              key: const ValueKey('checkbox'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              side: BorderSide(
                color: widget.habitCompleted
                    ? Colors.transparent
                    : (widget.colorValue != null
                        ? baseColor
                        : themeColors.outline),
                width: 2,
              ),
              activeColor: baseColor,
              checkColor: ThemeUtils.getContrastColor(baseColor),
              value: widget.habitCompleted,
              onChanged: widget.onChanged,
            ),
    );
  }

  Widget _buildTitleText(ColorScheme themeColors, TextTheme textTheme) {
    final textColor = _getTileTextColor(themeColors);
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 250),
      style: textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: textColor,
        decoration: widget.habitCompleted
            ? TextDecoration.lineThrough
            : TextDecoration.none,
        decorationColor: textColor.withValues(alpha: 0.6),
      ) ?? TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: textColor,
        decoration: widget.habitCompleted
            ? TextDecoration.lineThrough
            : TextDecoration.none,
        decorationColor: textColor.withValues(alpha: 0.6),
      ),
      child: Text(
        widget.habitName,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
