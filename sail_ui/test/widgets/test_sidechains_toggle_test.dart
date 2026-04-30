import 'package:connectrpc/http2.dart';
import 'package:connectrpc/protobuf.dart';
import 'package:connectrpc/protocol/connect.dart' as connect;
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sail_ui/sail_ui.dart';

class _InMemoryStore implements KeyValueStore {
  final Map<String, String> _data = {};

  @override
  Future<String?> getString(String key) async => _data[key];

  @override
  Future<void> setString(String key, String value) async {
    _data[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _data.remove(key);
  }
}

class _FakeWalletRPC extends OrchestratorWalletRPC {
  _FakeWalletRPC()
    : super.fromTransports(
        unary: connect.Transport(
          baseUrl: 'http://127.0.0.1:1',
          codec: const ProtoCodec(),
          httpClient: createHttpClient(),
        ),
        stream: connect.Transport(
          baseUrl: 'http://127.0.0.1:1',
          codec: const ProtoCodec(),
          httpClient: createHttpClient(),
        ),
      );

  bool? lastSetEnabled;
  bool getResponse = false;
  bool throwOnSet = false;

  @override
  Future<wmpb.GetTestSidechainsResponse> getTestSidechains() async {
    return wmpb.GetTestSidechainsResponse(enabled: getResponse);
  }

  @override
  Future<wmpb.SetTestSidechainsResponse> setTestSidechains(bool enabled) async {
    if (throwOnSet) {
      throw StateError('rpc boom');
    }
    lastSetEnabled = enabled;
    getResponse = enabled;
    return wmpb.SetTestSidechainsResponse();
  }
}

class _FakeOrchestratorRPC extends OrchestratorRPC {
  _FakeOrchestratorRPC(this._fake) : super(host: '127.0.0.1', port: 1);

  final _FakeWalletRPC _fake;

  @override
  // ignore: overridden_fields
  late final OrchestratorWalletRPC wallet = _fake;
}

void main() {
  late Logger logger;

  setUp(() async {
    await GetIt.I.reset();
    logger = Logger();
    GetIt.I.registerSingleton<Logger>(logger);
    GetIt.I.registerSingleton<ClientSettings>(
      ClientSettings(store: _InMemoryStore(), log: logger),
    );
    GetIt.I.registerSingleton<BitwindowClientSettings>(
      BitwindowClientSettings(store: _InMemoryStore(), log: logger),
    );
  });

  test('updateUseTestSidechains forwards to OrchestratorRPC', () async {
    final fake = _FakeWalletRPC();
    GetIt.I.registerSingleton<OrchestratorRPC>(_FakeOrchestratorRPC(fake));

    final provider = await SettingsProvider.create();
    expect(provider.useTestSidechains, isFalse);
    expect(fake.lastSetEnabled, isNull);

    await provider.updateUseTestSidechains(true);
    expect(fake.lastSetEnabled, isTrue);
    expect(provider.useTestSidechains, isTrue);

    await provider.updateUseTestSidechains(false);
    expect(fake.lastSetEnabled, isFalse);
    expect(provider.useTestSidechains, isFalse);
  });

  test('boot reconciles cache against orchestrator', () async {
    final fake = _FakeWalletRPC()..getResponse = true;
    GetIt.I.registerSingleton<OrchestratorRPC>(_FakeOrchestratorRPC(fake));

    // Cache says false, orchestrator says true: reconciled value wins.
    final provider = await SettingsProvider.create();
    expect(provider.useTestSidechains, isTrue);
  });

  test('updateUseTestSidechains reverts cache on RPC failure', () async {
    final fake = _FakeWalletRPC();
    GetIt.I.registerSingleton<OrchestratorRPC>(_FakeOrchestratorRPC(fake));

    final provider = await SettingsProvider.create();
    expect(provider.useTestSidechains, isFalse);

    fake.throwOnSet = true;
    await expectLater(
      provider.updateUseTestSidechains(true),
      throwsA(isA<Object>()),
    );
    expect(provider.useTestSidechains, isFalse, reason: 'cache must revert when RPC fails');
  });
}
