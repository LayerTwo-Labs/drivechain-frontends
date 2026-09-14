import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

Future<PlanECashSwitchResponse?> planECashMigration(
  BitcoinConfProvider provider,
  String toId, {
  NetworkChangePlan? plan,
}) async {
  if (toId.isEmpty) {
    return null;
  }
  plan ??= await provider.prepareNetworkChange(targetNetwork: BitcoinNetwork.BITCOIN_NETWORK_ECASH, networkId: toId);
  if (!plan.needsLocalBackends) {
    return null;
  }
  final migration = await provider.planECashSwitch(toId);
  final sourceId = migration.chainId.isEmpty ? migration.fromId : migration.chainId;
  return migration.hasChainData && sourceId != toId ? migration : null;
}

Future<bool> openECashMigration(
  BuildContext context, {
  required String fromId,
  required String toId,
  ECashMigrationStatus? initialStatus,
}) async {
  final result = await showThemedDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => ECashMigrationDialog(fromId: fromId, toId: toId, initialStatus: initialStatus),
  );
  return result == true;
}

class ECashMigrationDialog extends StatefulWidget {
  const ECashMigrationDialog({super.key, required this.fromId, required this.toId, this.initialStatus});

  final String fromId;
  final String toId;
  final ECashMigrationStatus? initialStatus;

  @override
  State<ECashMigrationDialog> createState() => _ECashMigrationDialogState();
}

class _ECashMigrationDialogState extends State<ECashMigrationDialog> {
  OrchestratorRPC get _rpc => GetIt.I.get<OrchestratorRPC>();

  ECashMigrationStatus? _status;
  Timer? _timer;
  String? _error;
  bool _busy = true;
  bool _statusReadFailed = false;
  bool _openSource = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _checkStatus(ECashMigrationStatus status, {bool saved = false}) {
    if (status.fromId != widget.fromId || status.toId != widget.toId) {
      throw StateError('The status belongs to another migration.');
    }
    if (saved && status.jobId.isEmpty) {
      throw StateError('The saved migration is unavailable.');
    }
    final jobId = _status?.jobId ?? widget.initialStatus?.jobId ?? '';
    if (jobId.isNotEmpty && status.jobId != jobId) {
      throw StateError('The migration job changed. Close this dialog and open the current migration.');
    }
  }

  void _acceptStatus(ECashMigrationStatus status) {
    if (!mounted) {
      return;
    }
    setState(() {
      _status = status;
      _error = status.error.isEmpty ? null : status.error;
      _statusReadFailed = false;
      _busy = false;
    });
    _timer?.cancel();
    if (status.running && !status.complete) {
      _timer = Timer(const Duration(seconds: 2), () => unawaited(_readStatus()));
    }
  }

  Future<void> _load() async {
    setState(() {
      _busy = true;
      _error = null;
      _openSource = false;
    });
    var statusRead = true;
    try {
      final saved = (await _rpc.getECashMigrationStatus()).status;
      if (saved.jobId.isNotEmpty && (!saved.complete || saved.fromId == widget.fromId && saved.toId == widget.toId)) {
        _checkStatus(saved, saved: true);
        _acceptStatus(saved);
        return;
      }
      if (widget.initialStatus?.jobId.isNotEmpty ?? false) {
        throw StateError('The saved migration is unavailable.');
      }
      if (GetIt.I.get<BitcoinConfProvider>().network != BitcoinNetwork.BITCOIN_NETWORK_ECASH) {
        if (mounted) {
          setState(() {
            _openSource = true;
            _busy = false;
            _statusReadFailed = false;
          });
        }
        return;
      }
      statusRead = false;
      final preview = (await _rpc.previewECashMigration(fromId: widget.fromId, toId: widget.toId)).status;
      _checkStatus(preview);
      _acceptStatus(preview);
    } catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _statusReadFailed = statusRead;
          _error = error.toString();
        });
      }
    }
  }

  Future<void> _readStatus() async {
    _timer?.cancel();
    try {
      final status = (await _rpc.getECashMigrationStatus()).status;
      _checkStatus(status, saved: true);
      _acceptStatus(status);
    } catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _statusReadFailed = true;
          _error = error.toString();
        });
      }
    }
  }

  Future<void> _start() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final status = (await _rpc.startECashMigration(fromId: widget.fromId, toId: widget.toId)).status;
      _checkStatus(status, saved: true);
      _acceptStatus(status);
    } catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _statusReadFailed = true;
          _error = error.toString();
        });
      }
    }
  }

  Future<void> _openTarget() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await GetIt.I.get<BitcoinConfProvider>().updateNetwork(
        BitcoinNetwork.BITCOIN_NETWORK_ECASH,
        networkId: widget.toId,
      );
      await NetworkScopedRegistry.clearAll();
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = error.toString();
        });
      }
    }
  }

  Future<void> _selectSource() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await GetIt.I.get<BitcoinConfProvider>().updateNetwork(
        BitcoinNetwork.BITCOIN_NETWORK_ECASH,
        networkId: widget.fromId,
      );
      await NetworkScopedRegistry.clearAll();
      if (mounted) {
        await _load();
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = error.toString();
        });
      }
    }
  }

  Widget _detail(String label, String value) => SailColumn(
    spacing: SailStyleValues.padding04,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SailText.secondary12(label, overflow: TextOverflow.visible),
      SailText.primary13(value, overflow: TextOverflow.visible),
    ],
  );

  List<Widget> _progress(ECashMigrationStatus status) {
    final colors = SailTheme.of(context).colors;
    final steps = [
      ('prepare', 'Prepare the Core binaries'),
      ('rewind', status.walletOnly ? 'Prepare wallet data' : 'Return to block ${status.commonHeight}'),
      ('convert', 'Change network data'),
      ('select', 'Select ${widget.toId}'),
      ('check', 'Check retained data'),
    ];
    final current = status.complete ? steps.length : steps.indexWhere((step) => step.$1 == status.phase);
    return [
      for (var index = 0; index < steps.length; index++)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: SizedBox(
                width: 16,
                height: 16,
                child: index == current && status.running
                    ? CircularProgressIndicator(strokeWidth: 1, color: colors.primary)
                    : SailSVG.fromAsset(
                        index < current ? SailSVGAsset.circleCheck : SailSVGAsset.circle,
                        color: index < current ? colors.success : colors.textSecondary,
                      ),
              ),
            ),
            const SizedBox(width: SailStyleValues.padding08),
            Expanded(child: SailText.primary13(steps[index].$2, overflow: TextOverflow.visible)),
          ],
        ),
      if (status.recordsTotal > 0) ...[
        LinearProgressIndicator(
          value: (status.recordsDone.toDouble() / status.recordsTotal.toDouble()).clamp(0, 1),
          color: colors.primary,
          backgroundColor: colors.border,
        ),
        SailText.secondary12(
          '${status.recordsDone} of ${status.recordsTotal} records complete',
          overflow: TextOverflow.visible,
        ),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final status = _status;
    final hasJob = status?.jobId.isNotEmpty ?? false;
    final complete = status?.complete ?? false;
    final active = status?.running ?? false;
    final theme = SailTheme.of(context);
    final String action;
    final Future<void> Function() onAction;
    if (_openSource) {
      action = 'Open ${widget.fromId}';
      onAction = _selectSource;
    } else if (_statusReadFailed) {
      action = 'Refresh status';
      onAction = hasJob ? _readStatus : _load;
    } else if (status == null) {
      action = 'Retry preview';
      onAction = _load;
    } else if (complete) {
      action = 'Open ${widget.toId}';
      onAction = _openTarget;
    } else {
      action = hasJob ? 'Resume migration' : 'Start migration';
      onAction = _start;
    }

    return SailDialog(
      title: _openSource
          ? 'Open source network'
          : complete
          ? 'Migration complete'
          : hasJob
          ? 'Migration to ${widget.toId}'
          : 'Preview migration',
      subtitle: '${widget.fromId} → ${widget.toId}',
      error: _error,
      maxWidth: 620,
      maxHeight: 760,
      child: SailColumn(
        spacing: SailStyleValues.padding16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_openSource) ...[
            SailText.primary13('The retained ECX data belongs to ${widget.fromId}.', overflow: TextOverflow.visible),
            SailText.secondary13('Open ${widget.fromId} to preview the migration to ${widget.toId}.'),
            SailText.secondary13('The app keeps the retained blocks.'),
          ] else if (_busy && status == null)
            SailText.secondary13('The app reads the migration preview.'),
          if (status != null) ...[
            SailText.primary13(
              status.walletOnly
                  ? 'The migration keeps wallet keys.'
                  : 'The migration keeps existing blocks and wallet keys.',
              overflow: TextOverflow.visible,
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(SailStyleValues.padding12),
              decoration: BoxDecoration(
                color: theme.colors.backgroundSecondary,
                borderRadius: SailStyleValues.borderRadiusSmall,
              ),
              child: SailColumn(
                spacing: SailStyleValues.padding12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!status.walletOnly) _detail('Rollback block', status.commonHeight.toString()),
                  _detail('Core data directory', status.dataDir),
                  SailText.secondary12(
                    status.walletOnly
                        ? 'The target sync starts from the first block.'
                        : '${status.blockFiles} block files and ${status.undoFiles} undo files stay on disk.',
                    overflow: TextOverflow.visible,
                  ),
                  if (status.pruned)
                    SailText.secondary12(
                      'The oldest retained block has height ${status.pruneHeight}.',
                      overflow: TextOverflow.visible,
                    ),
                ],
              ),
            ),
            if (!hasJob) ...[
              SailText.secondary13(
                'Balances and transactions on ${widget.fromId} do not transfer to ${widget.toId}.',
              ),
              SailText.secondary12('The full file check starts after Core stops.', overflow: TextOverflow.visible),
            ] else ...[
              ..._progress(status),
              if (complete)
                SailText.primary13(
                  'Local checks passed. ${widget.toId} sync continues.',
                  overflow: TextOverflow.visible,
                )
              else if (active)
                SailText.secondary13('The daemon continues if you close this dialog.')
              else
                SailText.secondary13(
                  'The migration stopped before completion. Resume it after you resolve the error.',
                ),
            ],
          ],
          SizedBox(
            width: double.infinity,
            child: Wrap(
              spacing: SailStyleValues.padding08,
              runSpacing: SailStyleValues.padding08,
              alignment: WrapAlignment.end,
              children: [
                SailButton(
                  label: 'Close',
                  variant: ButtonVariant.secondary,
                  disabled: _busy,
                  onPressed: () async => Navigator.of(context).pop(false),
                ),
                if (!active || complete || _statusReadFailed)
                  SailButton(label: action, loading: _busy, disabled: _busy, onPressed: onAction),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
