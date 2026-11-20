import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/utils/file_utils.dart';
import 'package:sidechain_core/utils/native_channel.dart';
import 'package:sidechain_core/utils/share_file.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() => messenger.setMockMethodCallHandler(nativeChannel, null));

  test('a phone asks the native side to share the file', () async {
    MethodCall? call;
    messenger.setMockMethodCallHandler(nativeChannel, (c) async {
      call = c;
      return null;
    });

    await shareFile('/data/bitdrive/note.txt', os: OS.android);

    expect(call?.method, 'shareFile');
    expect(call?.arguments, '/data/bitdrive/note.txt');
  });

  test('a native failure becomes a ShareFileException', () async {
    messenger.setMockMethodCallHandler(nativeChannel, (c) async {
      throw PlatformException(code: 'missing', message: 'no such file');
    });

    await expectLater(
      shareFile('/data/bitdrive/gone.txt', os: OS.ios),
      throwsA(isA<ShareFileException>().having((e) => e.message, 'message', contains('no such file'))),
    );
  });

  test('a desktop has no share sheet', () async {
    await expectLater(shareFile('/tmp/a.txt', os: OS.macos), throwsUnsupportedError);
  });
}
