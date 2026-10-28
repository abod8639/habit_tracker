import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/home/presentation/widget/curved_bottom_nav_bar.dart';
import 'package:habit_tracker/generated/l10n.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createWidgetUnderTest({required VoidCallback onAddHabit}) {
    return MaterialApp(
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: Scaffold(
        bottomNavigationBar: CurvedBottomNavBar(
          onAddHabit: onAddHabit,
        ),
      ),
    );
  }

  testWidgets('CurvedBottomNavBar renders 3 items: Settings, Add Habit FAB, AI Chat',
      (WidgetTester tester) async {
    bool addHabitCalled = false;

    await tester.pumpWidget(
      createWidgetUnderTest(
        onAddHabit: () {
          addHabitCalled = true;
        },
      ),
    );
    await tester.pumpAndSettle();

    // Verify Settings button exists on left
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);

    // Verify Add button exists in center with add icon
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);

    // Verify AI Chat button exists on right
    expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsOneWidget);

    // Tap Center FAB and verify callback
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    expect(addHabitCalled, isTrue);
  });
}
