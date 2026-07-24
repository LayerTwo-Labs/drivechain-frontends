import 'package:bitwindow/providers/mining_provider.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

/// Pins the [MiningBanner] strip above [child]; the strip hides itself when
/// mining is unavailable or dismissed.
class MiningBannerHeader extends StatelessWidget {
  const MiningBannerHeader({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const MiningBanner(),
        Expanded(child: child),
      ],
    );
  }
}

/// Drynet-only prompt to start mining. Shown while mining is stopped and not
/// dismissed; tapping opens the miner page, the trailing x dismisses it.
class MiningBanner extends StatefulWidget {
  const MiningBanner({super.key});

  @override
  State<MiningBanner> createState() => _MiningBannerState();
}

class _MiningBannerState extends State<MiningBanner> {
  BitcoinConfProvider get _conf => GetIt.I.get<BitcoinConfProvider>();
  MiningProvider get _mining => GetIt.I.get<MiningProvider>();
  ClientSettings get _settings => GetIt.I.get<ClientSettings>();

  bool _dismissed = true;

  @override
  void initState() {
    super.initState();
    _conf.addListener(_onChange);
    _mining.addListener(_onChange);
    _loadDismissed();
    _mining.refreshStatus();
  }

  @override
  void dispose() {
    _conf.removeListener(_onChange);
    _mining.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  Future<void> _loadDismissed() async {
    final setting = await _settings.getValue(MiningBannerDismissedSetting());
    if (mounted) setState(() => _dismissed = setting.value);
  }

  Future<void> _dismiss() async {
    await _settings.setValue(MiningBannerDismissedSetting().withValue(true));
    if (mounted) setState(() => _dismissed = true);
  }

  bool get _onDrynet => _conf.network == BitcoinNetwork.BITCOIN_NETWORK_DRYNET;

  @override
  Widget build(BuildContext context) {
    if (!_onDrynet || _dismissed || _mining.isMining) return const SizedBox.shrink();

    final theme = SailTheme.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => GetIt.I.get<AppRouter>().push(CpuMiningRoute()),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: theme.colors.orange.withValues(alpha: 0.08),
          border: Border(bottom: BorderSide(color: theme.colors.divider)),
        ),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: theme.colors.orange, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            SailText.secondary12('You can mine blocks on drynet', bold: true, color: theme.colors.text),
            const SizedBox(width: 10),
            SailText.secondary12('Start mining now →', color: theme.colors.orange),
            const Spacer(),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _dismiss,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: SailText.secondary13('✕', color: theme.colors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
