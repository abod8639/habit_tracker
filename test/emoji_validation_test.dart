import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:habit_tracker/features/home/presentation/widget/my_text_taile.dart';
import 'package:habit_tracker/features/home/presentation/widget/myalart_dialog.dart';
import 'package:habit_tracker/generated/l10n.dart';

void main() {
  group('Emoji & Length Validation Tests', () {
    testWidgets('MyTextTaile renders 99+ emojis without crashing', (
      tester,
    ) async {
      final emojis = '😀' * 99 + ' Walking';

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: Scaffold(
            body: MyTextTaile(
              habitId: 'h1',
              habitName: emojis,
              habitCompleted: false,
              onChanged: (_) {},
              onDelete: (_) {},
              onEdit: (_) {},
              onTap: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(MyTextTaile), findsOneWidget);
    });

    testWidgets('Myalartd enforces 100 character limit', (tester) async {
      final controller = TextEditingController();
      String? savedText;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            home: Scaffold(
              body: MyalartDialog(
                controller: controller,
                isEditing: true,
                onSave: () => savedText = controller.text,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final textField = find.byType(TextFormField);
      expect(textField, findsOneWidget);

      // Enter 105 emojis
      final emojis = '🔥' * 105;
      await tester.enterText(textField, emojis);
      await tester.pumpAndSettle();

      // Controller should enforce maximum 100 grapheme clusters
      expect(controller.text.characters.length, lessThanOrEqualTo(100));

      final saveButton = find.text('Edit');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      expect(savedText, isNotNull);
      expect(savedText!.characters.length, lessThanOrEqualTo(100));
    });
  });
}
