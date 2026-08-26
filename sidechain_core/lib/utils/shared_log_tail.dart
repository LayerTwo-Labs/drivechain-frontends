import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// True when bitwindowd already sends the orchestrator lines to its own stdout,
/// which the process manager forwards to the console. The tail would print the
/// file copy of the same lines a second time.
///
/// It reads the value exactly as bitwindowd reads it. A looser rule here would
/// hold the tail back on a value that leaves the backend in file-only mode, and
/// the console would then show nothing at all.
bool orchestratorLogsToStdout(Map<String, String> env) {
  final value = env['ORCHESTRATORD_STDOUT'];
  return value == '1' || value == 'true';
}

/// Prints the lines that another process appends to the shared log file.
///
/// drivechaind runs detached, so its output reaches no pipe the frontend
/// owns. A pipe would also kill it: the child outlives bitwindowd, and the
/// first write after the reader goes away ends the process.
///
/// It prints the lines of [source] and every line with no tag. A daemon that
/// dies before its logger exists writes the reason to its raw stderr, and that
/// reason lands in the same file with no tag in front of it.
class SharedLogTail {
  SharedLogTail({
    required this.file,
    required this.source,
    required this.onLine,
    this.interval = const Duration(milliseconds: 250),
  });

  final File file;

  /// The tag the writer puts in front of its lines, without the brackets.
  final String source;
  final void Function(String line) onLine;
  final Duration interval;

  late final String _prefix = '[$source]';

  /// The tag another writer puts in front of its own lines.
  static final RegExp _anyTag = RegExp(r'^\[[A-Za-z0-9_-]+\]');

  Timer? _timer;
  int _offset = 0;
  String _partial = '';
  bool _reading = false;

  /// Starts at the end of the file, so a restart prints this run only.
  Future<void> start() async {
    _offset = await _lengthOrZero();
    _timer = Timer.periodic(interval, (_) => unawaited(readNow()));
  }

  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    await readNow();
  }

  /// Reads what the file grew by since the last call. Public for the tests.
  Future<void> readNow() async {
    if (_reading) {
      return;
    }
    _reading = true;
    try {
      final length = await _lengthOrZero();
      if (length < _offset) {
        _offset = 0;
        _partial = '';
      }
      if (length == _offset) {
        return;
      }
      final chunks = await file.openRead(_offset, length).toList();
      _offset = length;
      _partial += utf8.decode(chunks.expand((c) => c).toList(), allowMalformed: true);

      final lines = _partial.split('\n');
      _partial = lines.removeLast();
      for (final line in lines) {
        if (_carries(line)) {
          onLine(line.trimRight());
        }
      }
    } catch (_) {
      // The file comes and goes with a network swap. The next tick reads it.
    } finally {
      _reading = false;
    }
  }

  bool _carries(String line) {
    if (line.trim().isEmpty) {
      return false;
    }
    if (line.startsWith(_prefix)) {
      return true;
    }
    return !_anyTag.hasMatch(line);
  }

  Future<int> _lengthOrZero() async {
    try {
      return await file.length();
    } catch (_) {
      return 0;
    }
  }
}
