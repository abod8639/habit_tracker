import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/core/components/app_confirmation_dialog.dart';
import 'package:habit_tracker/core/components/neumorphic_icon_button.dart';
import 'package:habit_tracker/core/routes/app_routes.dart';
import 'package:habit_tracker/core/theme/app_radius.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';
import 'package:habit_tracker/features/home/presentation/controllers/habit_controller.dart';
import 'package:habit_tracker/features/home/presentation/widget/neumorphic_color_picker_dialog.dart';
import 'package:habit_tracker/generated/l10n.dart';

/// Clean Architecture SliverAppBar for the Home screen.
/// Switches smoothly between Normal Mode and Selection Mode with tactile actions.
class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

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
              borderRadius: AppRadius.bottom(AppRadius.button),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : Colors.white.withValues(alpha: 0.85),
                width: 1.2,
              ),
              boxShadow: AppShadows.subtleCard(isDark: isDark),
            ),
          ),
          leading: Padding(
            padding: const EdgeInsetsDirectional.only(
              start: 16,
              top: 13,
              bottom: 13,
            ),
            child: NeumorphicIconButton(
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
              borderRadius: AppRadius.badgeRadius,
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
              child: NeumorphicIconButton(
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
              child: NeumorphicIconButton(
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
            builder: (context) => NeumorphicIconButton(
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
            child: NeumorphicIconButton(
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
      builder: (dialogContext) => NeumorphicColorPickerDialog(
        controller: controller,
      ),
    );
  }

  void _showBatchDeleteConfirm(
    BuildContext context,
    HabitController controller,
  ) {
    AppConfirmationDialog.show(
      context: context,
      title: S.of(context).deleteSelected,
      message: S
          .of(context)
          .deleteSelectedConfirm(controller.selectedHabitIds.length),
      icon: Icons.delete_outline_rounded,
      confirmText: S.of(context).delete,
      cancelText: S.of(context).cancel,
      isDestructive: true,
      onConfirm: () => controller.deleteSelectedHabits(),
    );
  }
}
