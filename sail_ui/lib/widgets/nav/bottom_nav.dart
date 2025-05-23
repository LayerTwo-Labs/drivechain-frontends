import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/providers/balance_provider.dart';
import 'package:sail_ui/rpcs/enforcer_rpc.dart';
import 'package:sail_ui/rpcs/mainchain_rpc.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/utils/change_tracker.dart';
import 'package:sail_ui/widgets/loaders/progress.dart';
import 'package:stacked/stacked.dart';

class BottomNav extends StatelessWidget {
  final List<Widget> endWidgets;
  final ConnectionMonitor additionalConnection;
  final bool mainchainInfo;
  final Function(String, String) navigateToLogs;

  const BottomNav({
    super.key,
    required this.endWidgets,
    required this.additionalConnection,
    required this.mainchainInfo,
    required this.navigateToLogs,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => BottomNavViewModel(
        additionalConnection: additionalConnection,
        mainchainInfo: mainchainInfo,
        navigateToLogs: navigateToLogs,
      ),
      fireOnViewModelReadyOnce: true,
      builder: ((context, model, child) {
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
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      model.setShowUnconfirmed(!model.showUnconfirmed);
                    },
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
                                description: 'Waiting for wallet to sync..',
                                enabled: model.balanceSyncing,
                                child: SailText.secondary12(
                                  formatBitcoin(model.balance, symbol: 'BTC'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (model.showUnconfirmed || model.pendingBalance > 0) const DividerDot(),
                        if (model.showUnconfirmed || model.pendingBalance > 0)
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: model.showUnconfirmed ? 1.0 : 0.0,
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
                                    formatBitcoin(model.pendingBalance, symbol: 'BTC'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Expanded(child: Container()),
                InkWell(
                  onTap: () async => displayConnectionStatusDialog(context),
                  child: Tooltip(
                    message: model.connectionStatus,
                    child: DecoratedBox(
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
                  ),
                ),
                const DividerDot(),
                ChainLoaders(),
                const DividerDot(),
                ...endWidgets,
                const SailSpacing(SailStyleValues.padding08),
              ],
            ),
          ),
        );
      }),
    );
  }

  void displayConnectionStatusDialog(
    BuildContext context,
  ) {
    widgetDialog(
      context: context,
      title: 'Daemon Status',
      subtitle:
          "You can use BitWindow without the enforcer, but it's not that interesting because the wallet does not work.",
      child: ViewModelBuilder.reactive(
        viewModelBuilder: () => BottomNavViewModel(
          mainchainInfo: mainchainInfo,
          additionalConnection: additionalConnection,
          navigateToLogs: navigateToLogs,
        ),
        builder: ((context, model, child) {
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
                  DaemonConnectionCard(
                    connection: model.mainchain,
                    syncInfo: model.blockInfoProvider.mainchainSyncInfo,
                    restartDaemon: () => model.mainchain.initBinary(),
                    infoMessage: null,
                    navigateToLogs: model.navigateToLogs,
                  ),
                  DaemonConnectionCard(
                    connection: model.enforcer,
                    syncInfo: model.blockInfoProvider.enforcerSyncInfo,
                    infoMessage: model.mainchain.initializingBinary
                        ? 'Waiting for mainchain to finish init'
                        : model.mainchain.inHeaderSync
                            ? 'Waiting for L1 to sync headers...'
                            : null,
                    restartDaemon: () => model.enforcer.initBinary(),
                    navigateToLogs: model.navigateToLogs,
                  ),
                  DaemonConnectionCard(
                    connection: additionalConnection.rpc,
                    syncInfo: model.blockInfoProvider.additionalSyncInfo,
                    infoMessage: null,
                    restartDaemon: () => additionalConnection.rpc.initBinary(),
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
  bool get initializing => rpc.initializingBinary;
  String? get error => rpc.connectionError;
}

class BottomNavViewModel extends BaseViewModel with ChangeTrackingMixin {
  final log = Logger(level: Level.debug);
  final ConnectionMonitor additionalConnection;

  // Required connections
  MainchainRPC get mainchain => GetIt.I.get<MainchainRPC>();
  EnforcerRPC get enforcer => GetIt.I.get<EnforcerRPC>();
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();
  BlockInfoProvider get blockInfoProvider => GetIt.I.get<BlockInfoProvider>();

  final bool mainchainInfo;
  final Function(String, String) navigateToLogs;
  bool showUnconfirmed = false;

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
    track('balance', balance);
    track('pendingBalance', pendingBalance);
    track('connectionColor', connectionColor);
    track('connectionStatus', connectionStatus);
    track('balanceSyncing', balanceSyncing);
    track('showUnconfirmed', showUnconfirmed);
    track('mainchainSyncInfo', blockInfoProvider.mainchainSyncInfo);
    track('enforcerSyncInfo', blockInfoProvider.enforcerSyncInfo);
    track('additionalSyncInfo', blockInfoProvider.additionalSyncInfo);
    notifyIfChanged();
  }

  // Balance getters
  double get balance => _balanceProvider.balance;
  double get pendingBalance => _balanceProvider.pendingBalance;

  // Connection status
  bool get allConnected => mainchain.connected && enforcer.connected && additionalConnection.connected;

  Color get connectionColor {
    if (allConnected) {
      return SailColorScheme.green;
    }

    if ((!mainchain.connected && !mainchain.initializingBinary) ||
        (!enforcer.connected && !enforcer.initializingBinary) ||
        (!additionalConnection.connected && !additionalConnection.initializing)) {
      // done initializing, but not connected
      return SailColorScheme.red;
    }
    return SailColorScheme.orange;
  }

  bool get balanceSyncing {
    if (allConnected) {
      return false;
    }

    if (balance > 0 || pendingBalance > 0) {
      return false;
    }

    return true;
  }

  String get connectionStatus {
    if (allConnected) {
      return 'All binaries connected';
    }

    List<String> errors = [];

    // Check required connections
    if (!mainchain.connected && mainchain.connectionError != null && !mainchain.initializingBinary) {
      errors.add('Mainchain: ${mainchain.connectionError}');
    }
    if (!enforcer.connected && enforcer.connectionError != null && !mainchain.initializingBinary) {
      errors.add('Enforcer: ${enforcer.connectionError}');
    }

    // Check additional connections
    if (!additionalConnection.connected && additionalConnection.error != null) {
      errors.add('${additionalConnection.name}: ${additionalConnection.error}');
    }

    return errors.isEmpty ? '' : errors.join('\n');
  }

  void setShowUnconfirmed(bool value) {
    showUnconfirmed = value;
    notifyListeners();
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
      constraints: const BoxConstraints(maxWidth: 700),
      child: SailRow(
        spacing: 0,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (mainchainConnected && !mainchainSynced) ...[
            ChainLoader(
              name: viewModel.blockInfoProvider.mainchain.name,
              syncInfo: viewModel.blockInfoProvider.mainchainSyncInfo!,
            ),
            DividerDot(),
          ],
          if (enforcerConnected && !enforcerSynced) ...[
            ChainLoader(
              name: viewModel.blockInfoProvider.enforcer.name,
              syncInfo: viewModel.blockInfoProvider.enforcerSyncInfo!,
            ),
            DividerDot(),
          ],
          if (additionalConnected && !additionalSynced) ...[
            ChainLoader(
              name: viewModel.blockInfoProvider.additionalConnection!.name,
              syncInfo: viewModel.blockInfoProvider.additionalSyncInfo!,
            ),
            DividerDot(),
          ],
          if (mainchainSynced && enforcerSynced && additionalSynced)
            SailText.primary12(
              '${formatWithThousandSpacers(viewModel.blockInfoProvider.mainchainSyncInfo?.blocks ?? 'Loading')} blocks',
            ),
        ],
      ),
    );
  }
}

class ChainLoader extends StatelessWidget {
  final String name;
  final SyncInfo syncInfo;

  const ChainLoader({
    super.key,
    required this.name,
    required this.syncInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Tooltip(
        message: '$name\nCurrent height ${syncInfo.blocks}\nHeader height ${syncInfo.headers}',
        child: ProgressBar(
          progress: syncInfo.verificationProgress,
          current: syncInfo.blocks,
          goal: syncInfo.headers,
        ),
      ),
    );
  }
}
