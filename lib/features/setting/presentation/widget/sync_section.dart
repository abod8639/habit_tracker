import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/core/components/animated_setting_tile.dart';
import 'package:habit_tracker/core/functions/perform_sync.dart';
import 'package:habit_tracker/features/auth/presentation/controllers/auth_controller.dart';
import 'package:habit_tracker/features/home/presentation/controllers/habit_controller.dart';
import 'package:habit_tracker/features/setting/presentation/controllers/sync_controller.dart';
import 'package:habit_tracker/generated/l10n.dart';

class SyncSection extends StatelessWidget {
  final AnimationController animationController;

  const SyncSection({super.key, required this.animationController});

  @override
  Widget build(BuildContext context) {
    final syncController = Get.put(SyncController());
    final habitController = Get.find<HabitController>();
    final authController = Get.put(AuthController());

    return Obx(() {
      final user = authController.currentUser;
      if (user != null) {
        return Column(
          children: [
            Obx(
              () => AnimatedSettingTile(
                animationController: animationController,
                index: 3,
                icon: syncController.syncStatus.value == SyncStatus.syncing
                    ? Icons.sync_rounded
                    : Icons.cloud_upload_outlined,
                title: S.current.syncNow,
                subtitle: syncController.syncStatusMessage,
                onTap: syncController.syncStatus.value == SyncStatus.syncing
                    ? null
                    : () => performSync(syncController, habitController),
              ),
            ),
          ],
        );
      }
      return const SizedBox.shrink();
    });
  }
}

Widget buildSyncSection(AnimationController animationController) {
  return SyncSection(animationController: animationController);
}
