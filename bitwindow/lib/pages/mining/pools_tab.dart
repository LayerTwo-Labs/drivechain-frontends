import 'package:bitwindow/pages/mining/mining_page.dart';
import 'package:bitwindow/providers/mining_pools_provider.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/stratum/v1/stratum.pb.dart';
import 'package:stacked/stacked.dart';

const _windows = [
  MiningPoolWindow.MINING_POOL_WINDOW_24H,
  MiningPoolWindow.MINING_POOL_WINDOW_3D,
  MiningPoolWindow.MINING_POOL_WINDOW_1W,
];

/// The pools on the network and the share of recent blocks each one mined.
class PoolsTab extends StatelessWidget {
  const PoolsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PoolsViewModel>.reactive(
      viewModelBuilder: () => PoolsViewModel(),
      builder: (context, model, child) {
        final provider = model.provider;
        return SailCard(
          title: 'Pools on the network',
          subtitle: model.subtitle,
          error: model.actionError ?? provider.error,
          bottomPadding: false,
          widgetHeaderEnd: model.isLight
              ? null
              : SailToggleGroup<MiningPoolWindow>(
                  items: [
                    for (final window in _windows)
                      SailToggleGroupItem(value: window, label: miningPoolWindowLabel(window)),
                  ],
                  values: [provider.window],
                  singleChoice: true,
                  onChanged: (values) => provider.setWindow(values.first),
                ),
          child: model.isLight
              ? SailText.secondary13('Pools needs a full node.')
              : SailColumn(
                  spacing: SailStyleValues.padding16,
                  children: [
                    if (!provider.registryAvailable)
                      SailText.secondary13(
                        'This network publishes no pool registry, so every block shows as Unknown.',
                      ),
                    if (provider.blockCount > 0) _ShareChart(provider: provider),
                    Expanded(child: _PoolsTable(model: model)),
                  ],
                ),
        );
      },
    );
  }
}

class _ShareChart extends StatelessWidget {
  final MiningPoolsProvider provider;

  const _ShareChart({required this.provider});

  @override
  Widget build(BuildContext context) {
    final colors = SailTheme.of(context).colors.chartPalette;
    final mined = provider.pools.where((share) => share.blockCount > 0).toList();

    return SizedBox(
      height: 160,
      child: SailRow(
        spacing: SailStyleValues.padding32,
        children: [
          SizedBox(
            width: 160,
            child: PieChart(
              PieChartData(
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 36,
                sections: [
                  for (var i = 0; i < mined.length; i++)
                    PieChartSectionData(
                      color: colors[i % colors.length],
                      value: mined[i].blockCount.toDouble(),
                      title: '',
                      radius: 44,
                    ),
                ],
              ),
            ),
          ),
          SailColumn(
            spacing: SailStyleValues.padding10,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < mined.length; i++)
                SailRow(
                  spacing: SailStyleValues.padding10,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(color: colors[i % colors.length], shape: BoxShape.circle),
                    ),
                    SizedBox(width: 140, child: SailText.primary13(mined[i].pool.name, bold: true)),
                    SizedBox(
                      width: 56,
                      child: SailText.primary13(formatShare(mined[i].share), textAlign: TextAlign.right),
                    ),
                    SizedBox(
                      width: 90,
                      child: SailText.secondary13(_blocks(mined[i].blockCount), textAlign: TextAlign.right),
                    ),
                  ],
                ),
            ],
          ),
          SailColumn(
            spacing: SailStyleValues.padding04,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.secondary13('Network hashrate'),
              SailText.primary24(formatHashrate(provider.networkHashrate), bold: true),
              SailText.secondary12('${_blocks(provider.blockCount)} · ${provider.fromHeight} to ${provider.toHeight}'),
            ],
          ),
        ],
      ),
    );
  }
}

String _blocks(int count) => '$count ${count == 1 ? 'block' : 'blocks'}';

const _actionWidth = 160.0;

const _columnNames = ['Pool', 'Share', 'Blocks', 'Empty blocks', 'Est. hashrate', 'Fee', 'Mode'];

class _PoolsTable extends StatelessWidget {
  final PoolsViewModel model;

  const _PoolsTable({required this.model});

  @override
  Widget build(BuildContext context) {
    final pools = model.provider.pools;
    final mines = model.mines;
    return SailTable(
      getRowId: (index) => pools[index].pool.slug,
      headerBuilder: (context) => [
        for (final name in _columnNames) SailTableHeaderCell(name: name),
        if (mines) const SailTableHeaderCell(name: ''),
        const SailTableHeaderCell(name: 'Stratum'),
      ],
      cellHeight: 40.0,
      rowBuilder: (context, row, selected) {
        final share = pools[row];
        final pool = share.pool;
        return [
          SailTableCell(value: pool.name),
          SailTableCell(value: formatShare(share.share), monospace: true),
          SailTableCell(value: share.blockCount.toString(), monospace: true),
          SailTableCell(value: share.emptyBlocks.toString(), monospace: true),
          SailTableCell(value: formatHashrate(share.estimatedHashrate), monospace: true),
          SailTableCell(value: pool.mode.isEmpty ? '—' : formatPoolFee(pool.feeBps), monospace: true),
          SailTableCell(value: pool.mode.isEmpty ? '—' : pool.mode),
          if (mines) _actionCell(pool),
          SailTableCell(
            value: pool.stratumUrl.isEmpty ? '—' : pool.stratumUrl,
            copyValue: pool.stratumUrl.isEmpty ? null : pool.stratumUrl,
            monospace: true,
          ),
        ];
      },
      rowCount: pools.length,
      emptyPlaceholder: 'No blocks recorded in this window',
      drawGrid: true,
    );
  }

  SailTableCell _actionCell(MiningPool pool) {
    if (pool.stratumUrl.isEmpty) {
      return const SailTableCell(value: '', width: _actionWidth);
    }
    if (model.isTarget(pool)) {
      final label = model.stratum.running ? 'Mining here' : 'Selected';
      return SailTableCell(
        value: label,
        alignment: Alignment.centerRight,
        width: _actionWidth,
        child: SailBadge(label, tone: model.stratum.running ? SailBadgeTone.success : SailBadgeTone.neutral),
      );
    }
    return SailTableCell(
      value: 'Mine here',
      alignment: Alignment.centerRight,
      width: _actionWidth,
      child: SailButton(
        label: 'Mine here',
        variant: ButtonVariant.outline,
        onPressed: () async => model.mineHere(pool),
      ),
    );
  }
}

String formatShare(double share) => '${(share * 100).toStringAsFixed(1)}%';

String formatPoolFee(int feeBps) => '${(feeBps / 100).toStringAsFixed(feeBps % 100 == 0 ? 0 : 1)}%';

class PoolsViewModel extends BaseViewModel {
  final MiningPoolsProvider provider = GetIt.I.get<MiningPoolsProvider>();
  final StratumProvider stratum = GetIt.I.get<StratumProvider>();

  /// Only an eCash node runs the stratum server that "Mine here" points.
  final bool mines = minesHere();

  String? actionError;

  PoolsViewModel() {
    provider.addListener(notifyListeners);
    stratum.addListener(notifyListeners);
  }

  bool get isLight => GetIt.I.isRegistered<NodeModeProvider>() && GetIt.I<NodeModeProvider>().isLight;

  String get subtitle {
    final source = provider.registrySource.isEmpty ? '' : ' Pool list from ${provider.registrySource}.';
    if (provider.blockCount == 0) {
      return 'No blocks recorded in this window yet.$source';
    }
    return 'Who mined the last ${_blocks(provider.blockCount)}, read from each coinbase.$source';
  }

  /// The stratum URL the server sends its work to, or null for solo.
  String? get targetUrl {
    final target = stratum.status.target;
    return switch (target.kind) {
      TargetKind.TARGET_KIND_POOL => stratum.pools.firstWhereOrNull((pool) => pool.id == target.poolId)?.url,
      TargetKind.TARGET_KIND_CUSTOM => target.url,
      _ => null,
    };
  }

  bool isTarget(MiningPool pool) => samePoolUrl(pool.stratumUrl, targetUrl ?? '');

  /// A pool the catalog knows becomes the target. Any other pool opens the
  /// custom pool form, because the worker name is the miner's choice.
  Future<void> mineHere(MiningPool pool) async {
    final known = stratum.pools.firstWhereOrNull((catalog) => samePoolUrl(catalog.url, pool.stratumUrl));
    if (known == null) {
      MiningPage.mineAt(pool.stratumUrl);
      return;
    }
    actionError = null;
    notifyListeners();
    try {
      await stratum.setTarget(Target(kind: TargetKind.TARGET_KIND_POOL, poolId: known.id));
    } catch (e) {
      actionError = 'Could not change where the work goes: ${extractConnectException(e)}';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    provider.removeListener(notifyListeners);
    stratum.removeListener(notifyListeners);
    super.dispose();
  }
}
