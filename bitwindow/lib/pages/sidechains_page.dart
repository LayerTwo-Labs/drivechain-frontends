import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/pages/explorer/block_explorer_dialog.dart';
import 'package:bitwindow/pages/sidechain_activation_management_page.dart';
import 'package:bitwindow/providers/sidechain_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:bitwindow/widgets/fast_withdrawal_tab.dart';
import 'package:bitwindow/widgets/starters_tab.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/gen/wallet/v1/wallet.pb.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class SidechainsPage extends StatelessWidget {
  const SidechainsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return QtPage(
      child: ViewModelBuilder.reactive(
        viewModelBuilder: () => SidechainsViewModel(),
        builder: (context, model, child) {
          return InlineTabBar(
            key: ValueKey('sidechains_page'),
            tabs: [
              TabItem(
                label: 'Overview',
                child: SidechainsTab(),
              ),
              TabItem(
                label: 'Fast Withdrawal',
                child: FastWithdrawalTab(),
              ),
              TabItem(
                label: 'Starters',
                child: StartersTab(),
              ),
            ],
            initialIndex: 0,
          );
        },
      ),
    );
  }
}

class SidechainsTab extends ViewModelWidget<SidechainsViewModel> {
  const SidechainsTab({super.key});

  @override
  Widget build(BuildContext context, SidechainsViewModel viewModel) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = SailStyleValues.padding08;
        final sidechainsWidth = max(480, constraints.maxWidth * 0.25);
        final depositsWidth = constraints.maxWidth - sidechainsWidth - spacing;

        return SailRow(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: spacing,
          children: [
            SizedBox(
              width: sidechainsWidth.toDouble(),
              child: SidechainsList(
                smallVersion: false,
              ),
            ),
            SizedBox(
              width: depositsWidth,
              child: const DepositWithdrawView(),
            ),
          ],
        );
      },
    );
  }
}

class SidechainsList extends ViewModelWidget<SidechainsViewModel> {
  final bool smallVersion;

  const SidechainsList({
    super.key,
    required this.smallVersion,
  });

  @override
  Widget build(BuildContext context, SidechainsViewModel viewModel) {
    // Check if network supports sidechains
    if (!viewModel.networkSupportsSidechains) {
      return SailCard(
        title: 'Sidechains',
        subtitle: 'Not available on this network',
        child: Padding(
          padding: const EdgeInsets.all(SailStyleValues.padding20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.primary20('Unlock Sidechains with BIP300'),
              const SailSpacing(SailStyleValues.padding20),
              SailText.secondary13(
                'Sidechains are only available on Drivechain-enabled networks (Forknet and Signet). '
                'These networks implement BIP300, which enables trustless two-way pegged sidechains.',
              ),
              const SailSpacing(SailStyleValues.padding20),
              SailText.primary15('What are Sidechains?'),
              const SailSpacing(SailStyleValues.padding08),
              SailText.secondary13(
                'Sidechains allow you to move your Bitcoin to separate blockchains with different features, '
                'while maintaining the security and scarcity of Bitcoin. Think of them as Bitcoin-backed '
                'altcoins that you can freely move between.',
              ),
              const SailSpacing(SailStyleValues.padding20),
              SailText.primary15('How to Enable Sidechains'),
              const SailSpacing(SailStyleValues.padding08),
              SailText.secondary13(
                '1. Go to Settings\n'
                '2. Switch to "Forknet" or "Signet" network\n'
                '3. Restart BitWindow\n'
                '4. Return to this tab to activate sidechains',
              ),
              const SailSpacing(SailStyleValues.padding20),
              SailText.primary15('Learn More'),
              const SailSpacing(SailStyleValues.padding08),
              SailText.secondary13(
                'BIP300 (Hashrate Escrows) and BIP301 (Blind Merged Mining) enable true sidechain functionality. '
                'Visit drivechain.info to learn more about how Drivechain works and why it matters for Bitcoin.',
              ),
            ],
          ),
        ),
      );
    }

    final error = viewModel.isUsingBitcoinCoreWallet
        ? 'Switch to your enforcer wallet to interact with sidechains'
        : viewModel.error('sidechain');

    return SailCard(
      title: 'Sidechains',
      titleTooltip:
          'List of all active sidechains with accompanying balance, and all empty slots where future sidechains will be added',
      subtitle: viewModel._enforcerRPC.initializingBinary ? 'Enforcer is initializing...' : null,
      error: viewModel._enforcerRPC.initializingBinary ? null : error,
      widgetHeaderEnd: smallVersion
          ? null
          : SailToggle(
              label: 'Show only filled slots',
              value: viewModel.showOnlyFilled,
              onChanged: (value) => viewModel.setShowOnlyFilled(value),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: SailSkeletonizer(
              description: 'Waiting for enforcer to become available..',
              enabled: viewModel.loading,
              child: viewModel.showOnlyFilled ? OnlyFilledTable() : FullTable(),
            ),
          ),
          const SizedBox(height: SailStyleValues.padding16),
          if (!smallVersion)
            Center(
              child: SailButton(
                label: 'Add / Remove',
                onPressed: viewModel.isUsingBitcoinCoreWallet
                    ? null
                    : () => showSidechainActivationManagementModal(context),
              ),
            ),
        ],
      ),
    );
  }
}

class OnlyFilledTable extends ViewModelWidget<SidechainsViewModel> {
  const OnlyFilledTable({super.key});

  @override
  Widget build(BuildContext context, SidechainsViewModel viewModel) {
    final formatter = GetIt.I<FormatterProvider>();

    // Filter to only show filled slots
    final filledSlots = <int>[];
    for (int slotNumber = 0; slotNumber < viewModel.sidechains.length; slotNumber++) {
      if (viewModel.sidechains[slotNumber] != null) {
        filledSlots.add(slotNumber);
      }
    }

    return ListenableBuilder(
      listenable: formatter,
      builder: (context, child) => SailTable(
        key: ValueKey('sidechains_table_filled'),
        getRowId: (index) => filledSlots[index].toString(),
        headerBuilder: (context) => [
          SailTableHeaderCell(
            name: 'Slot',
            onSort: () => viewModel.sortSidechains('slot'),
          ),
          SailTableHeaderCell(
            name: 'Name',
            onSort: () => viewModel.sortSidechains('name'),
          ),
          SailTableHeaderCell(
            name: 'Balance',
            onSort: () => viewModel.sortSidechains('balance'),
          ),
          SailTableHeaderCell(
            name: 'Action',
            onSort: () => viewModel.sortSidechains('action'),
          ),
          SailTableHeaderCell(
            name: 'Settings',
            onSort: () => viewModel.sortSidechains('update'),
          ),
        ],
        rowBuilder: (context, row, selected) {
          final slot = filledSlots[row]; // Get the actual slot number from filtered list
          final sidechain = viewModel.sidechains[slot];
          final textColor = context.sailTheme.colors.text;
          final buttonWidget = viewModel.sidechainWidget(slot);
          final updateAvailable = viewModel.updateAvailable(slot);
          final binary = viewModel.sidechainForSlot(slot);

          return [
            SailTableCell(value: '$slot:', textColor: textColor),
            SailTableCell(value: sidechain?.info.title ?? '', textColor: textColor),
            SailTableCell(
              value: formatter.formatSats(sidechain?.info.balanceSatoshi.toInt() ?? 0),
              textColor: textColor,
            ),
            SailTableCell(
              key: buttonWidget?.key,
              value: '                    ',
              child: buttonWidget,
            ),
            if (binary != null)
              SailTableCell(
                value: '    ',
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: 40,
                    maxHeight: 40,
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: Stack(
                        clipBehavior: Clip.hardEdge,
                        children: [
                          SailButton(
                            variant: ButtonVariant.outline,
                            label: '',
                            icon: SailSVGAsset.settings,
                            insideTable: true,
                            onPressed: viewModel.isUsingBitcoinCoreWallet
                                ? null
                                : () async {
                                    await showDialog(
                                      context: context,
                                      builder: (context) => ChainSettingsModal(
                                        connection: viewModel.rpcForSlot(slot)!,
                                      ),
                                    );
                                  },
                          ),
                          if (updateAvailable)
                            Positioned(
                              top: 4,
                              right: 6,
                              child: Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            else
              SailTableCell(value: ''),
          ];
        },
        rowCount: filledSlots.length, // Only show filled slots
        sortAscending: viewModel.sortAscending,
        sortColumnIndex: ['slot', 'name', 'balance', 'action', 'update'].indexOf(viewModel.sortColumn),
        onSort: (columnIndex, ascending) => viewModel.sortSidechains(viewModel.sortColumn),
        selectedRowId: viewModel.selectedIndex?.toString(),
        // rowId is the SLOT NUMBER (e.g., "2", "4", "98") from getRowId
        onSelectedRow: (rowId) => viewModel.toggleSelection(int.parse(rowId ?? '0')),
        onDoubleTap: (rowId) {
          final sidechain = viewModel.sidechains[int.parse(rowId)];
          if (sidechain == null || sidechain.info.chaintipTxid == '') {
            return;
          }

          showTransactionDetails(context, rowId);
        },
        contextMenuItems: (rowId) {
          final sidechain = viewModel.sidechains[int.parse(rowId)];
          if (sidechain == null || sidechain.info.chaintipTxid == '') {
            return [];
          }

          return [
            SailMenuItem(
              onSelected: () => showTransactionDetails(context, sidechain.info.chaintipTxid),
              child: SailText.primary12('Show Chaintip Transaction'),
            ),
          ];
        },
      ),
    );
  }
}

class FullTable extends ViewModelWidget<SidechainsViewModel> {
  const FullTable({super.key});

  @override
  Widget build(BuildContext context, SidechainsViewModel viewModel) {
    final formatter = GetIt.I<FormatterProvider>();

    return ListenableBuilder(
      listenable: formatter,
      builder: (context, child) => SailTable(
        key: ValueKey('sidechains_table_full'),
        getRowId: (index) => index.toString(),
        headerBuilder: (context) => [
          SailTableHeaderCell(
            name: 'Slot',
            onSort: () => viewModel.sortSidechains('slot'),
          ),
          SailTableHeaderCell(
            name: 'Name',
            onSort: () => viewModel.sortSidechains('name'),
          ),
          SailTableHeaderCell(
            name: 'Balance',
            onSort: () => viewModel.sortSidechains('balance'),
          ),
          SailTableHeaderCell(
            name: 'Action',
            onSort: () => viewModel.sortSidechains('action'),
          ),
          SailTableHeaderCell(
            name: 'Settings',
            onSort: () => viewModel.sortSidechains('update'),
          ),
        ],
        rowBuilder: (context, row, selected) {
          final slot = row; // This is now the slot number (0-255)
          final sidechain = viewModel.sidechains[slot];
          final textColor = sidechain == null ? context.sailTheme.colors.textSecondary : context.sailTheme.colors.text;
          final buttonWidget = viewModel.sidechainWidget(slot);
          final updateAvailable = viewModel.updateAvailable(slot);
          final binary = viewModel.sidechainForSlot(slot);

          return [
            SailTableCell(value: '$slot:', textColor: textColor),
            SailTableCell(value: sidechain?.info.title ?? '', textColor: textColor),
            SailTableCell(
              value: formatter.formatSats(sidechain?.info.balanceSatoshi.toInt() ?? 0),
              textColor: textColor,
            ),
            SailTableCell(
              key: buttonWidget?.key,
              value: buttonWidget?.toString() ?? '',
              child: buttonWidget,
            ),
            if (binary != null)
              SailTableCell(
                value: '    ', // Use spaces to represent the width needed for the settings button
                child: Stack(
                  children: [
                    SailButton(
                      variant: ButtonVariant.outline,
                      label: '',
                      icon: SailSVGAsset.settings,
                      insideTable: true,
                      onPressed: viewModel.isUsingBitcoinCoreWallet
                          ? null
                          : () async {
                              await showDialog(
                                context: context,
                                builder: (context) => ChainSettingsModal(
                                  connection: viewModel.rpcForSlot(slot)!,
                                ),
                              );
                            },
                    ),
                    if (updateAvailable)
                      Positioned(
                        top: 4,
                        right: 6,
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              )
            else
              Container(),
          ];
        },
        rowCount: 256, // Show all slots
        sortAscending: viewModel.sortAscending,
        sortColumnIndex: ['slot', 'name', 'balance', 'action', 'update'].indexOf(viewModel.sortColumn),
        onSort: (columnIndex, ascending) => viewModel.sortSidechains(viewModel.sortColumn),
        selectedRowId: viewModel.selectedIndex?.toString(),
        onSelectedRow: (rowId) => viewModel.toggleSelection(int.parse(rowId ?? '0')),
        onDoubleTap: (rowId) {
          final sidechain = viewModel.sidechains[int.parse(rowId)];
          if (sidechain == null || sidechain.info.chaintipTxid == '') {
            return;
          }

          showTransactionDetails(context, rowId);
        },
        contextMenuItems: (rowId) {
          final sidechain = viewModel.sidechains[int.parse(rowId)];
          if (sidechain == null || sidechain.info.chaintipTxid == '') {
            return [];
          }

          return [
            SailMenuItem(
              onSelected: () => showTransactionDetails(context, sidechain.info.chaintipTxid),
              child: SailText.primary12('Show Chaintip Transaction'),
            ),
          ];
        },
      ),
    );
  }
}

class SidechainsViewModel extends BaseViewModel with ChangeTrackingMixin {
  final TransactionProvider _transactionsProvider = GetIt.I.get<TransactionProvider>();
  final BalanceProvider _balanceProvider = GetIt.I.get<BalanceProvider>();
  final BitwindowRPC _api = GetIt.I.get<BitwindowRPC>();
  final SidechainProvider _sidechainProvider = GetIt.I.get<SidechainProvider>();
  final EnforcerRPC _enforcerRPC = GetIt.I.get<EnforcerRPC>();
  final BinaryProvider _binaryProvider = GetIt.I.get<BinaryProvider>();
  final BitcoinConfProvider _confProvider = GetIt.I.get<BitcoinConfProvider>();
  WalletReaderProvider get _walletReader => GetIt.I<WalletReaderProvider>();

  final TextEditingController addressController = TextEditingController();
  final TextEditingController depositAmountController = TextEditingController();
  final TextEditingController feeController = TextEditingController(text: '0.0001');

  SidechainsViewModel() {
    initChangeTracker();

    addressController.addListener(_onChange);
    depositAmountController.addListener(_onChange);
    feeController.addListener(_onChange);

    _sidechainProvider.addListener(_onChange);
    _sidechainProvider.fetch();

    _binaryProvider.addListener(_onChange);
    _binaryProvider.listenDownloadManager(notifyListeners);
  }

  bool get loading => _enforcerRPC.initializingBinary;

  /// Check if current network supports sidechains (L2L networks only)
  bool get networkSupportsSidechains {
    final network = _confProvider.network;
    return network == BitcoinNetwork.NETWORK_FORKNET ||
        network == BitcoinNetwork.NETWORK_SIGNET ||
        network == BitcoinNetwork.NETWORK_REGTEST;
  }

  bool get isUsingBitcoinCoreWallet {
    final activeWallet = _walletReader.activeWallet;
    if (activeWallet == null) return false;
    return activeWallet.walletType != BinaryType.enforcer;
  }

  List<SidechainOverview?> get sidechains => _sidechainProvider.sidechains;
  List<SidechainOverview?> _sortedSidechains = [];

  String sortColumn = 'slot';
  bool sortAscending = true;

  bool showOnlyFilled = true;
  void setShowOnlyFilled(bool value) {
    showOnlyFilled = value;
    notifyListeners();
  }

  Sidechain? sidechainForSlot(int slot) {
    return _binaryProvider.binaries.firstWhereOrNull((b) => b is Sidechain && b.slot == slot) as Sidechain?;
  }

  RPCConnection? rpcForSlot(int slot) {
    final sidechain = sidechainForSlot(slot);
    if (sidechain == null) {
      return null;
    }

    // Check if binary is running
    final rpc = switch (sidechain) {
      var b when b is BitcoinCore => _binaryProvider.mainchainRPC,
      var b when b is Enforcer => _binaryProvider.enforcerRPC,
      var b when b is BitWindow => _binaryProvider.bitwindowRPC,
      var b when b is Thunder => _binaryProvider.thunderRPC,
      var b when b is BitNames => _binaryProvider.bitnamesRPC,
      var b when b is BitAssets => _binaryProvider.bitassetsRPC,
      var b when b is ZSide => _binaryProvider.zsideRPC,
      _ => null,
    };

    return rpc;
  }

  Widget? sidechainWidget(int slot) {
    final sidechain = sidechainForSlot(slot);

    if (sidechain == null) {
      return null;
    }

    // Disable all interactions when using Bitcoin Core wallet
    if (isUsingBitcoinCoreWallet) {
      return SailButton(
        key: ValueKey('disabled_slot_${sidechain.slot}_${sidechain.name}'),
        label: 'Disabled',
        onPressed: null,
        insideTable: true,
      );
    }

    // Check if binary is running
    final isRunning = switch (sidechain) {
      var b when b is BitcoinCore => _binaryProvider.mainchainConnected,
      var b when b is Enforcer => _binaryProvider.enforcerConnected,
      var b when b is BitWindow => _binaryProvider.bitwindowConnected,
      var b when b is Thunder => _binaryProvider.thunderConnected,
      var b when b is BitNames => _binaryProvider.bitnamesConnected,
      var b when b is BitAssets => _binaryProvider.bitassetsConnected,
      var b when b is ZSide => _binaryProvider.zsideConnected,
      _ => false,
    };

    // Check if binary is initializing
    final isInitializing = switch (sidechain) {
      var b when b is BitcoinCore => _binaryProvider.mainchainInitializing,
      var b when b is Enforcer => _binaryProvider.enforcerInitializing,
      var b when b is BitWindow => _binaryProvider.bitwindowInitializing,
      var b when b is Thunder => _binaryProvider.thunderInitializing,
      var b when b is BitNames => _binaryProvider.bitnamesInitializing,
      var b when b is BitAssets => _binaryProvider.bitassetsInitializing,
      var b when b is ZSide => _binaryProvider.zsideInitializing,
      _ => false,
    };

    final stopping = switch (sidechain) {
      var b when b is BitcoinCore => _binaryProvider.mainchainStopping,
      var b when b is Enforcer => _binaryProvider.enforcerStopping,
      var b when b is BitWindow => _binaryProvider.bitwindowStopping,
      var b when b is Thunder => _binaryProvider.thunderStopping,
      var b when b is BitNames => _binaryProvider.bitnamesStopping,
      var b when b is BitAssets => _binaryProvider.bitassetsStopping,
      var b when b is ZSide => _binaryProvider.zsideStopping,
      _ => false,
    };

    final downloading = switch (sidechain) {
      var b when b is BitcoinCore => _binaryProvider.mainchainDownloadState.isDownloading,
      var b when b is Enforcer => _binaryProvider.enforcerDownloadState.isDownloading,
      var b when b is BitWindow => _binaryProvider.bitwindowDownloadState.isDownloading,
      var b when b is Thunder => _binaryProvider.thunderDownloadState.isDownloading,
      var b when b is BitNames => _binaryProvider.bitnamesDownloadState.isDownloading,
      var b when b is BitAssets => _binaryProvider.bitassetsDownloadState.isDownloading,
      var b when b is ZSide => _binaryProvider.zsideDownloadState.isDownloading,
      _ => false,
    };

    final isProcessRunning = _binaryProvider.isRunning(sidechain);

    if (downloading) {
      // Use the combined state getter for consistency
      final downloadInfo = _binaryProvider.downloadProgress(sidechain.type);

      final syncInfo = SyncInfo(
        progressCurrent: downloadInfo.progress,
        progressGoal: downloadInfo.total,
        lastBlockAt: null,
        downloadInfo: downloadInfo,
      );

      return ChainLoader(
        name: sidechain.name,
        syncInfo: syncInfo,
        justPercent: true,
        expanded: false,
      );
    }

    if (stopping) {
      return SailButton(
        key: ValueKey('stopping_slot_${sidechain.slot}_${sidechain.name}'),
        label: 'Stopping...',
        onPressed: null,
        insideTable: true,
        loading: true,
      );
    }

    if (isRunning) {
      return SailButton(
        key: ValueKey('stop_slot_${sidechain.slot}_${sidechain.name}'),
        label: 'Stop',
        onPressed: () async => _binaryProvider.stop(sidechain),
        insideTable: true,
      );
    }

    if (isInitializing) {
      return SailButton(
        key: ValueKey('launching_slot_${sidechain.slot}_${sidechain.name}'),
        label: 'Launching...',
        onPressed: null,
        insideTable: true,
        loading: true,
      );
    }

    if (isProcessRunning) {
      return SailButton(
        key: ValueKey('kill_slot_${sidechain.slot}_${sidechain.name}'),
        label: 'Kill',
        onPressed: () => _binaryProvider.stop(sidechain),
        insideTable: true,
      );
    }

    if (!sidechain.isDownloaded) {
      return SailButton(
        key: ValueKey('download_slot_${sidechain.slot}_${sidechain.name}'),
        label: 'Download',
        onPressed: () async => await _binaryProvider.download(sidechain),
        insideTable: true,
      );
    }

    if (sidechain.isDownloaded) {
      return SailButton(
        key: ValueKey('start_slot_${sidechain.slot}_${sidechain.name}'),
        label: 'Start',
        onPressed: () async => await _binaryProvider.start(sidechain),
        insideTable: true,
      );
    }

    return SailButton(
      key: ValueKey('error_slot_${sidechain.slot}_${sidechain.name}'),
      label: 'Devs did you wrong...',
      onPressed: () => throw Exception('Send them this error'),
      insideTable: true,
    );
  }

  bool updateAvailable(int slot) {
    final sidechain = sidechainForSlot(slot);

    if (sidechain == null) {
      return false;
    }

    return sidechain.updateAvailable;
  }

  List<SidechainOverview?> get sortedSidechains {
    if (!listEquals(_sortedSidechains, sidechains)) {
      _sortedSidechains = List<SidechainOverview?>.from(sidechains);
      _sortEntries();
    }
    return _sortedSidechains;
  }

  void sortSidechains(String column) {
    if (sortColumn == column) {
      sortAscending = !sortAscending;
    } else {
      sortColumn = column;
      sortAscending = true;
    }
    _sortEntries();
    notifyListeners();
  }

  void _sortEntries() {
    _sortedSidechains.sort((a, b) {
      if (a == null && b == null) return 0;
      if (a == null) return sortAscending ? 1 : -1;
      if (b == null) return sortAscending ? -1 : 1;

      dynamic aValue;
      dynamic bValue;

      switch (sortColumn) {
        case 'index':
          aValue = sidechains.indexOf(a);
          bValue = sidechains.indexOf(b);
          break;
        case 'balance':
          aValue = a.info.balanceSatoshi;
          bValue = b.info.balanceSatoshi;
          break;
        case 'title':
          aValue = a.info.title;
          bValue = b.info.title;
          break;
        default:
          return 0;
      }

      return sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });
  }

  int? _selectedIndex;

  int? get selectedIndex => _selectedIndex;

  void toggleSelection(int index) {
    if (_selectedIndex == index) {
      _selectedIndex = null; // Deselect if the same item is selected again
    } else {
      _selectedIndex = index; // Select the new item
    }
    notifyListeners();
  }

  void decrementSelectedIndex() {
    _selectedIndex = max(0, (_selectedIndex ?? 0) - 1);
    notifyListeners();
  }

  void incrementSelectedIndex() {
    _selectedIndex = min(255, (_selectedIndex ?? 0) + 1);
    notifyListeners();
  }

  List<ListSidechainDepositsResponse_SidechainDeposit> _sortedDeposits = [];
  String depositSortColumn = 'amount';
  bool depositSortAscending = true;

  List<ListSidechainDepositsResponse_SidechainDeposit> get sortedDeposits {
    if (!listEquals(_sortedDeposits, recentDeposits)) {
      _sortedDeposits = List<ListSidechainDepositsResponse_SidechainDeposit>.from(recentDeposits);
      _sortDeposits();
    }
    return _sortedDeposits;
  }

  List<WithdrawalBundle> get sortedWithdrawals {
    return _sidechainProvider.sidechains[_selectedIndex ?? 255]?.withdrawals ?? [];
  }

  void sortDeposits(String column) {
    if (depositSortColumn == column) {
      depositSortAscending = !depositSortAscending;
    } else {
      depositSortColumn = column;
      depositSortAscending = true;
    }
    _sortDeposits();
    notifyListeners();
  }

  void _sortDeposits() {
    _sortedDeposits.sort((a, b) {
      dynamic aValue;
      dynamic bValue;

      switch (depositSortColumn) {
        case 'amount':
          aValue = a.amount;
          bValue = b.amount;
          break;
        case 'txid':
          aValue = a.txid;
          bValue = b.txid;
          break;
        case 'confirmations':
          aValue = a.confirmations;
          bValue = b.confirmations;
          break;
        default:
          return 0;
      }

      return depositSortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });
  }

  List<ListSidechainDepositsResponse_SidechainDeposit> get recentDeposits =>
      _sidechainProvider.sidechains[_selectedIndex ?? 255]?.deposits ?? [];

  Future<void> clearAddress() async {
    addressController.clear();
    notifyListeners();
  }

  Future<void> formatAddress() async {
    if (_selectedIndex == null) {
      return;
    }

    addressController.text = formatDepositAddress(addressController.text, _selectedIndex!);
    notifyListeners();
  }

  String? get formatError {
    if (addressController.text.isEmpty) {
      return 'A deposit address from your sidechain must be set before you can format it.';
    }

    if (addressController.text.contains('_')) {
      return 'You can only format an address once. Unformatted addresses can not contain underscores.';
    }

    return null;
  }

  void deposit(BuildContext context) async {
    if (double.tryParse(depositAmountController.text) == null) {
      showSnackBar(context, 'Invalid amount, enter a number');
      return;
    }
    if (double.tryParse(feeController.text) == null) {
      showSnackBar(context, 'Invalid fee, enter a number');
      return;
    }

    try {
      final walletId = _walletReader.activeWalletId;
      if (walletId == null) throw Exception('No active wallet');

      setBusy(true);
      await _api.wallet.createSidechainDeposit(
        walletId,
        _selectedIndex ?? 255,
        addressController.text,
        double.parse(depositAmountController.text),
        double.parse(feeController.text),
      );
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, 'Could not create deposit:\n$e');
      }
    } finally {
      setBusy(false);
    }

    // refetching the transaction list also triggers the balance to be updated
    await _transactionsProvider.fetch();
    // refetching the balance also triggers the balance to be updated
    await _balanceProvider.fetch();
    // refetch sidechain transaction list
    await _sidechainProvider.fetch();
  }

  @override
  void dispose() {
    super.dispose();
    _sidechainProvider.removeListener(_onChange);
    addressController.removeListener(_onChange);
    depositAmountController.removeListener(_onChange);
    feeController.removeListener(_onChange);
    _binaryProvider.removeListener(_onChange);
  }

  void _onChange() {
    // Core data that affects the UI
    track('sidechains', _sidechainProvider.sidechains);
    track('recentDeposits', recentDeposits);

    // UI state that affects rendering
    track('showOnlyFilled', showOnlyFilled);
    track('selectedIndex', selectedIndex);

    // Sorting state
    track('sortColumn', sortColumn);
    track('sortAscending', sortAscending);
    track('depositSortColumn', depositSortColumn);
    track('depositSortAscending', depositSortAscending);

    // Text input values
    track('depositAmount', depositAmountController.text);
    track('addressController', addressController.text);
    track('fee', feeController.text);

    // Binary states that affect sidechainWidget() rendering
    track('binaryStates', _getBinaryStates());

    // Loading and error states
    track('loading', loading);
    // Error handling
    final hasChanges = track('error', _sidechainProvider.error);
    if (hasChanges) {
      setErrorForObject('sidechain', _sidechainProvider.error);
    }

    notifyIfChanged();
  }

  // Helper method to track binary states efficiently
  Map<String, dynamic> _getBinaryStates() {
    final states = {
      'mainchainConnected': _binaryProvider.mainchainConnected,
      'enforcerConnected': _binaryProvider.enforcerConnected,
      'bitwindowConnected': _binaryProvider.bitwindowConnected,
      'thunderConnected': _binaryProvider.thunderConnected,
      'bitnamesConnected': _binaryProvider.bitnamesConnected,
      'bitassetsConnected': _binaryProvider.bitassetsConnected,
      'mainchainInitializing': _binaryProvider.mainchainInitializing,
      'enforcerInitializing': _binaryProvider.enforcerInitializing,
      'bitwindowInitializing': _binaryProvider.bitwindowInitializing,
      'thunderInitializing': _binaryProvider.thunderInitializing,
      'bitnamesInitializing': _binaryProvider.bitnamesInitializing,
      'bitassetsInitializing': _binaryProvider.bitassetsInitializing,
      'mainchainStopping': _binaryProvider.mainchainStopping,
      'enforcerStopping': _binaryProvider.enforcerStopping,
      'bitwindowStopping': _binaryProvider.bitwindowStopping,
      'thunderStopping': _binaryProvider.thunderStopping,
      'bitnamesStopping': _binaryProvider.bitnamesStopping,
      'bitassetsStopping': _binaryProvider.bitassetsStopping,
      // Track complete download states for better change detection
      'bitnamesDownloadState': _binaryProvider.bitnamesDownloadState,
      'bitassetsDownloadState': _binaryProvider.bitassetsDownloadState,
      'mainchainDownloadState': _binaryProvider.mainchainDownloadState,
      'enforcerDownloadState': _binaryProvider.enforcerDownloadState,
      'bitwindowDownloadState': _binaryProvider.bitwindowDownloadState,
      'thunderDownloadState': _binaryProvider.thunderDownloadState,
    };

    return states;
  }
}

class DepositWithdrawView extends ViewModelWidget<SidechainsViewModel> {
  const DepositWithdrawView({super.key});

  @override
  Widget build(BuildContext context, SidechainsViewModel viewModel) {
    return const InlineTabBar(
      tabs: [
        TabItem(
          label: 'Create Deposits',
          icon: SailSVGAsset.iconDeposit,
          child: MakeDepositsView(),
        ),
        TabItem(
          label: 'See Withdrawals',
          icon: SailSVGAsset.iconWithdraw,
          child: SeeWithdrawalsView(),
        ),
      ],
      initialIndex: 0,
    );
  }
}

class MakeDepositsView extends ViewModelWidget<SidechainsViewModel> {
  const MakeDepositsView({super.key});

  @override
  Widget build(BuildContext context, SidechainsViewModel viewModel) {
    final isDisabled = viewModel.isUsingBitcoinCoreWallet;

    return SailCard(
      error: isDisabled ? 'Switch to your enforcer wallet to interact with sidechains' : null,
      bottomPadding: false,
      child: SailColumn(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: SailStyleValues.padding08,
        children: [
          SailRow(
            spacing: SailStyleValues.padding08,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 2, // take up 2/3 of the space
                child: SailTextField(
                  label: 'Sidechain Deposit Address',
                  controller: viewModel.addressController,
                  hintText: 's${viewModel._selectedIndex ?? 0}_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx_xxxxxx',
                  size: TextFieldSize.small,
                  enabled: !isDisabled,
                ),
              ),
              SailButton(
                variant: ButtonVariant.icon,
                onPressed: isDisabled
                    ? null
                    : () async {
                        try {
                          final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
                          if (clipboardData?.text != null) {
                            viewModel.addressController.text = clipboardData!.text!;
                            viewModel.notifyListeners(); // Make sure UI updates
                          }
                        } catch (e) {
                          if (!context.mounted) return;
                          showSnackBar(context, 'Error accessing clipboard');
                        }
                      },
                icon: SailSVGAsset.iconCopy,
              ),
              Tooltip(
                message: isDisabled ? 'Disabled' : (viewModel.formatError ?? 'Format as deposit address'),
                child: SailButton(
                  variant: ButtonVariant.icon,
                  onPressed: viewModel.formatAddress,
                  disabled: isDisabled || viewModel.formatError != null,
                  icon: SailSVGAsset.iconFormat,
                ),
              ),
            ],
          ),
          SailRow(
            spacing: SailStyleValues.padding08,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 2, // take up 2/3 of the space
                child: NumericField(
                  label: 'Deposit Amount',
                  controller: viewModel.depositAmountController,
                  hintText: '0.00',
                  enabled: !isDisabled,
                ),
              ),
              UnitDropdown(
                value: Unit.BTC,
                onChanged: (_) => {},
                enabled: false,
              ),
              Expanded(
                child: Container(),
              ),
            ],
          ),
          SailPadding(
            padding: const EdgeInsets.symmetric(vertical: SailStyleValues.padding08),
            child: SailText.secondary13(
              'The sidechain may also deduct a fee from your deposit.',
              color: context.sailTheme.colors.textTertiary,
            ),
          ),
          SailButton(
            label: 'Deposit',
            disabled:
                isDisabled ||
                viewModel.addressController.text == '' ||
                viewModel.depositAmountController.text == '' ||
                viewModel.feeController.text == '',
            onPressed: () async => viewModel.deposit(context),
          ),
          const SizedBox(height: SailStyleValues.padding16),
          Expanded(
            child: SailCard(
              title:
                  'Your Recent Deposits${viewModel.selectedIndex != null && viewModel.sidechains[viewModel.selectedIndex!] != null ? " to ${viewModel.sidechains[viewModel.selectedIndex!]!.info.title}" : ""}',
              subtitle: 'Recent deposits to sidechains, coming from your onchain-wallet.',
              shadowSize: ShadowSize.none,
              child: RecentDepositsTable(),
            ),
          ),
        ],
      ),
    );
  }
}

class SeeWithdrawalsView extends ViewModelWidget<SidechainsViewModel> {
  const SeeWithdrawalsView({super.key});

  @override
  Widget build(BuildContext context, SidechainsViewModel viewModel) {
    final isDisabled = viewModel.isUsingBitcoinCoreWallet;

    return SailCard(
      error: isDisabled ? 'Switch to your enforcer wallet to interact with sidechains' : null,
      bottomPadding: false,
      child: const RecentWithdrawalsTable(),
    );
  }
}

class RecentDepositsTable extends ViewModelWidget<SidechainsViewModel> {
  const RecentDepositsTable({super.key});

  @override
  Widget build(BuildContext context, SidechainsViewModel viewModel) {
    final formatter = GetIt.I<FormatterProvider>();

    return ListenableBuilder(
      listenable: formatter,
      builder: (context, child) => SailTable(
        getRowId: (index) => viewModel.sortedDeposits[index].txid,
        headerBuilder: (context) => [
          SailTableHeaderCell(
            name: 'Txid',
            onSort: () => viewModel.sortDeposits('txid'),
          ),
          SailTableHeaderCell(
            name: 'Amount',
            onSort: () => viewModel.sortDeposits('amount'),
          ),
          SailTableHeaderCell(
            name: 'Fee',
            onSort: () => viewModel.sortDeposits('fee'),
          ),
          SailTableHeaderCell(
            name: 'Confirmations',
            onSort: () => viewModel.sortDeposits('confirmations'),
          ),
        ],
        rowBuilder: (context, row, selected) {
          final deposit = viewModel.sortedDeposits[row];
          return [
            SailTableCell(
              value: '${deposit.txid.substring(0, 10)}..',
              copyValue: deposit.txid,
            ),
            SailTableCell(value: formatter.formatSats(deposit.amount.toInt())),
            SailTableCell(value: formatter.formatSats(deposit.fee.toInt())),
            SailTableCell(value: deposit.confirmations.toString()),
          ];
        },
        rowCount: viewModel.sortedDeposits.length,
        drawGrid: true,
        sortAscending: viewModel.depositSortAscending,
        sortColumnIndex: ['txid', 'amount', 'fee', 'confirmations'].indexOf(viewModel.depositSortColumn),
        onSort: (columnIndex, ascending) => viewModel.sortDeposits(viewModel.depositSortColumn),
        onDoubleTap: (rowId) => showTransactionDetails(context, rowId),
        contextMenuItems: (rowId) {
          return [
            SailMenuItem(
              onSelected: () => showTransactionDetails(context, rowId),
              child: SailText.primary12('Show Transaction Details'),
            ),
          ];
        },
      ),
    );
  }
}

class RecentWithdrawalsTable extends ViewModelWidget<SidechainsViewModel> {
  const RecentWithdrawalsTable({super.key});

  @override
  Widget build(BuildContext context, SidechainsViewModel viewModel) {
    if (viewModel.sortedWithdrawals.isEmpty) {
      return Center(
        child: SailText.secondary13('No withdrawal bundles found for this sidechain'),
      );
    }

    return SailTable(
      getRowId: (index) => viewModel.sortedWithdrawals[index].m6id,
      headerBuilder: (context) => [
        const SailTableHeaderCell(name: 'M6 ID'),
        const SailTableHeaderCell(name: 'Status'),
        const SailTableHeaderCell(name: 'Block Height'),
        const SailTableHeaderCell(name: 'Sequence #'),
      ],
      rowBuilder: (context, row, selected) {
        final withdrawal = viewModel.sortedWithdrawals[row];
        return [
          SailTableCell(
            value: '${withdrawal.m6id.substring(0, 10)}...',
            copyValue: withdrawal.m6id,
          ),
          SailTableCell(value: withdrawal.status),
          SailTableCell(value: withdrawal.blockHeight.toString()),
          SailTableCell(value: withdrawal.sequenceNumber.toInt() > 0 ? withdrawal.sequenceNumber.toString() : '-'),
        ];
      },
      rowCount: viewModel.sortedWithdrawals.length,
      drawGrid: true,
      sortAscending: true,
      sortColumnIndex: 2,
    );
  }
}
