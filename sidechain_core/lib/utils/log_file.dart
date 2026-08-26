import 'dart:io';

import 'package:sidechain_core/gen/orchestrator/v1/orchestrator.pbenum.dart';

/// Name of the one file that the bitwindow frontend, bitwindowd, and
/// drivechaind all append to.
const String sharedLogFileName = 'bitwindow.log';

/// True when the binary appends to the shared log file itself.
bool writesToSharedLog(BinaryType type) => type == BinaryType.BINARY_TYPE_BITWINDOWD;

/// The log file holds the lines of every restart, so cut it back at this size.
const int maxLogFileBytes = 20 * 1024 * 1024;

/// Creates [dir], then returns the log file in it. Empties the file first if
/// it grew past [maxBytes].
Future<File> prepareLogFile(Directory dir, String name, {int maxBytes = maxLogFileBytes}) async {
  await dir.create(recursive: true);

  final file = File([dir.path, name].join(Platform.pathSeparator));
  if (await file.exists() && await file.length() > maxBytes) {
    // Empty the file in place. A detached drivechaind holds an open append
    // handle, and a rename sends its lines to a file that nobody reads.
    await file.writeAsString('');
  }

  return file;
}
