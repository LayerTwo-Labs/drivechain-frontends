import 'dart:io';

import 'package:bitwindow/pages/learn_page.dart';
import 'package:bitwindow/providers/content_provider.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

void main() {
  tearDown(() => GetIt.I.reset());

  test('a title keeps the quotes inside its outer quotes', () {
    final content = File('assets/articles/beginner/is-liquid-a-real-sidechain.mdx').readAsStringSync();

    final article = ContentProvider().parseArticle(content, 'is-liquid-a-real-sidechain.mdx')!;

    expect(article.title, 'Is Liquid A "Real" Sidechain? Greg Maxwell Weighs In');
    expect(article.author, 'Paul Sztorc');
    expect(article.background, 'assets/articles/images/orbits.png');
  });

  test('front matter values without quotes stay the same', () {
    const content = "---\ntitle: It's Bitcoin\nauthor: \"Paul's\"\n---\nBody";

    final article = ContentProvider().parseArticle(content, 'a.mdx')!;

    expect(article.title, "It's Bitcoin");
    expect(article.author, "Paul's");
  });

  testWidgets('a long card title stays on one line', (tester) async {
    const long = 'Why Drivechain Is Harder to Understand Than Previous Soft Forks';
    Widget card(String title) => SizedBox(
      width: 400,
      child: ArticleCard(
        groupTitle: 'Getting Started',
        article: Article(title: title, markdown: 'word', filename: 'a.mdx'),
      ),
    );

    await tester.pumpSailPage(Column(children: [card(long), card('Short')]));

    final longText = tester.renderObject<RenderParagraph>(find.text(long));
    expect(longText.didExceedMaxLines, isTrue);
    expect(tester.getSize(find.text(long)).height, tester.getSize(find.text('Short')).height);
  });
}
