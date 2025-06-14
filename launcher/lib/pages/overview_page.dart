import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:launcher/env.dart';
import 'package:launcher/services/wallet_service.dart';
import 'package:launcher/widgets/chain_settings_modal.dart';
import 'package:launcher/widgets/quotes_widget.dart';
import 'package:sail_ui/sail_ui.dart';

@RoutePage()
class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  BinaryProvider get _binaryProvider => GetIt.I.get<BinaryProvider>();
  WalletService get _walletService => GetIt.I.get<WalletService>();
  SyncProgressProvider get _blockchainProvider => GetIt.I.get<SyncProgressProvider>();

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
      _blockchainProvider.addListener(_onBinaryProviderUpdate);
    });
  }

  @override
  void dispose() {
    _binaryProvider.removeListener(_onBinaryProviderUpdate);
    _blockchainProvider.removeListener(_onBinaryProviderUpdate);
    super.dispose();
  }

  void _onBinaryProviderUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _updateBinary(Binary binary) async {
    // Check if binary is running
    final isRunning = switch (binary) {
      var b when b is BitcoinCore => _binaryProvider.mainchainConnected,
      var b when b is Enforcer => _binaryProvider.enforcerConnected,
      var b when b is BitWindow => _binaryProvider.bitwindowConnected,
      var b when b is Thunder => _binaryProvider.thunderConnected,
      var b when b is Bitnames => _binaryProvider.bitnamesConnected,
      var b when b is BitAssets => _binaryProvider.bitassetsConnected,
      _ => false,
    };

    // Check if binary is initializing
    final isInitializing = switch (binary) {
      var b when b is BitcoinCore => _binaryProvider.mainchainInitializing,
      var b when b is Enforcer => _binaryProvider.enforcerInitializing,
      var b when b is BitWindow => _binaryProvider.bitwindowInitializing,
      var b when b is Thunder => _binaryProvider.thunderInitializing,
      var b when b is Bitnames => _binaryProvider.bitnamesInitializing,
      var b when b is BitAssets => _binaryProvider.bitassetsInitializing,
      _ => false,
    };

    final stopping = switch (binary) {
      var b when b is BitcoinCore => _binaryProvider.mainchainStopping,
      var b when b is Enforcer => _binaryProvider.enforcerStopping,
      var b when b is BitWindow => _binaryProvider.bitwindowStopping,
      var b when b is Thunder => _binaryProvider.thunderStopping,
      var b when b is Bitnames => _binaryProvider.bitnamesStopping,
      var b when b is BitAssets => _binaryProvider.bitassetsStopping,
      _ => false,
    };
    final isProcessRunning = _binaryProvider.isRunning(binary);
    final isConnected = _binaryProvider.isRunning(binary);

    if (isConnected || isRunning || isInitializing || stopping || isProcessRunning) {
      await _stopBinary(binary);
    }

    await _binaryProvider.download(binary);
  }

  Future<void> _downloadBinary(BuildContext context, Binary binary) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      await _binaryProvider.download(binary);

      if (!mounted) return;

      if (binary is Sidechain) {
        try {
          await _walletService.deriveSidechainStarter(binary.slot);
        } catch (e) {
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
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Failed to download binary: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildActionButton(BuildContext context, Binary binary, DownloadInfo? status) {
    // Check if binary is running
    final isRunning = switch (binary) {
      var b when b is BitcoinCore => _binaryProvider.mainchainConnected,
      var b when b is Enforcer => _binaryProvider.enforcerConnected,
      var b when b is BitWindow => _binaryProvider.bitwindowConnected,
      var b when b is Thunder => _binaryProvider.thunderConnected,
      var b when b is Bitnames => _binaryProvider.bitnamesConnected,
      var b when b is BitAssets => _binaryProvider.bitassetsConnected,
      _ => false,
    };

    // Check if binary is initializing
    final isInitializing = switch (binary) {
      var b when b is BitcoinCore => _binaryProvider.mainchainInitializing,
      var b when b is Enforcer => _binaryProvider.enforcerInitializing,
      var b when b is BitWindow => _binaryProvider.bitwindowInitializing,
      var b when b is Thunder => _binaryProvider.thunderInitializing,
      var b when b is Bitnames => _binaryProvider.bitnamesInitializing,
      var b when b is BitAssets => _binaryProvider.bitassetsInitializing,
      _ => false,
    };

    final stopping = switch (binary) {
      var b when b is BitcoinCore => _binaryProvider.mainchainStopping,
      var b when b is Enforcer => _binaryProvider.enforcerStopping,
      var b when b is BitWindow => _binaryProvider.bitwindowStopping,
      var b when b is Thunder => _binaryProvider.thunderStopping,
      var b when b is Bitnames => _binaryProvider.bitnamesStopping,
      var b when b is BitAssets => _binaryProvider.bitassetsStopping,
      _ => false,
    };

    final isProcessRunning = _binaryProvider.isRunning(binary);

    final isDownloaded = binary.isDownloaded;

    if (stopping) {
      return SailButton(
        label: 'Stopping...',
        onPressed: () async {},
        variant: ButtonVariant.primary,
        loading: true,
      );
    }

    if (isRunning) {
      return SailButton(
        label: 'Stop',
        onPressed: () async {
          await _stopBinary(binary);
        },
        variant: ButtonVariant.secondary,
      );
    }

    if (isInitializing) {
      return SailButton(
        label: 'Launching...',
        onPressed: () async {}, // Disable button while initializing
        variant: ButtonVariant.primary,
        loading: true,
      );
    }

    if (isProcessRunning) {
      return SailButton(
        label: 'Kill',
        onPressed: () async {
          await _stopBinary(binary);
        },
        variant: ButtonVariant.secondary,
      );
    }

    if (isDownloaded) {
      final mainchainReady = _binaryProvider.mainchainConnected;
      final canStart = switch (binary) {
        Enforcer() => mainchainReady ? null : 'Mainchain must be started and headers synced before starting Enforcer',
        BitWindow() => null,
        Thunder() => _binaryProvider.enforcerConnected && mainchainReady
            ? null
            : 'Mainchain and Enforcer must be running and headers synced before starting Thunder',
        Bitnames() => _binaryProvider.enforcerConnected && mainchainReady
            ? null
            : 'Mainchain and Enforcer must be running and headers synced before starting Bitnames',
        BitAssets() => _binaryProvider.enforcerConnected && mainchainReady
            ? null
            : 'Mainchain and Enforcer must be running and headers synced before starting BitAssets',
        ZCash() => _binaryProvider.enforcerConnected && mainchainReady
            ? null
            : 'Mainchain and Enforcer must be running and headers synced before starting ZCash',
        _ => null, // No requirements for mainchain
      };

      return Tooltip(
        message: canStart ?? 'Launch ${binary.name}',
        child: SailButton(
          label: 'Launch',
          onPressed: () => _binaryProvider.start(
            binary,
            useStarter: _useStarter[binary.name] ?? false,
          ),
          variant: ButtonVariant.primary,
          disabled: canStart != null,
        ),
      );
    }

    return SailButton(
      label: 'Download',
      onPressed: () => _downloadBinary(context, binary),
      variant: ButtonVariant.primary,
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
        title: const Text('Confirm Data And Asset Wipe'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SailText.primary15(
              'Confirming will wipe all chain data recursively for ${binary.name}, and can not be undone. Wallet data will not be touched.',
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
            style: TextButton.styleFrom(foregroundColor: SailColorScheme.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: SailText.primary15('Wipe Data', color: SailColorScheme.red),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: SailText.primary15('Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }
    // Check if binary is running before stopping
    final isRunning = _binaryProvider.isConnected(binary);
    final isInitializing = _binaryProvider.isInitializing(binary);
    final isStopping = _binaryProvider.isStopping(binary);
    final isProcessRunning = _binaryProvider.isRunning(binary);

    if (isRunning || isInitializing || isStopping || isProcessRunning) {
      // First stop the binary if it's running
      await _stopBinary(binary);
    }

    // Then wipe it
    await binary.wipeAppDir();
    final appDir = await Environment.appDir();
    final assetsDir = binDir(appDir.path);
    await binary.wipeAssets(assetsDir);

    // Show success message
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${binary.name} data wiped successfully'),
        ),
      );
    }
  }

  Widget _buildChainContent(Binary binary, DownloadInfo? status) {
    final theme = SailTheme.of(context);

    // Get RPC status based on binary type
    bool connected = false;
    bool initializing = false;
    bool stopping = false;
    String description = binary.description;
    String? error;
    String? startupError;

    switch (binary) {
      case BitcoinCore():
        connected = _binaryProvider.mainchainRPC.connected;
        initializing = _binaryProvider.mainchainInitializing;
        stopping = _binaryProvider.mainchainStopping;
        error = _binaryProvider.mainchainError;
        startupError = _binaryProvider.mainchainStartupError;

        if (connected && _binaryProvider.mainchainRPC.inIBD && _blockchainProvider.mainchainSyncInfo != null) {
          final info = _blockchainProvider.mainchainSyncInfo;
          final progress = info!.progress;
          description = 'Syncing... ${(progress * 100).toStringAsFixed(2)} %\n'
              'Blocks: ${info.progressCurrent} / ${info.progressGoal}';
        }

      case Enforcer():
        connected = _binaryProvider.enforcerConnected;
        initializing = _binaryProvider.enforcerInitializing;
        stopping = _binaryProvider.enforcerStopping;
        error = _binaryProvider.enforcerError;
        startupError = _binaryProvider.enforcerStartupError;

        if (_binaryProvider.mainchainRPC.connected && _binaryProvider.mainchainRPC.inHeaderSync) {
          description = 'Bitcoin Core syncing headers, waiting...';
        }

      case BitWindow():
        connected = _binaryProvider.bitwindowConnected;
        initializing = _binaryProvider.bitwindowInitializing;
        stopping = _binaryProvider.bitwindowStopping;
        error = _binaryProvider.bitwindowError;
        startupError = _binaryProvider.bitwindowStartupError;

      case Thunder():
        connected = _binaryProvider.thunderConnected;
        initializing = _binaryProvider.thunderInitializing;
        stopping = _binaryProvider.thunderStopping;
        error = _binaryProvider.thunderError;
        startupError = _binaryProvider.thunderStartupError;

      case Bitnames():
        connected = _binaryProvider.bitnamesConnected;
        initializing = _binaryProvider.bitnamesInitializing;
        stopping = _binaryProvider.bitnamesStopping;
        error = _binaryProvider.bitnamesError;
        startupError = _binaryProvider.bitnamesStartupError;

      case BitAssets():
        connected = _binaryProvider.bitassetsConnected;
        initializing = _binaryProvider.bitassetsInitializing;
        stopping = _binaryProvider.bitassetsStopping;
        error = _binaryProvider.bitassetsError;
        startupError = _binaryProvider.bitassetsStartupError;
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
                  _buildStatusIndicator(connected, initializing, stopping, error, startupError),
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
                SailInfoBox(
                  text: status?.error ?? error ?? '',
                  type: InfoType.error,
                ),
              if (startupError != null && startupError.isNotEmpty)
                SailInfoBox(
                  text: startupError,
                  type: InfoType.warn,
                ),
            ],
          ),
          SailSpacing(SailStyleValues.padding08),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActionButton(context, binary, status),
              if (binary.updateAvailable && (status?.progress == 1.0 || status?.progress == 0 || status == null)) ...[
                const SizedBox(width: 12),
                Center(
                  child: SailButton(
                    label: 'Update Now',
                    onPressed: () => _updateBinary(binary),
                    variant: ButtonVariant.primary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(bool connected, bool initializing, bool stopping, String? error, String? startupError) {
    final color = switch ((connected, initializing, stopping, error != null, startupError != null)) {
      (true, _, _, _, _) => Colors.green,
      (_, true, _, _, _) => Colors.orange,
      (_, _, true, _, _) => Colors.orange,
      (_, _, _, true, _) => SailColorScheme.red,
      (_, _, _, _, true) => SailColorScheme.orange,
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

  Widget _buildProgressIndicator(Binary binary, DownloadInfo? status) {
    final hide = status == null || status.progress == 0.0 || status.progress == 1.0;

    return Opacity(
      opacity: hide ? 0 : 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(value: status?.progress),
          const SizedBox(height: 4),
          SailText.secondary13(status?.message ?? ''),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return QtPage(
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: StreamBuilder<Map<String, DownloadInfo>>(
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

                                            return SailButton(
                                              label: allL1Downloaded ? 'Boot Layer 1' : 'Download and Boot Layer 1',
                                              onPressed: () async {
                                                try {
                                                  await _binaryProvider.startWithEnforcer(
                                                    _binaryProvider.binaries.firstWhere((b) => b is BitWindow),
                                                  );
                                                } catch (e) {
                                                  if (!context.mounted) return;
                                                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                                                  scaffoldMessenger.showSnackBar(
                                                    SnackBar(
                                                      content: Text('Failed to start L1 binaries: $e'),
                                                      backgroundColor: SailColorScheme.red,
                                                    ),
                                                  );
                                                }
                                              },
                                              variant: ButtonVariant.primary,
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
                                          child: SailCard(
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
                                          child: SailCard(
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
