import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/utils/append_file.dart';

const _darwin = 0x1 | 0x8 | 0x200 | 0x1000000;
const _linux = 0x1 | 0x400 | 0x40 | 0x80000;

void main() {
  test('iOS opens with the Darwin flags', () {
    expect(appendOpenFlags('ios'), _darwin);
    expect(appendOpenFlags('macos'), _darwin);
  });

  test('Linux and Android open with the Linux flags', () {
    expect(appendOpenFlags('linux'), _linux);
    expect(appendOpenFlags('android'), _linux);
  });

  test('creates a missing file and appends to it', skip: Platform.isWindows, () {
    final dir = Directory.systemTemp.createTempSync('append_file_test');
    addTearDown(() => dir.deleteSync(recursive: true));
    final path = '${dir.path}/new.log';

    final first = AppendFile.open(path)..write('a\n'.codeUnits);
    final second = AppendFile.open(path)..write('b\n'.codeUnits);
    first.write('c\n'.codeUnits);
    first.close();
    second.close();

    expect(File(path).readAsStringSync(), 'a\nb\nc\n');
  });
}
