import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';
import 'package:sidesail/config/sidechains.dart';
import 'package:sidesail/rpc/rpc_config.dart';
import 'package:sidesail/rpc/rpc_mainchain.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
import 'package:sidesail/widgets/containers/daemon_connection_card.dart';
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
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => BottomNavViewModel(navigateToSettings: widget.navigateToSettings),
      fireOnViewModelReadyOnce: true,
      onViewModelReady: (viewModel) => {
        if (!viewModel.mainchainConnected || !viewModel.sidechainConnected)
          {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              viewModel.displayConnectionStatusDialog(context);
            }),
          },
      },
      builder: ((context, viewModel, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _NodeConnectionStatus(
              onChipPressed: () => viewModel.displayConnectionStatusDialog(context),
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

  bool get sidechainConnected => _sideRPC.rpc.connected;
  bool get mainchainConnected => _mainRPC.connected;

  bool get sidechainInitializing => _sideRPC.rpc.initializingBinary;
  bool get mainchainInitializing => _mainRPC.initializingBinary;

  int get sidechainBlockCount => _sideRPC.rpc.blockCount;
  int get mainchainBlockCount => _mainRPC.blockCount;

  String? get sidechainError => _sideRPC.rpc.connectionError;
  String? get mainchainError => _mainRPC.connectionError;

  Sidechain get chain => _sideRPC.rpc.chain;

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
      maxWidth: 536,
      child: ViewModelBuilder.reactive(
        viewModelBuilder: () => BottomNavViewModel(navigateToSettings: navigateToSettings),
        builder: ((context, viewModel, child) {
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
                    chainName: 'Parent Chain',
                    initializing: _mainRPC.initializingBinary,
                    connected: _mainRPC.connected,
                    errorMessage: _mainRPC.connectionError,
                    restartDaemon: () => initMainchainBinary(context),
                  ),
                  DaemonConnectionCard(
                    chainName: _sideRPC.rpc.chain.name,
                    initializing: _mainRPC.inIBD ? true : _sideRPC.rpc.initializingBinary,
                    connected: _sideRPC.rpc.connected,
                    errorMessage: _mainRPC.inIBD
                        ? 'Waiting on L1 initial block download to complete...'
                        : _sideRPC.rpc.connectionError,
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
      _mainRPC.binary,
      bitcoinCoreBinaryArgs(_mainRPC.conf),
    );
  }

  Future<void> initSidechainBinary(
    BuildContext context,
  ) async {
    return _sideRPC.rpc.initBinary(
      context,
      _sideRPC.rpc.chain.binary,
      _sideRPC.rpc.binaryArgs(_mainRPC.conf),
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
      spacing: SailStyleValues.padding08,
      children: [
        if (viewModel.sidechainConnected || viewModel.sidechainInitializing)
          ConnectionStatusChip(
            chain: _sidechain.rpc.chain.name,
            initializing: viewModel.sidechainInitializing,
            blockHeight: viewModel.sidechainBlockCount,
            onPressed: onChipPressed,
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
