import 'package:bitwindow/providers/network_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sidechain_core/sidechain_core.dart';

import 'mocks/api_mock.dart';

class _CountingBitwindowdAPI extends MockBitwindowdAPI {
  int statsCalls = 0;

  @override
  Future<GetNetworkStatsResponse> getNetworkStats() async {
    statsCalls++;
    return GetNetworkStatsResponse();
  }
}

class _CountingAPI extends MockAPI {
  _CountingAPI() : super(binaryType: BinaryType.BINARY_TYPE_BITWINDOWD);

  final _CountingBitwindowdAPI api = _CountingBitwindowdAPI();

  @override
  BitwindowAPI get bitwindowd => api;
}

void main() {
  late _CountingAPI rpc;

  Future<void> boot(wmpb.NodeMode mode) async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    rpc = _CountingAPI();
    rpc.connected = true;
    GetIt.I.registerSingleton<BitwindowRPC>(rpc);
    GetIt.I.registerSingleton<NodeModeProvider>(NodeModeProvider()..mode = mode);
  }

  tearDown(() async {
    await GetIt.I.reset();
  });

  // Network stats read Bitcoin Core. A light-mode install runs none, so each
  // poll wrote an error to both logs every five seconds.
  test('network stats do not poll in light mode', () async {
    await boot(wmpb.NodeMode.NODE_MODE_LIGHT);

    final provider = NetworkProvider();
    await provider.fetch();

    expect(rpc.api.statsCalls, 0);
    expect(provider.error, isNull);
  });

  // A switch to light mode leaves the last reading on the cards and in the
  // traffic graph, where the numbers no longer move.
  test('a skipped poll drops the old network stats', () async {
    await boot(wmpb.NodeMode.NODE_MODE_FULL);
    final provider = NetworkProvider();
    await provider.fetch();
    expect(provider.stats, isNotNull);

    GetIt.I.get<NodeModeProvider>().mode = wmpb.NodeMode.NODE_MODE_LIGHT;
    await provider.fetch();

    expect(provider.stats, isNull);
    expect(provider.error, isNull);
    expect(provider.bandwidthHistory, isEmpty);
  });

  test('network stats poll in full mode', () async {
    await boot(wmpb.NodeMode.NODE_MODE_FULL);

    final provider = NetworkProvider();
    await provider.fetch();

    expect(rpc.api.statsCalls, greaterThan(0));
  });
}
