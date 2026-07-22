import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

/// Loads a UTXO snapshot into the running Bitcoin Core, so the node validates
/// at the tip within minutes instead of downloading all of history first.
/// Nothing is stopped or deleted; Core either accepts the snapshot or reports
/// why it cannot.
///
/// Pass exactly one of [url] or [filePath].
class UTXOSnapshotPage extends StatefulWidget {
  final String url;
  final String filePath;
  final String sha256;

  const UTXOSnapshotPage({super.key, this.url = '', this.filePath = '', this.sha256 = ''});

  @override
  State<UTXOSnapshotPage> createState() => _UTXOSnapshotPageState();
}

class _UTXOSnapshotPageState extends State<UTXOSnapshotPage> {
  Logger get _log => GetIt.I.get<Logger>();
  BinaryProvider get _binaries => GetIt.I.get<BinaryProvider>();

  final _step = _SnapshotStep('Loading snapshot into Bitcoin Core');
  bool _running = false;
  bool _done = false;
  String? _error;
  String _status = '';
  int _percent = 0;

  String get _source => widget.url.isNotEmpty ? widget.url : widget.filePath;

  Future<void> _start() async {
    setState(() {
      _running = true;
      _error = null;
      _step.startTime = DateTime.now();
      _step.endTime = null;
    });

    try {
      final stream = _binaries.applyUTXOSnapshot(
        url: widget.url,
        path: widget.filePath,
        sha256: widget.sha256,
      );
      await for (final update in stream) {
        if (!mounted) return;
        setState(() {
          if (update.message.isNotEmpty) _status = update.message;
          if (update.downloadPercent > 0) _percent = update.downloadPercent;
        });
      }

      if (!mounted) return;
      setState(() {
        _step.endTime = DateTime.now();
        _done = true;
      });
    } catch (e) {
      _log.e('UTXOSnapshotPage: apply failed: $e');
      if (!mounted) return;
      setState(() {
        _step.endTime = DateTime.now();
        _error = e.toString();
      });
    }
  }

  void _handleBack() {
    Navigator.of(context).pop(_done);
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return PopScope(
      canPop: !_running || _done || _error != null,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && (_done || _error != null)) {
          Navigator.of(context).pop(_done);
        }
      },
      child: Scaffold(
        backgroundColor: theme.colors.background,
        appBar: AppBar(
          backgroundColor: theme.colors.background,
          foregroundColor: theme.colors.text,
          leading: SailAppBarBackButton(
            onPressed: _running && !_done && _error == null ? null : _handleBack,
          ),
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: SizedBox(
                width: 800,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      SailRow(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: SailStyleValues.padding12,
                        children: [
                          if (_done)
                            Icon(Icons.check_circle, color: theme.colors.success, size: 32)
                          else if (_error != null)
                            Icon(Icons.error, color: theme.colors.error, size: 32)
                          else
                            SailSVG.fromAsset(
                              SailSVGAsset.iconRestart,
                              color: theme.colors.primary,
                              width: 32,
                              height: 32,
                            ),
                          SailText.primary24(
                            _done
                                ? 'Snapshot Applied'
                                : _error != null
                                ? 'Snapshot Failed'
                                : 'Load UTXO Snapshot',
                            bold: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SailText.secondary13(
                        _done
                            ? 'Bitcoin Core accepted the snapshot and finished loading it. It now validates at the tip while the rest of history backfills in the background.'
                            : _error != null
                            ? _error!
                            : _running
                            ? (_status.isNotEmpty ? _status : 'Handing the snapshot to Bitcoin Core...')
                            : 'Bitcoin Core will read this snapshot and start validating at the tip. Nothing is deleted, and your wallets are not touched.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      SailText.secondary12(_source, textAlign: TextAlign.center),
                      if (_running && _percent > 0) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: 400,
                          child: LinearProgressIndicator(value: _percent / 100),
                        ),
                      ],
                      const SizedBox(height: 24),
                      if (_running || _done || _error != null)
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: theme.colors.backgroundSecondary,
                            borderRadius: SailStyleValues.borderRadiusSmall,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(SailStyleValues.padding12),
                            child: ProgressStepTile(
                              name: _step.name,
                              isCompleted: _step.isCompleted,
                              isActive: _running && !_step.isCompleted,
                              duration: _step.duration,
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      if (!_running && !_done && _error == null)
                        SailButton(
                          label: 'Load snapshot',
                          onPressed: () async => _start(),
                        )
                      else if (_done || _error != null)
                        SailButton(
                          label: 'Close',
                          onPressed: () async => _handleBack(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SnapshotStep {
  final String name;
  DateTime? startTime;
  DateTime? endTime;

  _SnapshotStep(this.name);

  bool get isCompleted => endTime != null;
  Duration? get duration => (startTime != null && endTime != null) ? endTime!.difference(startTime!) : null;
}
