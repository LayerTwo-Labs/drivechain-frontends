import 'dart:io';

import 'package:bitwindow/providers/content_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

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
}
