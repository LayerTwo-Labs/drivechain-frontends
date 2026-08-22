import 'package:bitwindow/widgets/address_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized({
    'flutter.test.automatic_wait_for_timers': 'false',
  });

  const entries = [
    ['bb privat', 'bc1qjyeu20wv7yrwj6q96h5k7ewcc5v474n7yqv023'],
    ['bb jalborgs', 'bc1qcq7hfsfal7alfyfhe04jcy3avyt2j8e988zdh0'],
  ];

  Widget addressTable({required double width}) {
    return Center(
      child: SizedBox(
        width: width,
        height: 300,
        child: SailTable(
          getRowId: (index) => '$index',
          drawGrid: true,
          headerBuilder: (context) => const [
            SailTableHeaderCell(name: 'Label'),
            SailTableHeaderCell(name: 'Address'),
            SailTableHeaderCell(name: 'Actions', alignment: Alignment.centerRight),
          ],
          rowBuilder: (context, row, selected) => [
            SailTableCell(value: entries[row][0], monospace: true),
            SailTableCell(value: entries[row][1], monospace: true),
            SailTableCell(
              value: 'Actions',
              width: actionsColumnWidth,
              alignment: Alignment.centerRight,
              child: SailRow(
                spacing: SailStyleValues.padding04,
                children: [
                  SailButton(
                    variant: ButtonVariant.icon,
                    icon: SailSVGAsset.iconPen,
                    onPressed: () async {},
                    insideTable: true,
                  ),
                  SailButton(
                    variant: ButtonVariant.icon,
                    icon: SailSVGAsset.iconDelete,
                    onPressed: () async {},
                    insideTable: true,
                  ),
                ],
              ),
            ),
          ],
          rowCount: entries.length,
        ),
      ),
    );
  }

  double renderedTableWidth(WidgetTester tester) {
    final box = find
        .descendant(
          of: find.byType(SingleChildScrollView),
          matching: find.byType(SizedBox),
        )
        .first;
    return tester.getSize(box).width;
  }

  group('address book table', () {
    testWidgets('fills its width and keeps the actions in their column', (tester) async {
      await tester.pumpSailPage(addressTable(width: 900));
      await tester.pumpAndSettle();

      final actions = find
          .descendant(
            of: find.byType(SailTableCell).at(2),
            matching: find.byType(SailRow),
          )
          .first;

      expect(renderedTableWidth(tester), 900);
      expect(tester.getSize(actions).width, lessThanOrEqualTo(actionsColumnWidth));
      expect(tester.takeException(), isNull);
    });

    testWidgets('does not stretch past the content when the box is narrow', (tester) async {
      await tester.pumpSailPage(addressTable(width: 240));
      await tester.pumpAndSettle();

      expect(renderedTableWidth(tester), greaterThan(240));
    });
  });
}
