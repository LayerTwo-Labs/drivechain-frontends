import 'package:bitwindow/pages/learn_page.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/core/cover_image.dart';

import 'test_utils.dart';

void main() {
  tearDown(() {
    SailStyleValues.phoneLayoutOverride = null;
    return GetIt.I.reset();
  });

  final group = ArticleGroup(
    title: 'Getting Started',
    subtitle: 'The basics',
    articles: [
      for (var i = 0; i < 3; i++) Article(title: 'Article $i', markdown: 'word', filename: '$i.mdx'),
    ],
  );

  testWidgets('on a phone a group is one panel with a row for each article', (tester) async {
    SailStyleValues.phoneLayoutOverride = true;
    await loadBundledFonts();
    await tester.pumpSailPage(SingleChildScrollView(child: ArticleGroupCard(group: group)));
    await tester.binding.setSurfaceSize(const Size(390, 800));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(ListView), findsNothing);
    expect(find.byType(SailStatList), findsOneWidget);
    expect(tester.widget<Text>(find.text('Getting Started')).style!.fontSize, 18);

    final first = tester.getRect(find.text('Article 0'));
    final second = tester.getRect(find.text('Article 1'));
    expect(second.top, greaterThan(first.bottom));
    expect(first.left, second.left);
    final titleStyle = tester.widget<Text>(find.text('Article 0')).style!;
    expect(titleStyle.fontSize, 15);
    expect(titleStyle.fontWeight, SailStyleValues.regularWeight);

    final picture = find.descendant(of: find.byType(SailStatList), matching: find.byType(CoverImage)).first;
    expect(tester.getSize(picture), const Size(48, 48));
    expect(tester.getRect(find.text('Read time: 1 min').first).top, greaterThanOrEqualTo(first.bottom));

    final chevron = find
        .descendant(
          of: find.byType(SailStatList),
          matching: find.byWidgetPredicate((w) => w.runtimeType.toString() == 'SvgPicture'),
        )
        .first;
    expect(tester.getCenter(chevron).dx, greaterThan(first.right));
  });

  testWidgets('on desktop a group stays a carousel', (tester) async {
    await tester.pumpSailPage(SingleChildScrollView(child: ArticleGroupCard(group: group)));
    await tester.pumpAndSettle();

    expect(find.byType(ListView), findsOneWidget);
    expect(find.byType(SailStatList), findsNothing);
  });
}
