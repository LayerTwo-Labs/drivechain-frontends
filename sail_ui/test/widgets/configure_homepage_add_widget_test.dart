import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

class _FakeHomepageProvider extends HomepageProvider {
  final Map<String, HomepageWidgetInfo> catalog;
  HomepageConfiguration _temp = HomepageConfiguration(widgets: []);

  _FakeHomepageProvider(this.catalog);

  @override
  HomepageConfiguration get configuration => HomepageConfiguration(widgets: []);

  @override
  HomepageConfiguration get tempConfiguration => _temp;

  @override
  bool get isLoading => false;

  @override
  bool get hasUnsavedChanges => _temp.widgets.isNotEmpty;

  @override
  Future<void> saveConfiguration() async {}

  @override
  void addWidget(String widgetId) {
    _temp = _temp.addWidget(widgetId);
    notifyListeners();
  }

  @override
  void removeWidget(int index) {}

  @override
  void reorderWidgets(int oldIndex, int newIndex) {}

  @override
  void undoChanges() {}

  @override
  Map<String, HomepageWidgetInfo> getWidgetCatalog() => catalog;
}

HomepageWidgetInfo _info(String id) => HomepageWidgetInfo(
  id: id,
  name: 'Widget $id',
  description: 'Description $id',
  size: WidgetSize.half,
  icon: SailSVGAsset.iconHome,
  builder: (_) => const SizedBox(height: 10),
);

void main() {
  testWidgets('the add widget dialog stays open until the last widget is added', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1600, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final catalog = {
      for (final id in ['a', 'b', 'c']) id: _info(id),
    };
    final provider = _FakeHomepageProvider(catalog);

    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(0.5)),
          child: child!,
        ),
        home: SailTheme(
          data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
          child: SailConfigureHomePage(widgetCatalog: catalog, provider: provider),
        ),
      ),
    );

    await tester.tap(find.widgetWithText(SailButton, 'Add Widget').first);
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);

    Finder addButton() => find.descendant(of: find.byType(Dialog), matching: find.widgetWithText(SailButton, 'Add'));

    await tester.tap(addButton().first);
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.descendant(of: find.byType(Dialog), matching: find.text('Widget a')), findsNothing);
    expect(provider.tempConfiguration.widgets.map((w) => w.widgetId), ['a']);

    await tester.tap(addButton().first);
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);

    await tester.tap(addButton().first);
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
    expect(provider.tempConfiguration.widgets.map((w) => w.widgetId), ['a', 'b', 'c']);
  });
}
