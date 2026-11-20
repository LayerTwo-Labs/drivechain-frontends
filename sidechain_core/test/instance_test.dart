import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/utils/app_support_dir.dart';
import 'package:sidechain_core/utils/instance.dart';

const _defined = bool.hasEnvironment(portOffsetKey);

void main() {
  group('bitwindowHome', () {
    test('is null when not set', () {
      expect(bitwindowHome({}), isNull);
      expect(bitwindowHome({bitwindowHomeKey: ''}), isNull);
    });

    test('reads the environment', () {
      expect(bitwindowHome({bitwindowHomeKey: '/tmp/a'}), '/tmp/a');
    });

    test('moves the macOS support folder', () {
      expect(
        macosSupportPath({'HOME': '/Users/x', bitwindowHomeKey: '/tmp/a'}, 'bitwindow'),
        '/tmp/a/Library/Application Support/bitwindow',
      );
      expect(macosSupportPath({'HOME': '/Users/x'}, 'bitwindow'), '/Users/x/Library/Application Support/bitwindow');
    });
  });

  test('the Linux support folder ignores XDG_DATA_HOME under BITWINDOW_HOME', () async {
    final tmp = await Directory.systemTemp.createTemp('instance_test');
    addTearDown(() => tmp.delete(recursive: true));
    final dir = await linuxSupportDirectory(
      {'HOME': '/home/x', 'XDG_DATA_HOME': '${tmp.path}/xdg', bitwindowHomeKey: '${tmp.path}/a'},
      'com.layertwolabs.bitwindow',
      'bitwindow',
    );
    expect(dir.path, '${tmp.path}/a/.local/share/com.layertwolabs.bitwindow');
  });

  test('the Windows support folder follows BITWINDOW_HOME', () {
    expect(
      windowsSupportPath({'APPDATA': r'C:\Users\x\AppData\Roaming', bitwindowHomeKey: r'D:\a'}, 'BitWindow'),
      r'D:\a\AppData\Roaming\10520LayertwoLabs\BitWindow',
    );
  });

  group('instanceEnvironment', () {
    test('is empty when nothing is set', skip: _defined, () {
      expect(instanceEnvironment({}), isEmpty);
    });

    test('names both settings', () {
      expect(instanceEnvironment({bitwindowHomeKey: '/tmp/a', portOffsetKey: '1000'}), {
        bitwindowHomeKey: '/tmp/a',
        portOffsetKey: '1000',
      });
    });

    test('passes the regtest servers on', () {
      expect(
        instanceEnvironment({
          regtestEsploraUrlKey: 'http://10.0.2.2:25560',
          regtestEnforcerUrlKey: 'http://10.0.2.2:25550',
          'OTHER': 'x',
        }),
        {regtestEsploraUrlKey: 'http://10.0.2.2:25560', regtestEnforcerUrlKey: 'http://10.0.2.2:25550'},
      );
    });
  });

  group('instancePort', () {
    test('keeps the port when the offset is not set', skip: _defined, () {
      expect(portOffset({}), 0);
      expect(instancePort(30301, {}), 30301);
      expect(instancePort(30400, {portOffsetKey: ''}), 30400);
    });

    test('adds the offset', () {
      final env = {portOffsetKey: '1000'};
      expect(portOffset(env), 1000);
      expect(instancePort(30301, env), 31301);
      expect(instancePort(30400, env), 31400);
    });

    test('reads --dart-define when the environment does not set it', skip: !_defined, () {
      const defined = String.fromEnvironment(portOffsetKey);
      expect(portOffset({}), int.parse(defined));
      expect(instancePort(30301, {}), 30301 + int.parse(defined));
    });

    test('keeps a port of 0', () {
      expect(instancePort(0, {portOffsetKey: '1000'}), 0);
    });

    test('refuses a bad offset', () {
      for (final raw in ['abc', '-1', '7501', '1.5']) {
        expect(() => portOffset({portOffsetKey: raw}), throwsFormatException, reason: raw);
        expect(() => instancePort(30301, {portOffsetKey: raw}), throwsFormatException, reason: raw);
      }
    });
  });

  test('a home set by the app fills an empty environment and reaches a child process', () {
    setBitwindowHome('/app/Library/Application Support/BitWindowHome');

    expect(bitwindowHome(), '/app/Library/Application Support/BitWindowHome');
    expect(instanceEnvironment()[bitwindowHomeKey], '/app/Library/Application Support/BitWindowHome');
    expect(bitwindowHome({}), '/app/Library/Application Support/BitWindowHome');
    expect(bitwindowHome({bitwindowHomeKey: '/env'}), '/env', reason: 'the environment wins');
  });
}
