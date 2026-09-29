import 'package:bitwindow/providers/backend_swap_provider.dart';
import 'package:sail_ui/sail_ui.dart';

/// Starts bitwindowd for this app.
///
/// A start always replaces a bitwindowd from an earlier session, and that new
/// bitwindowd retires the running drivechaind. A shared daemon keeps the build
/// it started with: the network picker then lists the catalog that daemon
/// shipped with, and a newer RPC answers 404. bitcoind, the enforcer and the
/// sidechains stay up through the swap.
Future<void> startBitwindowd(
  BinaryProvider provider, {
  required BackendSwapProvider swap,
}) async {
  final bitwindow = provider.binaries.firstWhere((b) => b is BitWindow);
  if (!provider.isAdopted(bitwindow)) {
    await provider.start(bitwindow);
    return;
  }
  try {
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
