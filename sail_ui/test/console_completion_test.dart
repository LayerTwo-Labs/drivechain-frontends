import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

void main() {
  late List<String> ran;

  ConsoleService service(String name, List<String> commands) {
    return ConsoleService(
      name: name,
      commands: commands,
      execute: (command, args) async {
        ran.add('$name:$command');
        return 'ok';
      },
    );
  }

  Widget console() {
    return MaterialApp(
      home: SailTheme(
        data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
        child: Scaffold(
          body: ConsoleView(
            services: [
              service('alpha', ['help', 'alpha-only']),
              service('beta', ['help', 'beta-only']),
            ],
          ),
        ),
      ),
    );
  }

  setUp(() => ran = []);

  testWidgets('a command two CLIs publish names both of them', (tester) async {
    await tester.pumpWidget(console());
    await tester.enterText(find.byType(TextField), 'hel');
    await tester.pumpAndSettle();

    Finder inList(String text) => find.descendant(
      of: find.byType(ListView),
      matching: find.text(text),
    );

    // One row for each publisher, and each row names its own CLI.
    expect(inList('help'), findsNWidgets(2));
    expect(inList('alpha'), findsOneWidget);
    expect(inList('beta'), findsOneWidget);
  });

  testWidgets('the picked row decides which CLI runs the command', (tester) async {
    await tester.pumpWidget(console());
    await tester.enterText(find.byType(TextField), 'hel');
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(of: find.byType(ListView), matching: find.text('beta')),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'help');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(ran, ['beta:help']);
  });

  testWidgets('the CLI the user last used answers a shared command', (tester) async {
    await tester.pumpWidget(console());

    await tester.enterText(find.byType(TextField), 'beta-only');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'help');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(ran, ['beta:beta-only', 'beta:help']);
  });
}
