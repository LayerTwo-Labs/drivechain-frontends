import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class MempoolExplorerPage extends StatelessWidget {
  const MempoolExplorerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return QtPage(
      child: ViewModelBuilder<MempoolExplorerViewModel>.reactive(
        viewModelBuilder: () => MempoolExplorerViewModel(),
        builder: (context, model, child) {
          final theme = SailTheme.of(context);
          final formatter = GetIt.I<FormatterProvider>();

          return SailColumn(
            spacing: SailStyleValues.padding16,
            children: [
              // Info banner about limitations
              Container(
                padding: const EdgeInsets.all(SailStyleValues.padding12),
                decoration: BoxDecoration(
                  color: theme.colors.info.withValues(alpha: 0.1),
                  borderRadius: SailStyleValues.borderRadiusSmall,
                  border: Border.all(color: theme.colors.info.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: theme.colors.info),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SailText.primary13(
                        'Showing all UTXOs on the sidechain. Full mempool transaction list requires additional RPC support.',
                        color: theme.colors.info,
                      ),
                    ),
                    SailButton(
                      label: 'Refresh',
                      variant: ButtonVariant.secondary,
                      small: true,
                      onPressed: model.refresh,
                      loading: model.isRefreshing,
                    ),
                  ],
                ),
              ),

              // Stats row
              SailRow(
                spacing: SailStyleValues.padding16,
                children: [
                  _StatCard(
                    label: 'Total UTXOs',
                    value: model.utxos.length.toString(),
                    loading: model.isLoading,
                  ),
                  _StatCard(
                    label: 'Total Value',
                    value: formatter.formatSats(model.totalValue),
                    loading: model.isLoading,
                  ),
                ],
              ),

              // UTXO list
              Expanded(
                child: SailCard(
                  title: 'All UTXOs',
                  bottomPadding: false,
                  child: model.error != null
                      ? Center(child: SailText.primary13(model.error!, color: theme.colors.error))
                      : ListenableBuilder(
                          listenable: formatter,
                          builder: (context, child) => SailTable(
                            getRowId: (index) => model.utxos[index].outpoint,
                            headerBuilder: (context) => [
                              SailTableHeaderCell(name: 'Type'),
                              SailTableHeaderCell(name: 'Outpoint'),
                              SailTableHeaderCell(name: 'Address'),
                              SailTableHeaderCell(name: 'Value'),
                            ],
                            rowBuilder: (context, row, selected) {
                              final utxo = model.utxos[row];
                              return [
                                SailTableCell(value: utxo.type.name, monospace: true),
                                SailTableCell(
                                  value: _truncateOutpoint(utxo.outpoint),
                                  copyValue: utxo.outpoint,
                                  monospace: true,
                                ),
                                SailTableCell(
                                  value: _truncateAddress(utxo.address),
                                  copyValue: utxo.address,
                                  monospace: true,
                                ),
                                SailTableCell(
                                  value: formatter.formatSats(utxo.valueSats.toInt()),
                                  monospace: true,
                                ),
                              ];
                            },
                            rowCount: model.utxos.length,
                            drawGrid: true,
                            emptyPlaceholder: model.isLoading ? 'Loading UTXOs...' : 'No UTXOs found',
                          ),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _truncateOutpoint(String outpoint) {
    if (outpoint.length <= 16) return outpoint;
    final parts = outpoint.split(':');
    if (parts.length == 2) {
      final hash = parts[0];
      final index = parts[1];
      if (hash.length > 8) {
        return '${hash.substring(0, 8)}...:$index';
      }
    }
    return outpoint;
  }

  String _truncateAddress(String address) {
    if (address.length <= 16) return address;
    return '${address.substring(0, 8)}...${address.substring(address.length - 4)}';
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final bool loading;

  const _StatCard({
    required this.label,
    required this.value,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SailCard(
      child: SailColumn(
        spacing: SailStyleValues.padding04,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailText.secondary13(label),
          SailSkeletonizer(
            enabled: loading,
            description: 'Loading...',
            child: SailText.primary20(value, bold: true),
          ),
        ],
      ),
    );
  }
}

class MempoolExplorerViewModel extends BaseViewModel {
  PhotonRPC get _rpc => GetIt.I.get<PhotonRPC>();

  List<SidechainUTXO> utxos = [];
  String? error;
  bool isLoading = true;
  bool isRefreshing = false;
  Timer? _refreshTimer;

  int get totalValue => utxos.fold(0, (sum, utxo) => sum + utxo.valueSats.toInt());

  MempoolExplorerViewModel() {
    _fetchData();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) => _fetchData());
  }

  Future<void> _fetchData() async {
    try {
      error = null;
      final newUtxos = await _rpc.listAllUTXOs();
      utxos = newUtxos;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    isRefreshing = true;
    notifyListeners();

    try {
      await _fetchData();
    } finally {
      isRefreshing = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
