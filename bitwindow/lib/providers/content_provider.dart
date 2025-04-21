import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/widgets/modals/article_info_modal.dart';

extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

class ContentProvider extends ChangeNotifier {
  List<ArticleGroup> groups = [];
  Future<void> load() async {
    try {
      groups = await loadArticleGroups();

      notifyListeners();
    } catch (error) {
      // ignore
    }
  }

  Future<List<ArticleGroup>> loadArticleGroups() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifest = json.decode(manifestContent);

      final articlePaths = manifest.keys.where(
        (String key) => key.startsWith('assets/articles/') && key.endsWith('.mdx'),
      );

      if (articlePaths.isEmpty) {
        return [];
      }

      // Group by directory
      final Map<String, List<String>> groupedPaths = {};
      for (final path in articlePaths) {
        final pathParts = path.split('/');
        if (pathParts.length >= 3) {
          final dir = pathParts[2]; // assets/articles/beginner/file.mdx
          groupedPaths.putIfAbsent(dir, () => []).add(path);
        }
      }

      // Create groups
      final groups = await Future.wait(
        groupedPaths.entries.map((entry) async {
          final articles = await Future.wait<Article>(
            entry.value.map((path) async {
              try {
                final content = await rootBundle.loadString(path);
                final article = parseArticle(content, path);
                if (article == null) {
                  return Article(title: 'Error loading article', markdown: '', filename: path);
                }
                return article;
              } catch (e) {
                return Article(title: 'Error loading article', markdown: '', filename: path);
              }
            }),
          );

          return ArticleGroup(
            title: _getGroupTitle(entry.key),
            subtitle: _getGroupSubtitle(entry.key),
            articles: articles.where((article) => article.title != 'Error loading article').toList(),
          );
        }),
      );

      return groups.where((group) => group.articles.isNotEmpty).toList();
    } catch (e) {
      return [];
    }
  }

  String _getGroupTitle(String key) {
    switch (key) {
      case 'beginner':
        return 'Getting Started';
      case 'intermediate':
        return 'Intermediate Concepts';
      case 'advanced':
        return 'Advanced Topics';
      default:
        return key.capitalize();
    }
  }

  String _getGroupSubtitle(String key) {
    switch (key) {
      case 'beginner':
        return 'Start your Drivechain journey with the basics';
      case 'intermediate':
        return 'Dive deeper into core concepts';
      case 'advanced':
        return 'Master advanced techniques';
      default:
        return '';
    }
  }

  Future<List<Article>> loadArticles() async {
    final directory = Directory('assets/articles');
    final List<Article> articles = [];

    await for (final file in directory.list()) {
      if (file.path.endsWith('.mdx')) {
        final content = await File(file.path).readAsString();
        final article = parseArticle(content, path.basename(file.path));
        if (article != null) {
          articles.add(article);
        }
      }
    }

    return articles;
  }

  Future<List<Article>> loadArticlesFromDir(Directory dir) async {
    final articles = await loadArticles();
    return articles.where((article) => article.filename.startsWith('${path.basename(dir.path)}/')).toList();
  }

  Article? parseArticle(String content, String filename) {
    // Extract content between --- and ---
    final frontMatterRegex = RegExp(r'^---\s*\n([\s\S]*?)\n---\s*\n([\s\S]*)$');
    final match = frontMatterRegex.firstMatch(content);

    if (match != null) {
      final frontMatter = match.group(1) ?? '';
      final markdown = match.group(2) ?? '';

      // Extract title from front matter
      final titleRegex = RegExp(r'title:(.+)$', multiLine: true);
      final titleMatch = titleRegex.firstMatch(frontMatter);
      final title = titleMatch?.group(1)?.trim().replaceAll("'", '') ?? 'Untitled';

      return Article(
        title: title,
        markdown: markdown.trim(),
        filename: filename,
      );
    }
    return null;
  }
}
