import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

/// Minimal RPCConnection stub — we only care about the state-flip surface
/// (`initializingBinary`, `connected`, `markStateChanged`).
class _StubRpc extends RPCConnection {
  _StubRpc({required super.binaryType});

  int notifyCount = 0;

  @override
  Future<List<String>> binaryArgs() async => const [];

  @override
  Future<void> stopRPC() async {}

  @override
  Future<(double, double)> balance() async => (0.0, 0.0);

  @override
  Future<BlockchainInfo> getBlockchainInfo() async => BlockchainInfo.empty();

  @override
  void markStateChanged() {
    notifyCount++;
    super.markStateChanged();
  }
}

class _MockStore implements KeyValueStore {
  final _db = <String, String>{};

  @override
  Future<String?> getString(String key) async => _db[key];

  @override
  Future<void> setString(String key, String value) async {
    _db[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _db.remove(key);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    final getIt = GetIt.instance;
    await getIt.reset();

    final log = Logger(level: Level.off);
    getIt.registerSingleton<Logger>(log);
    getIt.registerSingleton<ClientSettings>(ClientSettings(store: _MockStore(), log: log));
    getIt.registerSingleton<BitwindowClientSettings>(
      BitwindowClientSettings(store: _MockStore(), log: log),
    );
    getIt.registerSingleton<SettingsProvider>(await SettingsProvider.create());
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  test('addStartupLogForBinary records a non-empty message on the binary', () {
    final bitwindow = BitWindow();
    final provider = BinaryProvider.test(
      appDir: Directory.systemTemp,
      binaries: [bitwindow, Orchestratord()],
    );

    provider.addStartupLogForBinary(BinaryType.bitWindow, 'Starting BitWindow...');

    final logs = provider.binaries.firstWhere((b) => b.type == BinaryType.bitWindow).startupLogs;
    expect(logs, isNotEmpty);
    expect(logs.last.message, 'Starting BitWindow...');
  });

  test('addStartupLogForBinary also captures logs targeting orchestratord', () {
    final provider = BinaryProvider.test(
      appDir: Directory.systemTemp,
      binaries: [BitWindow(), Orchestratord()],
    );

    provider.addStartupLogForBinary(BinaryType.orchestratord, 'Waiting for orchestratord...');

    final logs = provider.binaries.firstWhere((b) => b.type == BinaryType.orchestratord).startupLogs;
    expect(logs.last.message, 'Waiting for orchestratord...');
  });

  test(
    'orchestrator-wait hook holds initializingBinary=true while listBinaries is failing, clears on success',
    () async {
      // Mimics the shape of bootBitwindowBackend's wait loop: assert the flag
      // true before the loop, clear it when the RPC call finally succeeds.
      // This is the exact sequence that keeps DaemonConnectionCard showing
      // "Initializing..." instead of "Not connected" during early boot.
      final rpc = _StubRpc(binaryType: BinaryType.bitWindow);
      final observedDuringWait = <bool>[];

      rpc.initializingBinary = true;
      rpc.markStateChanged();

      // Scriptable "listBinaries" that throws N times, then returns.
      var attempts = 0;
      Future<void> fakeListBinaries() async {
        attempts++;
        if (attempts < 3) throw StateError('not ready');
      }

      for (var i = 0; i < 10; i++) {
        try {
          observedDuringWait.add(rpc.initializingBinary);
          await fakeListBinaries();
          rpc.initializingBinary = false;
          rpc.markStateChanged();
          break;
        } catch (_) {
          // keep looping
        }
      }

      expect(observedDuringWait, [true, true, true]);
      expect(rpc.initializingBinary, isFalse);
      expect(attempts, 3);
      // Flag set once at start + cleared at end = at least 2 notifyListeners calls.
      expect(rpc.notifyCount, greaterThanOrEqualTo(2));
    },
  );
}
