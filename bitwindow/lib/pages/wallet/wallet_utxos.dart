import 'package:bitwindow/pages/explorer/block_explorer_dialog.dart';
import 'package:bitwindow/pages/wallet/wallet_page.dart';
import 'package:bitwindow/pages/wallet/widgets/utxo_distribution_chart.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:bitwindow/providers/coin_selection_provider.dart';
import 'package:bitwindow/providers/consolidation_provider.dart';

import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart';
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
  ConsolidationProvider get _consolidation => GetIt.I<ConsolidationProvider>();
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
                // A consolidation broadcasts its queued transactions without
                // freezing again, so releasing one of its coins here would
                // break that send.
                if (_consolidation.reservedOutpoints.contains(outpoint)) {
                  showSailToast(context, 'A consolidation holds this coin. Stop it from the Consolidate tab first.');
                  return;
                }
                final isFrozen = _coinSelection.isFrozen(outpoint);
                await _rpc.wallet.setUTXOMetadata(outpoint, isFrozen: !isFrozen);
                await _coinSelection.fetch();
              },
              child: SailText.primary12(
                _consolidation.reservedOutpoints.contains(outpoint)
                    ? 'Held by a consolidation'
                    : _coinSelection.isFrozen(outpoint)
                    ? 'Unfreeze UTXO'
                    : 'Freeze UTXO',
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
              showSailToast(context, 'Selected ${bucket.count} UTXO(s) for sending - go to Send tab');
            },
            child: SailText.primary12(
              isSingleUtxo ? 'Send This UTXO' : 'Send These ${bucket.count} UTXOs',
            ),
          ),
        ],
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
                        widgetHeaderEnd: SailButton(
                          variant: ButtonVariant.icon,
                          icon: SailSVGAsset.iconQuestion,
                          onPressed: () async {
                            await widgetDialog(
                              context: context,
                              title: 'About UTXO Distribution',
                              child: SailColumn(
                                spacing: SailStyleValues.padding12,
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SailText.primary13(
                                    'UTXOs (Unspent Transaction Outputs) are the individual "coins" in your wallet. '
                                    'This chart shows how your balance is distributed across different UTXO sizes.',
                                  ),
                                  SailText.primary13(
                                    'Why it matters: Many small UTXOs can lead to higher transaction fees. '
                                    'Consider consolidating small UTXOs when fees are low.',
                                  ),
                                  SailText.primary13(
                                    'Right-click on any bar to see options for the UTXOs in that bucket.',
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        child: UTXODistributionChart(
                          walletId: walletId,
                          onBucketContextMenu: (bucket, position) {
                            _showBucketContextMenu(context, bucket, position);
                          },
                          onConsolidate: (_) => WalletPage.openSubtab(WalletPage.consolidateSubtabLabel),
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
  // One list, so a new column can't be added to the header and forgotten in
  // the sort lookups.
  static const _columns = [
    'frozen',
    'date',
    'output',
    'address',
    'path',
    'label',
    'deniability',
    'splittable',
    'value',
  ];

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
        case 'path':
          aValue = a.derivationPath;
          bValue = b.derivationPath;
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
        case 'splittable':
          aValue = splittableRank(a);
          bValue = splittableRank(b);
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

  // Unknown sorts below no, no below yes.
  int splittableRank(UnspentOutput utxo) {
    if (!utxo.hasSplittable()) {
      return 0;
    }
    return utxo.splittable ? 2 : 1;
  }

  int getDenialHops(UnspentOutput utxo) {
    if (!utxo.hasDenialInfo()) {
      return 0;
    }
    return utxo.denialInfo.hopsCompleted;
  }

  String getDenialStatus(UnspentOutput utxo) {
    if (!utxo.hasDenialInfo()) {
      return '-';
    }

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
    final result = await showThemedDialog<String>(
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
              return isDenied(utxo) ? theme.colors.success.withValues(alpha: 0.1) : null;
            },
            getRowId: (index) => sortedEntries[index].output,
            headerBuilder: (context) => [
              SailTableHeaderCell(name: '', onSort: () => onSort('frozen')),
              SailTableHeaderCell(
                name: 'Date',
                onSort: () => onSort('date'),
                filterWidget: DateFilter(onPickedRange: (dateRange) => widget.model.addFilter(dateRange)),
              ),
              SailTableHeaderCell(name: 'Output', onSort: () => onSort('output')),
              SailTableHeaderCell(name: 'Address', onSort: () => onSort('address')),
              SailTableHeaderCell(name: 'Path', onSort: () => onSort('path')),
              SailTableHeaderCell(name: 'Label', onSort: () => onSort('label')),
              SailTableHeaderCell(name: 'Deniability', onSort: () => onSort('deniability')),
              SailTableHeaderCell(name: 'Splittable', onSort: () => onSort('splittable')),
              SailTableHeaderCell(name: 'Amount', onSort: () => onSort('value')),
            ],
            rowBuilder: (context, row, selected) {
              final utxo = sortedEntries[row];
              final formattedAmount = formatter.formatSats(utxo.valueSats.toInt());
              final isFrozen = _coinSelection.isFrozen(utxo.output);

              return [
                SailTableCell(
                  width: 14,
                  value: '',
                  child: isFrozen
                      ? SailSVG.icon(
                          SailSVGAsset.snowflake,
                          width: 14,
                          color: theme.colors.info,
                        )
                      : const SizedBox(width: 14),
                ),
                SailTableCell(
                  value: utxo.hasReceivedAt() ? formatDate(utxo.receivedAt.toDateTime().toLocal()) : '—',
                ),
                SailTableCell(
                  value: '',
                  copyValue: utxo.output,
                  child: UTXO.toView(utxo),
                ),
                SailTableCell(
                  value: utxo.address,
                  copyValue: utxo.address,
                  monospace: true,
                ),
                SailTableCell(
                  value: utxo.derivationPath.isEmpty ? '—' : utxo.derivationPath,
                  copyValue: utxo.derivationPath,
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
                  value: !utxo.hasSplittable() ? '—' : (utxo.splittable ? 'Yes' : 'No'),
                  child: !utxo.hasSplittable()
                      ? SailText.secondary12('—')
                      : SailSVG.fromAsset(
                          SailSVGAsset.split,
                          width: 14,
                          color: utxo.splittable ? theme.colors.success : theme.colors.textSecondary,
                        ),
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
            sortColumnIndex: _columns.indexOf(sortColumn),
            sortAscending: sortAscending,
            onSort: (columnIndex, ascending) => onSort(_columns[columnIndex]),
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

/// Orchestrator migration status:
/// - UTXOs list: routed via TransactionProvider (already on orchestrator)
/// - setUTXOMetadata (freeze/label): STAYS on bitwindowd — BW-only coin control
/// - getUTXODistribution: STAYS on bitwindowd — BW-only chart aggregation
/// - Consolidation getNewAddress: MOVED to orchestrator
/// - Consolidation sendTransaction: MOVED to orchestrator shared wallet RPC
class LatestUTXOsViewModel extends BaseViewModel with ChangeTrackingMixin {
  final TransactionProvider _txProvider = GetIt.I<TransactionProvider>();
  final EnforcerRPC _enforcerRPC = GetIt.I<EnforcerRPC>();
  String sortColumn = 'date';
  bool sortAscending = true;
  ({DateTime end, DateTime start})? dateFilter;

  LatestUTXOsViewModel() {
    initChangeTracker();
    _txProvider.addListener(_onChange);
  }

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
    var utxos = _txProvider.utxos.where((utxo) {
      if (dateFilter != null) {
        final receivedAt = utxo.receivedAt.toDateTime();
        if (receivedAt.isBefore(dateFilter!.start) || receivedAt.isAfter(dateFilter!.end)) {
          return false;
        }
      }
      return true;
    }).toList();
    return utxos;
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

  void addFilter(({DateTime end, DateTime start})? range) {
    dateFilter = range;
    notifyListeners();
  }
}

/// Dialog for consolidating small UTXOs
