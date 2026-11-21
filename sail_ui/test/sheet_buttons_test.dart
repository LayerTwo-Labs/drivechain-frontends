import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

// Wider than a phone: the test font draws each letter as a wide square.
const _screen = Size(500, 800);

WalletMetadata _wallet(String id, String name) => WalletMetadata(
  id: id,
  name: name,
  gradient: WalletGradient(
    backgroundSvg: 'background_northern.svg',
    colors: const ['#000000', '#111111', '#222222'],
    stops: const [0, 0.5, 1],
    centerX: 0,
    centerY: 0,
    radius: 1.2,
    seed: 1,
  ),
  createdAt: DateTime(2026),
  lastUsed: DateTime(2026),
);

Future<void> _pump(WidgetTester tester, Widget Function(BuildContext) home) async {
  tester.view.physicalSize = _screen;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => SailTheme(
        data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
        child: child ?? const SizedBox(),
      ),
      home: Scaffold(body: Builder(builder: home)),
    ),
  );
}

Future<void> _openDialog(WidgetTester tester, WidgetBuilder builder) async {
  await _pump(
    tester,
    (context) => TextButton(
      onPressed: () => showThemedDialog<void>(context: context, builder: builder),
      child: const Text('open'),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

Future<void> _openEditWallet(WidgetTester tester) async {
  await _pump(
    tester,
    (context) => TextButton(
      onPressed: () => showEditWalletDialog(
        context,
        currentName: 'wallet1',
        gradient: _wallet('a', 'wallet1').gradient,
        onChangePicture: () async => null,
        onConfirmDelete: () async => false,
      ),
      child: const Text('open'),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

Finder _button(String label) => find.byWidgetPredicate((w) => w is SailButton && w.label == label);

ButtonVariant _variant(WidgetTester tester, String label) => tester.widget<SailButton>(_button(label)).variant;

Widget _alert(BuildContext context, {ButtonVariant? confirm}) => SailAlertCard(
  title: 'Delete wallet1?',
  subtitle: 'The wallet leaves this computer.',
  confirmText: 'Delete wallet',
  confirmButtonVariant: confirm,
  onConfirm: () async => Navigator.of(context).pop(),
);

void main() {
  tearDown(() => SailStyleValues.phoneLayoutOverride = null);

  group('on a phone', () {
    setUp(() => SailStyleValues.phoneLayoutOverride = true);

    testWidgets('Edit wallet puts Delete wallet at the left, then a grey Cancel and a filled Save', (tester) async {
      await _openEditWallet(tester);

      expect(tester.takeException(), isNull);
      expect(_variant(tester, 'Delete wallet'), ButtonVariant.destructive);
      expect(_variant(tester, 'Cancel'), ButtonVariant.secondary);
      expect(_variant(tester, 'Save'), ButtonVariant.primary);
      final delete = tester.getRect(_button('Delete wallet'));
      final cancel = tester.getRect(_button('Cancel'));
      final save = tester.getRect(_button('Save'));
      expect(delete.right, lessThan(cancel.left));
      expect(cancel.right, lessThan(save.left));
    });

    testWidgets('an alert sheet shows a grey Cancel and the action at equal width', (tester) async {
      await _openDialog(tester, (context) => _alert(context, confirm: ButtonVariant.destructive));

      expect(tester.takeException(), isNull);
      expect(_variant(tester, 'Cancel'), ButtonVariant.secondary);
      expect(_variant(tester, 'Delete wallet'), ButtonVariant.destructive);
      final cancel = tester.getRect(_button('Cancel'));
      final action = tester.getRect(_button('Delete wallet'));
      expect(cancel.right, lessThan(action.left));
      expect(cancel.width, closeTo(action.width, 1));
      expect(tester.getRect(find.byType(SailCard)).bottom, _screen.height);
    });

    testWidgets('an alert sheet fills its action when no style is given', (tester) async {
      await _openDialog(tester, (context) => _alert(context));

      expect(_variant(tester, 'Delete wallet'), ButtonVariant.primary);
    });
  });

  group('on a desktop', () {
    setUp(() => SailStyleValues.phoneLayoutOverride = false);

    testWidgets('Edit wallet keeps the outline Cancel and the ghost Delete wallet', (tester) async {
      await _openEditWallet(tester);

      expect(_variant(tester, 'Delete wallet'), ButtonVariant.ghost);
      expect(_variant(tester, 'Cancel'), ButtonVariant.outline);
    });

    testWidgets('an alert keeps a ghost Cancel and a secondary action at the right', (tester) async {
      await _openDialog(tester, (context) => _alert(context));

      expect(_variant(tester, 'Cancel'), ButtonVariant.ghost);
      expect(_variant(tester, 'Delete wallet'), ButtonVariant.secondary);
      expect(tester.getRect(find.byType(SailCard)).bottom, lessThan(_screen.height - 20));
    });
  });
}
