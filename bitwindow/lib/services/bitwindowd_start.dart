import 'dart:io';

import 'package:bitwindow/providers/backend_swap_provider.dart';
import 'package:connectrpc/connect.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

/// Starts bitwindowd for this app.
///
/// Only a new bitwindowd spawns drivechaind or claims it for this app. So a
/// bitwindowd whose app exited gets replaced, after [claimDrivechaind] keeps
/// its drivechaind alive through the swap. One that a live app owns is shared.
Future<void> startBitwindowd(
  BinaryProvider provider, {
  required Future<void> Function() claimDrivechaind,
  required BackendSwapProvider swap,
}) async {
  final bitwindow = provider.binaries.firstWhere((b) => b is BitWindow);
  if (!provider.isAdopted(bitwindow) || await provider.ownerAlive(bitwindow)) {
    await provider.start(bitwindow);
    return;
  }
  try {
    swap.report(BackendSwapStep.claim);
    await claimDrivechaind();
    await _replace(provider, bitwindow, swap);
    swap.finish();
  } catch (e) {
    swap.fail(e);
    rethrow;
  }
}

/// The old bitwindowd drains its daemons before it exits, so the stop holds
/// the app. [swap] carries that wait to the screen.
Future<void> _replace(BinaryProvider provider, Binary bitwindow, BackendSwapProvider swap) async {
  swap.report(BackendSwapStep.stop);
  await provider.stop(bitwindow);
  swap.report(BackendSwapStep.start);
  await provider.start(bitwindow);
}

/// Makes this app the owner of a drivechaind from the last session. The
/// backend drains the whole stack when its owner exits.
Future<void> claimDrivechaind(OrchestratorRPC orchestrator, Logger log) async {
  try {
    await orchestrator.adoptOwner(pid);
  } on ConnectException catch (e) {
    log.i('STARTUP: no drivechaind to claim, the new bitwindowd starts one: $e');
  }
}
