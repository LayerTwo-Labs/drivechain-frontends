// Regression for #1738: toolbar menu reset every 5s.
//
// Root cause: `BlockchainProvider` ticks every 5s, which triggers
// `_onProviderChanged` on `_RootPageState`, which calls `setState`. The
// `build()` method returned a fresh `List<PlatformMenuItem>` on every call.
// On macOS, `PlatformMenuBar` pushes any new identity into the native NSMenu,
// which the user perceives as a flicker / menu reset.
//
// Fix (commit 6949f401): cache the built list and only invalidate when
// `_isWalletEncrypted` changes. The exact pattern in root_page.dart:
//
//   if (_cachedMenuListEncrypted != _isWalletEncrypted) {
//     _cachedMenuListEncrypted = _isWalletEncrypted;
//     _cachedMenuList = null;
//   }
//   ...
//   menus: _cachedMenuList ??= [ ... build list ... ],
//
// The list literal in RootPage captures `context`, `app`, `_clientSettings`,
// `_routerKey` etc. — extracting it to a testable top-level function would
// require threading every captured value through as a parameter, which is
// invasive and gains nothing. Instead, this test exercises the cache
// mechanism in isolation: build a stateful widget that uses the same
// pattern and verify the identity invariants the fix relies on.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _MenuCacheHost extends StatefulWidget {
  const _MenuCacheHost();

  @override
  State<_MenuCacheHost> createState() => _MenuCacheHostState();
}

class _MenuCacheHostState extends State<_MenuCacheHost> {
  bool isEncrypted = false;
  int extraTickCount = 0;
  List<PlatformMenuItem>? _cachedMenuList;
  bool? _cachedMenuListEncrypted;

  List<PlatformMenuItem> get currentMenus => _cachedMenuList!;

  void bumpUnrelatedRebuild() => setState(() => extraTickCount++);
  void flipEncryption() => setState(() => isEncrypted = !isEncrypted);

  @override
  Widget build(BuildContext context) {
    if (_cachedMenuListEncrypted != isEncrypted) {
      _cachedMenuListEncrypted = isEncrypted;
      _cachedMenuList = null;
    }
    _cachedMenuList ??= [
      const PlatformMenuItem(label: 'Static A'),
      if (isEncrypted) const PlatformMenuItem(label: 'Change Password'),
      if (!isEncrypted) const PlatformMenuItem(label: 'Encrypt Wallet'),
    ];
    return Text('tick=$extraTickCount enc=$isEncrypted');
  }
}

void main() {
  testWidgets(
    'menu list identity is preserved across rebuilds when encryption unchanged',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: _MenuCacheHost()));
      final state = tester.state<_MenuCacheHostState>(find.byType(_MenuCacheHost));
      final firstList = state.currentMenus;

      // Simulate the 5s BlockchainProvider tick: setState fires but
      // encryption status is unchanged.
      state.bumpUnrelatedRebuild();
      await tester.pump();
      state.bumpUnrelatedRebuild();
      await tester.pump();

      expect(
        identical(state.currentMenus, firstList),
        isTrue,
        reason: 'cache must return the same list instance across unrelated rebuilds',
      );
    },
  );

  testWidgets(
    'menu list rebuilds exactly when encryption status changes',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: _MenuCacheHost()));
      final state = tester.state<_MenuCacheHostState>(find.byType(_MenuCacheHost));
      final beforeFlip = state.currentMenus;

      state.flipEncryption();
      await tester.pump();

      expect(
        identical(state.currentMenus, beforeFlip),
        isFalse,
        reason: 'encryption flip must invalidate the cache',
      );

      final afterFlip = state.currentMenus;
      state.bumpUnrelatedRebuild();
      await tester.pump();

      expect(
        identical(state.currentMenus, afterFlip),
        isTrue,
        reason: 'unrelated rebuild after flip must still reuse the new cached list',
      );
    },
  );
}
