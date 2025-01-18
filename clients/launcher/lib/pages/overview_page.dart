import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:launcher/widgets/chain_settings_modal.dart';
import 'package:launcher/widgets/quotes_widget.dart';
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

  @override
  void initState() {
    super.initState();
    _binaryProvider.addListener(_onBinaryProviderUpdate);
    _processProvider.addListener(_onBinaryProviderUpdate);
  }

  @override
  void dispose() {
    _binaryProvider.removeListener(_onBinaryProviderUpdate);
    _processProvider.removeListener(_onBinaryProviderUpdate);
    super.dispose();
  }

  void _onBinaryProviderUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  void _downloadUninstalledL1Binaries(Map<String, DownloadState>? statusData) {
    if (statusData == null) return;

    final uninstalledBinaries = _binaryProvider.binaries
        .where((b) => b.chainLayer == 1)
        .where((b) {
          final status = statusData[b.name]?.status;
          return status == null || 
                 status == DownloadStatus.uninstalled ||
                 status == DownloadStatus.failed;
        });
    
    // Start downloads concurrently for uninstalled/failed binaries
    Future.wait(
      uninstalledBinaries.map((binary) => 
        _binaryProvider.downloadBinary(binary),),
    );
  }

  bool _shouldDisableDownloadAll(Map<String, DownloadState>? statusData) {
    if (statusData == null) return false;

    // Get L1 binaries
    final l1Binaries = _binaryProvider.binaries.where((b) => b.chainLayer == 1);
    
    // Check if any downloads are in progress
    final hasActiveDownloads = statusData.values
        .any((state) => state.status == DownloadStatus.installing);
    
    // Check if all L1 binaries are already installed
    final allInstalled = l1Binaries
        .every((b) => statusData[b.name]?.status == DownloadStatus.installed);
    
    return hasActiveDownloads || allInstalled;
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
                                    SailButton.primary(
                                      'Download All',
                                      onPressed: () => _downloadUninstalledL1Binaries(statusSnapshot.data),
                                      size: ButtonSize.regular,
                                      disabled: _shouldDisableDownloadAll(statusSnapshot.data),
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
                                SailText.primary24('Layer 2'),
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
          const QuotesWidget(), // Now properly positioned in Stack
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(Binary binary) {
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

  Widget _buildActionButton(Binary binary, DownloadState? status) {
    // Check if binary is running
    final isRunning = switch (binary) {
      var b when b is ParentChain => _binaryProvider.mainchainConnected,
      var b when b is Enforcer => _binaryProvider.enforcerConnected,
      var b when b is BitWindow => _binaryProvider.bitwindowConnected,
      _ => false,
    };

    // Check if binary is initializing
    final isInitializing = switch (binary) {
      var b when b is ParentChain => _binaryProvider.mainchainInitializing,
      var b when b is Enforcer => _binaryProvider.enforcerInitializing,
      var b when b is BitWindow => _binaryProvider.bitwindowInitializing,
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
        loading: true, // Show loading spinner
      );
    }

    if (status == null || status.status == DownloadStatus.uninstalled) {
      return SailButton.primary(
        'Download',
        onPressed: () => _binaryProvider.downloadBinary(binary),
        size: ButtonSize.regular,
      );
    }

    if (status.status == DownloadStatus.failed) {
      return SailButton.primary(
        'Retry',
        onPressed: () => _binaryProvider.downloadBinary(binary),
        size: ButtonSize.regular,
      );
    }

    if (status.status == DownloadStatus.installed) {
      return SailButton.primary(
        'Launch',
        onPressed: () => _binaryProvider.startBinary(context, binary),
        size: ButtonSize.regular,
      );
    }

    return const SizedBox();
  }

  Widget _buildChainContent(Binary binary, DownloadState? status) {
    return Column(
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
              icon: const Icon(Icons.settings, color: Colors.white, size: 20),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => ChainSettingsModal(chain: binary),
                );
              },
            ),
            const SizedBox(width: 8),
            _buildStatusIndicator(binary),
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
        if (status?.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: SailText.secondary13(
              status!.error!,
              color: Colors.red,
            ),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildActionButton(binary, status),
            if (binary.updateAvailable) const SizedBox(width: 12),
            if (binary.updateAvailable)
              Center(
                child: SailButton.primary(
                  'Update Now',
                  onPressed: () => _binaryProvider.downloadBinary(binary),
                  size: ButtonSize.regular,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
