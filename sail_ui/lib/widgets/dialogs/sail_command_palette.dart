import 'package:flutter/material.dart' show Dialog, InputBorder, InputDecoration, TextField;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

class SailCommandPaletteItem {
  final String label;
  final String category;
  final String? subtitle;
  final VoidCallback onSelected;

  const SailCommandPaletteItem({
    required this.label,
    required this.category,
    this.subtitle,
    required this.onSelected,
  });
}

/// Searchable command palette dialog with keyboard navigation.
class SailCommandPalette extends StatefulWidget {
  final List<SailCommandPaletteItem> commands;

  /// Extra results for queries of 2+ characters (e.g. code search).
  final List<SailCommandPaletteItem> Function(String query)? searchResults;

  /// Filters [commands] by query; defaults to case-insensitive label match.
  final bool Function(SailCommandPaletteItem item, String query)? matches;

  const SailCommandPalette({
    super.key,
    required this.commands,
    this.searchResults,
    this.matches,
  });

  @override
  State<SailCommandPalette> createState() => _SailCommandPaletteState();
}

class _SailCommandPaletteState extends State<SailCommandPalette> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  int _selectedIndex = 0;

  List<SailCommandPaletteItem> get _allResults {
    final query = _searchController.text.toLowerCase();
    final results = <SailCommandPaletteItem>[];

    for (final cmd in widget.commands) {
      final matched = widget.matches?.call(cmd, query) ?? cmd.label.toLowerCase().contains(query);
      if (query.isEmpty || matched) {
        results.add(cmd);
      }
    }

    if (query.length >= 2 && widget.searchResults != null) {
      results.addAll(widget.searchResults!(query));
    }

    return results;
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() => _selectedIndex = 0));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _selectResult(SailCommandPaletteItem result) {
    Navigator.of(context).pop();
    result.onSelected();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final results = _allResults;
    if (results.isEmpty) return;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() {
        _selectedIndex = (_selectedIndex + 1) % results.length;
      });
    } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() {
        _selectedIndex = (_selectedIndex - 1 + results.length) % results.length;
      });
    } else if (event.logicalKey == LogicalKeyboardKey.enter) {
      _selectResult(results[_selectedIndex]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final results = _allResults;

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: _handleKeyEvent,
      child: Dialog(
        backgroundColor: theme.colors.backgroundSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: SailStyleValues.borderRadiusSmall,
          side: BorderSide(color: theme.colors.border, width: 1),
        ),
        child: Container(
          width: 500,
          constraints: const BoxConstraints(maxHeight: 450),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: theme.colors.border)),
                ),
                child: Row(
                  children: [
                    SailSVG.fromAsset(
                      SailSVGAsset.search,
                      height: 16,
                      color: theme.colors.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        style: SailStyleValues.thirteen.copyWith(color: theme.colors.text),
                        cursorColor: theme.colors.primary,
                        decoration: InputDecoration(
                          hintText: 'Search commands and code...',
                          hintStyle: SailStyleValues.thirteen.copyWith(color: theme.colors.textSecondary),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (results.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: SailText.secondary13('No matching results'),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final result = results[index];
                      final isSelected = index == _selectedIndex;

                      return MouseRegion(
                        onEnter: (_) => setState(() => _selectedIndex = index),
                        child: GestureDetector(
                          onTap: () => _selectResult(result),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            color: isSelected
                                ? theme.colors.primary.withValues(alpha: 0.1)
                                : SailColorScheme.transparent,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SailText.primary13(
                                        result.label.length > 60 ? '${result.label.substring(0, 60)}...' : result.label,
                                      ),
                                      if (result.subtitle != null)
                                        SailText.secondary12(result.subtitle!, color: theme.colors.textTertiary),
                                    ],
                                  ),
                                ),
                                SailText.secondary12(result.category, color: theme.colors.textSecondary),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
