import 'dart:async';
import 'dart:io';

import 'package:bitwindow/pages/welcome/wallet_backup_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

const _osHex = 'abababababababababababababababab';

/// The words the fake backend derives. They depend only on the text.
List<String> _wordsFor(String text, int count) {
  final tag = text.codeUnits.fold<int>(7, (a, b) => (a * 31 + b) % 9973);
  return List.generate(count, (i) => 'w$tag-${i + 1}');
}

/// Stands in for the orchestrator round trip. [gate] holds a derive open so a
/// test can act while one is in flight.
class _FakeWriter extends WalletWriterProvider {
  _FakeWriter() : super(bitwindowAppDir: Directory.systemTemp);

  Completer<void>? gate;
  int calls = 0;
  List<int>? lastExtraEntropy;
  String? lastSourceText;

  @override
  Future<Map<String, dynamic>> generateWalletFromEntropy(
    List<int> entropy, {
    String? name,
    String? passphrase,
    String? sourceText,
    int wordCount = 12,
    bool doNotSave = false,
    List<int> extraEntropy = const [],
  }) async {
    calls++;
    lastExtraEntropy = extraEntropy;
    lastSourceText = sourceText;
    final waitFor = gate;
    if (waitFor != null) {
      await waitFor.future;
    }
    return {
      'mnemonic': _wordsFor(sourceText ?? _osHex, wordCount).join(' '),
      'entropy_hex': _osHex,
    };
  }
}

/// The page targets a desktop window; the default 800x600 surface overflows it.
Future<void> _pumpPage(
  WidgetTester tester, {
  SeedEntryMode mode = SeedEntryMode.generate,
  Future<void> Function(SeedBackup seed)? onCreate,
}) async {
  await tester.binding.setSurfaceSize(const Size(1440, 2400));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(_app(mode, onCreate));
  await tester.pumpAndSettle();
}

Widget _app(SeedEntryMode mode, Future<void> Function(SeedBackup seed)? onCreate) {
  return MaterialApp(
    home: SailTheme(
      data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
      child: WalletBackupPage(mode: mode, onCreate: onCreate),
    ),
  );
}

SailButton _createWalletButton(WidgetTester tester) {
  return tester.widgetList<SailButton>(find.widgetWithText(SailButton, 'Create Wallet')).first;
}

Finder get _field => find.widgetWithText(TextField, 'Type anything: a sentence, dice rolls, hex, whatever you like');

String _fieldText(WidgetTester tester) => tester.widget<TextField>(_field).controller!.text;

// SailButton spins while its async onPressed is pending, and the confirm future
// stays pending until the dialog closes, so pumpAndSettle would never settle.
Future<void> _tapAndSettle(WidgetTester tester, String label) async {
  await tester.tap(find.widgetWithText(SailButton, label).first);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
}

// Moves the pointer over the board so it types one key per move. The pointer
// leaves at the end, so no repeat timer outlives the test.
Future<void> _typeOnPad(WidgetTester tester, int keys) async {
  final pad = find.byKey(const Key('mouse-entropy-pad'));
  final start = tester.getCenter(pad);
  final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await gesture.addPointer(location: start);
  addTearDown(gesture.removePointer);
  for (var i = 0; i < keys; i++) {
    await gesture.moveTo(start + Offset(3.0 * i, 0));
    await tester.pump();
  }
  await gesture.moveTo(Offset.zero);
  await tester.pump();
}

Future<void> _toReenter(WidgetTester tester) async {
  await _tapAndSettle(tester, 'Continue');
  expect(find.text('Re-enter your words'), findsOneWidget);
}

Future<void> _enterWords(WidgetTester tester, List<String> words) async {
  await tester.enterText(find.byType(TextField).first, words.join(' '));
  await tester.pump();
}

void main() {
  late _FakeWriter writer;

  setUp(() {
    GetIt.I.registerSingleton<Logger>(Logger());
    writer = _FakeWriter();
    GetIt.I.registerSingleton<WalletWriterProvider>(writer);
  });

  tearDown(() async => GetIt.I.reset());

  testWidgets('opens with OS entropy in the field and its words shown', (tester) async {
    await _pumpPage(tester);

    expect(find.text('Add mouse entropy'), findsOneWidget);
    expect(_fieldText(tester), _osHex);
    expect(writer.lastSourceText, _osHex, reason: 'the words come from the field text');
    expect(find.text(_wordsFor(_osHex, 12).first), findsOneWidget);
    expect(find.text('Valid checksum'), findsOneWidget);
    expect(find.text('32 characters'), findsOneWidget);
    expect(find.text('0 samples'), findsOneWidget);
    expect(tester.widgetList<SailButton>(find.widgetWithText(SailButton, 'Continue')).first.disabled, isFalse);
  });

  testWidgets('a key appends one character and derives at once', (tester) async {
    await _pumpPage(tester);
    final before = _wordsFor(_osHex, 12).first;

    await _typeOnPad(tester, 1);
    await tester.pump();

    final text = _fieldText(tester);
    expect(text, hasLength(33));
    expect(text.startsWith(_osHex), isTrue);
    expect(writer.lastSourceText, text, reason: 'no debounce: the derive runs on the key');
    expect(find.text(_wordsFor(text, 12).first), findsOneWidget);
    expect(find.text(before), findsNothing);
    expect(find.text('1 sample'), findsOneWidget);
    expect(writer.lastExtraEntropy, isEmpty, reason: 'no hidden entropy beside the field');
  });

  testWidgets('the words stay on screen while a derive runs', (tester) async {
    await _pumpPage(tester);
    final before = _wordsFor(_osHex, 12).first;

    writer.gate = Completer<void>();
    await _typeOnPad(tester, 1);
    expect(find.text(before), findsOneWidget);

    writer.gate!.complete();
    writer.gate = null;
    await tester.pump();
    await tester.pump();
    expect(find.text(_wordsFor(_fieldText(tester), 12).first), findsOneWidget);
  });

  testWidgets('Continue waits for the newest derive', (tester) async {
    await _pumpPage(tester);
    SailButton next() => tester.widgetList<SailButton>(find.widgetWithText(SailButton, 'Continue')).first;

    writer.gate = Completer<void>();
    await tester.enterText(_field, 'pending entropy');
    await tester.pump();
    expect(next().disabled, isTrue, reason: 'the words on screen are from the old text');

    writer.gate!.complete();
    writer.gate = null;
    await tester.pump();
    await tester.pump();
    expect(next().disabled, isFalse);
    expect(find.text(_wordsFor('pending entropy', 12).first), findsOneWidget);
  });

  testWidgets('keys typed before the OS entropy lands follow it', (tester) async {
    writer.gate = Completer<void>();
    await tester.binding.setSurfaceSize(const Size(1440, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app(SeedEntryMode.generate, null));
    await tester.pump();

    await _typeOnPad(tester, 2);
    expect(writer.calls, 1, reason: 'no derive runs on samples without the OS prefix');
    expect(tester.widgetList<SailButton>(find.widgetWithText(SailButton, 'Continue')).first.disabled, isTrue);

    writer.gate!.complete();
    writer.gate = null;
    await tester.pumpAndSettle();

    final text = _fieldText(tester);
    expect(text, startsWith(_osHex));
    expect(text, hasLength(34));
    expect(writer.lastSourceText, text);
    expect(find.text('2 samples'), findsOneWidget);
  });

  testWidgets('Copy waits for the newest derive', (tester) async {
    await _pumpPage(tester);
    SailButton copy() =>
        tester.widgetList<SailButton>(find.widgetWithText(SailButton, 'Copy Mnemonic for backup')).first;
    expect(copy().disabled, isFalse);

    writer.gate = Completer<void>();
    await tester.enterText(_field, 'pending entropy');
    await tester.pump();
    expect(copy().disabled, isTrue, reason: 'the words on screen are from the old text');

    writer.gate!.complete();
    writer.gate = null;
    await tester.pump();
    await tester.pump();
    expect(copy().disabled, isFalse);
  });

  testWidgets('a word count change before the OS entropy lands keeps it', (tester) async {
    writer.gate = Completer<void>();
    await tester.binding.setSurfaceSize(const Size(1440, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_app(SeedEntryMode.generate, null));
    await tester.pump();

    await tester.tap(find.text('Use 12 Words').first);
    await tester.pump();
    await tester.tap(find.text('Use 24 Words').last);
    await tester.pump();

    writer.gate!.complete();
    writer.gate = null;
    await tester.pumpAndSettle();

    expect(_fieldText(tester), _osHex);
    expect(find.text(_wordsFor(_osHex, 24).last), findsOneWidget);
    expect(tester.widgetList<SailButton>(find.widgetWithText(SailButton, 'Continue')).first.disabled, isFalse);
  });

  testWidgets('the same text gives the same words', (tester) async {
    await _pumpPage(tester);

    await tester.enterText(_field, 'pasted entropy');
    await tester.pump();
    final first = _wordsFor('pasted entropy', 12);
    expect(find.text(first.first), findsOneWidget);

    await tester.enterText(_field, 'pasted entropy!');
    await tester.pump();
    expect(find.text(first.first), findsNothing);

    await tester.enterText(_field, 'pasted entropy');
    await tester.pump();
    expect(find.text(first.first), findsOneWidget);
  });

  testWidgets('a superseded derive never overwrites the newest words', (tester) async {
    await _pumpPage(tester);

    writer.gate = Completer<void>();
    final old = writer.gate!;
    await tester.enterText(_field, 'old');
    await tester.pump();

    writer.gate = null;
    await tester.enterText(_field, 'new');
    await tester.pump();
    await tester.pump();
    expect(find.text(_wordsFor('new', 12).first), findsOneWidget);

    old.complete();
    await tester.pump();
    await tester.pump();
    expect(find.text(_wordsFor('new', 12).first), findsOneWidget);
    expect(find.text(_wordsFor('old', 12).first), findsNothing);
  });

  testWidgets('Generate Random replaces the field and the samples', (tester) async {
    await _pumpPage(tester);
    await _typeOnPad(tester, 3);
    expect(find.text('3 samples'), findsOneWidget);

    await _tapAndSettle(tester, 'Generate Random');

    expect(_fieldText(tester), _osHex);
    expect(find.text('0 samples'), findsOneWidget);
  });

  testWidgets('the removed steps and options are gone', (tester) async {
    await _pumpPage(tester);

    expect(find.text('Paranoid mode'), findsNothing);
    expect(find.text('Enable mouse entropy'), findsNothing);
    expect(find.text('Backup your wallet'), findsNothing);
    expect(find.widgetWithText(SailButton, 'Shuffle'), findsWidgets);

    await _toReenter(tester);
    expect(find.textContaining('been written down'), findsNothing);
  });

  testWidgets('creating a wallet offers no passphrase', (tester) async {
    final created = <SeedBackup>[];
    await _pumpPage(tester, onCreate: (seed) async => created.add(seed));

    expect(find.text('Add passphrase'), findsNothing);
    expect(find.widgetWithText(TextField, 'Passphrase'), findsNothing);

    await _toReenter(tester);
    expect(find.text('Add passphrase'), findsNothing);
    await _enterWords(tester, _wordsFor(_osHex, 12));
    await _tapAndSettle(tester, 'Create Wallet');

    expect(created.single.passphrase, isEmpty);
  });

  testWidgets('with no word entered the button skips, and the modal can go back', (tester) async {
    final created = <SeedBackup>[];
    await _pumpPage(tester, onCreate: (seed) async => created.add(seed));
    await _toReenter(tester);

    await _tapAndSettle(tester, 'Skip and create wallet');
    expect(find.text('Create wallet without a backup?'), findsOneWidget);
    expect(find.text('If you lose the 12 words, you lose the coins in this wallet.'), findsOneWidget);

    await _tapAndSettle(tester, 'Re-enter words');
    expect(find.text('Create wallet without a backup?'), findsNothing);
    expect(find.text('Re-enter your words'), findsOneWidget);
    expect(created, isEmpty);

    await _tapAndSettle(tester, 'Skip and create wallet');
    await _tapAndSettle(tester, 'Create without backup');

    expect(created.single.mnemonic, _wordsFor(_osHex, 12).join(' '));
  });

  testWidgets('words that do not match create nothing', (tester) async {
    final created = <SeedBackup>[];
    await _pumpPage(tester, onCreate: (seed) async => created.add(seed));
    await _toReenter(tester);

    final words = _wordsFor(_osHex, 12);
    await _enterWords(tester, [...words.take(11), 'wrong']);
    expect(_createWalletButton(tester).disabled, isFalse);

    await _tapAndSettle(tester, 'Create Wallet');
    expect(created, isEmpty);
    expect(find.text('12 of 12 entered'), findsOneWidget);
  });

  testWidgets('words that match create the wallet', (tester) async {
    final created = <SeedBackup>[];
    await _pumpPage(tester, onCreate: (seed) async => created.add(seed));
    await _toReenter(tester);

    await _enterWords(tester, _wordsFor(_osHex, 12));
    await _tapAndSettle(tester, 'Create Wallet');

    expect(created.single.mnemonic, _wordsFor(_osHex, 12).join(' '));
  });

  testWidgets('a failed create stays on the page and shows why', (tester) async {
    await _pumpPage(tester, onCreate: (seed) async => throw Exception('electrum is down'));
    await _toReenter(tester);

    await _enterWords(tester, _wordsFor(_osHex, 12));
    await _tapAndSettle(tester, 'Create Wallet');

    expect(find.text('Re-enter your words'), findsOneWidget);
    expect(find.textContaining('electrum is down'), findsOneWidget);
  });

  testWidgets('Back on re-enter keeps the field and the words', (tester) async {
    await _pumpPage(tester);
    await tester.enterText(_field, 'my own entropy');
    await tester.pump();
    await _toReenter(tester);

    await _tapAndSettle(tester, '← Back');

    expect(_fieldText(tester), 'my own entropy');
    expect(find.text(_wordsFor('my own entropy', 12).first), findsOneWidget);
  });

  // The keyboard shortcut takes a different route into the field than typing,
  // so the spread has to hold for a real paste too.
  testWidgets('re-enter spreads a keyboard paste', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    final phrase = _wordsFor(_osHex, 12).join(' ');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.getData') {
        return <String, dynamic>{'text': phrase};
      }
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));

    await _pumpPage(tester);
    await _toReenter(tester);

    await tester.tap(find.byType(TextField).first);
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.meta);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyV);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.meta);
    await tester.pumpAndSettle();
    debugDefaultTargetPlatformOverride = null;

    expect(find.text('12 of 12 entered'), findsOneWidget);
  });

  testWidgets('re-enter fills from the start when the paste lands in a later box', (tester) async {
    await _pumpPage(tester);
    await _toReenter(tester);

    await tester.enterText(find.byType(TextField).at(4), _wordsFor(_osHex, 12).join(' '));
    await tester.pump();

    expect(find.text('12 of 12 entered'), findsOneWidget);
    final success = SailTheme.of(tester.element(find.text('12 of 12 entered'))).colors.success;
    expect(tester.widget<Text>(find.text('12 of 12 entered')).style?.color, success);
  });

  group('import mode', () {
    const phrase = 'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';
    final long = '${'abandon ' * 23}art';

    testWidgets('a restore still takes a BIP39 passphrase', (tester) async {
      final created = <SeedBackup>[];
      await _pumpPage(tester, mode: SeedEntryMode.importExisting, onCreate: (seed) async => created.add(seed));

      await _tapAndSettle(tester, 'Add passphrase');
      await _tapAndSettle(tester, 'Yes, add one');
      await tester.enterText(find.widgetWithText(TextField, 'Passphrase'), 'my secret');
      await tester.enterText(find.byType(TextField).first, phrase);
      await tester.pump();
      await _tapAndSettle(tester, 'Create Wallet');

      expect(created.single.mnemonic, phrase);
      expect(created.single.passphrase, 'my secret');
    });

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

    // An Electrum-app seed fails the checksum too, and the line names it.
    testWidgets('an Electrum seed is named as one', (tester) async {
      await _pumpPage(tester, mode: SeedEntryMode.importExisting);

      await tester.enterText(
        find.byType(TextField).first,
        'bitter grass shiver impose acquire brush forget axis eager alone wine silver',
      );
      await tester.pump();

      expect(find.textContaining('an Electrum seed'), findsOneWidget);
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
