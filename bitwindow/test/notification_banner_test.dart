import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized({
    'flutter.test.automatic_wait_for_timers': 'false',
  });

  Future<NotificationProvider> freshProvider() async {
    await registerTestDependencies();
    if (GetIt.I.isRegistered<NotificationProvider>()) {
      GetIt.I.unregister<NotificationProvider>();
    }
    final provider = NotificationProvider();
    GetIt.I.registerSingleton<NotificationProvider>(provider);
    // Let the constructor's history load settle, then start from empty — the
    // mock store is shared across tests.
    await Future<void>.delayed(Duration.zero);
    await provider.clearAll();
    return provider;
  }

  void addBanner(NotificationProvider p, String id, String title) {
    p.add(
      id: id,
      title: title,
      content: 'act on it →',
      dialogType: DialogType.info,
      style: NotificationStyle.banner,
    );
  }

  group('NotificationItem persistence', () {
    test('round-trips the banner fields', () {
      final item = NotificationItem(
        id: 'drynet-upgrade-drynet3',
        title: 'drynet3 is out',
        content: 'Switch over →',
        dialogType: DialogType.info,
        timestamp: DateTime.now(),
        style: NotificationStyle.banner,
        action: 'drynet_upgrade',
        read: true,
      );

      final restored = NotificationItem.fromMap(item.toMap());

      expect(restored.style, NotificationStyle.banner);
      expect(restored.action, 'drynet_upgrade');
      expect(restored.read, isTrue);
      expect(restored.id, item.id);
    });

    test('history stored before banners existed still loads', () {
      final restored = NotificationItem.fromMap({
        'id': 'old',
        'title': 'legacy',
        'content': 'stored by an earlier build',
        'dialogType': 0,
        'timestamp': DateTime.now().toIso8601String(),
        'links': const [],
      });

      expect(restored.style, NotificationStyle.toast);
      expect(restored.action, '');
      expect(restored.read, isFalse);
    });
  });

  group('NotificationProvider banners', () {
    test('only the newest unread banner is active', () async {
      final p = await freshProvider();
      addBanner(p, 'first', 'drynet3 is out');
      addBanner(p, 'second', 'drynet4 is out');

      expect(p.activeBanner?.id, 'second');
    });

    test('marking read falls through to the next banner, then to none', () async {
      final p = await freshProvider();
      addBanner(p, 'first', 'drynet3 is out');
      addBanner(p, 'second', 'drynet4 is out');

      await p.markRead('second');
      expect(p.activeBanner?.id, 'first');

      await p.markRead('first');
      expect(p.activeBanner, isNull);
    });

    test('a banner dismissed before restart stays dismissed', () async {
      final p = await freshProvider();
      addBanner(p, 'drynet-upgrade-drynet3', 'drynet3 is out');
      await p.markRead('drynet-upgrade-drynet3');

      // A fresh provider re-adds it from its 15s poll before the async history
      // load lands — the load must not resurrect it as unread.
      final restarted = NotificationProvider();
      addBanner(restarted, 'drynet-upgrade-drynet3', 'drynet3 is out');
      await Future<void>.delayed(Duration.zero);

      expect(restarted.activeBanner, isNull);
    });

    test('a read banner stays in the bell history', () async {
      final p = await freshProvider();
      addBanner(p, 'first', 'drynet3 is out');

      await p.markRead('first');

      expect(p.history.map((n) => n.id), contains('first'));
    });

    test('re-adding the same id is a no-op, so polling cannot stack copies', () async {
      final p = await freshProvider();
      addBanner(p, 'drynet-upgrade-drynet3', 'drynet3 is out');
      addBanner(p, 'drynet-upgrade-drynet3', 'drynet3 is out');

      expect(p.history.where((n) => n.id == 'drynet-upgrade-drynet3'), hasLength(1));
    });

    test('a banner raises no toast', () async {
      final p = await freshProvider();
      addBanner(p, 'first', 'drynet3 is out');

      expect(p.notifications, isEmpty);
    });
  });

  group('NotificationBanner widget', () {
    testWidgets('renders one strip at a time and clears once read', (tester) async {
      final p = await freshProvider();
      addBanner(p, 'first', 'drynet3 is out');
      addBanner(p, 'second', 'drynet4 is out');

      await tester.pumpSailPage(const Column(children: [NotificationBanner()]));

      expect(find.text('drynet4 is out'), findsOneWidget);
      expect(find.text('drynet3 is out'), findsNothing);

      await p.markRead('second');
      await tester.pump();
      expect(find.text('drynet3 is out'), findsOneWidget);

      await p.markRead('first');
      await tester.pump();
      expect(find.text('drynet3 is out'), findsNothing);
    });

    testWidgets('the ✕ marks it read without running the action', (tester) async {
      final p = await freshProvider();
      var ran = false;
      if (GetIt.I.isRegistered<NotificationActions>()) {
        GetIt.I.unregister<NotificationActions>();
      }
      GetIt.I.registerSingleton<NotificationActions>(
        NotificationActions({'act': (_) async => ran = true}),
      );
      p.add(
        id: 'first',
        title: 'drynet3 is out',
        content: 'Switch over →',
        dialogType: DialogType.info,
        style: NotificationStyle.banner,
        action: 'act',
      );

      await tester.pumpSailPage(const Column(children: [NotificationBanner()]));
      await tester.tap(find.text('✕'));
      await tester.pump();

      expect(ran, isFalse);
      expect(p.activeBanner, isNull);
    });
  });
}
