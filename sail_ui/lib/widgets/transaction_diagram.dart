import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/gen/wallet/v1/wallet.pb.dart';
import 'package:sail_ui/sail_ui.dart';

/// A read-only inputs -> fee -> outputs flow for a decoded transaction.
/// Inputs are listed on the left, outputs on the right, with the fee shown
/// at the center junction. Unknown input values (e.g. arbitrary decoded tx,
/// unsigned PSBT) are rendered as "Unknown" rather than zero.
class TransactionDiagram extends StatelessWidget {
  final GetTransactionDetailsResponse details;

  /// Whether the total input / fee values are exact. When false the center
  /// fee node shows "Unknown" instead of a sat amount.
  final bool hasFee;

  /// Addresses known to belong to this wallet (change). Outputs paying these
  /// are labeled as change. Optional; when empty no output is marked change.
  final Set<String> changeAddresses;

  const TransactionDiagram({
    super.key,
    required this.details,
    this.hasFee = true,
    this.changeAddresses = const {},
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.sailTheme;

    return Container(
      padding: const EdgeInsets.all(SailStyleValues.padding12),
      decoration: BoxDecoration(
        color: theme.colors.backgroundSecondary,
        borderRadius: SailStyleValues.borderRadius,
        border: Border.all(color: theme.colors.divider),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SailText.secondary12('Inputs (${details.inputs.length})', bold: true),
                  const SailSpacing(SailStyleValues.padding08),
                  for (final input in details.inputs) _InputNode(input: input),
                  if (details.inputs.isEmpty) SailText.secondary12('No inputs'),
                ],
              ),
            ),
            const SailSpacing(SailStyleValues.padding12),
            _FeeJunction(details: details, hasFee: hasFee),
            const SailSpacing(SailStyleValues.padding12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SailText.secondary12('Outputs (${details.outputs.length})', bold: true),
                  const SailSpacing(SailStyleValues.padding08),
                  for (final output in details.outputs)
                    _OutputNode(
                      output: output,
                      isChange: output.address.isNotEmpty && changeAddresses.contains(output.address),
                    ),
                  if (details.outputs.isEmpty) SailText.secondary12('No outputs'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeeJunction extends StatelessWidget {
  final GetTransactionDetailsResponse details;
  final bool hasFee;

  const _FeeJunction({required this.details, required this.hasFee});

  @override
  Widget build(BuildContext context) {
    final theme = context.sailTheme;
    final formatter = GetIt.I<FormatterProvider>();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SailStyleValues.padding12,
            vertical: SailStyleValues.padding08,
          ),
          decoration: BoxDecoration(
            color: theme.colors.orange.withValues(alpha: 0.15),
            borderRadius: SailStyleValues.borderRadiusSmall,
            border: Border.all(color: theme.colors.orange),
          ),
          child: Column(
            children: [
              SailText.secondary12('Fee', bold: true, color: theme.colors.orange),
              SailText.primary12(
                hasFee ? formatter.formatSats(details.feeSats.toInt()) : 'Unknown',
                monospace: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InputNode extends StatelessWidget {
  final TransactionInput input;

  const _InputNode({required this.input});

  @override
  Widget build(BuildContext context) {
    final theme = context.sailTheme;
    final formatter = GetIt.I<FormatterProvider>();

    final hasValue = !input.isCoinbase && (input.valueSats.toInt() != 0 || input.address.isNotEmpty);
    final amount = input.isCoinbase
        ? 'Coinbase'
        : (hasValue ? formatter.formatSats(input.valueSats.toInt()) : 'Unknown');
    final label = input.isCoinbase
        ? 'Newly minted'
        : (input.address.isNotEmpty ? input.address : '${_short(input.prevTxid)}:${input.prevVout}');

    return _Node(
      alignEnd: false,
      accent: theme.colors.primary,
      amount: amount,
      label: label,
    );
  }
}

class _OutputNode extends StatelessWidget {
  final TransactionOutput output;
  final bool isChange;

  const _OutputNode({required this.output, required this.isChange});

  @override
  Widget build(BuildContext context) {
    final theme = context.sailTheme;
    final formatter = GetIt.I<FormatterProvider>();

    final isData = output.scriptType == 'nulldata';
    final accent = isData ? theme.colors.textSecondary : (isChange ? theme.colors.success : theme.colors.primary);
    final label = isData ? 'OP_RETURN (data)' : (output.address.isNotEmpty ? output.address : 'Unknown');

    return _Node(
      alignEnd: true,
      accent: accent,
      amount: formatter.formatSats(output.valueSats.toInt()),
      label: label,
      tag: isChange ? 'change' : null,
    );
  }
}

class _Node extends StatelessWidget {
  final bool alignEnd;
  final Color accent;
  final String amount;
  final String label;
  final String? tag;

  const _Node({
    required this.alignEnd,
    required this.accent,
    required this.amount,
    required this.label,
    this.tag,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.sailTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: SailStyleValues.padding04),
      padding: const EdgeInsets.symmetric(
        horizontal: SailStyleValues.padding08,
        vertical: SailStyleValues.padding04,
      ),
      decoration: BoxDecoration(
        color: theme.colors.background,
        borderRadius: SailStyleValues.borderRadiusSmall,
        border: Border(
          left: alignEnd ? BorderSide.none : BorderSide(color: accent, width: 3),
          right: alignEnd ? BorderSide(color: accent, width: 3) : BorderSide.none,
        ),
      ),
      child: Column(
        crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (tag != null && !alignEnd) _tagChip(theme),
              Flexible(child: SailText.primary12(amount, monospace: true, bold: true)),
              if (tag != null && alignEnd) _tagChip(theme),
            ],
          ),
          SailText.secondary12(
            _short(label),
            monospace: true,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _tagChip(SailThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(right: 4, left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: theme.colors.success.withValues(alpha: 0.15),
        borderRadius: SailStyleValues.borderRadiusSmall,
      ),
      child: SailText.secondary12(tag!, color: theme.colors.success),
    );
  }
}

String _short(String s) {
  if (s.length <= 20) return s;
  return '${s.substring(0, 10)}...${s.substring(s.length - 6)}';
}
