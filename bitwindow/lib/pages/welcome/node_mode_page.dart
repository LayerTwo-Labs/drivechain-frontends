import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/env.dart';
import 'package:bitwindow/main.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

/// The choice every user makes before BitWindow boots anything: run Bitcoin
/// here, or read it from a remote server.
@RoutePage()
class NodeModePage extends StatefulWidget {
  final VoidCallback onModePicked;

  /// Brings a dead backend back, as a new start of the app does. It returns
  /// what holds the backend, or null when the boot runs.
  final Future<String?> Function() restartBackend;

  /// The polls the page waits after a restart, so a new backend gets time to
  /// boot. The page polls every two seconds.
  final int pollsBetweenRestarts;

  const NodeModePage({
    super.key,
    required this.onModePicked,
    this.restartBackend = restartSilentBackend,
    this.pollsBetweenRestarts = 15,
  });

  @override
  State<NodeModePage> createState() => _NodeModePageState();
}

const String backendWait = 'BitWindow waits for the local backend.';

const String _backendDown = 'BitWindow cannot reach the local backend.';

Future<bool> _backendListens() async {
  try {
    final socket = await Socket.connect(
      Environment.orchestratorHost.value,
      Environment.orchestratorPort.value,
      timeout: const Duration(seconds: 2),
    );
    socket.destroy();
    return true;
  } on SocketException {
    return false;
  }
}

/// Runs the app boot again when nothing listens on the drivechaind port.
///
/// The boot replaces a bitwindowd from the last run, and it keeps a bitwindowd
/// this app spawned. Only the boot starts Bitcoin Core and the enforcer, so a
/// bitwindowd restart alone would open the app on a dead L1 stack.
///
/// A port that answers as something else gets no boot. A new bitwindowd could
/// not bind that port, so the user reads who holds it.
Future<String?> restartSilentBackend() async {
  if (await _backendListens()) {
    final host = Environment.orchestratorHost.value;
    final port = Environment.orchestratorPort.value;
    return '$host:$port answers, but not as drivechaind. Stop that program, then start BitWindow again.';
  }
  await bootBitwindowBackend(GetIt.I.get<Logger>());
  return null;
}

class _NodeModePageState extends State<NodeModePage> {
  NodeModeProvider get _nodeMode => GetIt.I.get<NodeModeProvider>();
  Logger get _log => GetIt.I.get<Logger>();

  wmpb.NodeMode _selected = wmpb.NodeMode.NODE_MODE_LIGHT;
  bool _saving = false;
  String? _error;
  Timer? _poll;
  bool _reloading = false;
  bool _restarting = false;
  bool _restartedOnce = false;
  int _pollsSinceRestart = 0;

  @override
  void initState() {
    super.initState();
    _alignSelection();
    if (!_nodeMode.loaded) {
      unawaited(_restartSilentBackend());
      _poll = Timer.periodic(const Duration(seconds: 2), (_) => unawaited(_reload()));
    }
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  // A network with no remote chain server runs full mode only, so start the
  // selection somewhere the user can confirm.
  void _alignSelection() {
    if (!_nodeMode.lightModeAvailable) {
      _selected = wmpb.NodeMode.NODE_MODE_FULL;
    }
  }

  /// A dead backend asks no question. Read again until it answers, then either
  /// show the choice or move on with the choice the user already made.
  Future<void> _reload() async {
    if (_reloading) {
      return;
    }
    _reloading = true;
    try {
      await _nodeMode.load();
    } finally {
      _reloading = false;
    }
    if (!mounted) {
      return;
    }
    if (!_nodeMode.loaded) {
      unawaited(_restartSilentBackend());
      return;
    }
    _poll?.cancel();
    _poll = null;
    if (!_nodeMode.needsChoice) {
      widget.onModePicked();
      return;
    }
    setState(_alignSelection);
  }

  /// A silent backend gets a replacement, and then time to boot. The bottom
  /// bar names the step, so the page asks the user for nothing.
  Future<void> _restartSilentBackend() async {
    if (_restarting) {
      return;
    }
    if (_restartedOnce && _pollsSinceRestart < widget.pollsBetweenRestarts) {
      _pollsSinceRestart++;
      return;
    }
    _restarting = true;
    _restartedOnce = true;
    _pollsSinceRestart = 0;
    try {
      final blocker = await widget.restartBackend();
      if (mounted) {
        setState(() => _error = blocker);
      }
    } catch (e) {
      _log.e('node mode: the backend restart failed: $e');
      if (mounted) {
        setState(() => _error = '$_backendDown $e');
      }
    } finally {
      _restarting = false;
    }
  }

  Future<void> _confirm() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await _nodeMode.select(_selected);
      widget.onModePicked();
    } catch (e) {
      _log.e('node mode: could not record the choice: $e');
      setState(() => _error = _backendDown);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_nodeMode.loaded) {
      return SailPage(
        title: 'BitWindow starts the local backend',
        body: SailColumn(
          spacing: SailStyleValues.padding20,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailRow(
              spacing: SailStyleValues.padding08,
              children: [
                const SizedBox(width: 16, height: 16, child: LoadingIndicator()),
                SailText.secondary13(backendWait),
              ],
            ),
            if (_error != null) SailText.secondary13(_error!, color: SailTheme.of(context).colors.error),
          ],
        ),
      );
    }

    return SailPage(
      title: 'How do you want to run Bitcoin?',
      scrollable: true,
      body: SailColumn(
        spacing: SailStyleValues.padding20,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailText.secondary13('You can change this later in Settings.'),
          IntrinsicHeight(
            child: SailRow(
              spacing: SailStyleValues.padding16,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_nodeMode.lightModeAvailable)
                  Expanded(
                    child: _ModeCard(
                      label: 'Light',
                      description: _nodeMode.remoteEnforcerAvailable
                          ? 'Runs sidechain daemons on this machine with a remote enforcer. '
                                'Your Bitcoin wallet uses Electrum. No Bitcoin Core download.'
                          : 'Your Bitcoin wallet uses Electrum. No Bitcoin Core download.',
                      selected: _selected == wmpb.NodeMode.NODE_MODE_LIGHT,
                      onTap: () => setState(() => _selected = wmpb.NodeMode.NODE_MODE_LIGHT),
                    ),
                  ),
                Expanded(
                  child: _ModeCard(
                    label: 'Full node',
                    description:
                        'Runs Bitcoin Core, the enforcer, and sidechain daemons on this machine. '
                        'Bitcoin sync takes hours and hundreds of gigabytes of disk.',
                    selected: _selected == wmpb.NodeMode.NODE_MODE_FULL,
                    onTap: () => setState(() => _selected = wmpb.NodeMode.NODE_MODE_FULL),
                  ),
                ),
              ],
            ),
          ),
          if (!_nodeMode.lightModeAvailable)
            SailText.secondary13(
              'This network has no remote enforcer or Bitcoin wallet server, so it uses full mode.',
            ),
          if (_error != null) SailText.secondary13(_error!, color: SailTheme.of(context).colors.error),
          SailButton(
            label: 'Continue',
            loading: _saving,
            onPressed: _confirm,
          ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String label;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.label,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(SailStyleValues.padding16),
        decoration: BoxDecoration(
          color: theme.colors.backgroundSecondary,
          border: Border.all(color: selected ? theme.colors.primary : theme.colors.divider),
          borderRadius: SailStyleValues.borderRadius,
        ),
        child: SailColumn(
          spacing: SailStyleValues.padding04,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SailText.primary15(label),
            SailText.secondary13(description),
          ],
        ),
      ),
    );
  }
}
