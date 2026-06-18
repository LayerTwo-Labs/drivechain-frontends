import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:window_manager/window_manager.dart';

class CrossPlatformMenuBar extends StatelessWidget {
  final List<PlatformMenuItem> menus;
  final Widget child;

  const CrossPlatformMenuBar({
    super.key,
    required this.menus,
    required this.child,
  });

  /// PlatformMenuBar replaces the entire native macOS menu bar, dropping the
  /// system Edit menu that delivers Cmd+X/C/V/A to text fields. Re-add one
  /// that dispatches the standard text-editing intents to the focused widget.
  static List<PlatformMenuItem> _withEditMenu(List<PlatformMenuItem> menus) {
    final edit = PlatformMenu(
      label: 'Edit',
      menus: [
        PlatformMenuItemGroup(
          members: [
            _editMenuItem('Undo', LogicalKeyboardKey.keyZ, const UndoTextIntent(SelectionChangedCause.keyboard)),
            _editMenuItem(
              'Redo',
              LogicalKeyboardKey.keyZ,
              const RedoTextIntent(SelectionChangedCause.keyboard),
              shift: true,
            ),
          ],
        ),
        PlatformMenuItemGroup(
          members: [
            _editMenuItem(
              'Cut',
              LogicalKeyboardKey.keyX,
              const CopySelectionTextIntent.cut(SelectionChangedCause.keyboard),
            ),
            _editMenuItem('Copy', LogicalKeyboardKey.keyC, CopySelectionTextIntent.copy),
            _editMenuItem('Paste', LogicalKeyboardKey.keyV, const PasteTextIntent(SelectionChangedCause.keyboard)),
            _editMenuItem(
              'Select All',
              LogicalKeyboardKey.keyA,
              const SelectAllTextIntent(SelectionChangedCause.keyboard),
            ),
          ],
        ),
      ],
    );
    return [if (menus.isNotEmpty) menus.first, edit, ...menus.skip(1)];
  }

  static PlatformMenuItem _editMenuItem(String label, LogicalKeyboardKey key, Intent intent, {bool shift = false}) {
    return PlatformMenuItem(
      label: label,
      shortcut: SingleActivator(key, meta: true, shift: shift),
      onSelected: () async {
        // The menu bar is app-wide but onSelected runs in this engine. When a
        // sub-window is key, dispatching here would edit a hidden field.
        if (!await windowManager.isFocused()) return;
        final context = primaryFocus?.context;
        if (context != null && context.mounted) Actions.maybeInvoke(context, intent);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isMacOS) {
      return PlatformMenuBar(menus: _withEditMenu(menus), child: child);
    }

    return _CustomMenuBar(menus: menus, child: child);
  }
}

// _CustomMenuBar renders the top menu bar on Linux/Windows (macOS uses the
// native PlatformMenuBar). It owns a _MenuAimController so an open dropdown
// isn't stolen by a sibling button while the pointer moves diagonally toward
// it — the "safety triangle" / menu-aim behaviour.
class _CustomMenuBar extends StatefulWidget {
  final List<PlatformMenuItem> menus;
  final Widget child;

  const _CustomMenuBar({required this.menus, required this.child});

  @override
  State<_CustomMenuBar> createState() => _CustomMenuBarState();
}

class _CustomMenuBarState extends State<_CustomMenuBar> {
  final _MenuAimController _aim = _MenuAimController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MouseRegion(
          onHover: (event) => _aim.updatePointer(event.position),
          child: Container(
            color: context.sailTheme.colors.background,
            height: 28,
            child: Row(
              children: [
                const SizedBox(width: 8),
                for (final menu in widget.menus)
                  if (menu is PlatformMenu) ...[
                    _MenuButton(menu: menu, aim: _aim),
                    const SizedBox(width: 4),
                  ],
              ],
            ),
          ),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}

// _MenuAimController coordinates hover-opening across the sibling _MenuButtons.
// When a dropdown is open and the pointer is moving toward it, hovering a
// neighbouring button is deferred instead of immediately switching menus, so a
// diagonal path into the open dropdown doesn't snap it shut.
class _MenuAimController {
  // Lift the cone's base slightly above the panel so pointer samples in the gap
  // between the bar and the dropdown still count as "aiming".
  static const double _edgeTolerance = 6;
  // Movement below this (logical px between samples) reads as "stopped", which
  // ends the aim gesture so a rested-on sibling opens.
  static const double _moveThreshold = 2.5;

  Object? _openId;
  Rect? _openRect;
  Offset? _loc;
  Offset? _prevLoc;

  Object? _pendingId;
  Rect? _pendingButtonRect;
  VoidCallback? _pendingOpen;

  void updatePointer(Offset position) {
    _prevLoc = _loc ?? position;
    _loc = position;
    _maybeReleasePending();
  }

  void notifyOpened(Object id, Rect panelRect) {
    _openId = id;
    _openRect = panelRect;
  }

  void notifyClosed(Object id) {
    if (_openId == id) {
      _openId = null;
      _openRect = null;
    }
    if (_pendingId == id) _clearPending();
  }

  // Decide whether a freshly-hovered button may open now. If another dropdown
  // is open and the pointer is aiming at it, defer until the aim gesture ends;
  // otherwise open immediately.
  void requestOpen({required Object id, required Rect buttonRect, required VoidCallback open}) {
    if (_openId == null || _openId == id || !_isAiming()) {
      open();
      return;
    }
    _pendingId = id;
    _pendingButtonRect = buttonRect;
    _pendingOpen = open;
  }

  void cancelRequest(Object id) {
    if (_pendingId == id) _clearPending();
  }

  void _maybeReleasePending() {
    final rect = _pendingButtonRect;
    final loc = _loc;
    if (_pendingId == null || rect == null || loc == null) return;
    if (!rect.contains(loc)) {
      _clearPending(); // pointer left the pending button — it was a pass-through
      return;
    }
    if (!_isAiming()) {
      final open = _pendingOpen;
      _clearPending();
      open?.call(); // aim gesture ended over the button — open it
    }
  }

  void _clearPending() {
    _pendingId = null;
    _pendingButtonRect = null;
    _pendingOpen = null;
  }

  // True when the pointer is moving into the triangle whose apex is the prior
  // pointer sample and whose base is the open dropdown's near (top) edge.
  bool _isAiming() {
    final rect = _openRect;
    final loc = _loc;
    final prev = _prevLoc;
    if (rect == null || rect.isEmpty || loc == null || prev == null) return false;
    if ((loc - prev).distance < _moveThreshold) return false;
    final base = rect.top - _edgeTolerance;
    return _pointInTriangle(loc, prev, Offset(rect.left, base), Offset(rect.right, base));
  }

  static bool _pointInTriangle(Offset p, Offset a, Offset b, Offset c) {
    double cross(Offset u, Offset v, Offset w) => (u.dx - w.dx) * (v.dy - w.dy) - (v.dx - w.dx) * (u.dy - w.dy);
    final d1 = cross(p, a, b);
    final d2 = cross(p, b, c);
    final d3 = cross(p, c, a);
    final hasNeg = d1 < 0 || d2 < 0 || d3 < 0;
    final hasPos = d1 > 0 || d2 > 0 || d3 > 0;
    return !(hasNeg && hasPos);
  }
}

class _MenuButton extends StatefulWidget {
  final PlatformMenu menu;
  final _MenuAimController aim;

  const _MenuButton({required this.menu, required this.aim});

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton> {
  late final MenuController _controller;
  final GlobalKey _menuKey = GlobalKey();
  bool _isInButton = false;
  bool _isInMenu = false;

  @override
  void initState() {
    super.initState();
    _controller = MenuController();
  }

  void _checkShouldClose() {
    // Add delay to make menu more forgiving when moving between areas
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted && !_isInButton && !_isInMenu) {
        _close();
      }
    });
  }

  void _open() {
    if (!_controller.isOpen) _controller.open();
    // Capture the dropdown's rect once it has laid out so the aim controller
    // can test the safety triangle against it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.aim.notifyOpened(this, _panelRect());
    });
  }

  void _close() {
    if (_controller.isOpen) _controller.close();
    widget.aim.notifyClosed(this);
  }

  Rect _panelRect() {
    final box = _menuKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return Rect.zero;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  Rect _buttonRect() {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return Rect.zero;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() {
        _isInButton = true;
        widget.aim.requestOpen(id: this, buttonRect: _buttonRect(), open: _open);
      }),
      onExit: (_) => setState(() {
        _isInButton = false;
        widget.aim.cancelRequest(this);
        _checkShouldClose();
      }),
      child: MenuAnchor(
        controller: _controller,
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(
            context.sailTheme.colors.background,
          ),
          padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        ),
        builder: (context, controller, child) {
          return TextButton(
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              backgroundColor: controller.isOpen ? context.sailTheme.colors.backgroundSecondary : Colors.transparent,
            ),
            onPressed: () {
              if (controller.isOpen) {
                _close();
              } else {
                _open();
              }
            },
            child: SailText.primary13(widget.menu.label),
          );
        },
        menuChildren: [
          MouseRegion(
            onEnter: (_) {
              setState(() => _isInMenu = true);
              // Refresh the rect now that the panel is laid out, so later aim
              // decisions use accurate bounds.
              widget.aim.notifyOpened(this, _panelRect());
            },
            onExit: (_) => setState(() {
              _isInMenu = false;
              _checkShouldClose();
            }),
            child: KeyedSubtree(
              key: _menuKey,
              child: SailMenu(items: _buildMenuItems(context, widget.menu)),
            ),
          ),
        ],
      ),
    );
  }

  List<SailMenuEntity> _buildMenuItems(
    BuildContext context,
    PlatformMenu menu,
  ) {
    final items = <SailMenuEntity>[];

    for (final group in menu.menus) {
      if (group is PlatformMenuItemGroup) {
        items.addAll(_buildMenuGroup(context, group));
        items.add(const SailMenuItemDivider());
      }
    }

    if (items.isNotEmpty && items.last is SailMenuItemDivider) {
      items.removeLast();
    }

    return items;
  }

  List<SailMenuEntity> _buildMenuGroup(
    BuildContext context,
    PlatformMenuItemGroup group,
  ) {
    return group.members.map((item) {
      final bool isEnabled = item.onSelected != null;

      return SailMenuItem(
        onSelected: item.onSelected,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SailText.primary13(
              item.label,
              color: isEnabled ? context.sailTheme.colors.text : context.sailTheme.colors.text.withValues(alpha: 0.3),
            ),
            if (item.shortcut != null)
              SailText.secondary13(
                _getShortcutLabel(item.shortcut!),
                color: isEnabled
                    ? context.sailTheme.colors.textTertiary
                    : context.sailTheme.colors.textTertiary.withValues(
                        alpha: 0.3,
                      ),
              ),
          ],
        ),
      );
    }).toList();
  }

  String _getShortcutLabel(MenuSerializableShortcut shortcut) {
    if (shortcut is SingleActivator) {
      final List<String> keys = [];
      // Shortcuts are authored with `meta: true` for macOS Cmd. macOS hits the
      // native PlatformMenuBar path above, so this branch only runs on
      // Linux/Windows — map meta to Ctrl instead of rendering ⌘.
      if (shortcut.control || shortcut.meta) keys.add('Ctrl');
      if (shortcut.shift) keys.add('Shift');
      if (shortcut.alt) keys.add('Alt');
      keys.add(shortcut.trigger.keyLabel);
      return keys.join('+');
    }
    return '';
  }
}
