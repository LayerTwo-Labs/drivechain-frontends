import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  String? clipboard;

  setUp(() {
    clipboard = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        switch (call.method) {
          case 'Clipboard.setData':
            clipboard = (call.arguments as Map)['text'] as String?;
            return null;
          case 'Clipboard.getData':
            return clipboard == null ? null : {'text': clipboard};
        }
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    );
  });

  const clearAfter = Duration(seconds: 60);

  testWidgets('secret stays on the clipboard before clearAfter', (tester) async {
    await copySecretToClipboard('abandon abandon about', clearAfter: clearAfter);
    await tester.pump(const Duration(seconds: 59));

    expect(clipboard, 'abandon abandon about');
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('secret is cleared after clearAfter', (tester) async {
    await copySecretToClipboard('abandon abandon about', clearAfter: clearAfter);
    await tester.pump(clearAfter);
    await tester.pump();

    expect(clipboard, '');
  });

  testWidgets('text copied later is kept after clearAfter', (tester) async {
    await copySecretToClipboard('abandon abandon about', clearAfter: clearAfter);
    await Clipboard.setData(const ClipboardData(text: 'bc1qaddress'));
    await tester.pump(clearAfter);
    await tester.pump();

    expect(clipboard, 'bc1qaddress');
  });

  testWidgets('secret CopyButton clears the clipboard after 60 seconds', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SailTheme(
          data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
          child: const Scaffold(
            body: Center(child: CopyButton(secret: true, text: 'xprv-secret')),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(CopyButton));
    await tester.pump();
    expect(clipboard, 'xprv-secret');

    await tester.pump(clearAfter);
    await tester.pump();
    expect(clipboard, '');
  });
}
