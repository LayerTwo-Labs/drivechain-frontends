import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class WithdrawalsPage extends StatelessWidget {
  const WithdrawalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return QtPage(
      child: ViewModelBuilder<WithdrawalsViewModel>.reactive(
        viewModelBuilder: () => WithdrawalsViewModel(),
        builder: (context, model, child) {
          final theme = SailTheme.of(context);
          final formatter = GetIt.I<FormatterProvider>();

          return SailColumn(
            spacing: SailStyleValues.padding16,
            children: [
              // Status header
              Container(
                padding: const EdgeInsets.all(SailStyleValues.padding12),
                decoration: BoxDecoration(
                  color: model.bundle != null
                      ? theme.colors.success.withValues(alpha: 0.1)
                      : theme.colors.orange.withValues(alpha: 0.1),
                  borderRadius: SailStyleValues.borderRadiusSmall,
                  border: Border.all(
                    color: model.bundle != null
                        ? theme.colors.success.withValues(alpha: 0.3)
                        : theme.colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      model.bundle != null ? Icons.pending_actions : Icons.hourglass_empty,
                      size: 20,
                      color: model.bundle != null ? theme.colors.success : theme.colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SailText.primary13(
                            model.bundle != null
                                ? 'Pending Withdrawals: ${model.bundle!.spendUtxos.length} UTXOs'
                                : 'No pending withdrawal bundle',
                            bold: true,
                          ),
                          if (model.lastFailedHeight != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.error_outline, size: 16, color: theme.colors.error),
                                const SizedBox(width: 4),
                                SailText.primary12(
                                  'Last failed bundle at height: ${model.lastFailedHeight}',
                                  color: theme.colors.error,
                                ),
                              ],
                            ),
                          ],
                        ],
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

              // Bundle details
              if (model.bundle != null) ...[
                SailCard(
                  title: 'Bundle Summary',
                  child: SailRow(
                    spacing: SailStyleValues.padding32,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SailText.secondary13('Height Created'),
                          SailText.primary15(model.bundle!.heightCreated.toString(), bold: true),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SailText.secondary13('Total Value'),
                          ListenableBuilder(
                            listenable: formatter,
                            builder: (context, child) => SailText.primary15(
                              formatter.formatSats(model.bundle!.totalValue),
                              bold: true,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SailText.secondary13('UTXOs'),
                          SailText.primary15(model.bundle!.spendUtxos.length.toString(), bold: true),
                        ],
                      ),
                    ],
                  ),
                ),

                // UTXO table
                Expanded(
                  child: SailCard(
                    title: 'Spent UTXOs',
                    bottomPadding: false,
                    child: ListenableBuilder(
                      listenable: formatter,
                      builder: (context, child) => SailTable(
                        getRowId: (index) => _formatOutPoint(model.bundle!.spendUtxos[index].outPoint),
                        headerBuilder: (context) => [
                          SailTableHeaderCell(name: 'Outpoint'),
                          SailTableHeaderCell(name: 'Value'),
                        ],
                        rowBuilder: (context, row, selected) {
                          final utxo = model.bundle!.spendUtxos[row];
                          final outpointStr = _formatOutPoint(utxo.outPoint);
                          final value = utxo.output.content.type == OutputContentType.value
                              ? formatter.formatSats(utxo.output.content.value!)
                              : '-';
                          return [
                            SailTableCell(
                              value: _truncateOutpoint(outpointStr),
                              copyValue: outpointStr,
                              monospace: true,
                            ),
                            SailTableCell(value: value, monospace: true),
                          ];
                        },
                        rowCount: model.bundle!.spendUtxos.length,
                        drawGrid: true,
                        emptyPlaceholder: 'No UTXOs in bundle',
                      ),
                    ),
                  ),
                ),
              ] else
                Expanded(
                  child: Center(
                    child: SailText.secondary15('No pending bundle'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  String _formatOutPoint(PWBOutPoint outPoint) {
    switch (outPoint.type) {
      case OutPointType.regular:
        final regular = outPoint.regular!;
        return '${regular.txid}:${regular.vout}';
      case OutPointType.coinbase:
        final coinbase = outPoint.coinbase!;
        return 'coinbase:${coinbase.merkleRoot}:${coinbase.vout}';
      case OutPointType.deposit:
        final deposit = outPoint.deposit!;
        return 'deposit:${deposit.txid}:${deposit.vout}';
    }
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
}

class WithdrawalsViewModel extends BaseViewModel {
  PhotonRPC get _rpc => GetIt.I.get<PhotonRPC>();

  PendingWithdrawalBundle? bundle;
  int? lastFailedHeight;
  bool isRefreshing = false;
  Timer? _refreshTimer;

  WithdrawalsViewModel() {
    _fetchData();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchData());
  }

  Future<void> _fetchData() async {
    try {
      final bundleFuture = _rpc.getPendingWithdrawalBundle();
      final failedHeightFuture = _rpc.getLatestFailedWithdrawalBundleHeight();

      final results = await Future.wait([bundleFuture, failedHeightFuture]);

      final newBundle = results[0] as PendingWithdrawalBundle?;
      final newFailedHeight = results[1] as int?;

      if (bundle?.toJson() != newBundle?.toJson() || lastFailedHeight != newFailedHeight) {
        bundle = newBundle;
        lastFailedHeight = newFailedHeight;
        notifyListeners();
      }
    } catch (e) {
      // Ignore errors during refresh
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
