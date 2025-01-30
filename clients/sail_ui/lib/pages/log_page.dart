import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class LogPage extends StatelessWidget {
  final String name;
  final String logPath;

  const LogPage({
    required this.name,
    required this.logPath,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => LogPageViewModel(logPath: logPath),
      onViewModelReady: (model) => model.init(),
      builder: (context, model, child) {
        return SailPage(
          widgetTitle: SailText.primary20('$name logs'),
          body: KeyboardListener(
            focusNode: model.focusNode,
            onKeyEvent: (KeyEvent event) {
              if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
                model.addLineBreak();
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(SailStyleValues.padding32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SailText.primary12(
                    'Viewing logs at: $logPath',
                  ),
                  const SailSpacing(SailStyleValues.padding16),
                  SailButton.primary(
                    'Clear logs',
                    size: ButtonSize.regular,
                    onPressed: () => model.clearLog(),
                  ),
                  const SailSpacing(SailStyleValues.padding16),
                  Expanded(
                    child: ListView.builder(
                      controller: model.scrollController,
                      itemCount: model.logLines.length + 1,
                      itemBuilder: (context, index) {
                        if (index == model.logLines.length) {
                          return const SizedBox(height: 100); // Bottom padding
                        }
                        return SailText.primary10(model.logLines[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
      _logLines.add(line);
      _scrollToBottom();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });
  }

  void _scrollToBottom({overrideBottom = false}) {
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
    // This regex matches ANSI escape codes
    return text.replaceAll(RegExp(r'\x1B\[[0-9;]*[a-zA-Z]'), '');
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
        final chunk = utf8
            .decode(buffer.toList(), allowMalformed: true)
            .split('\n')
            .map(_stripAnsiCodes) // Strip ANSI codes from each line
            .toList() // Convert to List before reversing
            .reversed;
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
          chunk
              .split('\n')
              .map(_stripAnsiCodes) // Strip ANSI codes from each line
              .where((line) => line.isNotEmpty),
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
