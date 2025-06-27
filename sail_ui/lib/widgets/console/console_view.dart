import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sail_ui/sail_ui.dart';

class ConsoleService {
  final String name;
  final List<String> commands;
  final Future<dynamic> Function(String command, List<String> args) execute;

  const ConsoleService({
    required this.name,
    required this.commands,
    required this.execute,
  });
}

class ConsoleEntry {
  final DateTime timestamp;
  final String content;
  final EntryType type;
  final String requestId;

  bool get isGrouped => requestId != '';
  bool get isGroupStart => type == EntryType.command;

  ConsoleEntry({
    required this.timestamp,
    required this.content,
    required this.type,
    required this.requestId,
  });
}

enum EntryType {
  command,
  response,
  error,
}

class ConsoleView extends StatefulWidget {
  final List<ConsoleService> services;

  const ConsoleView({
    super.key,
    required this.services,
  });

  @override
  State<ConsoleView> createState() => _ConsoleViewState();
}

class _ConsoleViewState extends State<ConsoleView> {
  late final List<String> _allCommands;
  String? _currentService;

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final List<String> _commandHistory = [];
  int _historyIndex = -1;

  List<ConsoleEntry> entries = [];

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();

    // Merge all commands into one list
    _allCommands = widget.services.expand((service) => service.commands).toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  ConsoleService _determineService(String command) {
    for (final service in widget.services) {
      if (service.commands.contains(command)) {
        return service;
      }
    }
    // Default to first service if command not found
    return widget.services.first;
  }

  void _handleSubmitted(String text) async {
    if (text.isEmpty) return;

    ConsoleService service;
    String command;
    List<String> args;

    // Remove any extra whitespace
    text = text.trim();

    // Simple split on first whitespace
    final firstSpace = text.indexOf(' ');
    if (firstSpace == -1) {
      command = text;
      args = [];
    } else {
      command = text.substring(0, firstSpace);
      final remainingText = text.substring(firstSpace + 1);
      args = _parseArgs(remainingText);
    }

    service = _determineService(command);
    final requestId = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now();

    setState(() {
      entries.add(
        ConsoleEntry(
          timestamp: now,
          content: text,
          type: EntryType.command,
          requestId: requestId,
        ),
      );
      _commandHistory.add(text);
      _historyIndex = _commandHistory.length;
      _controller.clear();
      _currentService = service.name;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    try {
      final response = await service.execute(command, args);

      // Try to format response
      String formattedResponse;
      try {
        if (response is String) {
          // If it's a string, try to parse as JSON
          final jsonData = json.decode(response);
          formattedResponse = const JsonEncoder.withIndent('  ').convert(jsonData);
        } else {
          // If it's already a Map/List, just encode it
          formattedResponse = const JsonEncoder.withIndent('  ').convert(response);
        }
      } catch (e) {
        // Not JSON, use raw response
        formattedResponse = response.toString();
      }

      _addResponse(
        ConsoleEntry(
          timestamp: DateTime.now(),
          content: formattedResponse,
          type: EntryType.response,
          requestId: requestId,
        ),
      );
    } catch (e) {
      _addResponse(
        ConsoleEntry(
          timestamp: DateTime.now(),
          content: 'Error: ${e.toString()}',
          type: EntryType.error,
          requestId: requestId,
        ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _handleKeyPress(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (_historyIndex > 0) {
        _historyIndex--;
        _controller.text = _commandHistory[_historyIndex];
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      }
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      if (_historyIndex < _commandHistory.length - 1) {
        _historyIndex++;
        _controller.text = _commandHistory[_historyIndex];
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      } else {
        _historyIndex = _commandHistory.length;
        _controller.clear();
      }
    }
  }

  void _addResponse(ConsoleEntry responseEntry) {
    setState(() {
      // Find the index of the matching request
      final requestIndex = entries.indexWhere(
        (e) => e.requestId == responseEntry.requestId && e.type == EntryType.command,
      );

      if (requestIndex != -1) {
        // Insert response right after its request
        entries.insert(requestIndex + 1, responseEntry);
      } else {
        // Fallback: add to end if request not found
        entries.add(responseEntry);
      }
    });
  }

  List<String> _parseArgs(String text) {
    if (text.contains('{')) {
      // its json! split on '} '
      return text.split(' {').map((e) => e.trim()).toList();
    }
    final args = <String>[];
    final buffer = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < text.length; i++) {
      final char = text[i];

      // Check for escaped quote
      if (char == '\\' && i + 1 < text.length && (text[i + 1] == '"' || text[i + 1] == "'")) {
        // Skip the backslash and add the quote as a literal character
        buffer.write(text[i + 1]);
        i++; // Skip the next character since we've already processed it
      } else if (char == '"' || char == "'") {
        inQuotes = !inQuotes;
      } else if (char == ' ' && !inQuotes) {
        if (buffer.isNotEmpty) {
          args.add(buffer.toString().trim());
          buffer.clear();
        }
      } else {
        buffer.write(char);
      }
    }

    if (buffer.isNotEmpty) {
      args.add(buffer.toString().trim());
    }

    return args;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.sailTheme;

    return Column(
      children: [
        Expanded(
          child: Container(
            color: theme.colors.backgroundSecondary,
            padding: const EdgeInsets.all(16),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return ConsoleEntryWidget(entry: entry, entries: entries);
              },
            ),
          ),
        ),
        Container(
          color: theme.colors.backgroundSecondary,
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: KeyboardListener(
                  focusNode: _focusNode,
                  onKeyEvent: _handleKeyPress,
                  child: Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      final searchTerm = textEditingValue.text.toLowerCase();
                      return _allCommands.where((command) {
                        final service = _determineService(command);
                        return command.toLowerCase().contains(searchTerm) ||
                            service.name.toLowerCase().contains(searchTerm) ||
                            service.name.toLowerCase().replaceAll('_', '').replaceAll('-', '').contains(searchTerm);
                      });
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4,
                          color: theme.colors.background,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 150),
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (BuildContext context, int index) {
                                final command = options.elementAt(index);
                                final service = _determineService(command);
                                return InkWell(
                                  onTap: () => onSelected(command),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    child: SailText.primary12(
                                      '${service.name} -> $command',
                                      color: theme.colors.text,
                                      monospace: true,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                    onSelected: (String selection) {
                      setState(() {
                        _currentService = _determineService(selection).name;
                        _controller.text = selection;
                        _controller.selection = TextSelection.fromPosition(
                          TextPosition(offset: selection.length),
                        );
                      });
                    },
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        style: TextStyle(
                          color: theme.colors.text,
                          fontFamily: 'SourceCodePro',
                        ),
                        decoration: InputDecoration(
                          prefixIcon: Container(
                            margin: const EdgeInsets.only(left: 8),
                            constraints: const BoxConstraints(maxWidth: 150),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_currentService != null)
                                  SailText.primary13(
                                    _currentService!,
                                    color: theme.colors.textSecondary,
                                    monospace: true,
                                  ),
                                if (_currentService != null) const SizedBox(width: 8),
                                SailText.primary13(
                                  '>',
                                  monospace: true,
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                          border: OutlineInputBorder(
                            borderRadius: SailStyleValues.borderRadius,
                          ),
                          fillColor: theme.colors.background,
                          filled: true,
                        ),
                        onSubmitted: _handleSubmitted,
                        onChanged: (value) {
                          if (_currentService != null) {
                            setState(() {
                              _currentService = null;
                            });
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ConsoleEntryWidget extends StatelessWidget {
  final ConsoleEntry entry;
  final List<ConsoleEntry> entries;
  final _timeFormat = DateFormat('HH:mm:ss');

  ConsoleEntryWidget({
    super.key,
    required this.entry,
    required this.entries,
  });

  bool _hasResponse(String requestId) => entries.any(
        (e) => e.requestId == requestId && (e.type == EntryType.response || e.type == EntryType.error),
      );

  @override
  Widget build(BuildContext context) {
    final theme = context.sailTheme;

    Color getColor() {
      switch (entry.type) {
        case EntryType.command:
          return theme.colors.primary;
        case EntryType.response:
          return theme.colors.text;
        case EntryType.error:
          return theme.colors.destructiveButtonHover;
      }
    }

    return Container(
      decoration: entry.isGrouped
          ? BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: theme.colors.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
            )
          : null,
      margin: EdgeInsets.only(
        left: entry.isGrouped ? 16 : 0,
        top: entry.isGroupStart ? 16 : 0,
      ),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SailSpacing(SailStyleValues.padding08),
          SailText.secondary13(
            _timeFormat.format(entry.timestamp),
            color: theme.colors.textSecondary,
            monospace: true,
          ),
          const SizedBox(width: 8),
          if (entry.type == EntryType.command) ...[
            if (!_hasResponse(entry.requestId))
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1,
                  color: theme.colors.primary,
                ),
              )
            else
              Icon(Icons.chevron_right, size: 16, color: theme.colors.textSecondary),
          ] else
            const SizedBox(width: 16),
          const SizedBox(width: 8),
          Expanded(
            child: SelectableText(
              entry.content,
              style: TextStyle(
                color: getColor(),
                fontFamily: 'SourceCodePro',
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
