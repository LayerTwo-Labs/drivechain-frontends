import 'dart:async';
import 'package:launcher/services/download_manager.dart';
import 'package:launcher/services/resource_downloader.dart';

class MockDownloadManager extends DownloadManager {
  final _statusController = StreamController<Map<String, DownloadProgress>>.broadcast();
  final Map<String, DownloadProgress> _componentStatus = {};

  @override
  Stream<Map<String, DownloadProgress>> get statusStream => _statusController.stream;

  MockDownloadManager() : super(configService: null, downloader: null) {
    // Initialize with a test status
    _componentStatus['test-chain'] = DownloadProgress(
      componentId: 'test-chain',
      status: DownloadStatus.notStarted,
    );
    _emitStatus();
  }

  @override
  Future<void> initialize() async {
    // No-op for tests
  }

  @override
  Future<bool> downloadComponent(String componentId) async {
    _componentStatus[componentId] = DownloadProgress(
      componentId: componentId,
      status: DownloadStatus.completed,
      progress: 1.0,
    );
    _emitStatus();
    return true;
  }

  @override
  Future<bool> verifyComponent(String componentId) async {
    return true;
  }

  void _emitStatus() {
    _statusController.add(Map.from(_componentStatus));
  }

  @override
  void dispose() {
    _statusController.close();
  }
}