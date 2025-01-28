import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/pages/router.dart';
import 'package:sail_ui/providers/balance_provider.dart';
import 'package:sail_ui/rpcs/enforcer_rpc.dart';
import 'package:sail_ui/rpcs/mainchain_rpc.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/services/blockinfo_service.dart';
import 'package:stacked/stacked.dart';

class BottomNav extends StatelessWidget {
  final List<Widget> endWidgets;
  final ConnectionMonitor additionalConnection;
  final bool mainchainInfo;

  const BottomNav({
    super.key,
    required this.endWidgets,
    required this.additionalConnection,
    required this.mainchainInfo,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => BottomNavViewModel(
        additionalConnection: additionalConnection,
        mainchainInfo: mainchainInfo,
      ),
      fireOnViewModelReadyOnce: true,
      builder: ((context, model, child) {
        return SizedBox(
          height: 36,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey,
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
                      SailText.secondary12(formatBitcoin(model.balance, symbol: 'BTC')),
                    ],
                  ),
                ),
                const DividerDot(),
                Tooltip(
                  message: 'Unconfirmed balance',
                  child: SailRow(
                    spacing: SailStyleValues.padding08,
                    children: [
                      SailSVG.icon(
                        SailSVGAsset.iconCoins,
                        width: SailStyleValues.iconSizeSecondary,
                        height: SailStyleValues.iconSizeSecondary,
                      ),
                      SailText.secondary12(formatBitcoin(model.pendingBalance, symbol: 'BTC')),
                    ],
                  ),
                ),
                Expanded(child: Container()),
                SailRawButton(
                  onPressed: () => displayConnectionStatusDialog(context),
                  disabled: false,
                  loading: false,
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
                if (model.infoService.blockchainInfo.initialBlockDownload &&
                    model.infoService.blockchainInfo.blocks != model.infoService.blockchainInfo.headers)
                  Tooltip(
                    message:
                        'Current height: ${model.infoService.blockchainInfo.blocks}\nHeader height: ${model.infoService.blockchainInfo.headers}',
                    child: SailText.primary12(
                      'Downloading blocks (${model.infoService.verificationProgress}%)',
                    ),
                  ),
                if (model.infoService.blockchainInfo.initialBlockDownload &&
                    model.infoService.blockchainInfo.blocks != model.infoService.blockchainInfo.headers)
                  const DividerDot(),
                SailText.primary12(
                  '${formatWithThousandSpacers(model.infoService.blockchainInfo.blocks)} blocks',
                ),
                ...endWidgets,
                const SailSpacing(SailStyleValues.padding04),
              ],
            ),
          ),
        );
      }),
    );
  }

  Future<void> displayConnectionStatusDialog(
    BuildContext context,
  ) async {
    await widgetDialog(
      context: context,
      title: 'Daemon Status',
      subtitle:
          "You can use BitWindow without the enforcer, but it's not that interesting because the wallet does not work.",
      child: ViewModelBuilder.reactive(
        viewModelBuilder: () => BottomNavViewModel(
          mainchainInfo: mainchainInfo,
          additionalConnection: additionalConnection,
        ),
        builder: ((context, model, child) {
          return SailColumn(
            spacing: SailStyleValues.padding20,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SailSpacing(SailStyleValues.padding08),
              SailColumn(
                spacing: SailStyleValues.padding12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DaemonConnectionCard(
                    connection: model.mainchain,
                    restartDaemon: () => model.mainchain.initBinary(context),
                    infoMessage: null,
                    navigateToLogs: model.navigateToLogs,
                  ),
                  DaemonConnectionCard(
                    connection: model.enforcer,
                    infoMessage: model.mainchain.initializingBinary
                        ? 'Waiting for mainchain to finish init'
                        : model.mainchain.inIBD
                            ? 'Waiting for L1 initial block download to complete...'
                            : null,
                    restartDaemon: () => model.enforcer.initBinary(context),
                    navigateToLogs: model.navigateToLogs,
                  ),
                  DaemonConnectionCard(
                    connection: additionalConnection.rpc,
                    infoMessage: null,
                    restartDaemon: () => additionalConnection.rpc.initBinary(context),
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
    return SailSVG.fromAsset(SailSVGAsset.dividerDot);
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

class BottomNavViewModel extends BaseViewModel {
  final log = Logger(level: Level.debug);
  final ConnectionMonitor additionalConnection;

  // Required connections
  AppRouter get router => GetIt.I.get<AppRouter>();
  MainchainRPC get mainchain => GetIt.I.get<MainchainRPC>();
  EnforcerRPC get enforcer => GetIt.I.get<EnforcerRPC>();
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();
  late BlockInfoService infoService;
  final bool mainchainInfo;

  BottomNavViewModel({
    required this.additionalConnection,
    required this.mainchainInfo,
  }) {
    infoService = BlockInfoService(connection: mainchainInfo ? mainchain : additionalConnection.rpc);
    // Add listeners for required connections
    mainchain.addListener(notifyListeners);
    enforcer.addListener(notifyListeners);

    // Add listeners for additional connections
    additionalConnection.rpc.addListener(notifyListeners);
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
    if (!mainchain.connected || !enforcer.connected) {
      return SailColorScheme.red;
    }
    return SailColorScheme.orange;
  }

  String get connectionStatus {
    if (allConnected) {
      return 'All binaries connected';
    }

    List<String> errors = [];

    // Check required connections
    if (!mainchain.connected && mainchain.connectionError != null) {
      errors.add('Mainchain: ${mainchain.connectionError}');
    }
    if (!enforcer.connected && enforcer.connectionError != null) {
      errors.add('Enforcer: ${enforcer.connectionError}');
    }

    // Check additional connections
    if (!additionalConnection.connected && additionalConnection.error != null) {
      errors.add('${additionalConnection.name}: ${additionalConnection.error}');
    }

    return errors.isEmpty ? '' : errors.join('\n');
  }

  void navigateToLogs(String name, String logPath) {
    router.push(
      SailLogRoute(
        name: name,
        logPath: logPath,
      ),
    );
  }

  @override
  void dispose() {
    mainchain.removeListener(notifyListeners);
    enforcer.removeListener(notifyListeners);
    additionalConnection.rpc.removeListener(notifyListeners);

    super.dispose();
  }
}
