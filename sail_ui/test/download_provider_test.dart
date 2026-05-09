import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/gen/orchestrator/v1/orchestrator.pb.dart' as orch_pb;
import 'package:sail_ui/sail_ui.dart';

class _FakeOrchestratorRPC extends OrchestratorRPC {
  _FakeOrchestratorRPC() : super(host: '127.0.0.1', port: 1);

  /// What the next [getDownloadStatus] call will return.
  List<orch_pb.DownloadStatus> nextDownloads = [];
  Object? nextError;
  int callCount = 0;

  @override
  Future<orch_pb.GetDownloadStatusResponse> getDownloadStatus() async {
    callCount++;
    if (nextError != null) {
      throw nextError!;
    }
    return orch_pb.GetDownloadStatusResponse(downloads: nextDownloads);
  }
}

void main() {
  setUpAll(() {
    if (!GetIt.I.isRegistered<Logger>()) {
      GetIt.I.registerSingleton<Logger>(Logger(level: Level.warning));
    }
  });

  setUp(() async {
    if (GetIt.I.isRegistered<OrchestratorRPC>()) {
      await GetIt.I.unregister<OrchestratorRPC>();
    }
  });

  test('fetch records each download keyed by BinaryType', () async {
    final fake = _FakeOrchestratorRPC()
      ..nextDownloads = [
        orch_pb.DownloadStatus(
          binary: BinaryType.BINARY_TYPE_BITCOIND,
          mbDownloaded: Int64(12),
          mbTotal: Int64(50),
        ),
        orch_pb.DownloadStatus(
          binary: BinaryType.BINARY_TYPE_THUNDER,
          mbDownloaded: Int64(4),
          mbTotal: Int64(-1),
        ),
      ];
    GetIt.I.registerSingleton<OrchestratorRPC>(fake);

    final provider = DownloadProvider(startTimer: false);
    await provider.fetch();

    expect(provider.hasActiveDownloads, isTrue);
    expect(provider.statusFor(BinaryType.BINARY_TYPE_BITCOIND)?.mbDownloaded, 12);
    expect(provider.statusFor(BinaryType.BINARY_TYPE_THUNDER)?.mbTotal, -1);
    expect(provider.statusFor(BinaryType.BINARY_TYPE_BITNAMES), isNull);
    expect(provider.lastError, isNull);
  });

  test('UNSPECIFIED entries from the wire are dropped from the map', () async {
    final fake = _FakeOrchestratorRPC()
      ..nextDownloads = [
        orch_pb.DownloadStatus(
          binary: BinaryType.BINARY_TYPE_UNSPECIFIED,
          mbDownloaded: Int64(1),
          mbTotal: Int64(2),
        ),
        orch_pb.DownloadStatus(
          binary: BinaryType.BINARY_TYPE_THUNDER,
          mbDownloaded: Int64(3),
          mbTotal: Int64(4),
        ),
      ];
    GetIt.I.registerSingleton<OrchestratorRPC>(fake);

    final provider = DownloadProvider(startTimer: false);
    await provider.fetch();

    expect(provider.downloads.keys, [BinaryType.BINARY_TYPE_THUNDER]);
  });

  test('empty response leaves the map empty and clears prior errors', () async {
    final fake = _FakeOrchestratorRPC();
    GetIt.I.registerSingleton<OrchestratorRPC>(fake);

    final provider = DownloadProvider(startTimer: false);
    await provider.fetch();

    expect(provider.hasActiveDownloads, isFalse);
    expect(provider.downloads, isEmpty);
  });

  test('rpc failures land in lastError and notify listeners', () async {
    final fake = _FakeOrchestratorRPC()..nextError = StateError('boom');
    GetIt.I.registerSingleton<OrchestratorRPC>(fake);

    final provider = DownloadProvider(startTimer: false);
    var notifyCount = 0;
    provider.addListener(() => notifyCount++);

    await provider.fetch();

    expect(provider.lastError, contains('boom'));
    expect(notifyCount, 1);
  });

  test('progressFraction clamps and survives unknown total', () {
    expect(
      const DownloadProgress(binary: BinaryType.BINARY_TYPE_BITCOIND, mbDownloaded: 50, mbTotal: 100).progressFraction,
      0.5,
    );
    // Unknown total → 0 instead of NaN, so the UI can render an indeterminate bar.
    expect(
      const DownloadProgress(binary: BinaryType.BINARY_TYPE_BITCOIND, mbDownloaded: 50, mbTotal: -1).progressFraction,
      0,
    );
    // Over 100% (rare, but happens on rounding) is clamped.
    expect(
      const DownloadProgress(binary: BinaryType.BINARY_TYPE_BITCOIND, mbDownloaded: 200, mbTotal: 100).progressFraction,
      1,
    );
  });
}
