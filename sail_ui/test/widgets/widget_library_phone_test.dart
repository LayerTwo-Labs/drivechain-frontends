import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

class _MemoryHomepageProvider extends HomepageProvider {
  HomepageConfiguration saved;

  _MemoryHomepageProvider(this.saved) : super(HomepageConfiguration(widgets: const []));

  @override
  final Map<String, HomepageWidgetInfo> catalog = {
    for (final (id, group, subtitle) in [
      ('quotes', 'News', null),
      ('news', 'News', null),
      ('graffiti', 'Chain', 'Browse blockchain graffiti and OP_RETURN data'),
    ])
      id: HomepageWidgetInfo(
        id: id,
        name: 'Widget $id',
        sizes: const [WidgetSize.full],
        group: group,
        subtitle: subtitle,
        builder: (size) => SizedBox(height: 80, child: Text('preview $id')),
      ),
  };

  @override
  Future<HomepageConfiguration> read() async => saved;

  @override
  Future<void> write(HomepageConfiguration configuration) async => saved = configuration;
}

Future<_MemoryHomepageProvider> _pump(WidgetTester tester, Size size) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final provider = _MemoryHomepageProvider(
    HomepageConfiguration(widgets: const [HomepageWidgetConfig(widgetId: 'quotes')]),
  );
  await provider.loaded;
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => SailTheme(
        data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
        child: child!,
      ),
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: TextButton(onPressed: () => showWidgetLibrary(context, provider), child: const Text('open')),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return provider;
}

void main() {
  tearDown(() => SailStyleValues.phoneLayoutOverride = null);

  testWidgets('on a phone the library lists one row per widget in a panel per group', (tester) async {
    SailStyleValues.phoneLayoutOverride = true;
    await _pump(tester, const Size(390, 844));

    expect(find.text('preview news'), findsNothing);
    expect(find.text('News'), findsOneWidget);
    expect(find.text('Chain'), findsOneWidget);
    expect(find.byType(SailStatList), findsNWidgets(2));
    final name = tester.getRect(find.text('Widget graffiti'));
    final subtitle = tester.getRect(find.text('Browse blockchain graffiti and OP_RETURN data'));
    expect(subtitle.top, greaterThanOrEqualTo(name.bottom));
    expect(subtitle.left, name.left);
    expect(
      tester.getRect(find.text('Widget news')).top,
      greaterThan(tester.getRect(find.text('Widget quotes')).bottom),
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Widget news'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('WidgetSizeDialog')), findsOneWidget);
  });

  testWidgets('on the desktop the library shows live previews', (tester) async {
    SailStyleValues.phoneLayoutOverride = false;
    await _pump(tester, const Size(1600, 1200));

    expect(find.text('preview news'), findsOneWidget);
    expect(find.byType(SailStatList), findsNothing);
  });
}
