import 'package:bitwindow/change_tracking_mixin.dart';
import 'package:bitwindow/pages/explorer/block_explorer_dialog.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/gen/wallet/v1/wallet.pb.dart';
import 'package:sail_ui/rpcs/enforcer_rpc.dart';
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

  @override
  void initState() {
    super.initState();
    sortEntries();
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
    widget.entries.sort((a, b) {
      dynamic aValue, bValue;
      switch (sortColumn) {
        case 'date':
          aValue = a.receivedAt.toDateTime();
          bValue = b.receivedAt.toDateTime();
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
          aValue = a.label;
          bValue = b.label;
          break;
        case 'value':
          aValue = a.value;
          bValue = b.value;
          break;
      }
      return sortAscending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SailCard(
      title: 'Your UTXOs',
      bottomPadding: false,
      child: Column(
        children: [
          Expanded(
            child: SailSkeletonizer(
              description: 'Waiting for enforcer to start and wallet to sync..',
              enabled: widget.model.loading,
              child: SailTable(
                getRowId: (index) => widget.entries[index].output.split(':').first,
                headerBuilder: (context) => [
                  SailTableHeaderCell(name: 'Date', onSort: () => onSort('date')),
                  SailTableHeaderCell(name: 'Output', onSort: () => onSort('output')),
                  SailTableHeaderCell(name: 'Address', onSort: () => onSort('address')),
                  SailTableHeaderCell(name: 'Label', onSort: () => onSort('label')),
                  SailTableHeaderCell(name: 'Amount', onSort: () => onSort('value')),
                ],
                rowBuilder: (context, row, selected) {
                  final utxo = widget.entries[row];
                  final formattedAmount = formatBitcoin(
                    satoshiToBTC(utxo.value.toInt()),
                    symbol: '',
                  );
                  return [
                    SailTableCell(
                      value: formatDate(utxo.receivedAt.toDateTime().toLocal()),
                    ),
                    SailTableCell(
                      value: '${utxo.output.substring(0, 6)}..:${utxo.output.split(':').last}',
                      copyValue: utxo.output,
                    ),
                    SailTableCell(value: utxo.address, monospace: true),
                    SailTableCell(value: utxo.label, monospace: true),
                    SailTableCell(value: formattedAmount, monospace: true),
                  ];
                },
                rowCount: widget.entries.length,
                columnWidths: const [120, 120, 320, 120, 120],
                drawGrid: true,
                sortColumnIndex: [
                  'date',
                  'output',
                  'address',
                  'label',
                  'value',
                ].indexOf(sortColumn),
                sortAscending: sortAscending,
                onSort: (columnIndex, ascending) {
                  onSort(['date', 'output', 'address', 'label', 'value'][columnIndex]);
                },
                onDoubleTap: (rowId) => showTransactionDetails(context, rowId),
                contextMenuItems: (rowId) {
                  return [
                    SailMenuItem(
                      onSelected: () async {
                        await showTransactionDetails(context, rowId);
                      },
                      child: SailText.primary12('Show Details'),
                    ),
                    MempoolMenuItem(txid: rowId),
                  ];
                },
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
          output: 'dummy_output',
          address: 'dummy_address',
          label: 'dummy_label',
        ),
        UnspentOutput(
          output: 'dummy_output',
          address: 'dummy_address',
          label: 'dummy_label',
        ),
        UnspentOutput(
          output: 'dummy_output',
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
    track('entries', entries);
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
