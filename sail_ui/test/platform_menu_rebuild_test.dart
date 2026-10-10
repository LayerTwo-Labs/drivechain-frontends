import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'rebuild with the same menus does not send the macOS menu again',
    (tester) async {
      var setMenusCalls = 0;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.menu, (call) async {
        if (call.method == 'Menu.setMenus') {
          setMenusCalls++;
        }
        return null;
      });

      final menus = <PlatformMenuItem>[
        const PlatformMenu(
          label: 'bitwindow',
          menus: [PlatformMenuItem(label: 'About')],
        ),
      ];
      late StateSetter rebuild;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return CrossPlatformMenuBar(menus: menus, child: const SizedBox());
          },
        ),
      );
      // PlatformMenuBar.initState does not record the menus, so the first rebuild always sends them.
      rebuild(() {});
      await tester.pump();
      final callsAfterFirstRebuild = setMenusCalls;

      rebuild(() {});
      await tester.pump();

      expect(setMenusCalls, callsAfterFirstRebuild);
    },
    skip: !Platform.isMacOS,
  );
}
