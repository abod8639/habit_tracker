import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/habitstats/presentation/providers/habitstats_providers.dart';
import 'package:habit_tracker/features/habitstats/presentation/widget/line_chart_box.dart';
import 'package:habit_tracker/features/home/domain/entities/habit_entity.dart';

class _FakeNotifier extends HabitStatsNotifier {
  final HabitStatsState _initial;
  _FakeNotifier(this._initial);

  @override
  Future<HabitStatsState> build() async => _initial;
}

void main() {
  testWidgets(
    'When "All" is selected, habits have small vertical shifts so lines do not overlap',
    (tester) async {
      final state = HabitStatsState(
        showAllHabits: true,
        selectedHabitName: null,
        habitNames: const ['Workout', 'Reading'],
        todaySummary: [
          HabitEntity(
            id: '1',
            name: 'Workout',
            isCompleted: true,
            createdAt: DateTime(2024, 1, 1),
          ),
          HabitEntity(
            id: '2',
            name: 'Reading',
            isCompleted: true,
            createdAt: DateTime(2024, 1, 1),
          ),
        ],
        individualTrends: {
          'Workout': [const FlSpot(0, 1.0), const FlSpot(1, 1.0)],
          'Reading': [const FlSpot(0, 1.0), const FlSpot(1, 1.0)],
        },
        daysPeriod: 2,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitStatsNotifierProvider.overrideWith(
              () => _FakeNotifier(state),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: LineChartBox(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final lineChartFinder = find.byType(LineChart);
      expect(lineChartFinder, findsOneWidget);

      final lineChart = tester.widget<LineChart>(lineChartFinder);
      final bars = lineChart.data.lineBarsData;
      expect(bars.length, equals(2));

      // Both habits originally had y = 1.0, but when All is selected, they must be shifted so they don't hide behind each other
      final habit1SpotY = bars[0].spots[0].y;
      final habit2SpotY = bars[1].spots[0].y;
      expect(habit1SpotY, isNot(equals(habit2SpotY)));
      expect((habit1SpotY - habit2SpotY).abs(), greaterThan(0.01));
    },
  );

  testWidgets(
    'When a single habit is selected, no vertical shift is applied',
    (tester) async {
      final state = HabitStatsState(
        showAllHabits: true,
        selectedHabitName: 'Workout',
        habitNames: const ['Workout', 'Reading'],
        todaySummary: [
          HabitEntity(
            id: '1',
            name: 'Workout',
            isCompleted: true,
            createdAt: DateTime(2024, 1, 1),
          ),
          HabitEntity(
            id: '2',
            name: 'Reading',
            isCompleted: true,
            createdAt: DateTime(2024, 1, 1),
          ),
        ],
        individualTrends: {
          'Workout': [const FlSpot(0, 1.0), const FlSpot(1, 1.0)],
          'Reading': [const FlSpot(0, 1.0), const FlSpot(1, 1.0)],
        },
        daysPeriod: 2,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            habitStatsNotifierProvider.overrideWith(
              () => _FakeNotifier(state),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: LineChartBox(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final lineChartFinder = find.byType(LineChart);
      expect(lineChartFinder, findsOneWidget);

      final lineChart = tester.widget<LineChart>(lineChartFinder);
      final bars = lineChart.data.lineBarsData;
      expect(bars.length, equals(1));
      expect(bars[0].spots[0].y, equals(1.0));
    },
  );
}
