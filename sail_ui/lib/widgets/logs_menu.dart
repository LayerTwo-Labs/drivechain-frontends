import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sidechain_core/sidechain_core.dart';

String openLogsLabel() => 'Open Logs in ${fileManagerName()}';

Future<void> openLogs() async {
  await openFile(GetIt.I.get<WindowProvider>().logFile);
}

PlatformMenuItem openLogsMenuItem() => PlatformMenuItem(
  label: openLogsLabel(),
  onSelected: openLogs,
);
