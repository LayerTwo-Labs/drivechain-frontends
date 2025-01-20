import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:get_it/get_it.dart';
import 'package:launcher/env.dart';
import 'package:launcher/services/wallet_service.dart';
import 'package:launcher/widgets/chain_settings_modal.dart';
import 'package:launcher/widgets/quotes_widget.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/providers/binary_provider.dart';
import 'package:sail_ui/sail_ui.dart';

@RoutePage()
class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  BinaryProvider get _binaryProvider => GetIt.I.get<BinaryProvider>();
  ProcessProvider get _processProvider => GetIt.I.get<ProcessProvider>();
  WalletService get _walletService => GetIt.I.get<WalletService>();
  Map<String, dynamic>? _chainConfig;

  bool _closeAlertOpen = false;

  @override
  void initState() {
    super.initState();
    _binaryProvider.addListener(_onBinaryProviderUpdate);
    _processProvider.addListener(_onBinaryProviderUpdate);
    _walletService.addListener(_onBinaryProviderUpdate);
    _loadChainConfig();
    FlutterWindowClose.setWindowShouldCloseHandler(() async {
      return await displayShutdownModal(context);
    });
  }

  Future<void> _loadChainConfig() async {
    try {
      final config = await rootBundle.loadString('assets/chain_config.json');
      setState(() {
        _chainConfig = jsonDecode(config) as Map<String, dynamic>;
      });
    } catch (e) {
      debugPrint('Error loading chain config: $e');
    }
  }

  @override
  void dispose() {
    _binaryProvider.removeListener(_onBinaryProviderUpdate);
    _processProvider.removeListener(_onBinaryProviderUpdate);
    _walletService.removeListener(_onBinaryProviderUpdate);
    super.dispose();
  }

  void _onBinaryProviderUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _downloadUninstalledL1Binaries(Map<String, DownloadState>? statusData) async {
    if (statusData == null) return;

    final uninstalledBinaries = _binaryProvider.binaries.where((b) => b.chainLayer == 1).where((b) {
      final status = statusData[b.name]?.status;
      return status == null || status == DownloadStatus.uninstalled || status == DownloadStatus.failed;
    });

    // Start downloads concurrently for uninstalled/failed binaries
    await Future.wait(
      uninstalledBinaries.map(
        (binary) => _binaryProvider.downloadBinary(binary),
      ),
    );
  }

  Future<void> _runL1(BuildContext context, Map<String, DownloadState>? statusData) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final log = GetIt.I.get<Logger>();
    final navigator = Navigator.of(context);
    log.i('Starting L1 binaries sequence');

    try {
      // First ensure all binaries are downloaded
      await _downloadUninstalledL1Binaries(statusData);

      // Ensure we have all required binaries
      final parentChain = _binaryProvider.binaries.whereType<ParentChain>().firstOrNull;
      final enforcer = _binaryProvider.binaries.whereType<Enforcer>().firstOrNull;
      final bitwindow = _binaryProvider.binaries.whereType<BitWindow>().firstOrNull;

      if (parentChain == null || enforcer == null || bitwindow == null) {
        throw Exception('could not find all required L1 binaries');
      }

      // 1. Start parent chain and wait for IBD
      if (!mounted) return;
      await _binaryProvider.startBinary(navigator.context, parentChain);
      if (_binaryProvider.mainchainRPC == null) {
        throw Exception('could not initialize mainchain RPC');
      }

      log.i('Waiting for mainchain to connect...');
      await _binaryProvider.mainchainRPC!.waitForIBD();
      log.i('Mainchain connected and synced');

      // 2. Start enforcer after mainchain is ready
      if (!mounted) return;
      await _binaryProvider.startBinary(navigator.context, enforcer);
      if (_binaryProvider.enforcerRPC == null) {
        throw Exception('could not initialize enforcer RPC');
      }
      log.i('Started enforcer');

      // 3. Start BitWindow after enforcer
      if (!mounted) return;
      await _binaryProvider.startBinary(navigator.context, bitwindow);
      if (_binaryProvider.bitwindowRPC == null) {
        throw Exception('could not initialize BitWindow RPC');
      }
      log.i('Started BitWindow');

      log.i('All L1 binaries started successfully');
    } catch (e) {
      log.e('Error starting L1 binaries: $e');
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Failed to start L1 binaries: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      rethrow; // Re-throw to indicate failure
    }
  }

  bool _shouldDisableDownloadAll(Map<String, DownloadState>? statusData) {
    if (statusData == null) return false;

    // Get L1 binaries
    final l1Binaries = _binaryProvider.binaries.where((b) => b.chainLayer == 1);

    // Check if any downloads are in progress
    final hasActiveDownloads = statusData.values.any((state) => state.status == DownloadStatus.installing);

    // Check if all L1 binaries are already installed
    final allInstalled = l1Binaries.every((b) => statusData[b.name]?.status == DownloadStatus.installed);

    return hasActiveDownloads || allInstalled;
  }

  Future<void> _handleBinaryDownload(BuildContext context, Binary binary) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    debugPrint('Starting download for ${binary.name}');
    await _binaryProvider.downloadBinary(binary);
    debugPrint('Download completed for ${binary.name}');

    if (binary.chainLayer == 2 && _chainConfig != null) {
      final chains = _chainConfig!['chains'] as List<dynamic>;
      for (final chain in chains) {
        if (chain['name'].toString().toLowerCase() == binary.name.toLowerCase() && chain['sidechain_slot'] != null) {
          final sidechainSlot = chain['sidechain_slot'] as int;
          debugPrint('Creating sidechain starter for slot $sidechainSlot');
          try {
            await _walletService.deriveSidechainStarter(sidechainSlot);
            debugPrint('Successfully created sidechain starter for slot $sidechainSlot');
          } catch (e) {
            debugPrint('Error creating sidechain starter: $e');
            // Show error to user
            if (mounted) {
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text('Failed to create sidechain starter: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return QtPage(
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: StreamBuilder<Map<String, DownloadState>>(
                  stream: _binaryProvider.statusStream,
                  builder: (context, statusSnapshot) {
                    final l1Chains = _binaryProvider.binaries.where((chain) => chain.chainLayer == 1).toList()
                      ..sort((a, b) => a.chainLayer.compareTo(b.chainLayer));
                    final l2Chains = _binaryProvider.binaries.where((chain) => chain.chainLayer == 2).toList();

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SailText.primary24('Layer 1'),
                                    Row(
                                      children: [
                                        SailButton.primary(
                                          'Boot Layer 1',
                                          onPressed: () => _runL1(context, statusSnapshot.data),
                                          size: ButtonSize.regular,
                                        ),
                                        const SizedBox(width: 8),
                                        SailButton.primary(
                                          'Download All',
                                          onPressed: () => _downloadUninstalledL1Binaries(statusSnapshot.data),
                                          size: ButtonSize.regular,
                                          disabled: _shouldDisableDownloadAll(statusSnapshot.data),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final availableWidth = constraints.maxWidth;
                                    final cardWidth = availableWidth >= 900
                                        ? (availableWidth - (3 * 16)) / 4 // 4 cards with 16px spacing
                                        : (availableWidth - 16) / 2; // 2 cards with 16px spacing

                                    return Wrap(
                                      spacing: 16.0,
                                      runSpacing: 16.0,
                                      children: l1Chains.map((chain) {
                                        final status = statusSnapshot.data?[chain.name];
                                        return SizedBox(
                                          width: cardWidth,
                                          child: SailRawCard(
                                            padding: true,
                                            child: _buildChainContent(chain, status),
                                          ),
                                        );
                                      }).toList(),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SailText.primary24('Layer 2'),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ...l2Chains.map((chain) {
                                  final status = statusSnapshot.data?[chain.name];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 8.0,
                                    ),
                                    child: SailRawCard(
                                      padding: true,
                                      child: _buildChainContent(chain, status),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const QuotesWidget(),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(bool connected, bool initializing, String? error) {
    final color = switch ((connected, initializing, error != null)) {
      (true, _, _) => Colors.green,
      (_, true, _) => Colors.orange,
      (_, _, true) => Colors.red,
      _ => Colors.grey,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(DownloadState? status) {
    if (status == null) return const SizedBox();

    if (status.status == DownloadStatus.installing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(value: status.progress),
          const SizedBox(height: 4),
          SailText.secondary13(status.message ?? ''),
        ],
      );
    }

    return const SizedBox();
  }

  Widget _buildActionButton(BuildContext context, Binary binary, DownloadState? status) {
    // Check if binary is running
    final isRunning = switch (binary) {
      var b when b is ParentChain => _binaryProvider.mainchainConnected,
      var b when b is Enforcer => _binaryProvider.enforcerConnected,
      var b when b is BitWindow => _binaryProvider.bitwindowConnected,
      var b when b is Thunder => _binaryProvider.thunderConnected,
      _ => false,
    };

    // Check if binary is initializing
    final isInitializing = switch (binary) {
      var b when b is ParentChain => _binaryProvider.mainchainInitializing,
      var b when b is Enforcer => _binaryProvider.enforcerInitializing,
      var b when b is BitWindow => _binaryProvider.bitwindowInitializing,
      var b when b is Thunder => _binaryProvider.thunderInitializing,
      _ => false,
    };

    if (isRunning) {
      return SailButton.secondary(
        'Stop',
        onPressed: () async {
          switch (binary) {
            case ParentChain():
              await _binaryProvider.mainchainRPC?.stop();
            case Enforcer():
              await _binaryProvider.enforcerRPC?.stop();
            case BitWindow():
              await _binaryProvider.bitwindowRPC?.stop();
            case Thunder():
              await _binaryProvider.thunderRPC?.stop();
          }
        },
        size: ButtonSize.regular,
      );
    }

    if (isInitializing) {
      return SailButton.primary(
        'Launching...',
        onPressed: () {}, // Disable button while initializing
        size: ButtonSize.regular,
        loading: true,
      );
    }

    if (status?.status == DownloadStatus.installed) {
      final canStart = _binaryProvider.canStart(binary);
      final dependencyMessage = _binaryProvider.getDependencyMessage(binary);

      return Tooltip(
        message: dependencyMessage ?? 'Launch ${binary.name}',
        child: SailButton.primary(
          'Launch',
          onPressed: () {
            final navigator = Navigator.of(context);
            _binaryProvider.startBinary(navigator.context, binary);
          },
          size: ButtonSize.regular,
          disabled: !canStart,
        ),
      );
    }

    if (status == null || status.status == DownloadStatus.uninstalled) {
      return SailButton.primary(
        'Download',
        onPressed: () => _handleBinaryDownload(context, binary),
        size: ButtonSize.regular,
      );
    }

    if (status.status == DownloadStatus.failed) {
      return SailButton.primary(
        'Retry',
        onPressed: () => _handleBinaryDownload(context, binary),
        size: ButtonSize.regular,
      );
    }

    return const SizedBox();
  }

  Widget _buildChainContent(Binary binary, DownloadState? status) {
    final theme = SailTheme.of(context);

    // Get RPC status based on binary type
    bool connected = false;
    bool initializing = false;
    String? error;

    switch (binary) {
      case ParentChain():
        connected = _binaryProvider.mainchainRPC?.connected ?? false;
        initializing = _binaryProvider.mainchainRPC?.initializingBinary ?? false;
        error = _binaryProvider.mainchainRPC?.connectionError;
      case Enforcer():
        connected = _binaryProvider.enforcerRPC?.connected ?? false;
        initializing = _binaryProvider.enforcerRPC?.initializingBinary ?? false;
        error = _binaryProvider.enforcerRPC?.connectionError;
      case BitWindow():
        connected = _binaryProvider.bitwindowRPC?.connected ?? false;
        initializing = _binaryProvider.bitwindowRPC?.initializingBinary ?? false;
        error = _binaryProvider.bitwindowRPC?.connectionError;
      case Thunder():
        connected = _binaryProvider.thunderRPC?.connected ?? false;
        initializing = _binaryProvider.thunderRPC?.initializingBinary ?? false;
        error = _binaryProvider.thunderRPC?.connectionError;
    }

    return Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SailText.primary24(
                  binary.name,
                  textAlign: TextAlign.left,
                ),
              ),
              IconButton(
                icon: Icon(Icons.settings, color: theme.colors.text, size: 20),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => ChainSettingsModal(chain: binary),
                  );
                },
              ),
              const SizedBox(width: 8),
              _buildStatusIndicator(connected, initializing, error),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            child: SailText.secondary13(
              binary.description,
              textAlign: TextAlign.left,
            ),
          ),
          const SizedBox(height: 12),
          _buildProgressIndicator(status),
          if (status?.error != null || error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: SailText.secondary13(
                status?.error ?? error!,
                color: Colors.red,
              ),
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActionButton(context, binary, status),
              if (binary.updateAvailable) ...[
                const SizedBox(width: 12),
                Center(
                  child: SailButton.primary(
                    'Update Now',
                    onPressed: () => _handleBinaryDownload(context, binary),
                    size: ButtonSize.regular,
                    disabled: status?.status == DownloadStatus.installing,
                  ),
                ),
              ],
              if (binary.chainLayer == 2) ...[
                const Spacer(),
                _buildWalletButton(binary, status),
              ] else if (binary.chainLayer == 1 && binary is ParentChain) ...[
                const Spacer(),
                _buildL1StarterButton(status),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildL1StarterButton(DownloadState? status) {
    // If binary not downloaded, show disabled button
    if (status?.status != DownloadStatus.installed) {
      return SailButton.secondary(
        '',
        onPressed: () {},
        size: ButtonSize.regular,
        disabled: true,
      );
    }

    return FutureBuilder<(bool, bool)>(
      future: _checkL1WalletFiles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData) return const SizedBox();

        final (hasMasterStarter, hasStarter) = snapshot.data!;

        if (!hasMasterStarter) {
          return SailButton.secondary(
            '',
            onPressed: () {},
            size: ButtonSize.regular,
            disabled: true,
          );
        }

        if (hasStarter) {
          return SailButton.secondary(
            'Delete Starter',
            onPressed: () => _deleteL1Starter(),
            size: ButtonSize.regular,
          );
        } else {
          return SailButton.primary(
            'Generate Starter',
            onPressed: () => _generateL1Starter(),
            size: ButtonSize.regular,
          );
        }
      },
    );
  }

  Future<(bool, bool)> _checkL1WalletFiles() async {
    final appDir = await Environment.appDir();
    final walletDir = Directory(path.join(appDir.path, 'wallet_starters'));
    final masterFile = File(path.join(walletDir.path, 'master_starter.json'));
    final l1File = File(path.join(walletDir.path, 'l1_starter.json'));

    return (masterFile.existsSync(), l1File.existsSync());
  }

  Future<void> _deleteL1Starter() async {
    try {
      await _walletService.deleteL1Starter();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting starter: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _generateL1Starter() async {
    try {
      await _walletService.deriveL1Starter();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating starter: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildWalletButton(Binary binary, DownloadState? status) {
    // If binary not downloaded or in a failed state, show disabled button
    if (status == null || status.status == DownloadStatus.uninstalled || status.status == DownloadStatus.failed) {
      return SailButton.secondary(
        '',
        onPressed: () {},
        size: ButtonSize.regular,
        disabled: true,
      );
    }

    // Find sidechain slot from config
    int? sidechainSlot;
    if (_chainConfig != null) {
      final chains = _chainConfig!['chains'] as List<dynamic>;
      for (final chain in chains) {
        if (chain['name'].toString().toLowerCase() == binary.name.toLowerCase()) {
          sidechainSlot = chain['sidechain_slot'] as int?;
          break;
        }
      }
    }

    if (sidechainSlot == null) {
      return const SizedBox(); // Hide button if no slot found
    }

    return FutureBuilder<(bool, bool)>(
      future: _checkWalletFiles(sidechainSlot),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData) return const SizedBox();

        final (hasMasterStarter, hasStarter) = snapshot.data!;

        if (!hasMasterStarter) {
          return SailButton.secondary(
            '',
            onPressed: () {},
            size: ButtonSize.regular,
            disabled: true,
          );
        }

        if (hasStarter) {
          return SailButton.secondary(
            'Delete Starter',
            onPressed: () => _deleteStarter(sidechainSlot!),
            size: ButtonSize.regular,
          );
        } else {
          return SailButton.primary(
            'Generate Starter',
            onPressed: () => _generateStarter(sidechainSlot!),
            size: ButtonSize.regular,
          );
        }
      },
    );
  }

  Future<(bool, bool)> _checkWalletFiles(int? sidechainSlot) async {
    if (sidechainSlot == null) return (false, false);

    final appDir = await Environment.appDir();
    final walletDir = Directory(path.join(appDir.path, 'wallet_starters'));
    final masterFile = File(path.join(walletDir.path, 'master_starter.json'));
    final starterFile = File(path.join(walletDir.path, 'sidechain_${sidechainSlot}_starter.json'));

    return (masterFile.existsSync(), starterFile.existsSync());
  }

  Future<void> _deleteStarter(int sidechainSlot) async {
    try {
      final appDir = await Environment.appDir();
      final walletDir = Directory(path.join(appDir.path, 'wallet_starters'));
      final starterFile = File(path.join(walletDir.path, 'sidechain_${sidechainSlot}_starter.json'));
      await starterFile.delete();
      setState(() {}); // Refresh UI
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting starter: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _generateStarter(int sidechainSlot) async {
    try {
      await _walletService.deriveSidechainStarter(sidechainSlot);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating starter: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> displayShutdownModal(
    BuildContext context,
  ) async {
    if (_closeAlertOpen) return false;
    _closeAlertOpen = true;

    var processesExited = Completer<bool>();
    unawaited(_processProvider.shutdown().then((_) => processesExited.complete(true)));

    if (!mounted) return true;

    unawaited(
      widgetDialog(
        context: context,
        title: 'Shutdown status',
        subtitle: 'Shutting down nodes...',
        child: SailColumn(
          spacing: SailStyleValues.padding20,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SailSpacing(SailStyleValues.padding08),
            SailRow(
              spacing: SailStyleValues.padding12,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _processProvider.runningProcesses.entries.map((entry) {
                return ShutdownCard(
                  chain: Binary.fromBinary(entry.value.binary)!,
                  initializing: true,
                  message: 'with pid ${entry.value.pid}',
                  forceCleanup: () => entry.value.cleanup(),
                );
              }).toList(),
            ),
            const SailSpacing(SailStyleValues.padding10),
            SailRow(
              spacing: SailStyleValues.padding12,
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: [
                SailButton.primary(
                  'Force close',
                  onPressed: () {
                    processesExited.complete(true);
                    Navigator.of(context).pop(true);
                    _closeAlertOpen = false;
                  },
                  size: ButtonSize.regular,
                ),
              ],
            ),
          ],
        ),
      ),
    );

    await processesExited.future;
    return true;
  }
}
