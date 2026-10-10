import 'dart:io';

import 'package:bitwindow/providers/backend_swap_provider.dart';
import 'package:bitwindow/services/bitwindowd_start.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

// An app that shares a bitwindowd from an earlier session also shares that
// daemon's build, so the network picker lists the catalog it shipped with.
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

  setUp(() {
    calls = [];
    reports = [];
    swap = BackendSwapProvider(tick: const Duration(minutes: 1));
    swap.addListener(() => reports.add(swap.step));
  });

  tearDown(() => swap.dispose());

  test('starts a new bitwindowd when none runs', () async {
    await startBitwindowd(binaries(adopted: false), swap: swap);

    expect(calls, ['start']);
    expect(reports, isEmpty);
  });

  test('replaces a bitwindowd from the last session', () async {
    await startBitwindowd(binaries(adopted: true), swap: swap);

    expect(calls, ['stop', 'start']);
  });

  test('replaces a bitwindowd that another live app owns', () async {
    await startBitwindowd(binaries(adopted: true, liveOwner: true), swap: swap);

    expect(calls, ['stop', 'start']);
  });

  test('reports the swap to the screen, then ends the report', () async {
    await startBitwindowd(binaries(adopted: true), swap: swap);

    expect(reports, [BackendSwapStep.stop, BackendSwapStep.start, null]);
    expect(swap.swapping, isFalse);
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

    await expectLater(startBitwindowd(provider, swap: swap), throwsStateError);
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
  Future<void> start(Binary binary, {bool background = false}) async => calls.add('start');

  @override
  Future<void> stop(Binary binary, {bool skipDownstream = false}) async {
    final error = stopError;
    if (error != null) {
      throw error;
    }
    calls.add('stop');
  }
}
