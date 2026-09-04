import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/explorer/v1/explorer.pb.dart' as pb;
import 'package:stacked/stacked.dart';

/// WithdrawalsTab reads the bundle the chain proposes to the mainchain, and
/// the withdrawals inside it.
class WithdrawalsTab extends StatelessWidget {
  const WithdrawalsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<WithdrawalsModel>.reactive(
      viewModelBuilder: () => WithdrawalsModel(),
      builder: (context, model, child) {
        final state = model.state;
        if (state == null) {
          return SailCard(
            title: 'Withdrawals',
            subtitle: model.readError ?? 'Reading the bundle',
            child: const SizedBox(height: 40),
          );
        }
        return SingleChildScrollView(
          child: SailColumn(
            spacing: SailStyleValues.padding16,
            children: [
              _BundleSummary(state: state),
              _BundleTable(bundle: state.bundle),
            ],
          ),
        );
      },
    );
  }
}

class _BundleSummary extends StatelessWidget {
  final pb.GetWithdrawalsResponse state;

  const _BundleSummary({required this.state});

  @override
  Widget build(BuildContext context) {
    final bundle = state.bundle;
    final failed = state.lastFailedHeight == 0 ? '—' : 'Height ${state.lastFailedHeight}';
    if (!bundle.present) {
      return SailCard(
        title: 'The bundle now',
        subtitle: 'The chain proposes none',
        child: _Row(label: 'Last failed bundle', value: failed),
      );
    }
    return SailCard(
      title: 'The bundle now',
      subtitle: '${bundle.withdrawals.length} withdrawals, pending since height ${bundle.heightCreated}',
      child: SailRow(
        spacing: SailStyleValues.padding16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SailColumn(
              spacing: SailStyleValues.padding08,
              children: [
                _Row(label: 'Total amount', value: '${bundle.totalValueSats} sats'),
                _Row(label: 'Total mainchain fees', value: '${bundle.totalMainFeesSats} sats'),
              ],
            ),
          ),
          Expanded(
            child: SailColumn(
              spacing: SailStyleValues.padding08,
              children: [
                _Row(label: 'Bundle weight', value: '${bundle.totalWeight} / ${bundle.maxWeight}'),
                _Row(label: 'Last failed bundle', value: failed),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BundleTable extends StatelessWidget {
  final pb.WithdrawalBundle bundle;

  const _BundleTable({required this.bundle});

  @override
  Widget build(BuildContext context) {
    final rows = bundle.withdrawals;
    return SailCard(
      title: 'In this bundle',
      subtitle: '${rows.length} withdrawals · ${bundle.totalWeight} of ${bundle.maxWeight} weight',
      child: SizedBox(
        height: 320,
        child: SailTable(
          getRowId: (index) => '${rows[index].mainAddress}:$index',
          headerBuilder: (context) => const [
            SailTableHeaderCell(name: 'Amount (sats)'),
            SailTableHeaderCell(name: 'Mainchain fee (sats)'),
            SailTableHeaderCell(name: 'Destination address'),
            SailTableHeaderCell(name: 'Bundle weight'),
          ],
          rowBuilder: (context, index, selected) {
            final row = rows[index];
            return [
              SailTableCell(value: '${row.valueSats}'),
              SailTableCell(value: '${row.mainFeeSats}'),
              SailTableCell(value: row.mainAddress, monospace: true),
              SailTableCell(value: '${row.cumulativeWeight} / ${bundle.maxWeight}'),
            ];
          },
          rowCount: rows.length,
          contextMenuItems: (rowId) => [
            SailMenuItem(
              onSelected: () async {
                final address = rowId.substring(0, rowId.lastIndexOf(':'));
                await Clipboard.setData(ClipboardData(text: address));
              },
              child: SailText.primary12('Copy address'),
            ),
          ],
          emptyPlaceholder: 'No withdrawals in the bundle',
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = SailTheme.of(context).colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SailStyleValues.padding12,
        vertical: SailStyleValues.padding08,
      ),
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: SailRow(
        spacing: SailStyleValues.padding08,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SailText.secondary13(label),
          Flexible(child: SailText.primary13(value)),
        ],
      ),
    );
  }
}
