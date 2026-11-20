import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('each article link has a scheme, so openUrl can open it', () {
    final articles = Directory(
      'assets/articles',
    ).listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.mdx')).toList();
    expect(articles, isNotEmpty);

    final linkTarget = RegExp(r'\]\(([^)\s]+)');
    final noScheme = [
      for (final article in articles)
        for (final match in linkTarget.allMatches(article.readAsStringSync()))
          if (!Uri.parse(match.group(1)!).hasScheme) '${article.path}: ${match.group(1)}',
    ];

    expect(noScheme, isEmpty);
  });
}
