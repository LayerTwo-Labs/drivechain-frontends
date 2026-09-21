import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

/// True for a coin that carries an asset, and false for the sidechain currency.
bool carriesAsset(SidechainUTXO utxo) =>
    utxo.type == OutpointType.bitAsset ||
    utxo.type == OutpointType.bitAssetControl ||
    utxo.type == OutpointType.ammLpToken;

/// The asset column of one coin: the text to show and the value to copy.
({String text, String copy}) assetCell(SidechainUTXO utxo) {
  if (utxo is! BitAssetsUTXO) {
    return (text: '-', copy: '');
  }
  final asset = utxo.bitAsset;
  if (asset != null) {
    return (text: shortHash(asset.hash), copy: asset.hash);
  }
  final control = utxo.bitAssetControlHash;
  if (control != null) {
    return (text: shortHash(control), copy: control);
  }
  final pair = utxo.ammLpPair;
  if (pair != null) {
    return (
      text: 'LP ${shortHash(pair.asset0)}/${shortHash(pair.asset1)}',
      copy: '${pair.asset0}/${pair.asset1}',
    );
  }
  return (text: '-', copy: '');
}

/// The amount a coin carries. A coin of an asset counts in units of that
/// asset, and a control coin carries no amount.
String amountOf(SidechainUTXO utxo, FormatterProvider formatter) {
  if (utxo.type == OutpointType.bitAssetControl) {
    return '-';
  }
  if (carriesAsset(utxo)) {
    return utxo.valueSats.toString();
  }
  return formatter.formatSats(utxo.valueSats.toInt()).replaceAll(' ${formatter.currentUnit.symbol}', '');
}

String shortHash(String hash) => hash.length > 16 ? '${hash.substring(0, 8)}..' : hash;

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
        case 'asset':
          aValue = assetCell(a).copy;
          bValue = assetCell(b).copy;
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
    final formatter = GetIt.I<FormatterProvider>();

    return SailCard(
      title: 'Your UTXOs',
      bottomPadding: false,
      child: Column(
        children: [
          Expanded(
            child: SailSkeletonizer(
              description: 'Waiting for enforcer to start and wallet to sync..',
              enabled: widget.model.loading,
              child: ListenableBuilder(
                listenable: formatter,
                builder: (context, child) => SailTable(
                  shrinkWrap: true,
                  getRowId: (index) => widget.entries[index].outpoint.split(':').first,
                  headerBuilder: (context) => [
                    SailTableHeaderCell(name: 'Output', onSort: () => onSort('output')),
                    SailTableHeaderCell(name: 'Address', onSort: () => onSort('address')),
                    SailTableHeaderCell(name: 'Asset', onSort: () => onSort('asset')),
                    SailTableHeaderCell(name: 'Amount', onSort: () => onSort('value')),
                  ],
                  rowBuilder: (context, row, selected) {
                    final utxo = widget.entries[row];
                    final asset = assetCell(utxo);
                    return [
                      SailTableCell(
                        value: '${utxo.outpoint.substring(0, 6)}..:${utxo.outpoint.split(':').last}',
                        copyValue: utxo.outpoint,
                      ),
                      SailTableCell(value: utxo.address, monospace: true),
                      SailTableCell(value: asset.text, copyValue: asset.copy, monospace: true),
                      SailTableCell(value: amountOf(utxo, formatter), monospace: true),
                    ];
                  },
                  rowCount: widget.entries.length,
                  drawGrid: true,
                  sortColumnIndex: [
                    'output',
                    'address',
                    'asset',
                    'value',
                  ].indexOf(sortColumn),
                  sortAscending: sortAscending,
                  onSort: (columnIndex, ascending) {
                    onSort(['output', 'address', 'asset', 'value'][columnIndex]);
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
          outpoint: 'a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2:1',
          address: '5M2WxjMwSVGLxYEo2zfn6A774Oh',
          valueSats: 2500000000,
          type: OutpointType.regular,
        ),
        SidechainUTXO(
          outpoint: 'b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3:2',
          address: '6N3XykNxTWHMyZFp3agp7B885Pi',
          valueSats: 750000000,
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
