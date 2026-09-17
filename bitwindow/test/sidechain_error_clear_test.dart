import 'package:bitwindow/providers/sidechain_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/sidechain_core.dart';

import 'mocks/api_mock.dart';

/// A chain with no sidechains answers with empty lists, which equal the state
/// the provider starts from.
class _EmptyChainRPC extends MockAPI {
  _EmptyChainRPC() : super(binaryType: BinaryType.BINARY_TYPE_BITWINDOWD);
}

class _ReadyConf implements BitcoinConfProvider {
  @override
  bool get drivechainFeaturesAvailable => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ActiveWallet implements WalletReaderProvider {
  @override
  String? get activeWalletId => 'W1';

  @override
  void addListener(void Function() listener) {}

  @override
  void removeListener(void Function() listener) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    GetIt.I.registerSingleton<BitwindowRPC>(_EmptyChainRPC()..connected = true);
    GetIt.I.registerSingleton<SyncProvider>(SyncProvider(startTimer: false));
    GetIt.I.registerSingleton<BitcoinConfProvider>(_ReadyConf());
    GetIt.I.registerSingleton<WalletReaderProvider>(_ActiveWallet());
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  test('a fetch that lands drops the error, even with nothing to show', () async {
    final provider = SidechainProvider();
    await pumpEventQueue();
    provider.error = 'enforcer does not accept connections';

    await provider.fetch();

    expect(provider.error, isNull);
  });
}
