import 'dart:convert';
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
import 'package:bitwindow/widgets/sign_preview_modal.dart';
import 'package:bitwindow/providers/hd_wallet_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

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

class _MultisigLoungeTabState extends State<MultisigLoungeTab>
    with WidgetsBindingObserver {
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

  Widget _buildGroupsSection(BuildContext context,
      MultisigLoungeViewModel viewModel, BoxConstraints constraints,) {
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
                onSelectGroup: viewModel._stateManager.setSelectedGroup,
                isLoading: viewModel.isLoadingGroups,
              ),
            ),
          ),
        ),
        const SizedBox(width: SailStyleValues.padding16),
        SizedBox(
          width: 240,
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

  Widget _buildTransactionsSection(BuildContext context,
      MultisigLoungeViewModel viewModel, BoxConstraints constraints,) {
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
                onAction: (tx, group) =>
                    viewModel.handleTransactionAction(context, tx, group),
                onBroadcast: () =>
                    viewModel.openCombineAndBroadcastModal(context),
                onView: (tx) => viewModel.openTransactionModal(context, tx),
                onSign: (tx, group) =>
                    viewModel.signTransaction(context, tx, group),
                isLoading: viewModel.isLoadingTransactions,
              ),
            ),
          ),
        ),
        const SizedBox(width: SailStyleValues.padding16),
        SizedBox(
          width: 240,
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
                        onPressed: viewModel.multisigGroups
                                .any((g) => g.balance > 0)
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
                        onPressed: () =>
                            viewModel.openCombineAndBroadcastModal(context),
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

class MultisigGroupsTable extends StatefulWidget {
  final List<MultisigGroup> groups;
  final MultisigGroup? selectedGroup;
  final Function(MultisigGroup?) onSelectGroup;
  final bool isLoading;

  const MultisigGroupsTable({
    super.key,
    required this.groups,
    required this.selectedGroup,
    required this.onSelectGroup,
    this.isLoading = false,
  });

  @override
  State<MultisigGroupsTable> createState() => _MultisigGroupsTableState();
}

class _MultisigGroupsTableState extends State<MultisigGroupsTable> {
  String sortColumn = 'name';
  bool sortAscending = true;
  List<MultisigGroup> _sortedGroups = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSortedGroups();
  }

  @override
  void didUpdateWidget(MultisigGroupsTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.groups != widget.groups) {
      _updateSortedGroups();
    }
  }

  void onSort(String column) {
    if (sortColumn == column) {
      sortAscending = !sortAscending;
    } else {
      sortColumn = column;
      sortAscending = true;
    }
    _updateSortedGroups();
  }

  void _updateSortedGroups() {
    _sortedGroups = List<MultisigGroup>.from(widget.groups);
    _sortedGroups.sort((a, b) {
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

      return sortAscending
          ? aValue.compareTo(bValue)
          : bValue.compareTo(aValue);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return SailSkeletonizer(
        enabled: true,
        description: 'Loading multisig groups...',
        child: SailTable(
          getRowId: (index) => 'skeleton$index',
          headerBuilder: (context) => [
            SailTableHeaderCell(name: 'Name', onSort: () => onSort('name')),
            const SailTableHeaderCell(name: 'ID'),
            SailTableHeaderCell(
                name: 'Balance (BTC)', onSort: () => onSort('balance'),),
            SailTableHeaderCell(name: 'UTXOs', onSort: () => onSort('utxos')),
            SailTableHeaderCell(name: 'Total Keys', onSort: () => onSort('total')),
            SailTableHeaderCell(
                name: 'Keys Required', onSort: () => onSort('required'),),
            const SailTableHeaderCell(name: 'Type'),
          ],
          rowBuilder: (context, row, selected) => [
            const SailTableCell(value: 'Loading Group Name'),
            const SailTableCell(value: 'LOADING123'),
            const SailTableCell(value: '0.00000000'),
            const SailTableCell(value: '0'),
            const SailTableCell(value: '3'),
            const SailTableCell(value: '2'),
            const SailTableCell(value: 'xPub'),
          ],
          rowCount: 3,
          drawGrid: true,
          sortColumnIndex: [
            'name',
            'id',
            'balance',
            'utxos',
            'total',
            'required',
            'type',
          ].indexOf(sortColumn),
          sortAscending: sortAscending,
          onSort: (columnIndex, ascending) {
            onSort([
              'name',
              'id',
              'balance',
              'utxos',
              'total',
              'required',
              'type',
            ][columnIndex],);
          },
        ),
      );
    }

    return SailTable(
      getRowId: (index) =>
          _sortedGroups.isNotEmpty ? _sortedGroups[index].id : 'empty$index',
      onSelectedRow: (rowId) {
        if (rowId != null && _sortedGroups.isNotEmpty) {
          final group = _sortedGroups.firstWhere(
            (g) => g.id == rowId,
            orElse: () => _sortedGroups.first,
          );
          widget.onSelectGroup(group);
        }
      },
      headerBuilder: (context) => [
        SailTableHeaderCell(name: 'Name', onSort: () => onSort('name')),
        const SailTableHeaderCell(name: 'ID'),
        SailTableHeaderCell(
            name: 'Balance (BTC)', onSort: () => onSort('balance'),),
        SailTableHeaderCell(name: 'UTXOs', onSort: () => onSort('utxos')),
        SailTableHeaderCell(name: 'Total Keys', onSort: () => onSort('total')),
        SailTableHeaderCell(
            name: 'Keys Required', onSort: () => onSort('required'),),
        const SailTableHeaderCell(name: 'Type'),
      ],
      rowBuilder: (context, row, selected) {
        if (_sortedGroups.isEmpty) {
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

        final group = _sortedGroups[row];
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
      rowCount: _sortedGroups.isEmpty ? 1 : _sortedGroups.length,
      drawGrid: true,
      sortColumnIndex: [
        'name',
        'id',
        'balance',
        'utxos',
        'total',
        'required',
        'type',
      ].indexOf(sortColumn),
      sortAscending: sortAscending,
      onSort: (columnIndex, ascending) {
        onSort([
          'name',
          'id',
          'balance',
          'utxos',
          'total',
          'required',
          'type',
        ][columnIndex],);
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
  final bool isLoading;

  const MultisigTransactionsTable({
    super.key,
    required this.transactionRows,
    required this.groups,
    required this.onAction,
    required this.onBroadcast,
    required this.onView,
    required this.onSign,
    this.isLoading = false,
  });

  @override
  State<MultisigTransactionsTable> createState() =>
      _MultisigTransactionsTableState();
}

class _MultisigTransactionsTableState extends State<MultisigTransactionsTable> {
  String sortColumn = 'group';
  bool sortAscending = true;
  List<TransactionRow> _sortedTransactionRows = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSortedTransactions();
  }

  @override
  void didUpdateWidget(MultisigTransactionsTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.transactionRows != widget.transactionRows) {
      _updateSortedTransactions();
    }
  }

  void onSort(String column) {
    if (sortColumn == column) {
      sortAscending = !sortAscending;
    } else {
      sortColumn = column;
      sortAscending = true;
    }
    _updateSortedTransactions();
  }

  void _updateSortedTransactions() {
    _sortedTransactionRows = List<TransactionRow>.from(widget.transactionRows);
    
    _sortedTransactionRows.sort((a, b) {
      final aNeedsSignatures = (a.transaction.status == TxStatus.needsSignatures || 
                               a.transaction.status == TxStatus.awaitingSignedPSBTs) &&
                               a.transaction.type != TxType.deposit;
      final bNeedsSignatures = (b.transaction.status == TxStatus.needsSignatures || 
                               b.transaction.status == TxStatus.awaitingSignedPSBTs) &&
                               b.transaction.type != TxType.deposit;
      
      if (aNeedsSignatures && !bNeedsSignatures) return -1;
      if (!aNeedsSignatures && bNeedsSignatures) return 1;
      
      if (sortColumn != 'group') {
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
          case 'type':
            aValue = a.transaction.type.index;
            bValue = b.transaction.type.index;
            break;
          case 'confirmations':
            aValue = a.transaction.confirmations;
            bValue = b.transaction.confirmations;
            break;
          default:
            aValue = aGroup.name;
            bValue = bGroup.name;
        }

        return sortAscending
            ? aValue.compareTo(bValue)
            : bValue.compareTo(aValue);
      }
      
      return b.transaction.created.compareTo(a.transaction.created);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return SailSkeletonizer(
        enabled: true,
        description: 'Loading multisig transactions...',
        child: SailTable(
          getRowId: (index) => 'skeleton$index',
          headerBuilder: (context) => [
            SailTableHeaderCell(name: 'Group', onSort: () => onSort('group')),
            const SailTableHeaderCell(name: 'MuSIG ID'),
            SailTableHeaderCell(
                name: 'Amount (BTC)', onSort: () => onSort('amount'),),
            SailTableHeaderCell(
                name: 'Signatures', onSort: () => onSort('signatures'),),
            SailTableHeaderCell(name: 'Status', onSort: () => onSort('status')),
            SailTableHeaderCell(name: 'Type', onSort: () => onSort('type')),
            const SailTableHeaderCell(name: 'TXID'),
            SailTableHeaderCell(
                name: 'Confirmations', onSort: () => onSort('confirmations'),),
            const SailTableHeaderCell(name: 'Action'),
          ],
          rowBuilder: (context, row, selected) => [
            const SailTableCell(value: 'Loading Group'),
            const SailTableCell(value: 'abc123'),
            const SailTableCell(value: '0.00100000'),
            const SailTableCell(value: '1/2'),
            const SailTableCell(value: 'Needs Signatures'),
            const SailTableCell(value: 'Withdrawal'),
            const SailTableCell(value: 'abc123...'),
            const SailTableCell(value: '-'),
            SailTableCell(
              value: 'Action Button',
              alignment: Alignment.center,
              child: Center(
                child: SailButton(
                  label: 'Loading',
                  variant: ButtonVariant.secondary,
                  insideTable: true,
                  onPressed: null,
                ),
              ),
            ),
          ],
          rowCount: 3,
          drawGrid: true,
          sortColumnIndex: [
            'group',
            'id',
            'amount',
            'signatures',
            'status',
            'type',
            'txid',
            'confirmations',
            'action',
          ].indexOf(sortColumn),
          sortAscending: sortAscending,
          onSort: (columnIndex, ascending) {
            onSort([
              'group',
              'id',
              'amount',
              'signatures',
              'status',
              'type',
              'txid',
              'confirmations',
              'action',
            ][columnIndex],);
          },
        ),
      );
    }

    return SailTable(
      getRowId: (index) => widget.transactionRows.isNotEmpty
          ? widget.transactionRows[index].transaction.id
          : 'empty$index',
      headerBuilder: (context) => [
        SailTableHeaderCell(name: 'Group', onSort: () => onSort('group')),
        const SailTableHeaderCell(name: 'MuSIG ID'),
        SailTableHeaderCell(
            name: 'Amount (BTC)', onSort: () => onSort('amount'),),
        SailTableHeaderCell(
            name: 'Signatures', onSort: () => onSort('signatures'),),
        SailTableHeaderCell(name: 'Status', onSort: () => onSort('status')),
        SailTableHeaderCell(name: 'Type', onSort: () => onSort('type')),
        const SailTableHeaderCell(name: 'TXID'),
        SailTableHeaderCell(
            name: 'Confirmations', onSort: () => onSort('confirmations'),),
        const SailTableHeaderCell(name: 'Action'),
      ],
      rowBuilder: (context, row, selected) {
        if (_sortedTransactionRows.isEmpty) {
          return [
            const SailTableCell(value: 'No transactions yet'),
            const SailTableCell(value: ''),
            const SailTableCell(value: ''),
            const SailTableCell(value: ''),
            const SailTableCell(value: ''),
            const SailTableCell(value: ''),
            const SailTableCell(value: ''),
            const SailTableCell(value: ''),
            const SailTableCell(value: ''),
          ];
        }

        final txRow = _sortedTransactionRows[row];
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
          SailTableCell(value: tx.type == TxType.deposit ? '-' : '${tx.signatureCount > group.m ? group.m : tx.signatureCount}/${group.m}'),
          SailTableCell(value: tx.status.displayName),
          SailTableCell(value: tx.type.displayName),
          SailTableCell(value: tx.shortTxid ?? '-'),
          SailTableCell(
              value: tx.confirmations > 0 ? tx.confirmations.toString() : '-',),
          _buildActionCell(txRow, tx, group),
        ];
      },
      rowCount:
          _sortedTransactionRows.isEmpty ? 1 : _sortedTransactionRows.length,
      drawGrid: true,
      sortColumnIndex: [
        'group',
        'id',
        'amount',
        'signatures',
        'status',
        'type',
        'txid',
        'confirmations',
        'action',
      ].indexOf(sortColumn),
      sortAscending: sortAscending,
      onSort: (columnIndex, ascending) {
        onSort([
          'group',
          'id',
          'amount',
          'signatures',
          'status',
          'type',
          'txid',
          'confirmations',
          'action',
        ][columnIndex],);
      },
    );
  }

  Widget _buildActionCell(
      TransactionRow txRow, MultisigTransaction tx, MultisigGroup group,) {
    if (txRow.hasWalletKeys &&
        !txRow.walletHasSigned &&
        (tx.status == TxStatus.needsSignatures ||
            tx.status == TxStatus.awaitingSignedPSBTs)) {
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

class MultisigLoungeViewModel extends BaseViewModel {
  final MainchainRPC _rpc = GetIt.I.get<MainchainRPC>();
  final HDWalletProvider _hdWalletProvider = GetIt.I.get<HDWalletProvider>();
  final BlockchainProvider _blockchainProvider =
      GetIt.I.get<BlockchainProvider>();
  final _walletManager = WalletRPCManager();
  final _logger = GetIt.I.get<Logger>();

  final MultisigStateManager _stateManager = MultisigStateManager();

  List<MultisigGroup> get multisigGroups => _stateManager.groups;
  List<MultisigTransaction> get transactions => _stateManager.transactions;
  MultisigGroup? get selectedGroup => _stateManager.selectedGroup;
  
  set selectedGroup(MultisigGroup? group) {
    _stateManager.setSelectedGroup(group);
  }

  late final VoidCallback _transactionListener;
  late final VoidCallback _blockchainListener;

  bool isLoading = false;
  bool isLoadingGroups = false;
  bool isLoadingTransactions = false;
  String? errorMessage;

  MultisigLoungeViewModel();

  Future<void> initialize() async {
    isLoadingGroups = true;
    isLoadingTransactions = true;
    notifyListeners();
    
    _transactionListener = () async {
      await _stateManager.refreshData();
      notifyListeners();
    };
    TransactionStorage.notifier.addListener(_transactionListener);

    _blockchainListener = () async {
      await _stateManager.refreshData();
      notifyListeners();
    };
    _blockchainProvider.addListener(_blockchainListener);

    await _stateManager.refreshData();
    await _validateAndFixWalletFlags();
    
    isLoadingGroups = false;
    isLoadingTransactions = false;
    notifyListeners();
  }

  Future<void> refreshData() async {
    isLoadingGroups = true;
    isLoadingTransactions = true;
    notifyListeners();
    
    await _stateManager.refreshData();
    isLoading = _stateManager.isLoading;
    errorMessage = _stateManager.errorMessage;
    
    isLoadingGroups = false;
    isLoadingTransactions = false;
    notifyListeners();
  }

  List<TransactionRow> get transactionRows {
    final rows = <TransactionRow>[];

    for (final tx in transactions) {
      final group = _stateManager.findGroupById(tx.groupId);
      if (group == null) continue;

      final walletKeys = group.keys.where((k) => k.isWallet).toList();
      final hasWalletKeys = walletKeys.isNotEmpty;
      
      final walletHasSigned = tx.keyPSBTs.any((kp) => 
        walletKeys.any((wk) => wk.xpub == kp.keyId) && kp.isSigned,
      );

      rows.add(
        TransactionRow(
          transaction: tx,
          hasWalletKeys: hasWalletKeys,
          walletHasSigned: walletHasSigned,
        ),
      );
    }

    return rows;
  }

  bool get hasReadyTransactions =>
      transactions.any((tx) => tx.status == TxStatus.readyForBroadcast);


  Future<void> createNewGroup(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => const CreateMultisigModal(),
    );
  }

  Future<void> importFromTxid(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const ImportTxidModal(),
    );

    if (result == true) {
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
        onImportSuccess: () {},
      ),
    );
  }

  Future<void> fundGroup(BuildContext context, MultisigGroup group) async {
    try {
      final address = await _getNewAddress(group);
      _logger.d('Got funding address for group ${group.name}: $address');

      if (context.mounted) {
        await showDialog<bool>(
          context: context,
          builder: (context) => FundGroupModal(
            groups: [group],
          ),
        );
      }

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
      await showDialog<bool>(
        context: context,
        builder: (context) => FundGroupModal(
          groups: multisigGroups,
        ),
      );

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
      await BalanceManager.updateGroupBalance(group);
    }

    return await _walletManager.getNewAddress(walletName);
  }


  Future<void> createTransaction(
      BuildContext context, MultisigGroup? group,) async {
    try {
      await showDialog<bool>(
        context: context,
        builder: (context) => PSBTCoordinatorModal(
          group: group,
          availableGroups: multisigGroups.where((g) => g.balance > 0).toList(),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create transaction: $e')),
        );
      }
    }
  }


  Future<void> _validateAndFixWalletFlags() async {
    try {
      if (!_hdWalletProvider.isInitialized) {
        _logger.d('HD wallet not initialized, skipping isWallet validation');
        return;
      }

      final mnemonic = _hdWalletProvider.mnemonic;
      if (mnemonic == null) {
        _logger.d('No mnemonic available, skipping isWallet validation');
        return;
      }

      bool groupsUpdated = false;
      final updatedGroups = <MultisigGroup>[];

      for (final group in multisigGroups) {
        bool groupUpdated = false;
        final updatedKeys = <MultisigKey>[];

        for (final key in group.keys) {
          if (key.isWallet) {
            updatedKeys.add(key);
            continue;
          }

          final walletKeyInfo = await _checkIfKeyBelongsToWallet(key, mnemonic);
          
          if (walletKeyInfo != null) {
            _logger.i('Found wallet key: ${key.owner} (${key.xpub.substring(0, 10)}...)');
            updatedKeys.add(key.copyWith(
              isWallet: true,
              derivationPath: walletKeyInfo['derivationPath'] ?? key.derivationPath,
              fingerprint: walletKeyInfo['fingerprint'] ?? key.fingerprint,
              originPath: walletKeyInfo['originPath'] ?? key.originPath,
            ),);
            groupUpdated = true;
          } else {
            updatedKeys.add(key);
          }
        }

        if (groupUpdated) {
          final updatedGroup = group.copyWith(keys: updatedKeys);
          updatedGroups.add(updatedGroup);
          groupsUpdated = true;
        } else {
          updatedGroups.add(group);
        }
      }

      if (groupsUpdated) {
        await MultisigStorage.saveGroups(updatedGroups);
        await _stateManager.refreshData();
        _logger.i('Updated isWallet flags for restored wallet keys');
        
        for (final group in updatedGroups) {
          if (group.keys.any((k) => k.isWallet)) {
            try {
              _logger.i('Restoring transaction history for wallet group: ${group.name}');
              await MultisigStorage.restoreTransactionHistory(group);
              _logger.i('Transaction history restoration completed for group: ${group.name}');
              
              _logger.i('Updating group balance and wallet state for: ${group.name}');
              await BalanceManager.updateGroupBalance(group);
              _logger.i('Balance and wallet state updated for group: ${group.name}');
            } catch (e) {
              _logger.e('Failed to restore transaction history for group ${group.name}: $e');
            }
          }
        }
        
        notifyListeners();
      }
    } catch (e) {
      _logger.e('Error validating wallet flags: $e');
    }
  }

  Future<Map<String, String>?> _checkIfKeyBelongsToWallet(MultisigKey key, String mnemonic) async {
    try {
      if (key.derivationPath.isNotEmpty) {
        final pathMatch = RegExp(r"m/84'/[01]'/(\d+)'").firstMatch(key.derivationPath);
        if (pathMatch != null) {
          final accountIndex = int.parse(pathMatch.group(1)!);
          _logger.d('Found derivation path ${key.derivationPath}, trying account index $accountIndex for key ${key.owner}');
          return await _tryDeriveKeyAtIndex(key, mnemonic, accountIndex);
        }
      }

      if (key.owner.startsWith('MyKey')) {
        final match = RegExp(r'MyKey(\d+)').firstMatch(key.owner);
        if (match != null) {
          final keyNumber = int.tryParse(match.group(1) ?? '');
          if (keyNumber != null) {
            final accountIndex = 8000 + keyNumber;
            _logger.d('Found owner pattern ${key.owner}, trying account index $accountIndex');
            final result = await _tryDeriveKeyAtIndex(key, mnemonic, accountIndex);
            if (result != null) {
              return result;
            }
          }
        }
      }

      _logger.d('No derivation path or owner pattern match, trying range 8000-8099 for key ${key.owner}');
      for (int accountIndex = 8000; accountIndex < 8100; accountIndex++) {
        final result = await _tryDeriveKeyAtIndex(key, mnemonic, accountIndex);
        if (result != null) {
          return result;
        }
      }

      return null;
    } catch (e) {
      _logger.e('Error checking if key belongs to wallet: $e');
      return null;
    }
  }

  Future<Map<String, String>?> _tryDeriveKeyAtIndex(MultisigKey targetKey, String mnemonic, int accountIndex) async {
    try {
      bool isMainnet = false;
      final keyInfo = await _hdWalletProvider.generateWalletXpub(accountIndex, isMainnet);
      
      if (keyInfo.isEmpty || keyInfo['xpub'] == null) {
        return null;
      }

      final derivedXpub = keyInfo['xpub']!;
      final matches = derivedXpub == targetKey.xpub;

      if (matches) {
        _logger.i('Key match found at account index $accountIndex: ${targetKey.owner} (network: testnet)');
        return keyInfo;
      }

      return null;
    } catch (e) {
      _logger.e('Error deriving key at index $accountIndex: $e');
      return null;
    }
  }

  Future<void> openCombineAndBroadcastModal(BuildContext context) async {
    await showDialog<bool>(
      context: context,
      builder: (context) => CombineBroadcastModal(
        onSuccess: () async {
          await _stateManager.refreshData();
          notifyListeners();
        },
      ),
    );
  }

  Future<void> openTransactionModal(
      BuildContext context, MultisigTransaction transaction,) async {
    final group = multisigGroups.firstWhere(
      (g) => g.id == transaction.groupId,
      orElse: () => throw Exception('Group not found for transaction'),
    );

    await showDialog<void>(
      context: context,
      builder: (context) =>
          _buildTransactionDetailsModal(context, transaction, group),
    );
  }

  Widget _buildTransactionDetailsModal(BuildContext context,
      MultisigTransaction transaction, MultisigGroup group,) {
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
                SailRow(
                  children: [
                    SailText.primary15('Status:'),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4,),
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
                _buildDetailRow('Group:', group.name),
                _buildDetailRow(
                    'Amount:', '${transaction.amount.toStringAsFixed(8)} BTC',),
                _buildDetailRow(
                    'Fee:', '${transaction.fee.toStringAsFixed(8)} BTC',),
                _buildDetailRow('Destination:', transaction.destination),
                _buildDetailRow(
                    'Created:', _formatDateTime(transaction.created),),

                if (transaction.txid != null)
                  _buildDetailRow('Transaction ID:', transaction.txid!),

                if (transaction.confirmations > 0)
                  _buildDetailRow(
                      'Confirmations:', transaction.confirmations.toString(),),

                if (transaction.broadcastTime != null)
                  _buildDetailRow('Broadcasted:',
                      _formatDateTime(transaction.broadcastTime!),),

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
                      SailText.secondary12(
                          'Required signatures: ${transaction.requiredSignatures}',),
                      SailText.secondary12(
                          'Current signatures: ${transaction.keyPSBTs.where((k) => k.isSigned).length}',),
                      const SizedBox(height: 8),
                      ...transaction.keyPSBTs.map((keyPSBT) {
                        final keyName = group.keys
                            .firstWhere(
                              (k) => k.xpub == keyPSBT.keyId,
                              orElse: () => MultisigKey(
                                xpub: keyPSBT.keyId,
                                owner: 'Unknown',
                                derivationPath: '',
                                isWallet: false,
                              ),
                            )
                            .owner;

                        return SailRow(
                          children: [
                            SailText.secondary12(keyName),
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2,),
                              decoration: BoxDecoration(
                                color: keyPSBT.isSigned
                                    ? Colors.green
                                    : Colors.grey,
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
                      SailRow(
                        children: [
                          Expanded(
                            child:
                                SailText.secondary12('Initial PSBT (unsigned)'),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2,),
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
                            label: 'Export',
                            variant: ButtonVariant.ghost,
                            small: true,
                            onPressed: () async => _exportPSBTToFile(
                                context,
                                transaction.initialPSBT,
                                transaction,
                                group,
                                'Initial',
                                false,),
                          ),
                        ],
                      ),
                      ...transaction.keyPSBTs.map((keyPSBT) {
                        final keyName = group.keys
                            .firstWhere(
                              (k) => k.xpub == keyPSBT.keyId,
                              orElse: () => MultisigKey(
                                xpub: keyPSBT.keyId,
                                owner: 'Unknown',
                                derivationPath: '',
                                isWallet: false,
                              ),
                            )
                            .owner;

                        return SailRow(
                          children: [
                            Expanded(
                              child: SailText.secondary12('$keyName PSBT'),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2,),
                              decoration: BoxDecoration(
                                color: keyPSBT.isSigned
                                    ? Colors.green
                                    : Colors.grey,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: SailText.primary10(
                                keyPSBT.isSigned ? 'Signed' : 'Unsigned',
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            SailButton(
                              label: 'Export',
                              variant: ButtonVariant.ghost,
                              small: true,
                              onPressed: (keyPSBT.psbt?.isNotEmpty ?? false)
                                  ? () async => _exportPSBTToFile(
                                      context,
                                      keyPSBT.psbt!,
                                      transaction,
                                      group,
                                      keyName,
                                      keyPSBT.isSigned,)
                                  : null,
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),

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
      case TxStatus.readyToCombine:
        return Colors.lightBlue;
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
      case TxStatus.readyToCombine:
        return 'Ready to Combine';
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

  Future<void> handleTransactionAction(
      BuildContext context, MultisigTransaction tx, MultisigGroup group,) async {
    switch (tx.status) {
      case TxStatus.needsSignatures:
      case TxStatus.awaitingSignedPSBTs:
        final walletKeys = group.keys.where((k) => k.isWallet).toList();
        final canSign = walletKeys.isNotEmpty && tx.keyPSBTs.any((kp) => 
          !kp.isSigned && 
          kp.psbt != null &&
          walletKeys.any((wk) => wk.xpub == kp.keyId),
        );

        if (canSign) {
          await showSignPreview(context, tx, group);
        } else {
          await openTransactionModal(context, tx);
        }
        break;
      case TxStatus.readyToCombine:
      case TxStatus.readyForBroadcast:
      case TxStatus.broadcasted:
      case TxStatus.confirmed:
      case TxStatus.completed:
      case TxStatus.voided:
        await openTransactionModal(context, tx);
        break;
    }
  }

  Future<void> showSignPreview(
      BuildContext context, MultisigTransaction tx, MultisigGroup group,) async {
    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (context) => SignPreviewModal(
        transaction: tx,
        group: group,
        onSignConfirm: () => signTransaction(context, tx, group),
      ),
    );
  }

  Future<void> signTransaction(
      BuildContext context, MultisigTransaction tx, MultisigGroup group,) async {
    MultisigLogger.info(
        'Starting transaction signing for ${tx.id} in group ${group.name}',);

    try {
      final rpcSigner = MultisigRPCSigner();

      final initialSignedCount = tx.keyPSBTs.where((kp) => kp.isSigned).length;

      final walletKeys = group.keys.where((k) => k.isWallet).toList();
      if (walletKeys.isEmpty) {
        throw Exception('No wallet keys found in group');
      }

      final canSign = walletKeys.isNotEmpty && tx.keyPSBTs.any((kp) => 
        !kp.isSigned && 
        kp.psbt != null &&
        walletKeys.any((wk) => wk.xpub == kp.keyId),
      );

      if (!canSign) {
        MultisigLogger.info('No unsigned PSBTs available for wallet keys');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('No unsigned PSBTs available to sign'),),
          );
        }
        return;
      }

      if (_hdWalletProvider.mnemonic == null) {
        await _hdWalletProvider.reinitialize();
        
        if (_hdWalletProvider.mnemonic == null) {
          throw Exception('HD wallet not initialized - no mnemonic available');
        }
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

      MultisigLogger.info(
          'PSBT signed successfully: ${signingResult.signaturesAdded} signatures added, complete: ${signingResult.isComplete}',);

      if (signingResult.errors.isNotEmpty) {
        MultisigLogger.error(
            'Signing warnings: ${signingResult.errors.join(', ')}',);
      }

      final ownedKeys = walletKeys.where((key) => key.isWallet).toList();
      final unsignedOwnedKeys = ownedKeys.where((key) =>
          !tx.keyPSBTs.any((kp) => kp.keyId == key.xpub && kp.isSigned),).toList();
      
      for (final key in unsignedOwnedKeys) {
        await TransactionStorage.updateKeyPSBT(
          tx.id,
          key.xpub,
          signingResult.signedPsbt,
          signatureThreshold: group.m,
          isOwnedKey: true,
        );
      }

      if (context.mounted) {
        final updatedTx = await TransactionStorage.getTransaction(tx.id);
        final signedCount = updatedTx?.keyPSBTs.where((kp) => kp.isSigned).length ?? 0;
        final wasSuccessful = signedCount > initialSignedCount;
        
        if (wasSuccessful) {
          final message = signingResult.isComplete
              ? 'Transaction signed and completed successfully!'
              : 'Transaction signed successfully ($signedCount/${group.m} signatures)';

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
      
      await _stateManager.refreshData();
      notifyListeners();
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
      
      await _stateManager.refreshData();
    }
  }


  Future<void> _exportPSBTToFile(
      BuildContext context,
      String psbtData,
      MultisigTransaction transaction,
      MultisigGroup group,
      String keyOwner,
      bool isSigned,) async {
    try {
      if (psbtData.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PSBT data is empty'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      try {
        await _rpc.callRAW('decodepsbt', [psbtData]);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invalid PSBT format: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final exportData = {
        'transaction_id': transaction.id,
        'psbt': psbtData,
        'is_signed': isSigned,
        'key_owner': keyOwner,
        'exported_at': DateTime.now().toIso8601String(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName =
          'psbt_${isSigned ? 'signed' : 'unsigned'}_${transaction.id.substring(0, 4)}_${timestamp}_$keyOwner.json';

      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Save PSBT Export',
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final file = File(result);
        await file.writeAsString(jsonString);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'PSBT exported successfully to ${file.path.split('/').last}',),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      _logger.e('Failed to export PSBT to file: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export PSBT: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    TransactionStorage.notifier.removeListener(_transactionListener);
    _blockchainProvider.removeListener(_blockchainListener);

    super.dispose();
  }
}
