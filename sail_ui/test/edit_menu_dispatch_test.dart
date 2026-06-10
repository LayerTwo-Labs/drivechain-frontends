import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// The macOS Edit menu items in CrossPlatformMenuBar dispatch text-editing
// intents to primaryFocus. Verify that dispatch path actually drives a
// focused TextField.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<TextEditingController> pumpField(WidgetTester tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: TextField(controller: controller, autofocus: true)),
      ),
    );
    await tester.pump();
    return controller;
  }

  // Mirrors CrossPlatformMenuBar._editMenuItem's onSelected.
  void invokeFromMenu(Intent intent) {
    final context = primaryFocus?.context;
    expect(context, isNotNull, reason: 'a field must be focused');
    Actions.maybeInvoke(context!, intent);
  }

  testWidgets('Paste intent from menu inserts clipboard text', (tester) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.getData') return {'text': 'twelve words go here'};
      if (call.method == 'Clipboard.hasStrings') return {'value': true};
      return null;
    });

    final controller = await pumpField(tester);
    invokeFromMenu(const PasteTextIntent(SelectionChangedCause.keyboard));
    await tester.pump();

    expect(controller.text, 'twelve words go here');
  });

  testWidgets('Select All + Copy intents from menu copy field text', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') copied = (call.arguments as Map)['text'] as String;
      return null;
    });

    final controller = await pumpField(tester);
    controller.text = 'secret seed';
    await tester.pump();

    invokeFromMenu(const SelectAllTextIntent(SelectionChangedCause.keyboard));
    await tester.pump();
    invokeFromMenu(CopySelectionTextIntent.copy);
    await tester.pump();

    expect(copied, 'secret seed');
  });
}
