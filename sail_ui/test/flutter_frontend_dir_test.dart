import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sail_ui/sail_ui.dart';

void main() {
  group('flutterFrontendDirFor — bitWindow Linux subdir', () {
    const home = '/home/tester';

    test('Linux uses bitwindow subdir (no com.layertwolabs prefix)', () {
      final dir = flutterFrontendDirFor(BinaryType.bitWindow, OS.linux, home);
      expect(dir, p.join(home, '.local', 'share', 'bitwindow'));
      expect(dir, isNot(contains('com.layertwolabs.bitwindow')));
    });

    test('macOS keeps "bitwindow" Application Support folder', () {
      expect(
        flutterFrontendDirFor(BinaryType.bitWindow, OS.macos, home),
        p.join(home, 'Library', 'Application Support', 'bitwindow'),
      );
    });

    test('Windows keeps 10520LayertwoLabs/BitWindow', () {
      expect(
        flutterFrontendDirFor(BinaryType.bitWindow, OS.windows, home),
        p.join(home, 'AppData', 'Roaming', '10520LayertwoLabs', 'BitWindow'),
      );
    });
  });

  test('flutterFrontendDirFor returns null for binaries without a Flutter frontend', () {
    expect(
      flutterFrontendDirFor(BinaryType.bitcoinCore, OS.linux, '/home/x'),
      isNull,
    );
    expect(
      flutterFrontendDirFor(BinaryType.enforcer, OS.linux, '/home/x'),
      isNull,
    );
  });
}
