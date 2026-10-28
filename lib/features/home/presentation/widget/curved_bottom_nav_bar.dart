import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/core/guards/ai_guard.dart';
import 'package:habit_tracker/core/routes/app_routes.dart';
import 'package:habit_tracker/features/ai_chat/presentation/pages/ai_chat_page.dart';
import 'package:habit_tracker/features/setting/presentation/pages/settings_page.dart';
import 'package:habit_tracker/generated/l10n.dart';

/// A modern, curved floating Bottom Navigation Bar matching the reference design.
///
/// Features:
/// - Smooth organic curved scoop cutout for the central Floating Action Button.
/// - Left button: Navigates to [SettingsPage].
/// - Center FloatingActionButton: Triggers new habit creation dialog.
/// - Right button: Navigates to [AiChatPage] (protected by [AiGuard]).
/// - Polished light & dark theme styling with soft shadows and micro-interactions.
class CurvedBottomNavBar extends StatelessWidget {
  /// Callback when the central Floating Action Button is tapped.
  final VoidCallback onAddHabit;

  const CurvedBottomNavBar({
    super.key,
    required this.onAddHabit,
  });

  static const double _barHeight = 66.0;
  static const double _fabOverflow = 24.0;
  static const double _totalHeight = _barHeight + _fabOverflow;
  static const double _fabSize = 54.0;

  void _navigateToSettings(BuildContext context) {
    HapticFeedback.lightImpact();
    try {
      context.push(AppRoutes.settings);
    } catch (_) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SettingsPage()),
      );
    }
  }

  void _navigateToAiChat(BuildContext context) {
    HapticFeedback.lightImpact();
    AiGuard.protect(
      context,
      onValid: () {
        try {
          context.push(AppRoutes.aiCoach);
        } catch (_) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AiChatPage()),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: math.max(bottomPadding, 14.0),
      ),
      child: SizedBox(
        height: _totalHeight,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // ── Curved Bar Background Surface ──────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              bottom: 0,
              child: CustomPaint(
                painter: _CurvedBarPainter(
                  isDark: isDark,
                  theme: theme,
                  yTop: _fabOverflow,
                  barHeight: _barHeight,
                ),
              ),
            ),

            // ── Navigation Buttons (Left: Settings, Right: AI Chat) ────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: _barHeight,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  children: [
                    // Left button: Settings
                    Expanded(
                      child: Center(
                        child: _NavBarItem(
                          icon: Icons.settings_outlined,
                          activeIcon: Icons.settings_rounded,
                          tooltip: S.of(context).drawerSetting,
                          isDark: isDark,
                          onTap: () => _navigateToSettings(context),
                        ),
                      ),
                    ),

                    // Middle spacing reserved for the central scoop & FAB
                    const SizedBox(width: 86),

                    // Right button: AI Chat
                    Expanded(
                      child: Center(
                        child: _NavBarItem(
                          icon: Icons.chat_bubble_outline_rounded,
                          activeIcon: Icons.chat_bubble_rounded,
                          tooltip: S.of(context).aiCoach,
                          isDark: isDark,
                          hasSparkleBadge: true,
                          onTap: () => _navigateToAiChat(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Central Floating Action Button (Add Habit) ────────────────
            Positioned(
              top: 0,
              child: _CenterAddButton(
                size: _fabSize,
                onPressed: onAddHabit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter that draws the smooth curved notch and rounded floating bar.
class _CurvedBarPainter extends CustomPainter {
  final bool isDark;
  final ThemeData theme;
  final double yTop;
  final double barHeight;

  const _CurvedBarPainter({
    required this.isDark,
    required this.theme,
    required this.yTop,
    required this.barHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double yBot = yTop + barHeight;
    final double cx = w / 2;
    const double r = 28.0; // Outer corner radius
    const double notchSpread = 48.0; // Half width of scoop
    const double notchDepth = 34.0; // Depth of notch scoop

    final path = Path()
      ..moveTo(r, yTop)
      // Left shoulder
      ..lineTo(cx - notchSpread, yTop)
      // Smooth cubic scoop down to center valley
      ..cubicTo(
        cx - notchSpread * 0.46,
        yTop,
        cx - notchSpread * 0.36,
        yTop + notchDepth,
        cx,
        yTop + notchDepth,
      )
      // Smooth cubic scoop back up to right shoulder
      ..cubicTo(
        cx + notchSpread * 0.36,
        yTop + notchDepth,
        cx + notchSpread * 0.46,
        yTop,
        cx + notchSpread,
        yTop,
      )
      // Top right straight line
      ..lineTo(w - r, yTop)
      // Top right corner
      ..arcToPoint(Offset(w, yTop + r), radius: const Radius.circular(r))
      // Right vertical edge
      ..lineTo(w, yBot - r)
      // Bottom right corner
      ..arcToPoint(Offset(w - r, yBot), radius: const Radius.circular(r))
      // Bottom horizontal line
      ..lineTo(r, yBot)
      // Bottom left corner
      ..arcToPoint(Offset(0, yBot - r), radius: const Radius.circular(r))
      // Left vertical edge
      ..lineTo(0, yTop + r)
      // Top left corner
      ..arcToPoint(Offset(r, yTop), radius: const Radius.circular(r))
      ..close();

    // ── Drop Shadows ────────────────────────────────────────────────────────
    if (isDark) {
      // Dark mode ambient & contact shadows
      final shadowPaint1 = Paint()
        ..color = Colors.black.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
      canvas.drawPath(path.shift(const Offset(0, 6)), shadowPaint1);

      final shadowPaint2 = Paint()
        ..color = Colors.black.withValues(alpha: 0.30)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawPath(path.shift(const Offset(0, 2)), shadowPaint2);
    } else {
      // Light mode soft multi-layer neumorphic/elevation shadows
      final shadowPaint1 = Paint()
        ..color = const Color(0xFF64748B).withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
      canvas.drawPath(path.shift(const Offset(0, 6)), shadowPaint1);

      final shadowPaint2 = Paint()
        ..color = const Color(0xFF0F172A).withValues(alpha: 0.06)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawPath(path.shift(const Offset(0, 2)), shadowPaint2);
    }

    // ── Surface Fill Gradient ──────────────────────────────────────────────
    final surfaceRect = Rect.fromLTWH(0, yTop, w, barHeight);
    final surfacePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDark
            ? [
                const Color(0xFF22242A),
                const Color(0xFF191A1E),
              ]
            : [
                Colors.white,
                const Color(0xFFF6F8FA),
              ],
      ).createShader(surfaceRect);
    canvas.drawPath(path, surfacePaint);

    // ── Subtle Glass/Neumorphic Outer Stroke ────────────────────────────────
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDark
            ? [
                Colors.white.withValues(alpha: 0.14),
                Colors.white.withValues(alpha: 0.04),
              ]
            : [
                Colors.white,
                Colors.black.withValues(alpha: 0.06),
              ],
      ).createShader(surfaceRect);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _CurvedBarPainter oldDelegate) {
    return oldDelegate.isDark != isDark ||
        oldDelegate.theme != theme ||
        oldDelegate.yTop != yTop ||
        oldDelegate.barHeight != barHeight;
  }
}

/// The central Floating Action Button nested into the scoop cutout.
class _CenterAddButton extends StatefulWidget {
  final double size;
  final VoidCallback onPressed;

  const _CenterAddButton({
    required this.size,
    required this.onPressed,
  });

  @override
  State<_CenterAddButton> createState() => _CenterAddButtonState();
}

class _CenterAddButtonState extends State<_CenterAddButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
  }


  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    setState(() => _isPressed = true);
    _animController.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
    _animController.reverse();
    widget.onPressed();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _animController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Vibrant violet/purple matching the reference image
    final Color purplePrimary = theme.colorScheme.primary;
    final Color purpleGradientStart = Color.lerp(
          purplePrimary,
          Colors.white,
          0.16,
        ) ??
        const Color(0xFF7E57C2);
    final Color purpleGradientEnd = Color.lerp(
          purplePrimary,
          const Color(0xFF4527A0),
          0.45,
        ) ??
        const Color(0xFF5E35B1);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Tooltip(
        message: S.of(context).addNewHabit,
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _isPressed
                    ? [purpleGradientEnd, purpleGradientStart]
                    : [purpleGradientStart, purpleGradientEnd],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: isDark ? 0.35 : 0.65),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: purplePrimary.withValues(alpha: isDark ? 0.45 : 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                  spreadRadius: 1,
                ),
                if (!isDark)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.add_rounded,
                size: 28,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// An interactive navigation item in the bottom bar with tactile feedback and active indicator.
class _NavBarItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String tooltip;
  final bool isDark;
  final bool hasSparkleBadge;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.tooltip,
    required this.isDark,
    this.hasSparkleBadge = false,
    required this.onTap,
  });

  @override
  State<_NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<_NavBarItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    setState(() => _isPressed = true);
    _animController.forward();
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
    _animController.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _animController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    final Color normalIconColor = widget.isDark
        ? Colors.white.withValues(alpha: 0.70)
        : Colors.black.withValues(alpha: 0.60);

    final Color activeIconColor = primaryColor;

    return Tooltip(
      message: widget.tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 60,
            height: 52,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      _isPressed ? widget.activeIcon : widget.icon,
                      size: 24,
                      color: _isPressed ? activeIconColor : normalIconColor,
                    ),

                    // Subtle AI sparkle badge on the chat bubble
                    if (widget.hasSparkleBadge)
                      Positioned(
                        top: -2,
                        right: -4,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryColor,
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.6),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),

                // Subtle indicator line matching the active indicator in the reference image
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  width: _isPressed ? 14 : 0,
                  height: 2.5,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
