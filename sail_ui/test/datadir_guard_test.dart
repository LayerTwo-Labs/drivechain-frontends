import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/orchestrator/v1/orchestrator.pb.dart' as orch_pb;

/// Reports whether a datadir is outstanding, and flips on the reload that
/// follows the picker so a test can play out a pick or a refusal.
class _FakeConf extends ChangeNotifier implements BitcoinConfProvider {
  _FakeConf({required this.mustSelectDatadir, this.picksOne = true});

  @override
  BitcoinNetwork network = BitcoinNetwork.BITCOIN_NETWORK_ECASH;

  @override
  bool mustSelectDatadir;

  final bool picksOne;
  bool _prompted = false;

  void promptHappened() => _prompted = true;

  @override
  Future<void> loadConfig({bool isFirst = false, bool userInitiated = false}) async {
    if (_prompted && picksOne) {
      mustSelectDatadir = false;
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeRouter implements StackRouter {
  _FakeRouter(this.conf);

  final _FakeConf conf;
  int pushes = 0;

  @override
  Future<T?> push<T extends Object?>(PageRouteInfo route, {OnNavigationFailure? onFailure}) async {
    pushes++;
    conf.promptHappened();
    return null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeOrchestratorRPC extends OrchestratorRPC {
  _FakeOrchestratorRPC() : super(host: '127.0.0.1', port: 1);

  int starts = 0;

  @override
  Future<orch_pb.StartWithL1Response> startWithL1(
    String target, {
    List<String>? targetArgs,
    Map<String, String>? targetEnv,
    List<String>? coreArgs,
    List<String>? enforcerArgs,
    bool immediate = false,
    bool forceBackend = false,
  }) async {
    starts++;
    return orch_pb.StartWithL1Response();
  }
}

void main() {
  late _FakeOrchestratorRPC orchestrator;

  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    orchestrator = _FakeOrchestratorRPC();
    GetIt.I.registerSingleton<OrchestratorRPC>(orchestrator);
  });

  tearDown(() async => GetIt.I.reset());

  // The orchestrator refuses to start L1 without a directory, so the picker has
  // to come first and the start has to follow it.
  test('asks for the missing directory, then starts the backends', () async {
    final conf = _FakeConf(mustSelectDatadir: true);
    GetIt.I.registerSingleton<BitcoinConfProvider>(conf);
    final router = _FakeRouter(conf);

    expect(await ensureDataDirThenStartBackends(router), isTrue);
    expect(router.pushes, 1);
    expect(orchestrator.starts, 1);
  });

  // A user who backs out of the picker leaves the network without a directory,
  // so nothing may boot and the caller has to hear about it.
  test('starts nothing when the user backs out of the picker', () async {
    final conf = _FakeConf(mustSelectDatadir: true, picksOne: false);
    GetIt.I.registerSingleton<BitcoinConfProvider>(conf);
    final router = _FakeRouter(conf);

    expect(await ensureDataDirThenStartBackends(router), isFalse);
    expect(router.pushes, 1);
    expect(orchestrator.starts, 0);
  });

  // A network that already has its directory is booted by bitwindow's startup
  // or by select(). A second dispatch races the first, and the loser reports a
  // startup failure.
  test('starts nothing when the directory is already set', () async {
    final conf = _FakeConf(mustSelectDatadir: false);
    GetIt.I.registerSingleton<BitcoinConfProvider>(conf);
    final router = _FakeRouter(conf);

    expect(await ensureDataDirThenStartBackends(router), isTrue);
    expect(router.pushes, 0);
    expect(orchestrator.starts, 0);
  });
}
