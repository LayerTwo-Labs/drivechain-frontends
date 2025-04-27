import 'package:bitwindow/pages/explorer/block_explorer_dialog.dart';
import 'package:bitwindow/pages/wallet/denial_dialog.dart';
import 'package:bitwindow/providers/denial_provider.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/gen/bitwindowd/v1/bitwindowd.pb.dart';
import 'package:sail_ui/rpcs/bitwindow_api.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class DeniabilityTab extends StatelessWidget {
  final NewWindowIdentifier? newWindowIdentifier;

  const DeniabilityTab({
    super.key,
    required this.newWindowIdentifier,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return ViewModelBuilder<DeniabilityViewModel>.reactive(
          viewModelBuilder: () => DeniabilityViewModel(),
          onViewModelReady: (model) => WidgetsBinding.instance.addPostFrameCallback((_) => model.postInit()),
          builder: (context, model, child) {
            final error = model.error('deniability');

            return DeniabilityTable(
              newWindowIdentifier: newWindowIdentifier,
              error: error,
              utxos: model.utxos,
              onDeny: (txid, vout) => model.showDenyDialog(context, txid, vout),
              onCancel: model.cancelDenial,
            );
          },
        );
      },
    );
  }
}

class DeniabilityTable extends StatefulWidget {
  final NewWindowIdentifier? newWindowIdentifier;
  final String? error;
  final List<DeniabilityUTXO> utxos;
  final void Function(String txid, int vout) onDeny;
  final void Function(Int64) onCancel;

  const DeniabilityTable({
    super.key,
    required this.error,
    required this.utxos,
    required this.onDeny,
    required this.onCancel,
    required this.newWindowIdentifier,
  });

  @override
  State<DeniabilityTable> createState() => _DeniabilityTableState();
}

class _DeniabilityTableState extends State<DeniabilityTable> {
  String sortColumn = 'txid';
  bool sortAscending = true;

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
    widget.utxos.sort((a, b) {
      dynamic aValue;
      dynamic bValue;

      switch (sortColumn) {
        case 'txid':
          // Sort by combined txid:vout string
          final aKey = '${a.txid}:${a.vout}';
          final bKey = '${b.txid}:${b.vout}';
          return sortAscending ? aKey.compareTo(bKey) : bKey.compareTo(aKey);
        case 'amount':
          return sortAscending ? a.valueSats.compareTo(b.valueSats) : b.valueSats.compareTo(a.valueSats);
        case 'hops':
          if (!a.hasDeniability() && !b.hasDeniability()) return 0;
          if (!a.hasDeniability()) return sortAscending ? 1 : -1;
          if (!b.hasDeniability()) return sortAscending ? -1 : 1;
          aValue = a.deniability.executions.length;
          bValue = b.deniability.executions.length;
          return sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
        case 'next':
          if (!a.hasDeniability() && !b.hasDeniability()) return 0;
          if (!a.hasDeniability()) return sortAscending ? 1 : -1;
          if (!b.hasDeniability()) return sortAscending ? -1 : 1;
          if (!a.deniability.hasNextExecution() && !b.deniability.hasNextExecution()) return 0;
          if (!a.deniability.hasNextExecution()) return sortAscending ? 1 : -1;
          if (!b.deniability.hasNextExecution()) return sortAscending ? -1 : 1;
          return sortAscending
              ? a.deniability.nextExecution.toDateTime().compareTo(b.deniability.nextExecution.toDateTime())
              : b.deniability.nextExecution.toDateTime().compareTo(a.deniability.nextExecution.toDateTime());
        case 'status':
          if (!a.hasDeniability() && !b.hasDeniability()) return 0;
          if (!a.hasDeniability()) return sortAscending ? 1 : -1;
          if (!b.hasDeniability()) return sortAscending ? -1 : 1;
          aValue = a.deniability.hasCancelTime()
              ? 'Cancelled'
              : (a.deniability.numHops - a.deniability.executions.length == 0 ? 'Completed' : 'Ongoing');
          bValue = b.deniability.hasCancelTime()
              ? 'Cancelled'
              : (b.deniability.numHops - b.deniability.executions.length == 0 ? 'Completed' : 'Ongoing');
          return sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
        default:
          return 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SailCard(
      title: 'UTXOs and Denials',
      subtitle: 'List of UTXOs with optional deniability info.',
      error: widget.error,
      bottomPadding: false,
      inSeparateWindow: widget.newWindowIdentifier != null,
      newWindowIdentifier: widget.newWindowIdentifier,
      child: Column(
        children: [
          SailSpacing(SailStyleValues.padding16),
          Expanded(
            child: SailTable(
              getRowId: (index) =>
                  widget.utxos.isEmpty ? '0' : '${widget.utxos[index].txid}:${widget.utxos[index].vout}',
              headerBuilder: (context) => [
                SailTableHeaderCell(
                  name: 'UTXO',
                  onSort: () => onSort('txid'),
                ),
                SailTableHeaderCell(
                  name: 'Amount',
                  onSort: () => onSort('amount'),
                ),
                SailTableHeaderCell(
                  name: 'Hops',
                  onSort: () => onSort('hops'),
                ),
                SailTableHeaderCell(
                  name: 'Next Execution',
                  onSort: () => onSort('next'),
                ),
                SailTableHeaderCell(
                  name: 'Status',
                  onSort: () => onSort('status'),
                ),
                const SailTableHeaderCell(name: 'Actions'),
              ],
              cellHeight: 36.0,
              rowBuilder: (context, row, selected) {
                // If there are no UTXOs, return a single row with an empty cell message
                if (widget.utxos.isEmpty) {
                  return [
                    const SailTableCell(value: 'No UTXOs available'),
                    const SailTableCell(value: ''),
                    const SailTableCell(value: ''),
                    const SailTableCell(value: ''),
                    const SailTableCell(value: ''),
                    const SailTableCell(value: ''),
                  ];
                }

                final utxo = widget.utxos[row];
                final hasDeniability = utxo.hasDeniability();

                String status = '-';
                String nextExecution = '-';
                String hops = '0';
                bool canCancel = false;

                if (hasDeniability) {
                  final completedHops = utxo.deniability.executions.length;
                  final totalHops = utxo.deniability.numHops;
                  hops = '$completedHops/$totalHops';
                  if (completedHops == totalHops) {
                    hops = '$completedHops';
                  }

                  status = utxo.deniability.hasCancelTime()
                      ? 'Cancelled'
                      : completedHops == totalHops
                          ? 'Completed'
                          : 'Ongoing';
                  nextExecution = utxo.deniability.hasNextExecution()
                      ? utxo.deniability.nextExecution.toDateTime().toLocal().toString()
                      : '-';
                  canCancel = status == 'Ongoing';

                  if (status == 'Cancelled') {
                    hops = '$completedHops';
                  }
                }

                return [
                  SailTableCell(
                    value: '${utxo.txid}:${utxo.vout}',
                    monospace: true,
                  ),
                  SailTableCell(
                    value: formatBitcoin(satoshiToBTC(utxo.valueSats.toInt())),
                    monospace: true,
                  ),
                  SailTableCell(
                    value: hops,
                    monospace: true,
                  ),
                  SailTableCell(
                    value: nextExecution,
                    monospace: true,
                  ),
                  Tooltip(
                    message: utxo.deniability.cancelReason,
                    child: SailTableCell(
                      value: status,
                      monospace: true,
                    ),
                  ),
                  SailTableCell(
                    value: canCancel ? 'Cancel' : '-',
                    monospace: true,
                    child: canCancel
                        ? SailButton(
                            label: 'Cancel',
                            onPressed: () async => widget.onCancel(utxo.deniability.id),
                          )
                        : SailButton(
                            label: 'Deny',
                            onPressed: () async => widget.onDeny(utxo.txid, utxo.vout),
                          ),
                  ),
                ];
              },
              rowCount: widget.utxos.isEmpty ? 1 : widget.utxos.length, // Show one row when empty
              columnWidths: const [-1, -1, -1, -1, -1, -1],
              drawGrid: true,
              sortColumnIndex: [
                'txid',
                'vout',
                'amount',
                'next',
                'status',
                'actions',
              ].indexOf(sortColumn),
              sortAscending: sortAscending,
              onSort: (columnIndex, ascending) {
                onSort(['txid', 'vout', 'amount', 'next', 'status', 'actions'][columnIndex]);
              },
              onDoubleTap: (rowId) {
                if (widget.utxos.isEmpty) return;
                final utxo = widget.utxos.firstWhere(
                  (u) => '${u.txid}:${u.vout}' == rowId,
                );
                _showUtxoDetails(context, utxo);
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showUtxoDetails(BuildContext context, DeniabilityUTXO utxo) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SailCard(
            title: 'UTXO Details',
            subtitle: 'UTXO and Deniability Information',
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DetailRow(label: 'TxID', value: utxo.txid),
                  DetailRow(label: 'Output Index', value: utxo.vout.toString()),
                  DetailRow(label: 'Amount', value: formatBitcoin(satoshiToBTC(utxo.valueSats.toInt()))),
                  if (utxo.hasDeniability()) ...[
                    const SailSpacing(SailStyleValues.padding16),
                    BorderedSection(
                      title: 'Deniability Info',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DetailRow(label: 'Status', value: _getDeniabilityStatus(utxo)),
                          DetailRow(label: 'Completed Hops', value: '${utxo.deniability.executions.length}'),
                          DetailRow(label: 'Total Hops', value: '${utxo.deniability.numHops}'),
                          if (utxo.deniability.hasNextExecution())
                            DetailRow(
                              label: 'Next Execution',
                              value: utxo.deniability.nextExecution.toDateTime().toLocal().toString(),
                            ),
                          if (utxo.deniability.hasCancelTime())
                            DetailRow(
                              label: 'Cancel Reason',
                              value: utxo.deniability.cancelReason,
                            ),
                        ],
                      ),
                    ),
                    if (utxo.deniability.executions.isNotEmpty) ...[
                      const SailSpacing(SailStyleValues.padding16),
                      SailText.primary13('Deniability Transactions:'),
                      const SailSpacing(SailStyleValues.padding08),
                      SizedBox(
                        height: 300,
                        child: SelectionContainer.disabled(
                          child: TXIDTransactionTable(
                            transactions: utxo.deniability.executions
                                .map((e) => e.fromTxid)
                                .where((txid) => txid.isNotEmpty)
                                .toList(),
                            onTransactionSelected: (txid) => _showTransactionDetails(context, txid),
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showTransactionDetails(BuildContext context, String txid) {
    showDialog(
      context: context,
      builder: (context) => TransactionDetailsDialog(
        txid: txid,
      ),
    );
  }

  String _getDeniabilityStatus(DeniabilityUTXO utxo) {
    if (!utxo.hasDeniability()) return 'No deniability';
    if (utxo.deniability.hasCancelTime()) return 'Cancelled';

    final completedHops = utxo.deniability.executions.length;
    final totalHops = utxo.deniability.numHops;

    if (completedHops == totalHops) return 'Completed';
    return 'Ongoing ($completedHops/$totalHops hops)';
  }
}

class DeniabilityViewModel extends BaseViewModel {
  final BitwindowRPC api = GetIt.I.get<BitwindowRPC>();
  final DenialProvider denialProvider = GetIt.I.get<DenialProvider>();

  List<DeniabilityUTXO> get utxos => denialProvider.utxos;

  DeniabilityViewModel() {
    denialProvider.addListener(notifyListeners);
    denialProvider.addListener(errorListener);
  }

  void init() {
    // Set busy state to show loading indicator
    setBusy(true);
    notifyListeners();
  }

  // Post-frame initialization for async operations
  Future<void> postInit() async {
    try {
      // Fetch data
      await denialProvider.fetch();
    } catch (e) {
      setErrorForObject('deniability', e.toString());
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  void errorListener() {
    setErrorForObject('deniability', denialProvider.error);
  }

  void showDenyDialog(BuildContext context, String txid, int vout) {
    denialProvider.fetch();

    showDialog(
      context: context,
      builder: (context) => DenialDialog(
        onSubmit: (hops, delaySeconds) async {
          await api.bitwindowd.createDenial(
            txid: txid,
            vout: vout,
            numHops: hops,
            delaySeconds: delaySeconds,
          );
          await denialProvider.fetch();
        },
      ),
    );
  }

  void cancelDenial(Int64 id) async {
    try {
      await api.bitwindowd.cancelDenial(id);
      await denialProvider.fetch();
    } catch (e) {
      setError(e.toString());
    }
  }
}
