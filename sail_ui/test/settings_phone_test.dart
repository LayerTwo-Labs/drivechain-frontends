import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

class _Host extends StatefulWidget {
  final bool opensSelected;

  const _Host({super.key, this.opensSelected = false});

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  int index = 0;
  late int openRequest = widget.opensSelected ? 1 : 0;

  void open(int section) => setState(() {
    index = section;
    openRequest++;
  });

  @override
  Widget build(BuildContext context) => SailSettingsScaffold(
    subtitle: 'Manage your BitWindow settings',
    selectedIndex: index,
    onSectionSelected: (i) => setState(() => index = i),
    phoneOpenRequest: openRequest,
    sections: [
      for (final label in ['Node mode', 'Network', 'Wallet'])
        SailSettingsSection(label: label, builder: (_) => Text('$label body')),
    ],
  );
}

final _hostKey = GlobalKey<_HostState>();

Future<void> _pump(WidgetTester tester, {bool opensSelected = false, Size size = const Size(400, 800)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => SailTheme(
        data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
        child: child ?? const SizedBox(),
      ),
      home: Scaffold(
        body: _Host(key: _hostKey, opensSelected: opensSelected),
      ),
    ),
  );
}

void main() {
  tearDown(() => SailStyleValues.phoneLayoutOverride = null);

  group('on a phone', () {
    setUp(() => SailStyleValues.phoneLayoutOverride = true);

    testWidgets('the sections show as one panel of rows with a grey chevron', (tester) async {
      await _pump(tester);

      expect(tester.takeException(), isNull);
      expect(find.byType(SideNav), findsNothing);
      expect(find.byType(SailStatList), findsOneWidget);
      expect(find.text('Node mode body'), findsNothing);
      final grey = ColorFilter.mode(
        SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter).colors.textTertiary,
        BlendMode.srcIn,
      );
      final chevrons = tester.widgetList<SvgPicture>(find.byType(SvgPicture)).toList();
      expect(chevrons, hasLength(3));
      for (final chevron in chevrons) {
        expect(chevron.colorFilter, grey);
        expect(chevron.width, lessThanOrEqualTo(16));
      }
      final rows = ['Node mode', 'Network', 'Wallet'].map((l) => tester.getRect(find.text(l))).toList();
      expect(rows[1].top, greaterThan(rows[0].bottom));
      expect(rows[2].top, greaterThan(rows[1].bottom));
    });

    testWidgets('a row opens its section as a page, and the back row returns to the list', (tester) async {
      await _pump(tester);

      await tester.tap(find.text('Network'));
      await tester.pumpAndSettle();
      expect(find.text('Network body'), findsOneWidget);
      expect(find.byType(SailStatList), findsNothing);

      await tester.tap(find.byKey(const Key('settings-back')));
      await tester.pumpAndSettle();
      expect(find.text('Network body'), findsNothing);
      expect(find.byType(SailStatList), findsOneWidget);
    });

    testWidgets('a requested section opens at once', (tester) async {
      await _pump(tester, opensSelected: true);

      expect(find.text('Node mode body'), findsOneWidget);
    });

    testWidgets('a second request for the section that was open opens it again', (tester) async {
      await _pump(tester);
      _hostKey.currentState!.open(1);
      await tester.pumpAndSettle();
      expect(find.text('Network body'), findsOneWidget);

      await tester.tap(find.byKey(const Key('settings-back')));
      await tester.pumpAndSettle();
      expect(find.text('Network body'), findsNothing);

      _hostKey.currentState!.open(1);
      await tester.pumpAndSettle();
      expect(find.text('Network body'), findsOneWidget);
    });
  });

  testWidgets('on a desktop the side nav and the selected section show together', (tester) async {
    SailStyleValues.phoneLayoutOverride = false;
    await _pump(tester, size: const Size(1200, 800));

    expect(find.byType(SideNav), findsOneWidget);
    expect(find.text('Node mode body'), findsOneWidget);
    expect(find.byType(SailStatList), findsNothing);
  });
}
