import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class BMMTab extends StatelessWidget {
  const BMMTab({super.key});

  /// Get the status color based on attempt status
  Color? _getStatusColor(BmmResult attempt, SailColor colors) {
    if (attempt.raw.isEmpty) {
      // Trying...
      return colors.orange.withValues(alpha: 0.3);
    } else if (attempt.error != null) {
      // Error/Failed
      return colors.error.withValues(alpha: 0.3);
    } else {
      // Success
      return colors.success.withValues(alpha: 0.3);
    }
  }

  /// Get the status text color based on attempt status
  Color _getStatusTextColor(BmmResult attempt, SailColor colors) {
    if (attempt.raw.isEmpty) {
      return colors.orange;
    } else if (attempt.error != null) {
      return colors.error;
    } else {
      return colors.success;
    }
  }

  /// Show Manual BMM Dialog for advanced control
  void _showManualBMMDialog(BuildContext context, BMMViewModel viewModel) {
    final theme = SailTheme.of(context);
    showThemedDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: SailText.primary15('Manual BMM Control'),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: SailColumn(
                spacing: SailStyleValues.padding16,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Last Attempt Details
                  if (viewModel.attempts.isNotEmpty) ...[
                    SailText.primary13('Last Attempt Details', bold: true),
                    Container(
                      padding: const EdgeInsets.all(SailStyleValues.padding12),
                      decoration: BoxDecoration(
                        color: _getStatusColor(viewModel.attempts.first, theme.colors),
                        borderRadius: SailStyleValues.borderRadiusSmall,
                        border: Border.all(color: theme.colors.border),
                      ),
                      child: SailColumn(
                        spacing: SailStyleValues.padding08,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _CopyableField(
                            label: 'Status',
                            value: viewModel.attempts.first.status,
                          ),
                          _CopyableField(
                            label: 'MC Transaction ID',
                            value: viewModel.attempts.first.txid.isEmpty ? 'Pending...' : viewModel.attempts.first.txid,
                          ),
                          _CopyableField(
                            label: 'MC Block Hash',
                            value: viewModel.attempts.first.hashLastMainBlock.isEmpty
                                ? 'Unknown'
                                : viewModel.attempts.first.hashLastMainBlock,
                          ),
                          if (viewModel.attempts.first.bmmBlockCreated != null)
                            _CopyableField(
                              label: 'BMM Block Created (h*)',
                              value: viewModel.attempts.first.bmmBlockCreated!,
                            ),
                          if (viewModel.attempts.first.bmmBlockSubmitted != null)
                            _CopyableField(
                              label: 'BMM Block Submitted',
                              value: viewModel.attempts.first.bmmBlockSubmitted!,
                            ),
                          if (viewModel.attempts.first.bmmBlockSubmittedBlind != null)
                            _CopyableField(
                              label: 'BMM Block Submitted (Blind)',
                              value: viewModel.attempts.first.bmmBlockSubmittedBlind!,
                            ),
                          _CopyableField(
                            label: 'Transactions',
                            value: viewModel.attempts.first.ntxn.toString(),
                          ),
                          _CopyableField(
                            label: 'Fees (sats)',
                            value: viewModel.attempts.first.nfees.toString(),
                          ),
                          if (viewModel.attempts.first.error != null)
                            _CopyableField(
                              label: 'Error',
                              value: viewModel.attempts.first.error!,
                              valueColor: theme.colors.error,
                            ),
                        ],
                      ),
                    ),
                  ] else
                    SailText.secondary13('No BMM attempts yet. Click "Mine Now" to create one.'),

                  Divider(color: theme.colors.divider),

                  // Manual Mining Controls
                  SailText.primary13('Manual Mining', bold: true),
                  SailRow(
                    spacing: SailStyleValues.padding08,
                    children: [
                      SailText.primary12('Bid Amount (BTC):'),
                      SizedBox(
                        width: 120,
                        child: SailTextField(
                          controller: viewModel.bidAmountController,
                          hintText: '0.0001',
                        ),
                      ),
                    ],
                  ),
                  SailButton(
                    label: 'Mine Single Block Now',
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await viewModel.bmmProvider.makeAttempt();
                    },
                  ),

                  Divider(color: theme.colors.divider),

                  // Raw Data (for debugging)
                  if (viewModel.attempts.isNotEmpty && viewModel.attempts.first.raw.isNotEmpty) ...[
                    SailText.primary13('Raw Response Data', bold: true),
                    Container(
                      padding: const EdgeInsets.all(SailStyleValues.padding08),
                      decoration: BoxDecoration(
                        color: theme.colors.backgroundSecondary,
                        borderRadius: SailStyleValues.borderRadiusSmall,
                      ),
                      child: SelectableText(
                        viewModel.attempts.first.raw,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: theme.colors.text,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            SailButton(
              label: 'Close',
              variant: ButtonVariant.secondary,
              onPressed: () async => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => BMMViewModel(),
      builder: (context, viewModel, child) {
        return SailCard(
          title: 'BMM',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailRow(
                spacing: SailStyleValues.padding04,
                children: [
                  SailButton(
                    label: 'Start',
                    disabled: viewModel.isMining,
                    onPressed: () async => viewModel.bmmProvider.startMining(),
                  ),
                  const SizedBox(width: 8),
                  SailButton(
                    label: 'Stop',
                    onPressed: () async => viewModel.bmmProvider.stopMining(),
                    disabled: !viewModel.isMining,
                    variant: ButtonVariant.secondary,
                  ),
                  const SizedBox(width: 8),
                  SailButton(
                    label: 'Mine Now',
                    onPressed: () async => viewModel.bmmProvider.makeAttempt(),
                    variant: ButtonVariant.secondary,
                  ),
                  const SizedBox(width: 8),
                  SailButton(
                    label: 'Manual',
                    onPressed: () async => _showManualBMMDialog(context, viewModel),
                    variant: ButtonVariant.secondary,
                  ),
                  const SizedBox(width: 16),
                  SailText.primary15('Bid Amount:'),
                  SizedBox(
                    width: 120,
                    child: SailTextField(controller: viewModel.bidAmountController, hintText: '0.0001'),
                  ),
                  const SizedBox(width: 16),
                  SailText.primary15('Refresh:'),
                  SizedBox(
                    width: 150,
                    child: SailTextField(controller: viewModel.intervalController, hintText: '1 Second(s)'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Statistics row
              SailRow(
                spacing: SailStyleValues.padding16,
                children: [
                  _StatChip(
                    label: 'Success',
                    value: viewModel.successCount.toString(),
                    color: theme.colors.success,
                  ),
                  _StatChip(
                    label: 'Failed',
                    value: viewModel.failedCount.toString(),
                    color: theme.colors.error,
                  ),
                  _StatChip(
                    label: 'Pending',
                    value: viewModel.pendingCount.toString(),
                    color: theme.colors.orange,
                  ),
                  _StatChip(
                    label: 'Total Profit',
                    value: '${viewModel.totalProfit} sats',
                    color: viewModel.totalProfit >= 0 ? theme.colors.success : theme.colors.error,
                  ),
                  const Spacer(),
                  if (viewModel.attempts.isNotEmpty)
                    SailButton(
                      label: 'Clear History',
                      variant: ButtonVariant.secondary,
                      onPressed: () async => viewModel.clearHistory(),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SailTable(
                  getRowId: (index) =>
                      viewModel.attempts[index].txid.isEmpty ? 'attempt-$index' : viewModel.attempts[index].txid,
                  headerBuilder: (context) => [
                    SailTableHeaderCell(name: 'MC txid'),
                    SailTableHeaderCell(name: 'MC Block'),
                    SailTableHeaderCell(name: 'SC Block'),
                    SailTableHeaderCell(name: 'Txns'),
                    SailTableHeaderCell(name: 'Fees (sats)'),
                    SailTableHeaderCell(name: 'Bid (sats)'),
                    SailTableHeaderCell(name: 'Profit (sats)'),
                    SailTableHeaderCell(name: 'Status'),
                  ],
                  rowBuilder: (context, row, selected) {
                    final attempt = viewModel.attempts[row];
                    final shortTxid = attempt.txid.length > 10 ? '${attempt.txid.substring(0, 10)}..' : attempt.txid;
                    final shortBlockHash = attempt.hashLastMainBlock.length > 10
                        ? '${attempt.hashLastMainBlock.substring(0, 10)}..'
                        : attempt.hashLastMainBlock;

                    // Calculate profit: fees - bid amount (in satoshis)
                    final bidSats = (viewModel.bmmProvider.bidAmount * 100000000).round();
                    final profit = attempt.nfees - bidSats;
                    final profitDisplay = attempt.raw.isEmpty ? '-' : profit.toString();
                    final profitColor = profit >= 0 ? theme.colors.success : theme.colors.error;

                    return [
                      SailTableCell(
                        value: shortTxid.isEmpty ? '-' : shortTxid,
                        copyValue: attempt.txid,
                        monospace: true,
                      ),
                      SailTableCell(
                        value: shortBlockHash.isEmpty ? '-' : shortBlockHash,
                        copyValue: attempt.hashLastMainBlock,
                        monospace: true,
                      ),
                      SailTableCell(value: attempt.bmmBlockCreated ?? '-', monospace: true),
                      SailTableCell(value: attempt.ntxn.toString()),
                      SailTableCell(value: attempt.nfees.toString(), monospace: true),
                      SailTableCell(value: bidSats.toString(), monospace: true),
                      SailTableCell(
                        value: profitDisplay,
                        monospace: true,
                        textColor: attempt.raw.isNotEmpty ? profitColor : null,
                      ),
                      SailTableCell(
                        value: attempt.status,
                        textColor: _getStatusTextColor(attempt, theme.colors),
                      ),
                    ];
                  },
                  rowCount: viewModel.attempts.length,
                  // Highlight rows based on status
                  rowBackgroundColor: (index) {
                    final attempt = viewModel.attempts[index];
                    return _getStatusColor(attempt, theme.colors);
                  },
                  drawGrid: true,
                  contextMenuItems: (rowId) {
                    // Handle both empty txid (attempt-N format) and regular txid
                    late final BmmResult attempt;
                    if (rowId.startsWith('attempt-')) {
                      final index = int.parse(rowId.replaceFirst('attempt-', ''));
                      attempt = viewModel.attempts[index];
                    } else {
                      attempt = viewModel.attempts.firstWhere((a) => a.txid == rowId);
                    }
                    return [
                      SailMenuItem(
                        onSelected: () {
                          // Copy transaction ID to clipboard
                          Clipboard.setData(ClipboardData(text: attempt.txid));
                        },
                        child: SailText.primary12('Copy TXID'),
                      ),
                      if (attempt.bmmBlockCreated != null)
                        SailMenuItem(
                          onSelected: () {
                            // Copy block hash to clipboard
                            Clipboard.setData(ClipboardData(text: attempt.bmmBlockCreated!));
                          },
                          child: SailText.primary12('Copy Block Hash'),
                        ),
                      SailMenuItem(
                        onSelected: () {
                          // Show attempt details in a dialog
                          showThemedDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: SailText.primary15('BMM Attempt Details'),
                                content: SailColumn(
                                  spacing: SailStyleValues.padding08,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SailText.primary12('Transaction ID: ${attempt.txid}'),
                                    SailText.primary12('Mainchain Block: ${attempt.hashLastMainBlock}'),
                                    if (attempt.bmmBlockCreated != null)
                                      SailText.primary12('Sidechain Block: ${attempt.bmmBlockCreated}'),
                                    if (attempt.bmmBlockSubmitted != null)
                                      SailText.primary12('Submitted Block: ${attempt.bmmBlockSubmitted}'),
                                    if (attempt.bmmBlockSubmittedBlind != null)
                                      SailText.primary12('Submitted Blind: ${attempt.bmmBlockSubmittedBlind}'),
                                    SailText.primary12('Transactions: ${attempt.ntxn}'),
                                    SailText.primary12('Fees: ${attempt.nfees}'),
                                    if (attempt.error != null)
                                      SailText.primary12('Error: ${attempt.error}', color: theme.colors.error),
                                  ],
                                ),
                                actions: [
                                  SailButton(label: 'Close', onPressed: () async => Navigator.of(context).pop()),
                                ],
                              );
                            },
                          );
                        },
                        child: SailText.primary12('Show Details'),
                      ),
                    ];
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class BMMViewModel extends BaseViewModel {
  final BMMProvider bmmProvider = GetIt.I.get<BMMProvider>();

  final TextEditingController bidAmountController;
  final TextEditingController intervalController;

  Timer? _syncTimer;

  BMMViewModel() : bidAmountController = TextEditingController(), intervalController = TextEditingController() {
    // Initialize controllers with provider values
    bidAmountController.text = bmmProvider.bidAmount.toString();
    intervalController.text = bmmProvider.interval.inSeconds.toString();

    // Listen for changes in the text fields
    bidAmountController.addListener(_onBidAmountChanged);
    intervalController.addListener(_onIntervalChanged);

    // Listen for changes in provider and update controllers
    bmmProvider.addListener(_syncControllers);

    // Optionally, keep controllers in sync every second
    _syncTimer = Timer.periodic(const Duration(seconds: 1), (_) => _syncControllers());
  }

  bool get isMining => bmmProvider.isMining;

  int get successCount => attempts.where((a) => a.raw.isNotEmpty && a.error == null).length;
  int get failedCount => attempts.where((a) => a.error != null).length;
  int get pendingCount => attempts.where((a) => a.raw.isEmpty).length;

  int get totalProfit {
    final bidSats = (bmmProvider.bidAmount * 100000000).round();
    return attempts.where((a) => a.raw.isNotEmpty && a.error == null).fold(0, (sum, a) => sum + (a.nfees - bidSats));
  }

  void clearHistory() {
    bmmProvider.attempts.clear();
    notifyListeners();
  }

  void _onBidAmountChanged() {
    final parsed = double.tryParse(bidAmountController.text);
    if (parsed != null && parsed != bmmProvider.bidAmount) {
      bmmProvider.setBidAmount(parsed);
    }
    notifyListeners();
  }

  void _onIntervalChanged() {
    final parsed = int.tryParse(intervalController.text);
    if (parsed != null && parsed != bmmProvider.interval.inSeconds) {
      bmmProvider.setInterval(Duration(seconds: parsed));
    }
    notifyListeners();
  }

  void _syncControllers() {
    if (bidAmountController.text != bmmProvider.bidAmount.toString()) {
      bidAmountController.text = bmmProvider.bidAmount.toString();
    }
    if (intervalController.text != bmmProvider.interval.inSeconds.toString()) {
      intervalController.text = bmmProvider.interval.inSeconds.toString();
    }
    notifyListeners();
  }

  List<BmmResult> get attempts => bmmProvider.attempts;

  @override
  void dispose() {
    bidAmountController.removeListener(_onBidAmountChanged);
    intervalController.removeListener(_onIntervalChanged);
    bidAmountController.dispose();
    intervalController.dispose();
    bmmProvider.removeListener(_syncControllers);
    _syncTimer?.cancel();
    super.dispose();
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SailStyleValues.padding12,
        vertical: SailStyleValues.padding04,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: SailStyleValues.borderRadiusSmall,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SailText.primary12(label, color: color),
          const SizedBox(width: 8),
          SailText.primary12(value, bold: true, color: color),
        ],
      ),
    );
  }
}

class _CopyableField extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _CopyableField({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 180,
          child: SailText.primary12('$label:', bold: true),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: SelectableText(
                  value,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: valueColor,
                  ),
                ),
              ),
              if (value.isNotEmpty && value != 'Pending...' && value != 'Unknown')
                IconButton(
                  icon: const Icon(Icons.copy, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Copied $label to clipboard'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}
