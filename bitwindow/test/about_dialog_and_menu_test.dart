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
    test('macOS exposes Hide and Show All', () {
      final items = buildVisibilityMenuItems(isMacOS: true);
      expect(items, hasLength(2));
      expect(items[0].label, 'Hide bitwindow');
      expect(
        items[0].shortcut,
        const SingleActivator(LogicalKeyboardKey.keyH, meta: true),
      );
      expect(items[1].label, 'Show All');
      expect(items[1].shortcut, isNull);
    });

    test('non-macOS exposes Minimize with Ctrl+M shortcut', () {
      final items = buildVisibilityMenuItems(isMacOS: false);
      expect(items, hasLength(1));
      expect(items.single.label, 'Minimize bitwindow');
      expect(
        items.single.shortcut,
        const SingleActivator(LogicalKeyboardKey.keyM, meta: true),
      );

      expect(
        items.where((m) => m.label == 'Hide bitwindow' || m.label == 'Show All'),
        isEmpty,
      );
    });
  });
}
