import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// getApplicationSupportDirectory, but creation failures name the broken
/// path component (e.g. ~/.local/share being a symlink to a missing target).
Future<Directory> applicationSupportDir() async {
  try {
    return await getApplicationSupportDirectory();
  } on FileSystemException catch (e) {
    final diagnosis = diagnoseUncreatablePath(e.path);
    if (diagnosis == null) rethrow;
    throw FileSystemException(
      'Could not create the application data directory: $diagnosis. Fix or remove it, then restart.',
      e.path,
      e.osError,
    );
  }
}

/// Walks up from [path] to the first component that exists and explains why
/// it blocks creating the rest. Returns null when nothing obvious is wrong.
String? diagnoseUncreatablePath(String? path) {
  if (path == null || path.isEmpty) return null;
  for (var dir = Directory(path); dir.path != dir.parent.path; dir = dir.parent) {
    final raw = FileSystemEntity.typeSync(dir.path, followLinks: false);
    if (raw == FileSystemEntityType.notFound) continue;
    if (raw == FileSystemEntityType.link) {
      final resolved = FileSystemEntity.typeSync(dir.path);
      if (resolved == FileSystemEntityType.notFound) {
        return '${dir.path} is a symlink to "${Link(dir.path).targetSync()}", which does not exist';
      }
      if (resolved == FileSystemEntityType.file) {
        return '${dir.path} is a symlink to a file, not a directory';
      }
      return null;
    }
    if (raw == FileSystemEntityType.file) {
      return '${dir.path} is a file, not a directory';
    }
    return null;
  }
  return null;
}

/// True on an Apple Silicon Mac without Rosetta 2, which the bundled x86_64
/// node binaries (bitcoind, enforcer, orchestratord, …) need to run.
Future<bool> missingRosetta() async {
  if (!Platform.isMacOS) return false;
  try {
    final result = await Process.run('/usr/bin/arch', ['-x86_64', '/usr/bin/true']);
    return result.exitCode != 0;
  } catch (_) {
    return false;
  }
}

Future<void> openDir(Directory dir) async {
  final os = getOS();

  final command = switch (os) {
    OS.linux => 'xdg-open',
    OS.macos => 'open',
    OS.windows => 'explorer',
  };

  await Process.run(command, [dir.path]);
}

Future<void> openFile(File file) async {
  final os = getOS();

  if (!await file.exists()) return;

  switch (os) {
    case OS.macos:
      // On macOS, use 'open -R' to reveal and select the file
      await Process.run('open', ['-R', file.path]);
    case OS.windows:
      // On Windows, use 'explorer /select,' to select the file
      await Process.run('explorer', ['/select,', file.path]);
    case OS.linux:
      // On Linux, first try to use xdg-open with the file
      // If that doesn't work, fall back to opening the directory
      try {
        await Process.run('xdg-open', [file.path]);
      } catch (e) {
        await openDir(file.parent);
      }
  }
}

enum OS {
  linux,
  macos,
  windows;

  static OS get current {
    if (Platform.isLinux) return OS.linux;
    if (Platform.isMacOS) return OS.macos;
    if (Platform.isWindows) return OS.windows;
    throw 'unsupported operating system: ${Platform.operatingSystem}';
  }
}

OS getOS() {
  if (Platform.isWindows) return OS.windows;
  if (Platform.isMacOS) return OS.macos;
  if (Platform.isLinux) return OS.linux;
  throw Exception('unsupported platform');
}
