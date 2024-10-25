import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidesail/config/runtime_args.dart';
import 'package:sidesail/providers/balance_provider.dart';
import 'package:sidesail/rpc/rpc_mainchain.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
import 'package:sidesail/widgets/containers/chain_overview_card.dart';
import 'package:stacked/stacked.dart';

class BottomNav extends StatefulWidget {
  final VoidCallback navigateToSettings;

  const BottomNav({
    super.key,
    required this.navigateToSettings,
  });

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  @override
  Widget build(BuildContext context) {
    final tabsRouter = AutoTabsRouter.of(context);
    final theme = SailTheme.of(context);

    return ViewModelBuilder.reactive(
      viewModelBuilder: () => BottomNavViewModel(navigateToSettings: widget.navigateToSettings),
      fireOnViewModelReadyOnce: true,
      onViewModelReady: (model) => {
        if (!model.mainchainConnected || !model.sidechainConnected)
          {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              model.displayConnectionStatusDialog(context);
            }),
          },
      },
      builder: ((context, model, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              color: theme.colors.background,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: theme.colors.formFieldBorder, width: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    ChainOverviewCard(
                      chain: model.chain,
                      confirmedBalance: model.balance,
                      unconfirmedBalance: model.pendingBalance,
                      highlighted: tabsRouter.activeIndex == 0,
                      currentChain: true,
                      onPressed: RuntimeArgs.swappableChains
                          ? () {
                              tabsRouter.setActiveIndex(0);
                            }
                          : null,
                      inBottomNav: true,
                    ),
                    Expanded(child: Container()),
                    _NodeConnectionStatus(
                      onChipPressed: () => model.displayConnectionStatusDialog(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class BottomNavViewModel extends BaseViewModel {
  final VoidCallback navigateToSettings;

  final log = Logger(level: Level.debug);
  SidechainContainer get _sideRPC => GetIt.I.get<SidechainContainer>();
  MainchainRPC get _mainRPC => GetIt.I.get<MainchainRPC>();
  BalanceProvider get _balanceProvider => GetIt.I.get<BalanceProvider>();

  double get balance => _balanceProvider.balance;
  double get pendingBalance => _balanceProvider.pendingBalance;

  bool get sidechainConnected => _sideRPC.rpc.connected;
  bool get mainchainConnected => _mainRPC.connected;

  bool get sidechainInitializing => _sideRPC.rpc.initializingBinary;
  bool get mainchainInitializing => _mainRPC.initializingBinary;
  bool get inIBD => _mainRPC.inIBD;

  int get sidechainBlockCount => _sideRPC.rpc.blockCount;
  int get mainchainBlockCount => _mainRPC.blockCount;

  String? get sidechainError => _sideRPC.rpc.connectionError;
  String? get mainchainError => _mainRPC.connectionError;

  Chain get chain => _sideRPC.rpc.chain;

  BottomNavViewModel({required this.navigateToSettings}) {
    _sideRPC.addListener(notifyListeners);
    _mainRPC.addListener(notifyListeners);
  }

  @override
  void dispose() {
    super.dispose();
    _sideRPC.removeListener(notifyListeners);
    _mainRPC.removeListener(notifyListeners);
  }

  Future<void> displayConnectionStatusDialog(
    BuildContext context,
  ) async {
    await widgetDialog(
      context: context,
      action: 'Startup connection',
      dialogText: 'Daemon status',
      dialogType: DialogType.info,
      maxWidth: 566,
      child: ViewModelBuilder.reactive(
        viewModelBuilder: () => BottomNavViewModel(navigateToSettings: navigateToSettings),
        builder: ((context, model, child) {
          return SailColumn(
            spacing: SailStyleValues.padding20,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SailSpacing(SailStyleValues.padding08),
              if (!_mainRPC.connected || !_sideRPC.rpc.connected)
                SailText.secondary12('You cannot use ${_sideRPC.rpc.chain.name} until nodes are connected'),
              SailRow(
                spacing: SailStyleValues.padding12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DaemonConnectionCard(
                    connection: _mainRPC,
                    restartDaemon: () => initMainchainBinary(context),
                    infoMessage: null,
                  ),
                  DaemonConnectionCard(
                    connection: _sideRPC.rpc,
                    infoMessage: _mainRPC.inIBD ? 'Waiting for L1 initial block download to complete...' : null,
                    restartDaemon: () => initSidechainBinary(context),
                  ),
                ],
              ),
              const SailSpacing(SailStyleValues.padding10),
              SailRow(
                spacing: SailStyleValues.padding12,
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                children: [
                  SailTextButton(
                    label: 'Configure connection parameters',
                    onPressed: navigateToSettings,
                  ),
                  if (!_mainRPC.connected || !_sideRPC.rpc.connected)
                    SailButton.primary(
                      'Test connection',
                      onPressed: () {
                        _sideRPC.rpc.testConnection();
                        _mainRPC.testConnection();
                      },
                      size: ButtonSize.regular,
                    ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  Future<void> initMainchainBinary(BuildContext context) async {
    return _mainRPC.initBinary(
      context,
    );
  }

  Future<void> initSidechainBinary(
    BuildContext context,
  ) async {
    return _sideRPC.rpc.initBinary(
      context,
    );
  }
}

class _NodeConnectionStatus extends ViewModelWidget<BottomNavViewModel> {
  SidechainContainer get _sidechain => GetIt.I.get<SidechainContainer>();
  final VoidCallback onChipPressed;

  const _NodeConnectionStatus({
    required this.onChipPressed,
  });

  @override
  Widget build(BuildContext context, BottomNavViewModel viewModel) {
    return SailRow(
      spacing: 0,
      children: [
        if (viewModel.sidechainConnected || viewModel.sidechainInitializing || viewModel.inIBD)
          ConnectionStatusChip(
            chain: _sidechain.rpc.chain.name,
            initializing: viewModel.sidechainInitializing,
            blockHeight: viewModel.sidechainBlockCount,
            onPressed: onChipPressed,
            infoMessage: viewModel.inIBD ? 'Waiting for IBD' : null,
          )
        else
          ConnectionErrorChip(
            chain: _sidechain.rpc.chain.name,
            onPressed: onChipPressed,
          ),
        if (viewModel.mainchainConnected || viewModel.mainchainInitializing)
          ConnectionStatusChip(
            chain: 'Parent chain',
            initializing: viewModel.mainchainInitializing,
            blockHeight: viewModel.mainchainBlockCount,
            onPressed: onChipPressed,
            infoMessage: null,
          )
        else
          ConnectionErrorChip(
            chain: 'Parent chain',
            onPressed: onChipPressed,
          ),
      ],
    );
  }
}
