import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:sidechain_core/utils/file_utils.dart';

/// APPLICATION_ID in linux/CMakeLists.txt of each app, by executable name.
const linuxApplicationIds = {
  'bitwindow': 'com.layertwolabs.bitwindow',
  'thunder': 'com.layertwolabs.thunder',
  'bitnames': 'com.layertwolabs.bitnames',
  'bitassets': 'com.layertwolabs.bitassets',
  'zside': 'com.layertwolabs.zside',
  'truthcoin': 'com.layertwolabs.truthcoin',
  'coinshift': 'com.layertwolabs.coinshift',
  'photon': 'com.layertwolabs.photon',
  'bbc': 'com.layertwolabs.bbc',
};

/// CompanyName in windows/runner/Runner.rc of each app.
const windowsCompanyName = '10520LayertwoLabs';

/// ProductName in windows/runner/Runner.rc of each app, by executable name.
const windowsProductNames = {
  'BitWindows': 'BitWindow',
  'Thunder': 'Thunder',
  'BitNames': 'BitNames',
  'BitAssets': 'BitAssets',
  'ZSide': 'ZSide',
  'Truthcoin': 'Truthcoin',
  'Coinshift': 'Coinshift',
  'Photon': 'Photon',
  'Big Block Covenant': 'Big Block Covenant',
};

const _windowsMaxPath = 260;

/// The folder that path_provider getApplicationSupportDirectory returned for this app.
/// Makes the folder if it does not exist.
Future<Directory> appSupportDirectory() async {
  final env = Platform.environment;
  switch (getOS()) {
    case OS.macos:
      final infoPlist = File(path.join(path.dirname(path.dirname(Platform.resolvedExecutable)), 'Info.plist'));
      final dir = Directory(macosSupportPath(env, macosBundleIdentifier(await infoPlist.readAsString())));
      return dir.create(recursive: true);
    case OS.linux:
      final executable = path.basenameWithoutExtension(await File('/proc/self/exe').resolveSymbolicLinks());
      final applicationId = linuxApplicationIds[executable];
      if (applicationId == null) {
        throw StateError('no Linux application id for executable "$executable"');
      }
      return linuxSupportDirectory(env, applicationId, executable);
    case OS.windows:
      final executable = path.basenameWithoutExtension(Platform.resolvedExecutable);
      final productName = windowsProductNames[executable];
      if (productName == null) {
        throw StateError('no Windows product name for executable "$executable"');
      }
      final dir = Directory(windowsSupportPath(env, productName));
      if (dir.path.length <= _windowsMaxPath) {
        await dir.create(recursive: true);
      }
      return dir;
  }
}

/// CFBundleIdentifier of an XML Info.plist.
String macosBundleIdentifier(String infoPlist) {
  final match = RegExp(r'<key>CFBundleIdentifier</key>\s*<string>([^<]+)</string>').firstMatch(infoPlist);
  if (match == null) {
    throw const FormatException('Info.plist has no CFBundleIdentifier');
  }
  return match.group(1)!;
}

String macosSupportPath(Map<String, String> env, String bundleIdentifier) =>
    path.join(_home(env), 'Library', 'Application Support', bundleIdentifier);

/// The application id folder under the XDG data home. An old folder named for the
/// executable wins when only that one exists.
Future<Directory> linuxSupportDirectory(Map<String, String> env, String applicationId, String executable) async {
  final xdgDataHome = env['XDG_DATA_HOME'] ?? '';
  final dataHome = xdgDataHome.isEmpty ? path.join(_home(env), '.local/share') : xdgDataHome;

  final dir = Directory(path.join(dataHome, applicationId));
  if (dir.existsSync()) {
    return dir;
  }
  final legacy = Directory(path.join(dataHome, executable));
  if (legacy.existsSync()) {
    return legacy;
  }
  return dir.create(recursive: true);
}

String windowsSupportPath(Map<String, String> env, String productName) {
  final appData = env['APPDATA'] ?? '';
  if (appData.isEmpty) {
    throw StateError('APPDATA is not set');
  }
  return path.windows.join(appData, windowsCompanyName, productName);
}

String _home(Map<String, String> env) {
  final home = env['HOME'] ?? '';
  if (home.isEmpty) {
    throw StateError('HOME is not set');
  }
  return home;
}
