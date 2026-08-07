import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

const _xpub =
    'xpub6DPU5UE745UtNgTLEVKSNVqD8tyPWKWz6acRWY3WfMsSc9ZkybCZbD9Yhe42Y7QZkJrjVtVu5acrHhwPdTRe4arNVMp8yr7Nabcdefghijk';

Widget _row({required bool wrap}) {
  return MaterialApp(
    home: SailTheme(
      data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
      child: Scaffold(
        body: SizedBox(
          width: 420,
          child: Row(
            children: [
              const SizedBox(width: 110),
              Expanded(
                child: SailEditableText(
                  value: _xpub,
                  wrap: wrap,
                  showPencil: false,
                  editOnDoubleTap: true,
                  onSubmitted: (_) {},
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('a long value wraps instead of overflowing the row', (tester) async {
    await tester.pumpWidget(_row(wrap: true));
    await tester.pumpAndSettle();

    expect(find.byType(SailEditableText), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Wrapped onto more than one line, so it stays inside the row.
    final field = tester.getSize(find.byType(SailEditableText));
    expect(field.width, lessThanOrEqualTo(420 - 110));
    expect(field.height, greaterThan(20));
  });

  testWidgets('a short value still hugs its content', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SailTheme(
          data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
          child: Scaffold(
            body: Row(
              children: [
                SailEditableText(value: 'Key 1', showPencil: false, onSubmitted: (_) {}),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final field = tester.getSize(find.byType(SailEditableText));
    expect(field.width, lessThan(200), reason: 'a label must not stretch the row');
  });
}
