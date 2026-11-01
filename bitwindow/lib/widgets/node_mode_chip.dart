import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

/// The node mode chip in the status bar. A click opens the node mode popover
/// above it.
class NodeModeChip extends StatefulWidget {
  const NodeModeChip({super.key});

  static final SailPopoverController _controller = SailPopoverController();
  static bool _openOnDataDir = false;

  /// Opens the popover. [dataDir] opens it on its data directory page.
  static void open({bool dataDir = false}) {
    _openOnDataDir = dataDir;
    _controller.show();
  }

  @override
  State<NodeModeChip> createState() => _NodeModeChipState();
}

class _NodeModeChipState extends State<NodeModeChip> {
  NodeModeProvider get _nodeMode => GetIt.I.get<NodeModeProvider>();

  @override
  void initState() {
    super.initState();
    _nodeMode.addListener(_onChange);
  }

  @override
  void dispose() {
    _nodeMode.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    return SailPopover(
      controller: NodeModeChip._controller,
      side: SailPopoverSide.top,
      offset: 8,
      borderRadius: theme.chrome.radiusLarge,
      popover: NodeModePopover(
        dataDirFirst: NodeModeChip._openOnDataDir,
        onDone: NodeModeChip._controller.hide,
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colors.chip,
            borderRadius: theme.chrome.radiusSmall,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SailText.primary12(_nodeMode.isFull ? 'Full node' : 'Light'),
              const SizedBox(width: 4),
              SailSVG.fromAsset(SailSVGAsset.chevronUp, color: theme.colors.text, width: 8),
            ],
          ),
        ),
      ),
    );
  }
}

/// Picks the node mode, and the data directory full mode needs first.
class NodeModePopover extends StatefulWidget {
  /// Opens on the data directory page, for a full mode install with none.
  final bool dataDirFirst;
  final VoidCallback onDone;

  const NodeModePopover({super.key, required this.onDone, this.dataDirFirst = false});

  @override
  State<NodeModePopover> createState() => _NodeModePopoverState();
}

class _NodeModePopoverState extends State<NodeModePopover> {
  NodeModeProvider get _nodeMode => GetIt.I.get<NodeModeProvider>();
  BitcoinConfProvider get _conf => GetIt.I.get<BitcoinConfProvider>();

  final DataDirSelection _dataDir = DataDirSelection();
  late wmpb.NodeMode _selected;
  late bool _onDataDirPage;
  bool _switching = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selected = widget.dataDirFirst || _nodeMode.isFull ? wmpb.NodeMode.NODE_MODE_FULL : wmpb.NodeMode.NODE_MODE_LIGHT;
    _onDataDirPage = widget.dataDirFirst;
    _dataDir.addListener(_onChange);
  }

  @override
  void dispose() {
    _dataDir.removeListener(_onChange);
    _dataDir.dispose();
    super.dispose();
  }

  void _onChange() {
    if (mounted) {
      setState(() {});
    }
  }

  bool get _toFull => _selected == wmpb.NodeMode.NODE_MODE_FULL;

  Future<void> _confirm() async {
    if (_toFull && fullModeNeedsDataDir(_conf)) {
      setState(() {
        _error = null;
        _onDataDirPage = true;
      });
      return;
    }
    // A Bitcoin Core wallet reads its balance from the local node, and light
    // mode stops that node.
    if (!_toFull && !(GetIt.I.get<WalletReaderProvider>().activeWallet?.isElectrum ?? true)) {
      setState(() {
        _error =
            'Your active wallet is served by Bitcoin Core, which light mode stops. '
            'Switch to an electrum wallet first.';
      });
      return;
    }
    await _switch();
  }

  Future<void> _continueWithDataDir() async {
    setState(() => _switching = true);
    final saved = await _dataDir.save(_conf.network);
    if (!saved) {
      if (mounted) {
        setState(() => _switching = false);
      }
      return;
    }
    await _switch();
  }

  Future<void> _switch() async {
    setState(() {
      _switching = true;
      _error = null;
    });
    try {
      await _nodeMode.select(_selected);
    } catch (e) {
      if (mounted) {
        setState(() {
          _switching = false;
          _error = '$e';
        });
      }
      return;
    }
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: Padding(
        padding: const EdgeInsets.all(SailStyleValues.padding16),
        child: _onDataDirPage ? _dataDirPage(context) : _modePage(context),
      ),
    );
  }

  Widget _modePage(BuildContext context) {
    final theme = SailTheme.of(context);
    final String label;
    if (!_toFull) {
      label = 'Switch to light mode';
    } else if (fullModeNeedsDataDir(_conf)) {
      label = 'Confirm node mode';
    } else {
      label = 'Switch to full mode';
    }
    final current = _toFull ? _nodeMode.isFull : _nodeMode.isLight;
    return SailColumn(
      spacing: SailStyleValues.padding12,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.primary15('Node mode', bold: true),
        if (_nodeMode.lightModeAvailable)
          NodeModeCard(
            label: 'Light',
            description: _nodeMode.remoteEnforcerAvailable && _nodeMode.localBuildsAvailable
                ? 'Runs sidechain daemons on this machine with a remote enforcer. '
                      'Your Bitcoin wallet uses Electrum. No Bitcoin Core download.'
                : 'Your Bitcoin wallet uses Electrum. No Bitcoin Core download.',
            selected: !_toFull,
            onTap: () => setState(() {
              _selected = wmpb.NodeMode.NODE_MODE_LIGHT;
              _error = null;
            }),
          ),
        if (_nodeMode.localBuildsAvailable)
          NodeModeCard(
            label: 'Full node',
            description:
                'Runs Bitcoin Core, the enforcer, and sidechain daemons on this machine. '
                'Bitcoin sync takes hours and hundreds of gigabytes of disk.',
            selected: _toFull,
            onTap: () => setState(() {
              _selected = wmpb.NodeMode.NODE_MODE_FULL;
              _error = null;
            }),
          ),
        if (_error != null) SailText.secondary12(_error!, color: theme.colors.error),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SailButton(
              label: label,
              loading: _switching,
              disabled: current,
              onPressed: _confirm,
            ),
          ],
        ),
      ],
    );
  }

  Widget _dataDirPage(BuildContext context) {
    final theme = SailTheme.of(context);
    final chosen = _dataDir.selectedPath;
    return SailColumn(
      spacing: SailStyleValues.padding12,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SailButton(
              variant: ButtonVariant.icon,
              icon: SailSVGAsset.chevronLeft,
              iconHeight: 14,
              iconWidth: 14,
              small: true,
              disabled: _switching,
              onPressed: () async => setState(() => _onDataDirPage = false),
            ),
            const SizedBox(width: 8),
            Expanded(child: SailText.primary15('Configure Data Directory', bold: true)),
          ],
        ),
        SailText.secondary13(
          '${_conf.network.toDisplayName()} requires a data directory to store blockchain data.\n'
          'This will require significant disk space (700GB+ for mainnet).',
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colors.border),
            borderRadius: SailStyleValues.borderRadiusSmall,
          ),
          child: Row(
            children: [
              Expanded(child: SailText.secondary13(chosen ?? 'No directory selected')),
              const SizedBox(width: 16),
              SailButton(
                label: 'Browse',
                variant: chosen == null ? ButtonVariant.primary : ButtonVariant.secondary,
                loading: _dataDir.selecting,
                disabled: _switching,
                onPressed: _dataDir.browse,
              ),
            ],
          ),
        ),
        if (_dataDir.error != null) SailText.secondary12(_dataDir.error!, color: theme.colors.error),
        if (_error != null) SailText.secondary12(_error!, color: theme.colors.error),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SailButton(
              label: 'Continue',
              loading: _switching,
              disabled: chosen == null,
              onPressed: _continueWithDataDir,
            ),
          ],
        ),
      ],
    );
  }
}

class NodeModeCard extends StatelessWidget {
  final String label;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  const NodeModeCard({
    super.key,
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
        width: double.infinity,
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
