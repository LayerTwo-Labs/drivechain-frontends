import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart';

/// What the user chose when a send would spend coins that exist on both chains.
enum ReplayChoice { cancel, sendPlain, sendProtected }

/// Asks before a send spends coins that exist on both chains, and offers
/// replay protection for that one transaction.
Future<ReplayChoice> askReplayProtection(
  BuildContext context, {
  required List<UnspentOutput> coins,
  bool coinsKnown = true,
}) async {
  final choice = await showThemedDialog<ReplayChoice>(
    context: context,
    builder: (context) => SailModal(
      constraints: const BoxConstraints(maxWidth: 720),
      child: SailCard(
        title: coinsKnown && coins.length == 1 ? 'This coin exists on both chains' : 'These coins exist on both chains',
        subtitle: coinsKnown
            ? 'Spending them makes the same transaction on the other chain.'
            : 'The wallet did not report its coins yet, so this send can spend one that exists on both chains.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (coinsKnown) ...[
              SailText.primary15('Coins on both chains', bold: true),
              const SizedBox(height: SailStyleValues.padding08),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 240),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: coins.map((c) => _CoinRow(coin: c)).toList(),
                  ),
                ),
              ),
              const SizedBox(height: SailStyleValues.padding16),
            ],
            SailText.secondary13(
              'Replay protection keeps this transaction on this chain only. The other chain rejects it.',
            ),
            const SizedBox(height: SailStyleValues.padding16),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: SailStyleValues.padding08,
              runSpacing: SailStyleValues.padding08,
              children: [
                SailButton(
                  label: 'Cancel',
                  variant: ButtonVariant.ghost,
                  onPressed: () async => Navigator.of(context).pop(ReplayChoice.cancel),
                ),
                SailButton(
                  label: 'Send without protection',
                  variant: ButtonVariant.secondary,
                  onPressed: () async => Navigator.of(context).pop(ReplayChoice.sendPlain),
                ),
                SailButton(
                  label: 'Enable replay protection',
                  onPressed: () async => Navigator.of(context).pop(ReplayChoice.sendProtected),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return choice ?? ReplayChoice.cancel;
}

class _CoinRow extends StatelessWidget {
  final UnspentOutput coin;

  const _CoinRow({required this.coin});

  @override
  Widget build(BuildContext context) {
    final formatter = GetIt.I.get<FormatterProvider>();
    return Padding(
      padding: const EdgeInsets.only(bottom: SailStyleValues.padding04),
      child: Row(
        children: [
          SailText.secondary13(formatter.formatSats(coin.valueSats.toInt()), monospace: true),
          const Spacer(),
          SailText.secondary13(_shortAddress(coin.address), monospace: true),
        ],
      ),
    );
  }
}

String _shortAddress(String address) {
  if (address.length <= 14) {
    return address;
  }
  return '${address.substring(0, 6)}…${address.substring(address.length - 4)}';
}
