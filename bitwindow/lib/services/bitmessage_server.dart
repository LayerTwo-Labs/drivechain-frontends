// dart format off
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bitwindow/models/bitintroduction_protocol.dart';
typedef BitMessageProfileProvider = FutureOr<BitMessageProfile?> Function(String? bitNameHash);
typedef IncomingBitMessageCallback = FutureOr<void> Function(BitMessageWire wire);
class BitMessageServer {
  BitMessageServer({
    required this.profileProvider,
    required this.onIncomingWire,
    this.allowRemoteClients,
    InternetAddress? bindAddress,
    this.port = 0,
    this.maxBodyBytes = 64 * 1024,
    this.requestBodyTimeout = const Duration(seconds: 5),
    this.callbackTimeout = const Duration(seconds: 10),
    this.idleTimeout = const Duration(seconds: 15),
    this.maxConcurrentRequests = 16,
  }) : bindAddress = bindAddress ?? InternetAddress.loopbackIPv4 {
    if (maxBodyBytes <= 0) throw ArgumentError.value(maxBodyBytes, 'maxBodyBytes', 'must be positive'); if (port < 0 || port > 65535) throw ArgumentError.value(port, 'port', 'must be between 0 and 65535'); if (maxConcurrentRequests < 1) throw ArgumentError.value(maxConcurrentRequests, 'maxConcurrentRequests');
  }
  final BitMessageProfileProvider profileProvider; final IncomingBitMessageCallback onIncomingWire;
  final bool Function()? allowRemoteClients; final InternetAddress bindAddress;
  final int port, maxBodyBytes; final Duration requestBodyTimeout, callbackTimeout, idleTimeout;
  final int maxConcurrentRequests; HttpServer? _server; int _activeRequests = 0;
  bool get isRunning => _server != null; Uri get localEndpoint {
    final server = _server ?? (throw StateError('BitMessageServer has not been started'));
    final address = server.address.address;
    return Uri.parse(
      'http://${server.address.type == InternetAddressType.IPv6 ? '[$address]' : address}:${server.port}',
    );
  }
  Future<Uri> start() async {
    if (isRunning) throw StateError('BitMessageServer is already running');
    final server = await HttpServer.bind(bindAddress, port, shared: false);
    server
      ..idleTimeout = idleTimeout
      ..autoCompress = false;
    _server = server; server.listen((request) => unawaited(_handle(request)));
    return localEndpoint;
  }
  Future<void> stop() async {
    final server = _server; _server = null;
    await server?.close(force: true);
  }
  Future<void> _handle(HttpRequest request) async {
    if (_activeRequests >= maxConcurrentRequests) {
      await _json(request.response, HttpStatus.serviceUnavailable, {'error': 'busy'});
      return;
    }
    _activeRequests++;
    try {
      if (!(allowRemoteClients?.call() ?? true) && !(request.connectionInfo?.remoteAddress.isLoopback ?? false)) {
        await _json(request.response, HttpStatus.forbidden, {'error': 'tor_only'});
        return;
      }
      final commit = RegExp(r'^/bitname/([0-9a-fA-F]{64})/bitname_commit$').firstMatch(request.uri.path);
      final submit = RegExp(r'^/bitname/([0-9a-fA-F]{64})/bitmessage_submit$').firstMatch(request.uri.path);
      if (commit != null) {
        if (!await _requireMethod(request, 'GET')) return;
        await _serveProfile(request.response, commit[1]!.toLowerCase());
      } else if (submit != null) {
        if (!await _requireMethod(request, 'POST')) return;
        await _accept(request, submit[1]!.toLowerCase());
      } else if (request.uri.path == '/bitname_commit') {
        if (!await _requireMethod(request, 'GET')) return;
        await _serveProfile(request.response, null);
      } else if (request.uri.path == '/bitmessage_submit') {
        if (!await _requireMethod(request, 'POST')) return;
        await _accept(request, null);
      } else {
        await _json(request.response, HttpStatus.notFound, {'error': 'not_found'});
      }
    } on _BodyTooLarge {
      await _json(request.response, HttpStatus.requestEntityTooLarge, {'error': 'body_too_large'});
    } on TimeoutException {
      await _json(request.response, HttpStatus.requestTimeout, {'error': 'request_timeout'});
    } on FormatException catch (error) {
      await _json(request.response, HttpStatus.badRequest, {'error': 'invalid_request', 'detail': error.message});
    } catch (_) {
      await _json(request.response, HttpStatus.internalServerError, {'error': 'internal_error'});
    } finally {
      _activeRequests--;
    }
  }
  Future<bool> _requireMethod(HttpRequest request, String method) async {
    if (request.method == method) return true;
    request.response.headers.set(HttpHeaders.allowHeader, method);
    await _json(request.response, HttpStatus.methodNotAllowed, {'error': 'method_not_allowed'});
    return false;
  }
  Future<void> _serveProfile(HttpResponse response, String? hash) async {
    final profile = await Future<BitMessageProfile?>.sync(() => profileProvider(hash)).timeout(callbackTimeout);
    if (profile == null) return _json(response, HttpStatus.notFound, {'error': 'identity_not_found'});
    if (hash != null && profile.bitNameHash != hash) {
      throw const FormatException('profile provider returned the wrong identity');
    }
    await _json(response, HttpStatus.ok, profile.toJson());
  }
  Future<void> _accept(HttpRequest request, String? expectedHash) async {
    if (request.headers.contentType?.mimeType != ContentType.json.mimeType) {
      return _json(request.response, HttpStatus.unsupportedMediaType, {'error': 'content_type_must_be_json'});
    }
    dynamic decoded;
    try {
      decoded = jsonDecode(utf8.decode(await _read(request)));
    } on FormatException catch (error) {
      throw FormatException('body is not valid UTF-8 JSON: $error');
    }
    if (decoded is! Map) throw const FormatException('body must be an object');
    final wire = BitMessageWire.fromJson(Map<String, dynamic>.from(decoded));
    if (expectedHash != null && wire.recipientBitNameHash != expectedHash) {
      throw const FormatException('wire recipient does not match endpoint identity');
    }
    try {
      await Future<void>.sync(() => onIncomingWire(wire)).timeout(callbackTimeout);
    } on TimeoutException {
      return _json(request.response, HttpStatus.gatewayTimeout, {'error': 'callback_timeout'});
    }
    await _json(request.response, HttpStatus.accepted, {'accepted': true});
  }
  Future<List<int>> _read(HttpRequest request) async {
    if (request.contentLength > maxBodyBytes) throw const _BodyTooLarge();
    final bytes = <int>[];
    await (() async {
      await for (final chunk in request) {
        if (bytes.length + chunk.length > maxBodyBytes) throw const _BodyTooLarge();
        bytes.addAll(chunk);
      }
    })().timeout(requestBodyTimeout);
    return bytes;
  }
  Future<void> _json(HttpResponse response, int status, Map<String, dynamic> body) async {
    response
      ..statusCode = status
      ..headers.contentType = ContentType.json;
    response.headers.set(HttpHeaders.cacheControlHeader, 'no-store');
    response.write(jsonEncode(body)); await response.close();
  }
}
class _BodyTooLarge implements Exception { const _BodyTooLarge(); }
