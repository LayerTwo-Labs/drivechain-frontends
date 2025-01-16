import 'dart:async';
import 'dart:io';

import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/providers/download_provider.dart';

class MockDownloadProvider extends DownloadProvider {
  final _statusController = StreamController<Map<String, DownloadProgress>>.broadcast();
  final Map<String, DownloadProgress> _binaryStatus = {};

  @override
  Stream<Map<String, DownloadProgress>> get statusStream => _statusController.stream;

  MockDownloadProvider() : super(datadir: Directory(''), binaries: []) {
    // Initialize with a test status
    _binaryStatus['test-chain'] = DownloadProgress(
      binaryName: 'test-chain',
      status: DownloadStatus.notStarted,
    );
    _emitStatus();
  }

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
  }
}
