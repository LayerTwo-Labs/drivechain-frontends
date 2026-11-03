import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/utils/file_utils.dart';
import 'package:sidechain_core/utils/open_url.dart';

void _expectCommand((String, List<String>) actual, String executable, List<String> arguments) {
  expect(actual.$1, executable);
  expect(actual.$2, arguments);
}

void main() {
  final uri = Uri.parse('https://drivechain.info/a?b=c d');

  test('openUrlCommand uses open on macOS', () {
    _expectCommand(openUrlCommand(OS.macos, uri), 'open', ['https://drivechain.info/a?b=c%20d']);
  });

  test('openUrlCommand uses xdg-open on Linux', () {
    _expectCommand(openUrlCommand(OS.linux, uri), 'xdg-open', ['https://drivechain.info/a?b=c%20d']);
  });

  test('openUrlCommand uses the url.dll handler on Windows', () {
    _expectCommand(
      openUrlCommand(OS.windows, uri),
      'rundll32',
      ['url.dll,FileProtocolHandler', 'https://drivechain.info/a?b=c%20d'],
    );
  });

  test('openUrlCommand keeps a file URI', () {
    _expectCommand(openUrlCommand(OS.macos, Uri.file('/tmp/paper wallet.pdf')), 'open', [
      'file:///tmp/paper%20wallet.pdf',
    ]);
  });

  group('openUrl', () {
    final calls = <(String, List<String>)>[];
    var exitCode = 0;

    setUp(() {
      calls.clear();
      exitCode = 0;
      openUrlProcessRunner = (executable, arguments) async {
        calls.add((executable, arguments));
        return ProcessResult(1, exitCode, '', 'no handler');
      };
    });
    tearDown(() => openUrlProcessRunner = Process.run);

    test('runs the command of this OS', () async {
      await openUrl(uri);
      expect(calls, hasLength(1));
      final (executable, arguments) = openUrlCommand(getOS(), uri);
      _expectCommand(calls.single, executable, arguments);
    });

    test('fails on a non-zero exit code', () async {
      exitCode = 1;
      await expectLater(
        openUrl(uri),
        throwsA(isA<OpenUrlException>().having((e) => e.message, 'message', contains('no handler'))),
      );
    });

    test('rejects a link without a scheme', () async {
      await expectLater(openUrl(Uri.parse('drivechain.info')), throwsA(isA<OpenUrlException>()));
      expect(calls, isEmpty);
    });
  });
}
