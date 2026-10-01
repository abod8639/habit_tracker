import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/core/routes/app_routes.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/core/functions/ai_guard.dart';
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

  Future<void> _handleScanImage() async {
    final canProceed = await AiGuard.protect(context, onValid: () {});
    if (!canProceed) return;

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
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
                  backgroundColor: Colors.red.shade700,
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
    return ListView(
      children: [
        const SizedBox(height: 20),
        MyDrawerListTile(
          icon: _isScanning
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(
                  color: Colors.lightBlue,
                  Icons.document_scanner_rounded,
                ),
          onTap:()=> _isScanning ? null : AiGuard.protect(
              context,
              onValid: () =>  _handleScanImage,
          ),
          title: S.current.scanImage,
        ),
        MyDrawerListTile(
          icon: const Icon(color: Colors.blueAccent, Icons.auto_graph_sharp),
          onTap: () {
            Navigator.of(context).pop();
            context.push(AppRoutes.stats);
          },
          title: S.current.drawerReat,
        ),
        MyDrawerListTile(
          icon: Icon(
            color: Theme.of(context).primaryColor,
            Icons.color_lens_outlined,
          ),
          onTap: () {
            Navigator.of(context).pop();
            context.push(AppRoutes.theme);
          },
          title: S.current.drawerTheme,
        ),

        MyDrawerListTile(
          icon: const Icon(color: Colors.purpleAccent, Icons.psychology),
          onTap: () {
            Navigator.of(context).pop();
            AiGuard.protect(
              context,
              onValid: () => context.push(AppRoutes.aiCoach),
            );
          },
          title: S.current.aiCoach,
        ),
        MyDrawerListTile(
          icon: const Icon(color: Colors.blueGrey, Icons.settings),
          onTap: () {
            Navigator.of(context).pop();
            context.push(AppRoutes.settings);
          },
          title: S.current.drawerSetting,
        ),
      ],
    );
  }
}
