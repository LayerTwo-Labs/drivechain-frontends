import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/env.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class LogPage extends StatefulWidget {
  final String logPath;
  final String title;

  const LogPage({
    super.key,
    required this.logPath,
    required this.title,
  });

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  final ScrollController _scrollController = ScrollController();
  final List<String> _logLines = [];
  final FocusNode _focusNode = FocusNode();
  Timer? _tailTimer;
  int _lastPosition = 0;
  bool _stickToBottom = true;
  static const int maxLines = 1000;
  static const int chunkSize = 8192;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLogView();
    });
  }

  Future<void> _initializeLogView() async {
    final logFile = File(widget.logPath);
    if (!logFile.existsSync()) return;

    // Read the last N lines initially
    await _readLastNLines(logFile);

    // Start tailing for new content
    _startTailing();
  }

  Future<void> _readLastNLines(File logFile) async {
    final length = logFile.lengthSync();
    if (length == 0) return;

    final raf = logFile.openSync(mode: FileMode.read);
    try {
      // Start from the end of the file
      raf.setPositionSync(length);

      // Read backwards in chunks until we have enough lines
      final lines = <String>[];
      var position = length;

      while (lines.length < maxLines && position > 0) {
        final readSize = position > chunkSize ? chunkSize : position;
        position -= readSize;
        raf.setPositionSync(position);
        final chunk = raf.readSync(readSize);

        try {
          final content = utf8.decode(chunk, allowMalformed: true);
          final newLines = content
              .split('\n')
              .where((line) => line.isNotEmpty)
              .where((line) => !isSpam(line))
              .map((line) => line.trim())
              .toList()
              .reversed; // Reverse to maintain chronological order

          lines.insertAll(0, newLines);
          if (lines.length > maxLines) {
            lines.removeRange(0, lines.length - maxLines);
          }
        } catch (e) {
          // If UTF8 fails, try Latin1
          final content = latin1.decode(chunk);
          final newLines = content
              .split('\n')
              .where((line) => line.isNotEmpty)
              .where((line) => !isSpam(line))
              .map((line) => line.trim())
              .toList()
              .reversed;

          lines.insertAll(0, newLines);
          if (lines.length > maxLines) {
            lines.removeRange(0, lines.length - maxLines);
          }
        }
      }

      setState(() {
        _logLines.addAll(lines);
        _lastPosition = length;
      });

      // Try multiple times to scroll to bottom
      for (var i = 0; i < 5; i++) {
        await Future.delayed(Duration(milliseconds: 100 * (i + 1)));
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          setState(() {
            _stickToBottom = true;
          });
        }
      }
    } finally {
      raf.closeSync();
    }
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;

    // Check if we're at the bottom
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    setState(() {
      _stickToBottom = maxScroll - currentScroll <= 50.0;
    });
  }

  TextSpan _parseAnsiCodes(String text) {
    final spans = <TextSpan>[];
    var currentColor = Colors.white;
    var currentBold = false;

    text = text.replaceAll(RegExp(r'^flutter: '), '');

    final ansiRegex = RegExp(r'\x1B\[([0-9;]*)m');
    var lastMatchEnd = 0;

    for (final match in ansiRegex.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(
          TextSpan(
            text: text.substring(lastMatchEnd, match.start),
            style: SailStyleValues.twelve.copyWith(
              color: currentColor,
              fontWeight: currentBold ? SailStyleValues.boldWeight : null,
              fontFamily: 'SourceCodePro',
            ),
          ),
        );
      }

      final code = match.group(1) ?? '';
      for (final num in code.split(';')) {
        switch (num) {
          case '0': // Reset
            currentColor = Colors.white;
            currentBold = false;
          case '1': // Bold
            currentBold = true;
          case '30':
            currentColor = Colors.black;
          case '31':
            currentColor = Colors.red;
          case '32':
            currentColor = Colors.green;
          case '33':
            currentColor = Colors.yellow;
          case '34':
            currentColor = Colors.blue;
          case '35':
            currentColor = Colors.purple;
          case '36':
            currentColor = Colors.cyan;
          case '37':
            currentColor = Colors.white;
        }
      }

      lastMatchEnd = match.end;
    }

    // Add remaining text
    if (lastMatchEnd < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastMatchEnd),
          style: SailStyleValues.twelve.copyWith(
            color: currentColor,
            fontWeight: currentBold ? SailStyleValues.boldWeight : null,
            fontFamily: 'SourceCodePro',
          ),
        ),
      );
    }

    return TextSpan(children: spans);
  }

  void _startTailing() {
    if (Environment.isInTest) {
      return;
    }

    final logFile = File(widget.logPath);

    _tailTimer = Timer.periodic(const Duration(milliseconds: 100), (_) async {
      if (!logFile.existsSync()) return;

      final length = await logFile.length();
      if (length < _lastPosition) {
        _lastPosition = 0;
        _logLines.clear();
        await _readLastNLines(logFile);
        return;
      }

      if (length > _lastPosition) {
        final raf = await logFile.open(mode: FileMode.read);
        await raf.setPosition(_lastPosition);
        final data = await raf.read(length - _lastPosition);
        await raf.close();

        String newContent;
        try {
          newContent = utf8.decode(data, allowMalformed: true);
        } catch (e) {
          // If UTF8 fails, try Latin1
          newContent = latin1.decode(data);
        }

        final newLines = newContent
            .split('\n')
            .where((line) => line.isNotEmpty)
            .where((line) => !isSpam(line))
            .map((line) => line.trim())
            .toList();

        // Store current scroll position before updating
        final wasAtBottom = _stickToBottom;
        final previousOffset = _scrollController.hasClients ? _scrollController.offset : 0;

        setState(() {
          _logLines.addAll(newLines);
          if (_logLines.length > maxLines) {
            _logLines.removeRange(0, _logLines.length - maxLines);
          }
        });

        _lastPosition = length;

        // Only auto-scroll if we were already at the bottom
        if (wasAtBottom && _scrollController.hasClients) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          });
        } else if (_scrollController.hasClients) {
          // Restore previous scroll position
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollController.jumpTo(previousOffset.toDouble());
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _tailTimer?.cancel();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SailColorScheme.blackLighter,
      appBar: AppBar(
        title: SailText.primary20(widget.title, color: SailColorScheme.whiteDark),
        backgroundColor: SailColorScheme.blackLighter,
        foregroundColor: SailColorScheme.whiteDark,
        actions: [
          SailButton(
            onPressed: () async {
              final logFile = File(widget.logPath);
              await openFile(logFile);
            },
            variant: ButtonVariant.icon,
            icon: SailSVGAsset.download,
          ),
        ],
      ),
      body: SelectableRegion(
        focusNode: _focusNode,
        selectionControls: DesktopTextSelectionControls(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _logLines.length + 1,
            itemBuilder: (context, index) {
              if (index == _logLines.length) {
                return const SizedBox(height: 100);
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
                child: Text.rich(
                  _parseAnsiCodes(_logLines[index]),
                  style: const TextStyle(
                    fontFamily: 'SourceCodePro',
                    fontSize: 10,
                    color: SailColorScheme.whiteDark,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class LogPageViewModel extends BaseViewModel {
  final Logger log = GetIt.I.get<Logger>();

  final String logPath;
  final List<String> _logLines = [];
  List<String> get logLines => _logLines;

  late ScrollController scrollController;
  StreamSubscription<String>? _logSubscription;
  RandomAccessFile? _raf;
  late FocusNode focusNode;

  LogPageViewModel({
    required this.logPath,
  });

  Future<void> init() async {
    scrollController = ScrollController();
    focusNode = FocusNode();

    _logSubscription = watchLogFile(logPath).listen((line) {
      if (!isSpam(line)) {
        _logLines.add(line);
        _scrollToBottom();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });
  }

  void _scrollToBottom({bool overrideBottom = false}) {
    // Only scroll to bottom if currently at or near the bottom
    final isAtBottom = scrollController.hasClients &&
        scrollController.position.pixels >= scrollController.position.maxScrollExtent - 150; // 150 pixels threshold

    if (!overrideBottom && !isAtBottom) {
      return;
    }

    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
    notifyListeners();
  }

  String _stripAnsiCodes(String text) {
    // This regex matches ANSI escape codes and Flutter debug prefixes
    return text
        .replaceAll(RegExp(r'\x1B\[[0-9;]*[a-zA-Z]'), '') // Remove ANSI color codes
        .replaceAll(RegExp(r'^flutter: '), ''); // Remove Flutter debug prefix
  }

  Stream<String> watchLogFile(String logFilePath) async* {
    final file = File(logFilePath);
    if (!await file.exists()) {
      yield 'Log file not found.';
      return;
    }

    _raf = await file.open(mode: FileMode.read);

    // Read initial lines
    final initialLines = await _readLastNLines(_raf!, 100);
    for (var line in initialLines) {
      yield line;
    }

    // Watch for file changes
    await for (final _ in file.watch(events: FileSystemEvent.modify)) {
      final newLines = await _readNewLines(_raf!);
      for (var line in newLines) {
        yield line;
      }
    }
  }

  Future<List<String>> _readLastNLines(RandomAccessFile raf, int n) async {
    final lines = <String>[];
    final fileLength = await raf.length();
    const int bufferSize = 4096;
    int end = fileLength;
    int start = end - bufferSize;
    if (start < 0) start = 0;

    while (lines.length < n && start >= 0) {
      raf.setPositionSync(start);
      final buffer = raf.readSync(end - start);
      try {
        final chunk =
            utf8.decode(buffer.toList(), allowMalformed: true).split('\n').map(_stripAnsiCodes).toList().reversed;
        lines.insertAll(0, chunk);
      } catch (e) {
        log.e('Error decoding log file chunk: $e');
      }
      end = start;
      start -= bufferSize;
      if (start < 0) start = 0;
    }

    return lines.take(n).toList();
  }

  Future<List<String>> _readNewLines(RandomAccessFile raf) async {
    final newLines = <String>[];
    final currentPosition = await raf.position();
    final fileLength = await raf.length();

    if (fileLength > currentPosition) {
      final buffer = await raf.read(fileLength - currentPosition);
      try {
        final chunk = utf8.decode(buffer, allowMalformed: true);
        newLines.addAll(
          chunk.split('\n').map(_stripAnsiCodes).where((line) => line.isNotEmpty),
        );
      } catch (e) {
        log.e('Error decoding new log lines: $e');
      }
      await raf.setPosition(fileLength);
    }

    return newLines;
  }

  void clearLog() {
    _logLines.clear();
    _scrollToBottom();
  }

  void addLineBreak() {
    _logLines.add('');
    _scrollToBottom(overrideBottom: true);
  }

  @override
  void dispose() {
    _logSubscription?.cancel();
    scrollController.dispose();
    focusNode.dispose();
    super.dispose();
  }
}
