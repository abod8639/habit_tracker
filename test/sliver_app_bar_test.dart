import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/core/components/my_app_bar.dart';

void main() {
  group('MySliverAppBar Clean Architecture Widget Tests', () {
    testWidgets('renders title text with correct styling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: const [
                MySliverAppBar(
                  title: 'Test Title',
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
      expect(find.byType(SliverAppBar), findsOneWidget);
    });

    testWidgets('renders custom actions and back button', (tester) async {
      bool backPressed = false;
      bool actionPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                MySliverAppBar(
                  title: 'Settings',
                  onBack: () => backPressed = true,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () => actionPressed = true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Settings'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      expect(backPressed, true);

      await tester.tap(find.byIcon(Icons.check));
      expect(actionPressed, true);
    });

    testWidgets('hides leading when showLeading is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: const [
                MySliverAppBar(
                  title: 'No Leading',
                  showLeading: false,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('No Leading'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsNothing);
    });
  });
}
