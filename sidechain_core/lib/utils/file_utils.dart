import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// getApplicationSupportDirectory, but creation failures name the broken
/// path component (e.g. ~/.local/share being a symlink to a missing target).
Future<Directory> applicationSupportDir() async {
  try {
    return await getApplicationSupportDirectory();
  } on FileSystemException catch (e) {
    final diagnosis = diagnoseUncreatablePath(e.path);
    if (diagnosis == null) {
      rethrow;
    }
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
  if (path == null || path.isEmpty) {
    return null;
  }
  for (var dir = Directory(path); dir.path != dir.parent.path; dir = dir.parent) {
    final raw = FileSystemEntity.typeSync(dir.path, followLinks: false);
    if (raw == FileSystemEntityType.notFound) {
      continue;
    }
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
/// node binaries (bitcoind, enforcer, drivechaind, …) need to run.
Future<bool> missingRosetta() async {
  if (!Platform.isMacOS) {
    return false;
  }
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

/// The command that shows [path] in the file manager of [os]. Windows takes
/// the switch and the path as one argument, and Linux has no select flag.
(String, List<String>) revealCommand(OS os, String path) => switch (os) {
  OS.macos => ('open', ['-R', path]),
  OS.windows => ('explorer', ['/select,$path']),
  OS.linux => ('xdg-open', [File(path).parent.path]),
};

Future<void> openFile(File file) async {
  if (!await file.exists()) {
    return;
  }

  final (command, args) = revealCommand(getOS(), file.path);
  await Process.run(command, args);
}

enum OS {
  linux,
  macos,
  windows;

  static OS get current {
    if (Platform.isLinux) {
      return OS.linux;
    }
    if (Platform.isMacOS) {
      return OS.macos;
    }
    if (Platform.isWindows) {
      return OS.windows;
    }
    throw 'unsupported operating system: ${Platform.operatingSystem}';
  }
}

OS getOS() {
  if (Platform.isWindows) {
    return OS.windows;
  }
  if (Platform.isMacOS) {
    return OS.macos;
  }
  if (Platform.isLinux) {
    return OS.linux;
  }
  throw Exception('unsupported platform');
}

/// Name of the file manager on this platform, for a menu label.
String fileManagerName() => switch (getOS()) {
  OS.macos => 'Finder',
  OS.windows => 'File Explorer',
  OS.linux => 'File Manager',
};
