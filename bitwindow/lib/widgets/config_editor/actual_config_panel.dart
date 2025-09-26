import 'package:bitwindow/providers/bitcoin_config_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sail_ui/sail_ui.dart';

class ActualConfigPanel extends StatefulWidget {
  const ActualConfigPanel({super.key});

  @override
  State<ActualConfigPanel> createState() => _ActualConfigPanelState();
}

class _ActualConfigPanelState extends State<ActualConfigPanel> {
  late final BitcoinConfigProvider _configProvider;

  @override
  void initState() {
    super.initState();
    _configProvider = GetIt.I.get<BitcoinConfigProvider>();
    _configProvider.addListener(_onConfigChanged);
  }

  @override
  void dispose() {
    _configProvider.removeListener(_onConfigChanged);
    super.dispose();
  }

  void _onConfigChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Container(
      color: theme.colors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: SailText.secondary13(
              'Diff',
              bold: true,
            ),
          ),

          Container(
            height: 1,
            color: theme.colors.divider,
          ),

          // Diff content
          Expanded(
            child: _configProvider.originalConfig == null
                ? Center(
                    child: SailText.secondary13('No config file loaded'),
                  )
                : _buildDiffView(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildDiffView(SailThemeData theme) {
    final diff = _getDiffLines();

    if (diff.isEmpty) {
      return Center(
        child: SailText.secondary13('No changes to show'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: diff.map((line) => _buildDiffLine(line, theme)).toList(),
        ),
      ),
    );
  }

  Widget _buildDiffLine(DiffLine line, SailThemeData theme) {
    Color? backgroundColor;
    Color textColor = theme.colors.text;

    switch (line.type) {
      case DiffLineType.added:
        backgroundColor = Colors.green.withValues(alpha: 0.2);
        textColor = Colors.green.shade700;
        break;
      case DiffLineType.removed:
        backgroundColor = Colors.red.withValues(alpha: 0.2);
        textColor = Colors.red.shade700;
        break;
      case DiffLineType.unchanged:
        textColor = theme.colors.textTertiary;
        break;
    }

    return Container(
      width: double.infinity,
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      child: Text(
        line.content,
        style: GoogleFonts.sourceCodePro(
          fontSize: 12,
          color: textColor,
          height: 1.4,
        ),
      ),
    );
  }

  List<DiffLine> _getDiffLines() {
    if (_configProvider.originalConfig == null || _configProvider.workingConfig == null) {
      return [];
    }

    final originalLines = _configProvider.originalConfigText.split('\n');
    final workingLines = _configProvider.workingConfigText.split('\n');

    return _computeDiff(originalLines, workingLines);
  }

  List<DiffLine> _computeDiff(List<String> original, List<String> working) {
    final List<DiffLine> result = [];
    final lcs = _longestCommonSubsequence(original, working);

    int i = 0; // index in original
    int j = 0; // index in working
    int k = 0; // index in lcs

    while (i < original.length || j < working.length) {
      if (k < lcs.length && i < original.length && original[i] == lcs[k]) {
        // This line is in the LCS, so it's unchanged
        if (j < working.length && working[j] == lcs[k]) {
          result.add(DiffLine('  ${original[i]}', DiffLineType.unchanged));
          i++;
          j++;
          k++;
        } else {
          // Added line in working
          result.add(DiffLine('+ ${working[j]}', DiffLineType.added));
          j++;
        }
      } else if (k < lcs.length && j < working.length && working[j] == lcs[k]) {
        // Removed line from original
        result.add(DiffLine('- ${original[i]}', DiffLineType.removed));
        i++;
      } else {
        // Neither line is in LCS
        if (i < original.length && j < working.length) {
          // Both lines exist but are different - treat as remove + add
          result.add(DiffLine('- ${original[i]}', DiffLineType.removed));
          result.add(DiffLine('+ ${working[j]}', DiffLineType.added));
          i++;
          j++;
        } else if (i < original.length) {
          // Only original line exists - removed
          result.add(DiffLine('- ${original[i]}', DiffLineType.removed));
          i++;
        } else if (j < working.length) {
          // Only working line exists - added
          result.add(DiffLine('+ ${working[j]}', DiffLineType.added));
          j++;
        }
      }
    }

    return result;
  }

  List<String> _longestCommonSubsequence(List<String> a, List<String> b) {
    final int m = a.length;
    final int n = b.length;

    // Create LCS table
    final List<List<int>> dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));

    // Fill the LCS table
    for (int i = 1; i <= m; i++) {
      for (int j = 1; j <= n; j++) {
        if (a[i - 1] == b[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1] + 1;
        } else {
          dp[i][j] = dp[i - 1][j] > dp[i][j - 1] ? dp[i - 1][j] : dp[i][j - 1];
        }
      }
    }

    // Backtrack to find the LCS
    final List<String> lcs = [];
    int i = m, j = n;

    while (i > 0 && j > 0) {
      if (a[i - 1] == b[j - 1]) {
        lcs.insert(0, a[i - 1]);
        i--;
        j--;
      } else if (dp[i - 1][j] > dp[i][j - 1]) {
        i--;
      } else {
        j--;
      }
    }

    return lcs;
  }
}

enum DiffLineType {
  added,
  removed,
  unchanged,
}

class DiffLine {
  final String content;
  final DiffLineType type;

  DiffLine(this.content, this.type);
}
