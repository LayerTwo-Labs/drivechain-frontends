import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class EnforcerActualConfigPanel extends ViewModelWidget<EnforcerConfigEditorViewModel> {
  const EnforcerActualConfigPanel({super.key});

  @override
  Widget build(BuildContext context, EnforcerConfigEditorViewModel viewModel) {
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
            child: viewModel.originalConfig == null
                ? Center(
                    child: SailText.secondary13('No config file loaded'),
                  )
                : _buildDiffView(theme, viewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildDiffView(SailThemeData theme, EnforcerConfigEditorViewModel viewModel) {
    final diff = _getDiffLines(viewModel);

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
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Text(
        line.content,
        style: TextStyle(
          fontFamily: 'IBMPlexMono',
          fontSize: 12,
          color: textColor,
          height: 1.4,
        ),
      ),
    );
  }

  List<DiffLine> _getDiffLines(EnforcerConfigEditorViewModel viewModel) {
    if (viewModel.originalConfig == null || viewModel.workingConfig == null) {
      return [];
    }

    final originalLines = viewModel.originalConfigText.split('\n');
    final workingLines = viewModel.workingConfigText.split('\n');

    return computeDiff(originalLines, workingLines);
  }
}
