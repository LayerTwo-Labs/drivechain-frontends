import 'dart:io';

import 'package:bitwindow/providers/backend_swap_provider.dart';
import 'package:bitwindow/services/bitwindowd_start.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

// After an app update the new app adopted the old bitwindowd. That one never
// spawns or claims drivechaind again, so the backend port stayed dead.
void main() {
  late List<String> calls;
  late BackendSwapProvider swap;
  late List<BackendSwapStep?> reports;

  _FakeBinaries binaries({required bool adopted, bool liveOwner = false}) => _FakeBinaries(
    adopted: adopted,
    liveOwner: liveOwner,
    calls: calls,
    appDir: Directory.systemTemp,
    binaries: [BitWindow()],
  );

  Future<void> claim() async => calls.add('claim');

  setUp(() {
    calls = [];
    reports = [];
    swap = BackendSwapProvider(tick: const Duration(minutes: 1));
    swap.addListener(() => reports.add(swap.step));
  });

  tearDown(() => swap.dispose());

  test('starts a new bitwindowd when none runs', () async {
    await startBitwindowd(binaries(adopted: false), claimDrivechaind: claim, swap: swap);

    expect(calls, ['start']);
    expect(reports, isEmpty);
  });

  test('claims drivechaind, then replaces a bitwindowd from the last session', () async {
    await startBitwindowd(binaries(adopted: true), claimDrivechaind: claim, swap: swap);

    expect(calls, ['claim', 'stop', 'start']);
  });

  test('reports the swap to the screen, then ends the report', () async {
    await startBitwindowd(binaries(adopted: true), claimDrivechaind: claim, swap: swap);

    expect(reports, [BackendSwapStep.claim, BackendSwapStep.stop, BackendSwapStep.start, null]);
    expect(swap.swapping, isFalse);
  });

  test('shares a bitwindowd that another live app owns', () async {
    await startBitwindowd(binaries(adopted: true, liveOwner: true), claimDrivechaind: claim, swap: swap);

    expect(calls, ['start']);
    expect(reports, isEmpty);
  });

  test('a failed stop still ends the report', () async {
    final provider = _FakeBinaries(
      adopted: true,
      liveOwner: false,
      calls: calls,
      appDir: Directory.systemTemp,
      binaries: [BitWindow()],
      stopError: StateError('no bitwindowd binary'),
    );

    await expectLater(startBitwindowd(provider, claimDrivechaind: claim, swap: swap), throwsStateError);
    expect(swap.swapping, isFalse);
    expect(swap.failedStep, BackendSwapStep.stop);
    expect(swap.error, 'Bad state: no bitwindowd binary');
  });
}

class _FakeBinaries extends BinaryProvider {
  _FakeBinaries({
    required this.adopted,
    required this.liveOwner,
    required this.calls,
    required super.appDir,
    required super.binaries,
    this.stopError,
  }) : super.test();

  final bool adopted;
  final bool liveOwner;
  final List<String> calls;
  final Object? stopError;

  @override
  bool isAdopted(Binary binary) => adopted;

  @override
  Future<bool> ownerAlive(Binary binary) async => liveOwner;

  @override
  Future<void> start(Binary binary) async => calls.add('start');

  @override
  Future<void> stop(Binary binary, {bool skipDownstream = false}) async {
    final error = stopError;
    if (error != null) {
      throw error;
    }
    calls.add('stop');
  }
}
