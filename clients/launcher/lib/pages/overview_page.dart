import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:get_it/get_it.dart';
import 'package:launcher/services/wallet_service.dart';
import 'package:launcher/widgets/chain_settings_modal.dart';
import 'package:launcher/widgets/quotes_widget.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/providers/binary_provider.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:launcher/env.dart';

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

  // Add state for starter usage
  final Map<String, bool> _useStarter = {};

  @override
  void initState() {
    super.initState();

    // Initialize starter state
    for (final binary in GetIt.I.get<BinaryProvider>().binaries) {
      if (binary.chainLayer == 2) {
        _useStarter[binary.name] = true;
      }
    }

    // Add all listeners and initialization after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _binaryProvider.addListener(_onBinaryProviderUpdate);
      _processProvider.addListener(_onBinaryProviderUpdate);
      _walletService.addListener(_onBinaryProviderUpdate);
      _loadChainConfig();
      FlutterWindowClose.setWindowShouldCloseHandler(() async {
        return await displayShutdownModal(context);
      });
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
      await _binaryProvider.startBinary(navigator.context, parentChain, useStarter: false);
      if (_binaryProvider.mainchainRPC == null) {
        throw Exception('could not initialize mainchain RPC');
      }

      log.i('Waiting for mainchain to connect...');
      await _binaryProvider.mainchainRPC!.waitForIBD();
      log.i('Mainchain connected and synced');

      // 2. Start enforcer after mainchain is ready
      if (!mounted) return;
      await _binaryProvider.startBinary(navigator.context, enforcer, useStarter: false);
      if (_binaryProvider.enforcerRPC == null) {
        throw Exception('could not initialize enforcer RPC');
      }
      log.i('Started enforcer');

      // 3. Start BitWindow after enforcer
      if (!mounted) return;
      await _binaryProvider.startBinary(navigator.context, bitwindow, useStarter: false);
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
            backgroundColor: SailColorScheme.red,
          ),
        );
      }
      rethrow; // Re-throw to indicate failure
    }
  }

  Future<void> _updateBinary(Binary binary) async {
    await _stopBinary(binary);
    await _binaryProvider.downloadBinary(binary);
  }

  Future<void> _handleBinaryDownload(BuildContext context, Binary binary) async {
    // Store all context values before async operations
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final chainConfig = _chainConfig; // Store config reference
    
    try {
      await _binaryProvider.downloadBinary(binary);
      debugPrint('Download completed for ${binary.name}');

      if (!mounted) return;

      if (binary.chainLayer == 2 && chainConfig != null) {
        final chains = chainConfig['chains'] as List<dynamic>;
        for (final chain in chains) {
          if (chain['name'].toString().toLowerCase() == binary.name.toLowerCase() && chain['sidechain_slot'] != null) {
            final sidechainSlot = chain['sidechain_slot'] as int;
            try {
              await _walletService.deriveSidechainStarter(sidechainSlot);
              debugPrint('Successfully created sidechain starter for slot $sidechainSlot');
            } catch (e) {
              debugPrint('Error creating sidechain starter: $e');
              if (!mounted) return;
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text('Failed to create sidechain starter: $e'),
                  backgroundColor: SailColorScheme.red,
                ),
              );
            }
            break;
          }
        }
      }
    } catch (e) {
      debugPrint('Error downloading binary: $e');
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Failed to download binary: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _starterExists(Binary binary) async {
    if (binary.chainLayer != 2 || _chainConfig == null) {
      return false;
    }
    
    // Find the sidechain slot from config
    final chains = _chainConfig!['chains'] as List<dynamic>;
    final chainConfig = chains.firstWhere(
      (chain) => chain['name'].toString().toLowerCase() == binary.name.toLowerCase(),
      orElse: () => null,
    );
    
    if (chainConfig == null || chainConfig['sidechain_slot'] == null) {
      return false;
    }
    
    final sidechainSlot = chainConfig['sidechain_slot'] as int;
    
    try {
      final appDir = await Environment.appDir();
      final starterDir = path.join(appDir.path, 'wallet_starters');
      final starterFile = File(
        path.join(
          starterDir,
          'sidechain_${sidechainSlot}_starter.json',
        ),
      );
      
      return starterFile.existsSync();
    } catch (e) {
      return false;
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
                                        Builder(
                                          builder: (context) {
                                            final allL1Installed = statusSnapshot.data != null &&
                                                [ParentChain(), Enforcer(), BitWindow()].every(
                                                  (b) =>
                                                      statusSnapshot.data![b.name]?.status == DownloadStatus.installed,
                                                );

                                            return SailButton.primary(
                                              allL1Installed ? 'Boot Layer 1' : 'Download Layer 1',
                                              onPressed: () => allL1Installed
                                                  ? _runL1(context, statusSnapshot.data)
                                                  : _downloadUninstalledL1Binaries(statusSnapshot.data),
                                              size: ButtonSize.regular,
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: SailStyleValues.padding16),
                                  child: IntrinsicHeight(
                                    child: SailRow(
                                      spacing: SailStyleValues.padding16,
                                      children: l1Chains.map((chain) {
                                        final status = statusSnapshot.data?[chain.name];
                                        return Expanded(
                                          child: SailRawCard(
                                            padding: true,
                                            child: _buildChainContent(chain, status),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
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
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: SailStyleValues.padding16),
                                  child: IntrinsicHeight(
                                    child: SailRow(
                                      spacing: SailStyleValues.padding16,
                                      children: l2Chains.map((chain) {
                                        final status = statusSnapshot.data?[chain.name];
                                        return Expanded(
                                          child: SailRawCard(
                                            padding: true,
                                            child: _buildChainContent(chain, status),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
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

  Widget _buildStatusIndicator(bool connected, bool initializing, bool stopping, String? error) {
    final color = switch ((connected, initializing, stopping, error != null)) {
      (true, _, _, _) => Colors.green,
      (_, true, _, _) => Colors.orange,
      (_, _, true, _) => Colors.orange,
      (_, _, _, true) => SailColorScheme.red,
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
    // Store context values before any async operations
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    // Check if binary is running
    final isRunning = switch (binary) {
      var b when b is ParentChain => _binaryProvider.mainchainConnected,
      var b when b is Enforcer => _binaryProvider.enforcerConnected,
      var b when b is BitWindow => _binaryProvider.bitwindowConnected,
      var b when b is Thunder => _binaryProvider.thunderConnected,
      var b when b is Bitnames => _binaryProvider.bitnamesConnected,
      _ => false,
    };

    // Check if binary is initializing
    final isInitializing = switch (binary) {
      var b when b is ParentChain => _binaryProvider.mainchainInitializing,
      var b when b is Enforcer => _binaryProvider.enforcerInitializing,
      var b when b is BitWindow => _binaryProvider.bitwindowInitializing,
      var b when b is Thunder => _binaryProvider.thunderInitializing,
      var b when b is Bitnames => _binaryProvider.bitnamesInitializing,
      _ => false,
    };

    final stopping = switch (binary) {
      var b when b is ParentChain => _binaryProvider.mainchainStopping,
      var b when b is Enforcer => _binaryProvider.enforcerStopping,
      var b when b is BitWindow => _binaryProvider.bitwindowStopping,
      var b when b is Thunder => _binaryProvider.thunderStopping,
      var b when b is Bitnames => _binaryProvider.bitnamesStopping,
      _ => false,
    };

    if (stopping) {
      return SailButton.primary(
        'Stopping...',
        onPressed: () {}, // Disable button while stopping
        size: ButtonSize.regular,
        loading: true,
      );
    }

    if (isRunning) {
      return SailButton.secondary(
        'Stop',
        onPressed: () async {
          await _stopBinary(binary);
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

      final actionButton = Tooltip(
        message: dependencyMessage ?? 'Launch ${binary.name}',
        child: SailButton.primary(
          'Launch',
          onPressed: () async {
            final useStarter = binary.chainLayer == 2 && await _starterExists(binary) && (_useStarter[binary.name] ?? true);
            
            try {
              if (!mounted) return;
              await _binaryProvider.startBinary(
                navigator.context,
                binary,
                useStarter: useStarter,
              );
            } catch (e) {
              if (!mounted) return;
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text('Failed to start binary: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          size: ButtonSize.regular,
          disabled: !canStart,
        ),
      );

      // Only show checkbox for L2 chains
      if (binary.chainLayer == 2) {
        return FutureBuilder<bool>(
          future: _starterExists(binary),
          builder: (context, snapshot) {
            final starterExists = snapshot.data ?? false;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                actionButton,
                const SizedBox(width: 8),
                Tooltip(
                  message: starterExists ? 'Use starter' : 'Generate starter',
                  child: Checkbox(
                    value: starterExists ? (_useStarter[binary.name] ?? true) : false,
                    onChanged: starterExists 
                      ? (value) {
                          setState(() {
                            _useStarter[binary.name] = value ?? false;
                          });
                        }
                      : null,
                  ),
                ),
                SailText.secondary13('Use starter'),
              ],
            );
          },
        );
      }

      return actionButton;
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

  Future<void> _stopBinary(Binary binary) async {
    switch (binary) {
      case ParentChain():
        await _binaryProvider.mainchainRPC?.stop();
      case Enforcer():
        await _binaryProvider.enforcerRPC?.stop();
      case BitWindow():
        await _binaryProvider.bitwindowRPC?.stop();
      case Thunder():
        await _binaryProvider.thunderRPC?.stop();
      case Bitnames():
        await _binaryProvider.bitnamesRPC?.stop();
    }
  }

  Future<void> _wipeBinary(BuildContext context, Binary binary) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Data Wipe'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SailText.primary15(
              'Are you sure you want to wipe all data recursively for ${binary.name}?',
            ),
            const SizedBox(height: 8),
            SailText.primary22(
              binary.datadir(),
              bold: true,
            ),
            const SizedBox(height: 8),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: SailText.primary15('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: SailColorScheme.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: SailText.primary15('Wipe Data', color: SailColorScheme.red),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    // First stop the binary
    await _stopBinary(binary);

    // Then wipe it
    await binary.wipeAppDir();

    // Show success message
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${binary.name} data wiped successfully'),
        ),
      );
    }
  }

  Future<void> _wipeWallet(BuildContext context, Binary binary) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Wallet Wipe'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SailText.primary15(
              'CAUTION: Are you sure you want to wipe all data recursively for ${binary.name}?',
            ),
            const SizedBox(height: 8),
            SailText.primary22(
              binary.datadir(),
              bold: true,
            ),
            const SizedBox(height: 8),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: SailColorScheme.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Wipe Wallet'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    // First stop the binary
    await _stopBinary(binary);

    // Then wipe it
    await binary.wipeWallet();

    // Show success message
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${binary.name} wallet wiped successfully'),
        ),
      );
    }
  }

  Widget _buildChainContent(Binary binary, DownloadState? status) {
    final theme = SailTheme.of(context);

    // Get RPC status based on binary type
    bool connected = false;
    bool initializing = false;
    bool stopping = false;
    String? error;

    switch (binary) {
      case ParentChain():
        connected = _binaryProvider.mainchainRPC?.connected ?? false;
        initializing = _binaryProvider.mainchainRPC?.initializingBinary ?? false;
        stopping = _binaryProvider.mainchainRPC?.stoppingBinary ?? false;
        error = _binaryProvider.mainchainError;
      case Enforcer():
        connected = _binaryProvider.enforcerRPC?.connected ?? false;
        initializing = _binaryProvider.enforcerRPC?.initializingBinary ?? false;
        stopping = _binaryProvider.enforcerRPC?.stoppingBinary ?? false;
        error = _binaryProvider.enforcerError;
      case BitWindow():
        connected = _binaryProvider.bitwindowRPC?.connected ?? false;
        initializing = _binaryProvider.bitwindowRPC?.initializingBinary ?? false;
        stopping = _binaryProvider.bitwindowRPC?.stoppingBinary ?? false;
        error = _binaryProvider.bitwindowError;
      case Thunder():
        connected = _binaryProvider.thunderRPC?.connected ?? false;
        initializing = _binaryProvider.thunderRPC?.initializingBinary ?? false;
        stopping = _binaryProvider.thunderRPC?.stoppingBinary ?? false;
        error = _binaryProvider.thunderError;
      case Bitnames():
        connected = _binaryProvider.bitnamesRPC?.connected ?? false;
        initializing = _binaryProvider.bitnamesRPC?.initializingBinary ?? false;
        stopping = _binaryProvider.bitnamesRPC?.stoppingBinary ?? false;
        error = _binaryProvider.bitnamesError;
    }

    return Builder(
      builder: (context) => Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
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
                        builder: (context) => ChainSettingsModal(
                          chain: binary,
                          onWipeAppDir: () => _wipeBinary(context, binary),
                          onWipeWallet: () => _wipeWallet(context, binary),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildStatusIndicator(connected, initializing, stopping, error),
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
                    color: SailColorScheme.red,
                  ),
                ),
            ],
          ),
          SailSpacing(SailStyleValues.padding08),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActionButton(context, binary, status),
              if (binary.updateAvailable) ...[
                const SizedBox(width: 12),
                Center(
                  child: SailButton.primary(
                    'Update Now',
                    onPressed: () => _updateBinary(binary),
                    size: ButtonSize.regular,
                    disabled: status?.status == DownloadStatus.installing,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Future<bool> displayShutdownModal(BuildContext context) async {
    // Start a timer that will force close after 6 seconds
    final timer = Timer(const Duration(seconds: 6), () {
      if (_closeAlertOpen) {
        Navigator.of(context).pop(true);
        _closeAlertOpen = false;
      }
    });

    try {
      final futures = <Future>[];
      // Try to stop all binaries regardless of state
      futures.add(_binaryProvider.mainchainRPC?.stop() ?? Future.value());
      futures.add(_binaryProvider.enforcerRPC?.stop() ?? Future.value());
      futures.add(_binaryProvider.bitwindowRPC?.stop() ?? Future.value());
      futures.add(_binaryProvider.thunderRPC?.stop() ?? Future.value());
      futures.add(_binaryProvider.bitnamesRPC?.stop() ?? Future.value());

      // If no processes are running, return immediately
      if (futures.isEmpty) {
        return true;
      }

      _closeAlertOpen = true;

      // Create dialog but don't await it. That's what the future is for
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: SailStyleValues.padding16),
                child: IntrinsicHeight(
                  child: SailRow(
                    spacing: SailStyleValues.padding16,
                    children: _processProvider.runningProcesses.values.map((process) {
                      final binary = Binary.fromBinary(process.binary)!;
                      return Expanded(
                        child: SailRawCard(
                          padding: true,
                          child: _buildChainContent(binary, null),
                        ),
                      );
                    }).toList(),
                  ),
                ),
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

      // Wait for all stop operations to complete
      await Future.wait(futures);
      if (context.mounted) {
        Navigator.of(context).pop(true);
      }
    } finally {
      timer.cancel();
      _closeAlertOpen = false;
    }

    return true;
  }
}