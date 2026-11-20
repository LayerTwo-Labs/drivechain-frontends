import 'package:bitwindow/widgets/homepage_widget_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a recent action avatar decodes at 40 px', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Center(child: SidechainActionAvatar(slot: 9))));
    RenderImage? image;
    for (var i = 0; i < 50 && image?.image == null; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
      await tester.pump();
      image = tester.renderObject<RenderImage>(find.byType(RawImage));
    }

    final pixels = (40 * tester.view.devicePixelRatio).ceil();
    expect(image!.image, isNotNull);
    expect(image.image!.width, lessThanOrEqualTo(pixels));
    expect(image.image!.height, lessThanOrEqualTo(pixels));
    expect(image.size.width, closeTo(40, 0.5));
  });
}
