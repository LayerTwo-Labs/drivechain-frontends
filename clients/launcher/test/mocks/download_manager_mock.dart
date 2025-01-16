import 'dart:async';
import 'dart:io';

import 'package:launcher/providers/download_provider.dart';
import 'package:sail_ui/config/binaries.dart';

class MockDownloadProvider extends DownloadProvider {
  final _statusController = StreamController<Map<String, DownloadProgress>>.broadcast();
  final Map<String, DownloadProgress> _binaryStatus = {};

  MockDownloadProvider() : super(datadir: Directory(''), configs: []) {
    // Initialize with a test status
    _binaryStatus['test-chain'] = DownloadProgress(
      binaryName: 'test-chain',
      status: DownloadStatus.notStarted,
    );
    _emitStatus();
  }

  @override
  Stream<Map<String, DownloadProgress>> get statusStream => _statusController.stream;

  @override
  Future<bool> downloadBinary(Binary binary) async {
    _binaryStatus[binary.name] = DownloadProgress(
      binaryName: binary.name,
      status: DownloadStatus.completed,
      progress: 1.0,
    );
    _emitStatus();
    return true;
  }

  void _emitStatus() {
    _statusController.add(Map.from(_binaryStatus));
  }

  @override
  void dispose() {
    _statusController.close();
    super.dispose();
  }
}
