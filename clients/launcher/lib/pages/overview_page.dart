import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:get_it/get_it.dart';
import 'package:launcher/services/wallet_service.dart';
import 'package:launcher/widgets/chain_settings_modal.dart';
import 'package:launcher/widgets/quotes_widget.dart';
import 'package:logger/logger.dart';
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
  BlockchainProvider get _blockchainProvider => GetIt.I.get<BlockchainProvider>();

  // Add state for starter usage
  final Map<String, bool> _useStarter = {};

  @override
  void initState() {
    super.initState();

    FlutterWindowClose.setWindowShouldCloseHandler(() async {
      return await onShutdown(context);
    });

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
      _blockchainProvider.addListener(_onBinaryProviderUpdate);
    });
  }

  @override
  void dispose() {
    _binaryProvider.removeListener(_onBinaryProviderUpdate);
    _processProvider.removeListener(_onBinaryProviderUpdate);
    _walletService.removeListener(_onBinaryProviderUpdate);
    _blockchainProvider.removeListener(_onBinaryProviderUpdate);
    super.dispose();
  }

  void _onBinaryProviderUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _downloadUninstalledL1Binaries() async {
    final uninstalledBinaries = _binaryProvider.binaries.where((b) => b.chainLayer == 1 && !b.isDownloaded);

    // Start downloads concurrently for uninstalled/failed binaries
    await Future.wait(
      uninstalledBinaries.map(
        (binary) => _binaryProvider.downloadBinary(binary),
      ),
    );
  }

  Future<void> _runL1(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final log = GetIt.I.get<Logger>();
    log.i('Starting L1 binaries sequence');

    try {
      // First ensure all binaries are downloaded
      await _downloadUninstalledL1Binaries();

      // Ensure we have all required binaries
      final parentChain = _binaryProvider.binaries.whereType<ParentChain>().firstOrNull;
      final enforcer = _binaryProvider.binaries.whereType<Enforcer>().firstOrNull;
      final bitwindow = _binaryProvider.binaries.whereType<BitWindow>().firstOrNull;

      if (parentChain == null || enforcer == null || bitwindow == null) {
        throw Exception('could not find all required L1 binaries');
      }

      // 1. Start parent chain and wait for IBD
      if (!context.mounted) return;
      await _binaryProvider.startBinary(context, parentChain, useStarter: false);

      log.i('Waiting for mainchain to connect...');
      await _binaryProvider.mainchainRPC.waitForIBD();
      log.i('Mainchain connected and synced');

      // 2. Start enforcer after mainchain is ready
      if (!context.mounted) return;
      await _binaryProvider.startBinary(context, enforcer, useStarter: false);
      log.i('Started enforcer');

      // 3. Start BitWindow after enforcer
      if (!context.mounted) return;
      await _binaryProvider.startBinary(context, bitwindow, useStarter: false);
      log.i('Started BitWindow');

      log.i('All L1 binaries started successfully');
    } catch (e) {
      log.e('Error starting L1 binaries: $e');
      if (context.mounted) {
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

    if (isRunning || isInitializing || stopping) {
      await _stopBinary(binary);
    }

    await _binaryProvider.downloadBinary(binary);
  }

  Future<void> _downloadBinary(BuildContext context, Binary binary) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await _binaryProvider.downloadBinary(binary);
      debugPrint('Download completed for ${binary.name}');

      if (!mounted) return;

      if (binary is Sidechain) {
        try {
          await _walletService.deriveSidechainStarter(binary.slot);
          debugPrint('Successfully created sidechain starter for slot ${binary.slot}');
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

  Widget _buildActionButton(BuildContext context, Binary binary, DownloadState? status) {
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

    final isDownloaded = binary.isDownloaded;

    if (stopping) {
      return SailButton.primary(
        'Stopping...',
        onPressed: () {},
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

    if (isDownloaded) {
      final canStart = _binaryProvider.canStart(binary);

      return Tooltip(
        message: canStart ?? 'Launch ${binary.name}',
        child: SailButton.primary(
          'Launch',
          onPressed: () => _binaryProvider.startBinary(context, binary, useStarter: _useStarter[binary.name] ?? false),
          size: ButtonSize.regular,
          disabled: canStart != null,
        ),
      );
    }

    return SailButton.primary(
      'Download',
      onPressed: () => _downloadBinary(context, binary),
      size: ButtonSize.regular,
      loading: status != null && status.progress != 1.0 && status.progress != 0.0,
    );
  }

  Future<void> _stopBinary(Binary binary) async {
    await _binaryProvider.stop(binary);
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
    String description = binary.description;
    String? error;

    switch (binary) {
      case ParentChain():
        connected = _binaryProvider.mainchainRPC.connected;
        initializing = _binaryProvider.mainchainRPC.initializingBinary;
        stopping = _binaryProvider.mainchainRPC.stoppingBinary;
        error = _binaryProvider.mainchainError;

        if (_binaryProvider.inIBD && _blockchainProvider.blockchainInfo.headers != 0) {
          final info = _blockchainProvider.blockchainInfo;
          description = 'Syncing... ${_blockchainProvider.verificationProgress}%\n'
              'Blocks: ${info.blocks} / ${info.headers}';
        }
      case Enforcer():
        connected = _binaryProvider.enforcerRPC.connected;
        initializing = _binaryProvider.enforcerRPC.initializingBinary;
        stopping = _binaryProvider.enforcerRPC.stoppingBinary;
        error = _binaryProvider.enforcerError;
        if (_binaryProvider.inIBD && _blockchainProvider.blockchainInfo.headers != 0) {
          description = 'Bitcoin Core in IBD, waiting...';
        }
      case BitWindow():
        connected = _binaryProvider.bitwindowRPC.connected;
        initializing = _binaryProvider.bitwindowRPC.initializingBinary;
        stopping = _binaryProvider.bitwindowRPC.stoppingBinary;
        error = _binaryProvider.bitwindowError;
      case Thunder():
        connected = _binaryProvider.thunderRPC.connected;
        initializing = _binaryProvider.thunderRPC.initializingBinary;
        stopping = _binaryProvider.thunderRPC.stoppingBinary;
        error = _binaryProvider.thunderError;
      case Bitnames():
        connected = _binaryProvider.bitnamesRPC.connected;
        initializing = _binaryProvider.bitnamesRPC.initializingBinary;
        stopping = _binaryProvider.bitnamesRPC.stoppingBinary;
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
                          useStarter: _useStarter[binary.name] ?? false,
                          onUseStarterChanged: (value) {
                            setState(() {
                              _useStarter[binary.name] = value;
                            });
                          },
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
                  description,
                  textAlign: TextAlign.left,
                ),
              ),
              const SizedBox(height: 12),
              _buildProgressIndicator(binary, status),
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
                  ),
                ),
              ],
            ],
          ),
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

  Widget _buildProgressIndicator(Binary binary, DownloadState? status) {
    if (status == null || status.progress == 0.0 || status.progress == 1.0) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(value: status.progress),
        const SizedBox(height: 4),
        SailText.secondary13(status.message ?? ''),
      ],
    );
  }

  Future<bool> onShutdown(BuildContext context) async {
    final futures = <Future>[];
    // Try to stop all binaries regardless of state
    for (final binary in _binaryProvider.binaries) {
      futures.add(_binaryProvider.stop(binary));
    }

    // If no processes are running, return immediately
    if (futures.isEmpty) {
      return true;
    }

    // Wait for all stop operations to complete
    await Future.wait(futures);

    return true;
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
                                            final allL1Downloaded = l1Chains.every(
                                              (b) => b.isDownloaded,
                                            );

                                            return SailButton.primary(
                                              allL1Downloaded ? 'Boot Layer 1' : 'Download Layer 1',
                                              onPressed: () =>
                                                  allL1Downloaded ? _runL1(context) : _downloadUninstalledL1Binaries(),
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
}
