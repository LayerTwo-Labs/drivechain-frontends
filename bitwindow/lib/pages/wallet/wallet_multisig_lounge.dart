import 'dart:async';
import 'dart:io';
import 'package:bitwindow/widgets/create_multisig_modal.dart';
import 'package:bitwindow/models/multisig_group.dart';
import 'package:bitwindow/models/multisig_transaction.dart';
import 'package:bitwindow/providers/blockchain_provider.dart';
import 'package:bitwindow/providers/multisig_provider.dart';
import 'package:bitwindow/widgets/combine_broadcast_modal.dart';
import 'package:bitwindow/widgets/fund_group_modal.dart';
import 'package:bitwindow/widgets/import_psbt_modal.dart';
import 'package:bitwindow/widgets/import_txid_modal.dart';
import 'package:bitwindow/widgets/multisig_key_modal.dart';
import 'package:bitwindow/widgets/psbt_coordinator_modal.dart';
import 'package:bitwindow/providers/hd_wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:crypto/crypto.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

// Constants
const int kDescriptorAddressRange = 999;
const double kTableHeight = 300.0;

class TransactionRow {
  final MultisigTransaction transaction;
  final bool hasWalletKeys;
  final bool walletHasSigned;
  
  TransactionRow({
    required this.transaction,
    required this.hasWalletKeys,
    required this.walletHasSigned,
  });
}

class MultisigLoungeTab extends StatefulWidget {
  const MultisigLoungeTab({super.key});

  @override
  State<MultisigLoungeTab> createState() => _MultisigLoungeTabState();
}

class _MultisigLoungeTabState extends State<MultisigLoungeTab> with WidgetsBindingObserver {
  MultisigLoungeViewModel? _viewModel;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _viewModel?.dispose();
    super.dispose();
  }

  // No longer need app lifecycle management with event-driven updates

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MultisigLoungeViewModel>.reactive(
      viewModelBuilder: () => MultisigLoungeViewModel(),
      onViewModelReady: (model) {
        _viewModel = model;
        model.initialize();
      },
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const SailPage(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (viewModel.errorMessage != null) {
          return SailPage(
            body: Center(
              child: SailColumn(
                spacing: SailStyleValues.padding16,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SailText.primary13('Error loading multisig data'),
                  SailText.secondary12(viewModel.errorMessage!),
                  SailButton(
                    label: 'Retry',
                    onPressed: () => viewModel.refreshData(),
                  ),
                ],
              ),
            ),
          );
        }

        return SailPage(
          body: SingleChildScrollView(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SailColumn(
                  spacing: SailStyleValues.padding16,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGroupsSection(context, viewModel, constraints),
                    _buildTransactionsSection(context, viewModel, constraints),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildGroupsSection(BuildContext context, MultisigLoungeViewModel viewModel, BoxConstraints constraints) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SailCard(
            title: 'Multisig Groups',
            subtitle: '${viewModel.multisigGroups.length} group(s)',
            bottomPadding: false,
            child: SizedBox(
              height: kTableHeight,
              child: MultisigGroupsTable(
                groups: viewModel.multisigGroups,
                selectedGroup: viewModel.selectedGroup,
                onSelectGroup: viewModel.selectGroup,
              ),
            ),
          ),
        ),
        const SizedBox(width: SailStyleValues.padding16),
        SizedBox(
          width: 240, // Slightly wider for tools
          child: SailCard(
            title: 'Group Tools',
            subtitle: 'Manage multisig groups',
            bottomPadding: false,
            child: SizedBox(
              height: kTableHeight,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SailButton(
                        label: 'Create New Group',
                        onPressed: () => viewModel.createNewGroup(context),
                        variant: ButtonVariant.primary,
                      ),
                      const SizedBox(height: SailStyleValues.padding08),
                      SailButton(
                        label: 'Fund Group',
                        onPressed: viewModel.multisigGroups.isNotEmpty
                            ? () => viewModel.fundGroupWithSelection(context)
                            : null,
                        variant: ButtonVariant.secondary,
                      ),
                      const SizedBox(height: SailStyleValues.padding08),
                      SailButton(
                        label: 'Import from TXID',
                        onPressed: () => viewModel.importFromTxid(context),
                        variant: ButtonVariant.secondary,
                      ),
                      const SizedBox(height: SailStyleValues.padding08),
                      SailButton(
                        label: 'Get Key',
                        onPressed: () => viewModel.getMultisigKey(context),
                        variant: ButtonVariant.secondary,
                      ),
                      if (viewModel.selectedGroup != null) ...[
                        const SizedBox(height: SailStyleValues.padding08),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: SailText.primary12(
                            'Selected: ${viewModel.selectedGroup!.name}',
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsSection(BuildContext context, MultisigLoungeViewModel viewModel, BoxConstraints constraints) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SailCard(
            title: 'Multisig Transactions',
            subtitle: '${viewModel.transactionRows.length} transaction(s)',
            bottomPadding: false,
            child: SizedBox(
              height: kTableHeight,
              child: MultisigTransactionsTable(
                transactionRows: viewModel.transactionRows,
                groups: viewModel.multisigGroups,
                onAction: (tx, group) => viewModel.handleTransactionAction(context, tx, group),
                onBroadcast: () => viewModel.openCombineAndBroadcastModal(context),
                onView: (tx) => viewModel.openTransactionModal(context, tx),
                onSign: (tx, group) => viewModel.signTransaction(context, tx, group),
              ),
            ),
          ),
        ),
        const SizedBox(width: SailStyleValues.padding16),
        SizedBox(
          width: 240, // Slightly wider for tools
          child: SailCard(
            title: 'Transaction Tools',
            subtitle: 'Create and manage transactions',
            bottomPadding: false,
            child: SizedBox(
              height: kTableHeight,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SailButton(
                        label: 'Create Transaction',
                        onPressed: viewModel.multisigGroups.any((g) => g.balance > 0)
                            ? () => viewModel.createTransaction(context, null)
                            : null,
                        variant: ButtonVariant.primary,
                      ),
                      const SizedBox(height: SailStyleValues.padding08),
                      SailButton(
                        label: 'Import PSBT',
                        onPressed: () => viewModel.importPSBT(context),
                        variant: ButtonVariant.secondary,
                      ),
                      const SizedBox(height: SailStyleValues.padding08),
                      SailButton(
                        label: 'Combine & Broadcast',
                        onPressed: viewModel.hasReadyTransactions
                            ? () => viewModel.openCombineAndBroadcastModal(context)
                            : null,
                        variant: ButtonVariant.secondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Table widgets
class MultisigGroupsTable extends StatefulWidget {
  final List<MultisigGroup> groups;
  final MultisigGroup? selectedGroup;
  final Function(MultisigGroup?) onSelectGroup;

  const MultisigGroupsTable({
    super.key,
    required this.groups,
    required this.selectedGroup,
    required this.onSelectGroup,
  });

  @override
  State<MultisigGroupsTable> createState() => _MultisigGroupsTableState();
}

class _MultisigGroupsTableState extends State<MultisigGroupsTable> {
  String sortColumn = 'name';
  bool sortAscending = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sortGroups();
  }

  void onSort(String column) {
    if (sortColumn == column) {
      sortAscending = !sortAscending;
    } else {
      sortColumn = column;
      sortAscending = true;
    }
    sortGroups();
    setState(() {});
  }

  void sortGroups() {
    widget.groups.sort((a, b) {
      dynamic aValue = '';
      dynamic bValue = '';

      switch (sortColumn) {
        case 'name':
          aValue = a.name;
          bValue = b.name;
          break;
        case 'balance':
          aValue = a.balance;
          bValue = b.balance;
          break;
        case 'utxos':
          aValue = a.utxos;
          bValue = b.utxos;
          break;
        case 'total':
          aValue = a.n;
          bValue = b.n;
          break;
        case 'required':
          aValue = a.m;
          bValue = b.m;
          break;
      }

      return sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SailTable(
      getRowId: (index) => widget.groups.isNotEmpty
          ? widget.groups[index].id
          : 'empty$index',
      onSelectedRow: (rowId) {
        if (rowId != null && widget.groups.isNotEmpty) {
          final group = widget.groups.firstWhere(
            (g) => g.id == rowId,
            orElse: () => widget.groups.first,
          );
          widget.onSelectGroup(group);
        }
      },
      headerBuilder: (context) => [
        SailTableHeaderCell(name: 'Name', onSort: () => onSort('name')),
        const SailTableHeaderCell(name: 'ID'),
        SailTableHeaderCell(name: 'Balance (BTC)', onSort: () => onSort('balance')),
        SailTableHeaderCell(name: 'UTXOs', onSort: () => onSort('utxos')),
        SailTableHeaderCell(name: 'Total Keys', onSort: () => onSort('total')),
        SailTableHeaderCell(name: 'Keys Required', onSort: () => onSort('required')),
        const SailTableHeaderCell(name: 'Type'),
      ],
      rowBuilder: (context, row, selected) {
        if (widget.groups.isEmpty) {
          return [
            const SailTableCell(value: 'No multisig groups yet'),
            const SailTableCell(value: ''),
            const SailTableCell(value: ''),
            const SailTableCell(value: ''),
            const SailTableCell(value: ''),
            const SailTableCell(value: ''),
            const SailTableCell(value: ''),
          ];
        }

        final group = widget.groups[row];
        return [
          SailTableCell(value: group.name),
          SailTableCell(value: group.id.toUpperCase()),
          SailTableCell(value: group.balance.toStringAsFixed(8)),
          SailTableCell(value: group.utxos.toString()),
          SailTableCell(value: group.n.toString()),
          SailTableCell(value: group.m.toString()),
          SailTableCell(value: 'xPub'),
        ];
      },
      rowCount: widget.groups.isEmpty ? 1 : widget.groups.length,
      drawGrid: true,
      sortColumnIndex: ['name', 'id', 'balance', 'utxos', 'total', 'required', 'type'].indexOf(sortColumn),
      sortAscending: sortAscending,
      onSort: (columnIndex, ascending) {
        onSort(['name', 'id', 'balance', 'utxos', 'total', 'required', 'type'][columnIndex]);
      },
    );
  }
}

class MultisigTransactionsTable extends StatefulWidget {
  final List<TransactionRow> transactionRows;
  final List<MultisigGroup> groups;
  final Function(MultisigTransaction, MultisigGroup) onAction;
  final VoidCallback onBroadcast;
  final Function(MultisigTransaction) onView;
  final Function(MultisigTransaction, MultisigGroup) onSign;

  const MultisigTransactionsTable({
    super.key,
    required this.transactionRows,
    required this.groups,
    required this.onAction,
    required this.onBroadcast,
    required this.onView,
    required this.onSign,
  });

  @override
  State<MultisigTransactionsTable> createState() => _MultisigTransactionsTableState();
}

class _MultisigTransactionsTableState extends State<MultisigTransactionsTable> {
  String sortColumn = 'group';
  bool sortAscending = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sortTransactions();
  }

  void onSort(String column) {
    if (sortColumn == column) {
      sortAscending = !sortAscending;
    } else {
      sortColumn = column;
      sortAscending = true;
    }
    sortTransactions();
    setState(() {});
  }

  void sortTransactions() {
    widget.transactionRows.sort((a, b) {
      dynamic aValue = '';
      dynamic bValue = '';
      
      final aGroup = widget.groups.firstWhere(
        (g) => g.id == a.transaction.groupId,
        orElse: () => MultisigGroup(
          id: a.transaction.groupId,
          name: 'Unknown',
          n: 0,
          m: 0,
          keys: [],
          created: 0,
        ),
      );
      
      final bGroup = widget.groups.firstWhere(
        (g) => g.id == b.transaction.groupId,
        orElse: () => MultisigGroup(
          id: b.transaction.groupId,
          name: 'Unknown',
          n: 0,
          m: 0,
          keys: [],
          created: 0,
        ),
      );

      switch (sortColumn) {
        case 'group':
          aValue = aGroup.name;
          bValue = bGroup.name;
          break;
        case 'amount':
          aValue = a.transaction.amount;
          bValue = b.transaction.amount;
          break;
        case 'signatures':
          aValue = a.transaction.signatureCount;
          bValue = b.transaction.signatureCount;
          break;
        case 'status':
          aValue = a.transaction.status.index;
          bValue = b.transaction.status.index;
          break;
        case 'confirmations':
          aValue = a.transaction.confirmations;
          bValue = b.transaction.confirmations;
          break;
      }

      return sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SailTable(
      getRowId: (index) => widget.transactionRows.isNotEmpty
          ? widget.transactionRows[index].transaction.id
          : 'empty$index',
      headerBuilder: (context) => [
        SailTableHeaderCell(name: 'Group', onSort: () => onSort('group')),
        const SailTableHeaderCell(name: 'MuSIG ID'),
        SailTableHeaderCell(name: 'Amount (BTC)', onSort: () => onSort('amount')),
        SailTableHeaderCell(name: 'Signatures', onSort: () => onSort('signatures')),
        SailTableHeaderCell(name: 'Status', onSort: () => onSort('status')),
        const SailTableHeaderCell(name: 'TXID'),
        SailTableHeaderCell(name: 'Confirmations', onSort: () => onSort('confirmations')),
        const SailTableHeaderCell(name: 'Action'),
      ],
      rowBuilder: (context, row, selected) {
        if (widget.transactionRows.isEmpty) {
          return [
            const SailTableCell(value: 'No transactions yet'),
            const SailTableCell(value: ''),
            const SailTableCell(value: ''),
            const SailTableCell(value: ''),
            const SailTableCell(value: ''),
            const SailTableCell(value: ''),
            const SailTableCell(value: ''),
            const SailTableCell(value: ''),
          ];
        }

        final txRow = widget.transactionRows[row];
        final tx = txRow.transaction;
        final group = widget.groups.firstWhere(
          (g) => g.id == tx.groupId,
          orElse: () => MultisigGroup(
            id: tx.groupId,
            name: 'Unknown',
            n: 0,
            m: 0,
            keys: [],
            created: 0,
          ),
        );

        return [
          SailTableCell(value: group.name),
          SailTableCell(value: tx.shortId),
          SailTableCell(value: tx.amount.toStringAsFixed(8)),
          SailTableCell(value: '${tx.signatureCount}/${group.m}'),
          SailTableCell(value: tx.status.displayName),
          SailTableCell(value: tx.shortTxid ?? '-'),
          SailTableCell(value: tx.confirmations > 0 ? tx.confirmations.toString() : '-'),
          _buildActionCell(txRow, tx, group),
        ];
      },
      rowCount: widget.transactionRows.isEmpty ? 1 : widget.transactionRows.length,
      drawGrid: true,
      sortColumnIndex: ['group', 'id', 'amount', 'signatures', 'status', 'txid', 'confirmations', 'action'].indexOf(sortColumn),
      sortAscending: sortAscending,
      onSort: (columnIndex, ascending) {
        onSort(['group', 'id', 'amount', 'signatures', 'status', 'txid', 'confirmations', 'action'][columnIndex]);
      },
    );
  }

  Widget _buildActionCell(TransactionRow txRow, MultisigTransaction tx, MultisigGroup group) {
    if (txRow.hasWalletKeys && !txRow.walletHasSigned && (tx.status == TxStatus.needsSignatures || tx.status == TxStatus.awaitingSignedPSBTs)) {
      return SailTableCell(
        value: 'Sign Button',
        alignment: Alignment.center,
        child: Center(
          child: SailButton(
            label: 'Sign',
            variant: ButtonVariant.primary,
            insideTable: true,
            onPressed: () => widget.onSign(tx, group),
          ),
        ),
      );
    } else if (tx.status == TxStatus.readyForBroadcast) {
      return SailTableCell(
        value: 'Broadcast Button',
        alignment: Alignment.center,
        child: Center(
          child: SailButton(
            label: 'Broadcast',
            variant: ButtonVariant.secondary,
            insideTable: true,
            onPressed: () async => widget.onBroadcast(),
          ),
        ),
      );
    } else {
      return SailTableCell(
        value: 'View Button',
        alignment: Alignment.center,
        child: Center(
          child: SailButton(
            label: 'View',
            variant: ButtonVariant.secondary,
            insideTable: true,
            onPressed: () => widget.onView(tx),
          ),
        ),
      );
    }
  }
}

// ViewModel
class MultisigLoungeViewModel extends BaseViewModel {
  final MainchainRPC _rpc = GetIt.I.get<MainchainRPC>();
  final HDWalletProvider _hdWalletProvider = GetIt.I.get<HDWalletProvider>();
  final BlockchainProvider _blockchainProvider = GetIt.I.get<BlockchainProvider>();
  final _walletManager = WalletRPCManager();
  final _logger = Logger();

  List<MultisigGroup> _multisigGroups = [];
  List<MultisigTransaction> _transactions = [];
  MultisigGroup? selectedGroup;
  
  // File checksums for change detection
  String? _lastMultisigFileHash;
  String? _lastTransactionFileHash;
  
  // Listen to transaction and blockchain changes
  late final VoidCallback _transactionListener;
  late final VoidCallback _blockchainListener;

  List<MultisigGroup> get multisigGroups => _multisigGroups;
  List<MultisigTransaction> get transactions => _transactions;
  
  bool isLoading = false;
  String? errorMessage;

  MultisigLoungeViewModel();




  // Helper method to find a group by ID with fallback
  MultisigGroup _findGroupByIdWithFallback(String groupId) {
    return multisigGroups.firstWhere(
      (g) => g.id == groupId,
      orElse: () => MultisigGroup(
        id: groupId,
        name: 'Unknown',
        n: 0,
        m: 0,
        keys: [],
        created: 0,
      ),
    );
  }

  Future<void> initialize() async {
    // Set up listener for transaction changes (immediate file updates)
    _transactionListener = () async {
      final hasChanges = await _haveFilesChanged();
      if (hasChanges) {
        await _loadDataFromFiles();
        notifyListeners();
        _logger.d('UI updated due to file changes');
      } else {
        _logger.d('No file changes detected, skipping UI update');
      }
    };
    TransactionStorage.notifier.addListener(_transactionListener);
    
    // Set up listener for blockchain changes (new blocks)
    _blockchainListener = () async {
      // For blockchain changes, we need to update balances which may change files
      // So we check both file hashes and balance updates
      final hasFileChanges = await _haveFilesChanged();
      if (hasFileChanges) {
        await _loadDataFromFiles();
        notifyListeners();
      } else {
        // Even if files haven't changed, we should update balances for display
        await _updateAllGroupBalances();
        notifyListeners();
      }
    };
    _blockchainProvider.addListener(_blockchainListener);
    
    // Initialize file checksums
    await _haveFilesChanged();
    
    await refreshData();
  }


  Future<void> refreshData() async {
    // Only show loading for initial load, not for background updates
    final wasInitialLoad = _multisigGroups.isEmpty && _transactions.isEmpty;
    
    if (wasInitialLoad) {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
    }

    try {
      // Load multisig groups and transactions from storage
      _multisigGroups = await MultisigStorage.loadGroups();
      _transactions = await TransactionStorage.loadTransactions();
      
      // Update balances for all groups
      for (final group in multisigGroups) {
        try {
          await _updateGroupBalance(group);
        } catch (e) {
          _logger.e('Failed to update balance for group ${group.name}', error: e);
        }
      }
    } catch (e) {
      errorMessage = e.toString();
      _logger.e('Error refreshing multisig data', error: e);
    } finally {
      if (wasInitialLoad) {
        isLoading = false;
      }
      notifyListeners();
    }
  }

  Future<void> _updateGroupBalance(MultisigGroup group) async {
    try {
      final walletName = group.watchWalletName ?? 'multisig_${group.id}';
      
      try {
        final walletInfo = await _walletManager.getWalletInfo(walletName);
        
        if (walletInfo['descriptors'] != true) {
          return;
        }
      } catch (e) {
        await _createWatchOnlyWallet(group);
      }

      // Get balance and UTXOs together to ensure consistency
      final balance = await _walletManager.getWalletBalance(walletName);
      final utxos = await _walletManager.listUnspent(walletName);
      final utxoCount = utxos.length;
      
      _logger.d('Updating group ${group.name}: balance=$balance, utxos=$utxoCount');
      
      // Update storage
      await MultisigStorage.updateGroupBalance(group.id, balance, utxoCount);
      
      // Update the in-memory group to reflect changes immediately
      final groupIndex = _multisigGroups.indexWhere((g) => g.id == group.id);
      if (groupIndex != -1) {
        final updatedGroup = MultisigGroup(
          id: group.id,
          name: group.name,
          n: group.n,
          m: group.m,
          keys: group.keys,
          created: group.created,
          descriptorReceive: group.descriptorReceive,
          descriptorChange: group.descriptorChange,
          watchWalletName: group.watchWalletName,
          txid: group.txid,
          addresses: group.addresses,
          nextReceiveIndex: group.nextReceiveIndex,
          balance: balance,
          utxos: utxoCount,
          utxoDetails: group.utxoDetails,
        );
        
        _multisigGroups[groupIndex] = updatedGroup;
      }
    } catch (e) {
      _logger.e('Failed to update balance for group ${group.name}', error: e);
    }
  }

  Future<void> _createWatchOnlyWallet(MultisigGroup group) async {
    try {
      final walletName = group.watchWalletName ?? 'multisig_${group.id}';
      
      await _walletManager.createWallet(
        walletName,
        disablePrivateKeys: true,
        blank: true,
        descriptors: true,
      );
      
      await _importDescriptorsToWallet(walletName, group);
    } catch (e) {
      _logger.e('Failed to create watch-only wallet for group ${group.name}', error: e);
      rethrow;
    }
  }

  Future<Map<String, String>> _buildDescriptors(MultisigGroup group) async {
    final descriptors = await MultisigDescriptorBuilder.buildWatchOnlyDescriptors(group);
    return {'receive': descriptors.receive, 'change': descriptors.change};
  }

  // Helper method to import descriptors with common logic
  Future<void> _importDescriptorsToWallet(String walletName, MultisigGroup group, {bool rescanning = false}) async {
    String? receiveDesc = group.descriptorReceive;
    String? changeDesc = group.descriptorChange;
    
    if (receiveDesc == null || changeDesc == null) {
      final descriptors = await _buildDescriptors(group);
      receiveDesc = descriptors['receive'];
      changeDesc = descriptors['change'];
    }
    
    await _walletManager.importDescriptors(walletName, [
      {
        'desc': receiveDesc,
        'active': true,
        'internal': false,
        'timestamp': rescanning ? 0 : 'now',
        'range': [0, kDescriptorAddressRange],
      },
      {
        'desc': changeDesc,
        'active': true,
        'internal': true,
        'timestamp': rescanning ? 0 : 'now',
        'range': [0, kDescriptorAddressRange],
      },
    ]);
  }

  List<TransactionRow> get transactionRows {
    final rows = <TransactionRow>[];
    
    for (final tx in transactions) {
      final group = _findGroupByIdWithFallback(tx.groupId);
      
      final walletKeys = group.keys.where((k) => k.isWallet).toList();
      final hasWalletKeys = walletKeys.isNotEmpty;
      final walletHasSigned = tx.keyPSBTs.any((kp) => 
        walletKeys.any((wk) => wk.xpub == kp.keyId) && kp.isSigned,
      );
      
      rows.add(TransactionRow(
        transaction: tx,
        hasWalletKeys: hasWalletKeys,
        walletHasSigned: walletHasSigned,
      ),);
    }
    
    return rows;
  }

  bool get hasReadyTransactions => 
    transactions.any((tx) => tx.status == TxStatus.readyForBroadcast);

  void selectGroup(MultisigGroup? group) {
    selectedGroup = group;
    notifyListeners();
  }

  // Actions
  Future<void> createNewGroup(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (context) => const CreateMultisigModal(),
    );
    
    // No manual refresh needed - blockchain provider will detect the new group
  }

  Future<void> importFromTxid(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const ImportTxidModal(),
    );
    
    if (result == true) {
      // Refresh data after successful import
      await refreshData();
    }
  }

  Future<void> getMultisigKey(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) => const MultisigKeyModal(),
    );
  }

  Future<void> importPSBT(BuildContext context) async {
    await showDialog<bool>(
      context: context,
      builder: (context) => ImportPSBTModal(
        availableGroups: multisigGroups,
        onImportSuccess: () {
          // The notifier will automatically trigger the update
        },
      ),
    );
    // No need to manually refresh - the notifier will trigger the update
  }

  Future<void> fundGroup(BuildContext context, MultisigGroup group) async {
    try {
      final address = await _getNewAddress(group);
      _logger.d('Got funding address for group ${group.name}: $address');
      
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => FundGroupModal(
          groups: [group],
        ),
      );
      
      // No manual refresh needed - blockchain provider handles balance updates
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get funding address: $e')),
        );
      }
    }
  }

  Future<void> fundGroupWithSelection(BuildContext context) async {
    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => FundGroupModal(
          groups: multisigGroups,
        ),
      );
      
      // No manual refresh needed - blockchain provider handles balance updates
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open funding modal: $e')),
        );
      }
    }
  }

  Future<String> _getNewAddress(MultisigGroup group) async {
    final walletName = group.watchWalletName ?? 'multisig_${group.id}';
    
    try {
      await _walletManager.getWalletInfo(walletName);
    } catch (e) {
      await _createWatchOnlyWallet(group);
    }
    
    return await _walletManager.getNewAddress(walletName);
  }

  Future<void> reimportDescriptors(BuildContext context, MultisigGroup group) async {
    try {
      final walletName = group.watchWalletName ?? 'multisig_${group.id}';
      
      await _importDescriptorsToWallet(walletName, group, rescanning: true);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Descriptors reimported for ${group.name}. Rescanning blockchain...'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reimport descriptors: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> createTransaction(BuildContext context, MultisigGroup? group) async {
    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => PSBTCoordinatorModal(
          group: group,
          availableGroups: multisigGroups.where((g) => g.balance > 0).toList(),
        ),
      );
      
      // No need to manually refresh - the notifier will trigger the update automatically
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create transaction: $e')),
        );
      }
    }
  }

  
  
  /// Calculate SHA256 hash of a file's contents
  Future<String?> _getFileHash(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return null;
      }
      
      final contents = await file.readAsBytes();
      final digest = sha256.convert(contents);
      return digest.toString();
    } catch (e) {
      _logger.e('Failed to calculate file hash for $filePath: $e');
      return null;
    }
  }
  
  /// Check if multisig files have changed using checksums
  Future<bool> _haveFilesChanged() async {
    try {
      // Get file paths
      final multisigPath = await MultisigStorage.getMultisigFilePath();
      final transactionPath = await TransactionStorage.getTransactionFilePath();
      
      // Calculate current hashes
      final currentMultisigHash = await _getFileHash(multisigPath);
      final currentTransactionHash = await _getFileHash(transactionPath);
      
      // Check if hashes changed
      final multisigChanged = _lastMultisigFileHash != currentMultisigHash;
      final transactionChanged = _lastTransactionFileHash != currentTransactionHash;
      
      if (multisigChanged || transactionChanged) {
        // Update stored hashes
        _lastMultisigFileHash = currentMultisigHash;
        _lastTransactionFileHash = currentTransactionHash;
        
        return true;
      }
      
      return false;
    } catch (e) {
      _logger.e('Error checking file changes: $e');
      return true; // Assume changed on error to be safe
    }
  }
  
  /// Load data from files without any change detection
  Future<void> _loadDataFromFiles() async {
    _multisigGroups = await MultisigStorage.loadGroups();
    _transactions = await TransactionStorage.loadTransactions();
  }
  
  /// Update balances for all groups (for blockchain updates)
  Future<void> _updateAllGroupBalances() async {
    for (final group in _multisigGroups) {
      try {
        await _updateGroupBalance(group);
      } catch (e) {
        _logger.e('Failed to update balance for group ${group.name}', error: e);
      }
    }
  }

  Future<void> openCombineAndBroadcastModal(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => CombineBroadcastModal(
        eligibleTransactions: transactions.where((tx) => 
          tx.status == TxStatus.readyForBroadcast,
        ).toList(),
        multisigGroups: multisigGroups,
        onBroadcastSuccess: () {
          // Transaction notifier will handle the update automatically
        },
      ),
    );
    
    // Transaction notifier will handle updates automatically
  }

  Future<void> openTransactionModal(BuildContext context, MultisigTransaction transaction) async {
    final group = multisigGroups.firstWhere(
      (g) => g.id == transaction.groupId,
      orElse: () => throw Exception('Group not found for transaction'),
    );
    
    await showDialog<void>(
      context: context,
      builder: (context) => _buildTransactionDetailsModal(context, transaction, group),
    );
  }

  Widget _buildTransactionDetailsModal(BuildContext context, MultisigTransaction transaction, MultisigGroup group) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
        child: SailCard(
          title: 'Transaction Details',
          subtitle: 'ID: ${transaction.id}',
          child: SingleChildScrollView(
            child: SailColumn(
              spacing: SailStyleValues.padding16,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transaction Status
                SailRow(
                  children: [
                    SailText.primary15('Status:'),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(transaction.status),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: SailText.primary12(
                        _getStatusText(transaction.status),
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                
                // Basic Info
                _buildDetailRow('Group:', group.name),
                _buildDetailRow('Amount:', '${transaction.amount.toStringAsFixed(8)} BTC'),
                _buildDetailRow('Fee:', '${transaction.fee.toStringAsFixed(8)} BTC'),
                _buildDetailRow('Destination:', transaction.destination),
                _buildDetailRow('Created:', _formatDateTime(transaction.created)),
                
                // Transaction Hash (if broadcasted)
                if (transaction.txid != null)
                  _buildDetailRow('Transaction ID:', transaction.txid!),
                
                // Confirmations (if confirmed)
                if (transaction.confirmations > 0)
                  _buildDetailRow('Confirmations:', transaction.confirmations.toString()),
                
                // Broadcast time (if broadcasted)
                if (transaction.broadcastTime != null)
                  _buildDetailRow('Broadcasted:', _formatDateTime(transaction.broadcastTime!)),
                
                // Signing Status
                const SizedBox(height: 32),
                SailText.primary15('Signing Status:'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SailColumn(
                    spacing: SailStyleValues.padding08,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SailText.secondary12('Required signatures: ${transaction.requiredSignatures}'),
                      SailText.secondary12('Current signatures: ${transaction.keyPSBTs.where((k) => k.isSigned).length}'),
                      const SizedBox(height: 8),
                      ...transaction.keyPSBTs.map((keyPSBT) {
                        final keyName = group.keys.firstWhere(
                          (k) => k.xpub == keyPSBT.keyId,
                          orElse: () => MultisigKey(
                            xpub: keyPSBT.keyId,
                            owner: 'Unknown',
                            derivationPath: '',
                            isWallet: false,
                          ),
                        ).owner;
                        
                        return SailRow(
                          children: [
                            SailText.secondary12(keyName),
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: keyPSBT.isSigned ? Colors.green : Colors.grey,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: SailText.primary10(
                                keyPSBT.isSigned ? 'Signed' : 'Pending',
                                color: Colors.white,
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
                
                // PSBT Export Section
                const SizedBox(height: 32),
                SailText.primary15('Export PSBTs:'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SailColumn(
                    spacing: SailStyleValues.padding08,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Initial PSBT
                      SailRow(
                        children: [
                          Expanded(
                            child: SailText.secondary12('Initial PSBT (unsigned)'),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: SailText.primary10(
                              'Unsigned',
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SailButton(
                            label: 'Copy',
                            variant: ButtonVariant.ghost,
                            small: true,
                            onPressed: () async => _copySpecificPSBT(context, transaction.initialPSBT, 'Initial PSBT'),
                          ),
                        ],
                      ),
                      // Individual key PSBTs
                      ...transaction.keyPSBTs.map((keyPSBT) {
                        final keyName = group.keys.firstWhere(
                          (k) => k.xpub == keyPSBT.keyId,
                          orElse: () => MultisigKey(
                            xpub: keyPSBT.keyId,
                            owner: 'Unknown',
                            derivationPath: '',
                            isWallet: false,
                          ),
                        ).owner;
                        
                        return SailRow(
                          children: [
                            Expanded(
                              child: SailText.secondary12('$keyName PSBT'),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: keyPSBT.isSigned ? Colors.green : Colors.grey,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: SailText.primary10(
                                keyPSBT.isSigned ? 'Signed' : 'Unsigned',
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            SailButton(
                              label: 'Copy',
                              variant: ButtonVariant.ghost,
                              small: true,
                              onPressed: (keyPSBT.psbt?.isNotEmpty ?? false)
                                ? () async => _copySpecificPSBT(context, keyPSBT.psbt!, '$keyName PSBT')
                                : null,
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
                
                // Close button
                const SizedBox(height: 16),
                SailButton(
                  label: 'Close',
                  onPressed: () async => Navigator.of(context).pop(),
                  variant: ButtonVariant.secondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return SailRow(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.primary13(label),
        const SizedBox(width: 16),
        Flexible(
          child: SailText.secondary13(
            value,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(TxStatus status) {
    switch (status) {
      case TxStatus.needsSignatures:
        return Colors.orange;
      case TxStatus.awaitingSignedPSBTs:
        return Colors.amber;
      case TxStatus.readyForBroadcast:
        return Colors.blue;
      case TxStatus.broadcasted:
        return Colors.purple;
      case TxStatus.confirmed:
        return Colors.green;
      case TxStatus.completed:
        return Colors.teal;
      case TxStatus.voided:
        return Colors.red;
    }
  }

  String _getStatusText(TxStatus status) {
    switch (status) {
      case TxStatus.needsSignatures:
        return 'Needs Signatures';
      case TxStatus.awaitingSignedPSBTs:
        return 'Awaiting Signed PSBTs';
      case TxStatus.readyForBroadcast:
        return 'Ready to Broadcast';
      case TxStatus.broadcasted:
        return 'Broadcasted';
      case TxStatus.confirmed:
        return 'Confirmed';
      case TxStatus.completed:
        return 'Completed';
      case TxStatus.voided:
        return 'Voided';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> handleTransactionAction(BuildContext context, MultisigTransaction tx, MultisigGroup group) async {
    switch (tx.status) {
      case TxStatus.needsSignatures:
      case TxStatus.awaitingSignedPSBTs:
        final walletKeys = group.keys.where((k) => k.isWallet).toList();
        final hasWalletSigned = tx.keyPSBTs.any((kp) => 
          walletKeys.any((wk) => wk.xpub == kp.keyId) && kp.isSigned,
        );
        
        if (!hasWalletSigned) {
          await signTransaction(context, tx, group);
        } else {
          await openTransactionModal(context, tx);
        }
        break;
      case TxStatus.readyForBroadcast:
      case TxStatus.broadcasted:
      case TxStatus.confirmed:
      case TxStatus.completed:
      case TxStatus.voided:
        await openTransactionModal(context, tx);
        break;
    }
  }

  Future<void> signTransaction(BuildContext context, MultisigTransaction tx, MultisigGroup group) async {
    MultisigLogger.info('Starting transaction signing for ${tx.id} in group ${group.name}');
    
    try {
      final rpcSigner = MultisigRPCSigner();
      
      final walletKeys = group.keys.where((k) => k.isWallet).toList();
      if (walletKeys.isEmpty) {
        throw Exception('No wallet keys found in group');
      }
      
      final alreadySigned = walletKeys.any((walletKey) =>
        tx.keyPSBTs.any((kp) => kp.keyId == walletKey.xpub && kp.isSigned),
      );
      
      if (alreadySigned) {
        MultisigLogger.info('Wallet has already signed this transaction');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaction already signed by this wallet')),
          );
        }
        return;
      }
      
      if (_hdWalletProvider.mnemonic == null) {
        throw Exception('HD wallet not initialized - no mnemonic available');
      }
      
      final mnemonic = _hdWalletProvider.mnemonic!;
      
      final isMainnet = await _rpc.callRAW('getblockchaininfo').then((info) {
        if (info is Map) {
          final chain = info['chain'] as String? ?? 'main';
          return chain == 'main';
        }
        return false;
      });
      
      final signingResult = await rpcSigner.signPSBT(
        psbtBase64: tx.initialPSBT,
        group: group,
        mnemonic: mnemonic,
        walletKeys: walletKeys,
        isMainnet: isMainnet,
      );
      
      MultisigLogger.info('PSBT signed successfully: ${signingResult.signaturesAdded} signatures added, complete: ${signingResult.isComplete}');
      
      if (signingResult.errors.isNotEmpty) {
        MultisigLogger.error('Signing warnings: ${signingResult.errors.join(', ')}');
      }
      
      // Only update keys that are owned by this wallet (generated, not imported)
      final ownedKeys = walletKeys.where((key) => key.isWallet).toList();
      for (final key in ownedKeys) {
        await TransactionStorage.updateKeyPSBT(
          tx.id, 
          key.xpub, 
          signingResult.signedPsbt,
          signatureThreshold: group.m,
          isOwnedKey: true,
        );
      }
      
      // Transaction notifier will handle the signing status update automatically
      
      if (context.mounted) {
        if (signingResult.signaturesAdded > 0) {
          final message = signingResult.isComplete 
              ? 'Transaction signed and completed successfully!'
              : 'Transaction signed successfully (${signingResult.signaturesAdded} signatures added)';
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add signatures to transaction'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      
      MultisigLogger.info('Transaction signing completed successfully');
      
    } catch (e) {
      MultisigLogger.error('Error in transaction signing: $e');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sign transaction: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _copySpecificPSBT(BuildContext context, String psbtData, String psbtName) async {
    try {
      if (psbtData.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$psbtName is empty'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      
      await Clipboard.setData(ClipboardData(text: psbtData));
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$psbtName copied to clipboard'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      _logger.e('Failed to copy $psbtName to clipboard: $e');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to copy $psbtName: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // Remove listeners
    TransactionStorage.notifier.removeListener(_transactionListener);
    _blockchainProvider.removeListener(_blockchainListener);
    
    super.dispose();
  }
}