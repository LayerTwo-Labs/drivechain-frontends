import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class SailDropdownButton<T> extends StatefulWidget {
  const SailDropdownButton({
    required this.items,
    required this.onChanged,
    required this.value,
    this.hint,
    this.icon = const Icon(
      Icons.expand_more,
      size: 16,
    ),
    this.large = false,
    this.enabled = true,
    this.openOnHover = false,
    super.key,
  });

  final List<SailDropdownItem<T>> items;
  final ValueChanged<T?> onChanged;
  final T? value;
  final Widget? hint;
  final Widget? icon;
  final bool large;
  final bool enabled;
  final bool openOnHover;

  @override
  State<StatefulWidget> createState() => _SailDropdownButtonState<T>();
}

class _SailDropdownButtonState<T> extends State<SailDropdownButton<T>> {
  late final MenuController _controller;
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
        _controller.close();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    var items = widget.items
        .map(
          (e) => SailMenuItem(
            onSelected: () {
              widget.onChanged(e.value);
              _controller.close();
            },
            child: e,
          ),
        )
        .toList();

    Widget currentDisplay;
    if (widget.value != null) {
      var currentIndex = widget.items.indexWhere((element) => element.value == widget.value);
      if (currentIndex >= 0) {
        currentDisplay = widget.items[currentIndex];
      } else {
        currentDisplay = widget.hint ?? const SizedBox();
      }
    } else {
      currentDisplay = widget.hint ?? const SizedBox();
    }

    final button = InkWell(
      onTap: () async {
        if (_controller.isOpen) {
          _controller.close();
        } else {
          _controller.open();
        }
      },
      // TODO: Restyle this button......
      child: SailRow(
        spacing: SailStyleValues.padding08,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          currentDisplay,
          SailSVG.fromAsset(
            SailSVGAsset.iconDropdown,
            color: theme.colors.textSecondary,
          ),
        ],
      ),
    );

    final menuAnchor = MenuAnchor(
      controller: _controller,
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(context.sailTheme.colors.background),
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
      ),
      builder: (context, controller, child) => button,
      menuChildren: [
        if (widget.openOnHover)
          MouseRegion(
            onEnter: (_) => setState(() => _isInMenu = true),
            onExit: (_) => setState(() {
              _isInMenu = false;
              _checkShouldClose();
            }),
            child: SailMenu(
              items: items,
            ),
          )
        else
          SailMenu(
            items: items,
          ),
      ],
    );

    if (widget.openOnHover) {
      return MouseRegion(
        onEnter: (_) => setState(() {
          _isInButton = true;
          _controller.open();
        }),
        onExit: (_) => setState(() {
          _isInButton = false;
          _checkShouldClose();
        }),
        child: menuAnchor,
      );
    }

    return menuAnchor;
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
