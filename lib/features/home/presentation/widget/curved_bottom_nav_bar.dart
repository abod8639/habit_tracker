import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/core/guards/ai_guard.dart';
import 'package:habit_tracker/core/routes/app_routes.dart';
import 'package:habit_tracker/core/theme/app_theme.dart';
import 'package:habit_tracker/features/ai_chat/presentation/pages/ai_chat_page.dart';
import 'package:habit_tracker/features/habitstats/presentation/pages/habit_stats_page.dart';
import 'package:habit_tracker/features/setting/presentation/pages/settings_page.dart';
import 'package:habit_tracker/generated/l10n.dart';

/// A modern, curved floating Bottom Navigation Bar fully wired to the application's
/// design system and theme tokens in `/core/theme/`.
///
/// Features:
/// - Smooth organic curved scoop cutout for the central Floating Action Button.
/// - Left button: Navigates to [SettingsPage] using [AppThemeColors.drawerSettingsIcon].
/// - Center FloatingActionButton: Triggers new habit creation dialog using [ThemeUtils.accentGradient].
/// - Right button: Navigates to [AiChatPage] using [AppThemeColors.drawerAiIcon] and protected by [AiGuard].
/// - Dynamic Neumorphic surface, lighting, and shadows derived directly from [ThemeData], [ThemeUtils], and [AppShadows].
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

  void _navigateToStats(BuildContext context) {
    HapticFeedback.lightImpact();
    try {
      context.push(AppRoutes.stats);
    } catch (_) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const HabitStatsPage()),
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
    final theme = context.theme;
    final isDark = context.isDark;
    final appColors = context.appColors;
    final primaryColor = context.colorScheme.primary;
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
                  baseColor: theme.cardColor,
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
                          icon: Icons.auto_graph_sharp,
                          activeIcon: Icons.auto_graph_rounded,
                          tooltip: S.of(context).drawerSetting,
                          isDark: isDark,
                          accentColor: appColors.drawerStatsIcon,
                          surfaceColor: theme.cardColor,
                          onTap: () => _navigateToStats(context),
                        ),
                      ),
                    ),

                    // Middle spacing reserved for the central scoop & FAB
                    const SizedBox(width: 86),

                    // Right button: AI Chat
                    Expanded(
                      child: Center(
                        child: _NavBarItem(
                          icon: Icons.psychology,
                          activeIcon: Icons.psychology_outlined,
                          tooltip: S.of(context).aiCoach,
                          isDark: isDark,
                          accentColor: appColors.drawerAiIcon,
                          surfaceColor: theme.cardColor,
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
              top: 3,
              child: _CenterAddButton(
                size: _fabSize,
                primaryColor: primaryColor,
                isDark: isDark,
                onPressed: onAddHabit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter that draws the smooth curved notch and rounded floating bar
/// driven dynamically by [AppRadius], [AppShadows], and [ThemeUtils].
class _CurvedBarPainter extends CustomPainter {
  final bool isDark;
  final Color baseColor;
  final double yTop;
  final double barHeight;

  const _CurvedBarPainter({
    required this.isDark,
    required this.baseColor,
    required this.yTop,
    required this.barHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double yBot = yTop + barHeight;
    final double cx = w / 2;
    final double r = AppRadius.dialog; // 28.0 from AppRadius design tokens
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
      ..arcToPoint(Offset(w, yTop + r), radius: Radius.circular(r))
      // Right vertical edge
      ..lineTo(w, yBot - r)
      // Bottom right corner
      ..arcToPoint(Offset(w - r, yBot), radius: Radius.circular(r))
      // Bottom horizontal line
      ..lineTo(r, yBot)
      // Bottom left corner
      ..arcToPoint(Offset(0, yBot - r), radius: Radius.circular(r))
      // Left vertical edge
      ..lineTo(0, yTop + r)
      // Top left corner
      ..arcToPoint(Offset(r, yTop), radius: Radius.circular(r))
      ..close();

    // ── Drop Shadows from AppShadows Engine ──────────────────────────────────
    final darkShadow = AppShadows.darkShadowColor(isDark);
    final lightShadow = AppShadows.lightShadowColor(isDark);

    // Primary ambient depth shadow
    final shadowPaint1 = Paint()
      ..color = darkShadow.withValues(alpha: isDark ? 0.65 : 0.20)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, isDark ? 16 : 18);
    canvas.drawPath(path.shift(const Offset(0, 6)), shadowPaint1);

    // Secondary contact/light shadow
    final shadowPaint2 = Paint()
      ..color = isDark
          ? darkShadow.withValues(alpha: 0.35)
          : lightShadow.withValues(alpha: 0.60)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawPath(path.shift(const Offset(0, 2)), shadowPaint2);

    // ── Surface Fill Gradient using ThemeUtils ──────────────────────────────
    final surfaceRect = Rect.fromLTWH(0, yTop, w, barHeight);
    final surfacePaint = Paint()
      ..shader = ThemeUtils.softGradient(
        baseColor: baseColor,
        isDark: isDark,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(surfaceRect);
    canvas.drawPath(path, surfacePaint);

    // ── Subtle Glass/Neumorphic Outer Stroke using ThemeUtils ────────────────
    final borderStartColor = ThemeUtils.subtleBorderColor(isDark);
    final borderEndColor = borderStartColor.withValues(
      alpha: isDark ? 0.03 : 0.20,
    );

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [borderStartColor, borderEndColor],
      ).createShader(surfaceRect);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _CurvedBarPainter oldDelegate) {
    return oldDelegate.isDark != isDark ||
        oldDelegate.baseColor != baseColor ||
        oldDelegate.yTop != yTop ||
        oldDelegate.barHeight != barHeight;
  }
}

/// The central Floating Action Button nested into the scoop cutout,
/// styled with [ThemeUtils.accentGradient] and [AppShadows].
class _CenterAddButton extends StatefulWidget {
  final double size;
  final Color primaryColor;
  final bool isDark;
  final VoidCallback onPressed;

  const _CenterAddButton({
    required this.size,
    required this.primaryColor,
    required this.isDark,
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
    final isDark = widget.isDark;
    final primaryColor = widget.primaryColor;

    // Derived gradients directly from ThemeUtils design tokens
    final gradientStart = ThemeUtils.accentGradientStart(primaryColor, isDark);
    final gradientEnd = ThemeUtils.accentGradientEnd(primaryColor, isDark);

    // Icon contrast color matching ThemeUtils engine
    final iconColor = ThemeUtils.getContrastColor(primaryColor);

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
                    ? [gradientEnd, gradientStart]
                    : [gradientStart, gradientEnd],
              ),
              border: Border.all(
                color: ThemeUtils.subtleBorderColor(
                  isDark,
                  isPressed: _isPressed,
                ),
                width: 1.5,
              ),
              boxShadow: _isPressed
                  ? AppShadows.buttonPressed(isDark: isDark)
                  : AppShadows.buttonResting(isDark: isDark),
            ),
            child: Center(
              child: Icon(
                Icons.add_rounded,
                size: 28,
                color: iconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// An interactive navigation item in the bottom bar with tactile feedback and active indicator,
/// styled with [ThemeUtils] and [AppRadius].
class _NavBarItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String tooltip;
  final bool isDark;
  final Color accentColor;
  final Color surfaceColor;
  final bool hasSparkleBadge;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.tooltip,
    required this.isDark,
    required this.accentColor,
    required this.surfaceColor,
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
    final isDark = widget.isDark;
    final accentColor = widget.accentColor;

    // Inactive tone computed using ThemeUtils contrast against surface color
    final textColor = ThemeUtils.getContrastColor(widget.surfaceColor);
    final normalIconColor = textColor.withValues(alpha: isDark ? 0.65 : 0.55);

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
                      size: 30,
                      color: _isPressed ? accentColor : normalIconColor,
                    ),

                    // Subtle AI sparkle badge on the chat bubble
                    // if (widget.hasSparkleBadge)
                    //   Positioned(
                    //     top: -2,
                    //     right: -4,
                    //     child: Container(
                    //       width: 7,
                    //       height: 7,
                    //       decoration: BoxDecoration(
                    //         shape: BoxShape.circle,
                    //         color: accentColor,
                    //         boxShadow: AppShadows.bloom(
                    //           color: accentColor,
                    //           isDark: isDark,
                    //           blur: 4.0,
                    //         ),
                    //       ),
                    //     ),
                    //   ),
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
                    color: accentColor,
                    borderRadius: AppRadius.xsRadius,
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
