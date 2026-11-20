import 'package:bitwindow/pages/explorer/block_explorer_dialog.dart';
import 'package:bitwindow/pages/wallet/denial_dialog.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart';
import 'package:sail_ui/sail_ui.dart' hide DetailRow;

/// True when the denial schedule still has a future execution to run. The
/// proto sets `nextExecutionTime` to the epoch-zero default when the schedule
/// is exhausted, so we treat that as "no scheduled next execution" rather
/// than rendering it as a 1969 timestamp.
bool denialHasScheduledNextExecution(DenialInfo info) {
  if (!info.hasNextExecutionTime()) {
    return false;
  }
  return info.nextExecutionTime.toDateTime().millisecondsSinceEpoch != 0;
}

class DeniabilityTab extends StatelessWidget {
  final SailWindow? newWindowButton;

  const DeniabilityTab({
    super.key,
    required this.newWindowButton,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return ViewModelBuilder<DeniabilityViewModel>.reactive(
          viewModelBuilder: () => DeniabilityViewModel(),
          onViewModelReady: (model) => WidgetsBinding.instance.addPostFrameCallback((_) => model.postInit()),
          builder: (context, model, child) {
            final error = model.error('deniability');
            final phone = SailStyleValues.phoneLayout(context);

            return SailColumn(
              spacing: SailStyleValues.padding16,
              children: [
                if (!phone)
                  DenyAllButton(
                    onPressed: () => model.showDenyAllDialog(context),
                    utxoCount: model.utxosWithoutDenial.length,
                  ),
                Expanded(
                  child: DeniabilityTable(
                    newWindowButton: newWindowButton,
                    error: error,
                    utxos: model.utxos,
                    model: model,
                    onDenyAll: phone ? () => model.showDenyAllDialog(context) : null,
                    denyAllCount: model.utxosWithoutDenial.length,
                    onDeny: (output, valueSats) => model.showDenyDialog(context, output, valueSats),
                    onCancel: model.cancelDenial,
                    onPause: model.pauseDenial,
                    onResume: model.resumeDenial,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class DenyAllButton extends StatelessWidget {
  final VoidCallback onPressed;
  final int utxoCount;

  const DenyAllButton({
    super.key,
    required this.onPressed,
    required this.utxoCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailTappable(
      onTap: utxoCount > 0 ? () async => onPressed() : null,
      borderRadius: context.sailTheme.chrome.radius,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          borderRadius: context.sailTheme.chrome.radius,
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              theme.colors.orange.withValues(alpha: utxoCount > 0 ? 0.25 : 0.1),
              theme.colors.orangeLight.withValues(alpha: utxoCount > 0 ? 0.25 : 0.1),
            ],
          ),
          border: Border.all(
            color: utxoCount > 0 ? theme.colors.orange : theme.colors.divider,
            width: 1.0,
          ),
        ),
        child: Column(
          children: [
            SailRow(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: SailStyleValues.padding08,
              children: [
                SailSVG.icon(
                  SailSVGAsset.iconSend,
                  color: utxoCount > 0 ? theme.colors.text : theme.colors.textTertiary,
                  height: 24,
                ),
                SailText.primary24(
                  'Deny All',
                  bold: true,
                  color: utxoCount > 0 ? null : theme.colors.textTertiary,
                ),
              ],
            ),
            SailText.secondary13(
              utxoCount > 0
                  ? 'Click here to start deniability on all $utxoCount UTXOs'
                  : 'All UTXOs already have active deniability',
              color: theme.colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class DeniabilityTable extends StatefulWidget {
  final SailWindow? newWindowButton;
  final String? error;
  final List<UnspentOutput> utxos;
  final void Function(String output, int valueSats) onDeny;
  final void Function(Int64) onCancel;
  final void Function(Int64) onPause;
  final void Function(Int64) onResume;
  final DeniabilityViewModel model;

  /// Shows a small Deny All button in the card head. The phone layout uses it in place of [DenyAllButton].
  final VoidCallback? onDenyAll;
  final int denyAllCount;

  const DeniabilityTable({
    super.key,
    required this.error,
    required this.utxos,
    required this.model,
    required this.onDeny,
    required this.onCancel,
    required this.onPause,
    required this.onResume,
    required this.newWindowButton,
    this.onDenyAll,
    this.denyAllCount = 0,
  });

  @override
  State<DeniabilityTable> createState() => _DeniabilityTableState();
}

class _DeniabilityTableState extends State<DeniabilityTable> {
  static const _sortColumns = ['id', 'hops', 'txid', 'amount', 'next', 'status', 'timestamp'];

  String sortColumn = 'txid';
  bool sortAscending = true;

  String _rowId(UnspentOutput utxo) => '${utxo.output}:${utxo.denialInfo.executions.length}';

  List<UnspentOutput> get _sortedUtxos {
    final utxos = [...widget.utxos];
    utxos.sort((a, b) => sortAscending ? _compare(a, b) : _compare(b, a));
    return utxos;
  }

  @override
  Widget build(BuildContext context) {
    final formatter = GetIt.I<FormatterProvider>();
    final utxos = _sortedUtxos;

    return SailCard(
      title: 'Your UTXOs with denial info',
      subtitle: 'List of your UTXOs with information about their deniability status.',
      error: widget.error,
      bottomPadding: false,
      newWindow: widget.newWindowButton,
      widgetHeaderEnd: widget.onDenyAll == null
          ? null
          : SailButton(
              label: 'Deny All',
              small: true,
              disabled: widget.denyAllCount == 0,
              onPressed: () async => widget.onDenyAll!(),
            ),
      child: Column(
        children: [
          SailSpacing(SailStyleValues.padding16),
          Expanded(
            child: ListenableBuilder(
              listenable: formatter,
              builder: (context, child) => SailStyleValues.phoneLayout(context)
                  ? _PhoneDenialList(
                      utxos: utxos,
                      onDeny: widget.onDeny,
                      onCancel: widget.onCancel,
                      onPause: widget.onPause,
                      onResume: widget.onResume,
                    )
                  : SailTable(
                      getRowId: (index) => utxos.isEmpty ? '0' : _rowId(utxos[index]),
                      headerBuilder: (context) => [
                        const SailTableHeaderCell(name: 'Denial ID'),
                        const SailTableHeaderCell(name: 'Hops'),
                        const SailTableHeaderCell(name: 'UTXO'),
                        const SailTableHeaderCell(name: 'Amount'),
                        const SailTableHeaderCell(name: 'Next Execution'),
                        const SailTableHeaderCell(name: 'Status'),
                        const SailTableHeaderCell(name: 'Timestamp'),
                        const SailTableHeaderCell(name: 'Actions', sortable: false),
                      ],
                      cellHeight: 36.0,
                      rowBuilder: (context, row, selected) {
                        final utxo = utxos[row];
                        final hasDenialInfo = utxo.hasDenialInfo();

                        String status = '-';
                        String nextExecution = '-';
                        String hops = '0';
                        bool canControl = false;
                        bool isPaused = false;
                        bool isTip = false;

                        if (hasDenialInfo) {
                          final completedHops = utxo.denialInfo.hopsCompleted;
                          final totalHops = utxo.denialInfo.numHops;
                          hops = '$completedHops/$totalHops';
                          final hasNext = denialHasScheduledNextExecution(utxo.denialInfo);
                          if (!hasNext) {
                            hops = '$completedHops';
                          }

                          isPaused = utxo.denialInfo.hasPausedAt();
                          isTip = !utxo.denialInfo.isChange;

                          status = utxo.denialInfo.hasCancelTime()
                              ? 'Cancelled'
                              : isPaused
                              ? 'Paused'
                              : !hasNext
                              ? 'Completed'
                              : 'Ongoing';
                          nextExecution = hasNext
                              ? utxo.denialInfo.nextExecutionTime.toDateTime().toLocal().toString()
                              : '-';
                          // Only the tip can be controlled (paused/resumed/cancelled)
                          canControl = isTip && (status == 'Ongoing' || status == 'Paused');

                          if (status == 'Cancelled') {
                            hops = '$completedHops';
                          }
                        }

                        return [
                          SailTableCell(
                            value: '${utxo.denialInfo.id == 0 ? '-' : utxo.denialInfo.id}',
                            copyValue: utxo.denialInfo.id.toString(),
                          ),
                          SailTableCell(
                            value: hops,
                          ),
                          SailTableCell(
                            value: '${utxo.output.substring(0, 6)}..:${utxo.output.split(':').last}',
                            copyValue: utxo.output,
                          ),
                          SailTableCell(
                            value: formatter.formatSats(utxo.valueSats.toInt()),
                            monospace: true,
                          ),
                          SailTableCell(
                            value: nextExecution,
                          ),
                          SailTooltip(
                            message: utxo.denialInfo.cancelReason,
                            child: SailTableCell(
                              value: status,
                            ),
                          ),
                          SailTableCell(
                            value: utxo.hasReceivedAt() ? formatDate(utxo.receivedAt.toDateTime()) : '—',
                          ),
                          SailTableCell(
                            value: canControl ? (isPaused ? 'Resume' : 'Pause') : 'Deny',
                            width: 160,
                            child: canControl
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SailButton(
                                        label: isPaused ? 'Resume' : 'Pause',
                                        onPressed: () async => isPaused
                                            ? widget.onResume(utxo.denialInfo.id)
                                            : widget.onPause(utxo.denialInfo.id),
                                        insideTable: true,
                                      ),
                                      const SizedBox(width: 4),
                                      SailButton(
                                        label: 'Cancel',
                                        onPressed: () async => widget.onCancel(utxo.denialInfo.id),
                                        insideTable: true,
                                        variant: ButtonVariant.secondary,
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SailButton(
                                        label: 'Deny',
                                        onPressed: () async => widget.onDeny(utxo.output, utxo.valueSats.toInt()),
                                        insideTable: true,
                                      ),
                                      const SizedBox(width: 4),
                                      Opacity(
                                        opacity: 0.0,
                                        child: IgnorePointer(
                                          child: SailButton(
                                            label: 'Cancel',
                                            onPressed: () async {},
                                            insideTable: true,
                                            variant: ButtonVariant.secondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ];
                      },
                      rowCount: utxos.length,
                      emptyPlaceholder: 'No UTXOs available',
                      drawGrid: true,
                      sortColumnIndex: _sortColumns.indexOf(sortColumn),
                      sortAscending: sortAscending,
                      onSort: (columnIndex, ascending) => setState(() {
                        sortColumn = _sortColumns[columnIndex];
                        sortAscending = ascending;
                      }),
                      onDoubleTap: (rowId) {
                        if (utxos.isEmpty) {
                          return;
                        }
                        final utxo = utxos.firstWhere((u) => _rowId(u) == rowId);
                        _showUtxoDetails(context, utxo);
                      },
                    ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  int _compare(UnspentOutput a, UnspentOutput b) {
    switch (sortColumn) {
      case 'id':
        return a.denialInfo.id.compareTo(b.denialInfo.id);
      case 'hops':
        return _missingLast(a.hasDenialInfo(), b.hasDenialInfo()) ??
            a.denialInfo.executions.length.compareTo(b.denialInfo.executions.length);
      case 'txid':
        return a.output.compareTo(b.output);
      case 'amount':
        return a.valueSats.compareTo(b.valueSats);
      case 'next':
        return _missingLast(a.hasDenialInfo(), b.hasDenialInfo()) ??
            _missingLast(a.denialInfo.hasNextExecutionTime(), b.denialInfo.hasNextExecutionTime()) ??
            a.denialInfo.nextExecutionTime.toDateTime().compareTo(b.denialInfo.nextExecutionTime.toDateTime());
      case 'status':
        return _missingLast(a.hasDenialInfo(), b.hasDenialInfo()) ??
            _statusKey(a.denialInfo).compareTo(_statusKey(b.denialInfo));
      case 'timestamp':
        return _missingLast(a.hasReceivedAt(), b.hasReceivedAt()) ??
            a.receivedAt.toDateTime().compareTo(b.receivedAt.toDateTime());
      default:
        return 0;
    }
  }

  /// Null when both values exist; otherwise puts the missing one last.
  int? _missingLast(bool aHas, bool bHas) {
    if (aHas && bHas) {
      return null;
    }
    if (aHas == bHas) {
      return 0;
    }
    return aHas ? -1 : 1;
  }

  String _statusKey(DenialInfo info) {
    if (info.hasCancelTime()) {
      return 'Cancelled';
    }
    if (info.hasPausedAt()) {
      return 'Paused';
    }
    return denialHasScheduledNextExecution(info) ? 'Ongoing' : 'Completed';
  }

  void _showUtxoDetails(BuildContext context, UnspentOutput utxo) {
    final formatter = GetIt.I<FormatterProvider>();

    showThemedDialog(
      context: context,
      builder: (context) => SailModal(
        constraints: const BoxConstraints(maxWidth: 800),
        child: SailCard(
          title: 'UTXO Details',
          subtitle: 'UTXO and Deniability Information',
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DetailRow(label: 'TxID', value: utxo.output.split(':').first),
                DetailRow(label: 'Output Index', value: utxo.output.split(':').last),
                DetailRow(label: 'Amount', value: formatter.formatSats(utxo.valueSats.toInt())),
                if (utxo.hasDenialInfo()) ...[
                  const SailSpacing(SailStyleValues.padding16),
                  BorderedSection(
                    title: 'Deniability Info',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DetailRow(label: 'Status', value: _getDeniabilityStatus(utxo)),
                        DetailRow(label: 'Completed Hops', value: '${utxo.denialInfo.executions.length}'),
                        DetailRow(label: 'Total Hops', value: '${utxo.denialInfo.numHops}'),
                        if (denialHasScheduledNextExecution(utxo.denialInfo))
                          DetailRow(
                            label: 'Next Execution',
                            value: formatDate(utxo.denialInfo.nextExecutionTime.toDateTime()),
                          ),
                        if (utxo.denialInfo.hasCancelTime())
                          DetailRow(
                            label: 'Cancel Reason',
                            value: utxo.denialInfo.cancelReason,
                          ),
                      ],
                    ),
                  ),
                  if (utxo.denialInfo.executions.isNotEmpty) ...[
                    const SailSpacing(SailStyleValues.padding16),
                    SailText.primary13('Deniability Transactions:'),
                    const SailSpacing(SailStyleValues.padding08),
                    SizedBox(
                      height: 300,
                      child: SelectionContainer.disabled(
                        child: TXIDTransactionTable(
                          transactions: utxo.denialInfo.executions
                              .map((e) => e.fromTxid)
                              .where((txid) => txid.isNotEmpty)
                              .toList(),
                          onTransactionSelected: (txid) => _showTransactionDetails(context, txid),
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTransactionDetails(BuildContext context, String txid) {
    showThemedDialog(
      context: context,
      builder: (context) => TransactionDetailsDialog(
        txid: txid,
      ),
    );
  }

  String _getDeniabilityStatus(UnspentOutput utxo) {
    if (!utxo.hasDenialInfo()) {
      return 'No deniability';
    }
    if (utxo.denialInfo.hasCancelTime()) {
      return 'Cancelled';
    }
    if (utxo.denialInfo.hasPausedAt()) {
      return 'Paused';
    }

    final completedHops = utxo.denialInfo.executions.length;
    final totalHops = utxo.denialInfo.numHops;

    if (!denialHasScheduledNextExecution(utxo.denialInfo)) {
      return 'Completed';
    }
    return 'Ongoing ($completedHops/$totalHops hops)';
  }
}

class _PhoneDenialList extends StatelessWidget {
  final List<UnspentOutput> utxos;
  final void Function(String output, int valueSats) onDeny;
  final void Function(Int64) onCancel;
  final void Function(Int64) onPause;
  final void Function(Int64) onResume;

  const _PhoneDenialList({
    required this.utxos,
    required this.onDeny,
    required this.onCancel,
    required this.onPause,
    required this.onResume,
  });

  @override
  Widget build(BuildContext context) {
    if (utxos.isEmpty) {
      return Center(child: SailText.secondary13('No UTXOs available'));
    }
    final formatter = GetIt.I<FormatterProvider>();
    return SailDividedList(
      itemCount: utxos.length,
      itemBuilder: (context, index) {
        final utxo = utxos[index];
        final info = utxo.denialInfo;
        final isPaused = utxo.hasDenialInfo() && info.hasPausedAt();
        final canControl =
            utxo.hasDenialInfo() &&
            !info.isChange &&
            !info.hasCancelTime() &&
            (isPaused || denialHasScheduledNextExecution(info));
        return SailListRow(
          title: formatter.formatSats(utxo.valueSats.toInt()),
          subtitle: 'Denial ID ${info.id == 0 ? '-' : info.id}',
          trailing: canControl
              ? SailRow(
                  spacing: SailStyleValues.padding04,
                  children: [
                    SailButton(
                      label: isPaused ? 'Resume' : 'Pause',
                      onPressed: () async => isPaused ? onResume(info.id) : onPause(info.id),
                      insideTable: true,
                      variant: ButtonVariant.outline,
                    ),
                    SailButton(
                      label: 'Cancel',
                      onPressed: () async => onCancel(info.id),
                      insideTable: true,
                      variant: ButtonVariant.outline,
                    ),
                  ],
                )
              : SailButton(
                  label: 'Deny',
                  onPressed: () async => onDeny(utxo.output, utxo.valueSats.toInt()),
                  insideTable: true,
                  variant: ButtonVariant.outline,
                ),
        );
      },
    );
  }
}

class DeniabilityViewModel extends BaseViewModel {
  final BitwindowRPC api = GetIt.I.get<BitwindowRPC>();
  final TransactionProvider transactionProvider = GetIt.I.get<TransactionProvider>();

  List<UnspentOutput> get utxos => transactionProvider.utxos;

  List<UnspentOutput> get utxosWithoutDenial => utxos.where((u) {
    if (!u.hasDenialInfo()) {
      return true;
    }
    // Has denial info but it's cancelled or completed
    if (u.denialInfo.hasCancelTime()) {
      return true;
    }
    if (!denialHasScheduledNextExecution(u.denialInfo)) {
      return true;
    }
    return false;
  }).toList();

  DeniabilityViewModel() {
    transactionProvider.addListener(notifyListeners);
    transactionProvider.addListener(errorListener);
  }

  @override
  void dispose() {
    transactionProvider.removeListener(notifyListeners);
    transactionProvider.removeListener(errorListener);
    super.dispose();
  }

  void init() {
    // Set busy state to show loading indicator
    setBusy(true);
  }

  // Post-frame initialization for async operations
  Future<void> postInit() async {
    await transactionProvider.fetch();
  }

  void errorListener() {
    setErrorForObject('deniability', transactionProvider.error);
  }

  void showDenyDialog(BuildContext context, String output, int valueSats) {
    showThemedDialog(
      context: context,
      builder: (context) => DenialDialog(output: output, valueSats: valueSats),
    );
  }

  void showDenyAllDialog(BuildContext context) {
    showThemedDialog(
      context: context,
      builder: (context) => DenialDialog(utxos: utxosWithoutDenial),
    );
  }

  void cancelDenial(Int64 id) async {
    try {
      await api.bitwindowd.cancelDenial(id);
      await transactionProvider.fetch();
    } catch (e) {
      setError(e.toString());
    }
  }

  void pauseDenial(Int64 id) async {
    try {
      await api.bitwindowd.pauseDenial(id);
      await transactionProvider.fetch();
    } catch (e) {
      setError(e.toString());
    }
  }

  void resumeDenial(Int64 id) async {
    try {
      await api.bitwindowd.resumeDenial(id);
      await transactionProvider.fetch();
    } catch (e) {
      setError(e.toString());
    }
  }
}
