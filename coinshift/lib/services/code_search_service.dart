import 'package:flutter/services.dart';

class CodeSearchResult {
  final String filePath;
  final String fileName;
  final String matchedLine;
  final int lineNumber;

  const CodeSearchResult({
    required this.filePath,
    required this.fileName,
    required this.matchedLine,
    required this.lineNumber,
  });
}

class CodeSearchService {
  final Map<String, String> _fileContents = {};
  List<String> _dartFiles = [];

  Future<void> loadFiles() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      _dartFiles = manifest.listAssets().where((path) => path.endsWith('.dart')).toList();

      for (final path in _dartFiles) {
        try {
          final content = await rootBundle.loadString(path);
          _fileContents[path] = content;
        } catch (e) {
          // Skip files that can't be loaded
        }
      }
    } catch (e) {
      // Asset manifest not available - code search disabled
    }
  }

  List<CodeSearchResult> search(String query) {
    if (query.isEmpty || query.length < 2) return [];

    final results = <CodeSearchResult>[];
    final lowerQuery = query.toLowerCase();

    for (final filePath in _dartFiles) {
      final content = _fileContents[filePath];
      if (content == null) continue;

      final lines = content.split('\n');
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        // Only match in string literals (text user would see in UI)
        if (line.toLowerCase().contains(lowerQuery) && _isUserVisibleText(line, lowerQuery)) {
          results.add(
            CodeSearchResult(
              filePath: filePath,
              fileName: filePath.split('/').last.replaceAll('.dart', ''),
              matchedLine: line.trim(),
              lineNumber: i + 1,
            ),
          );
          break; // Only one result per file
        }
      }
    }

    return results;
  }

  // Check if the match is in a user-visible string (not just code)
  bool _isUserVisibleText(String line, String query) {
    // Match strings in single or double quotes that contain the query
    final singleQuotePattern = RegExp(r"'([^']*)'");
    final doubleQuotePattern = RegExp(r'"([^"]*)"');

    for (final match in singleQuotePattern.allMatches(line)) {
      final content = match.group(1) ?? '';
      if (content.toLowerCase().contains(query)) {
        return true;
      }
    }

    for (final match in doubleQuotePattern.allMatches(line)) {
      final content = match.group(1) ?? '';
      if (content.toLowerCase().contains(query)) {
        return true;
      }
    }

    return false;
  }
}
