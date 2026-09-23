import 'package:flutter/material.dart';

/// Material 3 Navigation Drawer Tile
class MyDrawerListTile extends StatefulWidget {
  final Widget? icon;
  final String title;
  final VoidCallback? onTap;
  final bool isSelected;
  final Widget? trailing;

  const MyDrawerListTile({
    this.onTap,
    this.icon,
    this.title = "test",
    this.isSelected = false,
    this.trailing,
    super.key,
  });

  @override
  State<MyDrawerListTile> createState() => _MyDrawerListTileState();
}

class _MyDrawerListTileState extends State<MyDrawerListTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Material 3 Navigation Drawer tokens
    final Color backgroundColor;
    if (widget.isSelected) {
      backgroundColor = colorScheme.secondaryContainer;
    } else if (_isHovered) {
      backgroundColor = colorScheme.onSurface.withValues(alpha: 0.08);
    } else {
      backgroundColor = Colors.transparent;
    }

    final Color foregroundColor = widget.isSelected
        ? colorScheme.onSecondaryContainer
        : colorScheme.onSurface;

    final Color iconColor = widget.isSelected
        ? colorScheme.onSecondaryContainer
        : colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        height: 56.0,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(28.0),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(28.0),
            onTap: widget.onTap,
            onHover: (hovered) {
              if (_isHovered != hovered) {
                setState(() => _isHovered = hovered);
              }
            },
            splashColor: colorScheme.primary.withValues(alpha: 0.12),
            highlightColor: colorScheme.primary.withValues(alpha: 0.06),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  if (widget.icon != null) ...[
                    IconTheme(
                      data: IconThemeData(
                        color: iconColor,
                        size: 24.0,
                      ),
                      child: widget.icon!,
                    ),
                    const SizedBox(width: 12.0),
                  ],
                  Expanded(
                    child: Text(
                      widget.title,
                      style:
                          theme.textTheme.labelLarge?.copyWith(
                            fontSize: 14.5,
                            fontWeight: widget.isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: foregroundColor,
                            letterSpacing: 0.1,
                          ) ??
                          TextStyle(
                            fontSize: 14.5,
                            fontWeight: widget.isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: foregroundColor,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.trailing != null) ...[
                    const SizedBox(width: 8.0),
                    widget.trailing!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
