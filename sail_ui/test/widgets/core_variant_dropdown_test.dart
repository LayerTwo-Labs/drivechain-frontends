import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sail_ui/sail_ui.dart';

/// Mirrors the dropdown the Settings → Network & Node page renders for the
/// Core variant picker. Kept inline so the test isolates the visibility +
/// label logic without pulling in BitWindow's full settings page.
class _VariantDropdown extends StatelessWidget {
  final List<wmpb.CoreVariant> variants;
  final String activeId;

  const _VariantDropdown({required this.variants, required this.activeId});

  @override
  Widget build(BuildContext context) {
    if (variants.isEmpty) {
      return const SizedBox.shrink();
    }
    return SailDropdownButton<String>(
      value: activeId,
      items: variants
          .map(
            (v) => SailDropdownItem<String>(
              value: v.id,
              label: v.installed ? v.displayName : '${v.displayName} (will download)',
            ),
          )
          .toList(),
      onChanged: (_) async {},
    );
  }
}

void main() {
  Widget wrap(Widget child) => MaterialApp(
    home: SailTheme(
      data: SailThemeData.lightTheme(
        SailColorScheme.orange,
        true,
        SailFontValues.inter,
      ),
      child: Scaffold(body: child),
    ),
  );

  testWidgets('hides itself when variants list is empty (mainnet)', (tester) async {
    await tester.pumpWidget(wrap(const _VariantDropdown(variants: [], activeId: '')));
    expect(find.byType(SailDropdownButton<String>), findsNothing);
  });

  group('CoreVariantProvider.resolveActiveId', () {
    test('passes through a reported id that is visible', () {
      expect(
        CoreVariantProvider.resolveActiveId(
          reportedActiveId: 'knots',
          visibleIds: const ['untouched', 'knots'],
        ),
        'knots',
      );
    });

    test('falls back to the first visible id when reported id is empty', () {
      expect(
        CoreVariantProvider.resolveActiveId(
          reportedActiveId: '',
          visibleIds: const ['untouched', 'knots'],
        ),
        'untouched',
      );
    });

    test('falls back to the first visible id when reported id is unknown', () {
      expect(
        CoreVariantProvider.resolveActiveId(
          reportedActiveId: 'patched-from-other-network',
          visibleIds: const ['untouched', 'knots'],
        ),
        'untouched',
      );
    });

    test('returns empty when no variants are visible', () {
      expect(
        CoreVariantProvider.resolveActiveId(
          reportedActiveId: 'anything',
          visibleIds: const [],
        ),
        '',
      );
    });
  });

  testWidgets('renders dropdown with installed and download labels', (tester) async {
    final variants = [
      wmpb.CoreVariant(id: 'untouched', displayName: 'Bitcoin Core (vanilla)', installed: true),
      wmpb.CoreVariant(id: 'knots', displayName: 'Bitcoin Knots', installed: false),
    ];
    await tester.pumpWidget(
      wrap(_VariantDropdown(variants: variants, activeId: 'untouched')),
    );

    expect(find.byType(SailDropdownButton<String>), findsOneWidget);
    expect(find.text('Bitcoin Core (vanilla)'), findsWidgets);
    // Open dropdown to surface non-installed entry's "(will download)" suffix.
    await tester.tap(find.byType(SailDropdownButton<String>));
    await tester.pumpAndSettle();
    expect(find.text('Bitcoin Knots (will download)'), findsOneWidget);
  });
}
