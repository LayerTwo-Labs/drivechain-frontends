import 'dart:async';

import 'package:bitwindow/providers/fork_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

/// Mounts the [ForkCountdownTimer] above [child] and scrolls it out of the way:
/// scrolling the page down collapses the timer, returning to the top reveals it
/// again. Listens to scroll notifications bubbling up from whatever page is
/// active, so it works on every tab without per-page wiring.
class ForkCountdownHeader extends StatefulWidget {
  const ForkCountdownHeader({super.key, required this.child});
  final Widget child;

  @override
  State<ForkCountdownHeader> createState() => _ForkCountdownHeaderState();
}

class _ForkCountdownHeaderState extends State<ForkCountdownHeader> {
  bool _collapsed = false;

  bool _onScroll(ScrollNotification n) {
    if (n.metrics.axis != Axis.vertical) return false;
    final atTop = n.metrics.pixels <= 8;
    if (atTop && _collapsed) {
      setState(() => _collapsed = false);
    } else if (!atTop && !_collapsed && n is ScrollUpdateNotification && (n.scrollDelta ?? 0) > 0) {
      setState(() => _collapsed = true);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: _collapsed ? const SizedBox(width: double.infinity) : const ForkCountdownTimer(),
        ),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: widget.child,
          ),
        ),
      ],
    );
  }
}

/// "HARDFORK ACTIVATION · T MINUS" countdown, in the style of ecash.com.
/// Visible on every page while the fork is still ahead. The target instant is
/// held stable by [ForkProvider] (re-anchored only every 10 blocks); this
/// widget just ticks the local clock down to it once a second, so DAYS : HOURS
/// : MIN : SEC counts smoothly rather than jumping a block-interval at a time.
class ForkCountdownTimer extends StatefulWidget {
  const ForkCountdownTimer({super.key});

  @override
  State<ForkCountdownTimer> createState() => _ForkCountdownTimerState();
}

class _ForkCountdownTimerState extends State<ForkCountdownTimer> {
  ForkProvider get _fork => GetIt.I<ForkProvider>();
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _fork,
      builder: (context, _) {
        final target = _fork.forkTargetDate;
        if (!_fork.showCountdown || target == null) return const SizedBox.shrink();

        final theme = SailTheme.of(context);
        var remaining = target.difference(DateTime.now());
        if (remaining.isNegative) remaining = Duration.zero;

        final days = remaining.inDays;
        final hours = remaining.inHours % 24;
        final minutes = remaining.inMinutes % 60;
        final seconds = remaining.inSeconds % 60;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SailText.secondary12('HARDFORK ACTIVATION · T MINUS', color: theme.colors.textSecondary),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _unit(theme, days.toString(), 'DAYS'),
                  _separator(theme),
                  _unit(theme, hours.toString().padLeft(2, '0'), 'HOURS'),
                  _separator(theme),
                  _unit(theme, minutes.toString().padLeft(2, '0'), 'MIN'),
                  _separator(theme),
                  _unit(theme, seconds.toString().padLeft(2, '0'), 'SEC'),
                ],
              ),
              const SizedBox(height: 12),
              _footer(theme, target),
            ],
          ),
        );
      },
    );
  }

  Widget _unit(SailThemeData theme, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 56,
            height: 1.0,
            fontWeight: FontWeight.w700,
            color: theme.colors.text,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 4),
        SailText.secondary12(label, color: theme.colors.textSecondary),
      ],
    );
  }

  Widget _separator(SailThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        ':',
        style: TextStyle(fontSize: 48, height: 1.0, fontWeight: FontWeight.w700, color: theme.colors.orange),
      ),
    );
  }

  static const _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  Widget _footer(SailThemeData theme, DateTime target) {
    final utc = target.toUtc();
    final month = _monthNames[utc.month - 1];
    // Year is omitted unless the fork lands in a different year than now.
    final date = utc.year == DateTime.now().year ? '$month ${utc.day}' : '$month ${utc.day}, ${utc.year}';
    final time = '${_two(utc.hour)}:${_two(utc.minute)}';
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SailText.secondary13(date, color: theme.colors.textSecondary),
        _divider(theme),
        SailText.secondary13(time, color: theme.colors.textSecondary),
        _divider(theme),
        SailText.secondary13('BLOCK ~${_grouped(_fork.forkHeight)}', color: theme.colors.orange),
      ],
    );
  }

  Widget _divider(SailThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(width: 1, height: 14, color: theme.colors.divider),
    );
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  String _grouped(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
