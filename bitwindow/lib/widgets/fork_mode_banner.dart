import 'package:bitwindow/providers/fork_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
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
        final active = GetIt.I<WalletReaderProvider>().activeWalletId;
        if (!_fork.hasFundsToClaim || _fork.claimsForWallet(active).isEmpty || _fork.claimCardDismissed) {
          return const SizedBox.shrink();
        }
        return _ClaimEcashCard(fork: _fork, walletId: active);
      },
    );
  }
}

/// Share of the window the claim card body may take before it scrolls. The
/// window goes down to 400 pixels tall, so a fixed height leaves no room for
/// the wallet tabs below.
const double _claimCardBodyHeightShare = 0.4;

class _ClaimEcashCard extends StatefulWidget {
  const _ClaimEcashCard({required this.fork, required this.walletId});
  final ForkProvider fork;
  final String? walletId;

  @override
  State<_ClaimEcashCard> createState() => _ClaimEcashCardState();
}

class _ClaimEcashCardState extends State<_ClaimEcashCard> {
  final Map<String, Set<String>> _selected = {};
  final Map<String, Set<String>> _seen = {};

  TransactionProvider get _transactions => GetIt.I<TransactionProvider>();

  /// Keep the selection valid against the current claims: drop wallets and
  /// coins that left, drop coins that turned non-splittable, and check each
  /// coin the first time it appears while it is selectable. A user uncheck
  /// stays unchecked — a seen coin is never re-added.
  void _syncSelection() {
    final walletIds = widget.fork.sweepableClaims.map((c) => c.walletId).toSet();
    _selected.removeWhere((id, _) => !walletIds.contains(id));
    _seen.removeWhere((id, _) => !walletIds.contains(id));
    for (final claim in widget.fork.sweepableClaims) {
      final seen = _seen.putIfAbsent(claim.walletId, () => {});
      final selected = _selected.putIfAbsent(claim.walletId, () => {});
      final selectable = <String>{};
      for (final u in claim.utxos) {
        if (widget.fork.canSelect(claim, u)) {
          selectable.add(u.output);
          if (seen.add(u.output)) {
            selected.add(u.output);
          }
        } else {
          seen.add(u.output);
        }
      }
      selected.retainAll(selectable);
    }
  }

  int get _selectedSats {
    var sum = 0;
    for (final claim in widget.fork.sweepableClaims) {
      final selected = _selected[claim.walletId] ?? {};
      for (final u in claim.utxos) {
        if (selected.contains(u.output)) {
          sum += u.valueSats.toInt();
        }
      }
    }
    return sum;
  }

  /// True when at least one wallet has a selection and every non-empty
  /// selection can pay its sweep fee.
  bool get _selectionValid {
    var any = false;
    for (final claim in widget.fork.sweepableClaims) {
      final selected = _selected[claim.walletId] ?? {};
      if (selected.isEmpty) {
        continue;
      }
      any = true;
      final sum = claim.utxos.where((u) => selected.contains(u.output)).fold<int>(0, (s, u) => s + u.valueSats.toInt());
      if (sum < ForkProvider.minClaimSats(selected.length)) {
        return false;
      }
    }
    return any;
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final formatter = GetIt.I<FormatterProvider>();
    _syncSelection();
    final selectedSats = _selectedSats;
    final claims = widget.fork.claimsForWallet(widget.walletId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SailCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                const Spacer(),
                SailButton(
                  variant: ButtonVariant.icon,
                  icon: SailSVGAsset.iconClose,
                  onPressed: () async => widget.fork.dismissClaimCard(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // The page bounds the card, so the body takes what the header
            // leaves and scrolls the rest. An unbounded host caps it instead.
            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * _claimCardBodyHeightShare,
                ),
                child: SingleChildScrollView(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...claims.map((c) => _coinPicker(context, c, formatter)),
                            const SizedBox(height: 8),
                            if (_selectionValid)
                              SailButton(
                                label: _buttonLabel(formatter, selectedSats, claims),
                                icon: SailSVGAsset.iconCoins,
                                onPressed: () => _claim(context),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(child: _whyThisIsNecessary()),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// A multisig split ends in a PSBT its cosigners still have to sign, so the
  /// button never promises a finished split.
  String _buttonLabel(FormatterProvider formatter, int selectedSats, List<WalletClaim> claims) {
    final selectedClaims = claims.where((c) => (_selected[c.walletId] ?? {}).isNotEmpty).toList();
    if (ForkProvider.splitNeedsSignatures(selectedClaims)) {
      return 'Create split transaction';
    }
    if (claims.length > 1) {
      return 'Split ${formatter.formatSats(selectedSats)} from all wallets';
    }
    return 'Split ${formatter.formatSats(selectedSats)}';
  }

  Widget _coinPicker(BuildContext context, WalletClaim claim, FormatterProvider formatter) {
    final theme = SailTheme.of(context);
    final selected = _selected[claim.walletId] ?? {};
    final receivedAt = _receivedAtByOutpoint();
    final selectedClaimSats = claim.utxos
        .where((u) => selected.contains(u.output))
        .fold<int>(0, (sum, u) => sum + u.valueSats.toInt());

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SailCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SailText.secondary12(claim.walletName.toUpperCase(), bold: true),
                const SizedBox(width: 8),
                SailText.secondary12('${claim.utxos.length} coins'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const SizedBox(width: 26),
                Expanded(flex: 3, child: SailText.secondary12('AMOUNT')),
                Expanded(flex: 2, child: SailText.secondary12('BLOCK')),
                Expanded(flex: 3, child: SailText.secondary12('RECEIVED', textAlign: TextAlign.right)),
              ],
            ),
            const SizedBox(height: 8),
            ...claim.utxos.map((u) {
              final selectable = widget.fork.canSelect(claim, u);
              final isSelected = selected.contains(u.output);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Opacity(
                  opacity: selectable ? 1 : 0.45,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 26,
                        child: SailCheckbox(
                          value: isSelected,
                          enabled: selectable,
                          onChanged: (value) => setState(() {
                            if (value) {
                              selected.add(u.output);
                            } else {
                              selected.remove(u.output);
                            }
                          }),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: SailText.primary13(formatter.formatSats(u.valueSats.toInt()), monospace: true),
                      ),
                      Expanded(
                        flex: 2,
                        child: SailText.secondary13(
                          u.height > 0 ? formatWithThousandSpacers(u.height) : '—',
                          monospace: true,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: SailText.secondary13(
                          receivedAt[u.output] != null ? formatDate(receivedAt[u.output]!) : '—',
                          textAlign: TextAlign.right,
                          monospace: true,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            Container(height: 1, color: theme.colors.divider),
            const SizedBox(height: 8),
            Row(
              children: [
                SailText.secondary13('Total'),
                const Spacer(),
                SailText.primary13(formatter.formatSats(selectedClaimSats), bold: true, monospace: true),
              ],
            ),
            if (claim.isMultisig) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  SailText.secondary13('Signatures'),
                  const Spacer(),
                  SailText.primary13(
                    '${claim.multisig!.m} of ${claim.multisig!.n} keys',
                    bold: true,
                    monospace: true,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            SailText.secondary12('SENDS JUST ECX TO'),
            const SizedBox(height: 2),
            SailText.secondary13(
              claim.isMultisig
                  ? 'A fresh address in ${claim.walletName} · ${claim.multisig!.m}-of-${claim.multisig!.n} multisig'
                  : 'A fresh address in ${claim.walletName}',
            ),
          ],
        ),
      ),
    );
  }

  /// Received timestamps only exist for the active wallet's UTXO list; other
  /// wallets fall back to the block column.
  Map<String, DateTime> _receivedAtByOutpoint() {
    final out = <String, DateTime>{};
    for (final u in _transactions.utxos) {
      if (u.hasReceivedAt()) {
        out[u.output] = u.receivedAt.toDateTime().toLocal();
      }
    }
    return out;
  }

  Widget _whyThisIsNecessary() {
    final paragraphs = [
      'You have coins on both BTC and ECX. We recommend splitting your coins to not lose any ECX or BTC you currently own.',
      'By default, a transaction valid on bitcoin is also valid on eCash. Therefore, by spending your bitcoin, you will make that same transaction on eCash. If you do not control the receiving eCash wallet, you will lose your eCash.',
      'Claiming sweeps the selected coins to a fresh address in the same wallet.',
      if (widget.fork.sweepableClaims.any((c) => c.isMultisig))
        'A multisig wallet holds some of these coins. BitWindow builds a PSBT instead of a finished transaction, and nothing is broadcast until the cosigners sign it on the send tab.',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.secondary12('WHY THIS IS NECESSARY', bold: true),
        const SizedBox(height: 8),
        ...paragraphs.map(
          (p) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SailText.secondary13(p),
          ),
        ),
      ],
    );
  }

  Future<void> _claim(BuildContext context) async {
    // Snapshot the plan first — claim() refetches and replaces the claims,
    // so one wallet's failure must not misreport the wallets already swept.
    final planned = widget.fork.sweepableClaims
        .map(
          (c) => (
            walletId: c.walletId,
            multisig: c.isMultisig,
            outpoints: Set<String>.of(_selected[c.walletId] ?? {}),
          ),
        )
        .where((p) => p.outpoints.isNotEmpty)
        .toList();

    var broadcast = 0;
    var drafted = 0;
    Object? firstError;
    for (final p in planned) {
      try {
        if (p.multisig) {
          await widget.fork.createSplitDraft(p.walletId, outpoints: p.outpoints);
          drafted++;
        } else {
          await widget.fork.claim(p.walletId, outpoints: p.outpoints);
          broadcast++;
        }
      } catch (e) {
        firstError ??= e;
      }
    }
    if (!context.mounted) {
      return;
    }
    if (firstError != null) {
      showSailToast(
        context,
        'Claimed ${broadcast + drafted} of ${planned.length} wallet(s). First error: $firstError',
        duration: const Duration(seconds: 5),
      );
      return;
    }
    if (drafted > 0 && broadcast == 0) {
      showSailToast(
        context,
        'Split transaction created. Sign it on the send tab.',
        duration: const Duration(seconds: 5),
      );
      return;
    }
    if (drafted > 0) {
      showSailToast(
        context,
        'Claimed eCash in $broadcast transaction(s). '
        '$drafted split transaction(s) wait for signatures on the send tab.',
        duration: const Duration(seconds: 5),
      );
      return;
    }
    showSailToast(context, 'Claimed eCash in $broadcast transaction(s).');
  }
}
