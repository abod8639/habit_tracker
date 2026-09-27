import 'package:flutter/material.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';
import 'package:habit_tracker/generated/l10n.dart';

class MyfloatingActionButton extends StatefulWidget {
  final Function()? onPressed;
  const MyfloatingActionButton({this.onPressed, super.key});

  @override
  State<MyfloatingActionButton> createState() => _MyfloatingActionButtonState();
}

class _MyfloatingActionButtonState extends State<MyfloatingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    final Color gradientStart = isDark
        ? (Color.lerp(primaryColor, Colors.white, 0.12) ?? primaryColor)
        : (Color.lerp(primaryColor, Colors.white, 0.20) ?? primaryColor);

    final Color gradientEnd = isDark
        ? (Color.lerp(
          primaryColor,
          theme.colorScheme.secondary,
          0.9,
        ) ?? primaryColor)
        : (Color.lerp(
          primaryColor,
          theme.colorScheme.secondary,
          0.9,
        ) ?? primaryColor);

    return MouseRegion(
      onEnter: (_) => _animationController.forward(),
      onExit: (_) => _animationController.reverse(),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _isPressed ? 0.94 : _scaleAnimation.value,
            child: child,
          );
        },
        child: Tooltip(
          message: S.of(context).addNewHabit,
          child: GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) {
              setState(() => _isPressed = false);
              if (widget.onPressed != null) {
                widget.onPressed!();
              }
            },
            onTapCancel: () => setState(() => _isPressed = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOutCubic,
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _isPressed
                      ? [gradientEnd, gradientStart]
                      : [gradientStart, gradientEnd],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: isDark ? 0.25 : 0.60),
                  width: 1.2,
                ),
                boxShadow: _isPressed
                    ? [
                        ...AppShadows.buttonPressed(isDark: isDark),
                        ...AppShadows.bloom(
                          color: primaryColor,
                          isDark: isDark,
                          blur: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [
                        ...AppShadows.buttonResting(isDark: isDark),
                        ...AppShadows.bloom(
                          color: primaryColor,
                          isDark: isDark,
                          blur: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
              ),
              child: Center(
                child: Icon(
                  Icons.add_rounded,
                  size: 28,
                  color: theme.colorScheme.onPrimary,
                  shadows: AppShadows.buttonPressed(isDark: isDark),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
