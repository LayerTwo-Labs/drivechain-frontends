import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/providers/mempool_watch_provider.dart';
import 'package:bitwindow/providers/mining_pools_provider.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

const _windows = [
  SailToggleGroupItem(value: MiningPoolWindow.MINING_POOL_WINDOW_24H, label: '24h'),
  SailToggleGroupItem(value: MiningPoolWindow.MINING_POOL_WINDOW_3D, label: '3d'),
  SailToggleGroupItem(value: MiningPoolWindow.MINING_POOL_WINDOW_1W, label: '1w'),
];

@RoutePage()
class MiningPage extends StatelessWidget {
  const MiningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return QtPage(
      child: ViewModelBuilder<MiningPoolsViewModel>.reactive(
        viewModelBuilder: () => MiningPoolsViewModel(),
        builder: (context, model, child) {
          final provider = model.provider;
          return SailCard(
            title: 'Mining Pools',
            subtitle:
                'The pools listed at pool.drivechain.info and the recent blocks each one mined, read from the coinbase.',
            error: provider.error,
            bottomPadding: false,
            widgetHeaderEnd: SailButton(
              label: model.mempoolWatch.alerting ? 'Transaction Censorship ❗' : 'Transaction Censorship',
              variant: ButtonVariant.secondary,
              onPressed: () => GetIt.I.get<AppRouter>().push(const TransactionCensorshipRoute()),
            ),
            child: model.isLight
                ? SailText.secondary13('Mining Pools needs a full node.')
                : SailColumn(
                    spacing: SailStyleValues.padding16,
                    children: [
                      _Header(model: model),
                      if (!provider.registryAvailable)
                        SailText.secondary13(
                          'This network publishes no pool registry, so every block shows as Unknown.',
                        ),
                      _Stats(provider: provider),
                      if (provider.pools.isNotEmpty) _ShareChart(pools: provider.pools),
                      Expanded(child: _PoolsTable(provider: provider)),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final MiningPoolsViewModel model;

  const _Header({required this.model});

  @override
  Widget build(BuildContext context) {
    return SailRow(
      spacing: SailStyleValues.padding16,
      children: [
        SailToggleGroup<MiningPoolWindow>(
          items: _windows,
          values: [model.provider.window],
          singleChoice: true,
          onChanged: (values) => model.provider.setWindow(values.first),
        ),
        Expanded(child: SailText.secondary13(model.statusText)),
      ],
    );
  }
}

class _Stats extends StatelessWidget {
  final MiningPoolsProvider provider;

  const _Stats({required this.provider});

  @override
  Widget build(BuildContext context) {
    return SailRow(
      spacing: SailStyleValues.padding16,
      children: [
        Expanded(
          child: SailCardStats(
            title: 'Blocks',
            subtitle: 'In the selected window',
            value: provider.blockCount.toString(),
            icon: SailSVGAsset.boxes,
          ),
        ),
        Expanded(
          child: SailCardStats(
            title: 'Network hashrate',
            subtitle: 'Work the window took over its span',
            value: formatHashrate(provider.networkHashrate),
            icon: SailSVGAsset.barChartBig,
          ),
        ),
        Expanded(
          child: SailCardStats(
            title: 'Pools',
            subtitle: 'With blocks in the window',
            value: provider.pools.where((p) => p.blockCount > 0).length.toString(),
            icon: SailSVGAsset.scatterChart,
          ),
        ),
      ],
    );
  }
}

class _ShareChart extends StatefulWidget {
  final List<MiningPoolShare> pools;

  const _ShareChart({required this.pools});

  @override
  State<_ShareChart> createState() => _ShareChartState();
}

class _ShareChartState extends State<_ShareChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final colors = theme.colors.chartPalette;
    final pools = widget.pools;

    return SizedBox(
      height: 180,
      child: SailRow(
        spacing: SailStyleValues.padding16,
        children: [
          Expanded(
            flex: 2,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    setState(() {
                      final section = response?.touchedSection;
                      _touchedIndex = !event.isInterestedForInteractions || section == null
                          ? -1
                          : section.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 30,
                sections: [
                  for (var i = 0; i < pools.length; i++)
                    PieChartSectionData(
                      color: colors[i % colors.length],
                      value: pools[i].blockCount.toDouble(),
                      title: pools[i].share >= 0.05 ? '${(pools[i].share * 100).toStringAsFixed(0)}%' : '',
                      radius: i == _touchedIndex ? 55 : 50,
                      titleStyle: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: theme.colors.primaryButtonText,
                      ),
                      titlePositionPercentageOffset: 0.6,
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: _Legend(
              pools: pools,
              touchedIndex: _touchedIndex,
              onTouchChange: (index) => setState(() => _touchedIndex = index),
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final List<MiningPoolShare> pools;
  final int touchedIndex;
  final void Function(int) onTouchChange;

  const _Legend({required this.pools, required this.touchedIndex, required this.onTouchChange});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final colors = theme.colors.chartPalette;
    return ListView.builder(
      itemCount: pools.length,
      itemBuilder: (context, index) {
        final share = pools[index];
        return MouseRegion(
          onEnter: (_) => onTouchChange(index),
          onExit: (_) => onTouchChange(-1),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
            decoration: BoxDecoration(
              color: index == touchedIndex ? theme.colors.backgroundSecondary : SailColorScheme.transparent,
              borderRadius: SailStyleValues.borderRadiusSmall,
            ),
            child: SailRow(
              spacing: SailStyleValues.padding08,
              children: [
                SailAvatar(initials: share.pool.name, size: 18, backgroundColor: colors[index % colors.length]),
                Expanded(child: SailText.primary12(share.pool.name)),
                SailText.secondary12('${share.blockCount} ${share.blockCount == 1 ? 'block' : 'blocks'}'),
                SailText.primary12(formatShare(share.share), monospace: true),
              ],
            ),
          ),
        );
      },
    );
  }
}

const _columnNames = ['Pool', 'Mode', 'Fee', 'Blocks', 'Share', 'Empty blocks', 'Est. hashrate', 'Stratum', 'Link'];

class _PoolsTable extends StatelessWidget {
  final MiningPoolsProvider provider;

  const _PoolsTable({required this.provider});

  @override
  Widget build(BuildContext context) {
    final pools = provider.pools;
    return SailTable(
      getRowId: (index) => pools[index].pool.slug,
      headerBuilder: (context) => [for (final name in _columnNames) SailTableHeaderCell(name: name)],
      cellHeight: 36.0,
      rowBuilder: (context, row, selected) {
        final share = pools[row];
        final pool = share.pool;
        return [
          SailTableCell(value: pool.name),
          SailTableCell(value: pool.mode),
          SailTableCell(value: pool.mode.isEmpty ? '' : formatFee(pool.feeBps), monospace: true),
          SailTableCell(value: share.blockCount.toString(), monospace: true),
          SailTableCell(value: formatShare(share.share), monospace: true),
          SailTableCell(value: share.emptyBlocks.toString(), monospace: true),
          SailTableCell(value: formatHashrate(share.estimatedHashrate), monospace: true),
          SailTableCell(
            value: pool.stratumUrl,
            copyValue: pool.stratumUrl.isEmpty ? null : pool.stratumUrl,
            monospace: true,
          ),
          SailTableCell(value: pool.link, copyValue: pool.link.isEmpty ? null : pool.link),
        ];
      },
      rowCount: pools.length,
      emptyPlaceholder: 'No blocks recorded in this window',
      drawGrid: true,
    );
  }
}

String formatShare(double share) => '${(share * 100).toStringAsFixed(1)}%';

String formatFee(int feeBps) => '${(feeBps / 100).toStringAsFixed(feeBps % 100 == 0 ? 0 : 1)}%';

class MiningPoolsViewModel extends BaseViewModel {
  final MiningPoolsProvider provider = GetIt.I.get<MiningPoolsProvider>();
  final MempoolWatchProvider mempoolWatch = GetIt.I.get<MempoolWatchProvider>();

  MiningPoolsViewModel() {
    provider.addListener(notifyListeners);
    mempoolWatch.addListener(notifyListeners);
  }

  bool get isLight => GetIt.I.isRegistered<NodeModeProvider>() && GetIt.I<NodeModeProvider>().isLight;

  String get statusText {
    if (provider.blockCount == 0) {
      return 'No blocks recorded in this window yet';
    }
    return 'Blocks ${provider.fromHeight} to ${provider.toHeight} · registry: ${provider.registrySource}';
  }

  @override
  void dispose() {
    provider.removeListener(notifyListeners);
    mempoolWatch.removeListener(notifyListeners);
    super.dispose();
  }
}
