import 'package:bitwindow/pages/sidechains_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

import 'test_utils.dart';

WalletData _wallet(String id, String name, {bool watchOnly = false, bool multisig = false}) {
  return WalletData(
    version: 1,
    master: MasterWallet(mnemonic: '', seedHex: '', masterKey: '', chainCode: ''),
    l1: L1Wallet(mnemonic: ''),
    sidechains: const [],
    id: id,
    name: name,
    gradient: WalletGradient.fromWalletId(id),
    createdAt: DateTime(2026),
    walletType: BinaryType.BINARY_TYPE_ENFORCER,
    isWatchOnly: watchOnly,
    multisig: multisig ? wmpb.MultisigInfo(m: 2, n: 3) : null,
  );
}

class _FakeWalletReader extends ChangeNotifier implements WalletReaderProvider {
  @override
  List<WalletData> wallets = [];

  @override
  String? activeWalletId;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized({
    'flutter.test.automatic_wait_for_timers': 'false',
  });

  late _FakeWalletReader walletReader;

  setUp(() async {
    await GetIt.I.reset();
    walletReader = _FakeWalletReader();
    GetIt.I.registerSingleton<WalletReaderProvider>(walletReader);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  Future<void> pumpField(
    WidgetTester tester, {
    required void Function(String) onChanged,
    double width = 400,
  }) async {
    await tester.pumpSailPage(
      Center(
        child: SizedBox(
          width: width,
          child: FromWalletField(
            selectedWalletId: walletReader.activeWalletId,
            onChanged: onChanged,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('selecting a wallet reports the funding wallet', (tester) async {
    walletReader.wallets = [_wallet('enforcer-1', 'Enforcer'), _wallet('core-1', 'Savings')];
    walletReader.activeWalletId = 'enforcer-1';

    String? picked;
    await pumpField(tester, onChanged: (id) => picked = id);

    expect(find.text('From Wallet'), findsOneWidget);

    await tester.tap(find.byType(SailDropdownButton<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Savings').last);
    await tester.pumpAndSettle();

    expect(picked, 'core-1');
  });

  testWidgets('watch-only wallets cannot fund a deposit', (tester) async {
    walletReader.wallets = [
      _wallet('enforcer-1', 'Enforcer'),
      _wallet('watcher-1', 'Watcher', watchOnly: true),
    ];
    walletReader.activeWalletId = 'enforcer-1';

    await pumpField(tester, onChanged: (_) {});

    await tester.tap(find.byType(SailDropdownButton<String>));
    await tester.pumpAndSettle();

    expect(find.text('Watcher'), findsNothing);
  });

  // The field shares a row with the amount input, so it gets a narrow slot.
  testWidgets('a long wallet name does not overflow the amount row slot', (tester) async {
    walletReader.wallets = [_wallet('enforcer-1', 'Enforcer Wallet With A Very Long Name')];
    walletReader.activeWalletId = 'enforcer-1';

    await pumpField(tester, onChanged: (_) {}, width: 150);

    expect(tester.takeException(), isNull);
  });

  testWidgets('renders nothing without a spendable wallet', (tester) async {
    walletReader.wallets = [_wallet('watcher-1', 'Watcher', watchOnly: true)];

    await pumpField(tester, onChanged: (_) {});

    expect(find.byType(SailDropdownButton<String>), findsNothing);
  });

  // The field is handed a resolved ID by its parent; when the wallet list moves
  // underneath it, what it shows must stay the wallet a deposit would use.
  testWidgets('reflects a wallet list that arrives after the first build', (tester) async {
    walletReader.wallets = [];
    walletReader.activeWalletId = 'enforcer-1';

    late StateSetter rebuild;
    await tester.pumpSailPage(
      StatefulBuilder(
        builder: (context, setState) {
          rebuild = setState;
          return Center(
            child: SizedBox(
              width: 400,
              child: FromWalletField(
                selectedWalletId: FromWalletField.resolveFundingWalletId(walletReader, null),
                onChanged: (_) {},
              ),
            ),
          );
        },
      ),
    );
    expect(find.byType(SailDropdownButton<String>), findsNothing);

    walletReader.wallets = [_wallet('enforcer-1', 'Enforcer')];
    rebuild(() {});
    await tester.pumpAndSettle();

    expect(find.text('Enforcer'), findsOneWidget);
    expect(find.text('Select a wallet'), findsNothing);
  });

  group('resolveFundingWalletId', () {
    String? resolve(String? selected) => FromWalletField.resolveFundingWalletId(walletReader, selected);

    test('keeps a spendable selection', () {
      walletReader.wallets = [_wallet('enforcer-1', 'Enforcer'), _wallet('core-1', 'Savings')];
      walletReader.activeWalletId = 'enforcer-1';

      expect(resolve('core-1'), 'core-1');
    });

    test('falls back to the active wallet when nothing is selected', () {
      walletReader.wallets = [_wallet('enforcer-1', 'Enforcer'), _wallet('core-1', 'Savings')];
      walletReader.activeWalletId = 'enforcer-1';

      expect(resolve(null), 'enforcer-1');
    });

    test('skips a watch-only active wallet', () {
      walletReader.wallets = [
        _wallet('watcher-1', 'Watcher', watchOnly: true),
        _wallet('core-1', 'Savings'),
      ];
      walletReader.activeWalletId = 'watcher-1';

      expect(resolve(null), 'core-1');
    });

    test('drops a selection that turned watch-only', () {
      walletReader.wallets = [
        _wallet('watcher-1', 'Watcher', watchOnly: true),
        _wallet('core-1', 'Savings'),
      ];
      walletReader.activeWalletId = 'core-1';

      expect(resolve('watcher-1'), 'core-1');
    });

    // Multisig signs through the PSBT lounge; the deposit path broadcasts
    // directly, so it would fail with an incomplete signature.
    test('skips multisig wallets', () {
      walletReader.wallets = [_wallet('ms-1', 'Vault', multisig: true), _wallet('core-1', 'Savings')];
      walletReader.activeWalletId = 'ms-1';

      expect(resolve(null), 'core-1');
      expect(resolve('ms-1'), 'core-1');
    });

    test('resolves to null when only watch-only wallets exist', () {
      walletReader.wallets = [_wallet('watcher-1', 'Watcher', watchOnly: true)];
      walletReader.activeWalletId = 'watcher-1';

      expect(resolve(null), isNull);
      expect(resolve('watcher-1'), isNull);
    });
  });
}
