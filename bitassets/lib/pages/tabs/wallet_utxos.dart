import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
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
  final List<SidechainUTXO> entries;
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
  String sortColumn = 'output';
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
        case 'output':
          aValue = a.outpoint;
          bValue = b.outpoint;
          break;
        case 'address':
          aValue = a.address;
          bValue = b.address;
          break;
        case 'value':
          aValue = a.valueSats;
          bValue = b.valueSats;
          break;
        default:
          aValue = a.valueSats;
          bValue = b.valueSats;
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
                shrinkWrap: true,
                getRowId: (index) => widget.entries[index].outpoint.split(':').first,
                headerBuilder: (context) => [
                  SailTableHeaderCell(name: 'Output', onSort: () => onSort('output')),
                  SailTableHeaderCell(name: 'Address', onSort: () => onSort('address')),
                  SailTableHeaderCell(name: 'Amount', onSort: () => onSort('value')),
                ],
                rowBuilder: (context, row, selected) {
                  final utxo = widget.entries[row];
                  final formattedAmount = formatBitcoin(
                    satoshiToBTC(utxo.valueSats),
                    symbol: '',
                  );
                  return [
                    SailTableCell(
                      value: '${utxo.outpoint.substring(0, 6)}..:${utxo.outpoint.split(':').last}',
                      copyValue: utxo.outpoint,
                    ),
                    SailTableCell(value: utxo.address, monospace: true),
                    SailTableCell(value: formattedAmount, monospace: true),
                  ];
                },
                rowCount: widget.entries.length,
                drawGrid: true,
                sortColumnIndex: [
                  'output',
                  'address',
                  'value',
                ].indexOf(sortColumn),
                sortAscending: sortAscending,
                onSort: (columnIndex, ascending) {
                  onSort(['output', 'address', 'value'][columnIndex]);
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
  final SidechainTransactionsProvider _txProvider = GetIt.I<SidechainTransactionsProvider>();
  final EnforcerRPC _enforcerRPC = GetIt.I<EnforcerRPC>();

  List<SidechainUTXO> get entries {
    if (loading) {
      return [
        SidechainUTXO(
          outpoint: 'ef96ff0ab79d3666b7ea55d832bfa36947f0839cdf1708e4f4087cb89d6e0716:0',
          address: '4L1ZvhVLvRUFJkXEn1yen5Z663Nf',
          valueSats: 1500000000,
          type: OutpointType.regular,
        ),
        SidechainUTXO(
          outpoint: 'ef96ff0ab79d3666b7ea55d832bfa36947f0839cdf1708e4f4087cb89d6e0716:0',
          address: '4L1ZvhVLvRUFJkXEn1yen5Z663Nf',
          valueSats: 1500000000,
          type: OutpointType.regular,
        ),
        SidechainUTXO(
          outpoint: 'ef96ff0ab79d3666b7ea55d832bfa36947f0839cdf1708e4f4087cb89d6e0716:0',
          address: '4L1ZvhVLvRUFJkXEn1yen5Z663Nf',
          valueSats: 1500000000,
          type: OutpointType.regular,
        ),
      ];
    }

    return _txProvider.utxos.toList();
  }

  String sortColumn = 'output';
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
