import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

enum SailToastVariant { defaultVariant, destructive, warning, info, success }

enum SailToastPosition { topRight, bottomRight, topLeft, bottomLeft }

class SailToastAction {
  final String label;
  final VoidCallback onPressed;

  const SailToastAction({required this.label, required this.onPressed});
}

void showSailToast(
  BuildContext context,
  String message, {
  SailToastVariant variant = SailToastVariant.defaultVariant,
  SailToastAction? action,
  Duration duration = const Duration(seconds: 4),
  SailToastPosition position = SailToastPosition.topRight,
}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;
  _SailToastHost.of(overlay).enqueue(
    _SailToastSpec(
      message: message,
      variant: variant,
      action: action,
      duration: duration,
      position: position,
    ),
  );
}

class _SailToastSpec {
  final String message;
  final SailToastVariant variant;
  final SailToastAction? action;
  final Duration duration;
  final SailToastPosition position;

  _SailToastSpec({
    required this.message,
    required this.variant,
    required this.action,
    required this.duration,
    required this.position,
  });
}

class _SailToastHost {
  final OverlayState overlay;
  final List<_SailToastEntry> _entries = [];
  OverlayEntry? _overlayEntry;
  final ValueNotifier<int> _tick = ValueNotifier<int>(0);

  static final Expando<_SailToastHost> _hosts = Expando<_SailToastHost>();

  _SailToastHost._(this.overlay);

  static _SailToastHost of(OverlayState overlay) {
    final existing = _hosts[overlay];
    if (existing != null) return existing;
    final host = _SailToastHost._(overlay);
    _hosts[overlay] = host;
    return host;
  }

  void enqueue(_SailToastSpec spec) {
    final entry = _SailToastEntry(spec: spec, host: this);
    _entries.add(entry);
    _ensureOverlay();
    _tick.value++;
    entry.start();
  }

  void remove(_SailToastEntry entry) {
    _entries.remove(entry);
    if (_entries.isEmpty) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    } else {
      _tick.value++;
    }
  }

  void _ensureOverlay() {
    if (_overlayEntry != null) return;
    _overlayEntry = OverlayEntry(
      builder: (ctx) {
        return Positioned.fill(
          child: ValueListenableBuilder<int>(
            valueListenable: _tick,
            builder: (_, _, _) {
              return _ToastStack(entries: List.of(_entries));
            },
          ),
        );
      },
    );
    overlay.insert(_overlayEntry!);
  }
}

class _SailToastEntry {
  final _SailToastSpec spec;
  final _SailToastHost host;
  Timer? _timer;
  final ValueNotifier<bool> visible = ValueNotifier<bool>(false);

  _SailToastEntry({required this.spec, required this.host});

  void start() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      visible.value = true;
    });
    _timer = Timer(spec.duration, dismiss);
  }

  void dismiss() {
    _timer?.cancel();
    if (!visible.value) {
      host.remove(this);
      return;
    }
    visible.value = false;
    Future.delayed(const Duration(milliseconds: 220), () {
      host.remove(this);
    });
  }
}

class _ToastStack extends StatelessWidget {
  final List<_SailToastEntry> entries;
  const _ToastStack({required this.entries});

  @override
  Widget build(BuildContext context) {
    final groups = <SailToastPosition, List<_SailToastEntry>>{};
    for (final e in entries) {
      groups.putIfAbsent(e.spec.position, () => []).add(e);
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        for (final entry in groups.entries)
          _PositionedToastColumn(
            position: entry.key,
            children: entry.value.map((e) => _ToastCard(key: ObjectKey(e), entry: e)).toList(),
          ),
      ],
    );
  }
}

class _PositionedToastColumn extends StatelessWidget {
  final SailToastPosition position;
  final List<Widget> children;

  const _PositionedToastColumn({
    required this.position,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    const inset = 16.0;
    final isTop = position == SailToastPosition.topRight || position == SailToastPosition.topLeft;
    final isRight = position == SailToastPosition.topRight || position == SailToastPosition.bottomRight;
    return Positioned(
      top: isTop ? inset : null,
      bottom: isTop ? null : inset,
      right: isRight ? inset : null,
      left: isRight ? null : inset,
      child: Column(
        crossAxisAlignment: isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _ToastCard extends StatefulWidget {
  final _SailToastEntry entry;
  const _ToastCard({super.key, required this.entry});

  @override
  State<_ToastCard> createState() => _ToastCardState();
}

class _ToastCardState extends State<_ToastCard> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    final fromRight =
        widget.entry.spec.position == SailToastPosition.topRight ||
        widget.entry.spec.position == SailToastPosition.bottomRight;
    _slide = Tween<Offset>(
      begin: Offset(fromRight ? 0.4 : -0.4, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    widget.entry.visible.addListener(_sync);
    _sync();
  }

  void _sync() {
    if (!mounted) return;
    if (widget.entry.visible.value) {
      _ctrl.forward();
    } else {
      _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    widget.entry.visible.removeListener(_sync);
    _ctrl.dispose();
    super.dispose();
  }

  Color _foreground(SailThemeData theme) {
    switch (widget.entry.spec.variant) {
      case SailToastVariant.destructive:
        return theme.colors.error;
      case SailToastVariant.warning:
        return theme.colors.orange;
      case SailToastVariant.info:
        return theme.colors.info;
      case SailToastVariant.success:
        return theme.colors.success;
      case SailToastVariant.defaultVariant:
        return theme.colors.text;
    }
  }

  Color _border(SailThemeData theme) {
    switch (widget.entry.spec.variant) {
      case SailToastVariant.destructive:
        return theme.colors.error;
      case SailToastVariant.warning:
        return theme.colors.orange;
      case SailToastVariant.info:
        return theme.colors.info;
      case SailToastVariant.success:
        return theme.colors.success;
      case SailToastVariant.defaultVariant:
        return theme.colors.border;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final fg = _foreground(theme);

    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: SizedBox(
          width: 320,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colors.popoverBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _border(theme)),
              boxShadow: [
                BoxShadow(
                  color: theme.colors.shadow,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    widget.entry.spec.message,
                    style: SailStyleValues.thirteen.copyWith(color: fg),
                  ),
                ),
                if (widget.entry.spec.action != null) ...[
                  const SizedBox(width: 12),
                  _ToastActionButton(
                    label: widget.entry.spec.action!.label,
                    color: fg,
                    onPressed: () {
                      widget.entry.spec.action!.onPressed();
                      widget.entry.dismiss();
                    },
                  ),
                ],
                const SizedBox(width: 8),
                _ToastDismissButton(
                  color: theme.colors.textSecondary,
                  onPressed: widget.entry.dismiss,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ToastActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ToastActionButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        child: Text(
          label,
          style: SailStyleValues.thirteen.copyWith(
            color: color,
            fontWeight: SailStyleValues.boldWeight,
          ),
        ),
      ),
    );
  }
}

class _ToastDismissButton extends StatelessWidget {
  final Color color;
  final VoidCallback onPressed;

  const _ToastDismissButton({required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        child: Text(
          String.fromCharCode(0x00D7),
          style: TextStyle(color: color, fontSize: 16),
        ),
      ),
    );
  }
}
