import 'dart:io';

import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:truthcoin/deeplink/truthcoin_link.dart';

const String _handler = 'x-scheme-handler/$truthcoinScheme';

/// Tells the operating system that this app opens a truthcoin:// link.
/// macOS reads the scheme from Info.plist, so macOS asks for no step here.
Future<void> registerTruthcoinScheme(Logger log) async {
  try {
    if (Platform.isWindows) {
      await _registerWindows();
    } else if (Platform.isLinux) {
      await _registerLinux();
    }
  } catch (error) {
    log.w('the truthcoin:// scheme stays unregistered: $error');
  }
}

Future<void> _registerWindows() async {
  final exe = Platform.resolvedExecutable;
  final key = r'HKCU\Software\Classes\' + truthcoinScheme;
  final commands = <List<String>>[
    ['add', key, '/ve', '/d', 'URL:Truthcoin Protocol', '/f'],
    ['add', key, '/v', 'URL Protocol', '/d', '', '/f'],
    ['add', '$key\\DefaultIcon', '/ve', '/d', '"$exe",0', '/f'],
    ['add', '$key\\shell\\open\\command', '/ve', '/d', '"$exe" "%1"', '/f'],
  ];
  for (final args in commands) {
    final result = await Process.run('reg', args);
    if (result.exitCode != 0) {
      throw Exception('reg ${args.first} $key: ${result.stderr}');
    }
  }
}

Future<void> _registerLinux() async {
  final home = Platform.environment['HOME'];
  if (home == null || home.isEmpty) {
    throw Exception('HOME is empty');
  }
  final dir = Directory(p.join(home, '.local', 'share', 'applications'));
  await dir.create(recursive: true);
  final file = File(p.join(dir.path, 'truthcoin.desktop'));

  if (file.existsSync()) {
    // The installer writes this file with an icon and the AppImage path, so
    // the app adds the scheme and keeps every other line.
    final updated = withSchemeHandler(await file.readAsString());
    if (updated != null) await file.writeAsString(updated);
  } else {
    await file.writeAsString(desktopEntry(linuxExecutable()));
  }

  // The scheme stays invisible to the desktop until the database reads the file.
  await Process.run('update-desktop-database', [dir.path]);
  // The database alone offers the app as one choice. This line makes it the
  // default, so a browser opens the link without a chooser.
  await Process.run('xdg-mime', ['default', 'truthcoin.desktop', _handler]);
}

/// An AppImage runs from a temporary mount that ends with the process, so the
/// launcher a desktop entry must name is the AppImage file itself.
String linuxExecutable() {
  final appImage = Platform.environment['APPIMAGE'];
  return appImage != null && appImage.isNotEmpty ? appImage : Platform.resolvedExecutable;
}

/// Adds the scheme to a desktop entry. Answers null when the entry already
/// claims the scheme.
String? withSchemeHandler(String entry) {
  if (entry.contains(_handler)) return null;

  final lines = entry.split('\n');
  final index = lines.indexWhere((l) => l.startsWith('MimeType='));
  if (index < 0) {
    final body = entry.endsWith('\n') ? entry : '$entry\n';
    return '${body}MimeType=$_handler;\n';
  }

  final value = lines[index].substring('MimeType='.length).trim();
  final separator = value.isEmpty || value.endsWith(';') ? '' : ';';
  lines[index] = 'MimeType=$value$separator$_handler;';
  return lines.join('\n');
}

/// Writes one Exec argument. The freedesktop spec reads a percent as a field
/// code, it quotes an argument that holds a space, and it escapes the
/// backslash twice: once for Exec and once for the desktop-entry string.
String quoteExecArgument(String value) {
  final escaped = value.replaceAll('%', '%%');
  if (!RegExp(r'''[ \t\n"'\\><~|&;\$*?#()`]''').hasMatch(escaped)) return escaped;

  final buffer = StringBuffer('"');
  for (final ch in escaped.split('')) {
    if (ch == r'\') {
      buffer.write(r'\\\\');
    } else if (ch == '"' || ch == '`' || ch == r'$') {
      buffer.write(r'\\');
      buffer.write(ch);
    } else {
      buffer.write(ch);
    }
  }
  buffer.write('"');
  return buffer.toString();
}

/// The freedesktop entry that claims the scheme.
String desktopEntry(String executable) {
  return '''
[Desktop Entry]
Type=Application
Name=Truthcoin
GenericName=Drivechain Sidechain
Comment=Truthcoin Sidechain for Drivechain - Prediction markets
Exec=${quoteExecArgument(executable)} %U
Terminal=false
Categories=Network;P2P;Finance;
StartupWMClass=truthcoin
MimeType=$_handler;
''';
}
