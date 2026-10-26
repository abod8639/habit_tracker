import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/core/routes/app_routes.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/core/guards/ai_guard.dart';
import 'package:habit_tracker/core/theme/app_theme.dart';
import 'my_drawer_list_tile.dart';
import 'package:habit_tracker/core/services/gemini_service.dart';
import 'package:habit_tracker/features/home/presentation/widget/image_scanner_bottom_sheet.dart';
import 'package:habit_tracker/features/home/presentation/widget/habit_confirmation_dialog.dart';

import 'package:habit_tracker/core/utils/responsive_utils.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: ResponsiveUtils.isPhone(context) ? 200 : 300,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: const DrawerList(),
    );
  }
}

class DrawerList extends StatefulWidget {
  const DrawerList({super.key});

  @override
  State<DrawerList> createState() => _DrawerListState();
}

class _DrawerListState extends State<DrawerList> {
  bool _isScanning = false;

  void _handleScanImage() {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (bottomSheetContext) => ImageScannerBottomSheet(
        onImageSelected: (image) async {
          setState(() {
            _isScanning = true;
          });
          try {
            final service = GeminiService();
            final habits = await service.extractHabitsFromImage(image);

            if (mounted) {
              setState(() {
                _isScanning = false;
              });
              // Close the drawer if it's still open
              Navigator.of(context).pop();
              // Show the confirmation dialog
              showDialog(
                context: context,
                builder: (context) =>
                    HabitConfirmationDialog(extractedHabits: habits),
              );
            }
          } catch (e) {
            if (mounted) {
              setState(() {
                _isScanning = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: $e'),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final colorScheme = context.colorScheme;

    return ListView(
      children: [
        const SizedBox(height: 20),
        MyDrawerListTile(
          icon: _isScanning
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary,
                  ),
                )
              : Icon(
                  color: colors.drawerScanIcon,
                  Icons.document_scanner_rounded,
                ),
          onTap: () => _isScanning
              ? null
              : AiGuard.protect(
                  context,
                  onValid: _handleScanImage,
                ),
          title: S.current.scanImage,
        ),

        MyDrawerListTile(
          icon: Icon(color: colors.drawerStatsIcon, Icons.auto_graph_sharp),
          onTap: () {
            Navigator.of(context).canPop();
            context.push(AppRoutes.stats);
          },
          title: S.current.drawerReat,
        ),

        MyDrawerListTile(
          icon: Icon(
            color: colorScheme.primary,
            Icons.color_lens_outlined,
          ),
          onTap: () {
            Navigator.of(context).canPop();
            context.push(AppRoutes.theme);
          },
          title: S.current.drawerTheme,
        ),

        // MyDrawerListTile(
        //   icon: Icon(color: colors.drawerAiIcon, Icons.auto_awesome_rounded),
        //   onTap: () {
        //     final navigator = Navigator.of(context);
        //     final router = GoRouter.of(context);
        //     AiGuard.protect(
        //       context,
        //       onValid: () {
        //         navigator.canPop();
        //         router.push(AppRoutes.categorySelection);
        //       },
        //     );
        //   },
        //   title: S.current.generatePlan,
        // ),
        MyDrawerListTile(
          icon: Icon(color: colors.drawerAiIcon, Icons.psychology),
          onTap: () {
            final navigator = Navigator.of(context);
            final router = GoRouter.of(context);
            AiGuard.protect(
              context,
              onValid: () {
                navigator.canPop();
                router.push(AppRoutes.aiCoach);
              },
            );
          },
          title: S.current.aiCoach,
        ),
        MyDrawerListTile(
          icon: Icon(color: colors.drawerSettingsIcon, Icons.settings),
          onTap: () {
            Navigator.of(context).canPop();
            context.push(AppRoutes.settings);
          },
          title: S.current.drawerSetting,
        ),
      ],
    );
  }
}
