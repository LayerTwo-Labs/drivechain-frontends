import 'package:bitwindow/main.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

const _logTitleKey = 'log_title';
const _logPathKey = 'log_path';
const _binaryTypeKey = 'binary_type';

Future<void> openLogWindow(String title, String logPath, BinaryType binaryType) async {
  await GetIt.I.get<WindowProvider>().open(
    SubWindowTypes.logsFor(title),
    arguments: {
      _logTitleKey: title,
      _logPathKey: logPath,
      _binaryTypeKey: binaryType.value,
    },
  );
}

class LogWindowArguments {
  final String title;
  final String logPath;
  final BinaryType? binaryType;

  const LogWindowArguments({required this.title, required this.logPath, this.binaryType});

  factory LogWindowArguments.fromWindowArguments(Map<String, dynamic> arguments, {required String bitwindowLogPath}) {
    final binaryType = arguments[_binaryTypeKey] as int?;
    return LogWindowArguments(
      title: arguments[_logTitleKey] as String? ?? 'Bitwindow Logs',
      logPath: arguments[_logPathKey] as String? ?? bitwindowLogPath,
      binaryType: binaryType == null ? null : BinaryType.valueOf(binaryType),
    );
  }
}
