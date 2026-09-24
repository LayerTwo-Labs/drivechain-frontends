import 'dart:io';

import 'package:bitwindow/widgets/starters_tab.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

class _Conf extends ChangeNotifier implements BitcoinConfProvider {
  @override
  bool get networkSupportsSidechains => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _WalletWriter extends ChangeNotifier implements WalletWriterProvider {
  @override
  Future<Map<String, dynamic>?> loadMasterStarter() async => null;

  @override
  Future<String?> getL1Starter() async => null;

  @override
  Future<String?> getSidechainStarter(int sidechainSlot) async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

WalletData _wallet(String id, String name, {bool isStarter = false, bool watchOnly = false}) {
  return WalletData(
    version: 1,
    master: MasterWallet(mnemonic: watchOnly ? '' : 'seed $id', seedHex: '', masterKey: '', chainCode: ''),
    l1: L1Wallet(mnemonic: 'l1 $id'),
    sidechains: const [],
    isStarter: isStarter,
    id: id,
    name: name,
    gradient: WalletGradient.fromWalletId(id),
    createdAt: DateTime.utc(2026, 1, 1),
    walletType: BinaryType.BINARY_TYPE_UNSPECIFIED,
    isElectrum: true,
    isWatchOnly: watchOnly,
  );
}

void main() {
  late WalletReaderProvider reader;

  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    reader = WalletReaderProvider(Directory.systemTemp)
      ..wallets = [
        _wallet('first', 'First wallet', isStarter: true),
        _wallet('second', 'Second wallet'),
      ]
      ..activeWalletId = 'first';
    GetIt.I.registerSingleton<BitcoinConfProvider>(_Conf());
    GetIt.I.registerSingleton<WalletReaderProvider>(reader);
    GetIt.I.registerSingleton<WalletWriterProvider>(_WalletWriter());
    GetIt.I.registerSingleton<BinaryProvider>(
      BinaryProvider.test(appDir: Directory.systemTemp, binaries: [BitcoinCore()]),
    );
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  testWidgets('the Starters tab names the pinned wallet after a wallet switch', (tester) async {
    addTearDown(() => tester.pumpWidget(const SizedBox()));
    await tester.pumpSailPage(const StartersTab());
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Wallet: First wallet'), findsOneWidget);

    reader.activeWalletId = 'second';
    reader.notifyListeners();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Wallet: First wallet'), findsOneWidget);
    expect(find.text('Wallet: Second wallet'), findsNothing);
  });

  testWidgets('the Starters tab names no wallet when no wallet holds a seed', (tester) async {
    reader.wallets = [_wallet('watch', 'Watch wallet', watchOnly: true)];
    reader.activeWalletId = 'watch';
    addTearDown(() => tester.pumpWidget(const SizedBox()));
    await tester.pumpSailPage(const StartersTab());
    await tester.pump(const Duration(seconds: 1));

    expect(find.textContaining('Wallet:'), findsNothing);
  });
}
