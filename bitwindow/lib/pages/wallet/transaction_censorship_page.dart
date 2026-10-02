import 'dart:async';

import 'package:bitwindow/pages/explorer/block_explorer_dialog.dart';
import 'package:bitwindow/providers/mempool_watch_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class TransactionCensorshipTab extends StatelessWidget {
  final SailWindow? newWindowButton;

  const TransactionCensorshipTab({super.key, required this.newWindowButton});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<TransactionCensorshipViewModel>.reactive(
      viewModelBuilder: () => TransactionCensorshipViewModel(),
      builder: (context, model, child) {
        final provider = model.provider;
        return SailCard(
          title: 'Transaction Censorship',
          subtitle: 'Mempool transactions and how long they have waited to be mined.',
          error: provider.error,
          bottomPadding: false,
          newWindow: newWindowButton,
          child: model.isLight
              ? SailText.secondary13('Transaction Censorship needs a full node.')
              : SailColumn(
                  spacing: SailStyleValues.padding16,
                  children: [
                    _Header(model: model),
                    if (provider.alarm) _AlarmBanner(count: provider.alarmCount),
                    if (provider.truncated)
                      SailText.secondary13('Showing the first $maxPendingRows of ${provider.total} candidates'),
                    Expanded(child: _Table(model: model)),
                  ],
                ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final TransactionCensorshipViewModel model;

  const _Header({required this.model});

  @override
  Widget build(BuildContext context) {
    final provider = model.provider;
    final status = provider.status;
    final pending = provider.tab == MempoolWatchTab.pending;

    return SailColumn(
      spacing: SailStyleValues.padding08,
      children: [
        SailRow(
          spacing: SailStyleValues.padding16,
          children: [
            SailButton(
              label: status.enabled ? 'Stop watching' : 'Start watching',
              variant: status.enabled ? ButtonVariant.secondary : ButtonVariant.primary,
              onPressed: model.toggle,
            ),
            Expanded(child: SailText.secondary13(model.statusText)),
            SizedBox(
              width: 280,
              child: SailTextField(
                controller: model.searchController,
                hintText: 'Search txid',
                onChanged: (_) => model.onSearchChanged(),
              ),
            ),
          ],
        ),
        SailRow(
          spacing: SailStyleValues.padding16,
          children: [
            _Segmented(
              value: provider.tab,
              onChanged: provider.setTab,
              labels: const {MempoolWatchTab.pending: 'Pending', MempoolWatchTab.history: 'History'},
            ),
            if (pending) ...[
              SizedBox(
                width: 160,
                child: SailTextField(
                  controller: model.scoreController,
                  label: 'Score above',
                  hintText: '0',
                  textFieldType: TextFieldType.number,
                  enabled: !provider.showAll,
                  onChanged: (_) => model.onThresholdChanged(),
                ),
              ),
              SailRow(
                spacing: SailStyleValues.padding08,
                children: [
                  SailSwitch(value: provider.showAll, onChanged: provider.setShowAll),
                  SailText.secondary13('Show all'),
                ],
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _AlarmBanner extends StatelessWidget {
  final int count;

  const _AlarmBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(SailStyleValues.padding12),
      decoration: BoxDecoration(
        color: theme.colors.error.withValues(alpha: 0.1),
        borderRadius: SailStyleValues.borderRadius,
        border: Border.all(color: theme.colors.error.withValues(alpha: 0.3)),
      ),
      child: SailRow(
        spacing: SailStyleValues.padding08,
        children: [
          SailSVG.fromAsset(SailSVGAsset.triangleAlert, width: 18, color: theme.colors.error),
          SailText.primary13(
            'Censorship alarm: $count pending ${count == 1 ? 'transaction scores' : 'transactions score'} above ${alarmScore.toInt()}',
            color: theme.colors.error,
          ),
        ],
      ),
    );
  }
}

class _Segmented<T> extends StatelessWidget {
  final T value;
  final Map<T, String> labels;
  final ValueChanged<T> onChanged;

  const _Segmented({required this.value, required this.labels, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
      decoration: BoxDecoration(color: theme.colors.backgroundSecondary, borderRadius: theme.chrome.radius),
      child: SailRow(
        children: [
          for (final entry in labels.entries)
            SailTabItem(
              label: entry.value,
              isSelected: entry.key == value,
              onTap: () => onChanged(entry.key),
            ),
        ],
      ),
    );
  }
}

const _columns = <MempoolWatchSort?>[
  null,
  MempoolWatchSort.feeRate,
  MempoolWatchSort.fee,
  MempoolWatchSort.vsize,
  MempoolWatchSort.firstSeen,
  MempoolWatchSort.blocksWaited,
  MempoolWatchSort.blocksEligible,
  MempoolWatchSort.score,
  MempoolWatchSort.timeWaited,
  null,
];

const _columnNames = [
  'Txid',
  'Fee rate',
  'Fee',
  'vSize',
  'First seen',
  'Blocks waited',
  'Blocks eligible',
  'Score',
  'Time waited',
  'Status',
];

class _Table extends StatelessWidget {
  final TransactionCensorshipViewModel model;

  const _Table({required this.model});

  @override
  Widget build(BuildContext context) {
    final provider = model.provider;
    final formatter = GetIt.I<FormatterProvider>();
    final theme = SailTheme.of(context);
    final rows = provider.rows;

    return ListenableBuilder(
      listenable: formatter,
      builder: (context, child) => SailTable(
        getRowId: (index) => rows[index].txid,
        headerBuilder: (context) => [
          for (var i = 0; i < _columns.length; i++)
            SailTableHeaderCell(
              name: _columnNames[i],
              sortable: _columns[i] != null,
              onSort: _columns[i] == null ? null : () => model.onSort(i),
            ),
        ],
        cellHeight: 36.0,
        rowBackgroundColor: (index) => provider.alarmed(rows[index]) ? theme.colors.error.withValues(alpha: 0.1) : null,
        rowBuilder: (context, row, selected) {
          final tx = rows[row];
          final score = provider.score(tx);
          return [
            SailTableCell(value: '${tx.txid.substring(0, 10)}…', copyValue: tx.txid, monospace: true),
            SailTableCell(value: tx.hasDetails ? tx.feeRate.toStringAsFixed(1) : '…', monospace: true),
            SailTableCell(value: tx.hasDetails ? formatter.formatSats(tx.feeSats.toInt()) : '…', monospace: true),
            SailTableCell(value: tx.hasDetails ? tx.vsize.toString() : '…', monospace: true),
            SailTableCell(value: formatDate(tx.firstSeen.toDateTime())),
            SailTableCell(value: provider.waited(tx).toString(), monospace: true),
            SailTableCell(value: provider.eligible(tx).toString(), monospace: true),
            SailTableCell(
              value: score?.toStringAsFixed(1) ?? '…',
              monospace: true,
              textColor: provider.alarmed(tx) ? theme.colors.error : null,
            ),
            SailTableCell(value: formatWait(tx), monospace: true),
            SailTableCell(value: statusLabel(tx.status)),
          ];
        },
        rowCount: rows.length,
        emptyPlaceholder: emptyPlaceholder(provider),
        drawGrid: true,
        sortColumnIndex: _columns.indexOf(provider.sortBy),
        sortAscending: !provider.sortDescending,
        onSort: (columnIndex, _) => model.onSort(columnIndex),
        onDoubleTap: (rowId) => showTransactionDetails(context, rowId),
        onScrollApproachingEnd: provider.loadMore,
      ),
    );
  }
}

String emptyPlaceholder(MempoolWatchProvider provider) {
  if (!provider.status.enabled) {
    return 'Start watching to record the mempool';
  }
  if (provider.tab == MempoolWatchTab.pending && !provider.showAll) {
    return "No pending transaction is paying above the last block's average fee rate";
  }
  return 'No transactions match';
}

String statusLabel(MempoolTxStatus status) => switch (status) {
  MempoolTxStatus.MEMPOOL_TX_STATUS_PENDING => 'Pending',
  MempoolTxStatus.MEMPOOL_TX_STATUS_MINED => 'Mined',
  MempoolTxStatus.MEMPOOL_TX_STATUS_REMOVED => 'Removed',
  _ => '-',
};

String formatWait(MempoolTransaction tx) {
  final d = waitedFor(tx, DateTime.now());
  if (d.inMinutes < 1) {
    return '${d.inSeconds}s';
  }
  if (d.inHours < 1) {
    return '${d.inMinutes}m';
  }
  if (d.inDays < 1) {
    return '${d.inHours}h ${d.inMinutes % 60}m';
  }
  return '${d.inDays}d ${d.inHours % 24}h';
}

class TransactionCensorshipViewModel extends BaseViewModel {
  final MempoolWatchProvider provider = GetIt.I.get<MempoolWatchProvider>();
  late final TextEditingController scoreController = TextEditingController(text: provider.minScore.toString());
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;
  Timer? _searchDebounce;

  TransactionCensorshipViewModel() {
    provider.addListener(notifyListeners);
  }

  bool get isLight => GetIt.I.isRegistered<NodeModeProvider>() && GetIt.I<NodeModeProvider>().isLight;

  String get statusText {
    final s = provider.status;
    if (!s.enabled) {
      return 'Not watching';
    }
    if (s.error.isNotEmpty) {
      return 'Error: ${s.error}';
    }
    if (!s.running) {
      return 'Starting…';
    }
    final fstar = provider.referenceFeeRate;
    final reference = fstar == null ? 'F* pending' : 'F* ${fstar.toStringAsFixed(2)} sat/vB';
    return 'Watching at height ${s.tipHeight} · $reference · ${s.pendingCount} pending · ${s.minedCount} mined · ${s.removedCount} removed';
  }

  Future<void> toggle() => provider.setEnabled(!provider.status.enabled);

  void onThresholdChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final score = double.tryParse(scoreController.text);
      if (score != null && score != provider.minScore) {
        provider.setMinScore(score);
      }
    });
  }

  void onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (searchController.text.trim() != provider.txidSearch) {
        provider.setTxidSearch(searchController.text);
      }
    });
  }

  void onSort(int columnIndex) {
    final field = _columns[columnIndex];
    if (field == null) {
      return;
    }
    final descending = field == provider.sortBy ? !provider.sortDescending : true;
    provider.setSort(field, descending);
  }

  @override
  void dispose() {
    provider.removeListener(notifyListeners);
    _debounce?.cancel();
    _searchDebounce?.cancel();
    scoreController.dispose();
    searchController.dispose();
    super.dispose();
  }
}
