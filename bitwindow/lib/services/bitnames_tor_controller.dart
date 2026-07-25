// dart format off
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:sail_ui/sail_ui.dart';
enum BitnamesTorState { unavailable, notDownloaded, stopped, downloading, starting, ready, error }
class BitnamesTorStatus {
  const BitnamesTorStatus({required this.state, this.onionHost, this.p2pOnion, this.p2pReady = false,
    this.socksAddress = '127.0.0.1:19050', this.error});
  final BitnamesTorState state; final String? onionHost, p2pOnion, error;
  final bool p2pReady; final String socksAddress;
  bool get ready => state == BitnamesTorState.ready;
}
class BitnamesTorController {
  BitnamesTorController({required this.orchestrator, http.Client? httpClient, Uri? statusEndpoint, this._controlToken})
    : statusEndpoint = statusEndpoint ?? Uri.parse('http://127.0.0.1:37998/status'),
       _httpClient = httpClient ?? http.Client();
  static const binaryName = 'bitnames-tor'; final OrchestratorRPC orchestrator;
  final Uri statusEndpoint; final http.Client _httpClient; String? _controlToken;
  final Set<String> _tunnelAddresses = {}; bool _chainTorPrepared = false;
  bool get chainTorPrepared => _chainTorPrepared;
  Future<BitnamesTorStatus> refresh() async {
    final runtime = await _runtimeStatus();
    if (runtime?.ready ?? false) return runtime!;
    try {
      final binary = (await orchestrator.getBinaryStatus(binaryName)).status;
      if (!binary.downloaded) {
        return const BitnamesTorStatus(state: BitnamesTorState.notDownloaded);
      }
      if (binary.running || binary.initializing) {
        return BitnamesTorStatus(state: BitnamesTorState.starting, error: runtime?.error);
      }
      final error = binary.error.isNotEmpty
          ? binary.error
          : binary.connectionError.isNotEmpty
          ? binary.connectionError
          : runtime?.error;
      final state = error == null ? BitnamesTorState.stopped : BitnamesTorState.error;
      return BitnamesTorStatus(state: state, error: error);
    } catch (error) {
      return BitnamesTorStatus(state: BitnamesTorState.unavailable, error: '$error');
    }
  }
  Future<BitnamesTorStatus> downloadAndStart({Duration timeout = const Duration(minutes: 15)}) async {
    if ((await orchestrator.getBinaryStatus(binaryName)).status.downloaded) return start();
    await orchestrator.downloadBinary(binaryName);
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      final status = (await orchestrator.getBinaryStatus(binaryName)).status;
      if (status.downloaded) return start(timeout: const Duration(minutes: 2));
      if (status.error.isNotEmpty) throw StateError(status.error);
      await _pause();
    }
    throw TimeoutException('Timed out downloading BitNames Tor');
  }
  Future<BitnamesTorStatus> start({Duration timeout = const Duration(minutes: 2)}) async { final existing = await refresh(); if (existing.ready) return existing;
    await orchestrator.startBinary(binaryName);
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      final status = await _runtimeStatus();
      if (status?.ready ?? false) return status!;
      if (status?.state == BitnamesTorState.error) throw StateError(status?.error ?? 'BitNames Tor failed to start');
      await _pause();
    }
    throw TimeoutException('Timed out starting BitNames Tor');
  }
  Future<void> stop() async { _chainTorPrepared = false; _tunnelAddresses.clear(); await orchestrator.stopBinary(binaryName); }
  Future<String> connectP2P(String onion) async {
    final endpoint = statusEndpoint.replace(path: '/p2p/connect');
    final request = _httpClient.post(endpoint, headers: await _headers(contentType: true), body: jsonEncode({'onion': onion}));
    final response = await request.timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw StateError('BitNames Tor peer failed: ${response.body.trim()}');
    }
    final body = jsonDecode(response.body);
    final address = body is Map ? body['udp_address'] as String? : null;
    if (address == null || !_isLoopbackSocket(address)) {
      throw StateError('BitNames Tor returned an unsafe peer address');
    }
    _tunnelAddresses.add(address);
    return address;
  }
  Future<void> enableChainTor(BitnamesRPC rpc, String peerOnion,
    {Duration timeout = const Duration(minutes: 2)}) async {
    _chainTorPrepared = false;
    final status = await refresh();
    if (!status.ready || !status.p2pReady) throw StateError('Start BitNames Tor before enabling Tor mode');
    final tunnel = await connectP2P(peerOnion);
    await _restartBitNames(['--tor-proxy-mode', '--tor-proxy-peer', tunnel], timeout);
    _chainTorPrepared = true;
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      if (await chainTorReady(rpc)) return;
      try { await rpc.connectPeer(tunnel); } catch (_) {}
      await _pause();
    }
    _chainTorPrepared = false;
    throw StateError('BitNames did not establish a Tor-only peer');
  }
  Future<void> disableChainTor({Duration timeout = const Duration(minutes: 2)}) async {
    _chainTorPrepared = false; _tunnelAddresses.clear(); await _restartBitNames(const [], timeout); }
  Future<bool> chainTorReady(BitnamesRPC rpc) async {
    if (!_chainTorPrepared) return false;
    final status = await _runtimeStatus();
    if (!(status?.ready ?? false) || !(status?.p2pReady ?? false)) return false;
    try {
      final peers = await rpc.listPeers();
      return peers.isNotEmpty &&
          peers.every((peer) => _isLoopbackSocket(peer.address)) &&
          peers.any((peer) => peer.status.toLowerCase() == 'connected' && _tunnelAddresses.contains(peer.address));
    } catch (_) {
      return false;
    }
  }
  Future<void> _restartBitNames(List<String> args, Duration timeout) async {
    await orchestrator.stopBinary('bitnames', force: true); final deadline = DateTime.now().add(timeout); while ((await orchestrator.getBinaryStatus('bitnames')).status.connected && DateTime.now().isBefore(deadline)) { await _pause(); } await _pause();
    await orchestrator.startWithL1('bitnames', targetArgs: args, forceBackend: true);
    while (DateTime.now().isBefore(deadline)) {
      final status = (await orchestrator.getBinaryStatus('bitnames')).status;
      if (status.connected) return;
      final errors = [status.startupError];
      final error = errors.firstWhere((value) => value.isNotEmpty, orElse: () => '');
      if (error.isNotEmpty) throw StateError(error);
      await _pause();
    }
    throw TimeoutException('Timed out restarting BitNames');
  }
  Future<BitnamesTorStatus?> _runtimeStatus() async {
    try {
      final request = _httpClient.get(statusEndpoint, headers: await _headers());
      final body = jsonDecode((await request.timeout(const Duration(seconds: 1))).body);
      if (body is! Map) return null;
      final json = Map<String, dynamic>.from(body);
      final rawError = json['error'] as String?;
      final error = (rawError?.trim().isEmpty ?? true) ? null : rawError;
      var state = error == null ? BitnamesTorState.starting : BitnamesTorState.error;
      if (json['ready'] == true) state = BitnamesTorState.ready;
      return BitnamesTorStatus(state: state, onionHost: _withoutScheme(json['onion'] as String?),
        p2pOnion: json['p2p_onion'] as String?, p2pReady: json['p2p_ready'] == true,
        socksAddress: json['socks_address'] as String? ?? '127.0.0.1:19050', error: error);
    } catch (_) { return null; }
  }
  Future<Map<String, String>> _headers({bool contentType = false}) async => {
    'accept': 'application/json', 'authorization': 'Bearer ${await _token()}',
    if (contentType) 'content-type': 'application/json',
  }; Future<String> _token() async {
    if (_controlToken != null) return _controlToken!;
    final env = Platform.environment, home = env['HOME'] ?? env['USERPROFILE'];
    final base = Platform.isWindows ? env['APPDATA'] : Platform.isMacOS ? '$home/Library/Application Support' : env['XDG_CONFIG_HOME'] ?? '$home/.config';
    return _controlToken = (await File('$base/bitnames-tor/control-token').readAsString()).trim();
  }
  Future<void> _pause() => Future<void>.delayed(const Duration(milliseconds: 500));
  void close() => _httpClient.close();
}
String? _withoutScheme(String? value) => value?.replaceFirst(RegExp(r'^https?://'), '');
bool _isLoopbackSocket(String value) {
  final host = Uri.tryParse('udp://$value')?.host;
  return host != null && (InternetAddress.tryParse(host)?.isLoopback ?? false);
}
