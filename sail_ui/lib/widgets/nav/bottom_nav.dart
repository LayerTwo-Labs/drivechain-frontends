import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class BottomNav extends StatelessWidget {
  final List<Widget> endWidgets;
  final ConnectionMonitor additionalConnection;
  final bool mainchainInfo;
  final Function(String, String) navigateToLogs;
  final bool onlyShowAdditional;

  const BottomNav({
    super.key,
    required this.endWidgets,
    required this.additionalConnection,
    required this.mainchainInfo,
    required this.navigateToLogs,
    this.onlyShowAdditional = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: SailTheme.of(context).colors.border,
            ),
          ),
        ),
        child: SailRow(
          mainAxisAlignment: MainAxisAlignment.end,
          spacing: SailStyleValues.padding04,
          leadingSpacing: true,
          trailingSpacing: true,
          children: [
            const SailSpacing(SailStyleValues.padding04),
            ViewModelBuilder.reactive(
              viewModelBuilder: () => BalanceDisplayViewModel(),
              builder: (context, model, child) {
                return BalanceDisplay(
                  balance: model.balance,
                  pendingBalance: model.pendingBalance,
                  balanceSyncing: model.balanceSyncing,
                  showUnconfirmed: model.showUnconfirmed,
                  onToggleUnconfirmed: model.toggleUnconfirmed,
                );
              },
            ),
            Expanded(child: Container()),
            ViewModelBuilder.reactive(
              viewModelBuilder: () => BottomNavViewModel(
                additionalConnection: additionalConnection,
                mainchainInfo: mainchainInfo,
                navigateToLogs: navigateToLogs,
              ),
              fireOnViewModelReadyOnce: true,
              builder: ((context, model, child) {
                return SailRow(
                  spacing: SailStyleValues.padding08,
                  children: [
                    InkWell(
                      onTap: () async =>
                          displayConnectionStatusDialog(context, additionalConnection, onlyShowAdditional),
                      child: Tooltip(
                        message: 'Open daemon status dialog',
                        child: SailRow(
                          spacing: SailStyleValues.padding08,
                          children: [
                            DecoratedBox(
                              decoration: model.connectionColor == SailColorScheme.red
                                  ? BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: SailColorScheme.red.withValues(alpha: 0.5),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    )
                                  : const BoxDecoration(),
                              child: SailSVG.fromAsset(
                                SailSVGAsset.iconConnectionStatus,
                                color: model.connectionColor,
                              ),
                            ),
                            if (model.connectionStatus == 'All binaries connected')
                              SailText.secondary12(model.connectionStatus)
                            else
                              SailText.primary12(model.connectionStatus),
                          ],
                        ),
                      ),
                    ),
                    ChainLoaders(),
                    const DividerDot(),
                    ...endWidgets,
                    const SailSpacing(SailStyleValues.padding08),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void displayConnectionStatusDialog(
    BuildContext context,
    ConnectionMonitor additionalConnection,
    bool onlyShowAdditional,
  ) {
    widgetDialog(
      context: context,
      title: 'Daemon Status',
      child: ViewModelBuilder.reactive(
        viewModelBuilder: () => BottomNavViewModel(
          mainchainInfo: mainchainInfo,
          additionalConnection: additionalConnection,
          navigateToLogs: navigateToLogs,
        ),
        builder: ((context, model, child) {
          final binaryProvider = GetIt.I.get<BinaryProvider>();

          return SailColumn(
            spacing: SailStyleValues.padding20,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SailColumn(
                spacing: SailStyleValues.padding12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!model.mainchain.connected || !onlyShowAdditional)
                    DaemonConnectionCard(
                      connection: model.mainchain,
                      syncInfo: model.blockInfoProvider.mainchainSyncInfo,
                      restartDaemon: () => binaryProvider.start(
                        binaryProvider.binaries.firstWhere((b) => b.name == BitcoinCore().name),
                      ),
                      infoMessage: _getDownloadMessage(model.blockInfoProvider.mainchainSyncInfo),
                      navigateToLogs: model.navigateToLogs,
                    ),
                  if (!model.enforcer.connected || !onlyShowAdditional)
                    DaemonConnectionCard(
                      connection: model.enforcer,
                      syncInfo: model.blockInfoProvider.enforcerSyncInfo,
                      infoMessage: _getDownloadMessage(model.blockInfoProvider.enforcerSyncInfo) ??
                          (model.mainchain.initializingBinary
                              ? 'Waiting for mainchain to finish init'
                              : model.mainchain.inHeaderSync
                                  ? 'Waiting for L1 to sync headers...'
                                  : null),
                      restartDaemon: () => binaryProvider.start(
                        binaryProvider.binaries.firstWhere((b) => b.name == Enforcer().name),
                      ),
                      navigateToLogs: model.navigateToLogs,
                    ),
                  DaemonConnectionCard(
                    connection: additionalConnection.rpc,
                    syncInfo: model.blockInfoProvider.additionalSyncInfo,
                    infoMessage: _getDownloadMessage(model.blockInfoProvider.additionalSyncInfo),
                    restartDaemon: () => binaryProvider.start(
                      binaryProvider.binaries.firstWhere((b) => b.name == additionalConnection.rpc.binary.name),
                    ),
                    navigateToLogs: model.navigateToLogs,
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  String? _getDownloadMessage(SyncInfo? syncInfo) {
    if (syncInfo == null) return null;

    // Check if we're downloading (downloadProgress < 1)
    if (syncInfo.downloadProgress < 1) {
      final progressPercent = (syncInfo.downloadProgress * 100).toStringAsFixed(0);
      if (progressPercent == '100') {
        return null;
      } else {
        return 'Downloading binary... $progressPercent%';
      }
    }

    return null;
  }
}

class DividerDot extends StatelessWidget {
  const DividerDot({super.key});

  @override
  Widget build(BuildContext context) {
    return SailPadding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: SailText.primary10('|', color: SailTheme.of(context).colors.divider),
    );
  }
}

class Separator extends StatelessWidget {
  final Widget child;
  final bool right;

  const Separator({
    super.key,
    required this.child,
    this.right = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 4.0,
        vertical: 2.0,
      ),
      decoration: BoxDecoration(
        border: Border(
          left: right ? BorderSide.none : const BorderSide(color: Colors.grey),
          right: right ? const BorderSide(color: Colors.grey) : BorderSide.none,
        ),
      ),
      child: child,
    );
  }
}

/// Represents a binary that needs connection monitoring
class ConnectionMonitor {
  final RPCConnection rpc;
  final String name;

  const ConnectionMonitor({
    required this.rpc,
    required this.name,
  });

  bool get connected => rpc.connected;
  bool get initializingBinary => rpc.initializingBinary;
  String? get connectionError => rpc.connectionError;
}

class BottomNavViewModel extends BaseViewModel with ChangeTrackingMixin {
  final ConnectionMonitor additionalConnection;

  // Required connections
  MainchainRPC get mainchain => GetIt.I.get<MainchainRPC>();
  EnforcerRPC get enforcer => GetIt.I.get<EnforcerRPC>();
  SyncProgressProvider get blockInfoProvider => GetIt.I.get<SyncProgressProvider>();
  BinaryProvider get binaryProvider => GetIt.I.get<BinaryProvider>();

  final bool mainchainInfo;
  final Function(String, String) navigateToLogs;

  BottomNavViewModel({
    required this.additionalConnection,
    required this.mainchainInfo,
    required this.navigateToLogs,
  }) {
    initChangeTracker();
    // Add listeners for required connections
    mainchain.addListener(_onChange);
    enforcer.addListener(_onChange);
    additionalConnection.rpc.addListener(_onChange);
    blockInfoProvider.addListener(_onChange);
  }

  void _onChange() {
    track('allConnected', allConnected);
    track('connectionColor', connectionColor);
    track('connectionStatus', connectionStatus);
    track('mainchainSyncInfo', blockInfoProvider.mainchainSyncInfo);
    track('enforcerSyncInfo', blockInfoProvider.enforcerSyncInfo);
    track('additionalSyncInfo', blockInfoProvider.additionalSyncInfo);
    notifyIfChanged(); // Use change tracking for normal updates
  }

  // Connection status
  bool get allConnected => mainchain.connected && enforcer.connected && additionalConnection.connected;

  Color get connectionColor {
    if (allConnected) {
      return SailColorScheme.green;
    }

    if ((!mainchain.connected && !mainchain.initializingBinary) ||
        (!enforcer.connected && !enforcer.initializingBinary) ||
        (!additionalConnection.connected && !additionalConnection.initializingBinary)) {
      // done initializing, but not connected
      return SailColorScheme.red;
    }
    return SailColorScheme.orange;
  }

  String get connectionStatus {
    if (mainchain.initializingBinary) {
      return 'Initializing bitcoind..';
    }

    if (mainchain.connectionError != null || mainchain.startupError != null) {
      return mainchain.connectionError ?? mainchain.startupError!;
    }

    if (enforcer.initializingBinary || enforcer.startupError != null) {
      return 'Initializing enforcer..';
    }

    if (enforcer.connectionError != null || enforcer.startupError != null) {
      return enforcer.connectionError ?? enforcer.startupError!;
    }

    if (additionalConnection.initializingBinary) {
      return 'Initializing ${additionalConnection.name}..';
    }

    if (additionalConnection.connectionError != null || additionalConnection.rpc.startupError != null) {
      return additionalConnection.connectionError ?? additionalConnection.rpc.startupError!;
    }

    if (!allConnected) {
      return 'Wiring things together...';
    }

    return 'All binaries connected';
  }

  @override
  void dispose() {
    mainchain.removeListener(_onChange);
    enforcer.removeListener(_onChange);
    additionalConnection.rpc.removeListener(_onChange);
    blockInfoProvider.removeListener(_onChange);
    super.dispose();
  }
}

class ChainLoaders extends ViewModelWidget<BottomNavViewModel> {
  const ChainLoaders({super.key});

  @override
  Widget build(BuildContext context, BottomNavViewModel viewModel) {
    final mainchainConnected = viewModel.blockInfoProvider.mainchainSyncInfo != null;
    final enforcerConnected = viewModel.blockInfoProvider.enforcerSyncInfo != null;
    final additionalConnected = viewModel.blockInfoProvider.additionalSyncInfo != null;

    final mainchainSynced = mainchainConnected && viewModel.blockInfoProvider.mainchainSyncInfo!.isSynced;
    final enforcerSynced = enforcerConnected && viewModel.blockInfoProvider.enforcerSyncInfo!.isSynced;
    final additionalSynced = additionalConnected && viewModel.blockInfoProvider.additionalSyncInfo!.isSynced;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: SailRow(
        spacing: 0,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (mainchainConnected && !mainchainSynced) ...[
            ChainLoader(
              name: viewModel.blockInfoProvider.mainchain.name,
              syncInfo: viewModel.blockInfoProvider.mainchainSyncInfo!,
              justPercent: true,
            ),
            DividerDot(),
          ],
          if (enforcerConnected && !enforcerSynced) ...[
            ChainLoader(
              name: viewModel.blockInfoProvider.enforcer.name,
              syncInfo: viewModel.blockInfoProvider.enforcerSyncInfo!,
              justPercent: true,
            ),
            DividerDot(),
          ],
          if (additionalConnected && !additionalSynced) ...[
            ChainLoader(
              name: viewModel.blockInfoProvider.additionalConnection!.name,
              syncInfo: viewModel.blockInfoProvider.additionalSyncInfo!,
              justPercent: true,
            ),
          ],
          if (viewModel.blockInfoProvider.additionalConnection?.name.toLowerCase() == BitWindow().name.toLowerCase() &&
              mainchainSynced) ...[
            DividerDot(),
            SailText.secondary12(
              '${formatWithThousandSpacers(viewModel.blockInfoProvider.mainchainSyncInfo?.progressCurrent ?? 'Loading')} blocks',
            ),
          ] else if (additionalSynced) ...[
            DividerDot(),
            SailText.secondary12(
              '${formatWithThousandSpacers(viewModel.blockInfoProvider.additionalSyncInfo?.progressCurrent ?? 'Loading')} blocks',
            ),
          ],
        ],
      ),
    );
  }
}

class ChainLoader extends StatelessWidget {
  final String name;
  final SyncInfo syncInfo;
  final bool justPercent;

  const ChainLoader({
    super.key,
    required this.name,
    required this.syncInfo,
    this.justPercent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Tooltip(
        message: syncInfo.downloadProgress < 1
            ? 'Downloading $name\nProgress: ${syncInfo.progressCurrent} MB\nSize: ${syncInfo.progressGoal} MB'
            : '$name\nCurrent height ${syncInfo.progressCurrent}\nHeader height ${syncInfo.progressGoal}',
        child: ProgressBar(
          progress: syncInfo.progress,
          current: syncInfo.progressCurrent,
          goal: syncInfo.progressGoal,
          justPercent: justPercent,
        ),
      ),
    );
  }
}

class BalanceDisplay extends StatelessWidget {
  final double balance;
  final double pendingBalance;
  final bool balanceSyncing;
  final bool showUnconfirmed;
  final VoidCallback onToggleUnconfirmed;

  const BalanceDisplay({
    super.key,
    required this.balance,
    required this.pendingBalance,
    required this.balanceSyncing,
    required this.showUnconfirmed,
    required this.onToggleUnconfirmed,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onToggleUnconfirmed,
        child: SailRow(
          children: [
            Tooltip(
              message: 'Confirmed balance',
              child: SailRow(
                spacing: SailStyleValues.padding08,
                children: [
                  SailSVG.icon(
                    SailSVGAsset.iconCoins,
                    color: SailColorScheme.green,
                    width: SailStyleValues.iconSizeSecondary,
                    height: SailStyleValues.iconSizeSecondary,
                  ),
                  SailSkeletonizer(
                    description: 'Syncing wallet..',
                    enabled: balanceSyncing,
                    child: SailText.secondary12(
                      formatBitcoin(balance, symbol: 'BTC'),
                    ),
                  ),
                ],
              ),
            ),
            if (showUnconfirmed || pendingBalance > 0) const DividerDot(),
            if (showUnconfirmed || pendingBalance > 0)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: showUnconfirmed ? 1.0 : 0.0,
                child: Tooltip(
                  message: 'Unconfirmed balance',
                  child: SailRow(
                    spacing: SailStyleValues.padding08,
                    children: [
                      SailSVG.icon(
                        SailSVGAsset.iconCoins,
                        width: SailStyleValues.iconSizeSecondary,
                        height: SailStyleValues.iconSizeSecondary,
                      ),
                      SailText.secondary12(
                        formatBitcoin(pendingBalance, symbol: 'BTC'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class BalanceDisplayViewModel extends BaseViewModel with ChangeTrackingMixin {
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();
  bool _showUnconfirmed = false;

  BalanceDisplayViewModel() {
    initChangeTracker();
    _balanceProvider.addListener(_onChange);
  }

  void _onChange() {
    track('balance', balance);
    track('pendingBalance', pendingBalance);
    track('balanceSyncing', balanceSyncing);
    track('showUnconfirmed', showUnconfirmed);
    notifyIfChanged();
  }

  double get balance => _balanceProvider.balance;
  double get pendingBalance => _balanceProvider.pendingBalance;
  bool get balanceSyncing => !_balanceProvider.initialized;
  bool get showUnconfirmed => _showUnconfirmed;

  void toggleUnconfirmed() {
    _showUnconfirmed = !_showUnconfirmed;
    notifyListeners();
  }

  @override
  void dispose() {
    _balanceProvider.removeListener(_onChange);
    super.dispose();
  }
}
