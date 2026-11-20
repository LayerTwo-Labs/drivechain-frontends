import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

void main() {
  tearDown(() => SailStyleValues.phoneLayoutOverride = null);

  Future<void> runCommand(WidgetTester tester, {required bool phone}) async {
    SailStyleValues.phoneLayoutOverride = phone;
    tester.view.physicalSize = const Size(390, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: SailTheme(
          data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
          child: Scaffold(
            body: ConsoleView(
              services: [
                ConsoleService(name: 'cli', commands: ['getblockcount'], execute: (_, _) async => 'output'),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'getblockcount');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
  }

  Rect textRect(WidgetTester tester, String text) =>
      tester.getRect(find.byWidgetPredicate((w) => w is SelectableText && w.data == text));

  testWidgets('on a phone the output starts below the command line at the left edge', (tester) async {
    await runCommand(tester, phone: true);

    final command = textRect(tester, 'getblockcount');
    final output = textRect(tester, 'output');
    expect(output.top, greaterThanOrEqualTo(command.bottom));
    expect(output.left, lessThan(command.left - 40));
    expect(output.right, closeTo(390 - 16, 1));
    expect(output.left, closeTo(16 + 16 + 2 + 8, 1));
  });

  testWidgets('on desktop the output lines up with the command text', (tester) async {
    await runCommand(tester, phone: false);

    final command = textRect(tester, 'getblockcount');
    final output = textRect(tester, 'output');
    expect(output.left, closeTo(command.left, 1));
  });
}
