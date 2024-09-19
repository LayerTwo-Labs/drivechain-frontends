import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

@RoutePage()
class LogPage extends StatelessWidget {
  final String name;
  final String logPath;

  const LogPage({
    super.key,
    required this.name,
    required this.logPath,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => LogPageViewModel(logPath: logPath),
      onViewModelReady: (viewModel) => viewModel.init(),
      builder: (context, viewModel, child) {
        return SailPage(
          widgetTitle: SailText.primary15('$name logs'),
          body: KeyboardListener(
            focusNode: viewModel.focusNode,
            onKeyEvent: (KeyEvent event) {
              if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
                viewModel.addLineBreak();
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(SailStyleValues.padding30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SailButton.primary(
                    'Clear logs',
                    size: ButtonSize.small,
                    onPressed: () => viewModel.clearLog(),
                  ),
                  const SailSpacing(16),
                  Expanded(
                    child: ListView.builder(
                      controller: viewModel.scrollController,
                      itemCount: viewModel.logLines.length + 1,
                      itemBuilder: (context, index) {
                        if (index == viewModel.logLines.length) {
                          return const SizedBox(height: 100); // Bottom padding
                        }
                        return SailText.primary10(viewModel.logLines[index]);
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

  Stream<String> watchLogFile(String logFilePath) async* {
    final file = File(logFilePath);
    if (!await file.exists()) {
      yield 'Log file not found.';
      return;
    }

    _raf = await file.open(mode: FileMode.read);
    final initialLines = await _readLastNLines(_raf!, 100);
    for (var line in initialLines) {
      yield line;
    }

    var doneInitialScroll = false;

    while (true) {
      final newLines = await _readNewLines(_raf!);
      for (var line in newLines) {
        yield line;
      }
      await Future.delayed(const Duration(milliseconds: 100));
      if (!doneInitialScroll) {
        _scrollToBottom(overrideBottom: true);
        doneInitialScroll = true;
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
      final chunk = utf8.decode(buffer.toList()).split('\n').reversed;
      lines.insertAll(0, chunk);
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
      final chunk = utf8.decode(buffer);
      newLines.addAll(chunk.split('\n').where((line) => line.isNotEmpty));
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
    _raf?.close();
    scrollController.dispose();
    focusNode.dispose();
    super.dispose();
  }
}
