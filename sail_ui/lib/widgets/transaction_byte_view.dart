import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sail_ui/sail_ui.dart';

/// Renders a raw transaction hex as labeled, offset-annotated byte groups.
/// Falls back to plain copyable hex when the input cannot be parsed.
class TransactionByteView extends StatelessWidget {
  final String rawHex;

  const TransactionByteView({super.key, required this.rawHex});

  @override
  Widget build(BuildContext context) {
    final theme = context.sailTheme;

    ParsedTransaction? parsed;
    String? parseError;
    try {
      parsed = parseTransactionHex(rawHex);
    } on TxParseException catch (e) {
      parseError = e.message;
    } catch (_) {
      parseError = 'could not parse transaction';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(SailStyleValues.padding16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SailText.primary13('Byte-level view'),
              SailButton(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: rawHex));
                  if (context.mounted) {
                    showSailToast(context, 'Copied to clipboard');
                  }
                },
                label: 'Copy hex',
                small: true,
              ),
            ],
          ),
          const SailSpacing(SailStyleValues.padding08),
          if (parsed == null)
            _rawFallback(theme, parseError)
          else ...[
            Wrap(
              spacing: SailStyleValues.padding08,
              runSpacing: SailStyleValues.padding04,
              children: [
                _badge(theme, parsed.isSegwit ? 'SegWit' : 'Legacy'),
                _badge(theme, '${parsed.inputCount} in'),
                _badge(theme, '${parsed.outputCount} out'),
                _badge(theme, '${parsed.fields.fold<int>(0, (a, f) => a + f.length)} bytes'),
              ],
            ),
            const SailSpacing(SailStyleValues.padding12),
            for (final field in parsed.fields) _FieldRow(field: field),
          ],
        ],
      ),
    );
  }

  Widget _badge(SailThemeData theme, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: SailStyleValues.padding08, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colors.backgroundSecondary,
        borderRadius: SailStyleValues.borderRadiusSmall,
        border: Border.all(color: theme.colors.divider),
      ),
      child: SailText.secondary12(label),
    );
  }

  Widget _rawFallback(SailThemeData theme, String? parseError) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (parseError != null) ...[
          SailText.secondary12('Could not decode fields ($parseError). Showing raw hex.'),
          const SailSpacing(SailStyleValues.padding08),
        ],
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(SailStyleValues.padding12),
          decoration: BoxDecoration(
            color: theme.colors.backgroundSecondary,
            borderRadius: SailStyleValues.borderRadius,
            border: Border.all(color: theme.colors.divider),
          ),
          child: SailSelectableText(
            rawHex.isEmpty ? 'No raw data available' : rawHex,
            monospace: true,
          ),
        ),
      ],
    );
  }
}

class _FieldRow extends StatelessWidget {
  final TxByteField field;

  const _FieldRow({required this.field});

  @override
  Widget build(BuildContext context) {
    final theme = context.sailTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: SailStyleValues.padding04),
      padding: const EdgeInsets.all(SailStyleValues.padding08),
      decoration: BoxDecoration(
        color: theme.colors.backgroundSecondary,
        borderRadius: SailStyleValues.borderRadiusSmall,
        border: Border.all(color: theme.colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 64,
                child: SailText.secondary12('@${field.offset}', monospace: true),
              ),
              Expanded(child: SailText.primary12(field.label, bold: true)),
              if (field.value != null)
                Flexible(
                  child: SailText.secondary12(
                    field.value!,
                    monospace: true,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          const SailSpacing(SailStyleValues.padding04),
          SailSelectableText(field.hex, monospace: true),
        ],
      ),
    );
  }
}
