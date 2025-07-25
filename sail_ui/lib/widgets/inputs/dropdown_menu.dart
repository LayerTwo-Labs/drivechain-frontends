import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class SailDropdownButton<T> extends StatefulWidget {
  final List<SailDropdownItem<T>> items;
  final ValueChanged<T?> onChanged;
  final T? value;
  final String? hint;
  final Widget? icon;
  final bool large;
  final bool enabled;
  final bool openOnHover;
  final List<Widget>? menuChildren;

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
    this.menuChildren,
    super.key,
  });

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
        currentDisplay = widget.hint != null ? SailText.primary12(widget.hint!, color: Colors.white) : const SizedBox();
      }
    } else {
      currentDisplay = widget.hint != null ? SailText.primary12(widget.hint!, color: Colors.white) : const SizedBox();
    }

    final button = InkWell(
      onTap: () async {
        if (_controller.isOpen) {
          _controller.close();
        } else {
          _controller.open();
        }
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(
            color: context.sailTheme.colors.border,
            width: 1,
          ),
          borderRadius: SailStyleValues.borderRadius,
          color: widget.value == null ? theme.colors.primary : Colors.transparent,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 9,
            horizontal: 12,
          ),
          child: SailRow(
            spacing: SailStyleValues.padding08,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              currentDisplay,
              SailSVG.fromAsset(
                _controller.isOpen ? SailSVGAsset.chevronUp : SailSVGAsset.chevronDown,
                color: widget.value == null ? Colors.white : theme.colors.text,
                width: 13,
              ),
            ],
          ),
        ),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.menuChildren != null) ...widget.menuChildren!,
                SailMenu(
                  items: items,
                ),
              ],
            ),
          )
        else
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.menuChildren != null) ...widget.menuChildren!,
              SailMenu(
                items: items,
              ),
            ],
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
  final String label;
  final dynamic value;
  final bool monospace;

  const SailDropdownItem({
    super.key,
    required this.value,
    required this.label,
    this.monospace = false,
  });

  @override
  Widget build(BuildContext context) {
    return SelectionContainer.disabled(
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: SailStyleValues.thirteen.copyWith(
            color: SailTheme.of(context).colors.text,
            fontFamily: monospace ? 'SourceCodePro' : 'Inter',
          ),
        ),
      ),
    );
  }
}

class SailMultiSelectDropdown extends StatefulWidget {
  final List<SailDropdownItem> items;
  final List<String> selectedValues;
  final ValueChanged<String> onSelected;
  final Widget? hint;
  final bool enabled;
  final bool openOnHover;
  final String searchPlaceholder;
  final String selectedCountText;
  final ButtonVariant buttonVariant;
  final bool showDropdownArrow;

  const SailMultiSelectDropdown({
    super.key,
    required this.items,
    required this.selectedValues,
    required this.onSelected,
    required this.searchPlaceholder,
    required this.selectedCountText,
    this.hint,
    this.enabled = true,
    this.openOnHover = false,
    this.showDropdownArrow = true,
    this.buttonVariant = ButtonVariant.outline,
  });

  @override
  State<SailMultiSelectDropdown> createState() => _SailMultiSelectDropdownState();
}

class _SailMultiSelectDropdownState extends State<SailMultiSelectDropdown> {
  late final MenuController _controller;
  final TextEditingController searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isInButton = false;
  final bool _isInMenu = false;

  @override
  void initState() {
    super.initState();
    _controller = MenuController();
    searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _checkShouldClose() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted && !_isInButton && !_isInMenu) {
        _controller.close();
      }
    });
  }

  List<SailDropdownItem> get filteredItems {
    final query = searchController.text.toLowerCase();
    if (query.isEmpty) return widget.items;
    return widget.items.where((item) {
      return item.label.toLowerCase().contains(query);
    }).toList();
  }

  void _handlePress() {
    if (_controller.isOpen) {
      _controller.close();
    } else {
      _controller.open();
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    // Button content should only show the selected count
    final button = IntrinsicWidth(
      child: InkWell(
        onTap: _handlePress,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: widget.buttonVariant == ButtonVariant.outline
                ? Border.all(
                    color: theme.colors.border,
                    width: 1,
                  )
                : null,
            borderRadius: SailStyleValues.borderRadius,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 9,
              horizontal: 12,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.selectedCountText,
                  style: SailStyleValues.thirteen.copyWith(
                    color: theme.colors.text,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 8),
                if (widget.showDropdownArrow)
                  SailSVG.fromAsset(
                    _controller.isOpen ? SailSVGAsset.chevronUp : SailSVGAsset.chevronDown,
                    color: theme.colors.text,
                    width: 9,
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    final menuAnchor = MenuAnchor(
      controller: _controller,
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(theme.colors.background),
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
      ),
      builder: (context, controller, child) => button,
      menuChildren: [
        // Search field at the top of the dropdown
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              SailSVG.fromAsset(
                SailSVGAsset.search,
                height: 13,
                color: theme.colors.inactiveNavText,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  cursorColor: theme.colors.primary,
                  controller: searchController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: widget.searchPlaceholder,
                    hintStyle: SailStyleValues.thirteen.copyWith(
                      color: theme.colors.textSecondary,
                      fontSize: 13,
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                  ),
                  style: SailStyleValues.thirteen.copyWith(
                    color: theme.colors.text,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        SelectionContainer.disabled(
          child: SailMenu(
            items: filteredItems.map((item) {
              final isSelected = widget.selectedValues.contains(item.value);
              return SailMenuItem(
                closeOnSelect: false,
                onSelected: () {
                  widget.onSelected(item.value);
                },
                child: SailRow(
                  spacing: SailStyleValues.padding08,
                  children: [
                    if (isSelected)
                      SailSVG.fromAsset(
                        SailSVGAsset.check,
                        color: theme.colors.text,
                        height: 8,
                      )
                    else
                      const SizedBox(width: 13),
                    Expanded(child: SailText.primary13(item.label)),
                  ],
                ),
              );
            }).toList(),
          ),
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

class ExtraActionItem {
  final String label;
  final SailSVGAsset icon;
  final String? shortcut;
  final VoidCallback onSelect;

  const ExtraActionItem({
    required this.label,
    required this.icon,
    required this.onSelect,
    this.shortcut,
  });
}

class ExtraActionsDropdown extends StatefulWidget {
  final String title;
  final List<ExtraActionItem> items;

  const ExtraActionsDropdown({
    required this.title,
    required this.items,
    super.key,
  });

  @override
  State<ExtraActionsDropdown> createState() => _ExtraActionsDropdownState();
}

class _ExtraActionsDropdownState extends State<ExtraActionsDropdown> {
  late MenuController menuController;

  @override
  void initState() {
    super.initState();
    menuController = MenuController();
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: MenuAnchor(
        controller: menuController,
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(theme.colors.background),
          padding: const WidgetStatePropertyAll(EdgeInsets.zero),
          elevation: WidgetStatePropertyAll(0),
        ),
        builder: (context, controller, child) => SailButton(
          onPressed: () async {
            if (menuController.isOpen) {
              menuController.close();
            } else {
              menuController.open();
            }
          },
          variant: ButtonVariant.icon,
          icon: SailSVGAsset.ellipsis,
        ),
        menuChildren: [
          SailMenu(
            title: widget.title,
            items: widget.items
                .map(
                  (item) => SailMenuItem(
                    onSelected: () {
                      item.onSelect();
                      menuController.close();
                    },
                    child: SelectionContainer.disabled(
                      child: SailRow(
                        spacing: SailStyleValues.padding12,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SailSVG.fromAsset(item.icon, height: 13, color: theme.colors.text),
                          SailText.primary13(item.label),
                          if (item.shortcut != null) ...[
                            const Spacer(),
                            SailText.primary12(
                              item.shortcut!,
                              color: theme.colors.text.withValues(alpha: 0.6),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class MultiSelectDropdown extends StatefulWidget {
  final String searchPlaceholder;
  final List<SailDropdownItem> items;
  final List<String>? selectedValues;
  final ValueChanged<String> onSelected;
  final Widget? suffix;

  const MultiSelectDropdown({
    required this.searchPlaceholder,
    required this.items,
    required this.selectedValues,
    required this.onSelected,
    this.suffix,
    super.key,
  });

  @override
  State<MultiSelectDropdown> createState() => _MultiSelectDropdownState();
}

class _MultiSelectDropdownState extends State<MultiSelectDropdown> {
  late MenuController menuController;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    menuController = MenuController();
    searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<SailDropdownItem> get filteredItems {
    final query = searchController.text.toLowerCase();
    if (query.isEmpty) return widget.items;
    return widget.items.where((item) {
      return item.label.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    // Find the currently selected item
    final selectedItem = widget.selectedValues != null
        ? widget.items.firstWhere(
            (item) => item.value == widget.selectedValues,
            orElse: () => widget.items.first,
          )
        : null;

    return MenuAnchor(
      controller: menuController,
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(theme.colors.background),
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        elevation: const WidgetStatePropertyAll(8),
      ),
      builder: (context, controller, child) => SelectionContainer.disabled(
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: InkWell(
            onTap: () {
              if (menuController.isOpen) {
                menuController.close();
              } else {
                menuController.open();
                searchController.clear();
              }
            },
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colors.border,
                  width: 1,
                ),
                borderRadius: SailStyleValues.borderRadius,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 9,
                  horizontal: 12,
                ),
                child: SailRow(
                  spacing: SailStyleValues.padding08,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: selectedItem != null
                          ? SailText.primary13(selectedItem.label)
                          : SailText.primary13(
                              widget.searchPlaceholder,
                              color: theme.colors.textSecondary,
                            ),
                    ),
                    widget.suffix ??
                        SailSVG.fromAsset(
                          menuController.isOpen ? SailSVGAsset.chevronUp : SailSVGAsset.chevronDown,
                          color: theme.colors.inactiveNavText,
                          width: 9,
                        ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      menuChildren: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SailTextField(
            controller: searchController,
            hintText: widget.searchPlaceholder,
            prefixIcon: SailSVG.fromAsset(SailSVGAsset.search, height: 13),
          ),
        ),
        if (filteredItems.isEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SailText.primary13(
              'No results found',
              color: theme.colors.textSecondary,
            ),
          )
        else
          SailMenu(
            items: filteredItems.map((item) {
              return SailMenuItem(
                onSelected: () {
                  widget.onSelected(item.value);
                },
                child: SailRow(
                  spacing: SailStyleValues.padding08,
                  children: [
                    Expanded(child: SailText.primary13(item.label)),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
