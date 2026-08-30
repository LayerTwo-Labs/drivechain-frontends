import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

class SettingsNodeMode extends StatefulWidget {
  const SettingsNodeMode({super.key});

  @override
  State<SettingsNodeMode> createState() => _SettingsNodeModeState();
}

class _SettingsNodeModeState extends State<SettingsNodeMode> {
  NodeModeProvider get _nodeMode => GetIt.I.get<NodeModeProvider>();
  bool _switching = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nodeMode.addListener(setstate);
  }

  @override
  void dispose() {
    _nodeMode.removeListener(setstate);
    super.dispose();
  }

  void setstate() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _switchTo(wmpb.NodeMode next) async {
    // A Bitcoin Core wallet reads its balance from the local node. Light mode
    // stops that node, so the wallet would go dark with no way to spend.
    if (next == wmpb.NodeMode.NODE_MODE_LIGHT && _activeWalletNeedsCore) {
      setState(() {
        _error =
            'Your active wallet is served by Bitcoin Core, which light mode stops. '
            'Switch to an electrum wallet first.';
      });
      return;
    }

    // The side navigation stays live through the awaits below, so this page can
    // go away mid-transition. The router outlives it, and a half-applied mode
    // leaves full mode written with no directory and no daemons.
    final router = context.router;

    final confirmed = await _confirm(next);
    if (!confirmed) {
      return;
    }

    setState(() {
      _switching = true;
      _error = null;
    });
    try {
      await _nodeMode.select(next);
      // select() starts nothing while the network has no data directory, and
      // the route guards never re-run for a page already on screen. So this
      // toggle walks the same path the guard does.
      if (next == wmpb.NodeMode.NODE_MODE_FULL) {
        final ready = await ensureDataDirThenStartBackends(router);
        if (!ready) {
          // select() already wrote full mode, so a toggle left on here would
          // read as full mode with every local daemon down.
          await _nodeMode.select(wmpb.NodeMode.NODE_MODE_LIGHT);
          _showError('Full mode stores the chain on disk, so it needs a data directory.');
        }
      }
    } catch (e) {
      _showError('$e');
    } finally {
      if (mounted) {
        setState(() => _switching = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }
    setState(() => _error = message);
  }

  /// True when the active wallet reads its chain from the local node.
  bool get _activeWalletNeedsCore {
    final active = GetIt.I.get<WalletReaderProvider>().activeWallet;
    return active != null && !active.isElectrum;
  }

  Future<bool> _confirm(wmpb.NodeMode next) async {
    final toFull = next == wmpb.NodeMode.NODE_MODE_FULL;
    return await widgetDialog<bool>(
          context: context,
          title: toFull ? 'Switch to full mode' : 'Switch to light mode',
          child: Builder(
            builder: (ctx) => SailColumn(
              spacing: SailStyleValues.padding16,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SailText.secondary13(
                  toFull
                      ? 'BitWindow downloads Bitcoin Core and the enforcer, then syncs the chain. '
                            'That takes hours and hundreds of gigabytes. You can leave this page while it runs.'
                      : 'BitWindow stops the local node and reads the chain from a remote server. '
                            'Your chain data stays on disk, so a switch back does not sync from the start.',
                ),
                SailText.secondary13('No wallet and no key is deleted.'),
                SailRow(
                  spacing: SailStyleValues.padding08,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SailButton(
                      label: 'Cancel',
                      variant: ButtonVariant.ghost,
                      onPressed: () async => Navigator.of(ctx).pop(false),
                    ),
                    SailButton(label: 'Switch', onPressed: () async => Navigator.of(ctx).pop(true)),
                  ],
                ),
              ],
            ),
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final isFull = _nodeMode.isFull;

    return SailColumn(
      spacing: SailStyleValues.padding16,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailSettingsGroup(
          title: 'Node mode',
          description: 'Full mode runs Bitcoin on this machine. Light mode reads it from a remote server.',
          children: [
            SailSettingsRow(
              label: 'Full mode',
              description: 'If enabled, gives you sidechains and mining. Needs 1TB of disk.',
              trailing: _ModeToggle(
                value: isFull,
                // The row below says light mode is unavailable here, so the
                // toggle must not offer a switch the backend refuses.
                enabled: _nodeMode.lightModeAvailable && !_switching,
                onChanged: (on) => _switchTo(
                  on ? wmpb.NodeMode.NODE_MODE_FULL : wmpb.NodeMode.NODE_MODE_LIGHT,
                ),
              ),
            ),
            if (!_nodeMode.lightModeAvailable)
              SailSettingsRow(
                label: 'Light mode is unavailable here',
                description: 'This network serves no remote chain server, so it runs full mode only.',
              ),
            if (_error != null)
              SailSettingsRow(
                label: 'Could not switch',
                description: _error,
                descriptionColor: SailTheme.of(context).colors.error,
              ),
          ],
        ),
      ],
    );
  }
}

class _ModeToggle extends StatelessWidget {
  final bool value;
  final bool enabled;
  final ValueSetter<bool> onChanged;

  const _ModeToggle({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: IgnorePointer(
        ignoring: !enabled,
        child: SailToggle(value: value, onChanged: onChanged),
      ),
    );
  }
}
