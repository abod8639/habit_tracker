import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/components/animated_setting_tile.dart';
import 'package:habit_tracker/features/auth/presentation/providers/auth_providers.dart';
import 'package:habit_tracker/features/setting/presentation/providers/setting_providers.dart';
import 'package:habit_tracker/generated/l10n.dart';

class SyncSection extends ConsumerWidget {
  final AnimationController animationController;

  const SyncSection({super.key, required this.animationController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(
      authNotifierProvider.select((state) => state.user),
    );
    if (user == null) {
      return const SizedBox.shrink();
    }

    final syncState = ref.watch(syncNotifierProvider);
    final syncNotifier = ref.watch(syncNotifierProvider.notifier);

    return Column(
      children: [
        AnimatedSettingTile(
          animationController: animationController,
          index: 3,
          icon: syncState.syncStatus == SyncStatus.syncing
              ? Icons.sync_rounded
              : Icons.cloud_upload_outlined,
          title: S.current.syncNow,
          subtitle: syncState.syncStatusMessage,
          onTap: syncState.syncStatus == SyncStatus.syncing
              ? null
              : () => syncNotifier.syncHabits(),
        ),
      ],
    );
  }
}

Widget buildSyncSection(AnimationController animationController) {
  return SyncSection(animationController: animationController);
}
