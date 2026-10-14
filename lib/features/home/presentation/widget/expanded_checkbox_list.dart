import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_tracker/features/home/presentation/providers/habit_providers.dart';
import 'package:habit_tracker/features/home/presentation/widget/my_text_taile.dart';
import 'package:habit_tracker/features/home/presentation/dialogs/habit_dialogs.dart';

class CheckboxList extends ConsumerWidget {
  const CheckboxList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(
      habitNotifierProvider.select((s) => s.habits),
    );
    final habitNotifier = ref.read(habitNotifierProvider.notifier);

    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: SizedBox(
        height: double.infinity,
        child: AnimatedList(
          key: GlobalKey<AnimatedListState>(),
          scrollDirection: Axis.vertical,
          initialItemCount: habits.length,
          itemBuilder: (context, index, animation) {
            if (index >= habits.length) {
              return const SizedBox.shrink();
            }

            final habit = habits[index];

            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
              ),
              child: MyTextTaile(
                habitName: habit.name,
                habitCompleted: habit.isCompleted,
                onTap: () =>
                    habitNotifier.toggleHabit(habit.id, !habit.isCompleted),
                onDelete: (context) => habitNotifier.deleteHabit(habit.id),
                onEdit: (context) => HabitDialogs.showEdit(
                  context,
                  id: habit.id,
                  currentName: habit.name,
                ),
                onChanged: (value) =>
                    habitNotifier.toggleHabit(habit.id, value ?? false),
              ),
            );
          },
        ),
      ),
    );
  }
}
