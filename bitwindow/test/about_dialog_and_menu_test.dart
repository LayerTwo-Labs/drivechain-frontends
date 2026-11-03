import 'package:bitwindow/pages/root_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  group('encryptionMenuGroups', () {
    List<String?> labels(List<PlatformMenuItem> groups) => [
      for (final group in groups.cast<PlatformMenuItemGroup>())
        for (final member in group.members) member.label,
    ];

    List<PlatformMenuItem> build({required bool encrypted, required bool hasWallet}) => encryptionMenuGroups(
      encrypted: encrypted,
      hasWallet: hasWallet,
      onEncrypt: () {},
      onChangePassword: () {},
      onRemoveEncryption: () {},
    );

    test('gives no group without a wallet, so the macOS menu bar does not fail', () {
      expect(build(encrypted: false, hasWallet: false), isEmpty);
    });

    test('offers Encrypt Wallet for a wallet without a password', () {
      expect(labels(build(encrypted: false, hasWallet: true)), ['Encrypt Wallet']);
    });

    test('offers Change Password and Remove Encryption for an encrypted wallet', () {
      expect(labels(build(encrypted: true, hasWallet: true)), ['Change Password', 'Remove Encryption']);
    });

    test('every group serializes for the macOS menu bar', () {
      for (final encrypted in [false, true]) {
        for (final hasWallet in [false, true]) {
          for (final group in build(encrypted: encrypted, hasWallet: hasWallet)) {
            expect(
              () => group.toChannelRepresentation(
                DefaultPlatformMenuDelegate(),
                getId: (_) => 0,
              ),
              returnsNormally,
            );
          }
        }
      }
    });
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
        reason: 'hide/show-all must not return as menu items — bringing the window back relied on a dock icon that hide() removed',
      );
    });
  });
}
