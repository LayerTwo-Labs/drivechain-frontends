import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

class SailComboboxItem<T> {
  final T value;
  final String label;
  final String? subtitle;
  final String? searchValue;

  const SailComboboxItem({
    required this.value,
    required this.label,
    this.subtitle,
    this.searchValue,
  });

  String get matchKey => (searchValue ?? label).toLowerCase();
}

class SailCombobox<T> extends StatefulWidget {
  final List<SailComboboxItem<T>> items;
  final T? value;
  final ValueChanged<T> onChanged;
  final String placeholder;
  final String searchPlaceholder;
  final String noResultsText;
  final double? width;
  final double maxPopoverHeight;

  /// Custom match predicate; defaults to substring match on the item's matchKey.
  final bool Function(SailComboboxItem<T> item, String query)? filter;

  const SailCombobox({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.placeholder = 'Select...',
    this.searchPlaceholder = 'Search...',
    this.noResultsText = 'No results.',
    this.width,
    this.maxPopoverHeight = 240,
    this.filter,
  });

  @override
  State<SailCombobox<T>> createState() => _SailComboboxState<T>();
}

class _SailComboboxState<T> extends State<SailCombobox<T>> {
  final SailPopoverController _popover = SailPopoverController();
  final TextEditingController _search = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  int _highlighted = 0;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _popover.addListener(_onPopoverChange);
  }

  @override
  void dispose() {
    _popover.removeListener(_onPopoverChange);
    _popover.dispose();
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onPopoverChange() {
    if (_popover.isOpen) {
      _search.clear();
      _query = '';
      _highlighted = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _searchFocus.requestFocus();
      });
    }
    if (mounted) setState(() {});
  }

  List<SailComboboxItem<T>> get _filtered {
    if (_query.isEmpty) return widget.items;
    final q = _query.toLowerCase();
    if (widget.filter != null) {
      return widget.items.where((i) => widget.filter!(i, q)).toList();
    }
    return widget.items.where((i) => i.matchKey.contains(q)).toList();
  }

  String _displayLabel() {
    if (widget.value == null) return widget.placeholder;
    for (final i in widget.items) {
      if (i.value == widget.value) return i.label;
    }
    return widget.placeholder;
  }

  void _select(SailComboboxItem<T> item) {
    widget.onChanged(item.value);
    _popover.hide();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final filtered = _filtered;
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (filtered.isEmpty) return KeyEventResult.handled;
      setState(() {
        _highlighted = (_highlighted + 1) % filtered.length;
      });
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (filtered.isEmpty) return KeyEventResult.handled;
      setState(() {
        _highlighted = (_highlighted - 1 + filtered.length) % filtered.length;
      });
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      if (filtered.isEmpty) return KeyEventResult.handled;
      if (_highlighted >= 0 && _highlighted < filtered.length) {
        _select(filtered[_highlighted]);
      }
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _popover.hide();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final filtered = _filtered;

    return SailPopover(
      controller: _popover,
      popover: SizedBox(
        width: widget.width ?? 240,
        child: Focus(
          autofocus: true,
          onKeyEvent: _onKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: _SearchField(
                  controller: _search,
                  focusNode: _searchFocus,
                  placeholder: widget.searchPlaceholder,
                  onChanged: (v) {
                    setState(() {
                      _query = v;
                      _highlighted = 0;
                    });
                  },
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: widget.maxPopoverHeight),
                child: filtered.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          widget.noResultsText,
                          style: SailStyleValues.thirteen.copyWith(
                            color: theme.colors.textSecondary,
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        itemCount: filtered.length,
                        itemBuilder: (ctx, i) {
                          final item = filtered[i];
                          final selected = item.value == widget.value;
                          final highlighted = i == _highlighted;
                          return _ComboboxRow(
                            label: item.label,
                            subtitle: item.subtitle,
                            selected: selected,
                            highlighted: highlighted,
                            onTap: () => _select(item),
                            onHover: () => setState(() => _highlighted = i),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      child: Container(
        width: widget.width,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colors.background,
          border: Border.all(color: theme.colors.border),
          borderRadius: theme.chrome.radius,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                _displayLabel(),
                overflow: TextOverflow.ellipsis,
                style: SailStyleValues.thirteen.copyWith(
                  color: widget.value == null ? theme.colors.textSecondary : theme.colors.text,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              String.fromCharCode(0x25BE),
              style: TextStyle(color: theme.colors.textSecondary, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String placeholder;
  final ValueChanged<String> onChanged;

  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.placeholder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: theme.colors.border),
      ),
      child: EditableText(
        controller: controller,
        focusNode: focusNode,
        style: SailStyleValues.thirteen.copyWith(color: theme.colors.text),
        cursorColor: theme.colors.primary,
        backgroundCursorColor: theme.colors.backgroundSecondary,
        onChanged: onChanged,
      ),
    );
  }
}

class _ComboboxRow extends StatefulWidget {
  final String label;
  final String? subtitle;
  final bool selected;
  final bool highlighted;
  final VoidCallback onTap;
  final VoidCallback onHover;

  const _ComboboxRow({
    required this.label,
    this.subtitle,
    required this.selected,
    required this.highlighted,
    required this.onTap,
    required this.onHover,
  });

  @override
  State<_ComboboxRow> createState() => _ComboboxRowState();
}

class _ComboboxRowState extends State<_ComboboxRow> {
  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    return MouseRegion(
      onEnter: (_) => widget.onHover(),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: widget.highlighted ? theme.colors.backgroundSecondary : null,
          child: Row(
            children: [
              SizedBox(
                width: 16,
                child: widget.selected
                    ? Text(
                        String.fromCharCode(0x2713),
                        style: TextStyle(color: theme.colors.text),
                      )
                    : null,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.label,
                      overflow: TextOverflow.ellipsis,
                      style: SailStyleValues.thirteen.copyWith(
                        color: theme.colors.text,
                      ),
                    ),
                    if (widget.subtitle != null)
                      Text(
                        widget.subtitle!,
                        overflow: TextOverflow.ellipsis,
                        style: SailStyleValues.twelve.copyWith(
                          color: theme.colors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
