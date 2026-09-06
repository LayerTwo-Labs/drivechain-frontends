import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/explorer/v1/explorer.pb.dart' as pb;
import 'package:sidechain_core/utils/explorer_url.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';

/// ChainExplorerTab is the explorer landing page: the newest blocks, what
/// happened last, and what the treasury holds.
class ChainExplorerTab extends StatefulWidget {
  const ChainExplorerTab({super.key});

  @override
  State<ChainExplorerTab> createState() => _ChainExplorerTabState();
}

class _ChainExplorerTabState extends State<ChainExplorerTab> {
  final TextEditingController _search = TextEditingController();
  ExplorerTarget? _target;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _open(ExplorerTarget target) => setState(() => _target = target);

  void _submit(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return;
    }
    final height = int.tryParse(trimmed);
    if (height != null) {
      _open(ExplorerTarget.block(height: height));
      return;
    }
    _open(ExplorerTarget.search(trimmed));
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ExplorerModel>.reactive(
      viewModelBuilder: () => ExplorerModel(),
      builder: (context, model, child) {
        // The page is taller than a short window, so it scrolls. The search
        // stays put above it.
        return SailColumn(
          spacing: SailStyleValues.padding16,
          children: [
            SailTextField(
              controller: _search,
              hintText: 'Search a block height, a block hash, a transaction or an address',
              onSubmitted: _submit,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: _target != null
                    ? ExplorerDetail(
                        model: model,
                        target: _target!,
                        onClose: () => setState(() => _target = null),
                        onOpen: _open,
                      )
                    : _Overview(model: model, onOpen: _open),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Overview extends StatelessWidget {
  final ExplorerModel model;
  final void Function(ExplorerTarget) onOpen;

  const _Overview({required this.model, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final overview = model.overview;
    if (overview == null) {
      return SailCard(
        title: 'Explorer',
        subtitle: model.readError ?? 'Reading the chain',
        child: const SizedBox(height: 40),
      );
    }

    return SailColumn(
      spacing: SailStyleValues.padding16,
      children: [
        _BlockStrip(model: model, onOpen: onOpen),
        _RecentActivity(overview: overview, onOpen: onOpen),
        SailRow(
          spacing: SailStyleValues.padding16,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: overview.hasTreasury()
                  ? _TreasuryCard(treasury: overview.treasury)
                  : SailCard(
                      title: 'Treasury',
                      subtitle: 'This install reads no mainchain escrow',
                      child: const SizedBox(height: 24),
                    ),
            ),
            Expanded(child: _PendingWithdrawalsCard(bundle: overview.pendingBundle)),
          ],
        ),
        DepositsCard(rows: overview.recent.where((r) => r.kind == pb.Kind.KIND_DEPOSIT).toList()),
      ],
    );
  }
}

/// _BlockStrip shows the block the chain would mine next, then the blocks it
/// mined, newest first. It reads another page whenever a reader scrolls to
/// the end, down to the genesis block.
class _BlockStrip extends StatefulWidget {
  final ExplorerModel model;
  final void Function(ExplorerTarget) onOpen;

  const _BlockStrip({required this.model, required this.onOpen});

  @override
  State<_BlockStrip> createState() => _BlockStripState();
}

class _BlockStripState extends State<_BlockStrip> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_controller.hasClients) {
      return;
    }
    final remaining = _controller.position.maxScrollExtent - _controller.offset;
    if (remaining < 400) {
      unawaited(widget.model.loadOlderBlocks());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = SailTheme.of(context).colors;
    final overview = widget.model.overview!;
    final onOpen = widget.onOpen;
    return SingleChildScrollView(
      controller: _controller,
      scrollDirection: Axis.horizontal,
      child: SailRow(
        spacing: SailStyleValues.padding12,
        children: [
          _BlockCard(
            label: 'Next',
            mainchain: null,
            mainchainHash: '',
            color: colors.success,
            amount: blockAmount(context, overview.mempool.feesSats.toInt()),
            lines: [
              transactionCount(overview.mempool.txCount),
              '',
              'Waits for a bid',
            ],
          ),
          Container(width: 1, height: 120, color: colors.divider),
          for (final block in widget.model.blocks)
            _BlockCard(
              label: '${block.height}',
              mainchain: block.mainchainHeight != 0 ? '${block.mainchainHeight}' : _shorten(block.mainchainHash),
              mainchainHash: block.mainchainHash,
              color: colors.primary,
              onTap: () => onOpen(ExplorerTarget.block(hash: block.hash)),
              amount: blockFigure(context, block),
              lines: [
                transactionCount(block.txCount),
                block.depositCount != 0 ? '+${blockAmount(context, block.depositValueSats.toInt())} deposited' : '',
                explorerAge(block.blockTime.toInt()),
              ],
            ),
        ],
      ),
    );
  }
}

class _BlockCard extends StatelessWidget {
  final String label;
  final String? mainchain;
  final String mainchainHash;
  final Color color;
  final String amount;
  final List<String> lines;
  final VoidCallback? onTap;

  const _BlockCard({
    required this.label,
    required this.mainchain,
    this.mainchainHash = '',
    required this.color,
    required this.amount,
    required this.lines,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = SailTheme.of(context).colors;
    return SizedBox(
      width: 200,
      child: SailColumn(
        spacing: 4,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SailText.primary13(label, bold: true, color: colors.info),
          _MainchainLink(label: mainchain, hash: mainchainHash),
          SailTappable(
            onTap: onTap == null ? null : () async => onTap!(),
            child: Container(
              width: 200,
              padding: const EdgeInsets.all(SailStyleValues.padding12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SailColumn(
                spacing: 4,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 26,
                    child: SailText.primary20(amount, bold: true, color: colors.background),
                  ),
                  // An empty line holds the slot, so every card reads level.
                  for (final line in lines)
                    SizedBox(
                      height: 16,
                      child: SailText.primary12(line, color: colors.background),
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

/// _MainchainLink names the mainchain block a header points at, and opens it
/// in the mainchain explorer.
class _MainchainLink extends StatelessWidget {
  final String? label;
  final String hash;

  const _MainchainLink({required this.label, required this.hash});

  @override
  Widget build(BuildContext context) {
    final colors = SailTheme.of(context).colors;
    final row = SailRow(
      spacing: 4,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SailSVG.fromAsset(
          SailSVGAsset.link2,
          width: 12,
          color: label == null ? colors.textTertiary : colors.info,
        ),
        SailText.primary12(label ?? '—', color: label == null ? colors.textTertiary : colors.info),
      ],
    );
    if (hash.isEmpty) {
      return row;
    }
    return SailTappable(
      onTap: () async => launchUrl(
        Uri.parse(mempoolBlockUrl(hash, GetIt.I.get<BitcoinConfProvider>().network)),
      ),
      child: row,
    );
  }
}

class _RecentActivity extends StatelessWidget {
  final pb.GetOverviewResponse overview;
  final void Function(ExplorerTarget) onOpen;

  const _RecentActivity({required this.overview, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final rows = overview.recent;
    final unconfirmed = rows.where((r) => !r.confirmed).length;
    return SailCard(
      title: 'Recent transactions',
      subtitle: 'Latest ${rows.length} · $unconfirmed unconfirmed',
      child: SizedBox(
        height: 360,
        child: SailTable(
          getRowId: (index) => rows[index].id,
          headerBuilder: (context) => const [
            SailTableHeaderCell(name: 'Transaction'),
            SailTableHeaderCell(name: 'Kind'),
            SailTableHeaderCell(name: 'Value'),
            SailTableHeaderCell(name: 'Fee'),
            SailTableHeaderCell(name: 'Status'),
          ],
          rowBuilder: (context, index, selected) {
            final row = rows[index];
            return [
              SailTableCell(value: _shorten(row.id), monospace: true),
              SailTableCell(value: '', child: kindBadge(row.kind)),
              SailTableCell(value: explorerAmount(context, row.valueSats.toInt())),
              SailTableCell(value: explorerAmount(context, row.feeSats.toInt())),
              SailTableCell(value: _statusOf(row)),
            ];
          },
          rowCount: rows.length,
          drawGrid: false,
          onDoubleTap: (rowId) {
            final row = rows.firstWhere((r) => r.id == rowId);
            if (row.kind == pb.Kind.KIND_DEPOSIT) {
              return;
            }
            onOpen(ExplorerTarget.transaction(rowId));
          },
          emptyPlaceholder: 'No transactions yet',
        ),
      ),
    );
  }
}

/// DepositsCard lists what the mainchain paid into the chain. A deposit never
/// sits in a block body, so a transaction list alone misses it.
class DepositsCard extends StatelessWidget {
  final List<pb.Activity> rows;
  final String subtitle;

  /// compact drops the block and the age, for a card that sits beside another
  /// one on a page that already names the block.
  final bool compact;

  const DepositsCard({super.key, required this.rows, this.subtitle = '', this.compact = false});

  @override
  Widget build(BuildContext context) {
    final total = rows.fold<int>(0, (sum, row) => sum + row.valueSats.toInt());
    final named = rows.any((row) => row.address.isNotEmpty);
    return SailCard(
      title: 'Deposits',
      subtitle: subtitle.isNotEmpty
          ? subtitle
          : rows.isEmpty
          ? 'None in the newest blocks'
          : 'Latest ${rows.length} · ${blockAmount(context, total)}',
      child: SizedBox(
        height: rows.isEmpty ? 80 : 40.0 * rows.length + 40,
        child: SailTable(
          getRowId: (index) => rows[index].id,
          headerBuilder: (context) => [
            const SailTableHeaderCell(name: 'Mainchain transaction'),
            if (named) const SailTableHeaderCell(name: 'Sidechain address'),
            const SailTableHeaderCell(name: 'Amount'),
            if (!compact) const SailTableHeaderCell(name: 'Block'),
            if (!compact) const SailTableHeaderCell(name: 'Age'),
          ],
          rowBuilder: (context, index, selected) {
            final row = rows[index];
            return [
              SailTableCell(value: _shorten(row.id), monospace: true),
              if (named) SailTableCell(value: row.address, monospace: true),
              SailTableCell(value: blockAmount(context, row.valueSats.toInt())),
              if (!compact) SailTableCell(value: 'Block ${row.blockHeight}'),
              if (!compact) SailTableCell(value: explorerAge(row.blockTime.toInt())),
            ];
          },
          rowCount: rows.length,
          drawGrid: false,
          onDoubleTap: (rowId) async => launchUrl(
            Uri.parse(mempoolTxUrl(rowId, GetIt.I.get<BitcoinConfProvider>().network)),
          ),
          emptyPlaceholder: 'No deposits yet',
        ),
      ),
    );
  }
}

class _TreasuryCard extends StatelessWidget {
  final pb.Treasury treasury;

  const _TreasuryCard({required this.treasury});

  @override
  Widget build(BuildContext context) {
    return SailCard(
      title: 'Treasury',
      subtitle: 'Slot ${treasury.slot} · activated at mainchain ${treasury.activationHeight}',
      headerValue: blockAmount(context, treasury.balanceSats.toInt()),
      child: SailColumn(
        spacing: SailStyleValues.padding08,
        children: [
          _Field(label: 'CTIP', value: '${_shorten(treasury.ctipTxid)} : ${treasury.ctipVout}'),
        ],
      ),
    );
  }
}

/// _statusOf names the block a row sits in, and how long ago that was.
String _statusOf(pb.Activity row) {
  if (!row.confirmed) {
    return 'Unconfirmed';
  }
  final age = explorerAge(row.blockTime.toInt());
  if (age.isEmpty) {
    return 'Block ${row.blockHeight}';
  }
  return 'Block ${row.blockHeight} · $age';
}

class _PendingWithdrawalsCard extends StatelessWidget {
  final pb.WithdrawalBundle bundle;

  const _PendingWithdrawalsCard({required this.bundle});

  @override
  Widget build(BuildContext context) {
    if (!bundle.present) {
      return SailCard(
        title: 'Pending withdrawals',
        subtitle: 'No bundle',
        child: const SizedBox(height: 24),
      );
    }
    return SailCard(
      title: 'Pending withdrawals',
      headerValue: blockAmount(context, bundle.totalValueSats.toInt()),
      subtitle: '${bundle.withdrawals.length} withdrawals · bundle ${bundle.totalWeight} / ${bundle.maxWeight}',
      child: SailColumn(
        spacing: SailStyleValues.padding08,
        children: [
          _Field(
            label: 'Total mainchain fees',
            value: explorerAmount(context, bundle.totalMainFeesSats.toInt()),
          ),
          _Field(label: 'Height created', value: '${bundle.heightCreated}'),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String value;

  const _Field({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = SailTheme.of(context).colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SailStyleValues.padding12,
        vertical: SailStyleValues.padding08,
      ),
      decoration: BoxDecoration(
        color: colors.backgroundSecondary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: SailRow(
        spacing: SailStyleValues.padding08,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SailText.secondary13(label),
          SailText.primary13(value),
        ],
      ),
    );
  }
}

/// explorerAmount reads an amount in the unit the user picked, and in the
/// active network's own name for it.
String explorerAmount(BuildContext context, int sats) {
  if (sats == 0) {
    return '—';
  }
  return BitcoinFormatting.formatSatsWithUnit(context, sats);
}

/// blockAmount reads an amount on a block card, where a zero is a figure of
/// its own rather than a missing value.
String blockAmount(BuildContext context, int sats) {
  return BitcoinFormatting.formatSatsWithUnit(context, sats);
}

/// blockFigure is what a block card states in large type: what the block
/// moved, or what it collected. A source states one or the other, never both.
String blockFigure(BuildContext context, pb.Block block) {
  if (block.valueKnown) {
    return blockAmount(context, block.valueSats.toInt());
  }
  if (block.feesKnown) {
    return blockAmount(context, block.feesSats.toInt());
  }
  return '';
}

/// transactionCount names how many transactions a block carried.
String transactionCount(int count) {
  return switch (count) {
    0 => 'No transactions',
    1 => '1 transaction',
    _ => '$count transactions',
  };
}

/// explorerAge reads how long ago a block arrived. A sidechain header carries
/// no clock, so the time comes from the mainchain block it names.
String explorerAge(int unixSeconds) {
  if (unixSeconds <= 0) {
    return '';
  }
  final age = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(unixSeconds * 1000));
  if (age.inMinutes < 1) {
    return 'just now';
  }
  if (age.inMinutes < 60) {
    return '${age.inMinutes} ${age.inMinutes == 1 ? 'minute' : 'minutes'} ago';
  }
  if (age.inHours < 24) {
    return '${age.inHours} ${age.inHours == 1 ? 'hour' : 'hours'} ago';
  }
  return '${age.inDays} ${age.inDays == 1 ? 'day' : 'days'} ago';
}

/// kindBadge marks a row as a deposit, a withdrawal or a transfer. A reader
/// looking for money leaving or arriving finds it by colour.
Widget kindBadge(pb.Kind kind) {
  return switch (kind) {
    pb.Kind.KIND_DEPOSIT => const SailBadge('Deposit', tone: SailBadgeTone.success),
    pb.Kind.KIND_WITHDRAWAL => const SailBadge('Withdrawal', tone: SailBadgeTone.warning),
    _ => const SailBadge('Transfer'),
  };
}

String _shorten(String id) {
  if (id.length <= 20) {
    return id;
  }
  return '${id.substring(0, 8)}…${id.substring(id.length - 8)}';
}
