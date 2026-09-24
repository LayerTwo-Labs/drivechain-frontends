import 'package:bitwindow/dialogs/mining_settings_dialog.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/stratum/v1/stratum.pb.dart';

const _soloKey = 'solo';
const _customKey = 'custom';
const _poolKeyPrefix = 'pool:';

const _soloDescription = 'Your node builds each block. A block that you find pays the full reward to you.';
const _poolDescription = 'The pool splits each block among its miners. You get smaller payouts more often.';
const _customDescription = 'Send the work to a Stratum pool that you type in.';

const _ranges = [
  (HashrateRange.HASHRATE_RANGE_HOUR, '1 h'),
  (HashrateRange.HASHRATE_RANGE_DAY, '24 h'),
  (HashrateRange.HASHRATE_RANGE_WEEK, '7 d'),
];

/// The dropdown key of a target the backend holds.
String targetKey(Target target) {
  return switch (target.kind) {
    TargetKind.TARGET_KIND_POOL => '$_poolKeyPrefix${target.poolId}',
    TargetKind.TARGET_KIND_CUSTOM => _customKey,
    _ => _soloKey,
  };
}

/// The status of a found block: immature until it has 100 confirmations.
String blockStatus(int confirmations) {
  if (confirmations < 0) {
    return 'Orphaned';
  }
  if (confirmations >= 100) {
    return 'Mature';
  }
  return 'Immature · $confirmations of 100';
}

/// chartLabels writes the time under the plot, oldest first.
List<String> chartLabels(List<HashratePoint> points, HashrateRange range) {
  if (points.isEmpty) {
    return const [];
  }
  String two(int n) => n.toString().padLeft(2, '0');
  String label(HashratePoint point) {
    final at = point.time.toDateTime().toLocal();
    if (range == HashrateRange.HASHRATE_RANGE_WEEK) {
      return '${two(at.day)}.${two(at.month)}';
    }
    return '${two(at.hour)}:${two(at.minute)}';
  }

  final steps = [0, points.length ~/ 4, points.length ~/ 2, points.length * 3 ~/ 4, points.length - 1];
  return [for (final i in steps) label(points[i])];
}

class SoloMiningTab extends StatefulWidget {
  const SoloMiningTab({super.key});

  @override
  State<SoloMiningTab> createState() => _SoloMiningTabState();
}

class _SoloMiningTabState extends State<SoloMiningTab> {
  late final StratumProvider _stratum = GetIt.I.get<StratumProvider>();

  final _poolUrl = TextEditingController();
  final _worker = TextEditingController();
  final _password = TextEditingController(text: 'x');
  String? _choice;
  bool _savedCustomShown = false;

  @override
  void initState() {
    super.initState();
    _stratum.addListener(_onChange);
    _showSavedCustom();
  }

  @override
  void dispose() {
    _stratum.removeListener(_onChange);
    _poolUrl.dispose();
    _worker.dispose();
    _password.dispose();
    super.dispose();
  }

  void _onChange() {
    if (mounted) {
      _showSavedCustom();
      setState(() {});
    }
  }

  void _showSavedCustom() {
    if (_savedCustomShown || _stratum.status.target.kind != TargetKind.TARGET_KIND_CUSTOM) {
      return;
    }
    _savedCustomShown = true;
    _fillCustomFields();
  }

  String get _currentKey => _choice ?? targetKey(_stratum.status.target);

  Target _customTarget() {
    return Target(
      kind: TargetKind.TARGET_KIND_CUSTOM,
      url: _poolUrl.text.trim(),
      worker: _worker.text.trim(),
      password: _password.text,
    );
  }

  void _fillCustomFields() {
    final saved = _stratum.status.target;
    if (saved.kind == TargetKind.TARGET_KIND_CUSTOM) {
      _poolUrl.text = saved.url;
      _worker.text = saved.worker;
      _password.text = saved.password;
      return;
    }
    if (_worker.text.isEmpty && GetIt.I.isRegistered<TransactionProvider>()) {
      _worker.text = '${GetIt.I.get<TransactionProvider>().address}.';
    }
  }

  Future<void> _choose(String key) async {
    setState(() => _choice = key);
    if (key == _customKey) {
      _fillCustomFields();
      return;
    }
    final target = key == _soloKey
        ? Target(kind: TargetKind.TARGET_KIND_SOLO)
        : Target(kind: TargetKind.TARGET_KIND_POOL, poolId: key.substring(_poolKeyPrefix.length));
    await _run('Could not change where the work goes', () => _stratum.setTarget(target));
    if (mounted) {
      setState(() => _choice = null);
    }
  }

  Future<void> _switchToCustom() async {
    final done = await _run('Could not change where the work goes', () => _stratum.setTarget(_customTarget()));
    if (done && mounted) {
      setState(() => _choice = null);
    }
  }

  Future<void> _start() async {
    await _run('Could not start the stratum server', () async {
      if (_currentKey == _customKey) {
        await _stratum.setTarget(_customTarget());
      }
      await _stratum.start(_stratum.status.settings.port);
    });
  }

  Future<bool> _run(String failure, Future<void> Function() action) async {
    try {
      await action();
      return true;
    } catch (e) {
      if (mounted) {
        showSailToast(context, '$failure: ${extractConnectException(e)}', variant: SailToastVariant.destructive);
      }
      return false;
    }
  }

  Future<void> _copy(String label, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (mounted) {
      showSailToast(context, '$label copied to clipboard');
    }
  }

  List<SailComboboxItem<String>> _targetItems() {
    return [
      const SailComboboxItem(
        value: _soloKey,
        label: 'Solo, your node',
        subtitle: _soloDescription,
        section: 'Your node',
        trailing: ['No fee'],
      ),
      for (final pool in _stratum.pools)
        SailComboboxItem(
          value: '$_poolKeyPrefix${pool.id}',
          label: pool.name,
          subtitle: _poolDescription,
          section: 'Pools',
          searchValue: '${pool.name} ${pool.url}',
          trailing: [
            pool.hasHashrate() ? formatHashrate(pool.hashrate) : '—',
            if (pool.fee.isNotEmpty) '${pool.fee} fee',
          ],
        ),
      const SailComboboxItem(
        value: _customKey,
        label: 'Custom pool',
        subtitle: _customDescription,
        section: 'Other',
      ),
    ];
  }

  String _description(String key) {
    if (key == _soloKey) {
      return _soloDescription;
    }
    if (key == _customKey) {
      return _customDescription;
    }
    return _poolDescription;
  }

  @override
  Widget build(BuildContext context) {
    final status = _stratum.status;
    final key = _currentKey;
    final solo = key == _soloKey;

    return SingleChildScrollView(
      child: SailColumn(
        spacing: SailStyleValues.padding16,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SailCard(
            title: 'Stratum server',
            subtitle: 'Mining for ASIC miners on your network',
            error: _stratum.error ?? (status.error.isEmpty ? null : status.error),
            widgetHeaderEnd: SailRow(
              spacing: SailStyleValues.padding12,
              children: [
                SailBadge(
                  status.running ? 'Running' : 'Stopped',
                  tone: status.running ? SailBadgeTone.success : SailBadgeTone.neutral,
                ),
                status.running
                    ? SailButton(
                        label: 'Stop',
                        variant: ButtonVariant.outline,
                        onPressed: () async => _run('Could not stop the stratum server', _stratum.stop),
                      )
                    : SailButton(label: 'Start', onPressed: () async => _start()),
                SailButton(
                  variant: ButtonVariant.icon,
                  icon: SailSVGAsset.tabSettings,
                  onPressed: () async =>
                      showThemedDialog(context: context, builder: (context) => const MiningSettingsDialog()),
                ),
              ],
            ),
            child: SailColumn(
              spacing: SailStyleValues.padding16,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SailColumn(
                  spacing: SailStyleValues.padding08,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SailText.primary13('Mine to', bold: true),
                    SailRow(
                      spacing: SailStyleValues.padding12,
                      children: [
                        SailCombobox<String>(
                          items: _targetItems(),
                          value: key,
                          width: 480,
                          searchPlaceholder: 'Search pools',
                          noResultsText: 'No pool found',
                          onChanged: (next) => _choose(next),
                        ),
                        Flexible(child: SailText.secondary13(_description(key))),
                      ],
                    ),
                  ],
                ),
                if (!status.running)
                  _stoppedFields(status)
                else if (key == _customKey && status.target.kind != TargetKind.TARGET_KIND_CUSTOM)
                  SailColumn(
                    spacing: SailStyleValues.padding12,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ..._customFields(),
                      SailButton(label: 'Mine to this pool', onPressed: () async => _switchToCustom()),
                    ],
                  )
                else
                  _connectPanel(status),
              ],
            ),
          ),
          _statTiles(status, solo),
          if (status.running) _hashrateCard(),
          SailCard(
            title: 'Miners',
            child: SailTable(
              shrinkWrap: true,
              getRowId: (i) => '${status.miners[i].address}/${status.miners[i].worker}',
              emptyPlaceholder: 'No miner connected',
              headerBuilder: (context) => const [
                SailTableHeaderCell(name: 'Worker'),
                SailTableHeaderCell(name: 'Address'),
                SailTableHeaderCell(name: 'Hashrate'),
                SailTableHeaderCell(name: 'Best share'),
                SailTableHeaderCell(name: 'Accepted / rejected'),
                SailTableHeaderCell(name: 'Temperature'),
                SailTableHeaderCell(name: 'Fan'),
                SailTableHeaderCell(name: 'Power'),
                SailTableHeaderCell(name: 'Work mode'),
                SailTableHeaderCell(name: 'Last share'),
              ],
              rowCount: status.miners.length,
              rowBuilder: (context, row, selected) => _minerRow(status.miners[row]),
            ),
          ),
          _sharesCard(status),
          if (solo) _blocksCard(status) else _poolBlocksCard(),
        ],
      ),
    );
  }

  Widget _connectPanel(GetStratumStatusResponse status) {
    final theme = SailTheme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SailStyleValues.padding16),
      decoration: BoxDecoration(
        color: theme.colors.backgroundSecondary,
        borderRadius: SailStyleValues.borderRadiusSmall,
      ),
      child: SailColumn(
        spacing: SailStyleValues.padding08,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _field(
            'Pool address',
            status.poolUrl.isEmpty ? '—' : status.poolUrl,
            copy: status.poolUrl.isEmpty ? null : status.poolUrl,
            info: poolAddressInfo,
          ),
          _field('Worker', 'Any name'),
          _field('Password', 'x', copy: 'x'),
          if (status.target.kind == TargetKind.TARGET_KIND_CUSTOM) _field('Pool worker', status.target.worker),
          _payoutField(status),
        ],
      ),
    );
  }

  /// A custom pool pays whatever its own worker name earns, so this address
  /// says nothing there.
  Widget _payoutField(GetStratumStatusResponse status) {
    if (_currentKey == _customKey) {
      return const SizedBox.shrink();
    }
    return _field('Payout address', status.payoutAddress.isEmpty ? '—' : status.payoutAddress);
  }

  Widget _field(String label, String value, {String? copy, String? info}) {
    return SailRow(
      spacing: SailStyleValues.padding12,
      children: [
        SizedBox(
          width: 170,
          child: SailRow(
            spacing: SailStyleValues.padding04,
            children: [
              Flexible(child: SailText.secondary13(label)),
              if (info != null) SailInfoIcon(title: label, message: info),
            ],
          ),
        ),
        Flexible(child: SailText.primary13(value, monospace: copy != null)),
        if (copy != null)
          SailButton(
            variant: ButtonVariant.icon,
            icon: SailSVGAsset.iconCopy,
            onPressed: () async => _copy(label, copy),
          ),
      ],
    );
  }

  Widget _stoppedFields(GetStratumStatusResponse status) {
    if (_currentKey == _customKey) {
      return SailColumn(
        spacing: SailStyleValues.padding12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [..._customFields(), _payoutField(status)],
      );
    }
    return _payoutField(status);
  }

  List<Widget> _customFields() {
    return [
      SizedBox(
        width: 480,
        child: SailTextField(controller: _poolUrl, label: 'Pool address', hintText: 'stratum+tcp://'),
      ),
      SizedBox(
        width: 480,
        child: SailTextField(controller: _worker, label: 'Worker', hintText: 'address.worker'),
      ),
      SizedBox(
        width: 240,
        child: SailTextField(controller: _password, label: 'Password', hintText: 'x'),
      ),
    ];
  }

  Widget _statTiles(GetStratumStatusResponse status, bool solo) {
    final miners = status.miners.length;
    final expected = expectedTimeToBlock(status.networkDifficulty, status.hashrate);
    final tiles = <Widget>[
      SailCardStats(
        title: 'Hashrate',
        value: formatHashrate(status.hashrate),
        subtitle: '$miners ${miners == 1 ? 'miner' : 'miners'}',
        icon: SailSVGAsset.barChartBig,
        info: hashrateInfo(
          hashrate: status.hashrate,
          networkHashrate: status.networkHashrate,
          networkDifficulty: status.networkDifficulty,
          formattedHashrate: formatHashrate(status.hashrate),
          formattedNetwork: formatHashrate(status.networkHashrate),
        ),
      ),
      SailCardStats(
        title: 'Best share',
        value: formatDifficulty(status.bestShare),
        subtitle: 'of ${formatDifficulty(status.networkDifficulty)} needed for a block',
        icon: SailSVGAsset.scatterChart,
        info: bestShareInfo(
          bestShare: status.bestShare,
          won: status.bestShareWon,
          networkDifficulty: status.networkDifficulty,
        ),
      ),
      if (solo) ...[
        SailCardStats(
          title: 'Blocks found',
          value: '${status.blocksFound.length}',
          subtitle: 'since the server started',
          icon: SailSVGAsset.boxes,
          info: blocksFoundInfo,
        ),
        SailCardStats(
          title: 'Expected time to a block',
          value: expected == null ? '—' : formatLongDuration(expected),
          subtitle: 'at the current hashrate',
          icon: SailSVGAsset.hourglass,
          info: expectedTimeInfo,
        ),
      ] else ...[
        SailCardStats(
          title: 'Accepted shares',
          value: '${status.acceptedShares}',
          subtitle: '${status.rejectedShares} rejected',
          icon: SailSVGAsset.iconCheck,
          info: recentSharesInfo,
        ),
        SailCardStats(
          title: 'Pool',
          value: status.poolConnected ? 'Connected' : 'Disconnected',
          subtitle: status.poolHost,
          icon: SailSVGAsset.iconNetwork,
        ),
      ],
    ];
    return SailRow(
      spacing: SailStyleValues.padding16,
      children: [for (final tile in tiles) Expanded(child: tile)],
    );
  }

  Widget _hashrateCard() {
    final history = _stratum.history;
    return SailCard(
      title: 'Hashrate',
      widgetHeaderEnd: SailToggleGroup<HashrateRange>(
        singleChoice: true,
        values: [_stratum.range],
        items: [for (final (range, label) in _ranges) SailToggleGroupItem(value: range, label: label)],
        onChanged: (values) {
          if (values.isNotEmpty) {
            _run('Could not read the hashrate chart', () => _stratum.setRange(values.first));
          }
        },
      ),
      child: SailColumn(
        spacing: SailStyleValues.padding08,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SailAreaChart(
            points: [
              for (final point in history.points)
                SailChartPoint(at: point.time.toDateTime().toLocal(), value: point.hashrate),
            ],
            labels: chartLabels(history.points, _stratum.range),
          ),
          SailText.secondary12(
            'peak ${formatHashrate(history.peak)}  ·  now ${formatHashrate(history.current)}',
          ),
        ],
      ),
    );
  }

  Widget _sharesCard(GetStratumStatusResponse status) {
    return SailCard(
      title: 'Recent shares',
      titleTooltip: recentSharesInfo,
      widgetHeaderEnd: SailText.secondary12(
        'last ${status.recentShares.length} · a block needs ${formatDifficulty(status.networkDifficulty)}',
      ),
      child: SailTable(
        shrinkWrap: true,
        getRowId: (i) => '${status.recentShares[i].hash}/$i',
        emptyPlaceholder: 'No share yet',
        headerBuilder: (context) => const [
          SailTableHeaderCell(name: 'When'),
          SailTableHeaderCell(name: 'Worker'),
          SailTableHeaderCell(name: 'Target'),
          SailTableHeaderCell(name: 'Actual'),
          SailTableHeaderCell(name: 'Share hash'),
        ],
        rowCount: status.recentShares.length,
        rowBuilder: (context, row, selected) => _shareRow(status.recentShares[row]),
      ),
    );
  }

  List<Widget> _shareRow(AcceptedShare share) {
    return [
      SailTableCell(value: formatAgo(share.time.toDateTime(), DateTime.now())),
      SailTableCell(value: share.worker),
      SailTableCell(value: formatDifficulty(share.target)),
      SailTableCell(value: formatDifficulty(share.actual)),
      SailTableCell(value: share.block ? '${share.hash} · block' : share.hash, copyValue: share.hash),
    ];
  }

  Widget _blocksCard(GetStratumStatusResponse status) {
    return SailCard(
      title: 'Blocks found',
      child: SailTable(
        shrinkWrap: true,
        getRowId: (i) => status.blocksFound[i].hash,
        emptyPlaceholder: 'No block found',
        headerBuilder: (context) => const [
          SailTableHeaderCell(name: 'Height'),
          SailTableHeaderCell(name: 'Block hash'),
          SailTableHeaderCell(name: 'Reward'),
          SailTableHeaderCell(name: 'Found by'),
          SailTableHeaderCell(name: 'Time'),
          SailTableHeaderCell(name: 'Status'),
        ],
        rowCount: status.blocksFound.length,
        rowBuilder: (context, row, selected) => _blockRow(status.blocksFound[row]),
      ),
    );
  }

  List<Widget> _blockRow(FoundBlock block) {
    final formatter = GetIt.I.get<FormatterProvider>();
    return [
      SailTableCell(value: '${block.height}'),
      SailTableCell(value: truncateMiddle(block.hash), copyValue: block.hash, monospace: true),
      SailTableCell(value: formatter.formatSats(block.rewardSats.toInt())),
      SailTableCell(value: block.worker),
      SailTableCell(value: formatAgo(block.foundTime.toDateTime(), DateTime.now())),
      SailTableCell(value: block.hasConfirmations() ? blockStatus(block.confirmations) : '—'),
    ];
  }

  Widget _poolBlocksCard() {
    final blocks = _stratum.poolBlocks;
    return SailCard(
      title: 'Blocks the pool found',
      subtitle: blocks.unavailable.isEmpty ? null : blocks.unavailable,
      child: SailTable(
        shrinkWrap: true,
        getRowId: (i) => blocks.blocks[i].hash,
        emptyPlaceholder: blocks.unavailable.isEmpty ? 'No block found' : blocks.unavailable,
        headerBuilder: (context) => const [
          SailTableHeaderCell(name: 'Height'),
          SailTableHeaderCell(name: 'Block hash'),
          SailTableHeaderCell(name: 'Pool reward'),
          SailTableHeaderCell(name: 'Found by'),
          SailTableHeaderCell(name: 'My payout'),
          SailTableHeaderCell(name: 'Time'),
          SailTableHeaderCell(name: 'Status'),
        ],
        rowCount: blocks.blocks.length,
        rowBuilder: (context, row, selected) => _poolBlockRow(blocks.blocks[row]),
      ),
    );
  }

  List<Widget> _poolBlockRow(PoolBlock block) {
    final formatter = GetIt.I.get<FormatterProvider>();
    return [
      SailTableCell(value: '${block.height}'),
      SailTableCell(value: truncateMiddle(block.hash), copyValue: block.hash, monospace: true),
      SailTableCell(value: formatter.formatSats(block.rewardSats.toInt())),
      SailTableCell(value: block.mine ? '${block.finder} (you)' : block.finder),
      SailTableCell(value: block.hasMyPayoutSats() ? formatter.formatSats(block.myPayoutSats.toInt()) : '—'),
      SailTableCell(value: block.hasFoundTime() ? formatAgo(block.foundTime.toDateTime(), DateTime.now()) : '—'),
      SailTableCell(value: block.hasConfirmations() ? blockStatus(block.confirmations) : '—'),
    ];
  }

  List<Widget> _minerRow(ConnectedMiner miner) {
    String optional(bool present, String Function() format) => present ? format() : '—';
    final lastShare = miner.hasLastShareTime() ? formatAgo(miner.lastShareTime.toDateTime(), DateTime.now()) : '—';
    return [
      SailTableCell(value: miner.worker),
      SailTableCell(value: miner.address, monospace: true),
      SailTableCell(value: formatHashrate(miner.hashrate)),
      SailTableCell(value: formatDifficulty(miner.bestShare)),
      SailTableCell(value: '${miner.acceptedShares} / ${miner.rejectedShares}'),
      SailTableCell(
        value: optional(miner.hasTemperatureCelsius(), () => '${miner.temperatureCelsius.toStringAsFixed(0)} °C'),
      ),
      SailTableCell(value: optional(miner.hasFanPercent(), () => '${miner.fanPercent.toStringAsFixed(0)}%')),
      SailTableCell(value: optional(miner.hasPowerWatts(), () => '${miner.powerWatts.toStringAsFixed(0)} W')),
      miner.workMode == WorkMode.WORK_MODE_UNSPECIFIED
          ? SailTableCell(value: '—')
          : SailTableCell(
              value: _workModeLabel(miner.workMode),
              width: 120,
              child: SailDropdownButton<WorkMode>(
                value: miner.workMode,
                items: [
                  for (final mode in const [WorkMode.WORK_MODE_LOW, WorkMode.WORK_MODE_MID, WorkMode.WORK_MODE_HIGH])
                    SailDropdownItem<WorkMode>(value: mode, label: _workModeLabel(mode)),
                ],
                onChanged: (mode) {
                  if (mode == null || mode == miner.workMode) {
                    return;
                  }
                  _run('Could not set the work mode', () => _stratum.setWorkMode(miner.address, mode));
                },
              ),
            ),
      SailTableCell(value: lastShare),
    ];
  }

  String _workModeLabel(WorkMode mode) {
    return switch (mode) {
      WorkMode.WORK_MODE_LOW => 'Low',
      WorkMode.WORK_MODE_MID => 'Mid',
      WorkMode.WORK_MODE_HIGH => 'High',
      _ => '—',
    };
  }
}
