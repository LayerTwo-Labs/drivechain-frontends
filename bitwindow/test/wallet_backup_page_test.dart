import 'dart:async';
import 'dart:io';

import 'package:bitwindow/pages/welcome/wallet_backup_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

/// Stands in for the orchestrator round trip. [gate] holds a derive open so a
/// test can act while one is in flight.
class _FakeWriter extends WalletWriterProvider {
  _FakeWriter() : super(bitwindowAppDir: Directory.systemTemp);

  Completer<void>? gate;
  int calls = 0;

  @override
  Future<Map<String, dynamic>> generateWalletFromEntropy(
    List<int> entropy, {
    String? name,
    String? passphrase,
    String? sourceText,
    int wordCount = 12,
    bool doNotSave = false,
  }) async {
    calls++;
    if (gate != null) {
      await gate!.future;
    }
    return {'mnemonic': List.generate(wordCount, (i) => 'word${i + 1}').join(' ')};
  }
}

/// The page targets a desktop window; the default 800x600 surface overflows it.
Future<void> _pumpPage(WidgetTester tester, {SeedEntryMode mode = SeedEntryMode.generate}) async {
  await tester.binding.setSurfaceSize(const Size(1440, 1024));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(_app(mode));
  await tester.pumpAndSettle();
}

Widget _app(SeedEntryMode mode) {
  return MaterialApp(
    home: SailTheme(
      data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
      child: WalletBackupPage(mode: mode),
    ),
  );
}

SailButton _createWalletButton(WidgetTester tester) {
  return tester.widgetList<SailButton>(find.widgetWithText(SailButton, 'Create Wallet')).first;
}

SailThemeData _themeInPage(WidgetTester tester) {
  return SailTheme.of(tester.element(find.text('Backup your wallet')));
}

// SailButton spins while its async onPressed is pending, and the confirm future
// stays pending until the dialog closes, so pumpAndSettle would never settle.
Future<void> _tapAndSettle(WidgetTester tester, String label) async {
  await tester.tap(find.widgetWithText(SailButton, label).first);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  late _FakeWriter writer;

  setUp(() {
    GetIt.I.registerSingleton<Logger>(Logger());
    writer = _FakeWriter();
    GetIt.I.registerSingleton<WalletWriterProvider>(writer);
  });

  tearDown(() async => GetIt.I.reset());

  testWidgets('generates a seed on open and stays light', (tester) async {
    await _pumpPage(tester);

    expect(find.text('word1'), findsOneWidget);
    expect(find.text('Valid checksum'), findsOneWidget);
    expect(_themeInPage(tester).type, SailThemeValues.light);
  });

  testWidgets('enabling paranoid mode wipes the seed and turns the screen dark', (tester) async {
    await _pumpPage(tester);
    expect(find.text('word1'), findsOneWidget);

    await _tapAndSettle(tester, 'Paranoid mode');
    expect(find.text('Enable paranoid mode?'), findsOneWidget);
    await _tapAndSettle(tester, 'Yes, enable');

    expect(find.text('word1'), findsNothing);
    expect(_themeInPage(tester).type, SailThemeValues.dark);
  });

  testWidgets('declining paranoid mode keeps the seed and the light theme', (tester) async {
    await _pumpPage(tester);

    await _tapAndSettle(tester, 'Paranoid mode');
    await _tapAndSettle(tester, 'No');

    expect(find.text('word1'), findsOneWidget);
    expect(_themeInPage(tester).type, SailThemeValues.light);
  });

  testWidgets('clearing entropy mid-derive does not strand the loading state', (tester) async {
    await _pumpPage(tester);

    await _tapAndSettle(tester, 'Paranoid mode');
    await _tapAndSettle(tester, 'Yes, enable');

    final field = find.widgetWithText(TextField, 'Type anything: a sentence, dice rolls, hex, whatever you like');
    writer.gate = Completer<void>();
    await tester.enterText(field, 'dice rolls');
    await tester.pump();

    // Clear the field while that derive is still open, then let it land.
    await tester.enterText(field, '');
    await tester.pump();
    writer.gate!.complete();
    await tester.pump();
    await tester.pump();

    expect(_createWalletButton(tester).loading, isFalse);
  });

  testWidgets('a superseded derive never overwrites the newest words', (tester) async {
    await _pumpPage(tester);
    await _tapAndSettle(tester, 'Paranoid mode');
    await _tapAndSettle(tester, 'Yes, enable');

    final field = find.widgetWithText(TextField, 'Type anything: a sentence, dice rolls, hex, whatever you like');
    writer.gate = Completer<void>();
    await tester.enterText(field, 'first');
    await tester.pump();

    writer.gate!.complete();
    writer.gate = null;
    await tester.enterText(field, 'second');
    await tester.pump();
    await tester.pump();

    expect(find.text('word1'), findsOneWidget);
  });

  testWidgets('re-enter only accepts the words in order', (tester) async {
    await _pumpPage(tester);

    await _tapAndSettle(tester, 'Create Wallet');
    expect(find.text('Have these 12 words been written down?'), findsOneWidget);
    await _tapAndSettle(tester, 'Yes, continue');
    expect(find.text('Re-enter your words'), findsOneWidget);

    // The grid reads down each column, so the nth field on screen is not the
    // nth word: screen position p holds word (p % columns) * rows + (p ~/ columns).
    const columns = 3;
    const rows = 12 ~/ columns;
    final boxes = find.byType(TextField);
    expect(boxes, findsNWidgets(12));
    for (var p = 0; p < 12; p++) {
      final word = (p % columns) * rows + (p ~/ columns);
      await tester.enterText(boxes.at(p), 'word${word + 1}');
    }
    await tester.pump();
    expect(_createWalletButton(tester).disabled, isFalse);

    await tester.enterText(boxes.at(4), 'wrong');
    await tester.pump();
    expect(_createWalletButton(tester).disabled, isTrue);
  });

  testWidgets('re-enter takes a pasted phrase into the box it belongs in', (tester) async {
    await _pumpPage(tester);
    await _tapAndSettle(tester, 'Create Wallet');
    await _tapAndSettle(tester, 'Yes, continue');

    final phrase = List.generate(12, (i) => 'word${i + 1}').join(' ');
    await tester.enterText(find.byType(TextField).first, phrase);
    await tester.pump();

    expect(find.text('word12'), findsOneWidget);
    expect(_createWalletButton(tester).disabled, isFalse);
  });

  testWidgets('re-enter fills from the start when the paste lands in a later box', (tester) async {
    await _pumpPage(tester);
    await _tapAndSettle(tester, 'Create Wallet');
    await _tapAndSettle(tester, 'Yes, continue');

    final phrase = List.generate(12, (i) => 'word${i + 1}').join(' ');
    await tester.enterText(find.byType(TextField).at(4), phrase);
    await tester.pump();

    expect(_createWalletButton(tester).disabled, isFalse);
  });

  group('import mode', () {
    const phrase = 'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';
    final long = '${'abandon ' * 23}art';

    testWidgets('opens on an empty grid without minting a seed', (tester) async {
      await _pumpPage(tester, mode: SeedEntryMode.importExisting);

      expect(find.text('Enter your seed phrase'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(12));
      expect(writer.calls, 0, reason: 'importing a seed must not generate one');
      expect(_createWalletButton(tester).disabled, isTrue);
    });

    // Nobody types 12 words into 12 boxes; they paste the phrase into the first.
    testWidgets('pasting the whole phrase into the first box fills the grid', (tester) async {
      await _pumpPage(tester, mode: SeedEntryMode.importExisting);

      await tester.enterText(find.byType(TextField).first, phrase);
      await tester.pump();

      expect(find.text('about'), findsOneWidget);
      expect(find.text('abandon'), findsNWidgets(11));
      expect(find.text('Valid checksum'), findsOneWidget);
      expect(_createWalletButton(tester).disabled, isFalse);
    });

    // A wrong word derives a different wallet in silence, so the checksum has
    // to hold the button shut.
    testWidgets('a phrase that fails its checksum cannot continue', (tester) async {
      await _pumpPage(tester, mode: SeedEntryMode.importExisting);

      await tester.enterText(find.byType(TextField).first, phrase.replaceFirst('about', 'zebra'));
      await tester.pump();

      expect(find.textContaining('not a valid BIP39 phrase'), findsOneWidget);
      expect(_createWalletButton(tester).disabled, isTrue);
    });

    // The grid opens at 12, so a 24-word backup has to grow it on paste.
    testWidgets('pasting 24 words switches the grid to 24', (tester) async {
      await _pumpPage(tester, mode: SeedEntryMode.importExisting);

      await tester.enterText(find.byType(TextField).first, long);
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNWidgets(24));
      expect(find.text('art'), findsOneWidget);
      expect(find.text('Valid checksum'), findsOneWidget);
      expect(_createWalletButton(tester).disabled, isFalse);
    });

    testWidgets('pasting 12 words into a 24 grid switches back to 12', (tester) async {
      await _pumpPage(tester, mode: SeedEntryMode.importExisting);

      await tester.enterText(find.byType(TextField).first, long);
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNWidgets(24));

      await tester.enterText(find.byType(TextField).first, phrase);
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNWidgets(12));
      expect(find.text('about'), findsOneWidget);
      expect(find.text('Valid checksum'), findsOneWidget);
    });

    // Pasting into whichever box happens to have focus is still a whole-phrase
    // paste, so it must land in order from the first box, not from that one.
    testWidgets('a full phrase pasted into a later box still fills from the start', (tester) async {
      await _pumpPage(tester, mode: SeedEntryMode.importExisting);

      await tester.enterText(find.byType(TextField).at(4), phrase);
      await tester.pumpAndSettle();

      expect(find.text('about'), findsOneWidget);
      expect(find.text('abandon'), findsNWidgets(11));
      expect(find.text('Valid checksum'), findsOneWidget);
    });

    testWidgets('switching to 24 words keeps what was already typed', (tester) async {
      await _pumpPage(tester, mode: SeedEntryMode.importExisting);

      await tester.enterText(find.byType(TextField).first, phrase);
      await tester.pump();

      await tester.tap(find.text('Use 12 Words'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Use 24 Words').last);
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNWidgets(24));
      expect(find.text('about'), findsOneWidget);
      expect(_createWalletButton(tester).disabled, isTrue, reason: '12 of 24 boxes are still empty');
    });
  });
}
