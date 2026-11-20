import 'package:auto_route/auto_route.dart';
import 'package:connectrpc/connect.dart' as connect;
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/gen/orchestrator/v1/bitcoin_conf.connect.spec.dart' as specs;
import 'package:sidechain_core/sidechain_core.dart';

class _Router extends Fake implements RootStackRouter {}

class _Transport implements connect.Transport {
  GetBitcoinConfigResponse config = GetBitcoinConfigResponse(network: 'regtest', rpcPort: 18443, configContent: 'a=1');

  @override
  Future<connect.UnaryResponse<I, O>> unary<I extends Object, O extends Object>(
    connect.Spec<I, O> spec,
    I input, [
    connect.CallOptions? options,
  ]) async {
    final Object message;
    if (spec.procedure == specs.BitcoinConfService.getBitcoinConfig.procedure) {
      message = config.deepCopy();
    } else if (spec.procedure == specs.BitcoinConfService.listNetworks.procedure) {
      message = ListNetworksResponse(
        networks: [NetworkOption(id: 'regtest', network: 'regtest', isCurrent: true)],
      );
    } else {
      throw UnimplementedError(spec.procedure);
    }
    return connect.UnaryResponse(spec, connect.Headers(), message as O, connect.Headers());
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() => GetIt.I.registerSingleton<Logger>(Logger(level: Level.off)));
  tearDown(() => GetIt.I.reset());

  test('a poll with the same config does not notify', () async {
    final transport = _Transport();
    final conf = await BitcoinConfProvider.withTransport(_Router(), transport);
    var notifies = 0;
    conf.addListener(() => notifies++);

    await conf.loadConfig();
    await conf.loadConfig();
    expect(notifies, 0);

    transport.config = transport.config.deepCopy()..configContent = 'a=2';
    await conf.loadConfig();
    expect(notifies, 1);
    expect(conf.getCurrentConfigContent(), contains('a=2'));

    transport.config = transport.config.deepCopy()..network = 'signet';
    await conf.loadConfig();
    expect(notifies, 2);
    expect(conf.network, BitcoinNetwork.BITCOIN_NETWORK_SIGNET);
  });
}
