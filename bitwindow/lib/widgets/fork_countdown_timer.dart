import 'package:bitwindow/providers/fork_provider.dart';
import 'package:bitwindow/utils/second_clock.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

/// The strip label, for example "ECASH HARDFORK · IN 10 BLOCKS".
String forkStripLabel(String networkName, int blocksLeft) {
  final fork = networkName.isEmpty ? 'HARDFORK' : '${networkName.toUpperCase()} HARDFORK';
  return '$fork · IN $blocksLeft ${blocksLeft == 1 ? 'BLOCK' : 'BLOCKS'}';
}

/// Pins the [ForkCountdownTimer] strip above [child] on every tab. The strip is
/// a thin sliver, so it stays put rather than collapsing on scroll; it hides
/// itself entirely (via [ForkCountdownTimer]) when there's no fork ahead.
class ForkCountdownHeader extends StatelessWidget {
  const ForkCountdownHeader({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ForkCountdownTimer(),
        Expanded(child: child),
      ],
    );
  }
}

/// "HARDFORK · IN N BLOCKS" countdown, rendered as a single-line status strip.
/// Visible on every page while the fork is still ahead. The target instant is
/// held stable by [ForkProvider] (re-anchored only every 10 blocks); this
/// widget just ticks the local clock down to it once a second, so the
/// d HH:MM:SS counts smoothly rather than jumping a block-interval at a time.
class ForkCountdownTimer extends StatelessWidget {
  const ForkCountdownTimer({super.key});

  ForkProvider get _fork => GetIt.I<ForkProvider>();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _fork,
      builder: (context, _) {
        final target = _fork.forkTargetDate;
        if (!_fork.showCountdown || target == null) {
          return const SizedBox.shrink();
        }

        final theme = SailTheme.of(context);
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: theme.colors.orange.withValues(alpha: 0.08),
            border: Border(bottom: BorderSide(color: theme.colors.divider)),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(color: theme.colors.orange, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                SailText.secondary12(
                  forkStripLabel(_fork.networkName, _fork.blocksUntilFork),
                  bold: true,
                  color: theme.colors.textSecondary,
                ),
                const SizedBox(width: 10),
                _Countdown(target: target),
                const SizedBox(width: 10),
                _divider(theme),
                const SizedBox(width: 10),
                SailText.secondary12('BLOCK ~${_grouped(_fork.forkHeight)}', color: theme.colors.orange),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _divider(SailThemeData theme) {
    return Container(width: 1, height: 12, color: theme.colors.divider);
  }

  String _grouped(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) {
        buf.write(',');
      }
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

/// The d HH:MM:SS to [target]. Only this text rebuilds each second.
class _Countdown extends StatefulWidget {
  final DateTime target;

  const _Countdown({required this.target});

  @override
  State<_Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<_Countdown> {
  @override
  void initState() {
    super.initState();
    SecondClock.shared.addListener(_tick);
  }

  @override
  void dispose() {
    SecondClock.shared.removeListener(_tick);
    super.dispose();
  }

  void _tick() => setState(() {});

  String _two(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    var remaining = widget.target.difference(DateTime.now());
    if (remaining.isNegative) {
      remaining = Duration.zero;
    }

    final hms = '${_two(remaining.inHours % 24)}:${_two(remaining.inMinutes % 60)}:${_two(remaining.inSeconds % 60)}';
    final countdown = remaining.inDays > 0 ? '${remaining.inDays}d $hms' : hms;

    return Text(
      countdown,
      style: TextStyle(
        fontSize: 13,
        height: 1.0,
        fontWeight: FontWeight.w700,
        color: SailTheme.of(context).colors.text,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
