import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

Future<void> _pump(
  WidgetTester tester,
  List<String> typed, {
  bool showKeys = false,
  bool enabled = true,
}) async {
  await tester.binding.setSurfaceSize(const Size(900, 700));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      home: SailTheme(
        data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
        child: Scaffold(
          body: SizedBox(
            width: 768,
            child: SailEntropyKeyboard(
              onType: typed.add,
              showKeys: showKeys,
              enabled: enabled,
              caption: 'Move the pointer',
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

List<String> _drawnKeys(WidgetTester tester) {
  return tester
      .widgetList<Text>(
        find.descendant(of: find.byKey(const Key('mouse-entropy-pad')), matching: find.byType(Text)),
      )
      .map((t) => t.data ?? '')
      .where((s) => s.length == 1)
      .toList();
}

Future<TestGesture> _enter(WidgetTester tester, Offset at) async {
  final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await gesture.addPointer(location: at);
  addTearDown(gesture.removePointer);
  await gesture.moveTo(at);
  await tester.pump();
  return gesture;
}

void main() {
  test('the board offers every printable ASCII character once', () {
    expect(entropyKeyboardChars, hasLength(94));
    expect(entropyKeyboardChars.split('').toSet(), hasLength(94));
    expect(entropyKeyboardChars.codeUnits.every((c) => c >= 0x21 && c <= 0x7e), isTrue);
  });

  testWidgets('a hidden board types the keys under the pointer', (tester) async {
    final typed = <String>[];
    await _pump(tester, typed);

    final pad = find.byKey(const Key('mouse-entropy-pad'));
    expect(find.text('Move the pointer'), findsOneWidget);
    final gesture = await _enter(tester, tester.getCenter(pad));

    expect(typed, hasLength(1));
    expect(entropyKeyboardChars, contains(typed.single));

    await gesture.moveTo(tester.getTopLeft(pad) + const Offset(20, 20));
    await tester.pump();
    expect(typed, hasLength(2));

    await gesture.moveTo(Offset.zero);
    await tester.pump();
  });

  testWidgets('a shown board draws every key and types the drawn key under the pointer', (tester) async {
    final typed = <String>[];
    await _pump(tester, typed, showKeys: true);

    for (final char in ['!', 'A', 'z', '~']) {
      expect(find.text(char), findsOneWidget, reason: 'the board draws $char');
    }
    final drawn = _drawnKeys(tester);
    expect(drawn.toSet(), hasLength(94));

    final pad = find.byKey(const Key('mouse-entropy-pad'));
    await _enter(tester, tester.getTopLeft(pad) + const Offset(14, 14));
    expect(typed, [drawn.first], reason: 'the pointer types the key drawn at the top left');
  });

  testWidgets('the board opens with a shuffled layout', (tester) async {
    await _pump(tester, <String>[], showKeys: true);

    final drawn = _drawnKeys(tester);
    expect(drawn.toSet(), hasLength(94));
    expect(drawn.join(), isNot(entropyKeyboardChars), reason: 'the shuffle moves the keys');
  });

  testWidgets('the Shuffle button deals a new layout', (tester) async {
    final typed = <String>[];
    await _pump(tester, typed, showKeys: true);
    final before = _drawnKeys(tester).join();

    await tester.tap(find.widgetWithText(SailButton, 'Shuffle').first);
    await tester.pump();

    final after = _drawnKeys(tester).join();
    expect(after, isNot(before));
    expect(after.split('').toSet(), hasLength(94));
    expect(typed, isEmpty, reason: 'the button types nothing');
  });

  testWidgets('a key repeats while the pointer rests on it', (tester) async {
    final typed = <String>[];
    await _pump(tester, typed);

    final pad = find.byKey(const Key('mouse-entropy-pad'));
    final gesture = await _enter(tester, tester.getCenter(pad));
    final first = typed.single;

    await tester.pump(entropyKeyRepeat * 3);
    expect(typed, hasLength(4));
    expect(typed.every((c) => c == first), isTrue, reason: 'the resting key repeats itself');

    await gesture.moveTo(Offset.zero);
    await tester.pump();
    await tester.pump(entropyKeyRepeat * 3);
    expect(typed, hasLength(4), reason: 'the repeat stops when the pointer leaves');
  });

  testWidgets('a disabled board types nothing', (tester) async {
    final typed = <String>[];
    await _pump(tester, typed, showKeys: true, enabled: false);

    expect(find.byKey(const Key('mouse-entropy-pad')), findsNothing);
    final opacity = tester.widget<Opacity>(find.byType(Opacity).first);
    expect(opacity.opacity, 0.5);
    expect(typed, isEmpty);
  });
}
