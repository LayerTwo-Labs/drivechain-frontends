import 'dart:math';

import 'package:bitwindow/widgets/tx_flow_diagram.dart';
import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

/// One coin or output in the transaction graph. [address] is empty for the
/// fee, and for change whose address the wallet picks at send time.
class GraphLine {
  final int sats;
  final String address;
  final FlowKind kind;

  const GraphLine({required this.sats, required this.address, required this.kind});
}

const double graphLabelRowHeight = 22;
const double _minPlotHeight = 220;

/// The top of each label row, so that each row sits at its band center
/// and no two rows overlap. Rows that do not fit move up from the bottom.
List<double> graphLabelTops(List<double> centers, double rowHeight, double height) {
  final tops = <double>[];
  for (final center in centers) {
    final wanted = max(center - rowHeight / 2, 0.0);
    tops.add(tops.isEmpty ? wanted : max(wanted, tops.last + rowHeight));
  }
  var limit = height - rowHeight;
  for (var i = tops.length - 1; i >= 0; i--) {
    tops[i] = max(min(tops[i], limit), 0.0);
    limit = tops[i] - rowHeight;
  }
  return tops;
}

String shortGraphAddress(String address) {
  if (address.length <= 14) {
    return address;
  }
  return '${address.substring(0, 9)}…${address.substring(address.length - 4)}';
}

/// The coins a send spends, its outputs and its fee, as a sankey with a
/// label at each band.
class TransactionGraphCard extends StatelessWidget {
  final List<GraphLine> spends;
  final List<GraphLine> creates;
  final String walletName;

  const TransactionGraphCard({
    super.key,
    required this.spends,
    required this.creates,
    required this.walletName,
  });

  @override
  Widget build(BuildContext context) {
    return SailCard(
      title: 'Transaction graph',
      child: spends.isEmpty || creates.isEmpty
          ? SailText.secondary13('Enter an address and an amount to see the graph.')
          : _GraphBody(spends: spends, creates: creates, walletName: walletName),
    );
  }
}

class _GraphBody extends StatelessWidget {
  final List<GraphLine> spends;
  final List<GraphLine> creates;
  final String walletName;

  const _GraphBody({required this.spends, required this.creates, required this.walletName});

  @override
  Widget build(BuildContext context) {
    final rows = max(spends.length, creates.length);
    final plotHeight = max(_minPlotHeight, rows * (graphLabelRowHeight + 6));
    final spendsTotal = spends.fold<int>(0, (sum, l) => sum + l.sats);
    final outputs = creates.where((l) => l.kind != FlowKind.fee).length;
    final hasFee = creates.any((l) => l.kind == FlowKind.fee);

    return SailColumn(
      spacing: SailStyleValues.padding12,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: SailText.secondary12(
                'SPENDS · ${spends.length} ${spends.length == 1 ? 'coin' : 'coins'} · ${_fmt(spendsTotal)}',
                bold: true,
              ),
            ),
            const Spacer(flex: 3),
            const SizedBox(width: SailStyleValues.padding16),
            Expanded(
              flex: 4,
              child: SailText.secondary12(
                'CREATES · $outputs ${outputs == 1 ? 'output' : 'outputs'}${hasFee ? ' + fee' : ''}',
                bold: true,
              ),
            ),
          ],
        ),
        SizedBox(
          height: plotHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: _LabelStack(
                  lines: spends,
                  height: plotHeight,
                  row: (l) => _SpendLabel(line: l),
                ),
              ),
              Expanded(
                flex: 3,
                child: TxFlowPlot(
                  inputs: [for (final l in spends) FlowSlot(sats: l.sats, kind: l.kind)],
                  outputs: [for (final l in creates) FlowSlot(sats: l.sats, kind: l.kind)],
                ),
              ),
              const SizedBox(width: SailStyleValues.padding16),
              Expanded(
                flex: 4,
                child: _LabelStack(
                  lines: creates,
                  height: plotHeight,
                  row: (l) => _CreateLabel(line: l, walletName: walletName),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// One label row at the center of each band of [lines].
class _LabelStack extends StatelessWidget {
  final List<GraphLine> lines;
  final double height;
  final Widget Function(GraphLine) row;

  const _LabelStack({required this.lines, required this.height, required this.row});

  @override
  Widget build(BuildContext context) {
    final bands = flowBandLayout([for (final l in lines) FlowSlot(sats: l.sats, kind: l.kind)], height);
    final tops = graphLabelTops([for (final b in bands) b.top + b.height / 2], graphLabelRowHeight, height);
    return Stack(
      children: [
        for (var i = 0; i < lines.length; i++)
          Positioned(
            top: tops[i],
            left: 0,
            right: 0,
            height: graphLabelRowHeight,
            child: Align(alignment: Alignment.centerLeft, child: row(lines[i])),
          ),
      ],
    );
  }
}

class _SpendLabel extends StatelessWidget {
  final GraphLine line;

  const _SpendLabel({required this.line});

  @override
  Widget build(BuildContext context) {
    return SailRow(
      spacing: SailStyleValues.padding12,
      children: [
        SailText.primary13(_fmt(line.sats), monospace: true),
        Flexible(child: SailText.secondary13(shortGraphAddress(line.address), monospace: true)),
      ],
    );
  }
}

class _CreateLabel extends StatelessWidget {
  final GraphLine line;
  final String walletName;

  const _CreateLabel({required this.line, required this.walletName});

  @override
  Widget build(BuildContext context) {
    final theme = context.sailTheme;
    if (line.kind == FlowKind.fee) {
      return SailRow(
        spacing: SailStyleValues.padding12,
        children: [
          SailText.secondary13(_fmt(line.sats), monospace: true),
          Flexible(child: SailText.secondary13('fee, paid to the miner', color: theme.colors.textTertiary)),
        ],
      );
    }
    final isChange = line.kind == FlowKind.change;
    final where = line.address.isEmpty ? 'back to $walletName' : shortGraphAddress(line.address);
    return SailRow(
      spacing: SailStyleValues.padding12,
      children: [
        SailText.primary13(_fmt(line.sats), monospace: true),
        Flexible(child: SailText.secondary13(where, monospace: true)),
        FlowChip(
          label: isChange ? 'change' : 'payment',
          color: isChange ? theme.colors.success : theme.colors.orange,
        ),
      ],
    );
  }
}

String _fmt(int sats) => formatBitcoin(satoshiToBTC(sats));
