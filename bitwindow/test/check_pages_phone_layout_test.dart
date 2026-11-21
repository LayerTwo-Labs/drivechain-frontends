import 'package:bitwindow/pages/wallet/cash_check_page.dart';
import 'package:bitwindow/pages/wallet/cash_check_success_page.dart';
import 'package:bitwindow/pages/wallet/check_detail_page.dart';
import 'package:bitwindow/pages/wallet/create_check_page.dart';
import 'package:bitwindow/providers/check_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart' as bwpb;

import 'test_utils.dart';

const _address = 'bcrt1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq';
const _txid = 'f3a1c09e5b7d2468ace013579bdf2468ace013579bdf2468ace013579bdf2468';
const _phone = Size(390, 844);

class _FakeCheckProvider extends ChangeNotifier implements CheckProvider {
  _FakeCheckProvider({this.funded = false});

  final bool funded;

  @override
  Future<bwpb.Cheque?> getCheck(int id) async => bwpb.Cheque(
    id: Int64(1),
    address: _address,
    expectedAmountSats: Int64(1000000),
    funded: funded,
    fundedTxids: funded ? [_txid] : [],
    privateKeyWif: funded ? 'cVt4o7BGAig1UXywgGSmARhxMdzP5qvQsxKkSsc1XEkw3tDTQFpy' : null,
  );

  @override
  List<bwpb.Cheque> get checks => const [];

  @override
  void startPolling(int checkId, {Duration interval = const Duration(seconds: 5)}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeProviders extends ChangeNotifier implements TransactionProvider, WalletReaderProvider {
  @override
  String? activeWalletId = 'wallet-1';

  @override
  String address = _address;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeOrchestratorWallet implements OrchestratorWalletRPC {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeOrchestrator implements OrchestratorRPC {
  @override
  OrchestratorWalletRPC wallet = _FakeOrchestratorWallet();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeBitwindow implements BitwindowRPC {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void _registerFakes({bool funded = false}) {
  final providers = _FakeProviders();
  GetIt.I.registerSingleton<CheckProvider>(_FakeCheckProvider(funded: funded));
  GetIt.I.registerSingleton<TransactionProvider>(providers);
  GetIt.I.registerSingleton<WalletReaderProvider>(providers);
  GetIt.I.registerSingleton<OrchestratorRPC>(_FakeOrchestrator());
  GetIt.I.registerSingleton<BitwindowRPC>(_FakeBitwindow());
}

Future<void> _pump(WidgetTester tester, Widget page, {required bool phone}) async {
  SailStyleValues.phoneLayoutOverride = phone;
  await tester.pumpSailPage(page);
  if (phone) {
    await tester.binding.setSurfaceSize(_phone);
  }
  await tester.pump();
  await tester.pump();
}

bool _inCard(String text) =>
    find.descendant(of: find.byType(SailCard), matching: find.text(text)).evaluate().isNotEmpty;

double? _fontSize(WidgetTester tester, String text) => tester.widget<Text>(find.text(text)).style!.fontSize;

void main() {
  setUpAll(loadBundledFonts);

  setUp(() async {
    await GetIt.I.reset();
  });

  tearDown(() async {
    SailStyleValues.phoneLayoutOverride = null;
    await GetIt.I.reset();
  });

  group('Create Check and Cash Check', () {
    for (final (name, page, heading) in [
      ('Create Check', const CreateCheckPage(), 'How much should the check be for?'),
      ('Cash Check', const CashCheckPage(), 'Enter the private key (WIF)'),
    ]) {
      testWidgets('$name puts its content in one panel with a 15 px heading on a phone', (tester) async {
        _registerFakes();
        await _pump(tester, page, phone: true);

        expect(tester.takeException(), isNull);
        expect(_inCard(heading), isTrue);
        expect(_fontSize(tester, heading), 15);
      });

      testWidgets('$name keeps the large heading and no panel on the desktop', (tester) async {
        _registerFakes();
        await _pump(tester, page, phone: false);

        expect(_inCard(heading), isFalse);
        expect(_fontSize(tester, heading), 24);
      });
    }
  });

  group('check details', () {
    testWidgets('an unfunded check on a phone shows a dot, the address on one line and a full-width button', (
      tester,
    ) async {
      _registerFakes();
      await _pump(tester, const CheckDetailPage(checkId: 1), phone: true);

      expect(tester.takeException(), isNull);
      expect(_inCard('Awaiting funding'), isTrue);
      final card = tester.getRect(find.byType(SailCard));
      expect(tester.getCenter(find.text('Awaiting funding')).dx, greaterThan(card.center.dx));
      expect(find.byWidgetPredicate((w) => w is Container && w.constraints?.maxWidth == 8), findsOneWidget);

      final address = tester.getRect(find.text(_address));
      final copy = tester.getRect(find.byType(CopyButton));
      expect(address.height, lessThan(24), reason: 'the address stays on one line');
      expect(copy.left, greaterThanOrEqualTo(address.right));
      expect(copy.center.dy, closeTo(address.center.dy, 2));

      final button = tester.getRect(find.widgetWithText(SailButton, 'Fund with Wallet'));
      expect(button.width, closeTo(card.width - 32 - 2, 2));
    });

    testWidgets('a funded check on a phone shows a full-width sweep button', (tester) async {
      _registerFakes(funded: true);
      await _pump(tester, const CheckDetailPage(checkId: 1), phone: true);

      expect(tester.takeException(), isNull);
      expect(_inCard('Funded'), isTrue);
      final card = tester.getRect(find.byType(SailCard));
      final button = tester.getRect(find.widgetWithText(SailButton, 'Sweep Check to Wallet'));
      expect(button.width, closeTo(card.width - 32 - 2, 2));
    });

    testWidgets('the desktop keeps the rings and the 400 px button', (tester) async {
      _registerFakes();
      await _pump(tester, const CheckDetailPage(checkId: 1), phone: false);

      expect(find.byType(SailCard), findsNothing);
      expect(tester.getSize(find.widgetWithText(SailButton, 'Fund with Wallet')).width, 400);
    });
  });

  group('check cashed', () {
    testWidgets('on a phone the amount and the transaction are label and value rows, Done at the right', (
      tester,
    ) async {
      await _pump(tester, const CashCheckSuccessPage(txid: _txid, amountSats: 1000000), phone: true);

      expect(tester.takeException(), isNull);
      expect(_inCard('Your Check was Cashed'), isTrue);
      expect(_fontSize(tester, 'Your Check was Cashed'), 15);

      final label = tester.getRect(find.text('Amount'));
      final value = tester.getRect(find.text('0.01000000 ${activeTicker.symbol}'));
      expect(value.left, greaterThan(label.right));
      expect(value.center.dy, closeTo(label.center.dy, 1));
      expect(find.text('Transaction'), findsOneWidget);

      final card = tester.getRect(find.byType(SailCard));
      final done = tester.getRect(find.widgetWithText(SailButton, 'Done'));
      expect(_inCard('Done'), isTrue);
      expect(done.right, closeTo(card.right - 16 - 1, 1));
    });

    testWidgets('the desktop keeps the large title and the colon labels', (tester) async {
      await _pump(tester, const CashCheckSuccessPage(txid: _txid, amountSats: 1000000), phone: false);

      expect(_fontSize(tester, 'Your Check was Cashed'), 40);
      expect(find.text('Amount:'), findsOneWidget);
    });
  });
}
