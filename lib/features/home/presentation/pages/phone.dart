import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/core/routes/app_routes.dart';
import 'package:habit_tracker/features/home/presentation/controllers/habit_controller.dart';
import 'package:habit_tracker/core/functions/add_habit.dart';
import 'package:habit_tracker/features/home/presentation/widget/habit_list.dart';
import 'package:habit_tracker/features/home/presentation/widget/sliver_monthly_summary.dart';
import 'package:habit_tracker/core/components/build_error_screen.dart';
import 'package:habit_tracker/core/components/build_loading_screen.dart';
import 'package:habit_tracker/core/components/my_drawer.dart';
import 'package:habit_tracker/features/home/presentation/widget/my_fab.dart';
import 'package:habit_tracker/generated/l10n.dart';

class Phone extends StatefulWidget {
  const Phone({super.key});

  @override
  State<Phone> createState() => _PhoneState();
}

class _PhoneState extends State<Phone> {
  final HabitController controller = Get.find<HabitController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Obx(
        () => controller.isSelectionMode
            ? const SizedBox.shrink()
            : MyfloatingActionButton(
                onPressed: () => addHabit(context),
              ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return buildLoadingScreen();
          }

          if (controller.errorMessage.value.isNotEmpty) {
            return buildErrorScreen();
          }

          return CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: const [
              MyAppBar(),
              SliverMonthlySummary(),
              HabitList(),
              SliverToBoxAdapter(
                child: SizedBox(height: 85),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class MyAppBar extends StatelessWidget {
  const MyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final HabitController controller = Get.find<HabitController>();

    return Obx(() {
      if (controller.isSelectionMode) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final baseColor = theme.cardColor;
        final colorScheme = theme.colorScheme;

        final Color surfaceGradientStart = isDark
            ? (Color.lerp(baseColor, Colors.white, 0.04) ?? baseColor)
            : (Color.lerp(baseColor, Colors.white, 0.45) ?? baseColor);

        final Color surfaceGradientEnd = isDark
            ? (Color.lerp(baseColor, Colors.black, 0.15) ?? baseColor)
            : (Color.lerp(baseColor, const Color(0xFFA3B1C6), 0.08) ??
                baseColor);

        final Color lightShadow = isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.white.withValues(alpha: 0.90);

        final Color darkShadow = isDark
            ? Colors.black.withValues(alpha: 0.55)
            : const Color(0xFFA3B1C6).withValues(alpha: 0.32);

        return SliverAppBar(
          pinned: true,
          automaticallyImplyLeading: false,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 68,
          titleSpacing: 0,
          leadingWidth: 68,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [surfaceGradientStart, surfaceGradientEnd],
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(22),
              ),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : Colors.white.withValues(alpha: 0.85),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: darkShadow,
                  offset: const Offset(0, 4),
                  blurRadius: 10,
                ),
                BoxShadow(
                  color: lightShadow,
                  offset: const Offset(0, -2),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          leading: Padding(
            padding: const EdgeInsetsDirectional.only(
              start: 16,
              top: 13,
              bottom: 13,
            ),
            child: _NeumorphicAppBarIconButton(
              icon: Icons.close_rounded,
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              onPressed: () => controller.clearSelection(),
            ),
          ),
          title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: Color.alphaBlend(
                colorScheme.primary.withValues(alpha: isDark ? 0.16 : 0.10),
                baseColor,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.primary.withValues(
                  alpha: isDark ? 0.30 : 0.20,
                ),
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  size: 16,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  S.current.itemsSelected(controller.selectedHabitIds.length),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.primary,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 13),
              child: _NeumorphicAppBarIconButton(
                icon: Icons.palette_outlined,
                accentColor: colorScheme.primary,
                tooltip: S.of(context).chooseColor,
                onPressed: () => _showColorPicker(context, controller),
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsetsDirectional.only(
                end: 16,
                top: 13,
                bottom: 13,
              ),
              child: _NeumorphicAppBarIconButton(
                icon: Icons.delete_outline_rounded,
                accentColor: colorScheme.error,
                tooltip: S.of(context).delete,
                onPressed: () => _showBatchDeleteConfirm(context, controller),
              ),
            ),
          ],
        );
      }

      return SliverAppBar(
        pinned: false,
        floating: true,
        automaticallyImplyLeading: false,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 64,
        titleSpacing: 16,
        leadingWidth: 68,
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'HABIT MATRIX',
              style: TextStyle(
                fontSize: 11,
                letterSpacing: 2.2,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Daily Persistence',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        leading: Padding(
          padding: const EdgeInsetsDirectional.only(
            start: 16,
            top: 11,
            bottom: 11,
          ),
          child: Builder(
            builder: (context) => _NeumorphicAppBarIconButton(
              icon: Icons.menu_rounded,
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(
              end: 16,
              top: 11,
              bottom: 11,
            ),
            child: _NeumorphicAppBarIconButton(
              icon: Icons.auto_awesome_rounded,
              accentColor: Theme.of(context).primaryColor,
              tooltip: S.current.generatePlan,
              onPressed: () => Get.toNamed(AppRoutes.categorySelection),
            ),
          ),
        ],
      );
    });
  }

  void _showColorPicker(BuildContext context, HabitController controller) {
    showDialog(
      context: context,
      builder: (dialogContext) => _NeumorphicColorPickerDialog(
        controller: controller,
      ),
    );
  }

  void _showBatchDeleteConfirm(
    BuildContext context,
    HabitController controller,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => _NeumorphicDeleteConfirmDialog(
        controller: controller,
      ),
    );
  }
}

/// Tactile circular Neumorphic button for AppBars
class _NeumorphicAppBarIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final Color? accentColor;

  const _NeumorphicAppBarIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.accentColor,
  });

  @override
  State<_NeumorphicAppBarIconButton> createState() =>
      _NeumorphicAppBarIconButtonState();
}

class _NeumorphicAppBarIconButtonState
    extends State<_NeumorphicAppBarIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = theme.cardColor;
    final colorScheme = theme.colorScheme;

    final Color surfaceStart = isDark
        ? (Color.lerp(baseColor, Colors.white, 0.04) ?? baseColor)
        : (Color.lerp(baseColor, Colors.white, 0.45) ?? baseColor);

    final Color surfaceEnd = isDark
        ? (Color.lerp(baseColor, Colors.black, 0.15) ?? baseColor)
        : (Color.lerp(baseColor, const Color(0xFFA3B1C6), 0.08) ?? baseColor);

    final Color lightShadow = isDark
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.white.withValues(alpha: 0.90);

    final Color darkShadow = isDark
        ? Colors.black.withValues(alpha: 0.50)
        : const Color(0xFFA3B1C6).withValues(alpha: 0.35);

    const double size = 42.0;
    final Color effectiveIconColor =
        widget.accentColor ?? colorScheme.onSurface;

    Widget button = GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: _isPressed
              ? null
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [surfaceStart, surfaceEnd],
                ),
          color: _isPressed
              ? (isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : const Color(0xFFD3DCE8))
              : null,
          border: Border.all(
            color: widget.accentColor != null
                ? widget.accentColor!.withValues(alpha: isDark ? 0.35 : 0.25)
                : (isDark
                    ? Colors.white.withValues(alpha: _isPressed ? 0.03 : 0.07)
                    : Colors.white.withValues(alpha: _isPressed ? 0.4 : 0.85)),
            width: 1.0,
          ),
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.4)
                        : const Color(0xFFA3B1C6).withValues(alpha: 0.25),
                    offset: const Offset(1, 1),
                    blurRadius: 2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: lightShadow,
                    offset: const Offset(-2.5, -2.5),
                    blurRadius: 5,
                  ),
                  BoxShadow(
                    color: darkShadow,
                    offset: const Offset(2.5, 2.5),
                    blurRadius: 5,
                  ),
                  if (widget.accentColor != null)
                    BoxShadow(
                      color: widget.accentColor!.withValues(
                        alpha: isDark ? 0.25 : 0.15,
                      ),
                      offset: const Offset(0, 2),
                      blurRadius: 6,
                    ),
                ],
        ),
        child: Center(
          child: Icon(
            widget.icon,
            size: size * 0.50,
            color: effectiveIconColor,
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}

/// Neumorphic Color Picker Dialog with 3D color coins
class _NeumorphicColorPickerDialog extends StatelessWidget {
  final HabitController controller;

  const _NeumorphicColorPickerDialog({required this.controller});

  static final List<Color> _colors = [
    Colors.red[400]!,
    Colors.pink[400]!,
    Colors.purple[400]!,
    Colors.deepPurple[400]!,
    Colors.indigo[400]!,
    Colors.blue[400]!,
    Colors.lightBlue[400]!,
    Colors.cyan[400]!,
    Colors.teal[400]!,
    Colors.green[400]!,
    Colors.lightGreen[500]!,
    Colors.lime[600]!,
    Colors.yellow[700]!,
    Colors.amber[500]!,
    Colors.orange[600]!,
    Colors.deepOrange[500]!,
    Colors.brown[400]!,
    Colors.blueGrey[400]!,
    const Color(0xFF6C63FF),
    const Color(0xFF2D2D2D),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final baseColor = theme.cardColor;

    final Color surfaceGradientStart = isDark
        ? (Color.lerp(baseColor, Colors.white, 0.04) ?? baseColor)
        : (Color.lerp(baseColor, Colors.white, 0.45) ?? baseColor);

    final Color surfaceGradientEnd = isDark
        ? (Color.lerp(baseColor, Colors.black, 0.15) ?? baseColor)
        : (Color.lerp(baseColor, const Color(0xFFA3B1C6), 0.08) ?? baseColor);

    final Color lightShadow = isDark
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.white.withValues(alpha: 0.90);

    final Color darkShadow = isDark
        ? Colors.black.withValues(alpha: 0.65)
        : const Color(0xFFA3B1C6).withValues(alpha: 0.35);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
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
          boxShadow: [
            BoxShadow(
              color: lightShadow,
              offset: const Offset(-5, -5),
              blurRadius: 14,
            ),
            BoxShadow(
              color: darkShadow,
              offset: const Offset(6, 6),
              blurRadius: 16,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.alphaBlend(
                          colorScheme.primary.withValues(
                            alpha: isDark ? 0.14 : 0.09,
                          ),
                          baseColor,
                        ),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.white.withValues(alpha: 0.9),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: lightShadow,
                            offset: const Offset(-2, -2),
                            blurRadius: 4,
                          ),
                          BoxShadow(
                            color: darkShadow,
                            offset: const Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.palette_outlined,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      S.of(context).chooseColor,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? (Color.lerp(baseColor, Colors.black, 0.2) ??
                              baseColor)
                          : (Color.lerp(
                                  baseColor,
                                  const Color(0xFFDCE2EC),
                                  0.3,
                                ) ??
                                baseColor),
                      boxShadow: [
                        BoxShadow(
                          color: lightShadow,
                          offset: const Offset(-1.5, -1.5),
                          blurRadius: 3,
                        ),
                        BoxShadow(
                          color: darkShadow,
                          offset: const Offset(1.5, 1.5),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 5,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              children: _colors.map((color) {
                return _ColorCoin(
                  color: color,
                  onTap: () {
                    controller.updateSelectedHabitsColor(color);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tactile Neumorphic Color Coin
class _ColorCoin extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;

  const _ColorCoin({required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: isDark ? 0.35 : 0.65),
            width: 1.5,
          ),
          boxShadow: [
            // Soft radiant glow of the color itself
            BoxShadow(
              color: color.withValues(alpha: isDark ? 0.5 : 0.35),
              offset: const Offset(0, 3),
              blurRadius: 6,
            ),
            // Top-left ambient reflection
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.6),
              offset: const Offset(-1.5, -1.5),
              blurRadius: 3,
            ),
          ],
        ),
      ),
    );
  }
}

/// Neumorphic Batch Delete Confirmation Dialog
class _NeumorphicDeleteConfirmDialog extends StatelessWidget {
  final HabitController controller;

  const _NeumorphicDeleteConfirmDialog({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final baseColor = theme.cardColor;

    final Color surfaceGradientStart = isDark
        ? (Color.lerp(baseColor, Colors.white, 0.04) ?? baseColor)
        : (Color.lerp(baseColor, Colors.white, 0.45) ?? baseColor);

    final Color surfaceGradientEnd = isDark
        ? (Color.lerp(baseColor, Colors.black, 0.15) ?? baseColor)
        : (Color.lerp(baseColor, const Color(0xFFA3B1C6), 0.08) ?? baseColor);

    final Color lightShadow = isDark
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.white.withValues(alpha: 0.90);

    final Color darkShadow = isDark
        ? Colors.black.withValues(alpha: 0.65)
        : const Color(0xFFA3B1C6).withValues(alpha: 0.35);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
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
          boxShadow: [
            BoxShadow(
              color: lightShadow,
              offset: const Offset(-5, -5),
              blurRadius: 14,
            ),
            BoxShadow(
              color: darkShadow,
              offset: const Offset(6, 6),
              blurRadius: 16,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Warning Icon Badge with Neumorphic dual shadows & subtle red glow
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.alphaBlend(
                  colorScheme.error.withValues(alpha: isDark ? 0.16 : 0.10),
                  baseColor,
                ),
                border: Border.all(
                  color: colorScheme.error.withValues(
                    alpha: isDark ? 0.35 : 0.25,
                  ),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.error.withValues(
                      alpha: isDark ? 0.35 : 0.20,
                    ),
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                  ),
                  BoxShadow(
                    color: lightShadow,
                    offset: const Offset(-2, -2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: colorScheme.error,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              S.of(context).deleteSelected,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              S
                  .of(context)
                  .deleteSelectedConfirm(controller.selectedHabitIds.length),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface.withValues(alpha: 0.65),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _NeumorphicDialogButton(
                    label: S.of(context).cancel,
                    isDestructive: false,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _NeumorphicDialogButton(
                    label: S.of(context).delete,
                    isDestructive: true,
                    onPressed: () {
                      controller.deleteSelectedHabits();
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Tactile button for dialog actions
class _NeumorphicDialogButton extends StatefulWidget {
  final String label;
  final bool isDestructive;
  final VoidCallback onPressed;

  const _NeumorphicDialogButton({
    required this.label,
    required this.isDestructive,
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
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final baseColor = theme.cardColor;

    final Color lightShadow = isDark
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.white.withValues(alpha: 0.85);

    final Color darkShadow = isDark
        ? Colors.black.withValues(alpha: 0.45)
        : const Color(0xFFA3B1C6).withValues(alpha: 0.32);

    final Color destructiveColor = colorScheme.error;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: widget.isDestructive
              ? LinearGradient(
                  colors: [
                    destructiveColor,
                    Color.lerp(
                          destructiveColor,
                          Colors.black,
                          isDark ? 0.25 : 0.12,
                        ) ??
                        destructiveColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: widget.isDestructive
              ? null
              : (_isPressed
                  ? (isDark
                      ? Colors.black.withValues(alpha: 0.25)
                      : const Color(0xFFD3DCE8))
                  : (Color.lerp(
                          baseColor,
                          isDark ? Colors.black : const Color(0xFFDCE2EC),
                          isDark ? 0.15 : 0.25,
                        ) ??
                        baseColor)),
          border: Border.all(
            color: widget.isDestructive
                ? Colors.white.withValues(alpha: isDark ? 0.15 : 0.35)
                : (isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.white.withValues(alpha: 0.8)),
            width: 1.0,
          ),
          boxShadow: widget.isDestructive
              ? [
                  BoxShadow(
                    color: destructiveColor.withValues(
                      alpha: isDark ? 0.45 : 0.32,
                    ),
                    offset: Offset(0, _isPressed ? 1 : 4),
                    blurRadius: _isPressed ? 4 : 10,
                  ),
                  BoxShadow(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.white.withValues(alpha: 0.6),
                    offset: const Offset(-1.5, -1.5),
                    blurRadius: 3,
                  ),
                ]
              : (_isPressed
                  ? [
                      BoxShadow(
                        color: darkShadow,
                        offset: const Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: lightShadow,
                        offset: const Offset(-2, -2),
                        blurRadius: 4,
                      ),
                      BoxShadow(
                        color: darkShadow,
                        offset: const Offset(2.5, 2.5),
                        blurRadius: 4,
                      ),
                    ]),
        ),
        child: Center(
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: widget.isDestructive
                  ? Colors.white
                  : colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}


