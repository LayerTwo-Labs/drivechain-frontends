import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

const _screen = Size(400, 800);

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

Future<void> _pump(WidgetTester tester, Widget dropdown) async {
  tester.view.physicalSize = _screen;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => SailTheme(
        data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
        child: child ?? const SizedBox(),
      ),
      home: Scaffold(
        body: Align(alignment: Alignment.topLeft, child: dropdown),
      ),
    ),
  );
}

void main() {
  tearDown(() => SailStyleValues.phoneLayoutOverride = null);

  group('on a phone', () {
    setUp(() => SailStyleValues.phoneLayoutOverride = true);

    testWidgets('the wallet menu opens as a sheet of 44 px rows', (tester) async {
      String? selected;
      await _pump(
        tester,
        WalletDropdown(
          currentWallet: _wallet('a', 'wallet1'),
          availableWallets: [_wallet('a', 'wallet1'), _wallet('b', 'savings')],
          onWalletSelected: (id) => selected = id,
          onCreateWallet: () {},
          onEditWallet: (_) {},
        ),
      );

      expect(find.byType(SailDropdownButton<String>), findsNothing);
      await tester.tap(find.text('wallet1'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(tester.getRect(find.byType(SailCard)).bottom, _screen.height);
      for (final label in ['savings', 'Edit wallet1', 'Create new wallet']) {
        final row = find.ancestor(of: find.text(label), matching: find.byType(Container)).first;
        expect(tester.getSize(row).height, 44, reason: label);
      }

      final group = find
          .ancestor(
            of: find.text('savings'),
            matching: find.byWidgetPredicate(
              (w) => w is DecoratedBox && (w.decoration as BoxDecoration).border != null,
            ),
          )
          .first;
      expect(tester.getRect(group).height, 44, reason: 'the other wallets sit in their own bordered group');
      expect(tester.getRect(group).bottom, lessThanOrEqualTo(tester.getRect(find.text('Edit wallet1')).top));

      await tester.tap(find.text('savings'));
      await tester.pumpAndSettle();
      expect(selected, 'b');
      expect(find.text('Create new wallet'), findsNothing);
    });

    testWidgets('a long wallet list scrolls inside the sheet', (tester) async {
      final wallets = [for (var i = 0; i < 30; i++) _wallet('w$i', 'wallet$i')];
      await _pump(
        tester,
        WalletDropdown(
          currentWallet: wallets.first,
          availableWallets: wallets,
          onWalletSelected: (_) {},
          onCreateWallet: () {},
          onEditWallet: (_) {},
        ),
      );

      await tester.tap(find.text('wallet0'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.scrollUntilVisible(find.text('Create new wallet'), 200, scrollable: find.byType(Scrollable).last);
      expect(find.text('Create new wallet').hitTestable(), findsOneWidget);
    });

    testWidgets('the Edit link of another wallet closes the sheet and edits that wallet', (tester) async {
      WalletMetadata? edited;
      await _pump(
        tester,
        WalletDropdown(
          currentWallet: _wallet('a', 'wallet1'),
          availableWallets: [_wallet('a', 'wallet1'), _wallet('b', 'savings')],
          onWalletSelected: (_) {},
          onCreateWallet: () {},
          onEditWallet: (wallet) => edited = wallet,
        ),
      );
      await tester.tap(find.text('wallet1'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      expect(edited?.id, 'b');
      expect(find.text('savings'), findsNothing);
    });

    testWidgets('with no wallet the sheet offers the three ways to make one', (tester) async {
      await _pump(
        tester,
        WalletDropdown(
          currentWallet: null,
          availableWallets: const [],
          onWalletSelected: (_) {},
          onCreateWallet: () {},
          noWalletActions: (onGenerate: () {}, onPasteSeed: () {}, onImportDescriptor: () {}),
        ),
      );

      await tester.tap(find.text('No wallet'));
      await tester.pumpAndSettle();
      expect(find.text('Generate wallet'), findsOneWidget);
      expect(find.text('Paste seed phrase'), findsOneWidget);
      expect(find.text('Import descriptor'), findsOneWidget);
    });
  });

  testWidgets('on a desktop the wallet menu stays a dropdown', (tester) async {
    SailStyleValues.phoneLayoutOverride = false;
    await _pump(
      tester,
      WalletDropdown(
        currentWallet: _wallet('a', 'wallet1'),
        availableWallets: [_wallet('a', 'wallet1')],
        onWalletSelected: (_) {},
        onCreateWallet: () {},
      ),
    );

    expect(find.byType(SailDropdownButton<String>), findsOneWidget);
  });
}
