import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:habit_tracker/features/theme/data/datasources/theme_utils.dart';

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
      return Theme.of(context).primaryColor.withValues(alpha: 0.2);
    }

    final baseColor = widget.colorValue != null
        ? Color(widget.colorValue!)
        : Theme.of(context).primaryColor;

    if (widget.habitCompleted) {
      return widget.colorValue != null
          ? baseColor
          : baseColor.withValues(alpha: 0.7);
    }

    return widget.colorValue != null
        ? baseColor.withValues(alpha: 0.3)
        : (themeColors.brightness == Brightness.light
              ? themeColors.surface
              : Colors.grey[850]!);
  }

  Color _getTileTextColor(ColorScheme themeColors) {
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

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).colorScheme;

    return Material(
      
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Slidable(
          startActionPane: _buildActionPane(
            icon: Icons.delete,
            color: themeColors.error,
            onPressed: widget.onDelete,
          ),
          endActionPane: _buildActionPane(
            icon: Icons.edit,
            color: Colors.orange[700]!,
            onPressed: widget.onEdit,
          ),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              onTap: _handleTap,
              onLongPress: widget.onLongPress,
              title: _buildTileContent(themeColors),
            ),
          ),
        ),
      ),
    );
  }

  ActionPane _buildActionPane({
    required IconData icon,
    required Color color,
    required Function(BuildContext)? onPressed,
  }) {
    return ActionPane(
      motion: const ScrollMotion(),
      children: [
        SlidableAction(
          borderRadius: BorderRadius.circular(10),
          backgroundColor: color,
          onPressed: onPressed,
          icon: icon,
        ),
      ],
    );
  }

Widget _buildTileContent(ColorScheme themeColors) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(12), 
      decoration: BoxDecoration(
        color: _getTileColor(themeColors),
        borderRadius: BorderRadius.circular(15), 
        
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getTileColor(themeColors).withValues(alpha: 0.9),
            _getTileColor(themeColors),
          ],
        ),

        border: widget.isSelected
            ? Border.all(color: themeColors.primary, width: 2)
            : Border.all(
                color: themeColors.brightness == Brightness.light
                    ? Colors.black.withValues(alpha: 0.06)
                    : Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: themeColors.brightness == Brightness.light ? 0.04 : 0.2,
            ),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildLeadingIcon(themeColors),
          const SizedBox(width: 12),
          Expanded(child: _buildTitleText(themeColors)),
        ],
      ),
    );
  }

  Widget _buildLeadingIcon(ColorScheme themeColors) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: widget.isSelectionMode
          ? Icon(
              widget.isSelected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              key: const ValueKey('selection_icon'),
              color: widget.isSelected
                  ? themeColors.onSurface.withValues(alpha: 0.5)
                  : Theme.of(context).primaryColor,
            )
          : Checkbox(
              key: const ValueKey('checkbox'),
              activeColor: Theme.of(context).primaryColor,
              checkColor: Theme.of(context).colorScheme.onPrimary,
              value: widget.habitCompleted,
              onChanged: widget.onChanged,
            ),
    );
  }

  Widget _buildTitleText(ColorScheme themeColors) {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 300),
      style: TextStyle(
        fontWeight: FontWeight.w600,
        color: _getTileTextColor(themeColors),
        decoration: widget.habitCompleted
            ? TextDecoration.lineThrough
            : TextDecoration.none,
      ),
      child: Text(widget.habitName),
    );
  }
}
