import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/core/components/animated_setting_tile.dart';
import 'package:habit_tracker/core/error/failures.dart';
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

    // Listen to sync failures and show floating SnackBar with Retry action
    ref.listen<Failure?>(syncFailureProvider, (previous, next) {
      if (next != null) {
        final s = S.maybeOf(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(next.toMessage()),
            backgroundColor: Theme.of(context).colorScheme.error,
            action: SnackBarAction(
              label: s?.tryAgain ?? 'Retry',
              textColor: Theme.of(context).colorScheme.onError,
              onPressed: () {
                ref.read(syncNotifierProvider.notifier).syncHabits();
              },
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });

    final syncState = ref.watch(syncNotifierProvider);
    final isError = syncState.syncStatus == SyncStatus.error;

    return Column(
      children: [
        AnimatedSettingTile(
          animationController: animationController,
          index: 3,
          icon: syncState.syncStatus == SyncStatus.syncing
              ? Icons.sync_rounded
              : (isError
                    ? Icons.sync_problem_rounded
                    : Icons.cloud_upload_outlined),
          title: S.current.syncNow,
          subtitle: isError && syncState.activeFailure != null
              ? syncState.activeFailure!.toMessage()
              : syncState.syncStatusMessage,
          textColor: isError ? Theme.of(context).colorScheme.error : null,
          onTap: syncState.syncStatus == SyncStatus.syncing
              ? null
              : () => ref.read(syncNotifierProvider.notifier).syncHabits(),
        ),
      ],
    );
  }
}

Widget buildSyncSection(AnimationController animationController) {
  return SyncSection(animationController: animationController);
}
