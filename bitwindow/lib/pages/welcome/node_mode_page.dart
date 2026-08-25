import 'dart:async';

import 'package:auto_route/auto_route.dart';
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

  const NodeModePage({super.key, required this.onModePicked});

  @override
  State<NodeModePage> createState() => _NodeModePageState();
}

const String _backendDown = 'BitWindow cannot reach the local backend.';

class _NodeModePageState extends State<NodeModePage> {
  NodeModeProvider get _nodeMode => GetIt.I.get<NodeModeProvider>();
  Logger get _log => GetIt.I.get<Logger>();

  wmpb.NodeMode _selected = wmpb.NodeMode.NODE_MODE_LIGHT;
  bool _saving = false;
  String? _error;
  Timer? _poll;
  bool _reloading = false;

  @override
  void initState() {
    super.initState();
    _alignSelection();
    if (!_nodeMode.loaded) {
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
    if (!mounted || !_nodeMode.loaded) {
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
            SailText.secondary13(_backendDown, color: SailTheme.of(context).colors.error),
            SailButton(
              label: 'Try again',
              onPressed: _reload,
            ),
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
                      description:
                          'Reads the chain from a remote server. Ready in seconds, and uses almost no disk. '
                          'No sidechains and no mining.',
                      selected: _selected == wmpb.NodeMode.NODE_MODE_LIGHT,
                      onTap: () => setState(() => _selected = wmpb.NodeMode.NODE_MODE_LIGHT),
                    ),
                  ),
                Expanded(
                  child: _ModeCard(
                    label: 'Full node',
                    description:
                        'Runs Bitcoin Core and the enforcer on this machine. Gives you sidechains, mining, '
                        'and full privacy. Takes hours to sync and hundreds of gigabytes of disk.',
                    selected: _selected == wmpb.NodeMode.NODE_MODE_FULL,
                    onTap: () => setState(() => _selected = wmpb.NodeMode.NODE_MODE_FULL),
                  ),
                ),
              ],
            ),
          ),
          if (!_nodeMode.lightModeAvailable)
            SailText.secondary13('This network serves no remote chain server, so it runs full mode only.'),
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
