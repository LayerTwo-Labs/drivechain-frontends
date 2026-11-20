import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

WalletGradient _gradient(String svg, {String? picturePath}) => WalletGradient(
  backgroundSvg: svg,
  picturePath: picturePath,
  colors: const ['#000000', '#111111', '#222222'],
  stops: const [0, 0.5, 1],
  centerX: 0,
  centerY: 0,
  radius: 1.2,
  seed: 7,
);

Widget _host(String svg, {String? picturePath}) => MaterialApp(
  home: Scaffold(
    body: Center(
      child: WalletBlobAvatar(gradient: _gradient(svg, picturePath: picturePath), size: 24),
    ),
  ),
);

Future<RenderImage> _drawn(WidgetTester tester) async {
  for (var i = 0; i < 100; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump();
    final found = find.byType(RawImage);
    if (found.evaluate().isNotEmpty) {
      final image = tester.renderObject<RenderImage>(found);
      if (image.image != null) {
        return image;
      }
    }
  }
  fail('the avatar did not draw');
}

void main() {
  testWidgets('the generated avatar draws an image of its own pixel size', (tester) async {
    await tester.pumpWidget(_host('background_sphere.svg'));
    final image = await _drawn(tester);

    final pixels = (24 * tester.view.devicePixelRatio).ceil();
    expect(image.image!.width, pixels);
    expect(image.image!.height, pixels);
  });

  testWidgets('a second avatar of the same size draws in its first frame', (tester) async {
    await tester.pumpWidget(_host('background_sphere.svg'));
    await _drawn(tester);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(_host('background_sphere.svg'));

    expect(tester.renderObject<RenderImage>(find.byType(RawImage)).image, isNotNull);
  });

  testWidgets('a user picture decodes at the avatar size', (tester) async {
    final file = (await tester.runAsync(() async {
      final recorder = ui.PictureRecorder();
      Canvas(recorder).drawRect(const Rect.fromLTWH(0, 0, 1600, 1200), Paint()..color = const Color(0xFF3366FF));
      final image = await recorder.endRecording().toImage(1600, 1200);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      final dir = await Directory.systemTemp.createTemp('avatar');
      return File('${dir.path}/picture.png')..writeAsBytesSync(png!.buffer.asUint8List());
    }))!;
    addTearDown(() => file.parent.deleteSync(recursive: true));

    await tester.pumpWidget(_host('background_sphere.svg', picturePath: file.path));
    final image = await _drawn(tester);

    final pixels = (24 * tester.view.devicePixelRatio).ceil();
    expect(image.image!.height, pixels);
    expect(image.image!.width, (1600 * pixels / 1200).ceil());
  });
}
