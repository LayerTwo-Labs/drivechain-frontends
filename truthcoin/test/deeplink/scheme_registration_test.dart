import 'package:flutter_test/flutter_test.dart';
import 'package:truthcoin/deeplink/scheme_registration.dart';

void main() {
  group('desktopEntry', () {
    test('claims the truthcoin scheme', () {
      final entry = desktopEntry('/home/octo/.local/bin/truthcoin.AppImage');

      expect(entry, contains('MimeType=x-scheme-handler/truthcoin;'));
      expect(entry, contains('Exec=/home/octo/.local/bin/truthcoin.AppImage %U'));
      expect(entry, startsWith('[Desktop Entry]'));
      expect(entry, contains('Type=Application'));
    });
  });

  group('withSchemeHandler', () {
    test('adds a MimeType line to an entry that holds none', () {
      const entry = '[Desktop Entry]\nType=Application\nExec=/opt/truthcoin %U\n';

      expect(
        withSchemeHandler(entry),
        '[Desktop Entry]\nType=Application\nExec=/opt/truthcoin %U\nMimeType=x-scheme-handler/truthcoin;\n',
      );
    });

    test('adds the scheme to a MimeType line that holds another type', () {
      const entry = '[Desktop Entry]\nMimeType=text/plain;\nIcon=/opt/icon.png\n';

      expect(
        withSchemeHandler(entry),
        '[Desktop Entry]\nMimeType=text/plain;x-scheme-handler/truthcoin;\nIcon=/opt/icon.png\n',
      );
    });

    test('adds the separator when the MimeType line ends without one', () {
      const entry = '[Desktop Entry]\nMimeType=text/plain\n';

      expect(withSchemeHandler(entry), '[Desktop Entry]\nMimeType=text/plain;x-scheme-handler/truthcoin;\n');
    });

    test('keeps every other line of the installer entry', () {
      const entry =
          '[Desktop Entry]\nName=Truthcoin\nExec=/home/octo/.local/bin/truthcoin.AppImage %U\nIcon=/home/octo/.local/share/icons/truthcoin.png\n';
      final updated = withSchemeHandler(entry)!;

      expect(updated, contains('Icon=/home/octo/.local/share/icons/truthcoin.png'));
      expect(updated, contains('Exec=/home/octo/.local/bin/truthcoin.AppImage %U'));
      expect(updated, contains('MimeType=x-scheme-handler/truthcoin;'));
    });

    test('answers null when the entry already claims the scheme', () {
      const entry = '[Desktop Entry]\nMimeType=x-scheme-handler/truthcoin;\n';

      expect(withSchemeHandler(entry), isNull);
    });
  });

  group('quoteExecArgument', () {
    test('keeps a plain path unquoted', () {
      expect(quoteExecArgument('/opt/truthcoin/truthcoin'), '/opt/truthcoin/truthcoin');
    });

    test('quotes a path that holds a space', () {
      expect(
        quoteExecArgument('/home/octo/Truthcoin Wallet.AppImage'),
        '"/home/octo/Truthcoin Wallet.AppImage"',
      );
    });

    test('escapes a quote, a dollar and a backtick', () {
      expect(quoteExecArgument(r'/opt/a b"c'), r'"/opt/a b\\"c"');
      expect(quoteExecArgument(r'/opt/a b$c'), r'"/opt/a b\\$c"');
      expect(quoteExecArgument('/opt/a b`c'), r'"/opt/a b\\`c"');
    });

    test('escapes a backslash four times', () {
      expect(quoteExecArgument(r'/opt/a\b'), r'"/opt/a\\\\b"');
    });

    test('quotes a path that holds an apostrophe', () {
      expect(quoteExecArgument("/mnt/apps/Truthcoin's.AppImage"), '"/mnt/apps/Truthcoin\'s.AppImage"');
    });

    test('doubles a percent, which Exec reads as a field code', () {
      expect(quoteExecArgument('/opt/Truthcoin%20Wallet.AppImage'), '/opt/Truthcoin%%20Wallet.AppImage');
      expect(quoteExecArgument('/opt/a b%c'), '"/opt/a b%%c"');
    });

    test('the entry quotes the executable', () {
      expect(
        desktopEntry('/home/octo/Truthcoin Wallet.AppImage'),
        contains('Exec="/home/octo/Truthcoin Wallet.AppImage" %U'),
      );
    });
  });
}
