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

enum EntryType { command, response, error }

class ConsoleView extends StatefulWidget {
  final List<ConsoleService> services;

  const ConsoleView({super.key, required this.services});

  @override
  State<ConsoleView> createState() => _ConsoleViewState();
}

class _ConsoleViewState extends State<ConsoleView> {
  static const _maxSuggestions = 40;

  late final List<_Completion> _allCommands;

  /// The service the next command goes to. It sticks after a command runs, so
  /// a name no CLI claims still reaches the CLI the user last used.
  ConsoleService? _stickyService;

  final TextEditingController _controller = TextEditingController();
  final FocusNode _inputFocus = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final List<String> _commandHistory = [];

  /// Position in the filtered history, or -1 when the user is not browsing.
  int _historyIndex = -1;
  String _historySeed = '';

  List<_Completion> _suggestions = const [];

  List<ConsoleEntry> entries = [];

  @override
  void initState() {
    super.initState();
    _inputFocus.requestFocus();

    _allCommands = [
      for (final service in widget.services)
        for (final command in service.commands) _Completion(command, service),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    _inputFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// The service that publishes this command, or null when none does.
  ConsoleService? _publisherOf(String command) {
    for (final service in widget.services) {
      if (service.commands.contains(command)) {
        return service;
      }
    }
    return null;
  }

  /// The service a typed command runs on. Two CLIs can publish the same name,
  /// such as help, so the one the user last used answers for it.
  ConsoleService _determineService(String command) {
    final sticky = _stickyService;
    if (sticky != null && sticky.commands.contains(command)) {
      return sticky;
    }
    return _publisherOf(command) ?? sticky ?? widget.services.first;
  }

  String _firstWord(String text) {
    final trimmed = text.trim();
    final space = trimmed.indexOf(' ');
    return space == -1 ? trimmed : trimmed.substring(0, space);
  }

  void _handleSubmitted(String text) async {
    if (text.isEmpty) {
      return;
    }

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
      _historyIndex = -1;
      _historySeed = '';
      _suggestions = const [];
      _controller.clear();
      _stickyService = service;
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
          formattedResponse = const JsonEncoder.withIndent(
            '  ',
          ).convert(jsonData);
        } else {
          // If it's already a Map/List, just encode it
          formattedResponse = const JsonEncoder.withIndent(
            '  ',
          ).convert(response);
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

  KeyEventResult _handleKeyPress(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowUp) {
      _stepHistory(-1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      _stepHistory(1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.tab) {
      return _completeFirst() ? KeyEventResult.handled : KeyEventResult.ignored;
    }
    if (key == LogicalKeyboardKey.escape && _suggestions.isNotEmpty) {
      setState(() => _suggestions = const []);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _setText(String value) {
    _controller.text = value;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: value.length),
    );
  }

  /// Walks the history, oldest to newest. What the user typed before the first
  /// arrow press narrows it, so `gen` + up finds only the generate commands.
  void _stepHistory(int step) {
    if (_historyIndex == -1) {
      _historySeed = _controller.text.trim();
    }
    final matches = _historyMatches();
    if (matches.isEmpty) {
      return;
    }

    final from = _historyIndex == -1 ? matches.length : _historyIndex;
    final next = from + step;
    if (next >= matches.length) {
      setState(() {
        _historyIndex = -1;
        _suggestions = const [];
      });
      _setText(_historySeed);
      return;
    }

    setState(() {
      _historyIndex = next < 0 ? 0 : next;
      _suggestions = const [];
    });
    _setText(matches[_historyIndex]);
  }

  /// History entries that hold the seed, oldest first, each one only once.
  List<String> _historyMatches() {
    final seed = _historySeed.toLowerCase();
    final seen = <String>{};
    final newestFirst = <String>[];
    for (var i = _commandHistory.length - 1; i >= 0; i--) {
      final entry = _commandHistory[i];
      if (seed.isNotEmpty && !entry.toLowerCase().contains(seed)) {
        continue;
      }
      if (seen.add(entry)) {
        newestFirst.add(entry);
      }
    }
    return newestFirst.reversed.toList();
  }

  bool _completeFirst() {
    if (_suggestions.isEmpty) {
      return false;
    }
    _accept(_suggestions.first);
    return true;
  }

  void _accept(_Completion completion) {
    _setText('${completion.command} ');
    setState(() {
      _suggestions = const [];
      // The user picked this row, so its service answers the command even when
      // another CLI publishes the same name.
      _stickyService = completion.service;
    });
    _inputFocus.requestFocus();
  }

  /// Commands that match what the user typed, whole-prefix matches first. Only
  /// the first word completes — the rest of the line is arguments.
  List<_Completion> _matches(String text) {
    if (text.contains(' ')) {
      return const [];
    }
    final term = text.trim().toLowerCase();
    if (term.isEmpty) {
      return const [];
    }

    final starts = <_Completion>[];
    final holds = <_Completion>[];
    for (final completion in _allCommands) {
      final lower = completion.command.toLowerCase();
      if (lower == term) {
        continue;
      }
      if (lower.startsWith(term)) {
        starts.add(completion);
      } else if (lower.contains(term)) {
        holds.add(completion);
      }
    }
    return [...starts, ...holds].take(_maxSuggestions).toList();
  }

  void _onChanged(String value) {
    setState(() {
      _historyIndex = -1;
      _suggestions = _matches(value);
    });
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
          child: SailColumn(
            mainAxisSize: MainAxisSize.min,
            spacing: SailStyleValues.padding04,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_suggestions.isNotEmpty) _suggestionList(theme),
              Focus(
                onKeyEvent: _handleKeyPress,
                child: TextField(
                  controller: _controller,
                  focusNode: _inputFocus,
                  style: TextStyle(
                    color: theme.colors.text,
                    fontFamily: 'IBMPlexMono',
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Container(
                      margin: const EdgeInsets.only(left: 8),
                      constraints: const BoxConstraints(maxWidth: 150),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SailText.primary13(
                            _determineService(_firstWord(_controller.text)).name,
                            color: theme.colors.textSecondary,
                            monospace: true,
                          ),
                          const SizedBox(width: 8),
                          SailText.primary13('>', monospace: true),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                    prefixIconConstraints: const BoxConstraints(
                      minWidth: 0,
                      minHeight: 0,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: SailStyleValues.borderRadius,
                      borderSide: BorderSide(color: theme.colors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: SailStyleValues.borderRadius,
                      borderSide: BorderSide(color: theme.colors.primary, width: 1.5),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: SailStyleValues.borderRadius,
                      borderSide: BorderSide(color: theme.colors.border),
                    ),
                    fillColor: theme.colors.background,
                    filled: true,
                  ),
                  onSubmitted: _handleSubmitted,
                  onChanged: _onChanged,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _suggestionList(SailThemeData theme) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 160),
      decoration: BoxDecoration(
        color: theme.colors.background,
        border: Border.all(color: theme.colors.border),
        borderRadius: SailStyleValues.borderRadius,
      ),
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: _suggestions.length,
        itemBuilder: (context, index) {
          final completion = _suggestions[index];
          final first = index == 0;
          return InkWell(
            onTap: () => _accept(completion),
            child: Container(
              color: first ? theme.colors.primary.withValues(alpha: 0.10) : null,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  SailText.primary12(completion.command, monospace: true),
                  const Spacer(),
                  if (first) ...[
                    SailText.secondary12('tab', monospace: true),
                    const SizedBox(width: 8),
                  ],
                  SailText.secondary12(
                    completion.service.name,
                    monospace: true,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ConsoleEntryWidget extends StatelessWidget {
  final ConsoleEntry entry;
  final List<ConsoleEntry> entries;
  final _timeFormat = DateFormat('HH:mm:ss');

  ConsoleEntryWidget({super.key, required this.entry, required this.entries});

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
              Icon(
                Icons.chevron_right,
                size: 16,
                color: theme.colors.textSecondary,
              ),
          ] else
            const SizedBox(width: 16),
          const SizedBox(width: 8),
          Expanded(
            child: SelectableText(
              entry.content,
              style: TextStyle(
                color: getColor(),
                fontFamily: 'IBMPlexMono',
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One command a console can complete, with the service that publishes it.
/// Two CLIs can publish the same name, so the name alone names no service.
class _Completion {
  const _Completion(this.command, this.service);

  final String command;
  final ConsoleService service;
}
