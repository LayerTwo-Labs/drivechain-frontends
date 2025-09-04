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
          border: Border(top: BorderSide(color: SailTheme.of(context).colors.border)),
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
                              decoration: !model.initializingAny && model.connectionColor == SailColorScheme.red
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
                              child: SailSVG.fromAsset(SailSVGAsset.iconConnectionStatus, color: model.connectionColor),
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
                  if (!model.mainchain.connected ||
                      !(model.syncProvider.mainchainSyncInfo?.isSynced ?? false) ||
                      !onlyShowAdditional)
                    DaemonConnectionCard(
                      connection: model.mainchain,
                      syncInfo: model.syncProvider.mainchainSyncInfo,
                      restartDaemon: () =>
                          binaryProvider.start(binaryProvider.binaries.firstWhere((b) => b.name == BitcoinCore().name)),
                      stopDaemon: () =>
                          binaryProvider.stop(binaryProvider.binaries.firstWhere((b) => b.name == BitcoinCore().name)),
                      infoMessage: _getDownloadMessage(model.syncProvider.mainchainSyncInfo),
                      navigateToLogs: model.navigateToLogs,
                    ),
                  if (!model.enforcer.connected ||
                      !(model.syncProvider.enforcerSyncInfo?.isSynced ?? false) ||
                      !onlyShowAdditional)
                    DaemonConnectionCard(
                      connection: model.enforcer,
                      syncInfo: model.syncProvider.enforcerSyncInfo,
                      infoMessage:
                          _getDownloadMessage(model.syncProvider.enforcerSyncInfo) ??
                          (model.mainchain.initializingBinary
                              ? 'Waiting for mainchain to finish init'
                              : model.mainchain.inHeaderSync
                              ? 'Waiting for L1 to sync headers...'
                              : null),
                      restartDaemon: () =>
                          binaryProvider.start(binaryProvider.binaries.firstWhere((b) => b.name == Enforcer().name)),
                      stopDaemon: () =>
                          binaryProvider.stop(binaryProvider.binaries.firstWhere((b) => b.name == Enforcer().name)),
                      navigateToLogs: model.navigateToLogs,
                    ),
                  DaemonConnectionCard(
                    connection: additionalConnection.rpc,
                    syncInfo: model.syncProvider.additionalSyncInfo,
                    infoMessage: _getDownloadMessage(model.syncProvider.additionalSyncInfo),
                    restartDaemon: () => binaryProvider.start(
                      binaryProvider.binaries.firstWhere((b) => b.name == additionalConnection.rpc.binary.name),
                    ),
                    stopDaemon: () => binaryProvider.stop(
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

    if (!syncInfo.downloadInfo.isDownloading) {
      return null;
    }

    // Check if we're downloading (downloadProgress < 1)
    if (syncInfo.downloadInfo.progressPercent < 1) {
      final progressPercent = (syncInfo.downloadInfo.progressPercent * 100).toStringAsFixed(0);
      if (progressPercent == '100') {
        return null;
      } else {
        return syncInfo.downloadInfo.message;
      }
    }

    return 'Finishing up...';
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

  const Separator({super.key, required this.child, this.right = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
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

  const ConnectionMonitor({required this.rpc, required this.name});

  bool get connected => rpc.connected;
  bool get initializingBinary => rpc.initializingBinary;
  String? get connectionError => rpc.connectionError;
}

class BottomNavViewModel extends BaseViewModel with ChangeTrackingMixin {
  final ConnectionMonitor additionalConnection;

  // Required connections
  MainchainRPC get mainchain => GetIt.I.get<MainchainRPC>();
  EnforcerRPC get enforcer => GetIt.I.get<EnforcerRPC>();
  SyncProvider get syncProvider => GetIt.I.get<SyncProvider>();
  BinaryProvider get binaryProvider => GetIt.I.get<BinaryProvider>();

  final bool mainchainInfo;
  final Function(String, String) navigateToLogs;

  BottomNavViewModel({required this.additionalConnection, required this.mainchainInfo, required this.navigateToLogs}) {
    initChangeTracker();
    // Add listeners for required connections
    mainchain.addListener(_onChange);
    enforcer.addListener(_onChange);
    additionalConnection.rpc.addListener(_onChange);
    syncProvider.addListener(_onChange);
    syncProvider.listenDownloads();
  }

  void _onChange() {
    track('allConnected', allConnected);
    track('connectionColor', connectionColor);
    track('connectionStatus', connectionStatus);
    track('mainchainSyncInfo', syncProvider.mainchainSyncInfo);
    track('enforcerSyncInfo', syncProvider.enforcerSyncInfo);
    track('additionalSyncInfo', syncProvider.additionalSyncInfo);
    notifyIfChanged(); // Use change tracking for normal updates
  }

  // Connection status
  bool get allConnected => mainchain.connected && enforcer.connected && additionalConnection.connected;
  bool get initializingAny =>
      mainchain.initializingBinary || enforcer.initializingBinary || additionalConnection.initializingBinary;
  bool get downloadingAny =>
      syncProvider.mainchainSyncInfo?.downloadInfo.isDownloading ??
      syncProvider.enforcerSyncInfo?.downloadInfo.isDownloading ??
      syncProvider.additionalSyncInfo?.downloadInfo.isDownloading ??
      false;

  Color get connectionColor {
    if (initializingAny) {
      return SailColorScheme.orange;
    }

    if (mainchain.startupError != null) {
      return SailColorScheme.orange;
    }

    if (enforcer.startupError != null) {
      return SailColorScheme.orange;
    }

    if (additionalConnection.rpc.startupError != null) {
      return SailColorScheme.orange;
    }

    if (mainchain.connectionError != null ||
        enforcer.connectionError != null ||
        additionalConnection.connectionError != null) {
      return SailColorScheme.red;
    }

    if (!mainchain.connected) {
      return SailColorScheme.red;
    }

    if (!enforcer.connected) {
      return SailColorScheme.red;
    }

    if (!additionalConnection.connected) {
      return SailColorScheme.red;
    }

    if (downloadingAny) {
      return SailColorScheme.orange;
    }

    if (mainchain.inSync) {
      return SailColorScheme.orange;
    }

    if (!(syncProvider.enforcerSyncInfo?.isSynced ?? false)) {
      return SailColorScheme.orange;
    }

    if (!(syncProvider.additionalSyncInfo?.isSynced ?? false)) {
      return SailColorScheme.orange;
    }

    if (allConnected) {
      return SailColorScheme.green;
    }

    return SailColorScheme.orange;
  }

  String get connectionStatus {
    if (syncProvider.mainchainSyncInfo?.downloadInfo.isDownloading ?? false) {
      return 'Downloading mainchain...';
    }

    if (syncProvider.enforcerSyncInfo?.downloadInfo.isDownloading ?? false) {
      return 'Downloading enforcer...';
    }

    if (syncProvider.additionalSyncInfo?.downloadInfo.isDownloading ?? false) {
      return 'Downloading ${additionalConnection.name}...';
    }

    if (mainchain.initializingBinary) {
      return 'Initializing bitcoind..';
    }

    if (enforcer.initializingBinary || enforcer.startupError != null) {
      return 'Initializing enforcer..';
    }

    if (additionalConnection.initializingBinary) {
      return 'Initializing ${additionalConnection.name}..';
    }

    if (mainchain.connectionError != null || mainchain.startupError != null) {
      return mainchain.connectionError ?? mainchain.startupError!;
    }

    if (enforcer.connectionError != null || enforcer.startupError != null) {
      return enforcer.connectionError ?? enforcer.startupError!;
    }

    if (additionalConnection.connectionError != null || additionalConnection.rpc.startupError != null) {
      return additionalConnection.connectionError ?? additionalConnection.rpc.startupError!;
    }

    if (!mainchain.connected) {
      return 'Bitcoin Core not started';
    }

    if (!enforcer.connected) {
      return 'Enforcer not started';
    }

    if (!additionalConnection.connected) {
      return '${additionalConnection.name} not started';
    }

    if (mainchain.inSync) {
      return 'Syncing mainchain blocks';
    }

    if (!(syncProvider.enforcerSyncInfo?.isSynced ?? false)) {
      return 'Syncing enforcer blocks';
    }

    if (!(syncProvider.additionalSyncInfo?.isSynced ?? false)) {
      return 'Syncing ${additionalConnection.name} blocks';
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
    syncProvider.removeListener(_onChange);
    super.dispose();
  }
}

class ChainLoaders extends ViewModelWidget<BottomNavViewModel> {
  const ChainLoaders({super.key});

  @override
  Widget build(BuildContext context, BottomNavViewModel viewModel) {
    final mainchainConnected = viewModel.syncProvider.mainchainSyncInfo != null;
    final enforcerConnected = viewModel.syncProvider.enforcerSyncInfo != null;
    final additionalConnected = viewModel.syncProvider.additionalSyncInfo != null;

    final mainchainSynced = mainchainConnected && viewModel.syncProvider.mainchainSyncInfo!.isSynced;
    final enforcerSynced = enforcerConnected && viewModel.syncProvider.enforcerSyncInfo!.isSynced;
    final additionalSynced = additionalConnected && viewModel.syncProvider.additionalSyncInfo!.isSynced;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: SailRow(
        spacing: 0,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (mainchainConnected && !mainchainSynced) ...[
            ChainLoader(
              name: viewModel.syncProvider.mainchain.name,
              syncInfo: viewModel.syncProvider.mainchainSyncInfo!,
              justPercent: true,
            ),
            DividerDot(),
          ],
          if (enforcerConnected && !enforcerSynced) ...[
            ChainLoader(
              name: viewModel.syncProvider.enforcer.name,
              syncInfo: viewModel.syncProvider.enforcerSyncInfo!,
              justPercent: true,
            ),
            DividerDot(),
          ],
          if (additionalConnected && !additionalSynced) ...[
            ChainLoader(
              name: viewModel.syncProvider.additionalConnection!.name,
              syncInfo: viewModel.syncProvider.additionalSyncInfo!,
              justPercent: true,
            ),
          ],
          if (viewModel.syncProvider.additionalConnection?.name.toLowerCase() == BitWindow().name.toLowerCase() &&
              mainchainSynced) ...[
            DividerDot(),
            SailText.secondary12(
              '${formatWithThousandSpacers(viewModel.syncProvider.mainchainSyncInfo?.progressCurrent.toInt() ?? 'Loading')} blocks',
            ),
          ] else if (additionalSynced) ...[
            DividerDot(),
            SailText.secondary12(
              '${formatWithThousandSpacers(viewModel.syncProvider.additionalSyncInfo?.progressCurrent.toInt() ?? 'Loading')} blocks',
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
  final bool expanded;

  const ChainLoader({
    super.key,
    required this.name,
    required this.syncInfo,
    this.justPercent = false,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final widget = Tooltip(
      message: syncInfo.downloadInfo.isDownloading
          ? 'Downloading $name\n${syncInfo.downloadInfo.message}'
          : '$name\nCurrent height ${formatProgress(syncInfo.progressCurrent)}\nHeader height ${formatProgress(syncInfo.progressGoal)}',
      child: ProgressBar(current: syncInfo.progressCurrent, goal: syncInfo.progressGoal, justPercent: justPercent),
    );

    if (expanded) {
      return Expanded(child: widget);
    }

    return widget;
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
                    child: SailText.secondary12(formatBitcoin(balance, symbol: 'BTC')),
                  ),
                ],
              ),
            ),
            if (showUnconfirmed || pendingBalance > 0) const DividerDot(),
            if (showUnconfirmed || pendingBalance > 0)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: 1,
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
                      SailText.secondary12(formatBitcoin(pendingBalance, symbol: 'BTC')),
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
