import 'dart:async';

/// Holds back the timers of a hidden sub-window engine. Run the engine in a
/// zone with [zoneSpecification].
class HiddenWindowTimers {
  HiddenWindowTimers({DateTime Function()? now}) : _now = now ?? DateTime.now;

  final DateTime Function() _now;
  final Set<_GatedTimer> _live = {};
  bool _paused = false;

  bool get paused => _paused;

  ZoneSpecification get zoneSpecification => ZoneSpecification(
    createTimer: (self, parent, zone, duration, f) => _GatedTimer.oneShot(this, parent, zone, duration, f),
    createPeriodicTimer: (self, parent, zone, period, f) => _GatedTimer.periodic(this, parent, zone, period, f),
  );

  /// Stops every timer of the zone. A timer that the zone makes while paused
  /// does not start.
  void pause() {
    _paused = true;
    for (final timer in _live) {
      timer._stop();
    }
  }

  /// Lets new timers run. The timers that [pause] stopped wait for [runMissed].
  void resume() {
    _paused = false;
  }

  /// Starts the stopped timers again. A timer that came due while stopped
  /// runs at once, one time.
  void runMissed() {
    if (_paused) {
      return;
    }
    for (final timer in List.of(_live)) {
      timer._restart();
    }
  }
}

class _GatedTimer implements Timer {
  _GatedTimer.oneShot(this._gate, this._parent, this._zone, Duration duration, void Function() f)
    : _period = null,
      _oneShot = f,
      _periodic = null {
    _gate._live.add(this);
    _arm(duration);
  }

  _GatedTimer.periodic(this._gate, this._parent, this._zone, Duration period, void Function(Timer) f)
    : _period = period,
      _oneShot = null,
      _periodic = f {
    _gate._live.add(this);
    _arm(period);
  }

  final HiddenWindowTimers _gate;
  final ZoneDelegate _parent;
  final Zone _zone;
  final Duration? _period;
  final void Function()? _oneShot;
  final void Function(Timer)? _periodic;

  Timer? _inner;
  late DateTime _due;
  int _tick = 0;

  void _arm(Duration wait) {
    _due = _gate._now().add(wait);
    if (_gate._paused) {
      return;
    }
    final period = _period;
    _inner = period == null
        ? _parent.createTimer(_zone, wait, _fire)
        : wait == period
        ? _parent.createPeriodicTimer(_zone, period, (_) => _fire())
        : _parent.createTimer(_zone, wait, () {
            _fire();
            if (isActive) {
              _inner = _parent.createPeriodicTimer(_zone, period, (_) => _fire());
            }
          });
  }

  void _fire() {
    final periodic = _periodic;
    if (periodic == null) {
      _inner = null;
      _gate._live.remove(this);
      _oneShot!();
      return;
    }
    _tick++;
    _due = _gate._now().add(_period!);
    periodic(this);
  }

  void _stop() {
    _inner?.cancel();
    _inner = null;
  }

  void _restart() {
    if (_inner != null || !isActive) {
      return;
    }
    final left = _due.difference(_gate._now());
    if (!left.isNegative && left != Duration.zero) {
      _arm(left);
      return;
    }
    if (_period == null) {
      _fire();
      return;
    }
    _fire();
    if (isActive) {
      _arm(_period);
    }
  }

  @override
  bool get isActive => _gate._live.contains(this);

  @override
  int get tick => _period == null ? (isActive ? 0 : 1) : _tick;

  @override
  void cancel() {
    _stop();
    _gate._live.remove(this);
  }
}
