// Opens every side nav menu item of BitWindow on a phone, and closes each one the way a user does.
// Run it after phone_regtest_test.dart on the same install, or on a fresh one; see phone_regtest/README.md.
import 'package:bitwindow/main.dart' as app;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sail_ui/sail_ui.dart';

import 'phone_regtest/ui.dart';

// These pages keep desktop columns on a phone. Their phone layouts wait for a design.
const _knownLayoutFaults = ['Paper Wallet:', 'OP_RETURN Graffiti:', 'BitDrive:'];

const _menuItems = [
  'About bitwindow',
  'Change Theme',
  'Edit Home Page',
  'Backup',
  'Restore',
  'Send Money',
  'Request Money',
  'See Wallet Transactions',
  'Address Book',
  'Open URI Link',
  'Deniability',
  'Proof of Funds',
  'Multisig Lounge',
  'Transaction Censorship',
  'Paper Wallet',
  'Write a Check',
  'M4 Explorer',
  'Broadcast CoinNews',
  'Timestamp File(s)',
  'OP_RETURN Graffiti',
  'BitDrive',
  'Sign / Verify Message',
  'Chain Merchants',
  'Network Statistics',
  'Sidechain Activation',
  'Block Explorer',
  'Hash Calculator',
  'Merkle Tree',
  'Signatures',
  'Converter',
  'HD Wallet Explorer',
  'Options',
  'View Logs',
];

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('every side nav item opens and closes on a phone', (tester) async {
    final ui = PhoneUi(tester, binding);
    final testHandler = FlutterError.onError;
    final testErrorWidget = ErrorWidget.builder;
    try {
      app.main([]);
      await ui.waitFor(
        find.byWidgetPredicate((w) => w is SailButton && w.icon == SailSVGAsset.menu),
        timeout: const Duration(minutes: 3),
      );
      await ui.waitFor(find.text('All binaries connected'), timeout: const Duration(minutes: 2));
      ui.watchLayoutErrors();
      if (find.text('No wallet').evaluate().isNotEmpty) {
        await ui.tap(ui.topmost(find.text('No wallet')));
        await ui.tapText('Generate wallet');
        await ui.waitFor(find.text('Continue'));
        await ui.settle(const Duration(seconds: 3));
        await ui.tapText('Continue');
        await ui.tapText('Skip and create wallet');
        await ui.tapText('Create without backup');
        await ui.waitFor(find.text('wallet1'), timeout: const Duration(minutes: 2));
      }

      for (final item in _menuItems) {
        ui.step(item);
        await ui.openSideNav();
        await ui.tap(find.text(item));
        await ui.settle(const Duration(seconds: 2));
        await ui.shot('menu-${item.toLowerCase().replaceAll(RegExp('[^a-z0-9]+'), '-')}');
        switch (item) {
          case 'Change Theme':
            await ui.openSideNav();
            await ui.tap(find.text(item));
          case 'Edit Home Page':
            await ui.tapText('Done');
          default:
            await _close(tester, ui);
        }
      }
    } catch (_) {
      await ui.shot('failure');
      rethrow;
    } finally {
      FlutterError.onError = testHandler;
      ErrorWidget.builder = testErrorWidget;
    }
    expect(
      ui.layoutErrors.where((e) => !_knownLayoutFaults.any(e.startsWith)),
      isEmpty,
      reason: 'layout overflows on a phone',
    );
  }, timeout: const Timeout(Duration(minutes: 30)));
}

final _menuButton = find.byWidgetPredicate((w) => w is SailButton && w.icon == SailSVGAsset.menu);

/// Taps the barrier above a sheet. A full page takes a system back.
Future<void> _close(WidgetTester tester, PhoneUi ui) async {
  for (var i = 0; i < 3 && _menuButton.hitTestable().evaluate().isEmpty; i++) {
    await tester.tapAt(const Offset(195, 30));
    await ui.settle();
    if (_menuButton.hitTestable().evaluate().isNotEmpty) {
      return;
    }
    await tester.binding.handlePopRoute();
    await ui.settle();
  }
  if (_menuButton.hitTestable().evaluate().isEmpty) {
    throw TestFailure('could not close what the side nav opened');
  }
}
