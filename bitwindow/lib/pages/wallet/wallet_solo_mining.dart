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

String truncateMiddle(String value, {int keep = 8}) {
  if (value.length <= keep * 2 + 1) {
    return value;
  }
  return '${value.substring(0, keep)}…${value.substring(value.length - keep)}';
}

class SoloMiningTab extends StatefulWidget {
  const SoloMiningTab({super.key});

  @override
  State<SoloMiningTab> createState() => _SoloMiningTabState();
}

class _SoloMiningTabState extends State<SoloMiningTab> {
  late final StratumProvider _stratum = GetIt.I.get<StratumProvider>();
  late final MiningProvider _cpu = GetIt.I.get<MiningProvider>();

  final _port = TextEditingController(text: '3333');
  final _poolUrl = TextEditingController();
  final _worker = TextEditingController();
  final _password = TextEditingController(text: 'x');
  String? _choice;
  bool _savedCustomShown = false;

  @override
  void initState() {
    super.initState();
    _stratum.addListener(_onChange);
    _cpu.addListener(_onChange);
    _cpu.refreshStatus();
    _showSavedCustom();
  }

  @override
  void dispose() {
    _stratum.removeListener(_onChange);
    _cpu.removeListener(_onChange);
    _port.dispose();
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
    final port = int.tryParse(_port.text.trim());
    if (port == null || port < 1 || port > 65535) {
      showSailToast(context, 'The port must be a number from 1 to 65535');
      return;
    }
    await _run('Could not start the stratum server', () async {
      if (_currentKey == _customKey) {
        await _stratum.setTarget(_customTarget());
      }
      await _stratum.start(port);
    });
  }

  Future<bool> _run(String failure, Future<void> Function() action) async {
    try {
      await action();
      return true;
    } catch (e) {
      if (mounted) {
        showSailToast(context, '$failure: ${extractConnectException(e)}');
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
                  _stoppedFields(status, key)
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
                  _connectPanel(status, solo),
              ],
            ),
          ),
          _statTiles(status, solo),
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
          if (solo)
            SailCard(
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
            ),
          _cpuCard(),
        ],
      ),
    );
  }

  Widget _connectPanel(GetStratumStatusResponse status, bool solo) {
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
          ),
          _field('Worker', 'Any name'),
          _field('Password', 'x', copy: 'x'),
          switch (status.target.kind) {
            TargetKind.TARGET_KIND_POOL => _field(
              'Payout address',
              status.payoutAddress.isEmpty ? '—' : status.payoutAddress,
            ),
            TargetKind.TARGET_KIND_CUSTOM => _field('Pool worker', status.target.worker),
            _ => _field('Block reward to', 'Enforcer wallet'),
          },
        ],
      ),
    );
  }

  Widget _field(String label, String value, {String? copy}) {
    return SailRow(
      spacing: SailStyleValues.padding12,
      children: [
        SizedBox(width: 140, child: SailText.secondary13(label)),
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

  Widget _stoppedFields(GetStratumStatusResponse status, String key) {
    final port = SizedBox(
      width: 160,
      child: SailTextField(controller: _port, label: 'Port', hintText: '3333', textFieldType: TextFieldType.number),
    );
    if (key == _customKey) {
      return SailColumn(
        spacing: SailStyleValues.padding12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [port, ..._customFields()],
      );
    }
    return SailColumn(
      spacing: SailStyleValues.padding12,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        port,
        key == _soloKey
            ? _field('Block reward to', 'Enforcer wallet')
            : _field('Payout address', status.payoutAddress.isEmpty ? '—' : status.payoutAddress),
      ],
    );
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
      ),
      SailCardStats(
        title: 'Best share',
        value: formatDifficulty(status.bestShare),
        subtitle: 'network difficulty ${formatDifficulty(status.networkDifficulty)}',
        icon: SailSVGAsset.scatterChart,
      ),
      if (solo) ...[
        SailCardStats(
          title: 'Blocks found',
          value: '${status.blocksFound.length}',
          subtitle: 'since the server started',
          icon: SailSVGAsset.boxes,
        ),
        SailCardStats(
          title: 'Expected time to a block',
          value: expected == null ? '—' : formatLongDuration(expected),
          subtitle: 'at the current hashrate',
          icon: SailSVGAsset.hourglass,
        ),
      ] else ...[
        SailCardStats(
          title: 'Accepted shares',
          value: '${status.acceptedShares}',
          subtitle: '${status.rejectedShares} rejected',
          icon: SailSVGAsset.iconCheck,
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

  Widget _cpuCard() {
    final running = _cpu.isMining;
    return SailCard(
      title: 'CPU miner',
      subtitle: 'Mine blocks on eCash with your own CPU',
      error: _cpu.error,
      widgetHeaderEnd: SailRow(
        spacing: SailStyleValues.padding12,
        children: [
          SailBadge(running ? 'Running' : 'Stopped', tone: running ? SailBadgeTone.success : SailBadgeTone.neutral),
          running
              ? SailButton(label: 'Stop', variant: ButtonVariant.outline, onPressed: () async => _cpu.stopMining())
              : SailButton(label: 'Start', onPressed: () async => _cpu.startMining()),
        ],
      ),
      child: running ? SailText.secondary13(_cpu.formattedHashRate) : const SizedBox.shrink(),
    );
  }
}
