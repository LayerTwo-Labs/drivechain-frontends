import 'dart:async';
import 'dart:io';

import 'package:bitwindow/env.dart';
import 'package:bitwindow/providers/backend_swap_provider.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

/// Asks the running [bitwindow] to stay with this app as its owner. True when
/// it and its drivechaind run the same files that this app starts.
typedef KeepDaemons = Future<bool> Function(BinaryProvider provider, Binary bitwindow);

/// Starts bitwindowd for this app.
///
/// A bitwindowd from an earlier session stays when it and its drivechaind run
/// the files this app starts. Else the start replaces it, and the new
/// bitwindowd retires the running drivechaind: a daemon of another build lists
/// the catalog it shipped with, and a newer RPC answers 404. bitcoind, the
/// enforcer and the sidechains stay up through the swap.
Future<void> startBitwindowd(
  BinaryProvider provider, {
  required BackendSwapProvider swap,
  KeepDaemons keep = keepRunningDaemons,
}) async {
  final bitwindow = provider.binaries.firstWhere((b) => b is BitWindow);
  if (!provider.isAdopted(bitwindow) || await keep(provider, bitwindow)) {
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

/// Asks the bitwindowd on the configured port to stay. A daemon that does not
/// answer, or an older build with no answer for the request, does not stay.
Future<bool> keepRunningDaemons(BinaryProvider provider, Binary bitwindow) async {
  final bitwindowd = await bitwindow.resolveBinaryPath(provider.appDir);
  final uri = Uri.http('${Environment.bitwindowdHost.value}:${Environment.bitwindowdPort.value}', '/daemon/keep', {
    'owner': '$pid',
    'path': bitwindowd.path,
  });
  final token = await LocalAuth.token();
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 1);
  try {
    final request = await client.postUrl(uri);
    if (token != null) {
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    }
    final response = await request.close().timeout(const Duration(seconds: 3));
    final body = await response.transform(const SystemEncoding().decoder).join();
    if (response.statusCode != HttpStatus.ok) {
      GetIt.I.get<Logger>().i('bitwindowd of the last session does not stay: ${response.statusCode} $body');
      return false;
    }
    return true;
  } on SocketException catch (e) {
    GetIt.I.get<Logger>().i('bitwindowd of the last session does not answer: $e');
    return false;
  } on TimeoutException catch (e) {
    GetIt.I.get<Logger>().i('bitwindowd of the last session does not answer: $e');
    return false;
  } finally {
    client.close(force: true);
  }
}
