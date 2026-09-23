import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/features/home/presentation/controllers/habit_controller.dart';
import 'package:habit_tracker/features/home/presentation/widget/my_text_taile.dart';
import 'package:habit_tracker/core/functions/edit_habit.dart';

class CheckboxList extends StatelessWidget {
  const CheckboxList({super.key});

  @override
  Widget build(BuildContext context) {
    final HabitController controller = Get.find<HabitController>();

    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: SizedBox(
        height: double.infinity,
        child: Obx(() {
          final habits = controller.habits;
          return AnimatedList(
            key:
                GlobalKey<
                  AnimatedListState
                >(), // Simple key for now, could be improved for better animations
            scrollDirection: Axis.vertical,
            initialItemCount: habits.length,
            itemBuilder: (context, index, animation) {
              if (index >= habits.length) {
                return const SizedBox.shrink();
              }

              final habit = habits[index];

              return SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(1, 0),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(parent: animation, curve: Curves.easeOut),
                    ),
                child: MyTextTaile(
                  habitName: habit.name,
                  habitCompleted: habit.isCompleted,
                  onTap: () =>
                      controller.toggleHabit(habit.id, !habit.isCompleted),
                  onDelete: (context) => controller.deleteHabit(habit.id),
                  onEdit: (context) => editHabit(habit.id, habit.name, context),
                  onChanged: (value) =>
                      controller.toggleHabit(habit.id, value ?? false),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
