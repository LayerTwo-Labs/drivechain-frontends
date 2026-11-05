import 'dart:io';
import 'dart:ui' as ui;

// The finders need the Material Dialog and TextField types.
// ignore: drivechain_lints/avoid_material_import
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/shell/shell.dart';
import 'package:zside/widgets/homepage_widget_catalog.dart';
import 'package:zside/zside_module.dart';

// sidechain-orchestrator/zside_app_ui_integration_test.go starts the regtest
// stack, deposits 0.5 BTC to the zSide wallet, and then runs this file.
const withdrawAddress = String.fromEnvironment('ZSIDE_UI_WITHDRAW_ADDRESS');
const shotsDir = String.fromEnvironment('ZSIDE_UI_SHOTS');

const depositBtc = 0.5;
const shieldBtc = 0.1;
const deshieldBtc = 0.02;
const sendBtc = 0.01;
const withdrawBtc = 0.05;
const feeBtc = 0.00001;
const anchorDepth = 3;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('zSide app runs every wallet flow on regtest', (tester) async {
    expect(withdrawAddress, isNotEmpty, reason: 'run this through TestZSideAppUI');

    final errorHandler = FlutterError.onError;
    final errorBuilder = ErrorWidget.builder;
    final layoutFaults = <String>[];
    final faults = <String>[];
    FlutterError.onError = (details) {
      final text = details.exceptionAsString();
      if (text.contains('mouse_tracker.dart') ||
          text.contains('KeyDownEvent is dispatched') ||
          text.contains('_debugDuringDeviceUpdate')) {
        return;
      }
      if (text.contains('overflowed')) {
        layoutFaults.add(text);
        return;
      }
      faults.add('${details.exceptionAsString()}\n${details.stack}');
    };

    try {
      await runSidechainApp(ZSideModule());

      final ui = _AppDriver(tester);
      final fmt = GetIt.I<FormatterProvider>().formatBTC;

      await ui.waitFor(() => tester.any(find.text('Shield/Deshield')), 'the home page', timeout: 120);

      // a. The overview shows the deposit.
      await ui.waitFor(
        () => ui.poolTotal('Transparent') == fmt(depositBtc),
        'the deposit in the transparent pool',
        timeout: 120,
      );
      expect(ui.poolTotal('Private (Shielded)'), fmt(0));
      expect(find.descendant(of: ui.card('Balance'), matching: find.text(fmt(depositBtc))), findsWidgets);
      await ui.shot('a-overview');

      // b. The receive cards show one address of each kind.
      await ui.waitFor(
        () =>
            ui.fieldText('Receive - Transparent Address').isNotEmpty &&
            ui.fieldText('Receive - Private Address').isNotEmpty,
        'the receive addresses',
      );
      final transparentAddress = ui.fieldText('Receive - Transparent Address');
      final shieldedAddress = ui.fieldText('Receive - Private Address');
      expect(transparentAddress, isNot(shieldedAddress));
      await ui.scrollTo(ui.card('Receive - Private Address'));
      await ui.shot('b-receive');

      // c. Shield from the transparent UTXO table.
      await ui.tap(find.text('Shield/Deshield'));
      await ui.waitFor(() => tester.any(find.text('Transparent UTXOs 1')), 'the deposit coin in the table');
      await ui.shot('c-shield-tab');
      await ui.tap(find.text('Shield'));
      await ui.enter('How much do you want to shield?', '$shieldBtc');
      await ui.shot('c-shield-dialog');
      await ui.tap(find.text('Execute shield'));
      final shieldTxid = await ui.closeResult('Initiated shield', 'c-shield-done');
      expect(shieldTxid, hasLength(64));

      await ui.tap(find.text('Home'));
      await ui.waitFor(
        () => ui.poolTotal('Private (Shielded)') == fmt(shieldBtc),
        'the shielded balance',
      );
      await ui.shot('c-overview-shielded');

      // d. The note waits for the anchor depth, then the private table lists it.
      await ui.waitBlocks(anchorDepth);
      await ui.tap(find.text('Shield/Deshield'));
      await ui.waitFor(() => tester.any(find.text('Private UTXOs 1')), 'the note in the private table');
      expect(find.descendant(of: ui.card('Private UTXOs 1'), matching: find.text(fmt(shieldBtc))), findsOneWidget);
      await ui.shot('d-private-utxos');
      await ui.tap(find.text('Deshield'));
      await ui.enter('How much do you want to deshield?', '$deshieldBtc');
      await ui.shot('d-deshield-dialog');
      await ui.tap(find.text('Execute deshield'));
      await ui.closeResult('Initiated deshield', 'd-deshield-done');

      await ui.tap(find.text('Home'));
      await ui.waitFor(
        () => ui.poolTotal('Private (Shielded)') == fmt(shieldBtc - deshieldBtc - feeBtc),
        'the shielded balance after the deshield',
      );
      await ui.shot('d-overview-deshielded');

      // e. Send to the own transparent address, then to the own private address.
      await ui.scrollTo(ui.card('Send on Sidechain'));
      await ui.enter('Enter a transparent or private address', transparentAddress);
      await ui.enter('0.00', '$sendBtc');
      await ui.shot('e-send-transparent');
      await ui.tap(find.text('Send Transparent'));
      final transparentTxid = await ui.closeResult('You sent', 'e-send-transparent-done');

      // The change note of the deshield must reach the anchor depth too.
      await ui.waitBlocks(anchorDepth);
      await ui.scrollTo(ui.card('Send on Sidechain'));
      await ui.enter('Enter a transparent or private address', shieldedAddress);
      await ui.enter('0.00', '$sendBtc');
      await ui.shot('e-send-private');
      await ui.tap(find.text('Send Private'));
      final privateTxid = await ui.closeResult('You sent', 'e-send-private-done');
      expect(privateTxid, isNot(transparentTxid));

      // f. The history lists the transfers.
      await ui.waitBlocks(1);
      await ui.scrollTo(ui.card('Wallet Transaction History'));
      await ui.waitFor(
        () =>
            tester.any(find.textContaining('${transparentTxid.substring(0, 6)}..:')) &&
            tester.any(find.textContaining('${shieldTxid.substring(0, 6)}..:')),
        'the transfers in the history',
      );
      expect(find.text('No transactions yet'), findsNothing);
      await ui.shot('f-history');

      // g. Withdraw to the mainchain.
      await ui.tap(find.text('Parent Chain'));
      await ui.waitFor(() => tester.any(ui.card('Withdraw to Parent Chain')), 'the withdraw card');
      final withdrawFields = find.descendant(of: ui.card('Withdraw to Parent Chain'), matching: find.byType(TextField));
      await ui.enterAt(withdrawFields.at(0), withdrawAddress);
      await ui.enterAt(withdrawFields.at(1), '$withdrawBtc');
      await ui.shot('g-withdraw');
      await ui.tap(find.descendant(of: ui.card('Withdraw to Parent Chain'), matching: find.text('Send')));
      await ui.closeResult('Submitted withdraw successfully', 'g-withdraw-done');
      await ui.shot('g-parent-chain');
    } finally {
      FlutterError.onError = errorHandler;
      ErrorWidget.builder = errorBuilder;
      for (final fault in layoutFaults.toSet()) {
        debugPrint('LAYOUT FAULT: $fault');
      }
    }
    expect(faults, isEmpty, reason: faults.join('\n\n'));
  });
}

class _AppDriver {
  final WidgetTester tester;
  int _shotIndex = 0;

  _AppDriver(this.tester);

  Finder card(String title) => find.widgetWithText(SailCard, title).first;

  String? poolTotal(String label) {
    final row = find.widgetWithText(PoolBalanceRow, label);
    if (!tester.any(row)) {
      return null;
    }
    final texts = tester.widgetList<Text>(find.descendant(of: row.first, matching: find.byType(Text)));
    return texts.map((t) => t.data).whereType<String>().where((t) => t != label).firstOrNull;
  }

  String fieldText(String cardTitle) {
    final field = find.descendant(of: card(cardTitle), matching: find.byType(TextField));
    if (!tester.any(field)) {
      return '';
    }
    return tester.widget<TextField>(field.first).controller?.text ?? '';
  }

  Future<void> waitFor(bool Function() ready, String what, {int timeout = 90}) async {
    final deadline = DateTime.now().add(Duration(seconds: timeout));
    while (true) {
      await tester.pump(const Duration(milliseconds: 250));
      if (ready()) {
        return;
      }
      final error = find.textContaining('Could not');
      if (tester.any(error)) {
        await shot('fault');
        fail('$what: the app shows an error: ${_dialogText()}');
      }
      if (DateTime.now().isAfter(deadline)) {
        await shot('timeout');
        fail('timed out after ${timeout}s waiting for $what');
      }
    }
  }

  Future<void> waitBlocks(int count) async {
    final rpc = GetIt.I<ZSideRPC>();
    final start = await rpc.getBlockCount();
    final deadline = DateTime.now().add(Duration(seconds: 30 * count + 30));
    while (await rpc.getBlockCount() < start + count) {
      if (DateTime.now().isAfter(deadline)) {
        fail('the zSide chain stayed below height ${start + count}');
      }
      await tester.pump(const Duration(seconds: 1));
    }
  }

  Future<void> scrollTo(Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> tap(Finder finder) async {
    await waitFor(() => tester.any(finder), 'a widget to tap: $finder');
    await tester.ensureVisible(finder.first);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(finder.first);
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> enter(String hint, String text) async {
    await enterAt(find.widgetWithText(TextField, hint).last, text);
  }

  Future<void> enterAt(Finder field, String text) async {
    await waitFor(() => tester.any(field), 'a text field: $field');
    await tester.ensureVisible(field);
    await tester.enterText(field, text);
    await tester.pump(const Duration(milliseconds: 300));
  }

  /// Waits for the result dialog whose title starts with [title], saves a
  /// screenshot, closes it, and returns the txid it shows.
  Future<String> closeResult(String title, String shotName) async {
    final dialogTitle = find.descendant(of: find.byType(Dialog), matching: find.textContaining(title));
    await waitFor(() => tester.any(dialogTitle), 'the dialog "$title"', timeout: 120);
    await shot(shotName);
    final txid = RegExp(r'[0-9a-f]{64}').firstMatch(_dialogText())?.group(0) ?? '';
    await tap(find.descendant(of: find.byType(Dialog), matching: find.text('Close')));
    await waitFor(() => !tester.any(dialogTitle), 'the dialog "$title" to close');
    return txid;
  }

  String _dialogText() => tester
      .widgetList<Text>(find.descendant(of: find.byType(Dialog), matching: find.byType(Text)))
      .map((t) => t.data ?? '')
      .join(' | ');

  Future<void> shot(String name) async {
    if (shotsDir.isEmpty) {
      return;
    }
    await tester.pump(const Duration(milliseconds: 300));
    final view = tester.binding.renderViews.first;
    final layer = view.debugLayer! as OffsetLayer;
    final image = await layer.toImage(Offset.zero & view.size, pixelRatio: view.flutterView.devicePixelRatio);
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    _shotIndex++;
    final file = File('$shotsDir/${_shotIndex.toString().padLeft(2, '0')}-$name.png');
    await file.writeAsBytes(png!.buffer.asUint8List());
    debugPrint('screenshot: ${file.path}');
  }
}
