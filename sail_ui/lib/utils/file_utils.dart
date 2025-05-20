import 'dart:io';

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
