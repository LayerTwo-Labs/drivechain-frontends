import 'package:bitwindow/providers/bitdrive_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

import 'mocks/api_mock.dart';
import 'test_utils.dart';

class _WalletReader extends ChangeNotifier implements WalletReaderProvider {
  @override
  String? get activeWalletId => 'qa';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    GetIt.I.registerSingleton<BitwindowRPC>(MockAPI(binaryType: BinaryType.BINARY_TYPE_BITWINDOWD));
    GetIt.I.registerSingleton<WalletReaderProvider>(_WalletReader());
    await registerTestDependencies();
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  testWidgets('an init before the first sync status completes when the status arrives', (tester) async {
    final provider = BitDriveProvider();
    await provider.init();
    expect(provider.initialized, isFalse);

    final sync = GetIt.I.get<SyncProvider>();
    sync.mainchainSyncInfo = SyncInfo(progressCurrent: 5, progressGoal: 10, lastBlockAt: null);
    sync.notifyListeners();
    await tester.pump();

    expect(provider.initialized, isTrue);
  });
}
