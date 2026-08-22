import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
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

class _NodeModePageState extends State<NodeModePage> {
  NodeModeProvider get _nodeMode => GetIt.I.get<NodeModeProvider>();

  wmpb.NodeMode _selected = wmpb.NodeMode.NODE_MODE_LIGHT;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // A network with no remote chain server runs full mode only, so start the
    // selection somewhere the user can confirm.
    if (!_nodeMode.lightModeAvailable) {
      _selected = wmpb.NodeMode.NODE_MODE_FULL;
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
      setState(() => _error = '$e');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SailPage(
      title: 'How do you want to run Bitcoin?',
      scrollable: true,
      body: SailColumn(
        spacing: SailStyleValues.padding20,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailText.primary24('How do you want to run Bitcoin?'),
          SailText.secondary13('You can change this later in Settings.'),
          if (_nodeMode.lightModeAvailable)
            _ModeCard(
              label: 'Light',
              description:
                  'Reads the chain from a remote server. Ready in seconds, and uses almost no disk. '
                  'No sidechains and no mining.',
              selected: _selected == wmpb.NodeMode.NODE_MODE_LIGHT,
              onTap: () => setState(() => _selected = wmpb.NodeMode.NODE_MODE_LIGHT),
            ),
          _ModeCard(
            label: 'Full node',
            description:
                'Runs Bitcoin Core and the enforcer on this machine. Gives you sidechains, mining, '
                'and full privacy. Takes hours to sync and hundreds of gigabytes of disk.',
            selected: _selected == wmpb.NodeMode.NODE_MODE_FULL,
            onTap: () => setState(() => _selected = wmpb.NodeMode.NODE_MODE_FULL),
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
