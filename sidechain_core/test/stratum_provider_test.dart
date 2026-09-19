import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sidechain_core/gen/stratum/v1/stratum.pb.dart';
import 'package:sidechain_core/rpcs/orchestrator_stratum_rpc.dart';
import 'package:sidechain_core/sidechain_core.dart';

class _FakeStratum implements OrchestratorStratumRPC {
  GetStratumStatusResponse next = GetStratumStatusResponse();
  Future<GetStratumStatusResponse>? pending;
  Target? target;

  @override
  Future<GetStratumStatusResponse> status() => pending ?? Future.value(next);

  @override
  Future<List<CatalogPool>> listPools() async => [CatalogPool(id: 'bip300', name: 'bip300 pool')];

  @override
  Future<void> setTarget(Target target) async {
    this.target = target;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeOrchestrator implements OrchestratorRPC {
  _FakeOrchestrator(this.stratum);

  @override
  final OrchestratorStratumRPC stratum;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

FoundBlock _block(int height, String hash) => FoundBlock(height: height, hash: hash, worker: 'avalon.1');

void main() {
  late _FakeStratum stratum;

  setUp(() async {
    await GetIt.I.reset();
    stratum = _FakeStratum();
    GetIt.I.registerSingleton<OrchestratorRPC>(_FakeOrchestrator(stratum));
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  group('StratumProvider', () {
    test('a found block is announced one time', () async {
      final announced = <int>[];
      final provider = StratumProvider(onBlockFound: (block) => announced.add(block.height));

      stratum.next = GetStratumStatusResponse(running: true, blocksFound: [_block(500, 'aa')]);
      await provider.refresh();
      await provider.refresh();
      expect(announced, [500]);

      stratum.next = GetStratumStatusResponse(
        running: true,
        blocksFound: [_block(502, 'cc'), _block(501, 'bb'), _block(500, 'aa')],
      );
      await provider.refresh();
      expect(announced, [500, 501, 502]);
      expect(provider.running, isTrue);
      expect(provider.pools.single.name, 'bip300 pool');
    });

    test('a pool target', () async {
      final provider = StratumProvider();
      stratum.next = GetStratumStatusResponse(target: Target(kind: TargetKind.TARGET_KIND_SOLO));
      await provider.refresh();
      expect(provider.poolTarget, isFalse);

      stratum.next = GetStratumStatusResponse(target: Target(kind: TargetKind.TARGET_KIND_CUSTOM));
      await provider.refresh();
      expect(provider.poolTarget, isTrue);
    });

    test('an older read never overwrites a newer one', () async {
      final provider = StratumProvider();
      final slow = Completer<GetStratumStatusResponse>();
      stratum.pending = slow.future;

      final first = provider.refresh();
      await Future<void>.delayed(Duration.zero);
      stratum.pending = null;
      stratum.next = GetStratumStatusResponse(running: false, port: 2);
      final second = provider.refresh();
      await Future<void>.delayed(Duration.zero);
      slow.complete(GetStratumStatusResponse(running: true, port: 1));
      await Future.wait([first, second]);

      expect(provider.status.port, 2);
    });

    test('a failed read keeps the last status', () async {
      final provider = StratumProvider();
      stratum.next = GetStratumStatusResponse(running: true, port: 3333);
      await provider.refresh();

      GetIt.I.unregister<OrchestratorRPC>();
      GetIt.I.registerSingleton<OrchestratorRPC>(_FakeOrchestrator(_BrokenStratum()));
      await provider.refresh();
      expect(provider.error, isNotNull);
      expect(provider.status.port, 3333);
    });
  });

  group('formatting', () {
    test('hashrate', () {
      expect(formatHashrate(0), '0 H/s');
      expect(formatHashrate(950), '950 H/s');
      expect(formatHashrate(6.02e12), '6.02 TH/s');
      expect(formatHashrate(1.5e15), '1.50 PH/s');
      expect(formatHashrate(16531755363981.977), '16.5 TH/s');
      expect(formatHashrate(123.4e9), '123 GH/s');
      expect(formatHashrate(999.9e9), '1.00 TH/s');
    });

    test('difficulty', () {
      expect(formatDifficulty(0), '0');
      expect(formatDifficulty(4.66e-10), '4.66e-10');
      expect(formatDifficulty(812), '812');
      expect(formatDifficulty(8192), '8.19K');
      expect(formatDifficulty(1234567), '1.23M');
      expect(formatDifficulty(90.5e12), '90.50T');
    });

    test('relative time', () {
      final now = DateTime(2026, 9, 19, 12);
      expect(formatAgo(now.subtract(const Duration(seconds: 3)), now), '3 s ago');
      expect(formatAgo(now.subtract(const Duration(minutes: 5)), now), '5 min ago');
      expect(formatAgo(now.subtract(const Duration(hours: 2)), now), '2 h ago');
      expect(formatAgo(now.subtract(const Duration(days: 4)), now), '4 d ago');
      expect(formatAgo(now.add(const Duration(seconds: 2)), now), '0 s ago');
    });

    test('expected time to a block', () {
      expect(expectedTimeToBlock(1000, 0), isNull);
      // Difficulty 1 takes 2^32 hashes.
      expect(expectedTimeToBlock(1, 4294967296), const Duration(seconds: 1));
      expect(formatLongDuration(expectedTimeToBlock(90e12, 6e12)!), '2042 years');
      expect(formatLongDuration(const Duration(hours: 5)), '5 hours');
      expect(formatLongDuration(const Duration(days: 1)), '1 day');
    });
  });
}

class _BrokenStratum implements OrchestratorStratumRPC {
  @override
  Future<GetStratumStatusResponse> status() async => throw Exception('drivechaind is down');

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
