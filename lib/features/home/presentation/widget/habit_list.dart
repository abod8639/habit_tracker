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
    final habitNotifier = ref.watch(habitNotifierProvider.notifier);

    if (habits.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: NoHabitsYet(),
      );
    }

    return SliverReorderableList(
      itemCount: habits.length,
      onReorderItem: (oldIndex, newIndex) =>
          habitNotifier.reorderHabits(oldIndex, newIndex, isAdjusted: true),
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
            habitName: habit.name,
            habitCompleted: habit.isCompleted,
            isSelected: isSelected,
            isSelectionMode: isSelectionMode,
            colorValue: habit.colorValue,
            onTap: () {
              if (isSelectionMode) {
                habitNotifier.toggleHabitSelection(habit.id);
              } else {
                habitNotifier.toggleHabit(habit.id, !habit.isCompleted);
              }
            },
            onDelete: (context) => habitNotifier.deleteHabit(habit.id),
            onEdit: (context) => HabitDialogs.showEdit(
              context,
              id: habit.id,
              currentName: habit.name,
              ref: ref,
            ),
            onChanged: (value) =>
                habitNotifier.toggleHabit(habit.id, value ?? false),
            onLongPress: isSelectionMode
                ? null
                : () => habitNotifier.toggleHabitSelection(habit.id),
          ),
        );
      },
    );
  }
}
