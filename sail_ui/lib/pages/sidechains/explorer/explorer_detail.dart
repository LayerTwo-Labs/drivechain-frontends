import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/explorer/v1/explorer.pb.dart' as pb;
import 'package:sidechain_core/utils/explorer_url.dart';
import 'package:url_launcher/url_launcher.dart';

/// What the explorer is looking at.
enum ExplorerTargetKind { block, transaction, address, search }

/// ExplorerTarget names one thing to read. A search resolves to whichever of
/// the three the chain knows.
class ExplorerTarget {
  final ExplorerTargetKind kind;
  final String id;
  final int? height;

  const ExplorerTarget._(this.kind, this.id, this.height);

  factory ExplorerTarget.block({String? hash, int? height}) =>
      ExplorerTarget._(ExplorerTargetKind.block, hash ?? '', height);
  factory ExplorerTarget.transaction(String txid) => ExplorerTarget._(ExplorerTargetKind.transaction, txid, null);
  factory ExplorerTarget.address(String address) => ExplorerTarget._(ExplorerTargetKind.address, address, null);
  factory ExplorerTarget.search(String query) => ExplorerTarget._(ExplorerTargetKind.search, query, null);
}

/// ExplorerDetail reads one block, transaction or address.
class ExplorerDetail extends StatefulWidget {
  final ExplorerModel model;
  final ExplorerTarget target;
  final VoidCallback onClose;
  final void Function(ExplorerTarget) onOpen;

  const ExplorerDetail({
    super.key,
    required this.model,
    required this.target,
    required this.onClose,
    required this.onOpen,
  });

  @override
  State<ExplorerDetail> createState() => _ExplorerDetailState();
}

class _ExplorerDetailState extends State<ExplorerDetail> {
  Object? _result;
  String? _error;

  /// _generation counts the loads. A reader who opens a second thing before
  /// the first arrives must not see the first land on top of it.
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant ExplorerDetail old) {
    super.didUpdateWidget(old);
    if (old.target != widget.target) {
      _load();
    }
  }

  Future<void> _load() async {
    final generation = ++_generation;
    setState(() {
      _result = null;
      _error = null;
    });
    try {
      final result = await _read();
      if (mounted && generation == _generation) {
        setState(() => _result = result);
      }
    } catch (e) {
      if (mounted && generation == _generation) {
        setState(() => _error = e.toString());
      }
    }
  }

  /// A search tries each kind in turn, because a chain gives no way to tell a
  /// block hash from a txid by its shape alone.
  Future<Object> _read() async {
    final target = widget.target;
    switch (target.kind) {
      case ExplorerTargetKind.block:
        return await widget.model.block(
          hash: target.id.isEmpty ? null : target.id,
          height: target.height,
        );
      case ExplorerTargetKind.transaction:
        return await widget.model.transaction(target.id);
      case ExplorerTargetKind.address:
        return await widget.model.address(target.id);
      case ExplorerTargetKind.search:
        try {
          return await widget.model.transaction(target.id);
        } catch (_) {}
        try {
          return await widget.model.block(hash: target.id);
        } catch (_) {}
        return await widget.model.address(target.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return SailColumn(
      spacing: SailStyleValues.padding16,
      children: [
        SailRow(
          spacing: SailStyleValues.padding08,
          children: [
            SailButton(
              label: 'Back to the chain',
              variant: ButtonVariant.secondary,
              icon: SailSVGAsset.arrowLeft,
              onPressed: () async => widget.onClose(),
            ),
          ],
        ),
        if (_error != null)
          SailCard(title: 'Not found', subtitle: _error, child: const SizedBox(height: 24))
        else if (result == null)
          SailCard(title: 'Reading', child: const SizedBox(height: 24))
        else if (result is pb.GetBlockResponse)
          _BlockView(response: result, onOpen: widget.onOpen)
        else if (result is pb.Transaction)
          _TransactionView(transaction: result, onOpen: widget.onOpen)
        else if (result is pb.GetAddressResponse)
          _AddressView(response: result, onOpen: widget.onOpen),
      ],
    );
  }
}

class _BlockView extends StatelessWidget {
  final pb.GetBlockResponse response;
  final void Function(ExplorerTarget) onOpen;

  const _BlockView({required this.response, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final block = response.block;
    return SailColumn(
      spacing: SailStyleValues.padding16,
      children: [
        _Header(title: 'Block ${block.height}', id: block.hash),
        SailRow(
          spacing: SailStyleValues.padding16,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SailCard(
                title: 'Details',
                child: SailColumn(
                  spacing: SailStyleValues.padding08,
                  children: [
                    _Row(label: 'Transactions', value: '${block.txCount}'),
                    _Row(label: 'Value', value: explorerAmount(context, block.valueSats.toInt())),
                    _Row(
                      label: 'Transaction bytes',
                      value: block.sizeBytes == 0 ? '—' : '${block.sizeBytes}',
                    ),
                    _Row(
                      label: 'Fees',
                      value: block.feesKnown ? explorerAmount(context, block.feesSats.toInt()) : '—',
                    ),
                    _Row(label: 'Merkle root', value: shortenId(block.merkleRoot)),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SailCard(
                title: 'Blind merge mine',
                subtitle: 'The mainchain block that carried the bid',
                child: SailColumn(
                  spacing: SailStyleValues.padding08,
                  children: [
                    _LinkRow(
                      label: 'Mainchain block',
                      value: block.mainchainHeight != 0 ? '${block.mainchainHeight}' : shortenId(block.mainchainHash),
                      onTap: () async => launchUrl(
                        Uri.parse(
                          mempoolBlockUrl(
                            block.mainchainHash,
                            GetIt.I.get<BitcoinConfProvider>().network,
                          ),
                        ),
                      ),
                    ),
                    if (block.prevHash.isNotEmpty)
                      _LinkRow(
                        label: 'Previous block',
                        value: shortenId(block.prevHash),
                        onTap: () async => onOpen(ExplorerTarget.block(hash: block.prevHash)),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
        _ActivityTable(
          title: 'Transactions',
          subtitle: '${response.activity.length} in this block',
          rows: response.activity,
          onOpen: onOpen,
        ),
      ],
    );
  }
}

class _TransactionView extends StatelessWidget {
  final pb.Transaction transaction;
  final void Function(ExplorerTarget) onOpen;

  const _TransactionView({required this.transaction, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return SailColumn(
      spacing: SailStyleValues.padding16,
      children: [
        _Header(
          title: 'Transaction',
          id: transaction.txid,
          trailing: transaction.confirmed
              ? SailBadge('Block ${transaction.blockHeight}')
              : const SailBadge('Unconfirmed', tone: SailBadgeTone.warning),
        ),
        SailCard(
          title: 'Details',
          child: SailRow(
            spacing: SailStyleValues.padding16,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SailColumn(
                  spacing: SailStyleValues.padding08,
                  children: [
                    _Row(label: 'Kind', value: kindLabel(transaction.kind)),
                    _Row(label: 'Size', value: '${transaction.sizeBytes} bytes'),
                  ],
                ),
              ),
              Expanded(
                child: SailColumn(
                  spacing: SailStyleValues.padding08,
                  children: [
                    _Row(label: 'Fee', value: explorerAmount(context, transaction.feeSats.toInt())),
                    _Row(
                      label: 'Total value',
                      value: explorerAmount(
                        context,
                        transaction.outputs.fold<int>(0, (sum, o) => sum + o.valueSats.toInt()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SailCard(
          title: 'Inputs and outputs',
          subtitle: '${transaction.inputs.length} in · ${transaction.outputs.length} out',
          child: SailRow(
            spacing: SailStyleValues.padding16,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _CoinList(coins: transaction.inputs, onOpen: onOpen),
              ),
              Expanded(
                child: _CoinList(coins: transaction.outputs, onOpen: onOpen),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CoinList extends StatelessWidget {
  final List<pb.Coin> coins;
  final void Function(ExplorerTarget) onOpen;

  const _CoinList({required this.coins, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final colors = SailTheme.of(context).colors;
    return SailColumn(
      spacing: SailStyleValues.padding08,
      children: [
        for (final coin in coins)
          SailTappable(
            onTap: coin.address.isEmpty ? null : () async => onOpen(ExplorerTarget.address(coin.address)),
            child: Container(
              padding: const EdgeInsets.all(SailStyleValues.padding08),
              decoration: BoxDecoration(
                color: colors.backgroundSecondary,
                borderRadius: BorderRadius.circular(6),
                border: coin.mainAddress.isEmpty ? null : Border(left: BorderSide(color: colors.orange, width: 3)),
              ),
              child: SailColumn(
                spacing: 2,
                children: [
                  SailRow(
                    spacing: SailStyleValues.padding08,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(child: SailText.primary13(shortenId(coin.address), color: colors.info)),
                      SailText.primary13(explorerAmount(context, coin.valueSats.toInt())),
                    ],
                  ),
                  if (coin.mainAddress.isNotEmpty)
                    SailText.secondary12(
                      'Withdrawal to ${shortenId(coin.mainAddress)} · '
                      'mainchain fee ${explorerAmount(context, coin.mainFeeSats.toInt())}',
                    )
                  else if (coin.outpointKind == 'deposit')
                    SailText.secondary12('Deposit ${shortenId(coin.txid)}'),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _AddressView extends StatelessWidget {
  final pb.GetAddressResponse response;
  final void Function(ExplorerTarget) onOpen;

  const _AddressView({required this.response, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return SailColumn(
      spacing: SailStyleValues.padding16,
      children: [
        _Header(title: 'Address', id: response.address),
        SailCard(
          title: 'Summary',
          subtitle: '${response.confirmedBalanceSats} sats confirmed, over ${response.confirmedCoinCount} coins',
          child: SailRow(
            spacing: SailStyleValues.padding16,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SailColumn(
                  spacing: SailStyleValues.padding08,
                  children: [
                    _Row(label: 'Total received', value: explorerAmount(context, response.totalReceivedSats.toInt())),
                    _Row(label: 'Unconfirmed', value: explorerAmount(context, response.unconfirmedBalanceSats.toInt())),
                  ],
                ),
              ),
              Expanded(
                child: SailColumn(
                  spacing: SailStyleValues.padding08,
                  children: [
                    _Row(label: 'Unconfirmed coins', value: '${response.unconfirmedCoinCount}'),
                    _Row(label: 'Transactions', value: '${response.txCount}'),
                  ],
                ),
              ),
            ],
          ),
        ),
        for (final tx in response.transactions) _AddressTransaction(transaction: tx, onOpen: onOpen),
      ],
    );
  }
}

/// _AddressTransaction marks a deposit or a withdrawal with a coloured accent,
/// so a reader scanning an address sees money arriving or leaving at a glance.
class _AddressTransaction extends StatelessWidget {
  final pb.Transaction transaction;
  final void Function(ExplorerTarget) onOpen;

  const _AddressTransaction({required this.transaction, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final colors = SailTheme.of(context).colors;
    final accent = switch (transaction.kind) {
      pb.Kind.KIND_DEPOSIT => colors.success,
      pb.Kind.KIND_WITHDRAWAL => colors.orange,
      _ => colors.divider,
    };
    final deposit = transaction.kind == pb.Kind.KIND_DEPOSIT;
    return SailTappable(
      onTap: deposit ? null : () async => onOpen(ExplorerTarget.transaction(transaction.txid)),
      child: Container(
        padding: const EdgeInsets.all(SailStyleValues.padding12),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: accent, width: 3)),
        ),
        child: SailColumn(
          spacing: SailStyleValues.padding08,
          children: [
            SailRow(
              spacing: SailStyleValues.padding08,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: SailText.primary13(shortenId(transaction.txid), color: colors.info)),
                kindBadge(transaction.kind),
                SailText.secondary12(
                  transaction.confirmed ? 'Block ${transaction.blockHeight}' : 'Unconfirmed',
                ),
              ],
            ),
            SailText.secondary12(
              '${explorerAmount(context, transaction.feeSats.toInt())} fee · '
              '${transaction.inputs.length} in · ${transaction.outputs.length} out',
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTable extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<pb.Activity> rows;
  final void Function(ExplorerTarget) onOpen;

  const _ActivityTable({
    required this.title,
    required this.subtitle,
    required this.rows,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return SailCard(
      title: title,
      subtitle: subtitle,
      child: SizedBox(
        height: 240,
        child: SailTable(
          getRowId: (index) => rows[index].id,
          headerBuilder: (context) => const [
            SailTableHeaderCell(name: 'Transaction'),
            SailTableHeaderCell(name: 'Kind'),
            SailTableHeaderCell(name: 'Value'),
            SailTableHeaderCell(name: 'Fee'),
            SailTableHeaderCell(name: 'Size'),
          ],
          rowBuilder: (context, index, selected) {
            final row = rows[index];
            return [
              SailTableCell(value: shortenId(row.id), monospace: true),
              SailTableCell(value: '', child: kindBadge(row.kind)),
              SailTableCell(value: explorerAmount(context, row.valueSats.toInt())),
              SailTableCell(value: explorerAmount(context, row.feeSats.toInt())),
              SailTableCell(value: row.sizeBytes == 0 ? '—' : '${row.sizeBytes} bytes'),
            ];
          },
          rowCount: rows.length,
          onDoubleTap: (rowId) {
            final row = rows.firstWhere((r) => r.id == rowId);
            if (row.kind == pb.Kind.KIND_DEPOSIT) {
              return;
            }
            onOpen(ExplorerTarget.transaction(rowId));
          },
          emptyPlaceholder: 'Nothing in this block',
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String id;
  final Widget? trailing;

  const _Header({required this.title, required this.id, this.trailing});

  @override
  Widget build(BuildContext context) {
    return SailRow(
      spacing: SailStyleValues.padding12,
      children: [
        SailText.primary24(title, bold: true),
        Expanded(child: SailText.secondary13(id)),
        CopyButton(text: id),
        ?trailing,
      ],
    );
  }
}

/// _LinkRow is a field whose value opens something.
class _LinkRow extends StatelessWidget {
  final String label;
  final String value;
  final Future<void> Function() onTap;

  const _LinkRow({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = SailTheme.of(context).colors;
    return SailTappable(
      onTap: onTap,
      child: Container(
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
            Flexible(child: SailText.primary13(value, color: colors.info)),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row({required this.label, required this.value});

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
          Flexible(child: SailText.primary13(value)),
        ],
      ),
    );
  }
}

String kindLabel(pb.Kind kind) {
  return switch (kind) {
    pb.Kind.KIND_DEPOSIT => 'Deposit',
    pb.Kind.KIND_WITHDRAWAL => 'Withdrawal',
    _ => 'Transfer',
  };
}

String shortenId(String id) {
  if (id.length <= 20) {
    return id;
  }
  return '${id.substring(0, 8)}…${id.substring(id.length - 8)}';
}
