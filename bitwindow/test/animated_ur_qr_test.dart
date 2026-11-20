import 'dart:typed_data';

import 'package:bitwindow/widgets/animated_ur_qr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sail_ui/sail_ui.dart';

Widget _host(Uint8List psbt) => SailTheme(
  data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
  child: MaterialApp(
    home: Scaffold(
      body: Center(child: AnimatedURQR(psbt: psbt)),
    ),
  ),
);

CustomPainter? _painter(WidgetTester tester) {
  final paints = tester.widgetList<CustomPaint>(find.byType(CustomPaint)).where((p) => p.painter is QrPainter);
  return paints.single.painter;
}

void main() {
  testWidgets('a frame keeps its QR painter for the next cycle', (tester) async {
    final psbt = Uint8List.fromList(List.generate(600, (i) => i % 251));
    await tester.pumpWidget(_host(psbt));
    final first = _painter(tester);
    final frames = int.parse(
      RegExp(r'of (\d+)').firstMatch(tester.widget<Text>(find.textContaining('Frame 1 of')).data!)!.group(1)!,
    );
    expect(frames, greaterThan(1));

    for (var i = 0; i < frames; i++) {
      await tester.pump(const Duration(milliseconds: 167));
    }

    expect(find.textContaining('Frame 1 of'), findsOneWidget);
    expect(identical(_painter(tester), first), isTrue);
    await tester.pumpWidget(const SizedBox());
  });
}
