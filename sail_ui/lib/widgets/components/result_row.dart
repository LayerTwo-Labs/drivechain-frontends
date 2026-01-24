import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sail_ui/sail_ui.dart';

class ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final bool monospace;
  final bool copyable;
  final Color? color;

  const ResultRow({
    super.key,
    required this.label,
    required this.value,
    this.monospace = false,
    this.copyable = false,
    this.color,
  });

  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${label.replaceAll(':', '')} copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colors.backgroundSecondary,
        borderRadius: SailStyleValues.borderRadiusSmall,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: SailText.secondary13(label, color: theme.colors.textSecondary),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    value,
                    style: TextStyle(
                      fontFamily: monospace ? 'IBMPlexMono' : 'Inter',
                      fontSize: 13,
                      color: color ?? theme.colors.text,
                    ),
                  ),
                ),
                if (copyable) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.copy, size: 18, color: theme.colors.primary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _copyToClipboard(context),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
