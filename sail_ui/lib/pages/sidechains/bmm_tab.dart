import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/bmm/v1/bmm.pb.dart' as bmmpb;
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

final NumberFormat _thousands = NumberFormat('#,##0', 'en_US');

/// Digits in groups of three, split by a thin space that never breaks a line.
String groupDigits(int value) => _thousands.format(value).replaceAll(',', '\u2009');

/// A hash cut to its first characters, so a table cell holds it on one line.
String shortenHash(String hash) {
  if (hash.isEmpty) {
    return '—';
  }
  return hash.length > 16 ? '${hash.substring(0, 16)}..' : hash;
}

/// A sidechain block hash in the h* form the enforcer and the miners use.
String shortenCriticalHash(String hash) {
  if (hash.isEmpty) {
    return '—';
  }
  return hash.length > 8 ? 'h*${hash.substring(0, 8)}..' : 'h*$hash';
}

const String bidStateWaiting = 'Waiting for a miner';
const String bidStateConnected = 'Connected';
const String bidStateNotIncluded = 'Not included';
const String bidStateSkipped = 'Skipped';

/// One row of the historic bids table: our bid for a round, and its outcome.
class HistoricBid {
  final String prevMainHash;
  final String state;
  final int bidSats;
  final int blockFeesSats;
  final int? profitSats;
  final String txid;
  final String mainchainBlock;

  const HistoricBid({
    required this.prevMainHash,
    required this.state,
    required this.bidSats,
    required this.blockFeesSats,
    required this.profitSats,
    required this.txid,
    required this.mainchainBlock,
  });
}

String historicBidState(String result) => switch (result) {
  'won' => bidStateConnected,
  'lost' => bidStateNotIncluded,
  'skipped' => bidStateSkipped,
  _ => bidStateWaiting,
};

Color? historicBidStateColor(String state, SailColor colors) => switch (state) {
  bidStateConnected => colors.success,
  bidStateWaiting => colors.orange,
  _ => colors.textSecondary,
};

/// Our bids, newest first. A round we never bid on has no row.
List<HistoricBid> historicBids(bmmpb.Round? current, List<bmmpb.Round> history) {
  final rows = <HistoricBid>[];
  final seen = <String>{};
  for (final round in [?current, ...history]) {
    final bid = round.ourBids.lastOrNull;
    if (bid == null || !seen.add(round.prevMainHash)) {
      continue;
    }
    rows.add(
      HistoricBid(
        prevMainHash: round.prevMainHash,
        state: historicBidState(round.result),
        bidSats: bid.bidSats.toInt(),
        blockFeesSats: round.blockWorthSats.toInt(),
        profitSats: round.hasProfit ? round.profitSats.toInt() : null,
        txid: bid.txid,
        // Only a bid a miner took rides in a block. A lost round names the
        // winner's block, which was never ours.
        mainchainBlock: round.result == 'won' ? round.includedInBlock : '',
      ),
    );
  }
  return rows;
}

String profitLabel(int? sats) {
  if (sats == null) {
    return '—';
  }
  return sats < 0 ? '-${groupDigits(-sats)}' : '+${groupDigits(sats)}';
}

/// A round the chain left behind pays no fees back, so it returns the bid as a
/// loss.
Color? profitColor(int? profitSats, SailColor colors) {
  if (profitSats == null) {
    return null;
  }
  return profitSats < 0 ? colors.error : colors.success;
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
          subtitle: 'Bid on the parent chain to mine a ${viewModel.chainName} block',
          error: viewModel.bmmError,
          child: SailColumn(
            spacing: SailStyleValues.padding16,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Controls(viewModel: viewModel),
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

const double _controlsGap = 44;

class _Controls extends StatelessWidget {
  final BMMViewModel viewModel;
  const _Controls({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final colors = SailTheme.of(context).colors;
    // Stopping stays available while the enforcer is behind: an engine started
    // before it fell back has to be stoppable.
    final blocked = !viewModel.canBid;

    return SailColumn(
      spacing: SailStyleValues.padding08,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailRow(
          spacing: _controlsGap,
          children: [
            SailButton(
              label: viewModel.running ? 'Stop auto-bidding' : 'Start auto-bidding',
              disabled: blocked && !viewModel.running,
              onPressed: () async => viewModel.running ? await viewModel.stopBidding() : await viewModel.startBidding(),
            ),
            _Field(
              label: 'Wallet:',
              width: 220,
              child: WalletPicker(
                selectedWalletId: viewModel.fundingWalletId,
                onChanged: viewModel.setFundingWallet,
              ),
            ),
            _Field(
              label: 'Min bid:',
              child: SailTextField(
                controller: viewModel.minBidController,
                hintText: '0.00005000',
                readOnly: true,
              ),
            ),
            _Field(
              label: 'Max bid:',
              child: SailTextField(controller: viewModel.maxBidController, hintText: '0.00020000'),
            ),
            Expanded(child: Container()),
            SailButton(
              label: 'Bid manually',
              variant: ButtonVariant.secondary,
              disabled: blocked,
              onPressed: () async => _showManualBidDialog(context, viewModel),
            ),
          ],
        ),
        if (viewModel.fundingWarning) SailText.secondary12(viewModel.fundingWarningLabel, color: colors.orange),
      ],
    );
  }

  void _showManualBidDialog(BuildContext context, BMMViewModel viewModel) {
    final controller = TextEditingController(text: viewModel.bmmProvider.suggestedBidSats.toString());
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

/// A label beside its control, as the controls row lines them up.
class _Field extends StatelessWidget {
  final String label;
  final Widget child;
  final double width;

  const _Field({required this.label, required this.child, this.width = 130});

  @override
  Widget build(BuildContext context) {
    return SailRow(
      spacing: SailStyleValues.padding08,
      children: [
        SailText.primary13(label),
        SizedBox(width: width, child: child),
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
    final colors = SailTheme.of(context).colors;
    final live = viewModel.bmmProvider.liveBid;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SailStyleValues.padding16),
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SailColumn(
        spacing: SailStyleValues.padding12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailRow(
            spacing: SailStyleValues.padding12,
            children: [
              SailText.primary13('Current slot', bold: true),
              SailBadge(viewModel.slotStatus, tone: viewModel.slotTone),
              Expanded(child: Container()),
              SailText.secondary13(viewModel.slotHint),
            ],
          ),
          SailRow(
            spacing: SailStyleValues.padding64,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Figure(label: 'Block worth', value: viewModel.satsLabel(viewModel.blockWorthSats)),
              _Figure(
                label: 'Your bid',
                value: live == null ? '—' : viewModel.satsLabel(live.bidSats.toInt()),
              ),
              _Figure(label: 'Profit if won', value: viewModel.satsLabel(viewModel.profitIfWon)),
              _Figure(label: 'Sidechain block ready', value: viewModel.currentCriticalHash),
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
      spacing: SailStyleValues.padding04,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.secondary13(label),
        SailText.primary20(value, bold: true),
      ],
    );
  }
}

/// A title over its explanation, with room for one action on the right.
class _SectionHead extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? action;

  const _SectionHead({required this.title, required this.subtitle, this.action});

  @override
  Widget build(BuildContext context) {
    return SailRow(
      spacing: SailStyleValues.padding08,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SailColumn(
            spacing: 2,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailText.primary14(title, bold: true),
              SailText.secondary13(subtitle),
            ],
          ),
        ),
        ?action,
      ],
    );
  }
}

/// The border every table on this page sits inside.
class _TableFrame extends StatelessWidget {
  final double height;
  final Widget child;

  const _TableFrame({required this.height, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = SailTheme.of(context).colors;
    return Container(
      width: double.infinity,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}

/// A hash that opens the mainchain explorer.
class _HashLink extends StatelessWidget {
  final String label;
  final String url;
  final Color? color;

  const _HashLink({required this.label, required this.url, this.color});

  @override
  Widget build(BuildContext context) {
    final tone = color ?? SailTheme.of(context).colors.info;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => unawaited(launchUrl(Uri.parse(url))),
        child: SailRow(
          spacing: SailStyleValues.padding08,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(child: SailText.primary13(label, color: tone)),
            SailSVG.icon(SailSVGAsset.externalLink, color: tone, width: 12, height: 12),
          ],
        ),
      ),
    );
  }
}

/// Height a bordered table takes: its header, plus one line per row.
double tableFrameHeight(int rows) => rows == 0 ? 100 : (rows * 40) + 42;

/// Every bid we can see for this round, highest first. Ours are marked rather
/// than reordered, so the running order of the auction stays readable.
class _BidsOnNextBlock extends StatelessWidget {
  final BMMViewModel viewModel;
  const _BidsOnNextBlock({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final colors = SailTheme.of(context).colors;
    final bids = viewModel.bmmProvider.currentBids;

    return SailColumn(
      spacing: SailStyleValues.padding08,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHead(
          title: 'Bids on next block',
          subtitle:
              'Every bid for slot ${viewModel.slot} in the mainchain mempool, highest first. '
              'Updates as bids arrive.',
        ),
        _TableFrame(
          height: tableFrameHeight(bids.length),
          child: SailTable(
            getRowId: (index) => bids[index].txid.isEmpty ? 'bid-$index' : bids[index].txid,
            emptyPlaceholder: 'No bids yet',
            headerBackgroundColor: colors.backgroundSecondary,
            headerBuilder: (context) => [
              SailTableHeaderCell(name: 'Bid (sats)'),
              SailTableHeaderCell(name: 'Bidder'),
              SailTableHeaderCell(name: 'Sidechain block (h*)'),
              SailTableHeaderCell(name: 'Prev mainchain block'),
              SailTableHeaderCell(name: 'Mainchain txid'),
              SailTableHeaderCell(name: 'Status'),
            ],
            rowBuilder: (context, row, selected) {
              final bid = bids[row];
              return [
                SailTableCell(value: groupDigits(bid.bidSats.toInt())),
                SailTableCell(
                  value: bid.isOurs ? 'You' : '—',
                  textColor: bid.isOurs ? colors.info : null,
                ),
                SailTableCell(value: shortenCriticalHash(bid.criticalHash)),
                SailTableCell(value: shortenHash(bid.prevMainHash)),
                SailTableCell(
                  value: bid.txid,
                  copyValue: bid.txid,
                  child: bid.txid.isEmpty
                      ? null
                      : _HashLink(label: shortenHash(bid.txid), url: viewModel.txUrl(bid.txid)),
                ),
                _statusCell(bid, bids, colors),
              ];
            },
            rowCount: bids.length,
            rowBackgroundColor: (index) => bids[index].isOurs ? colors.info.withValues(alpha: 0.06) : null,
            drawLastRowsBorder: false,
          ),
        ),
      ],
    );
  }

  SailTableCell _statusCell(bmmpb.Bid bid, List<bmmpb.Bid> bids, SailColor colors) {
    final replacement = bid.replacedByTxid;
    if (replacement.isNotEmpty) {
      return SailTableCell(
        value: replacement,
        copyValue: replacement,
        child: _HashLink(
          label: 'Replaced by ${shortenHash(replacement)}',
          url: viewModel.txUrl(replacement),
          color: colors.orange,
        ),
      );
    }
    return SailTableCell(
      value: viewModel.bidStatus(bid, bids),
      copyValue: bid.error.isEmpty ? null : bid.error,
      textColor: viewModel.bidStatusColor(bid, bids, colors),
    );
  }
}

/// One row per bid we placed, newest first, with a drilldown to the round.
class _HistoricBids extends StatelessWidget {
  final BMMViewModel viewModel;
  const _HistoricBids({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final colors = SailTheme.of(context).colors;
    final rows = viewModel.historicRows;

    return SailColumn(
      spacing: SailStyleValues.padding08,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHead(
          title: 'Historic bids',
          subtitle: 'What your bids came to. A bid only costs anything once a miner takes it.',
          action: rows.isEmpty
              ? null
              : SailButton(
                  label: 'Clear history',
                  variant: ButtonVariant.secondary,
                  small: true,
                  onPressed: () async => viewModel.bmmProvider.clearHistory(),
                ),
        ),
        _TableFrame(
          height: tableFrameHeight(rows.length).clamp(100, 362),
          child: SailTable(
            getRowId: (index) => rows[index].prevMainHash,
            emptyPlaceholder: 'No bids yet',
            headerBackgroundColor: colors.backgroundSecondary,
            headerBuilder: (context) => [
              SailTableHeaderCell(name: 'State'),
              SailTableHeaderCell(name: 'Bid (sats)'),
              SailTableHeaderCell(name: 'Block fees (sats)'),
              SailTableHeaderCell(name: 'Profit (sats)'),
              SailTableHeaderCell(name: 'Mainchain txid'),
              SailTableHeaderCell(name: 'Mainchain block'),
            ],
            rowBuilder: (context, row, selected) {
              final bid = rows[row];
              return [
                SailTableCell(
                  value: bid.state,
                  textColor: historicBidStateColor(bid.state, colors),
                ),
                SailTableCell(value: groupDigits(bid.bidSats)),
                SailTableCell(value: groupDigits(bid.blockFeesSats)),
                SailTableCell(
                  value: profitLabel(bid.profitSats),
                  textColor: profitColor(bid.profitSats, colors),
                ),
                SailTableCell(
                  value: bid.txid,
                  copyValue: bid.txid,
                  child: bid.txid.isEmpty
                      ? null
                      : _HashLink(label: shortenHash(bid.txid), url: viewModel.txUrl(bid.txid)),
                ),
                SailTableCell(
                  value: bid.mainchainBlock,
                  copyValue: bid.mainchainBlock,
                  child: bid.mainchainBlock.isEmpty
                      ? SailText.primary13('—', color: colors.textSecondary)
                      : _HashLink(
                          label: shortenHash(bid.mainchainBlock),
                          url: viewModel.blockUrl(bid.mainchainBlock),
                        ),
                ),
              ];
            },
            rowCount: rows.length,
            drawLastRowsBorder: false,
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

  final TextEditingController maxBidController = TextEditingController();
  final TextEditingController minBidController = TextEditingController();

  BMMViewModel() {
    maxBidController.text = bmmProvider.maxBidAmount.toStringAsFixed(8);
    maxBidController.addListener(_onMaxBound);
    minBidController.text = _minBidText;
    bmmProvider.addListener(_onProviderChanged);
    _sync.addListener(_onSyncChanged);
  }

  String get chainName => bmmProvider.sidechainRPC.chain.name;
  int get slot => bmmProvider.sidechainRPC.chain.slot;

  bool get canBid => bidBlockedReason == null;
  String? get bidBlockedReason => bidBlockedReasonFor(_sync);

  bool get running => bmmProvider.running;
  String? get bmmError => bmmProvider.error ?? bmmProvider.lastBidError;

  String? get fundingWalletId => bmmProvider.fundingWalletId;
  void setFundingWallet(String walletId) => bmmProvider.setFundingWalletId(walletId);

  bool get fundingBalanceTooLow => bmmProvider.fundingBalanceTooLow;

  bool get fundingWarning => fundingWalletId == null || fundingBalanceTooLow;

  String get fundingWarningLabel {
    if (fundingWalletId == null) {
      return BMMProvider.noFundingWallet;
    }
    final sats = bmmProvider.fundingBalanceSats ?? 0;
    return 'The wallet holds ${satoshiToBTC(sats).toStringAsFixed(8)} BTC, '
        'under the max bid of ${bmmProvider.maxBidAmount.toStringAsFixed(8)} BTC';
  }

  /// The bid the engine opens at, from Core's own rate and a plain bid's size.
  String get _minBidText => satoshiToBTC(bmmProvider.suggestedBidSats).toStringAsFixed(8);

  int get blockWorthSats => bmmProvider.current?.blockWorthSats.toInt() ?? 0;

  List<HistoricBid> get historicRows => historicBids(bmmProvider.current, bmmProvider.history);

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
    return live == null ? '—' : shortenCriticalHash(live.criticalHash);
  }

  String get slotStatus {
    if (!running) {
      return 'Not bidding';
    }
    return bmmProvider.liveBid == null ? 'Assembling' : 'Bid placed';
  }

  SailBadgeTone get slotTone => bmmProvider.liveBid == null ? SailBadgeTone.neutral : SailBadgeTone.success;

  String get slotHint {
    final live = bmmProvider.liveBid;
    if (!running && live == null) {
      return bidBlockedReason ?? 'Press Start auto-bidding to bid for the next block';
    }
    if (live == null) {
      return '';
    }
    return 'Waiting for a miner to commit to ${shortenCriticalHash(live.criticalHash)}';
  }

  void _onMaxBound() {
    final max = double.tryParse(maxBidController.text.trim());
    if (max != null) {
      bmmProvider.setMaxBidAmount(max);
    }
  }

  // Sync progress moves constantly, and mirroring the bounds on every step
  // would overwrite a bound the user is still typing.
  void _onSyncChanged() {
    notifyListeners();
  }

  void _onProviderChanged() {
    // Mirror bounds the backend reports, except while an edit is waiting to be
    // pushed — that value is the user's, mid-typing.
    if (!bmmProvider.boundsPushPending) {
      _mirrorBound(maxBidController, bmmProvider.maxBidAmount);
    }
    if (minBidController.text != _minBidText) {
      minBidController.text = _minBidText;
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

  String satsLabel(int sats) => sats == 0 ? '—' : '${groupDigits(sats)} sats';

  String txUrl(String txid) => mempoolTxUrl(txid, _conf.network);
  String blockUrl(String hash) => mempoolBlockUrl(hash, _conf.network);

  /// The block that decided the round, by height when the enforcer gave us one.
  String blockLabel(bmmpb.Round round) {
    if (round.includedInHeight > 0) {
      return round.includedInHeight.toString();
    }
    return shortenHash(round.includedInBlock);
  }

  /// A replaced bid is superseded by our own raise, so it can never be mined.
  String bidStatus(bmmpb.Bid bid, List<bmmpb.Bid> bids) {
    if (bid.replacedByTxid.isNotEmpty) {
      return 'Replaced by ${shortenHash(bid.replacedByTxid)}';
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
    unawaited(launchUrl(Uri.parse(txUrl(txid))));
  }

  Future<void> showAllBids(BuildContext context, String prevMainHash) async {
    final round = await bmmProvider.roundBids(prevMainHash);
    if (!context.mounted) {
      return;
    }

    await showThemedDialog(
      context: context,
      builder: (BuildContext context) {
        final colors = SailTheme.of(context).colors;
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
                _TableFrame(
                  height: tableFrameHeight(bids.length),
                  child: SailTable(
                    getRowId: (index) => bids[index].txid.isEmpty ? 'bid-$index' : bids[index].txid,
                    emptyPlaceholder: 'No bids yet',
                    headerBackgroundColor: colors.backgroundSecondary,
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
                        SailTableCell(value: groupDigits(bid.bidSats.toInt())),
                        SailTableCell(
                          value: bid.isOurs ? 'You' : '—',
                          textColor: bid.isOurs ? colors.info : null,
                        ),
                        SailTableCell(value: shortenCriticalHash(bid.criticalHash)),
                        SailTableCell(value: shortenHash(bid.txid), copyValue: bid.txid),
                        SailTableCell(value: outcomeOf(bid, round)),
                      ];
                    },
                    rowCount: bids.length,
                    rowBackgroundColor: (index) => bids[index].isOurs ? colors.info.withValues(alpha: 0.06) : null,
                    drawLastRowsBorder: false,
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
    _sync.removeListener(_onSyncChanged);
    maxBidController.dispose();
    minBidController.dispose();
    super.dispose();
  }
}
