import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:sidechain_core/config/binaries.dart';
import 'package:sidechain_core/utils/app_support_dir.dart';
import 'package:sidechain_core/utils/file_utils.dart';

const _apps = {
  'bitwindow': BinaryType.BINARY_TYPE_BITWINDOWD,
  'thunder': BinaryType.BINARY_TYPE_THUNDER,
  'bitnames': BinaryType.BINARY_TYPE_BITNAMES,
  'bitassets': BinaryType.BINARY_TYPE_BITASSETS,
  'zside': BinaryType.BINARY_TYPE_ZSIDE,
  'truthcoin': BinaryType.BINARY_TYPE_TRUTHCOIN,
  'coinshift': BinaryType.BINARY_TYPE_COINSHIFT,
  'photon': BinaryType.BINARY_TYPE_PHOTON,
  'bbc': null,
};

String _read(String app, String file) => File(path.join('..', app, file)).readAsStringSync();

String _cmakeSet(String cmake, String name) => RegExp('set\\($name "([^"]+)"\\)').firstMatch(cmake)!.group(1)!;

String _rcValue(String rc, String key) => RegExp('VALUE "$key", "([^"]+)"').firstMatch(rc)!.group(1)!;

void main() {
  group('macOS', () {
    test('appends the bundle id to Application Support', () {
      expect(
        macosSupportPath({'HOME': '/Users/x'}, 'com.layertwolabs.thunder'),
        '/Users/x/Library/Application Support/com.layertwolabs.thunder',
      );
    });

    test('reads CFBundleIdentifier from Info.plist', () {
      const plist =
          '<dict>\n\t<key>CFBundleExecutable</key>\n\t<string>BitWindow</string>\n'
          '\t<key>CFBundleIdentifier</key>\n\t<string>bitwindow</string>\n</dict>';
      expect(macosBundleIdentifier(plist), 'bitwindow');
    });

    test('fails when Info.plist has no CFBundleIdentifier', () {
      expect(() => macosBundleIdentifier('<dict></dict>'), throwsFormatException);
    });

    test('fails without HOME', () {
      expect(() => macosSupportPath({}, 'bitwindow'), throwsStateError);
    });
  });

  group('Linux', () {
    late Directory tmp;
    setUp(() async => tmp = await Directory.systemTemp.createTemp('app_support_dir_test'));
    tearDown(() => tmp.delete(recursive: true));

    test('uses XDG_DATA_HOME when set', () async {
      final dir = await linuxSupportDirectory({'XDG_DATA_HOME': tmp.path, 'HOME': '/nowhere'}, 'com.x.app', 'app');
      expect(dir.path, path.join(tmp.path, 'com.x.app'));
      expect(dir.existsSync(), isTrue);
    });

    test('uses HOME/.local/share when XDG_DATA_HOME is unset or empty', () async {
      for (final env in [
        {'HOME': tmp.path},
        {'HOME': tmp.path, 'XDG_DATA_HOME': ''},
      ]) {
        final dir = await linuxSupportDirectory(env, 'com.x.app', 'app');
        expect(dir.path, '${tmp.path}/.local/share/com.x.app');
        expect(dir.existsSync(), isTrue);
      }
    });

    test('uses the executable folder when only that one exists', () async {
      Directory(path.join(tmp.path, 'app')).createSync();
      final dir = await linuxSupportDirectory({'XDG_DATA_HOME': tmp.path}, 'com.x.app', 'app');
      expect(dir.path, path.join(tmp.path, 'app'));
      expect(Directory(path.join(tmp.path, 'com.x.app')).existsSync(), isFalse);
    });

    test('uses the application id folder when both exist', () async {
      Directory(path.join(tmp.path, 'app')).createSync();
      Directory(path.join(tmp.path, 'com.x.app')).createSync();
      final dir = await linuxSupportDirectory({'XDG_DATA_HOME': tmp.path}, 'com.x.app', 'app');
      expect(dir.path, path.join(tmp.path, 'com.x.app'));
    });

    test('uses the application id link that bitwindowd leaves', () async {
      Directory(path.join(tmp.path, 'bitwindow')).createSync();
      Link(path.join(tmp.path, 'com.layertwolabs.bitwindow')).createSync(path.join(tmp.path, 'bitwindow'));
      final dir = await linuxSupportDirectory({'XDG_DATA_HOME': tmp.path}, 'com.layertwolabs.bitwindow', 'bitwindow');
      expect(dir.path, path.join(tmp.path, 'com.layertwolabs.bitwindow'));
    });
  });

  group('Windows', () {
    test('joins APPDATA, company and product', () {
      expect(
        windowsSupportPath({'APPDATA': r'C:\Users\x\AppData\Roaming'}, 'BitWindow'),
        r'C:\Users\x\AppData\Roaming\10520LayertwoLabs\BitWindow',
      );
    });

    test('fails without APPDATA', () {
      expect(() => windowsSupportPath({}, 'BitWindow'), throwsStateError);
      expect(() => windowsSupportPath({'APPDATA': ''}, 'BitWindow'), throwsStateError);
    });
  });

  group('app config matches the tables', () {
    for (final MapEntry(key: app, value: binaryType) in _apps.entries) {
      test(app, () {
        final linuxCmake = _read(app, 'linux/CMakeLists.txt');
        expect(linuxApplicationIds[_cmakeSet(linuxCmake, 'BINARY_NAME')], _cmakeSet(linuxCmake, 'APPLICATION_ID'));

        final windowsExecutable = _cmakeSet(_read(app, 'windows/CMakeLists.txt'), 'BINARY_NAME');
        final rc = _read(app, 'windows/runner/Runner.rc');
        expect(_rcValue(rc, 'CompanyName'), windowsCompanyName);
        expect(windowsProductNames[windowsExecutable], _rcValue(rc, 'ProductName'));
        expect(_rcValue(rc, 'ProductName'), isNot(matches(RegExp(r'[<>:"/\\|?*]|[ .]$'))));

        final bundleId = RegExp(r'PRODUCT_BUNDLE_IDENTIFIER = (\S+)')
            .firstMatch(_read(app, 'macos/Runner/Configs/AppInfo.xcconfig'))!;
        if (binaryType != null) {
          expect(
            flutterFrontendDirFor(binaryType, OS.macos, '/Users/x'),
            macosSupportPath({'HOME': '/Users/x'}, bundleId.group(1)!),
          );
        }
        expect(_read(app, 'macos/Runner/Info.plist'), contains('<string>\$(PRODUCT_BUNDLE_IDENTIFIER)</string>'));
        for (final entitlements in ['DebugProfile', 'Release']) {
          expect(
            _read(app, 'macos/Runner/$entitlements.entitlements'),
            matches(RegExp(r'<key>com.apple.security.app-sandbox</key>\s*<false/>')),
          );
        }
      });
    }

    test('every table entry belongs to an app', () {
      expect(linuxApplicationIds, hasLength(_apps.length));
      expect(windowsProductNames, hasLength(_apps.length));
    });
  });
}
