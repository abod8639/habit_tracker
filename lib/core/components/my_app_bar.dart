import 'package:flutter/material.dart';
import 'package:habit_tracker/core/components/neumorphic_icon_button.dart';
import 'package:habit_tracker/core/theme/app_shadows.dart';

/// Clean Architecture reusable Neumorphic [SliverAppBar].
/// Adheres to SOLID principles, providing high customizability,
/// seamless scroll coordination, and consistent design language across the app.
class MySliverAppBar extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final VoidCallback? onBack;
  final bool showLeading;
  final bool pinned;
  final bool floating;
  final bool snap;
  final double? expandedHeight;
  final Widget? flexibleSpace;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;
  final bool centerTitle;
  final double leadingWidth;
  final double? toolbarHeight;

  const MySliverAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.onBack,
    this.showLeading = true,
    this.pinned = true,
    this.floating = true,
    this.snap = true,
    this.expandedHeight,
    this.flexibleSpace,
    this.bottom,
    this.backgroundColor,
    this.centerTitle = true,
    this.leadingWidth = 72,
    this.toolbarHeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveBgColor = backgroundColor ?? theme.scaffoldBackgroundColor;

    Widget? effectiveTitle = titleWidget;
    if (effectiveTitle == null && title != null) {
      effectiveTitle = Text(
        title!,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          letterSpacing: 0.3,
          shadows: AppShadows.bloom(
            isDark: isDark,
            color: theme.colorScheme.onPrimary,
            blur: 2,
            spread: 0.2,
          ),
        ),
      );
    }

    Widget? effectiveLeading;
    if (showLeading) {
      effectiveLeading = Center(
        child: Padding(
          padding: const EdgeInsetsDirectional.only(start: 16),
          child:
              leading ??
              NeumorphicIconButton.square(
                customShadows: AppShadows.softCard(isDark: isDark),
                size: 46,
                iconSize: 22,
                icon: Icons.arrow_back_ios_new_rounded,
                accentColor: theme.colorScheme.onSurface,
                onPressed:
                    onBack ??
                    () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },
              ),
        ),
      );
    }

    return SliverAppBar(
      backgroundColor: effectiveBgColor,
      elevation: 0,

      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      pinned: pinned,
      floating: floating,
      snap: snap,
      expandedHeight: expandedHeight,
      flexibleSpace: flexibleSpace,
      bottom: bottom,
      leadingWidth: leadingWidth,
      automaticallyImplyLeading: false,
      leading: effectiveLeading,
      title: effectiveTitle,
      centerTitle: centerTitle,
      actions: actions,
      toolbarHeight: toolbarHeight ?? kToolbarHeight,
    );
  }
}

/// Helper function to create [MySliverAppBar] fluently.
Widget mySliverAppBar({
  required String title,
  List<Widget>? actions,
  Widget? leading,
  VoidCallback? onBack,
  bool showLeading = true,
  bool pinned = true,
  bool floating = false,
  bool snap = false,
  double? expandedHeight,
  Widget? flexibleSpace,
  PreferredSizeWidget? bottom,
  Color? backgroundColor,
}) {
  return MySliverAppBar(
    title: title,
    actions: actions,
    leading: leading,
    onBack: onBack,
    showLeading: showLeading,
    pinned: pinned,
    floating: floating,
    snap: snap,
    expandedHeight: expandedHeight,
    flexibleSpace: flexibleSpace,
    bottom: bottom,
    backgroundColor: backgroundColor,
  );
}

/// Legacy backward-compatible function returning a standard PreferredSizeWidget [AppBar].
PreferredSizeWidget myAppBar({
  required String title,
  required BuildContext context,
  List<Widget>? actions,
  Widget? leading,
  VoidCallback? onBack,
  bool showLeading = true,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final theme = Theme.of(context);
  return AppBar(
    backgroundColor: theme.scaffoldBackgroundColor,
    elevation: 0,
    scrolledUnderElevation: 0,
    surfaceTintColor: Colors.transparent,
    leadingWidth: 72,
    leading: showLeading
        ? Center(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(start: 16),
              child:
                  leading ??
                  NeumorphicIconButton.square(
                    customShadows: AppShadows.softCard(isDark: isDark),
                    size: 40,
                    iconSize: 18,
                    icon: Icons.arrow_back_ios_new_rounded,
                    accentColor: theme.colorScheme.onSurface,
                    onPressed:
                        onBack ??
                        () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                        },
                  ),
            ),
          )
        : null,
    title: Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        letterSpacing: 0.3,
        shadows: AppShadows.bloom(
          isDark: theme.brightness == Brightness.dark,
          color: theme.colorScheme.onPrimary,
          blur: 2,
          spread: 0.2,
        ),
      ),
    ),
    centerTitle: true,
    actions: actions,
  );
}
