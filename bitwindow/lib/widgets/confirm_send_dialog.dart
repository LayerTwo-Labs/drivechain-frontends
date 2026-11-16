import 'dart:math';

import 'package:bitwindow/utils/fee_estimation.dart';
import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

/// A send for the user to check before the broadcast.
class SendConfirmation {
  final List<({String address, int sats})> payments;
  final String payFrom;

  final String feeTarget;
  final int feeSats;
  final bool feeIsEstimate;

  final bool feeFromAmount;
  final int totalSats;
  final BitcoinUnit unit;

  const SendConfirmation({
    required this.payments,
    required this.payFrom,
    required this.feeTarget,
    required this.feeSats,
    required this.feeIsEstimate,
    required this.feeFromAmount,
    required this.totalSats,
    required this.unit,
  });
}

/// One line per address. A recipient who pays the fee gets the amount less the fee.
List<({String address, int sats})> confirmSendPayments({
  required Map<String, int> destinations,
  required int feeSats,
  required bool feeFromAmount,
}) => [
  for (final d in destinations.entries) (address: d.key, sats: feeFromAmount ? max(d.value - feeSats, 0) : d.value),
];

/// Shows the send and returns true only when the user clicks "Send".
Future<bool> askConfirmSend(BuildContext context, SendConfirmation send) async {
  final confirmed = await showThemedDialog<bool>(
    context: context,
    builder: (context) => ConfirmSendDialog(send: send),
  );
  return confirmed ?? false;
}

class ConfirmSendDialog extends StatelessWidget {
  final SendConfirmation send;

  const ConfirmSendDialog({super.key, required this.send});

  @override
  Widget build(BuildContext context) {
    String fmt(int sats) => formatBitcoinWithUnit(satoshiToBTC(sats), send.unit);
    final estimate = approximateFeePrefix(send.feeIsEstimate) ?? '';
    final fee = [
      send.feeTarget,
      '$estimate${fmt(send.feeSats)}',
      if (send.feeFromAmount) 'from the amount',
    ].join(' · ');

    return SailModal(
      constraints: const BoxConstraints(maxWidth: 600),
      child: SailCard(
        title: 'Confirm send',
        subtitle: 'Check each address before you send.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _RecipientList(payments: send.payments, fmt: fmt),
            const SizedBox(height: SailStyleValues.padding16),
            _Line(label: 'Pay from', value: send.payFrom),
            const SizedBox(height: SailStyleValues.padding16),
            _Line(label: 'Fee', value: fee),
            const SizedBox(height: SailStyleValues.padding16),
            _Line(label: 'Total', value: fmt(send.totalSats), bold: true),
            const SizedBox(height: SailStyleValues.padding16),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: SailStyleValues.padding08,
              runSpacing: SailStyleValues.padding08,
              children: [
                SailButton(
                  label: 'Cancel',
                  variant: ButtonVariant.ghost,
                  onPressed: () async => Navigator.of(context).pop(false),
                ),
                SailButton(
                  label: 'Send',
                  onPressed: () async => Navigator.of(context).pop(true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipientList extends StatelessWidget {
  final List<({String address, int sats})> payments;
  final String Function(int sats) fmt;

  const _RecipientList({required this.payments, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final total = payments.fold<int>(0, (sum, p) => sum + p.sats);

    return SailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SailText.secondary12(
                payments.length == 1 ? '1 recipient' : '${payments.length} recipients',
                bold: true,
              ),
              const Spacer(),
              SailText.secondary12(fmt(total), bold: true, monospace: true),
            ],
          ),
          const SizedBox(height: SailStyleValues.padding08),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 125),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final p in payments)
                    Padding(
                      padding: const EdgeInsets.only(bottom: SailStyleValues.padding04),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: SailText.primary13(p.address, monospace: true, overflow: null)),
                          const SizedBox(width: SailStyleValues.padding16),
                          SailText.primary13(fmt(p.sats), monospace: true),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _Line({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (bold) SailText.primary13(label, bold: true) else SailText.secondary13(label),
        const SizedBox(width: SailStyleValues.padding16),
        Expanded(
          child: SailText.primary13(value, bold: bold, monospace: true, textAlign: TextAlign.end, overflow: null),
        ),
      ],
    );
  }
}
