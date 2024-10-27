import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class SailDropdownButton<T> extends StatefulWidget {
  const SailDropdownButton({
    required this.items,
    required this.onChanged,
    required this.value,
    this.icon = const Icon(
      Icons.expand_more,
      size: 16,
    ),
    this.large = false,
    this.enabled = true,
    super.key,
  });

  final List<SailDropdownItem<T>> items;
  final ValueChanged<T> onChanged;
  final T value;
  final Widget? icon;
  final bool large;
  final bool enabled;
  @override
  State<StatefulWidget> createState() => _SailDropdownButtonState<T>();
}

class _SailDropdownButtonState<T> extends State<SailDropdownButton<T>> {
  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    var items = widget.items
        .map(
          (e) => SailMenuItem(
            onSelected: () {
              widget.onChanged(e.value);
            },
            child: e,
          ),
        )
        .toList();

    var currentIndex = widget.items.indexWhere((element) => element.value == widget.value);
    Widget currentItem = widget.items[currentIndex];

    return QtButton(
      size: ButtonSize.small,
      onPressed: () {
        var bounds = getGlobalBoundsForContext(context);
        showSailMenu(
          context: context,
          preferredAnchorPoint: Offset(
            bounds.left - (context.isWindows ? 1 : 9),
            bounds.bottom,
          ),
          menu: SailMenu(
            items: items,
          ),
        );
      },
      style: SailButtonStyle.secondary,
      disabled: !widget.enabled,
      child: SailRow(
        spacing: SailStyleValues.padding08,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          currentItem,
          SailSVG.fromAsset(
            SailSVGAsset.iconDropdown,
            color: theme.colors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class SailDropdownItem<T> extends StatelessWidget {
  const SailDropdownItem({
    required this.value,
    required this.child,
    super.key,
  });

  final T value;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: child,
    );
  }
}
