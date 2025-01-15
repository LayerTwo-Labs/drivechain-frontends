import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:launcher/services/configuration_service.dart';
import 'package:launcher/services/resource_downloader.dart';

/// Manages the overall download process for all components
class DownloadManager {
  final ConfigurationService _configService;
  final ResourceDownloader _downloader;

  // Stream controller for overall download status
  final _statusController = StreamController<Map<String, DownloadProgress>>.broadcast();
  Stream<Map<String, DownloadProgress>> get statusStream => _statusController.stream;

  // Track status of all components
  final Map<String, DownloadProgress> _componentStatus = {};

  DownloadManager({
    ConfigurationService? configService,
    ResourceDownloader? downloader,
  })  : _configService = configService ?? GetIt.I<ConfigurationService>(),
        _downloader = downloader ?? ResourceDownloader() {
    // Listen to individual download progress updates
    _downloader.progressStream.listen(_handleProgressUpdate);
  }

  /// Initialize the download manager
  Future<void> initialize() async {
    // Initialize all components with "not started" status
    for (final chain in _configService.configs.chains) {
      _componentStatus[chain.id] = DownloadProgress(
        componentId: chain.id,
        status: DownloadStatus.notStarted,
      );
    }
    _emitStatus();
  }

  /// Download all required components
  Future<bool> downloadAllComponents() async {
    bool success = true;

    // Download L1 components first
    final l1Chains = _configService.getL1Chains();
    for (final chain in l1Chains) {
      if (!await _downloader.downloadComponent(chain)) {
        success = false;
        break;
      }
    }

    // Then download L2 components if L1 was successful
    if (success) {
      final l2Chains = _configService.getL2Chains();
      for (final chain in l2Chains) {
        if (!await _downloader.downloadComponent(chain)) {
          success = false;
          break;
        }
      }
    }

    return success;
  }

  /// Download a specific component by ID
  Future<bool> downloadComponent(String componentId) async {
    final config = _configService.getChainConfig(componentId);
    if (config == null) {
      _componentStatus[componentId] = DownloadProgress(
        componentId: componentId,
        status: DownloadStatus.failed,
        error: 'Component not found',
      );
      _emitStatus();
      return false;
    }

    return await _downloader.downloadComponent(config);
  }

  /// Check if all required components are downloaded
  Future<bool> verifyAllComponents() async {
    bool allValid = true;

    for (final chain in _configService.configs.chains) {
      final binaryPath = _configService.getBinaryPath(chain.id);
      if (binaryPath == null) {
        allValid = false;
        _componentStatus[chain.id] = DownloadProgress(
          componentId: chain.id,
          status: DownloadStatus.failed,
          error: 'Invalid binary path',
        );
        continue;
      }

      if (!await _verifyComponent(chain.id, binaryPath)) {
        allValid = false;
      }
    }

    _emitStatus();
    return allValid;
  }

  /// Verify a specific component
  Future<bool> verifyComponent(String componentId) async {
    final binaryPath = _configService.getBinaryPath(componentId);
    if (binaryPath == null) {
      _componentStatus[componentId] = DownloadProgress(
        componentId: componentId,
        status: DownloadStatus.failed,
        error: 'Invalid binary path',
      );
      _emitStatus();
      return false;
    }

    return await _verifyComponent(componentId, binaryPath);
  }

  /// Internal helper to verify a component
  Future<bool> _verifyComponent(String componentId, String binaryPath) async {
    try {
      if (await _downloader.verifyBinary(binaryPath)) {
        _componentStatus[componentId] = DownloadProgress(
          componentId: componentId,
          status: DownloadStatus.completed,
          progress: 1.0,
        );
        _emitStatus();
        return true;
      } else {
        _componentStatus[componentId] = DownloadProgress(
          componentId: componentId,
          status: DownloadStatus.failed,
          error: 'Binary verification failed',
        );
        _emitStatus();
        return false;
      }
    } catch (e) {
      _componentStatus[componentId] = DownloadProgress(
        componentId: componentId,
        status: DownloadStatus.failed,
        error: e.toString(),
      );
      _emitStatus();
      return false;
    }
  }

  /// Handle progress updates from the downloader
  void _handleProgressUpdate(DownloadProgress progress) {
    _componentStatus[progress.componentId] = progress;
    _emitStatus();
  }

  /// Emit current status to listeners
  void _emitStatus() {
    _statusController.add(Map.from(_componentStatus));
  }

  /// Get current status for a component
  DownloadProgress? getComponentStatus(String componentId) {
    return _componentStatus[componentId];
  }

  /// Get current status for all components
  Map<String, DownloadProgress> getAllComponentStatus() {
    return Map.from(_componentStatus);
  }

  /// Dispose of resources
  void dispose() {
    _statusController.close();
    _downloader.dispose();
  }
}
