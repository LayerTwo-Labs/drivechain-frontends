import 'dart:async';

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
  // ignore: close_sinks
  final frames = StreamController<WatchBitcoinConfigResponse>();
  int unaryReads = 0;

  /// Runs before a SetBitcoinConfigNetwork call answers.
  void Function()? onSwitch;

  /// Runs before a GetBitcoinConfig call answers.
  void Function()? onRead;

  /// True while the backend does not answer.
  bool down = false;

  @override
  Future<connect.StreamResponse<I, O>> stream<I extends Object, O extends Object>(
    connect.Spec<I, O> spec,
    Stream<I> input, [
    connect.CallOptions? options,
  ]) async {
    if (spec.procedure != specs.BitcoinConfService.watchBitcoinConfig.procedure) {
      throw UnimplementedError(spec.procedure);
    }
    return connect.StreamResponse(spec, connect.Headers(), frames.stream as Stream<O>, connect.Headers());
  }

  @override
  Future<connect.UnaryResponse<I, O>> unary<I extends Object, O extends Object>(
    connect.Spec<I, O> spec,
    I input, [
    connect.CallOptions? options,
  ]) async {
    if (down) {
      throw connect.ConnectException(connect.Code.unavailable, 'down');
    }
    final Object message;
    if (spec.procedure == specs.BitcoinConfService.getBitcoinConfig.procedure) {
      unaryReads++;
      message = config.deepCopy();
      onRead?.call();
    } else if (spec.procedure == specs.BitcoinConfService.setBitcoinConfigNetwork.procedure) {
      onSwitch?.call();
      message = SetBitcoinConfigNetworkResponse();
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
  tearDown(() {
    NetworkScopedRegistry.clearRegistrations();
    return GetIt.I.reset();
  });

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

  test('a watch frame applies the config and a heartbeat does not notify', () async {
    final transport = _Transport();
    final conf = await BitcoinConfProvider.withTransport(_Router(), transport);
    conf.startWatch();
    var notifies = 0;
    conf.addListener(() => notifies++);

    transport.frames.add(WatchBitcoinConfigResponse(heartbeat: true));
    transport.frames.add(
      WatchBitcoinConfigResponse(
        config: transport.config.deepCopy()..configContent = 'a=3',
        networks: [NetworkOption(id: 'regtest', network: 'regtest', isCurrent: true)],
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(notifies, 1);
    expect(conf.getCurrentConfigContent(), contains('a=3'));
    conf.dispose();
  });

  test('a restored config shows until the backend answers', () async {
    final (conf, _) = await _restored('signet');

    expect(conf.network, BitcoinNetwork.BITCOIN_NETWORK_SIGNET);
    expect(conf.networkOptions.single.displayName, 'Saved signet');
    expect(conf.backendConfig, isNull);

    await conf.loadConfig();
    expect(conf.network, BitcoinNetwork.BITCOIN_NETWORK_REGTEST);
    expect(conf.backendConfig?.network, 'regtest');
    conf.dispose();
  });

  test('a backend network other than the restored one clears network state', () async {
    final (conf, _) = await _restored('signet');
    var cleared = 0;
    NetworkScopedRegistry.enrol(_Scoped(() => cleared++));

    await conf.loadConfig();
    expect(cleared, 1);

    await conf.loadConfig();
    expect(cleared, 1);
    conf.dispose();
  });

  test('a backend network equal to the restored one clears nothing', () async {
    final (conf, _) = await _restored('regtest');
    var cleared = 0;
    NetworkScopedRegistry.enrol(_Scoped(() => cleared++));

    await conf.loadConfig();
    expect(cleared, 0);
    conf.dispose();
  });

  test('a network switch clears network state also when a frame lands first', () async {
    final transport = _Transport();
    final conf = await BitcoinConfProvider.withTransport(_Router(), transport);
    conf.startWatch();
    final signet = transport.config.deepCopy()..network = 'signet';
    transport.frames.add(WatchBitcoinConfigResponse(config: transport.config.deepCopy()));
    await Future<void>.delayed(const Duration(milliseconds: 20));

    var cleared = 0;
    NetworkScopedRegistry.enrol(_Scoped(() => cleared++));
    transport.onSwitch = () {
      transport.config = signet;
      transport.frames.add(WatchBitcoinConfigResponse(config: signet));
    };
    await conf.updateNetwork(BitcoinNetwork.BITCOIN_NETWORK_SIGNET);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(conf.network, BitcoinNetwork.BITCOIN_NETWORK_SIGNET);
    expect(cleared, 1);
    conf.dispose();
  });

  test('an old-network frame during the switch read does not drop the reset', () async {
    final transport = _Transport();
    final conf = await BitcoinConfProvider.withTransport(_Router(), transport);
    conf.startWatch();
    final regtest = transport.config.deepCopy();
    final signet = transport.config.deepCopy()..network = 'signet';
    transport.frames.add(WatchBitcoinConfigResponse(config: regtest));
    await Future<void>.delayed(const Duration(milliseconds: 20));

    var cleared = 0;
    NetworkScopedRegistry.enrol(_Scoped(() => cleared++));
    transport.onSwitch = () => transport.config = signet;
    transport.onRead = () {
      transport.onRead = null;
      transport.frames.add(WatchBitcoinConfigResponse(config: regtest.deepCopy()..configContent = 'a=9'));
    };
    await conf.updateNetwork(BitcoinNetwork.BITCOIN_NETWORK_SIGNET);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(conf.network, BitcoinNetwork.BITCOIN_NETWORK_REGTEST);
    expect(cleared, 0);

    transport.frames.add(WatchBitcoinConfigResponse(config: signet));
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(conf.network, BitcoinNetwork.BITCOIN_NETWORK_SIGNET);
    expect(cleared, 1);
    conf.dispose();
  });
}

Future<(BitcoinConfProvider, _Transport)> _restored(String network) async {
  final transport = _Transport()..down = true;
  final conf = await BitcoinConfProvider.withTransport(
    _Router(),
    transport,
    restored: (
      config: GetBitcoinConfigResponse(network: network, rpcPort: 18443),
      networks: [NetworkOption(id: network, network: network, displayName: 'Saved $network', isCurrent: true)],
    ),
  );
  transport.down = false;
  return (conf, transport);
}

class _Scoped implements NetworkScoped {
  _Scoped(this.onChange);

  final void Function() onChange;

  @override
  Future<void> onNetworkChanged() async => onChange();
}
