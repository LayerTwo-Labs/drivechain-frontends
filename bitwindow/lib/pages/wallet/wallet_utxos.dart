import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
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
            );
          },
        );
      },
    );
  }
}

class UTXOTable extends StatefulWidget {
  final List<UnspentOutput> entries;

  const UTXOTable({super.key, required this.entries});

  @override
  State<UTXOTable> createState() => _UTXOTableState();
}

class _UTXOTableState extends State<UTXOTable> {
  String sortColumn = 'date';
  bool sortAscending = true;
  late List<UnspentOutput> entries;

  @override
  void initState() {
    super.initState();
    entries = List.from(widget.entries);
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
    entries.sort((a, b) {
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
            child: SailTable(
              getRowId: (index) => entries[index].output,
              headerBuilder: (context) => [
                SailTableHeaderCell(name: 'Date', onSort: () => onSort('date')),
                SailTableHeaderCell(name: 'Output', onSort: () => onSort('output')),
                SailTableHeaderCell(name: 'Address', onSort: () => onSort('address')),
                SailTableHeaderCell(name: 'Label', onSort: () => onSort('label')),
                SailTableHeaderCell(name: 'Amount', onSort: () => onSort('value')),
              ],
              rowBuilder: (context, row, selected) {
                final utxo = entries[row];
                final formattedDate = DateFormat('yyyy MMM dd HH:mm').format(utxo.receivedAt.toDateTime().toLocal());
                final formattedAmount = formatBitcoin(
                  satoshiToBTC(utxo.value.toInt()),
                  symbol: '',
                );
                return [
                  SailTableCell(
                    value: formattedDate,
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
              rowCount: entries.length,
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
            ),
          ),
        ],
      ),
    );
  }
}

class LatestUTXOsViewModel extends BaseViewModel {
  final TransactionProvider _txProvider = GetIt.I<TransactionProvider>();
  List<UnspentOutput> get entries => _txProvider.utxos.toList();

  String sortColumn = 'date';
  bool sortAscending = true;

  LatestUTXOsViewModel() {
    _txProvider.addListener(notifyListeners);
  }

  @override
  void dispose() {
    _txProvider.removeListener(notifyListeners);
    super.dispose();
  }
}
