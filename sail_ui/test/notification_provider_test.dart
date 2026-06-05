import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

class MockStore implements KeyValueStore {
  final Map<String, String> db = {};

  @override
  Future<String?> getString(String key) async => db[key];

  @override
  Future<void> setString(String key, String value) async {
    db[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    db.remove(key);
  }
}

NotificationItem _item({
  String id = '1',
  String title = 'Sent',
  String content = 'Sent 1 BTC',
  DialogType type = DialogType.info,
  List<NotificationLink> links = const [],
}) {
  return NotificationItem(
    id: id,
    title: title,
    content: content,
    dialogType: type,
    timestamp: DateTime.utc(2026, 1, 2, 3, 4, 5),
    links: links,
  );
}

// Let fire-and-forget _persist/_load futures settle.
Future<void> _flush() => Future<void>.delayed(Duration.zero);

void main() {
  late MockStore store;

  setUp(() async {
    await GetIt.I.reset();
    final log = Logger(level: Level.warning);
    store = MockStore();
    GetIt.I.registerSingleton<Logger>(log);
    GetIt.I.registerSingleton<ClientSettings>(ClientSettings(store: store, log: log));
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  group('NotificationItem', () {
    test('toMap/fromMap round-trips including links', () {
      final original = _item(
        type: DialogType.success,
        links: const [NotificationLink(text: 'View transaction', url: 'https://x/tx/abc')],
      );

      final restored = NotificationItem.fromMap(original.toMap());

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.content, original.content);
      expect(restored.dialogType, DialogType.success);
      expect(restored.timestamp, original.timestamp);
      expect(restored.links.single.text, 'View transaction');
      expect(restored.links.single.url, 'https://x/tx/abc');
    });

    test('fromMap tolerates missing links and bad dialogType index', () {
      final restored = NotificationItem.fromMap({
        'id': '7',
        'title': 't',
        'content': 'c',
        'dialogType': 999,
        'timestamp': 'not-a-date',
      });

      expect(restored.links, isEmpty);
      expect(restored.dialogType, DialogType.values.last);
      expect(restored.timestamp, isA<DateTime>());
    });
  });

  group('NotificationHistory', () {
    test('toJson/fromJson round-trips a list', () {
      final history = NotificationHistory(
        items: [
          _item(id: 'a'),
          _item(id: 'b'),
        ],
      );

      final restored = NotificationHistory.fromJson(history.toJson());

      expect(restored.items.map((i) => i.id), ['a', 'b']);
    });

    test('fromJson returns empty on garbage', () {
      expect(NotificationHistory.fromJson('}{not json').items, isEmpty);
    });
  });

  group('NotificationProvider', () {
    test('add() appends newest-first and persists to the store', () async {
      final provider = NotificationProvider();
      await _flush();

      provider.add(title: 'First', content: 'one', dialogType: DialogType.info);
      provider.add(
        title: 'Second',
        content: 'two',
        dialogType: DialogType.success,
        links: const [NotificationLink(text: 'View transaction', url: 'https://x/tx/2')],
      );
      await _flush();

      expect(provider.history.map((n) => n.title), ['Second', 'First']);
      expect(provider.history.first.links.single.url, 'https://x/tx/2');

      final persisted = await GetIt.I.get<ClientSettings>().getValue(NotificationHistorySetting());
      expect(persisted.value.items.map((n) => n.title), ['Second', 'First']);
      expect(persisted.value.items.first.links.single.text, 'View transaction');
    });

    test('loads persisted history on construction', () async {
      await GetIt.I.get<ClientSettings>().setValue(
        NotificationHistorySetting(
          newValue: NotificationHistory(
            items: [_item(id: 'persisted', title: 'Old')],
          ),
        ),
      );

      final provider = NotificationProvider();
      await _flush();

      expect(provider.history.single.title, 'Old');
    });

    test('dismiss() removes one and persists', () async {
      final provider = NotificationProvider();
      await _flush();
      provider.add(title: 'Keep', content: 'k', dialogType: DialogType.info);
      provider.add(title: 'Drop', content: 'd', dialogType: DialogType.info);
      await _flush();

      final dropId = provider.history.firstWhere((n) => n.title == 'Drop').id;
      await provider.dismiss(dropId);

      expect(provider.history.map((n) => n.title), ['Keep']);
      final persisted = await GetIt.I.get<ClientSettings>().getValue(NotificationHistorySetting());
      expect(persisted.value.items.map((n) => n.title), ['Keep']);
    });

    test('clearAll() empties history and persists', () async {
      final provider = NotificationProvider();
      await _flush();
      provider.add(title: 'A', content: 'a', dialogType: DialogType.info);
      await _flush();

      await provider.clearAll();

      expect(provider.history, isEmpty);
      final persisted = await GetIt.I.get<ClientSettings>().getValue(NotificationHistorySetting());
      expect(persisted.value.items, isEmpty);
    });

    test('add() without ClientSettings registered still updates memory', () async {
      await GetIt.I.reset();
      GetIt.I.registerSingleton<Logger>(Logger(level: Level.warning));

      final provider = NotificationProvider();
      provider.add(title: 'NoStore', content: 'x', dialogType: DialogType.info);

      expect(provider.history.single.title, 'NoStore');
    });
  });
}
