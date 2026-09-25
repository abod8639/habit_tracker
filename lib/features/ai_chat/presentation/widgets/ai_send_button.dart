import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Clean Architecture component: 3D Convex Neumorphic send button with
/// tactile spring feedback and loading transition.
class AiSendButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final bool enabled;

  const AiSendButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    this.enabled = true,
  });

  @override
  State<AiSendButton> createState() => _AiSendButtonState();
}

class _AiSendButtonState extends State<AiSendButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
      reverseDuration: const Duration(milliseconds: 130),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (widget.isLoading || !widget.enabled) return;
    HapticFeedback.mediumImpact();
    await _controller.forward();
    if (mounted) {
      await _controller.reverse();
    }
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;
    final surface = theme.colorScheme.surface;

    final isActive = widget.enabled && !widget.isLoading;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: isActive ? _handleTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: isActive
                ? LinearGradient(
                    colors: [
                      Color.alphaBlend(
                        Colors.white.withValues(alpha: 0.2),
                        primary,
                      ),
                      primary,
                      Color.alphaBlend(
                        Colors.black.withValues(alpha: 0.1),
                        secondary,
                      ),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isActive
                ? null
                : (isDark
                    ? Color.alphaBlend(
                        Colors.white.withValues(alpha: 0.05),
                        surface,
                      )
                    : const Color(0xFFF0F3F8)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive
                  ? Colors.white.withValues(alpha: isDark ? 0.25 : 0.4)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.white.withValues(alpha: 0.8)),
              width: 1.2,
            ),
            boxShadow: isActive
                ? [
                    // Top-left soft highlight
                    BoxShadow(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.8),
                      offset: const Offset(-2, -2),
                      blurRadius: 4,
                    ),
                    // Radiant colored bloom / depth
                    BoxShadow(
                      color: primary.withValues(alpha: isDark ? 0.48 : 0.35),
                      offset: const Offset(2, 4),
                      blurRadius: 10,
                    ),
                  ]
                : [
                    // Resting ambient shadows
                    BoxShadow(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.035)
                          : Colors.white.withValues(alpha: 0.9),
                      offset: const Offset(-2, -2),
                      blurRadius: 4,
                    ),
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.4)
                          : const Color(0xFFA3B1C6).withValues(alpha: 0.28),
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  )
                : Icon(
                    Icons.send_rounded,
                    color: isActive
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.20),
                    size: 20,
                  ),
          ),
        ),
      ),
    );
  }
}
