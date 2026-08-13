import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sidechain_core/gen/bmm/v1/bmm.pb.dart' as bmmpb;
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/utils/explorer_url.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';

/// Reason bidding is unavailable, or null when it is allowed.
///
/// A bid commits to the tip the enforcer has validated, so one built while it
/// trails Bitcoin Core names a block miners have already built past and can
/// never be included. The orchestrator rejects those bids too — this only keeps
/// the controls from offering an action that cannot succeed.
String? bidBlockedReasonFor(SyncProvider sync) {
  // Without Core the enforcer's goal falls back to its own height, which reads
  // as synced however far behind it is.
  if (sync.mainchainSyncInfo == null || (sync.mainchainError?.isNotEmpty ?? false)) {
    return 'Waiting for Bitcoin Core';
  }
  final enforcer = sync.enforcerSyncInfo;
  if (enforcer == null || (sync.enforcerError?.isNotEmpty ?? false)) {
    return 'Waiting for the enforcer to start';
  }
  if (enforcer.isSynced) {
    return null;
  }
  return 'Enforcer is syncing — '
      '${enforcer.progressCurrent.toInt()} of ${enforcer.progressGoal.toInt()} blocks';
}

class BMMTab extends StatelessWidget {
  const BMMTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => BMMViewModel(),
      builder: (context, viewModel, child) {
        return SailCard(
          title: 'BMM',
          subtitle: 'One sidechain block per mainchain block — bid below what the block is worth',
          error: viewModel.bmmError,
          child: SailColumn(
            spacing: SailStyleValues.padding16,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Controls(viewModel: viewModel),
              _FundingWallet(viewModel: viewModel),
              _CurrentSlot(viewModel: viewModel),
              _BidsOnNextBlock(viewModel: viewModel),
              _HistoricBids(viewModel: viewModel),
            ],
          ),
        );
      },
    );
  }
}

class _Controls extends StatelessWidget {
  final BMMViewModel viewModel;
  const _Controls({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    // Stopping stays available while the enforcer is behind: an engine started
    // before it fell back has to be stoppable.
    final blocked = !viewModel.canBid;
    return SailRow(
      spacing: SailStyleValues.padding08,
      children: [
        SailButton(
          label: viewModel.running ? 'Stop auto-bidding' : 'Start auto-bidding',
          disabled: blocked && !viewModel.running,
          onPressed: () async => viewModel.running ? await viewModel.stopBidding() : await viewModel.startBidding(),
        ),
        SailButton(
          label: 'Bid manually',
          variant: ButtonVariant.secondary,
          disabled: blocked,
          onPressed: () async => _showManualBidDialog(context, viewModel),
        ),
        SailButton(
          label: 'Attack',
          variant: ButtonVariant.secondary,
          disabled: blocked,
          onPressed: () async => viewModel.bmmProvider.attackBid(),
        ),
        if (viewModel.bidBlockedReason case final reason?) SailText.secondary13(reason),
        Expanded(child: Container()),
        SailText.primary13('Min bid:'),
        SizedBox(
          width: 130,
          child: SailTextField(controller: viewModel.minBidController, hintText: '0.00000100'),
        ),
        SailText.primary13('Max bid:'),
        SizedBox(
          width: 130,
          child: SailTextField(controller: viewModel.maxBidController, hintText: '0.00020000'),
        ),
      ],
    );
  }

  void _showManualBidDialog(BuildContext context, BMMViewModel viewModel) {
    final controller = TextEditingController(text: viewModel.bmmProvider.minBidSats.toString());
    final worth = viewModel.blockWorthSats;

    showThemedDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = SailTheme.of(context);
        return AlertDialog(
          title: SailText.primary15('Manual bid'),
          content: SizedBox(
            width: 480,
            child: SailColumn(
              spacing: SailStyleValues.padding12,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SailText.secondary13(
                  'One bid for the next mainchain block. It costs nothing unless a miner takes it.',
                ),
                SailTextField(controller: controller, hintText: 'Bid in sats'),
                if (worth > 0)
                  SailText.secondary12(
                    'This block collects $worth sats in fees. A bid above that loses money.',
                    color: theme.colors.orange,
                  ),
              ],
            ),
          ),
          actions: [
            SailButton(
              label: 'Cancel',
              variant: ButtonVariant.secondary,
              onPressed: () async => Navigator.of(context).pop(),
            ),
            SailButton(
              label: 'Place bid',
              onPressed: () async {
                final sats = int.tryParse(controller.text.trim());
                Navigator.of(context).pop();
                if (sats != null && sats > 0) {
                  await viewModel.bmmProvider.bidManually(sats);
                }
              },
            ),
          ],
        );
      },
    );
  }
}

/// The wallet every bid spends from, with what it holds.
class _FundingWallet extends StatelessWidget {
  final BMMViewModel viewModel;
  const _FundingWallet({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailColumn(
      spacing: SailStyleValues.padding04,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailRow(
          spacing: SailStyleValues.padding08,
          children: [
            SailText.secondary13('Funding wallet:'),
            SizedBox(
              width: 260,
              child: WalletPicker(
                selectedWalletId: viewModel.fundingWalletId,
                onChanged: viewModel.setFundingWallet,
                rawOutputs: true,
              ),
            ),
            SailText.secondary13(
              viewModel.fundingBalanceLabel,
              color: viewModel.fundingWarning ? theme.colors.orange : null,
            ),
          ],
        ),
        SailText.secondary12(
          'Bids spend from this wallet. It does not change the active wallet.',
          color: theme.colors.textTertiary,
        ),
      ],
    );
  }
}

/// The block being bid on: what it is worth, what we bid, what we stand to make.
class _CurrentSlot extends StatelessWidget {
  final BMMViewModel viewModel;
  const _CurrentSlot({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final live = viewModel.bmmProvider.liveBid;

    return Container(
      padding: const EdgeInsets.all(SailStyleValues.padding12),
      decoration: BoxDecoration(
        color: theme.colors.backgroundSecondary,
        borderRadius: SailStyleValues.borderRadiusSmall,
      ),
      child: SailColumn(
        spacing: SailStyleValues.padding08,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailRow(
            spacing: SailStyleValues.padding08,
            children: [
              SailText.primary13('Current slot', bold: true),
              SailText.secondary12(viewModel.slotStatus),
              Expanded(child: Container()),
              SailText.secondary12(viewModel.slotHint),
            ],
          ),
          SailRow(
            spacing: SailStyleValues.padding32,
            children: [
              _Figure(label: 'Block worth', value: viewModel.formatSats(viewModel.blockWorthSats)),
              _Figure(
                label: 'Your bid',
                value: live == null ? '—' : viewModel.formatSats(live.bidSats.toInt()),
              ),
              _Figure(label: 'Profit if won', value: viewModel.formatSats(viewModel.profitIfWon)),
              _Figure(label: 'Sidechain block ready', value: viewModel.currentCriticalHash),
              if (viewModel.bmmProvider.attackBidsSent > 0)
                _Figure(
                  label: 'Attack cost',
                  value:
                      '${viewModel.bmmProvider.attackBidsSent} fake, '
                      '${viewModel.bmmProvider.attackSatsSpent} sats',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  final String label;
  final String value;
  const _Figure({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return SailColumn(
      spacing: 2,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.secondary12(label),
        SailText.primary15(value),
      ],
    );
  }
}

/// Every bid we can see for this round, highest first. Ours are marked rather
/// than reordered, so the running order of the auction stays readable.
class _BidsOnNextBlock extends StatelessWidget {
  final BMMViewModel viewModel;
  const _BidsOnNextBlock({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final bids = viewModel.bmmProvider.currentBids;

    return SailColumn(
      spacing: SailStyleValues.padding08,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.primary15('Bids on next block', bold: true),
        SailText.secondary13('Every bid we can see for this round, highest first. Yours are highlighted.'),
        if (bids.isEmpty)
          SailText.secondary13('No bids yet — press Start auto-bidding to bid on every new mainchain block.')
        else
          SizedBox(
            height: (bids.length * 40) + 40,
            child: SailTable(
              getRowId: (index) => bids[index].txid.isEmpty ? 'bid-$index' : bids[index].txid,
              headerBuilder: (context) => [
                SailTableHeaderCell(name: 'Bid (sats)'),
                SailTableHeaderCell(name: 'Bidder'),
                SailTableHeaderCell(name: 'Sidechain block (h*)'),
                SailTableHeaderCell(name: 'Mainchain txid'),
                SailTableHeaderCell(name: 'Status'),
              ],
              rowBuilder: (context, row, selected) {
                final bid = bids[row];
                return [
                  SailTableCell(value: bid.bidSats.toString(), monospace: true),
                  SailTableCell(
                    value: bid.isOurs ? 'You' : 'Other',
                    textColor: bid.isOurs ? theme.colors.primary : null,
                  ),
                  SailTableCell(value: viewModel.shorten(bid.criticalHash), monospace: true),
                  SailTableCell(value: viewModel.shorten(bid.txid), copyValue: bid.txid, monospace: true),
                  SailTableCell(
                    value: viewModel.bidStatus(bid, bids),
                    textColor: viewModel.bidStatusColor(bid, bids, theme.colors),
                  ),
                ];
              },
              rowCount: bids.length,
              rowBackgroundColor: (index) => bids[index].isOurs ? theme.colors.primary.withValues(alpha: 0.06) : null,
              drawGrid: true,
              onDoubleTap: viewModel.openTx,
            ),
          ),
      ],
    );
  }
}

/// One row per mainchain block, with a drilldown to the bids it drew.
class _HistoricBids extends StatelessWidget {
  final BMMViewModel viewModel;
  const _HistoricBids({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final rounds = viewModel.bmmProvider.history;

    return SailColumn(
      spacing: SailStyleValues.padding08,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailRow(
          spacing: SailStyleValues.padding08,
          children: [
            SailText.primary15('Historic bids', bold: true),
            Expanded(child: Container()),
            if (rounds.isNotEmpty)
              SailButton(
                label: 'Clear history',
                variant: ButtonVariant.secondary,
                onPressed: () async => viewModel.bmmProvider.clearHistory(),
              ),
          ],
        ),
        SailText.secondary13('One row per mainchain block. A bid you lost never confirmed, so it cost nothing.'),
        if (rounds.isEmpty)
          SailText.secondary13('No finished rounds yet.')
        else
          SizedBox(
            height: (rounds.length * 40).clamp(80, 320).toDouble() + 40,
            child: SailTable(
              getRowId: (index) => rounds[index].prevMainHash,
              headerBuilder: (context) => [
                SailTableHeaderCell(name: 'MC block'),
                SailTableHeaderCell(name: 'Result'),
                SailTableHeaderCell(name: 'Your bid'),
                SailTableHeaderCell(name: 'Block worth'),
                SailTableHeaderCell(name: 'Profit'),
                SailTableHeaderCell(name: 'Winner'),
                SailTableHeaderCell(name: 'Bids'),
              ],
              rowBuilder: (context, row, selected) {
                final round = rounds[row];
                return [
                  SailTableCell(
                    value: viewModel.blockLabel(round),
                    copyValue: round.includedInBlock,
                    monospace: true,
                  ),
                  SailTableCell(
                    value: round.result,
                    textColor: viewModel.resultColor(round.result, theme.colors),
                  ),
                  SailTableCell(value: viewModel.ourBidOf(round), monospace: true),
                  SailTableCell(value: round.blockWorthSats.toString(), monospace: true),
                  SailTableCell(
                    value: round.hasProfit ? round.profitSats.toString() : '—',
                    monospace: true,
                    textColor: round.hasProfit ? theme.colors.success : null,
                  ),
                  SailTableCell(value: viewModel.winnerOf(round), monospace: true),
                  SailTableCell(value: '${round.ourBids.length + round.otherBids.length}'),
                ];
              },
              rowCount: rounds.length,
              drawGrid: true,
              contextMenuItems: (rowId) => [
                SailMenuItem(
                  onSelected: () => viewModel.showAllBids(context, rowId),
                  child: SailText.primary12('See all bids for block'),
                ),
              ],
              onDoubleTap: (rowId) => viewModel.showAllBids(context, rowId),
            ),
          ),
      ],
    );
  }
}

class BMMViewModel extends BaseViewModel {
  final BMMProvider bmmProvider = GetIt.I.get<BMMProvider>();
  final BitcoinConfProvider _conf = GetIt.I.get<BitcoinConfProvider>();
  final SyncProvider _sync = GetIt.I.get<SyncProvider>();

  final TextEditingController minBidController = TextEditingController();
  final TextEditingController maxBidController = TextEditingController();

  BMMViewModel() {
    minBidController.text = bmmProvider.minBidAmount.toStringAsFixed(8);
    maxBidController.text = bmmProvider.maxBidAmount.toStringAsFixed(8);
    minBidController.addListener(_onMinBound);
    maxBidController.addListener(_onMaxBound);
    bmmProvider.addListener(_onProviderChanged);
    _sync.addListener(_onProviderChanged);
  }

  bool get canBid => bidBlockedReason == null;
  String? get bidBlockedReason => bidBlockedReasonFor(_sync);

  bool get running => bmmProvider.running;
  String? get bmmError => bmmProvider.error;

  String? get fundingWalletId => bmmProvider.fundingWalletId;
  void setFundingWallet(String walletId) => bmmProvider.setFundingWalletId(walletId);

  bool get fundingBalanceTooLow => bmmProvider.fundingBalanceTooLow;

  bool get fundingWarning => fundingWalletId == null || fundingBalanceTooLow;

  String get fundingBalanceLabel {
    if (fundingWalletId == null) {
      return BMMProvider.noFundingWallet;
    }
    final sats = bmmProvider.fundingBalanceSats;
    if (sats == null) {
      return 'Reading balance…';
    }
    final balance = 'Balance ${satoshiToBTC(sats).toStringAsFixed(8)} BTC';
    if (!fundingBalanceTooLow) {
      return balance;
    }
    return '$balance — under the max bid of ${bmmProvider.maxBidAmount.toStringAsFixed(8)} BTC';
  }

  int get blockWorthSats => bmmProvider.current?.blockWorthSats.toInt() ?? 0;

  /// What the live bid stands to make, not money already earned: profit is only
  /// real once the block connects.
  int get profitIfWon {
    final live = bmmProvider.liveBid;
    if (live == null || blockWorthSats == 0) {
      return 0;
    }
    return blockWorthSats - live.bidSats.toInt();
  }

  String get currentCriticalHash {
    final live = bmmProvider.liveBid;
    return live == null ? '—' : shorten(live.criticalHash);
  }

  String get slotStatus {
    if (!running) {
      return 'Not bidding';
    }
    return bmmProvider.liveBid == null ? 'Assembling' : 'Bid placed';
  }

  String get slotHint {
    final live = bmmProvider.liveBid;
    if (!running && live == null) {
      return bidBlockedReason ?? 'Press Start auto-bidding to bid for the next block';
    }
    if (live == null) {
      return '';
    }
    return 'Waiting for a miner to commit to ${shorten(live.criticalHash)}';
  }

  // One listener per field: editing one bound must not push the other, whose box
  // may still show a value the watch stream has since moved on from.
  void _onMinBound() {
    final min = double.tryParse(minBidController.text.trim());
    if (min != null) {
      bmmProvider.setMinBidAmount(min);
    }
  }

  void _onMaxBound() {
    final max = double.tryParse(maxBidController.text.trim());
    if (max != null) {
      bmmProvider.setMaxBidAmount(max);
    }
  }

  void _onProviderChanged() {
    // Mirror bounds the backend reports, except while an edit is waiting to be
    // pushed — that value is the user's, mid-typing.
    if (!bmmProvider.boundsPushPending) {
      _mirrorBound(minBidController, bmmProvider.minBidAmount);
      _mirrorBound(maxBidController, bmmProvider.maxBidAmount);
    }
    notifyListeners();
  }

  void _mirrorBound(TextEditingController controller, double value) {
    if (double.tryParse(controller.text.trim()) == value) {
      return;
    }
    controller.text = value.toStringAsFixed(8);
  }

  Future<void> startBidding() => bmmProvider.startBidding();
  Future<void> stopBidding() => bmmProvider.stopBidding();

  String formatSats(int sats) => sats == 0 ? '—' : '$sats sats';

  String shorten(String hash) {
    if (hash.isEmpty) {
      return '—';
    }
    return hash.length > 12 ? '${hash.substring(0, 12)}..' : hash;
  }

  /// The block that decided the round, by height when the enforcer gave us one.
  String blockLabel(bmmpb.Round round) {
    if (round.includedInHeight > 0) {
      return round.includedInHeight.toString();
    }
    return shorten(round.includedInBlock);
  }

  String ourBidOf(bmmpb.Round round) {
    if (round.ourBids.isEmpty) {
      return '—';
    }
    return round.ourBids.last.bidSats.toString();
  }

  String winnerOf(bmmpb.Round round) {
    if (round.result == 'won') {
      return 'You';
    }
    if (round.winnerCriticalHash.isNotEmpty) {
      return shorten(round.winnerCriticalHash);
    }
    return '—';
  }

  Color? resultColor(String result, SailColor colors) => switch (result) {
    'won' => colors.success,
    'lost' => colors.textSecondary,
    _ => null,
  };

  /// A replaced bid is superseded by our own raise, so it can never be mined.
  String bidStatus(bmmpb.Bid bid, List<bmmpb.Bid> bids) {
    if (bid.replacedByTxid.isNotEmpty) {
      return 'Replaced by ${shorten(bid.replacedByTxid)}';
    }
    if (bid.state == 'failed') {
      return 'Failed';
    }
    if (bids.isNotEmpty && bids.first.txid == bid.txid) {
      return 'Leading';
    }
    return 'Outbid';
  }

  Color? bidStatusColor(bmmpb.Bid bid, List<bmmpb.Bid> bids, SailColor colors) {
    if (bid.replacedByTxid.isNotEmpty) {
      return colors.orange;
    }
    if (bid.state == 'failed') {
      return colors.error;
    }
    if (bids.isNotEmpty && bids.first.txid == bid.txid) {
      return colors.success;
    }
    return colors.textSecondary;
  }

  void openTx(String txid) {
    if (txid.isEmpty || txid.startsWith('bid-')) {
      return;
    }
    unawaited(launchUrl(Uri.parse(mempoolTxUrl(txid, _conf.network))));
  }

  Future<void> showAllBids(BuildContext context, String prevMainHash) async {
    final round = await bmmProvider.roundBids(prevMainHash);
    if (!context.mounted) {
      return;
    }

    await showThemedDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = SailTheme.of(context);
        final bids = [...round.ourBids, ...round.otherBids]..sort((a, b) => b.bidSats.compareTo(a.bidSats));

        return AlertDialog(
          title: SailText.primary15('Bids for mainchain block ${blockLabel(round)}'),
          content: SizedBox(
            width: 900,
            child: SailColumn(
              spacing: SailStyleValues.padding12,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SailText.secondary13(
                  'A losing bid never confirms and leaves the mempool, so this is every bid we saw '
                  'while the block was pending — not proof that it was all of them.',
                ),
                SizedBox(
                  height: (bids.length * 40) + 40,
                  child: SailTable(
                    getRowId: (index) => bids[index].txid.isEmpty ? 'bid-$index' : bids[index].txid,
                    headerBuilder: (context) => [
                      SailTableHeaderCell(name: 'Bid (sats)'),
                      SailTableHeaderCell(name: 'Bidder'),
                      SailTableHeaderCell(name: 'Sidechain block (h*)'),
                      SailTableHeaderCell(name: 'Mainchain txid'),
                      SailTableHeaderCell(name: 'Outcome'),
                    ],
                    rowBuilder: (context, row, selected) {
                      final bid = bids[row];
                      return [
                        SailTableCell(value: bid.bidSats.toString(), monospace: true),
                        SailTableCell(value: bid.isOurs ? 'You' : 'Other'),
                        SailTableCell(value: shorten(bid.criticalHash), monospace: true),
                        SailTableCell(value: shorten(bid.txid), copyValue: bid.txid, monospace: true),
                        SailTableCell(value: outcomeOf(bid, round)),
                      ];
                    },
                    rowCount: bids.length,
                    rowBackgroundColor: (index) =>
                        bids[index].isOurs ? theme.colors.primary.withValues(alpha: 0.06) : null,
                    drawGrid: true,
                    onDoubleTap: openTx,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            SailButton(label: 'Close', onPressed: () async => Navigator.of(context).pop()),
          ],
        );
      },
    );
  }

  String outcomeOf(bmmpb.Bid bid, bmmpb.Round round) {
    if (bid.replacedByTxid.isNotEmpty) {
      return 'Replaced';
    }
    if (bid.txid.isNotEmpty && bid.txid == round.winnerTxid) {
      return 'Won';
    }
    if (bid.criticalHash.isNotEmpty && bid.criticalHash == round.winnerCriticalHash) {
      return 'Won';
    }
    return 'Lost';
  }

  @override
  void dispose() {
    bmmProvider.removeListener(_onProviderChanged);
    _sync.removeListener(_onProviderChanged);
    minBidController.dispose();
    maxBidController.dispose();
    super.dispose();
  }
}
