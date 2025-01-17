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
