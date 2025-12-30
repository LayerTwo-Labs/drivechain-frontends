import 'package:bitwindow/pages/explorer/block_explorer_dialog.dart';
import 'package:bitwindow/pages/wallet/widgets/utxo_distribution_chart.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:bitwindow/providers/coin_selection_provider.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/gen/wallet/v1/wallet.pb.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class UTXOsTab extends StatefulWidget {
  const UTXOsTab({super.key});

  @override
  State<UTXOsTab> createState() => _UTXOsTabState();
}

class _UTXOsTabState extends State<UTXOsTab> {
  // Row height in SailTable (approx - includes padding)
  static const double _rowHeight = 36.0;
  static const double _headerHeight = 40.0;
  static const double _cardPadding = 80.0; // title + padding

  BitwindowRPC get _rpc => GetIt.I<BitwindowRPC>();
  CoinSelectionProvider get _coinSelection => GetIt.I<CoinSelectionProvider>();
  WalletReaderProvider get _walletReader => GetIt.I<WalletReaderProvider>();

  void _showBucketContextMenu(BuildContext context, UTXOBucket bucket, Offset position) {
    final isSingleUtxo = bucket.count == 1;
    final outpoint = isSingleUtxo ? bucket.outpoints.first : null;

    showSailMenu(
      context: context,
      preferredAnchorPoint: position,
      menu: SailMenu(
        items: [
          if (isSingleUtxo && outpoint != null) ...[
            SailMenuItem(
              onSelected: () async {
                final isFrozen = _coinSelection.isFrozen(outpoint);
                await _rpc.wallet.setUTXOMetadata(outpoint, isFrozen: !isFrozen);
                await _coinSelection.fetch();
              },
              child: SailText.primary12(
                _coinSelection.isFrozen(outpoint) ? 'Unfreeze UTXO' : 'Freeze UTXO',
              ),
            ),
            SailMenuItem(
              onSelected: () async {
                final txid = outpoint.split(':').first;
                await showTransactionDetails(context, txid);
              },
              child: SailText.primary12('Show Transaction'),
            ),
          ],
          SailMenuItem(
            onSelected: () {
              showSnackBar(context, 'Selected ${bucket.count} UTXO(s) for sending - go to Send tab');
            },
            child: SailText.primary12(
              isSingleUtxo ? 'Send This UTXO' : 'Send These ${bucket.count} UTXOs',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleConsolidate(BuildContext context, List<UTXOBucket> smallBuckets) async {
    final walletId = _walletReader.activeWalletId;
    if (walletId == null) return;

    // Show the consolidation dialog
    await showDialog(
      context: context,
      builder: (context) => _ConsolidateDialog(
        walletId: walletId,
        initialBuckets: smallBuckets,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return ViewModelBuilder<LatestUTXOsViewModel>.reactive(
          viewModelBuilder: () => LatestUTXOsViewModel(),
          builder: (context, model, child) {
            final walletId = _walletReader.activeWalletId;
            final showChart = walletId != null && !model.loading;

            // Calculate table height based on row count - show ALL rows
            final rowCount = model.entries.length;
            final tableContentHeight = _headerHeight + (rowCount * _rowHeight) + _cardPadding;
            // Minimum height to fill available space, or larger if more rows
            final tableHeight = tableContentHeight.clamp(
              constraints.maxHeight - (showChart ? 280 : 0),
              double.infinity,
            );

            return SingleChildScrollView(
              child: Column(
                children: [
                  // UTXO Distribution Chart
                  if (showChart)
                    Padding(
                      padding: const EdgeInsets.only(bottom: SailStyleValues.padding16),
                      child: SailCard(
                        title: 'UTXO Distribution',
                        child: UTXODistributionChart(
                          walletId: walletId,
                          onBucketContextMenu: (bucket, position) {
                            _showBucketContextMenu(context, bucket, position);
                          },
                          onConsolidate: (smallBuckets) {
                            _handleConsolidate(context, smallBuckets);
                          },
                        ),
                      ),
                    ),

                  // UTXO Table - height based on content to show all rows
                  SizedBox(
                    height: tableHeight,
                    child: UTXOTable(
                      entries: model.entries,
                      model: model,
                    ),
                  ),
                ],
              ),
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
      builder: (context) => SailDialog(
        title: 'Edit UTXO Label',
        subtitle: 'Add a label to help identify this UTXO',
        maxWidth: 400,
        maxHeight: 200,
        actions: [
          SailButton(
            label: 'Cancel',
            variant: ButtonVariant.ghost,
            onPressed: () async => Navigator.pop(context),
          ),
          SailButton(
            label: 'Save',
            onPressed: () async => Navigator.pop(context, controller.text),
          ),
        ],
        child: SailTextField(
          controller: controller,
          hintText: 'e.g., Cold storage, Exchange deposit',
          autofocus: true,
        ),
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
                  child: isFrozen ? Icon(Icons.ac_unit, size: 14, color: theme.colors.info) : const SizedBox(width: 14),
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

/// Dialog for consolidating small UTXOs
class _ConsolidateDialog extends StatefulWidget {
  final String walletId;
  final List<UTXOBucket> initialBuckets;

  const _ConsolidateDialog({
    required this.walletId,
    required this.initialBuckets,
  });

  @override
  State<_ConsolidateDialog> createState() => _ConsolidateDialogState();
}

class _ConsolidateDialogState extends State<_ConsolidateDialog> {
  BitwindowRPC get _rpc => GetIt.I<BitwindowRPC>();
  TransactionProvider get _txProvider => GetIt.I<TransactionProvider>();
  FormatterProvider get _formatter => GetIt.I<FormatterProvider>();

  // Threshold options in satoshis
  static const List<int> _thresholdOptions = [
    10000, // 0.0001 BTC
    50000, // 0.0005 BTC
    100000, // 0.001 BTC
    500000, // 0.005 BTC
    1000000, // 0.01 BTC
    5000000, // 0.05 BTC
    10000000, // 0.1 BTC
  ];

  int _selectedThreshold = 100000; // Default 0.001 BTC
  Set<String> _selectedOutpoints = {};
  bool _isLoading = false;

  List<UnspentOutput> get _allUtxos => _txProvider.utxos.toList();

  List<UnspentOutput> get _utxosBelowThreshold {
    return _allUtxos.where((u) => u.valueSats.toInt() <= _selectedThreshold).toList()
      ..sort((a, b) => a.valueSats.compareTo(b.valueSats));
  }

  int get _totalSelectedSats {
    return _selectedOutpoints.fold<int>(0, (sum, op) {
      final utxo = _allUtxos.firstWhere((u) => u.output == op, orElse: () => UnspentOutput());
      return sum + utxo.valueSats.toInt();
    });
  }

  @override
  void initState() {
    super.initState();
    // Pre-select UTXOs from initial buckets
    for (final bucket in widget.initialBuckets) {
      _selectedOutpoints.addAll(bucket.outpoints);
    }
    // Also select any below default threshold
    _updateSelectionFromThreshold();
  }

  void _updateSelectionFromThreshold() {
    setState(() {
      _selectedOutpoints = _utxosBelowThreshold.map((u) => u.output).toSet();
    });
  }

  Future<void> _consolidate() async {
    if (_selectedOutpoints.length < 2) {
      showSnackBar(context, 'Select at least 2 UTXOs to consolidate');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get a new address for the consolidated output
      final newAddress = await _rpc.wallet.getNewAddress(widget.walletId);

      // Build list of required inputs
      final requiredInputs = _selectedOutpoints.map((op) => UnspentOutput(output: op)).toList();

      // Send transaction - fee will be deducted from total
      await _rpc.wallet.sendTransaction(
        widget.walletId,
        {newAddress: _totalSelectedSats},
        feeSatPerVbyte: 1, // Low fee rate for consolidation
        requiredInputs: requiredInputs,
      );

      if (mounted) {
        Navigator.pop(context);
        showSnackBar(context, 'Consolidation transaction sent!');
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, 'Consolidation failed: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final utxosBelowThreshold = _utxosBelowThreshold;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
        child: SailCard(
          title: 'Consolidate UTXOs',
          subtitle: 'Combine multiple small UTXOs into one',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Threshold selector
              SailRow(
                spacing: SailStyleValues.padding12,
                children: [
                  SailText.primary13('Include UTXOs smaller than:'),
                  SailDropdownButton<int>(
                    value: _selectedThreshold,
                    items: _thresholdOptions.map((sats) {
                      return SailDropdownItem<int>(
                        value: sats,
                        label: _formatter.formatSats(sats),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _selectedThreshold = value;
                        _updateSelectionFromThreshold();
                      }
                    },
                  ),
                ],
              ),

              const SailSpacing(SailStyleValues.padding12),

              // Summary
              Container(
                padding: const EdgeInsets.all(SailStyleValues.padding12),
                decoration: BoxDecoration(
                  color: theme.colors.backgroundSecondary,
                  borderRadius: SailStyleValues.borderRadiusSmall,
                ),
                child: SailRow(
                  spacing: SailStyleValues.padding16,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SailText.secondary13('${_selectedOutpoints.length} UTXOs selected'),
                    SailText.primary13(_formatter.formatSats(_totalSelectedSats)),
                  ],
                ),
              ),

              const SailSpacing(SailStyleValues.padding12),

              // UTXO list
              SailText.secondary12('Select UTXOs to consolidate:'),
              const SailSpacing(SailStyleValues.padding08),

              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colors.divider),
                    borderRadius: SailStyleValues.borderRadiusSmall,
                  ),
                  child: utxosBelowThreshold.isEmpty
                      ? Center(
                          child: SailText.secondary12('No UTXOs below threshold'),
                        )
                      : ListView.builder(
                          itemCount: utxosBelowThreshold.length,
                          itemBuilder: (context, index) {
                            final utxo = utxosBelowThreshold[index];
                            final isSelected = _selectedOutpoints.contains(utxo.output);

                            return InkWell(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedOutpoints.remove(utxo.output);
                                  } else {
                                    _selectedOutpoints.add(utxo.output);
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: SailStyleValues.padding12,
                                  vertical: SailStyleValues.padding08,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected ? theme.colors.info.withValues(alpha: 0.1) : Colors.transparent,
                                  border: Border(
                                    bottom: BorderSide(color: theme.colors.divider, width: 0.5),
                                  ),
                                ),
                                child: SailRow(
                                  spacing: SailStyleValues.padding12,
                                  children: [
                                    SailCheckbox(
                                      value: isSelected,
                                      onChanged: (value) {
                                        setState(() {
                                          if (value) {
                                            _selectedOutpoints.add(utxo.output);
                                          } else {
                                            _selectedOutpoints.remove(utxo.output);
                                          }
                                        });
                                      },
                                    ),
                                    Expanded(
                                      child: SailText.secondary12(
                                        '${utxo.output.substring(0, 8)}...:${utxo.output.split(':').last}',
                                        monospace: true,
                                      ),
                                    ),
                                    SailText.primary12(
                                      _formatter.formatSats(utxo.valueSats.toInt()),
                                      monospace: true,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),

              const SailSpacing(SailStyleValues.padding16),

              // Actions
              SailRow(
                spacing: SailStyleValues.padding08,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SailButton(
                    label: 'Cancel',
                    variant: ButtonVariant.ghost,
                    onPressed: () async => Navigator.pop(context),
                  ),
                  SailButton(
                    label: 'Consolidate ${_selectedOutpoints.length} UTXOs',
                    disabled: _selectedOutpoints.length < 2,
                    loading: _isLoading,
                    onPressed: _consolidate,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
