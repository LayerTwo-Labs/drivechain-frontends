import 'dart:async';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/config/sidechains.dart';
import 'package:sail_ui/env.dart';
import 'package:sail_ui/providers/process_provider.dart';
import 'package:sail_ui/rpcs/bitassets_rpc.dart';
import 'package:sail_ui/rpcs/bitnames_rpc.dart';
import 'package:sail_ui/rpcs/bitwindow_api.dart';
import 'package:sail_ui/rpcs/enforcer_rpc.dart';
import 'package:sail_ui/rpcs/mainchain_rpc.dart';
import 'package:sail_ui/rpcs/thunder_rpc.dart';
import 'package:sail_ui/rpcs/zcash_rpc.dart';
import 'package:sail_ui/utils/file_utils.dart';

/// Manages downloads and installations of binaries
class BinaryProvider extends ChangeNotifier {
  final log = Logger(level: Level.info);
  final Directory appDir;

  final _processProvider = GetIt.I.get<ProcessProvider>();
  final mainchainRPC = GetIt.I.get<MainchainRPC>();
  final enforcerRPC = GetIt.I.get<EnforcerRPC>();

  late final BitwindowRPC? bitwindowRPC;
  late final ThunderRPC? thunderRPC;
  late final BitnamesRPC? bitnamesRPC;
  late final BitAssetsRPC? bitassetsRPC;
  late final ZCashRPC? zcashRPC;
  late final DownloadManager downloadManager;

  // Track starter usage for L2 chains
  final Map<String, bool> _useStarter = {};
  bool shouldUseStarter(Binary binary) => _useStarter[binary.name] ?? false;
  void setUseStarter(Binary binary, bool value) {
    _useStarter[binary.name] = value;
    notifyListeners();
  }

  // Connection status getters
  bool get mainchainConnected => mainchainRPC.connected;
  bool get enforcerConnected => enforcerRPC.connected;
  bool get bitwindowConnected => bitwindowRPC?.connected ?? false;
  bool get thunderConnected => thunderRPC?.connected ?? false;
  bool get bitnamesConnected => bitnamesRPC?.connected ?? false;
  bool get bitassetsConnected => bitassetsRPC?.connected ?? false;
  bool get zcashConnected => zcashRPC?.connected ?? false;

  bool get mainchainInitializing => mainchainRPC.initializingBinary;
  bool get enforcerInitializing => enforcerRPC.initializingBinary;
  bool get bitwindowInitializing => bitwindowRPC?.initializingBinary ?? false;
  bool get thunderInitializing => thunderRPC?.initializingBinary ?? false;
  bool get bitnamesInitializing => bitnamesRPC?.initializingBinary ?? false;
  bool get bitassetsInitializing => bitassetsRPC?.initializingBinary ?? false;
  bool get zcashInitializing => zcashRPC?.initializingBinary ?? false;

  bool get mainchainStopping => mainchainRPC.stoppingBinary;
  bool get enforcerStopping => enforcerRPC.stoppingBinary;
  bool get bitwindowStopping => bitwindowRPC?.stoppingBinary ?? false;
  bool get thunderStopping => thunderRPC?.stoppingBinary ?? false;
  bool get bitnamesStopping => bitnamesRPC?.stoppingBinary ?? false;
  bool get bitassetsStopping => bitassetsRPC?.stoppingBinary ?? false;
  bool get zcashStopping => zcashRPC?.stoppingBinary ?? false;

  // Only show errors for explicitly launched binaries
  String? get mainchainError => mainchainRPC.connectionError;
  String? get enforcerError => enforcerRPC.connectionError;
  String? get bitwindowError => bitwindowRPC?.connectionError;
  String? get thunderError => thunderRPC?.connectionError;
  String? get bitnamesError => bitnamesRPC?.connectionError;
  String? get bitassetsError => bitassetsRPC?.connectionError;
  String? get zcashError => zcashRPC?.connectionError;

  // Only show errors for explicitly launched binaries
  String? get mainchainStartupError => mainchainRPC.startupError;
  String? get enforcerStartupError => enforcerRPC.startupError;
  String? get bitwindowStartupError => bitwindowRPC?.startupError;
  String? get thunderStartupError => thunderRPC?.startupError;
  String? get bitnamesStartupError => bitnamesRPC?.startupError;
  String? get bitassetsStartupError => bitassetsRPC?.startupError;
  String? get zcashStartupError => zcashRPC?.startupError;

  bool get inIBD => mainchainRPC.inIBD;
  // let the download manager handle all binary stuff. Only it does updates!
  List<Binary> get binaries => downloadManager.binaries;

  BinaryProvider({
    required this.appDir,
    required List<Binary> initialBinaries,
  }) {
    downloadManager = DownloadManager(
      appDir: appDir,
      initialBinaries: initialBinaries,
    );

    // Forward DownloadManager notifications to BinaryProvider listeners
    downloadManager.addListener(notifyListeners);
    _processProvider.addListener(notifyListeners);
    mainchainRPC.addListener(notifyListeners);
    enforcerRPC.addListener(notifyListeners);

    // Then try to register optional RPCs
    try {
      bitwindowRPC = GetIt.I.get<BitwindowRPC>();
      bitwindowRPC?.addListener(notifyListeners);
    } catch (_) {
      bitwindowRPC = null;
    }

    try {
      thunderRPC = GetIt.I.get<ThunderRPC>();
      thunderRPC?.addListener(notifyListeners);
    } catch (_) {
      thunderRPC = null;
    }

    try {
      bitnamesRPC = GetIt.I.get<BitnamesRPC>();
      bitnamesRPC?.addListener(notifyListeners);
    } catch (_) {
      bitnamesRPC = null;
    }

    try {
      bitassetsRPC = GetIt.I.get<BitAssetsRPC>();
      bitassetsRPC?.addListener(notifyListeners);
    } catch (_) {
      bitassetsRPC = null;
    }

    try {
      zcashRPC = GetIt.I.get<ZCashRPC>();
      zcashRPC?.addListener(notifyListeners);
    } catch (_) {
      zcashRPC = null;
    }
  }

  /// Get all L1 chain configurations
  List<Binary> getL1Chains() {
    return binaries.where((chain) => chain.chainLayer == 1).toList();
  }

  /// Get all L2 chain configurations
  List<Binary> getL2Chains() {
    return binaries.where((chain) => chain.chainLayer == 2).toList();
  }

  /// Check if a binary can be started based on its dependencies
  String? canStart(Binary binary) {
    final mainchainReady = mainchainConnected && !mainchainRPC.inHeaderSync;
    return switch (binary) {
      Enforcer() => mainchainReady ? null : 'Mainchain must be started and headers synced before starting Enforcer',
      BitWindow() => enforcerConnected && mainchainReady
          ? null
          : 'Mainchain and Enforcer must be running and headers synced before starting BitWindow',
      Thunder() => enforcerConnected && mainchainReady
          ? null
          : 'Mainchain and Enforcer must be running and headers synced before starting Thunder',
      Bitnames() => enforcerConnected && mainchainReady
          ? null
          : 'Mainchain and Enforcer must be running and headers synced before starting Bitnames',
      BitAssets() => enforcerConnected && mainchainReady
          ? null
          : 'Mainchain and Enforcer must be running and headers synced before starting BitAssets',
      ZCash() => enforcerConnected && mainchainReady
          ? null
          : 'Mainchain and Enforcer must be running and headers synced before starting ZCash',
      _ => null, // No requirements for mainchain
    };
  }

  // Start a binary, and set starter seeds (if set)
  Future<void> startBinary(
    Binary binary, {
    bool useStarter = false,
  }) async {
    if (binary is Thunder || binary is Bitnames || binary is BitAssets) {
      binary = binary as Sidechain;
      // We're booting some sort of sidechain. Check the launcher-directory for
      // a starter seed
      final mnemonicPath = binary.getMnemonicPath(appDir);
      if (mnemonicPath != null) {
        binary.addBootArg('--mnemonic-seed-phrase-path=$mnemonicPath');
      }
    }

    switch (binary) {
      case ParentChain():
        await mainchainRPC.initBinary();

      case Enforcer():
        await enforcerRPC.initBinary();

      case BitWindow():
        await bitwindowRPC?.initBinary();

      case Thunder():
        await thunderRPC?.initBinary();

      case Bitnames():
        await bitnamesRPC?.initBinary();

      case BitAssets():
        await bitassetsRPC?.initBinary();

      case ZCash():
        await zcashRPC?.initBinary();

      default:
        log.i('is $binary');
    }
    // Wait for connection or timeout
    await Future.any([
      () async {
        while (!_isConnected(binary)) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }(),
      Future.delayed(const Duration(seconds: 60)),
    ]);

    log.i('${binary.name} started successfully');
    notifyListeners();
  }

  bool _isConnected(Binary binary) {
    return switch (binary) {
      ParentChain() => mainchainConnected,
      Enforcer() => enforcerConnected,
      BitWindow() => bitwindowConnected,
      Thunder() => thunderConnected,
      Bitnames() => bitnamesConnected,
      ZCash() => zcashConnected,
      _ => false,
    };
  }

  /// Download a binary using the DownloadProvider
  Future<void> downloadBinary(Binary binary) async {
    await downloadManager.downloadBinary(binary);
  }

  Future<void> stop(Binary binary) async {
    switch (binary) {
      case ParentChain():
        await mainchainRPC.stop();
      case Enforcer():
        await enforcerRPC.stop();
      case BitWindow():
        await bitwindowRPC?.stop();
      case Thunder():
        await thunderRPC?.stop();
      case Bitnames():
        await bitnamesRPC?.stop();
      case BitAssets():
        await bitassetsRPC?.stop();
      case ZCash():
        await zcashRPC?.stop();
    }
  }

  /// Get download progress for a binary
  DownloadInfo getDownloadProgress(Binary binary) => downloadManager.getProgress(binary.name);

  bool isRunning(Binary binary) {
    return switch (binary) {
      var b when b is ParentChain => mainchainConnected,
      var b when b is Enforcer => enforcerConnected,
      var b when b is BitWindow => bitwindowConnected,
      var b when b is Thunder => thunderConnected,
      var b when b is Bitnames => bitnamesConnected,
      var b when b is BitAssets => bitassetsConnected,
      var b when b is ZCash => zcashConnected,
      _ => false,
    };
  }

  bool isInitializing(Binary binary) {
    return switch (binary) {
      var b when b is ParentChain => mainchainInitializing,
      var b when b is Enforcer => enforcerInitializing,
      var b when b is BitWindow => bitwindowInitializing,
      var b when b is Thunder => thunderInitializing,
      var b when b is Bitnames => bitnamesInitializing,
      var b when b is BitAssets => bitassetsInitializing,
      var b when b is ZCash => zcashInitializing,
      _ => false,
    };
  }

  bool isStopping(Binary binary) {
    return switch (binary) {
      var b when b is ParentChain => mainchainStopping,
      var b when b is Enforcer => enforcerStopping,
      var b when b is BitWindow => bitwindowStopping,
      var b when b is Thunder => thunderStopping,
      var b when b is Bitnames => bitnamesStopping,
      var b when b is BitAssets => bitassetsStopping,
      var b when b is ZCash => zcashStopping,
      _ => false,
    };
  }

  bool isProcessRunning(Binary binary) {
    return switch (binary) {
      var b when b is ParentChain => _processProvider.isRunning(ParentChain()),
      var b when b is Enforcer => _processProvider.isRunning(Enforcer()),
      var b when b is BitWindow => _processProvider.isRunning(BitWindow()),
      var b when b is Thunder => _processProvider.isRunning(Thunder()),
      var b when b is Bitnames => _processProvider.isRunning(Bitnames()),
      var b when b is BitAssets => _processProvider.isRunning(BitAssets()),
      var b when b is ZCash => _processProvider.isRunning(ZCash()),
      _ => false,
    };
  }

  Future<void> downloadThenBootBinary(
    Binary binaryToBoot, {
    bool bootAllNoMatterWhat = false,
  }) async {
    final log = GetIt.I.get<Logger>();
    final startTime = DateTime.now();
    int getElapsed() => DateTime.now().difference(startTime).inMilliseconds;

    log.i('[T+0ms] STARTUP: Booting L1 binaries + ${binaryToBoot.name}');

    await downloadManager.ensureAllBinariesDownloaded(binaryToBoot);

    log.i('[T+${getElapsed()}ms] STARTUP: Ensuring all binaries are downloaded');

    // Ensure we have all required binaries
    final parentChain = binaries.whereType<ParentChain>().firstOrNull;
    final enforcer = binaries.whereType<Enforcer>().firstOrNull;

    if (parentChain == null || enforcer == null) {
      throw Exception('could not find all required L1 binaries');
    }

    if (bootAllNoMatterWhat) {
      // 2.1. If we're told to boot no matter what, any extra connection should go instantly
      log.i('[T+${getElapsed()}ms] STARTUP: Starting ${binaryToBoot.name}');
      unawaited(
        startBinary(
          binaryToBoot,
          useStarter: false,
        ),
      );
    }

    // 1. Start parent chain and wait for IBD
    // parent chain does not need to be restarted on crash, it's very stable
    await startBinary(parentChain, useStarter: false);

    log.i('[T+${getElapsed()}ms] STARTUP: Waiting for mainchain to connect and sync headers...');
    await mainchainRPC.waitForHeaderSync();
    log.i('[T+${getElapsed()}ms] STARTUP: Mainchain headers synced, starting enforcer');

    // 2. Start rest after mainchain is ready
    await startBinary(
      enforcer,
      useStarter: false,
    );
    log.i('[T+${getElapsed()}ms] STARTUP: Started enforcer');

    if (!bootAllNoMatterWhat) {
      // 3. Start whatever binary we were told to boot after enforcer
      await startBinary(
        binaryToBoot,
        useStarter: false,
      );
      log.i('[T+${getElapsed()}ms] STARTUP: Started ${binaryToBoot.name}');
    }

    log.i('[T+${getElapsed()}ms] STARTUP: All binaries started successfully');
  }

  @override
  void dispose() {
    downloadManager.removeListener(notifyListeners);
    mainchainRPC.removeListener(notifyListeners);
    enforcerRPC.removeListener(notifyListeners);
    bitwindowRPC?.removeListener(notifyListeners);
    thunderRPC?.removeListener(notifyListeners);
    bitnamesRPC?.removeListener(notifyListeners);
    bitassetsRPC?.removeListener(notifyListeners);
    zcashRPC?.removeListener(notifyListeners);
    downloadManager.dispose();
    super.dispose();
  }

  // Add status stream for download progress
  Stream<Map<String, DownloadInfo>> get statusStream {
    return downloadManager.progressStream;
  }
}

Future<List<Binary>> loadBinaryCreationTimestamp(List<Binary> binaries, Directory appDir) async {
  for (var i = 0; i < binaries.length; i++) {
    final binary = binaries[i];
    try {
      // Load metadata from bin/
      final (lastModified, binaryFile) = await binary.getCreationDate(appDir);

      final updatedConfig = binary.metadata.copyWith(
        remoteTimestamp: binary.metadata.remoteTimestamp,
        downloadedTimestamp: lastModified,
        binaryPath: binaryFile,
      );
      binaries[i] = binary.copyWith(metadata: updatedConfig);
    } catch (e) {
      // Log error but continue with other binaries
      GetIt.I.get<Logger>().e('Error loading binary state for ${binary.name}: $e');
    }
  }

  return binaries;
}

/// Manager responsible for downloading and extracting binaries to
/// the right place
class DownloadManager extends ChangeNotifier {
  final log = Logger(level: Level.info);
  final Directory appDir;
  late List<Binary> binaries;
  StreamSubscription<FileSystemEvent>? _dirWatcher;
  Timer? _releaseCheckTimer;

  DownloadManager({
    required this.appDir,
    required List<Binary> initialBinaries,
  }) {
    binaries = initialBinaries;

    // Set up periodic release date checks
    if (!Environment.isInTest) {
      _releaseCheckTimer = Timer.periodic(
        const Duration(minutes: 1),
        (_) => _checkReleaseDates(),
      );

      _setupDirectoryWatcher();
      _checkReleaseDates();
    }
  }

  void _updateBinary(String name, Binary Function(Binary) updater) {
    final index = binaries.indexWhere((b) => b.name == name);
    binaries[index] = updater(binaries[index]);
    notifyListeners();
  }

  void _setupDirectoryWatcher() {
    // Watch the assets directory for changes
    final assetsDir = Directory(path.join(appDir.path, 'bin'));
    _dirWatcher = assetsDir.watch(recursive: true).listen((event) async {
      switch (event.type) {
        case FileSystemEvent.create:
        case FileSystemEvent.delete:
          // Always reload metadata and notify when files change
          binaries = await loadBinaryCreationTimestamp(binaries, appDir);
          notifyListeners(); // Notify immediately after metadata reload
          break;
        default:
          break;
      }
    });
  }

  Future<void> _checkReleaseDates() async {
    for (var i = 0; i < binaries.length; i++) {
      try {
        final binary = binaries[i];
        final serverReleaseDate = await checkReleaseDate(binary);
        if (serverReleaseDate != null) {
          final updatedConfig = binary.metadata.copyWith(
            remoteTimestamp: serverReleaseDate,
            downloadedTimestamp: binary.metadata.downloadedTimestamp,
            binaryPath: binary.metadata.binaryPath,
          );
          binaries[i] = binary.copyWith(metadata: updatedConfig);

          // Notify immediately after each binary update
          notifyListeners();
        }
      } catch (e) {
        log.e('Error checking release date: $e');
        // Still notify even on error so UI can update error states
        notifyListeners();
      }
    }
  }

  /// Check the Last-Modified header for a binary without downloading
  Future<DateTime?> checkReleaseDate(Binary binary) async {
    try {
      final os = getOS();
      final fileName = binary.metadata.files[os]!;
      final downloadUrl = Uri.parse(binary.metadata.baseUrl).resolve(fileName).toString();

      final client = HttpClient();

      final request = await client.headUrl(Uri.parse(downloadUrl));
      final response = await request.close();

      if (response.statusCode != 200) {
        log.w('Warning: Could not check release date for ${binary.name}: HTTP ${response.statusCode}');
        return null;
      }

      final lastModified = response.headers.value('last-modified');
      if (lastModified == null) {
        log.w('Warning: No Last-Modified header for ${binary.name}');
        return null;
      }

      final releaseDate = HttpDate.parse(lastModified);
      return releaseDate;
    } catch (e) {
      log.w('Warning: Failed to check release date for ${binary.name}: $e');
      return null;
    }
  }

  bool isDownloading(Binary binary) {
    return binary.downloadInfo.progress > 0.0 && binary.downloadInfo.progress < 1.0;
  }

  DownloadInfo getProgress(String binaryName) {
    final binary = binaries.firstWhere((b) => b.name == binaryName);
    return binary.downloadInfo;
  }

  /// Download and extract a binary
  Future<void> downloadBinary(Binary binary) async {
    // Check if already downloading
    if (isDownloading(binary)) {
      log.w('Download already in progress for ${binary.name}');
      return;
    }

    try {
      await _downloadAndExtractBinary(binary);
      _updateBinary(
        binary.name,
        (b) => b.copyWith(
          downloadInfo: const DownloadInfo(progress: 1.0, message: 'Download completed'),
        ),
      );
      log.i('Successfully downloaded and extracted ${binary.name}');
    } catch (e) {
      _updateBinary(
        binary.name,
        (b) => b.copyWith(
          downloadInfo: DownloadInfo(progress: 0.0, error: 'Download failed: $e'),
        ),
      );
      log.e('Download failed for ${binary.name}: $e');
      rethrow;
    }
  }

  /// Download multiple binaries concurrently
  Future<void> downloadBinaries(List<Binary> binaries) async {
    // Immediately update download info for all binaries to indicate download is starting
    for (final binary in binaries) {
      _updateBinary(
        binary.name,
        (b) => b.copyWith(
          downloadInfo: const DownloadInfo(progress: 0.0, message: 'Initiating download...'),
        ),
      );
    }

    // This will trigger the SyncProgressProvider to update immediately
    notifyListeners();

    await Future.wait(
      binaries.map((binary) => downloadBinary(binary)),
    );
  }

  /// Internal method to handle the actual download and extraction
  Future<void> _downloadAndExtractBinary(Binary binary) async {
    // 1. Setup directories
    final downloadsDir = Directory(path.join(appDir.path, 'downloads'));
    final extractDir = binDir(appDir.path);
    await downloadsDir.create(recursive: true);
    await extractDir.create(recursive: true);

    // 2. Download the binary
    final zipName = binary.metadata.files[OS.current]!;
    final zipPath = path.join(downloadsDir.path, zipName);
    final downloadUrl = Uri.parse(binary.metadata.baseUrl).resolve(zipName).toString();
    await _downloadFile(downloadUrl, zipPath, binary.name);

    // 3. Extract
    await _extractBinary(extractDir, zipPath, downloadsDir, binary);

    final releaseDate = await checkReleaseDate(binary);
    // Update binary metadata
    final binaryPath = await binary.resolveBinaryPath(appDir);
    _updateBinary(
      binary.name,
      (b) => b.copyWith(
        metadata: b.metadata.copyWith(
          remoteTimestamp: releaseDate,
          downloadedTimestamp: releaseDate,
          binaryPath: binaryPath,
        ),
      ),
    );
  }

  /// Download a file
  Future<void> _downloadFile(String url, String savePath, String binaryName) async {
    log.i('_downloadFile started for $binaryName from $url');
    try {
      final client = HttpClient();
      log.i('Starting download from $url to $savePath');

      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();

      if (response.statusCode != 200) {
        throw Exception('HTTP Status ${response.statusCode}');
      }

      final file = File(savePath);
      final sink = file.openWrite();

      final totalBytes = response.contentLength;
      var receivedBytes = 0;
      String lastPercentStr = '';

      log.i('Download starting: totalBytes=$totalBytes, binaryName=$binaryName');

      await for (final chunk in response) {
        receivedBytes += chunk.length;
        sink.add(chunk);

        if (totalBytes != -1) {
          final progress = receivedBytes / totalBytes;
          final currentPercentStr = (progress * 100).toStringAsFixed(1);

          // Only update if the percentage display would change
          if (currentPercentStr != lastPercentStr) {
            final downloadedMB = (receivedBytes / 1024 / 1024).toStringAsFixed(1);
            final totalMB = (totalBytes / 1024 / 1024).toStringAsFixed(1);

            _updateBinary(
              binaryName,
              (b) => b.copyWith(
                downloadInfo: DownloadInfo(
                  progress: progress,
                  message: 'Downloaded $downloadedMB MB / $totalMB MB ($currentPercentStr%)',
                ),
              ),
            );

            lastPercentStr = currentPercentStr;
          }
        }
      }

      await sink.close();
      client.close();

      log.i('Download completed for $binaryName');
    } catch (e) {
      final error = 'Download failed from $url: $e\nSave path: $savePath';
      log.e('ERROR: $error');
      throw Exception(error);
    }
  }

  /// Extract binary archive
  Future<void> _extractBinary(
    Directory extractDir,
    String zipPath,
    Directory downloadsDir,
    Binary binary,
  ) async {
    // Create a temporary directory for extraction
    final tempDir = Directory(path.join(extractDir.path, 'temp', path.basenameWithoutExtension(binary.binary)));
    try {
      await tempDir.delete(recursive: true);
    } catch (e) {
      // directory probably doesn't exist, swallow!
    }
    await tempDir.create(recursive: true);

    final inputStream = InputFileStream(zipPath);
    final archive = ZipDecoder().decodeStream(inputStream);

    try {
      await extractArchiveToDisk(archive, tempDir.path);

      // Helper function to safely move files/directories
      Future<void> safeMove(FileSystemEntity entity, String newPath) async {
        log.d('Moving ${entity.path} to $newPath');
        try {
          await entity.rename(newPath);
        } on FileSystemException catch (e) {
          if (e.message.contains('Directory not empty') || e.message.contains('Rename failed')) {
            if (entity is File) {
              await File(newPath).delete();
              await entity.rename(newPath);
            } else {
              await Directory(newPath).delete(recursive: true);
              await entity.rename(newPath);
            }
          } else {
            log.e('Failed to move: ${e.message}');
            rethrow;
          }
        }
      }

      log.d('Moving files from temp directory to final location');
      await for (final entity in tempDir.list()) {
        final baseName = path.basename(entity.path);
        final targetPath = path.join(extractDir.path, baseName);

        if (entity is Directory && baseName == path.basenameWithoutExtension(zipPath)) {
          await for (final innerEntity in entity.list()) {
            await safeMove(innerEntity, path.join(extractDir.path, path.basename(innerEntity.path)));
          }
          await entity.delete(recursive: true);
          continue;
        }

        await safeMove(entity, targetPath);
      }

      // Clean up temp directory
      await tempDir.delete(recursive: true);

      // Get the zip name without extension
      final zipBaseName = path.basenameWithoutExtension(zipPath);
      final expectedDirPath = path.join(extractDir.path, zipBaseName);

      if (await Directory(expectedDirPath).exists()) {
        final innerDir = Directory(expectedDirPath);

        for (final entity in innerDir.listSync()) {
          final newPath = path.join(extractDir.path, path.basename(entity.path));
          await safeMove(entity, newPath);
        }
        await innerDir.delete(recursive: true);
      }

      // Clean up the filename: remove version numbers and platform specifics
      await for (final entity in extractDir.list(recursive: false)) {
        if (entity is File) {
          final fileName = path.basename(entity.path);

          // Skip non-executable files
          if (fileName.endsWith('.zip') || fileName.endsWith('.meta') || fileName.endsWith('.md')) continue;

          String targetName = fileName;

          // Remove platform specific parts
          final platformParts = [
            '-x86_64-apple-darwin',
            '-x86_64-linux',
            '-x86_64.exe',
            '-x86_64-unknown-linux-gnu',
            '-x86_64-pc-windows-gnu',
            'x86_64-unknown-linux-gnu',
            'x86_64-apple-darwin',
            'x86_64-pc-windows-gnu',
            '-latest',
          ];
          for (final part in platformParts) {
            targetName = targetName.replaceAll(part, '');
          }
          // Remove version numbers (matches patterns like -0.1.7- or -v1.2.3-)
          targetName = targetName.replaceAll(RegExp(r'-v?\d+\.\d+\.\d+-?'), '');

          if (fileName == targetName) {
            continue;
          }

          final newPath = path.join(path.dirname(entity.path), targetName);
          await safeMove(entity, newPath);
        }
      }
    } catch (e) {
      log.e('Extraction error: $e\nStack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<void> ensureAllBinariesDownloaded(Binary binaryToBoot) async {
    final log = GetIt.I.get<Logger>();
    log.i('Starting download of uninstalled binaries');

    var uninstalledBinaries = binaries.where((b) => b.chainLayer == 1 && !b.isDownloaded).toList();
    log.i('Found ${uninstalledBinaries.length} uninstalled L1 binaries');

    if (!binaryToBoot.isDownloaded) {
      log.i('Adding ${binaryToBoot.name} to download queue');
      uninstalledBinaries.add(binaryToBoot);
    }

    if (uninstalledBinaries.isEmpty) {
      log.i('No binaries to download');
      return;
    }

    // Use DownloadProvider for concurrent downloads
    log.i('Starting concurrent downloads for ${uninstalledBinaries.length} binaries');
    await downloadBinaries(uninstalledBinaries);
    log.i('Completed all binary downloads');
  }

  Stream<Map<String, DownloadInfo>> get progressStream {
    return Stream.periodic(const Duration(milliseconds: 500), (_) {
      return Map.fromEntries(
        binaries.map((b) => MapEntry(b.name, b.downloadInfo)),
      );
    });
  }

  @override
  void dispose() {
    _dirWatcher?.cancel();
    _releaseCheckTimer?.cancel();
    super.dispose();
  }
}

Directory binDir(String appDir) => Directory(path.join(appDir, 'bin'));
