import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

class _MemoryHomepageProvider extends HomepageProvider {
  HomepageConfiguration saved;
  int writes = 0;
  final Future<void>? readGate;

  _MemoryHomepageProvider(this.saved, {this.readGate}) : super(HomepageConfiguration(widgets: const []));

  @override
  final Map<String, HomepageWidgetInfo> catalog = {
    for (final (id, sizes) in [
      ('quotes', [WidgetSize.bar]),
      ('news', [WidgetSize.half, WidgetSize.full]),
      ('blocks', [WidgetSize.half]),
      ('peers', [WidgetSize.full]),
      ('traffic', [WidgetSize.half, WidgetSize.full]),
      ('ticker', [WidgetSize.bar]),
    ])
      id: HomepageWidgetInfo(
        id: id,
        name: 'Widget $id',
        sizes: sizes,
        builder: (size) => SizedBox(height: 80, child: Text('$id ${size.name}')),
      ),
  };

  @override
  Future<HomepageConfiguration> read() async {
    await readGate;
    return saved;
  }

  @override
  Future<void> write(HomepageConfiguration configuration) async {
    writes++;
    saved = configuration;
  }
}

List<String> _ids(List<HomepageWidgetConfig> widgets) => [for (final w in widgets) w.widgetId];

Future<_MemoryHomepageProvider> _pump(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(1600, 1200));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final provider = _MemoryHomepageProvider(
    HomepageConfiguration(
      widgets: const [
        HomepageWidgetConfig(widgetId: 'quotes'),
        HomepageWidgetConfig(widgetId: 'news'),
        HomepageWidgetConfig(widgetId: 'blocks'),
      ],
    ),
  );
  await provider.loaded;

  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => SailTheme(
        data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
        child: child!,
      ),
      home: Scaffold(body: HomepageView(provider: provider)),
    ),
  );
  await tester.pumpAndSettle();
  return provider;
}

Future<void> _startEdit(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('HomepageEdit')));
  await tester.pumpAndSettle();
}

Future<void> _addFromLibrary(WidgetTester tester, String id, WidgetSize? size) async {
  await tester.tap(find.byKey(const Key('HomepageAddWidget')));
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.byKey(Key('WidgetLibrary-$id')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key('WidgetLibrary-$id')));
  await tester.pumpAndSettle();
  if (size != null) {
    await tester.tap(find.byKey(Key('WidgetSize-${size.name}')));
    await tester.pumpAndSettle();
  }
  await tester.tap(find.byKey(const Key('WidgetSizeConfirm')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('edit homepage starts edit mode, and done saves and ends it', (tester) async {
    final provider = await _pump(tester);
    expect(find.byKey(const Key('HomepageEditBar')), findsNothing);

    await _startEdit(tester);
    expect(provider.editing, isTrue);
    expect(find.byKey(const Key('HomepageEditBar')), findsOneWidget);
    expect(find.byKey(const Key('HomepageEdit')), findsNothing);
    expect(find.byKey(const Key('HomepageRemove-news')), findsOneWidget);

    await tester.tap(find.byKey(const Key('HomepageDone')));
    await tester.pumpAndSettle();
    expect(provider.editing, isFalse);
    expect(provider.writes, 1);
    expect(find.byKey(const Key('HomepageEditBar')), findsNothing);
    expect(find.byKey(const Key('HomepageEdit')), findsOneWidget);
  });

  testWidgets('a widget dragged onto another widget takes its place', (tester) async {
    final provider = await _pump(tester);
    await _startEdit(tester);

    final gesture = await tester.startGesture(tester.getCenter(find.byKey(const Key('HomepageDrag-blocks'))));
    await tester.pump();
    final target = tester.getCenter(find.byKey(const Key('HomepageDrag-news')));
    for (var i = 0; i < 10; i++) {
      await gesture.moveBy((target - tester.getCenter(find.byKey(const Key('HomepageDrag-blocks')))) / 10);
      await tester.pump();
    }
    expect(find.byKey(const Key('HomepageDropPlace')), findsOneWidget);
    await gesture.up();
    await tester.pumpAndSettle();

    expect(_ids(provider.widgets), ['quotes', 'blocks', 'news']);
    await tester.tap(find.byKey(const Key('HomepageDone')));
    await tester.pumpAndSettle();
    expect(_ids(provider.saved.widgets), ['quotes', 'blocks', 'news']);
  });

  testWidgets('the remove badge takes the widget off the homepage', (tester) async {
    final provider = await _pump(tester);
    await _startEdit(tester);

    await tester.tap(find.byKey(const Key('HomepageRemove-blocks')));
    await tester.pumpAndSettle();
    expect(find.text('blocks half'), findsNothing);

    await tester.tap(find.byKey(const Key('HomepageDone')));
    await tester.pumpAndSettle();
    expect(_ids(provider.saved.widgets), ['quotes', 'news']);
  });

  testWidgets('the library adds a widget in each size at the bottom', (tester) async {
    final provider = await _pump(tester);
    await _startEdit(tester);

    await _addFromLibrary(tester, 'ticker', null);
    expect(find.byKey(const Key('WidgetLibrary')), findsNothing);
    await _addFromLibrary(tester, 'traffic', WidgetSize.half);
    await _addFromLibrary(tester, 'peers', null);

    expect(_ids(provider.widgets), ['quotes', 'news', 'blocks', 'ticker', 'traffic', 'peers']);
    expect(find.text('ticker bar'), findsOneWidget);
    expect(find.text('traffic half'), findsOneWidget);
    expect(find.text('peers full'), findsOneWidget);

    await tester.tap(find.byKey(const Key('HomepageRemove-traffic')));
    await tester.pumpAndSettle();
    await _addFromLibrary(tester, 'traffic', WidgetSize.full);
    expect(find.text('traffic full'), findsOneWidget);

    await tester.tap(find.byKey(const Key('HomepageDone')));
    await tester.pumpAndSettle();
    final traffic = provider.saved.widgets.singleWhere((w) => w.widgetId == 'traffic');
    expect(traffic.size, WidgetSize.full);
  });

  testWidgets('a widget on the homepage changes size, and opens no dialog with one size', (tester) async {
    final provider = await _pump(tester);
    await _startEdit(tester);

    await tester.tap(find.byKey(const Key('HomepageAddWidget')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('WidgetLibrary-blocks')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('WidgetSizeDialog')), findsNothing);

    await tester.tap(find.byKey(const Key('WidgetLibrary-news')));
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byKey(const Key('WidgetSizeConfirm')), matching: find.text('Save')), findsWidgets);
    await tester.tap(find.byKey(const Key('WidgetSize-full')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('WidgetSizeConfirm')));
    await tester.pumpAndSettle();

    expect(_ids(provider.widgets), ['quotes', 'news', 'blocks']);
    expect(provider.widgets[1].size, WidgetSize.full);
    expect(find.text('news full'), findsOneWidget);
  });

  testWidgets('edit mode waits for the saved layout', (tester) async {
    final gate = Completer<void>();
    final provider = _MemoryHomepageProvider(
      HomepageConfiguration(widgets: const [HomepageWidgetConfig(widgetId: 'peers')]),
      readGate: gate.future,
    );
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => SailTheme(
          data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
          child: child!,
        ),
        home: Scaffold(body: HomepageView(provider: provider)),
      ),
    );

    await tester.tap(find.byKey(const Key('HomepageEdit')), warnIfMissed: false);
    provider.startEdit();
    await tester.pump();
    expect(provider.editing, isFalse);

    gate.complete();
    await provider.loaded;
    await tester.pumpAndSettle();
    await _startEdit(tester);
    expect(provider.editing, isTrue);
    expect(_ids(provider.widgets), ['peers']);
  });
}
