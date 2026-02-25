import 'package:bitassets/providers/bitassets_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

enum TransactionType {
  swap,
  auctionBid,
  liquidityAdd,
  liquidityRemove,
  assetTransfer,
  assetReceive,
}

class BitAssetsTransaction {
  final String id;
  final TransactionType type;
  final String title;
  final String subtitle;
  final int amount;
  final String assetId;
  final DateTime timestamp;
  final bool isIncoming;

  BitAssetsTransaction({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.assetId,
    required this.timestamp,
    required this.isIncoming,
  });

  String get typeIcon {
    switch (type) {
      case TransactionType.swap:
        return 'Swap';
      case TransactionType.auctionBid:
        return 'Bid';
      case TransactionType.liquidityAdd:
        return 'LP+';
      case TransactionType.liquidityRemove:
        return 'LP-';
      case TransactionType.assetTransfer:
        return 'Send';
      case TransactionType.assetReceive:
        return 'Recv';
    }
  }
}

class TransactionHistoryCard extends StatelessWidget {
  final int maxItems;

  const TransactionHistoryCard({super.key, this.maxItems = 10});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<TransactionHistoryViewModel>.reactive(
      viewModelBuilder: () => TransactionHistoryViewModel(),
      builder: (context, model, child) {
        final theme = SailTheme.of(context);

        return SailCard(
          title: 'Recent Activity',
          subtitle: 'Your recent BitAssets transactions',
          child: model.isLoading
              ? const SizedBox(
                  height: 200,
                  child: Center(child: SailCircularProgressIndicator()),
                )
              : model.transactions.isEmpty
              ? SizedBox(
                  height: 150,
                  child: Center(
                    child: SailColumn(
                      spacing: SailStyleValues.padding08,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SailSVG.icon(SailSVGAsset.iconCalendar, width: 40),
                        SailText.secondary13('No recent activity'),
                        SailText.secondary12('Your transactions will appear here'),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Table header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SailStyleValues.padding12,
                        vertical: SailStyleValues.padding08,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colors.backgroundSecondary,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 60, child: SailText.secondary12('Type')),
                          Expanded(flex: 2, child: SailText.secondary12('Details')),
                          Expanded(child: SailText.secondary12('Amount', textAlign: TextAlign.right)),
                          SizedBox(width: 80, child: SailText.secondary12('Time', textAlign: TextAlign.right)),
                        ],
                      ),
                    ),
                    // Transaction rows
                    ...model.transactions
                        .take(maxItems)
                        .map(
                          (tx) => _TransactionRow(
                            transaction: tx,
                            onCopyId: () => model.copyToClipboard(tx.id, context),
                          ),
                        ),
                  ],
                ),
        );
      },
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final BitAssetsTransaction transaction;
  final VoidCallback onCopyId;

  const _TransactionRow({
    required this.transaction,
    required this.onCopyId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final isPositive = transaction.isIncoming;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SailStyleValues.padding12,
        vertical: SailStyleValues.padding12,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.colors.divider, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Type badge
          SizedBox(
            width: 60,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getTypeColor(transaction.type, theme).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: SailText.secondary12(
                transaction.typeIcon,
                color: _getTypeColor(transaction.type, theme),
                textAlign: TextAlign.center,
                bold: true,
              ),
            ),
          ),

          // Details
          Expanded(
            flex: 2,
            child: SailRow(
              spacing: SailStyleValues.padding08,
              children: [
                Expanded(
                  child: SailColumn(
                    spacing: 2,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SailText.primary13(transaction.title),
                      SailText.secondary12(transaction.subtitle),
                    ],
                  ),
                ),
                IconButton(
                  icon: SailSVG.icon(SailSVGAsset.iconCopy, width: 12),
                  onPressed: onCopyId,
                  tooltip: 'Copy TX ID',
                  iconSize: 12,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                ),
              ],
            ),
          ),

          // Amount
          Expanded(
            child: SailText.primary13(
              '${isPositive ? '+' : '-'}${_formatAmount(transaction.amount)}',
              textAlign: TextAlign.right,
              color: isPositive ? theme.colors.success : theme.colors.error,
              monospace: true,
              bold: true,
            ),
          ),

          // Time
          SizedBox(
            width: 80,
            child: SailText.secondary12(
              _formatTime(transaction.timestamp),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(TransactionType type, SailThemeData theme) {
    switch (type) {
      case TransactionType.swap:
        return theme.colors.primary;
      case TransactionType.auctionBid:
        return theme.colors.orange;
      case TransactionType.liquidityAdd:
        return theme.colors.success;
      case TransactionType.liquidityRemove:
        return theme.colors.error;
      case TransactionType.assetTransfer:
        return theme.colors.error;
      case TransactionType.assetReceive:
        return theme.colors.success;
    }
  }

  String _formatAmount(int amount) {
    if (amount >= 100000000) {
      return '${(amount / 100000000).toStringAsFixed(4)} BTC';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(2)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}k';
    }
    return amount.toString();
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${time.month}/${time.day}';
    }
  }
}

class TransactionHistoryViewModel extends BaseViewModel {
  final BitAssetsProvider bitAssetsProvider = GetIt.I.get<BitAssetsProvider>();
  final NotificationProvider notificationProvider = GetIt.I.get<NotificationProvider>();

  TransactionHistoryViewModel() {
    bitAssetsProvider.addListener(notifyListeners);
  }

  bool get isLoading => false;

  List<BitAssetsTransaction> get transactions {
    // For now, return an empty list - transaction history requires RPC methods
    // that may not be implemented yet. This widget is ready to display data
    // once the backend provides transaction history.
    return [];
  }

  void copyToClipboard(String text, BuildContext context) {
    Clipboard.setData(ClipboardData(text: text));
    notificationProvider.add(
      title: 'Copied',
      content: 'Transaction ID copied to clipboard',
      dialogType: DialogType.success,
    );
  }

  @override
  void dispose() {
    bitAssetsProvider.removeListener(notifyListeners);
    super.dispose();
  }
}
