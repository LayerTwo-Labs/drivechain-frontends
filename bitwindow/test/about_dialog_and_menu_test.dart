import 'package:bitwindow/pages/root_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized({
    'flutter.test.automatic_wait_for_timers': 'false',
  });

  testWidgets('About dialog renders refreshed copy', (tester) async {
    await tester.pumpSailPage(const AboutBitwindowDialog());

    expect(
      find.textContaining('BitWindow — GUI for the BIP300/301 sidechain enforcer.'),
      findsOneWidget,
    );
    expect(find.textContaining('2009-2026 The Drivechain developers'), findsOneWidget);
    expect(find.textContaining('2009-2026 The Bitcoin Core developers'), findsOneWidget);

    expect(find.textContaining('Drivechain version v0.47.00.0-unk (64-bit)'), findsNothing);
    expect(find.textContaining('2009-2024'), findsNothing);
  });

  group('buildVisibilityMenuItems', () {
    test('exposes Minimize with Cmd/Ctrl+M on every platform', () {
      // Issue #1657: macOS used to call windowManager.hide(), which strips
      // the dock icon and leaves users with no first-party way back into
      // the app. Minimize is the only path now — keep the menu surface
      // identical across platforms so the shortcut and label match.
      final items = buildVisibilityMenuItems();
      expect(items, hasLength(1));
      expect(items.single.label, 'Minimize bitwindow');
      expect(
        items.single.shortcut,
        const SingleActivator(LogicalKeyboardKey.keyM, meta: true),
      );

      expect(
        items.where((m) => m.label == 'Hide bitwindow' || m.label == 'Show All'),
        isEmpty,
        reason:
            'hide/show-all must not return as menu items — bringing the window back relied on a dock icon that hide() removed',
      );
    });
  });
}
