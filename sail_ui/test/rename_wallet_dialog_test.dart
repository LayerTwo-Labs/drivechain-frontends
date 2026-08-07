import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

Future<String?> _open(WidgetTester tester, String current) async {
  String? result;
  await tester.pumpWidget(
    MaterialApp(
      home: SailTheme(
        data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
        child: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () async => result = await showRenameWalletDialog(context, current),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return result;
}

void main() {
  testWidgets('returns the new name', (tester) async {
    await _open(tester, 'bitkey');

    await tester.enterText(find.byType(TextField), 'treasury');
    await tester.pump();
    await tester.tap(find.text('Rename').last);
    await tester.pumpAndSettle();

    expect(find.text('Rename wallet'), findsNothing, reason: 'the dialog closes on rename');
  });

  testWidgets('an empty name cannot be submitted', (tester) async {
    await _open(tester, 'bitkey');

    await tester.enterText(find.byType(TextField), '   ');
    await tester.pump();
    await tester.tap(find.text('Rename').last);
    await tester.pumpAndSettle();

    expect(find.text('Rename wallet'), findsOneWidget, reason: 'a blank name must not close it');
  });

  testWidgets('cancel keeps the wallet name', (tester) async {
    await _open(tester, 'bitkey');

    await tester.tap(find.text('Cancel').last);
    await tester.pumpAndSettle();

    expect(find.text('Rename wallet'), findsNothing);
  });
}
