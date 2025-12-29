import 'package:bitwindow/pages/explorer/block_explorer_dialog.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:bitwindow/providers/coin_selection_provider.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/gen/wallet/v1/wallet.pb.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class UTXOsTab extends StatelessWidget {
  const UTXOsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return ViewModelBuilder<LatestUTXOsViewModel>.reactive(
          viewModelBuilder: () => LatestUTXOsViewModel(),
          builder: (context, model, child) {
            return UTXOTable(
              entries: model.entries,
              model: model,
            );
          },
        );
      },
    );
  }
}

class UTXOTable extends StatefulWidget {
  final List<UnspentOutput> entries;
  final LatestUTXOsViewModel model;

  const UTXOTable({
    super.key,
    required this.entries,
    required this.model,
  });

  @override
  State<UTXOTable> createState() => _UTXOTableState();
}

class _UTXOTableState extends State<UTXOTable> {
  String sortColumn = 'date';
  bool sortAscending = true;
  List<UnspentOutput> sortedEntries = [];
  bool hideFrozen = false;

  CoinSelectionProvider get _coinSelection => GetIt.I<CoinSelectionProvider>();
  BitwindowRPC get _rpc => GetIt.I<BitwindowRPC>();

  @override
  void initState() {
    super.initState();
    sortedEntries = List.from(widget.entries);
    sortEntries();
    _coinSelection.addListener(_onMetadataChange);
  }

  @override
  void dispose() {
    _coinSelection.removeListener(_onMetadataChange);
    super.dispose();
  }

  void _onMetadataChange() {
    setState(() {
      sortEntries();
    });
  }

  @override
  void didUpdateWidget(UTXOTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.entries != oldWidget.entries) {
      sortedEntries = List.from(widget.entries);
      sortEntries();
    }
  }

  void onSort(String column) {
    setState(() {
      if (sortColumn == column) {
        sortAscending = !sortAscending;
      } else {
        sortColumn = column;
        sortAscending = true;
      }
      sortEntries();
    });
  }

  void sortEntries() {
    var entries = List<UnspentOutput>.from(widget.entries);

    // Filter frozen if needed
    if (hideFrozen) {
      entries = entries.where((u) => !_coinSelection.isFrozen(u.output)).toList();
    }

    entries.sort((a, b) {
      dynamic aValue, bValue;
      switch (sortColumn) {
        case 'frozen':
          aValue = _coinSelection.isFrozen(a.output) ? 1 : 0;
          bValue = _coinSelection.isFrozen(b.output) ? 1 : 0;
          break;
        case 'date':
          aValue = a.receivedAt.toDateTime();
          bValue = b.receivedAt.toDateTime();
          if (aValue.compareTo(bValue) == 0) {
            return a.output.compareTo(b.output);
          }
          break;
        case 'output':
          aValue = a.output;
          bValue = b.output;
          break;
        case 'address':
          aValue = a.address;
          bValue = b.address;
          break;
        case 'label':
          aValue = _getLabel(a);
          bValue = _getLabel(b);
          break;
        case 'value':
          aValue = a.valueSats;
          bValue = b.valueSats;
          break;
        case 'deniability':
          aValue = getDenialHops(a);
          bValue = getDenialHops(b);
          break;
      }
      return sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });

    sortedEntries = entries;
  }

  String _getLabel(UnspentOutput utxo) {
    final metaLabel = _coinSelection.getLabel(utxo.output);
    return metaLabel.isNotEmpty ? metaLabel : utxo.label;
  }

  int getDenialHops(UnspentOutput utxo) {
    if (!utxo.hasDenialInfo()) return 0;
    return utxo.denialInfo.hopsCompleted;
  }

  String getDenialStatus(UnspentOutput utxo) {
    if (!utxo.hasDenialInfo()) return '-';

    final hops = utxo.denialInfo.hopsCompleted;
    final totalHops = utxo.denialInfo.numHops;

    if (hops >= totalHops && totalHops > 0) {
      return 'Done ($hops)';
    }
    if (!utxo.denialInfo.hasNextExecutionTime() ||
        utxo.denialInfo.nextExecutionTime.toDateTime().millisecondsSinceEpoch == 0) {
      if (utxo.denialInfo.hasCancelTime()) {
        return 'Cancelled ($hops)';
      }
      return 'Done ($hops)';
    }
    if (utxo.denialInfo.hasCancelTime()) {
      return 'Cancelled ($hops)';
    }
    if (utxo.denialInfo.hasPausedAt()) {
      return 'Paused ($hops/$totalHops)';
    }
    return 'Active ($hops/$totalHops)';
  }

  Color? getDenialColor(BuildContext context, UnspentOutput utxo) {
    final theme = SailTheme.of(context);
    final hops = getDenialHops(utxo);

    if (hops == 0) {
      return theme.colors.error;
    } else if (hops <= 2) {
      return theme.colors.orange;
    } else {
      return theme.colors.success;
    }
  }

  bool isDenied(UnspentOutput utxo) {
    return utxo.hasDenialInfo() && getDenialHops(utxo) > 0;
  }

  Future<void> _showLabelDialog(BuildContext context, UnspentOutput utxo) async {
    final controller = TextEditingController(text: _getLabel(utxo));
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit UTXO Label'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Label',
            hintText: 'e.g., Cold storage, Exchange deposit',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null) {
      await _rpc.wallet.setUTXOMetadata(utxo.output, label: result);
      await _coinSelection.fetch();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = GetIt.I<FormatterProvider>();
    final theme = SailTheme.of(context);
    final frozenCount = widget.entries.where((u) => _coinSelection.isFrozen(u.output)).length;

    return SailCard(
      title: 'Your UTXOs',
      bottomPadding: false,
      widgetHeaderEnd: SailCheckbox(
        value: hideFrozen,
        onChanged: (value) {
          setState(() {
            hideFrozen = value;
            sortEntries();
          });
        },
        label: 'Hide frozen ($frozenCount)',
      ),
      child: Column(
        children: [
          Expanded(
            child: SailSkeletonizer(
              description: 'Waiting for enforcer to start and wallet to sync..',
              enabled: widget.model.loading,
              child: ListenableBuilder(
                listenable: Listenable.merge([formatter, _coinSelection]),
                builder: (context, child) => SailTable(
                  rowBackgroundColor: (index) {
                    final utxo = sortedEntries[index];
                    if (_coinSelection.isFrozen(utxo.output)) {
                      return theme.colors.divider.withValues(alpha: 0.3);
                    }
                    return isDenied(utxo) ? Colors.green.withValues(alpha: 0.1) : null;
                  },
                  getRowId: (index) => sortedEntries[index].output,
                  headerBuilder: (context) => [
                    SailTableHeaderCell(name: '', onSort: () => onSort('frozen')),
                    SailTableHeaderCell(name: 'Date', onSort: () => onSort('date')),
                    SailTableHeaderCell(name: 'Output', onSort: () => onSort('output')),
                    SailTableHeaderCell(name: 'Address', onSort: () => onSort('address')),
                    SailTableHeaderCell(name: 'Label', onSort: () => onSort('label')),
                    SailTableHeaderCell(name: 'Deniability', onSort: () => onSort('deniability')),
                    SailTableHeaderCell(name: 'Amount', onSort: () => onSort('value')),
                  ],
                  rowBuilder: (context, row, selected) {
                    final utxo = sortedEntries[row];
                    final formattedAmount = formatter.formatSats(utxo.valueSats.toInt());
                    final isFrozen = _coinSelection.isFrozen(utxo.output);

                    return [
                      SailTableCell(
                        value: '',
                        child: isFrozen
                            ? Icon(Icons.ac_unit, size: 14, color: theme.colors.info)
                            : const SizedBox(width: 14),
                      ),
                      SailTableCell(
                        value: formatDate(utxo.receivedAt.toDateTime().toLocal()),
                      ),
                      SailTableCell(
                        value: '${utxo.output.substring(0, 6)}..:${utxo.output.split(':').last}',
                        copyValue: utxo.output,
                      ),
                      SailTableCell(
                        value: utxo.address,
                        copyValue: utxo.address,
                        monospace: true,
                      ),
                      SailTableCell(
                        value: _getLabel(utxo),
                        monospace: true,
                      ),
                      SailTableCell(
                        value: getDenialStatus(utxo),
                        textColor: getDenialColor(context, utxo),
                        monospace: true,
                      ),
                      SailTableCell(
                        value: formattedAmount,
                        monospace: true,
                      ),
                    ];
                  },
                  rowCount: sortedEntries.length,
                  emptyPlaceholder: hideFrozen ? 'No unfrozen UTXOs' : 'No UTXOs in wallet',
                  drawGrid: true,
                  sortColumnIndex: [
                    'frozen',
                    'date',
                    'output',
                    'address',
                    'label',
                    'deniability',
                    'value',
                  ].indexOf(sortColumn),
                  sortAscending: sortAscending,
                  onSort: (columnIndex, ascending) {
                    onSort(['frozen', 'date', 'output', 'address', 'label', 'deniability', 'value'][columnIndex]);
                  },
                  onDoubleTap: (rowId) => showTransactionDetails(context, rowId.split(':').first),
                  contextMenuItems: (rowId) {
                    final utxo = sortedEntries.firstWhere((u) => u.output == rowId);
                    final isFrozen = _coinSelection.isFrozen(rowId);

                    return [
                      SailMenuItem(
                        onSelected: () async {
                          await _rpc.wallet.setUTXOMetadata(rowId, isFrozen: !isFrozen);
                          await _coinSelection.fetch();
                        },
                        child: SailText.primary12(isFrozen ? 'Unfreeze UTXO' : 'Freeze UTXO'),
                      ),
                      SailMenuItem(
                        onSelected: () async {
                          await _showLabelDialog(context, utxo);
                        },
                        child: SailText.primary12('Edit Label'),
                      ),
                      SailMenuItem(
                        onSelected: () async {
                          await showTransactionDetails(context, rowId.split(':').first);
                        },
                        child: SailText.primary12('Show Details'),
                      ),
                      MempoolMenuItem(txid: rowId.split(':').first),
                    ];
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LatestUTXOsViewModel extends BaseViewModel with ChangeTrackingMixin {
  final TransactionProvider _txProvider = GetIt.I<TransactionProvider>();
  final EnforcerRPC _enforcerRPC = GetIt.I<EnforcerRPC>();

  List<UnspentOutput> get entries {
    if (loading) {
      return [
        UnspentOutput(
          output: 'dummy_output:0',
          address: 'dummy_address',
          label: 'dummy_label',
        ),
        UnspentOutput(
          output: 'dummy_output:1',
          address: 'dummy_address',
          label: 'dummy_label',
        ),
        UnspentOutput(
          output: 'dummy_output:2',
          address: 'dummy_address',
          label: 'dummy_label',
        ),
      ];
    }

    return _txProvider.utxos.toList();
  }

  String sortColumn = 'date';
  bool sortAscending = true;

  LatestUTXOsViewModel() {
    initChangeTracker();
    _txProvider.addListener(_onChange);
  }

  void _onChange() {
    track('entriesss', entries);
    track('loading', loading);
    notifyIfChanged();
  }

  bool get loading => _enforcerRPC.initializingBinary;

  @override
  void dispose() {
    _txProvider.removeListener(_onChange);
    super.dispose();
  }
}
