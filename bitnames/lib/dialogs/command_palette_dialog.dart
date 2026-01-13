import 'package:bitnames/services/code_search_service.dart';
import 'package:bitnames/utils/menu_commands.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sail_ui/sail_ui.dart';

class CommandPaletteDialog extends StatefulWidget {
  final List<CommandItem> commands;
  final CodeSearchService codeSearchService;
  final void Function(String filePath, String matchedLine) onCodeResultSelected;

  const CommandPaletteDialog({
    super.key,
    required this.commands,
    required this.codeSearchService,
    required this.onCodeResultSelected,
  });

  @override
  State<CommandPaletteDialog> createState() => _CommandPaletteDialogState();
}

class _SearchResult {
  final String label;
  final String category;
  final String? subtitle;
  final VoidCallback onSelected;

  const _SearchResult({
    required this.label,
    required this.category,
    this.subtitle,
    required this.onSelected,
  });
}

class _CommandPaletteDialogState extends State<CommandPaletteDialog> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  int _selectedIndex = 0;

  List<_SearchResult> get _allResults {
    final query = _searchController.text.toLowerCase();
    final results = <_SearchResult>[];

    // Add matching commands
    for (final cmd in widget.commands) {
      if (query.isEmpty || cmd.matchesQuery(query)) {
        results.add(
          _SearchResult(
            label: cmd.label,
            category: cmd.category,
            onSelected: cmd.onSelected,
          ),
        );
      }
    }

    // Add code search results
    if (query.length >= 2) {
      final codeResults = widget.codeSearchService.search(query);
      for (final result in codeResults) {
        results.add(
          _SearchResult(
            label: result.matchedLine,
            category: result.fileName,
            subtitle: 'Line ${result.lineNumber}',
            onSelected: () {
              Navigator.of(context).pop();
              widget.onCodeResultSelected(result.filePath, result.matchedLine);
            },
          ),
        );
      }
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

  void _selectResult(_SearchResult result) {
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
              // Search field
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

              // Results list
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
                            color: isSelected ? theme.colors.primary.withValues(alpha: 0.1) : Colors.transparent,
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
