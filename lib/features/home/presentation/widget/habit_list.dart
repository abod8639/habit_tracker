import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/features/home/presentation/controllers/habit_controller.dart';
import 'package:habit_tracker/features/home/presentation/widget/no_habits_yet.dart';
import 'package:habit_tracker/features/home/presentation/widget/my_text_taile.dart';
import 'package:habit_tracker/core/functions/edit_habit.dart';

class HabitList extends StatelessWidget {
  const HabitList({super.key});

  @override
  Widget build(BuildContext context) {
    final HabitController controller = Get.find<HabitController>();

    return Obx(() {
      final habits = controller.habits;

      if (habits.isEmpty) {
        return const SliverFillRemaining(
          hasScrollBody: false,
          child: NoHabitsYet(),
        );
      }

      return SliverReorderableList(
        itemCount: habits.length,
        onReorderItem: (oldIndex, newIndex) =>
            controller.reorderHabits(oldIndex, newIndex, isAdjusted: true),
        proxyDecorator: (child, index, animation) {
          return Material(
            color: Colors.transparent,
            child: child,
          );
        },
        itemBuilder: (context, index) {
          final habit = habits[index];
          return ReorderableDelayedDragStartListener(
            key: ValueKey(habit.id),
            index: index,
            enabled: true,
            child: Obx(() {
              // Wrap only the tile with Obx to listen to specific state changes like selection
              final isSelected = controller.selectedHabitIds.contains(habit.id);
              final isSelectionMode = controller.isSelectionMode;

              return MyTextTaile(
                habitName: habit.name,
                habitCompleted: habit.isCompleted,
                isSelected: isSelected,
                isSelectionMode: isSelectionMode,
                colorValue: habit.colorValue,
                onTap: () {
                  if (controller.isSelectionMode) {
                    controller.toggleHabitSelection(habit.id);
                  } else {
                    controller.toggleHabit(habit.id, !habit.isCompleted);
                  }
                },
                onDelete: (context) => controller.deleteHabit(habit.id),
                onEdit: (context) => editHabit(habit.id, habit.name, context),
                onChanged: (value) =>
                    controller.toggleHabit(habit.id, value ?? false),
                onLongPress: isSelectionMode
                    ? null
                    : () => controller.toggleHabitSelection(habit.id),
              );
            }),
          );
        },
      );
    });
  }
}
