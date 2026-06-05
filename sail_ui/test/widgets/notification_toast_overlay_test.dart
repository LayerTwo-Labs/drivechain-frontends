import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

class _MockStore implements KeyValueStore {
  final Map<String, String> db = {};
  @override
  Future<String?> getString(String key) async => db[key];
  @override
  Future<void> setString(String key, String value) async => db[key] = value;
  @override
  Future<void> delete(String key) async => db.remove(key);
}

void main() {
  setUp(() async {
    await GetIt.I.reset();
    final log = Logger(level: Level.warning);
    GetIt.I.registerSingleton<Logger>(log);
    GetIt.I.registerSingleton<ClientSettings>(ClientSettings(store: _MockStore(), log: log));
    GetIt.I.registerSingleton<NotificationProvider>(NotificationProvider());
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  testWidgets('renders an added notification with its link in the overlay', (tester) async {
    await tester.pumpWidget(
      SailApp(
        dense: false,
        accentColor: SailColorScheme.orange,
        log: GetIt.I.get<Logger>(),
        builder: (_) => const MaterialApp(
          home: Scaffold(
            body: Stack(children: [NotificationToastOverlay()]),
          ),
        ),
      ),
    );
    await tester.pump();

    GetIt.I.get<NotificationProvider>().add(
      title: 'Transaction sent',
      content: 'abc',
      dialogType: DialogType.info,
      links: const [NotificationLink(text: 'View transaction', url: 'https://x/tx/abc')],
    );
    await tester.pump();

    expect(find.text('Transaction sent'), findsOneWidget);
    expect(find.text('View transaction'), findsOneWidget);

    // Drain the 5s auto-dismiss timer so the test ends without a pending timer.
    await tester.pump(const Duration(seconds: 6));
    expect(find.text('Transaction sent'), findsNothing);
  });
}
