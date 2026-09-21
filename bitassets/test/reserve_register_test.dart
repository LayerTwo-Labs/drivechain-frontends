import 'package:bitassets/pages/tabs/reserve_register_page.dart';
import 'package:bitassets/providers/bitassets_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

import 'mocks/rpc_mock_bitassets.dart';
import 'mocks/storage_mock.dart';

class _ListBitAssetsRPC extends MockBitAssetsRPC {
  final List<String> reserved = [];

  @override
  Future<List<SidechainUTXO>> listUTXOs() async => [];

  @override
  Future<String> reserveBitAsset(String assetId) async {
    reserved.add(assetId);
    return 'txid';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized({
    'flutter.test.automatic_wait_for_timers': 'false',
  });

  late BitwindowClientSettings settings;
  late _ListBitAssetsRPC rpc;

  setUp(() async {
    await GetIt.I.reset();
    final log = Logger();
    settings = BitwindowClientSettings(store: MockStore(), log: log);
    rpc = _ListBitAssetsRPC();
    GetIt.I.registerSingleton<Logger>(log);
    GetIt.I.registerSingleton<BitwindowClientSettings>(settings);
    GetIt.I.registerSingleton<ClientSettings>(ClientSettings(store: MockStore(), log: log));
    GetIt.I.registerSingleton<BitAssetsRPC>(rpc);
    GetIt.I.registerSingleton<BitAssetsProvider>(BitAssetsProvider());
    GetIt.I.registerSingleton<NotificationProvider>(NotificationProvider());
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  // The node reserves a name with no input and no fee.
  testWidgets('a wallet with no coins can reserve a name', (tester) async {
    final model = BitAssetsViewModel();
    model.reserveNameController.text = 'NewAsset';

    await tester.pumpWidget(const SizedBox.shrink());
    await model.reserveBitname(tester.element(find.byType(SizedBox)));

    expect(model.reserveError, isNull);
    expect(rpc.reserved, ['NewAsset']);
  });
}
