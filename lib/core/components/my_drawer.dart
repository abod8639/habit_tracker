import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/features/ai_chat/presentation/controllers/ai_chat_binding.dart';
import 'package:habit_tracker/features/ai_chat/presentation/pages/ai_chat_page.dart';
import 'package:habit_tracker/features/habitstats/presentation/pages/habit_stats_page.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/features/habitstats/presentation/controllers/habitstats_binding.dart';
import 'package:habit_tracker/features/setting/presentation/pages/settings_page.dart';
import 'package:habit_tracker/features/setting/presentation/controllers/setting_binding.dart';
import 'package:habit_tracker/features/theme/presentation/pages/theme_page.dart';
import 'package:habit_tracker/features/home/presentation/widget/my_list_tile.dart';
import 'package:habit_tracker/core/services/gemini_service.dart';
import 'package:habit_tracker/features/home/presentation/widget/image_scanner_bottom_sheet.dart';
import 'package:habit_tracker/features/home/presentation/widget/habit_confirmation_dialog.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});
  bool isPhone(BuildContext context) {
    final double mwidth = MediaQuery.of(context).size.width;
    return mwidth < 600.0;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: isPhone(context) ? 200 : 300,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // backgroundColor: Colors.grey[900],
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
              Get.back();
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
    // HabitController controller = Get.put(HabitController());

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
          onTap: _isScanning ? null : _handleScanImage,
          title: S.current.scanImage,
        ),
        MyDrawerListTile(
          icon: Icon(
            color: Theme.of(context).primaryColor,
            Icons.color_lens_outlined,
          ),
          onTap: () {
            Get.back();
            Get.to(() => ThemePage());
          },
          title: S.current.drawerTheme,
        ),

        MyDrawerListTile(
          icon: const Icon(color: Colors.blueAccent, Icons.auto_graph_sharp),
          onTap: () {
            Get.back();
            Get.to(() => const HabitStatsPage(), binding: HabitStatsBinding());
          },
          title: S.current.drawerReat,
        ),
        MyDrawerListTile(
          icon: const Icon(color: Colors.purpleAccent, Icons.psychology),
          onTap: () {
            Get.back();
            Get.to(
              () => const AiChatPage(),
              binding: AiChatBinding(),
            );
          },
          title: S.current.aiCoach,
        ),
        MyDrawerListTile(
          icon: const Icon(color: Colors.blueGrey, Icons.settings),
          onTap: () {
            Get.back();
            Get.to(() => const SettingsPage(), binding: SettingBinding());
          },
          title: S.current.drawerSetting,
        ),
      ],
    );
  }
}
