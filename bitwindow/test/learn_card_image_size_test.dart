import 'package:bitwindow/pages/learn_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

Widget _card(String? background) => SailTheme(
  data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
  child: MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 400,
          child: StoryCard(title: 'Title', subtitle: 'Read time: 1 min', onPressed: () {}, background: background),
        ),
      ),
    ),
  ),
);

Future<RenderImage> _loaded(WidgetTester tester) async {
  for (var i = 0; i < 50; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump();
    final image = tester.renderObject<RenderImage>(find.byType(RawImage));
    if (image.image != null) {
      return image;
    }
  }
  fail('the card image did not load');
}

void main() {
  for (final background in ['assets/articles/images/badges.png', null]) {
    testWidgets('a learn card decodes ${background ?? 'the default picture'} at the card size', (tester) async {
      await tester.pumpWidget(_card(background));
      final image = await _loaded(tester);

      final ratio = tester.view.devicePixelRatio;
      final box = image.size;
      expect(image.image!.width, lessThanOrEqualTo((box.width * ratio).ceil() + 1));
      expect(image.image!.width, greaterThanOrEqualTo((box.width * ratio).floor()));
      expect(image.image!.height, greaterThanOrEqualTo((box.height * ratio).floor()));
    });
  }
}
