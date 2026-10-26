import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/features/home/presentation/providers/habit_providers.dart';
import 'package:habit_tracker/features/home/presentation/widget/no_habits_yet.dart';
import 'package:habit_tracker/features/home/presentation/widget/my_text_taile.dart';
import 'package:habit_tracker/features/home/presentation/dialogs/habit_dialogs.dart';

class HabitList extends ConsumerWidget {
  const HabitList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(
      habitNotifierProvider.select((s) => s.habits),
    );
    final selectedHabitIds = ref.watch(
      habitNotifierProvider.select((s) => s.selectedHabitIds),
    );
    final isSelectionMode = selectedHabitIds.isNotEmpty;

    if (habits.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: NoHabitsYet(),
      );
    }

    return SliverReorderableList(
      itemCount: habits.length,
      onReorderItem: (oldIndex, newIndex) => ref
          .read(habitNotifierProvider.notifier)
          .reorderHabits(oldIndex, newIndex, isAdjusted: true),
      proxyDecorator: (child, index, animation) {
        return Material(
          color: Colors.transparent,
          child: child,
        );
      },
      itemBuilder: (context, index) {
        final habit = habits[index];
        final isSelected = selectedHabitIds.contains(habit.id);

        return ReorderableDelayedDragStartListener(
          key: ValueKey(habit.id),
          index: index,
          enabled: true,
          child: MyTextTaile(
            habitId: habit.id,
            habitName: habit.name,
            habitCompleted: habit.isCompleted,
            isSelected: isSelected,
            isSelectionMode: isSelectionMode,
            colorValue: habit.colorValue,
            onTap: () {
              if (isSelectionMode) {
                ref
                    .read(habitNotifierProvider.notifier)
                    .toggleHabitSelection(habit.id);
              } else {
                ref
                    .read(habitNotifierProvider.notifier)
                    .toggleHabit(habit.id, !habit.isCompleted);
              }
            },
            onDelete: (_) =>
                ref.read(habitNotifierProvider.notifier).deleteHabit(habit.id),
            onEdit: (_) => HabitDialogs.showEdit(
              context,
              id: habit.id,
              currentName: habit.name,
              ref: ref,
            ),
            onChanged: (value) => ref
                .read(habitNotifierProvider.notifier)
                .toggleHabit(habit.id, value ?? false),
            onLongPress: isSelectionMode
                ? null
                : () => ref
                    .read(habitNotifierProvider.notifier)
                    .toggleHabitSelection(habit.id),
          ),
        );
      },
    );
  }
}
