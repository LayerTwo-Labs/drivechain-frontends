import 'package:bitwindow/providers/fork_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

/// Drives "fork mode" at the top of the wallet page:
/// - before the fork: a countdown to the fork height,
/// - after the fork, with un-swept pre-fork coins: the big "claim your eCash"
///   hero card,
/// - otherwise nothing.
class ForkModeBanner extends StatelessWidget {
  const ForkModeBanner({super.key});

  ForkProvider get _fork => GetIt.I<ForkProvider>();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _fork,
      builder: (context, _) {
        // Claim card only — the countdown is handled globally by
        // ForkCountdownTimer, and is hidden by the engine while coins are
        // unclaimed, so the two never overlap.
        if (!_fork.hasFundsToClaim) return const SizedBox.shrink();
        return _ClaimEcashCard(fork: _fork);
      },
    );
  }
}

class _ClaimEcashCard extends StatelessWidget {
  const _ClaimEcashCard({required this.fork});
  final ForkProvider fork;

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final formatter = GetIt.I<FormatterProvider>();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SailCard(
        color: theme.colors.orange.withValues(alpha: 0.08),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SailSVG.fromAsset(
                  SailSVGAsset.iconCoins,
                  width: 22,
                  height: 22,
                  color: theme.colors.orange,
                ),
                const SizedBox(width: 8),
                SailText.primary15('You have eCash to claim', bold: true),
              ],
            ),
            const SizedBox(height: 4),
            SailText.secondary13(
              'The eCash fork is live. Sweep your pre-fork coins to a fresh address you '
              'control — your Bitcoin stays exactly where it is.',
            ),
            const SizedBox(height: 16),
            SailText.primary24(formatter.formatSats(fork.totalClaimableSats)),
            const SizedBox(height: 12),
            // Only claimable wallets — the enforcer wallet can't be swept, so
            // it's left out entirely (it never keeps this card open).
            ...fork.sweepableClaims.map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  children: [
                    SailText.secondary13(c.walletName),
                    const Spacer(),
                    SailText.secondary13(formatter.formatSats(c.claimableSats)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (fork.totalClaimableSats > 0)
              SailButton(
                label: fork.sweepableClaims.length > 1 ? 'Claim eCash from all wallets' : 'Claim eCash',
                icon: SailSVGAsset.iconCoins,
                onPressed: () => _claim(context),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _claim(BuildContext context) async {
    try {
      final txids = await fork.claimAll();
      if (context.mounted) {
        showSnackBar(context, 'Claimed eCash in ${txids.length} transaction(s).');
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, 'Could not claim eCash: $e', duration: 5);
      }
    }
  }
}
