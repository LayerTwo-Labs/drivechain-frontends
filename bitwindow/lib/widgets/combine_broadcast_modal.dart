import 'package:bitwindow/models/multisig_group.dart';
import 'package:bitwindow/models/multisig_transaction.dart';
import 'package:bitwindow/providers/multisig_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

class CombineBroadcastModal extends StatefulWidget {
  final Function() onSuccess;

  const CombineBroadcastModal({super.key, required this.onSuccess});

  @override
  State<CombineBroadcastModal> createState() => _CombineBroadcastModalState();
}

class _CombineBroadcastModalState extends State<CombineBroadcastModal> {
  MultisigTransaction? _selectedTransaction;
  bool _isProcessing = false;
  bool _isLoading = true;
  String? _error;
  List<MultisigTransaction> _eligibleTransactions = [];
  List<MultisigGroup> _multisigGroups = [];
  MainchainRPC get _rpc => GetIt.I.get<MainchainRPC>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final allTransactions = await TransactionStorage.loadTransactions();
      _eligibleTransactions = allTransactions
          .where((tx) => tx.status == TxStatus.readyToCombine || tx.status == TxStatus.readyForBroadcast)
          .toList();

      _multisigGroups = await MultisigStorage.loadGroups();

      if (_eligibleTransactions.isNotEmpty) {
        _selectedTransaction = _eligibleTransactions.first;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load transactions: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _combineTransaction() async {
    if (_selectedTransaction == null) {
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final tx = _selectedTransaction!;

      final group = _multisigGroups.firstWhere(
        (g) => g.id == tx.groupId,
        orElse: () => throw Exception('Group not found'),
      );

      final signedPSBTs = <String>[];

      for (final kp in tx.keyPSBTs) {
        if (kp.isSigned && kp.psbt != null) {
          signedPSBTs.add(kp.psbt!);
        }
      }

      if (signedPSBTs.isEmpty) {
        throw Exception('No signed PSBTs found');
      }

      if (tx.signatureCount < group.m) {
        throw Exception('Insufficient signatures: ${tx.signatureCount}/${group.m} required');
      }

      final uniquePSBTs = signedPSBTs.toSet().toList();

      String combined;
      if (uniquePSBTs.length == 1) {
        combined = uniquePSBTs.first;
      } else {
        final combineResult = await _rpc.callRAW('combinepsbt', [uniquePSBTs]);
        combined = combineResult as String;
      }

      final finalizeResult = await _rpc.callRAW('finalizepsbt', [combined]);

      if (finalizeResult is! Map) {
        throw Exception('PSBT finalization returned invalid result type');
      }

      final complete = finalizeResult['complete'] as bool? ?? false;

      if (!complete) {
        final errors = finalizeResult['errors'] as List<dynamic>? ?? [];
        throw Exception(
          'PSBT finalization failed - transaction not complete. Expected ${group.m}-of-${group.n} but finalization failed. Errors: $errors',
        );
      }

      final hex = finalizeResult['hex'] as String?;
      if (hex == null) {
        throw Exception('No transaction hex returned from finalization');
      }

      await TransactionStatusManager.updateTransactionStatus(
        transactionId: tx.id,
        newStatus: TxStatus.readyForBroadcast,
        combinedPSBT: combined,
        finalHex: hex,
        reason: 'PSBT combined and finalized',
      );

      widget.onSuccess();

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction combined and finalized successfully! Ready for broadcast.'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isProcessing = false;
        });
      }
    } finally {
      if (mounted && _error == null) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _broadcastTransaction() async {
    if (_selectedTransaction == null) {
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final tx = _selectedTransaction!;

      if (tx.finalHex == null) {
        throw Exception('Transaction not finalized - cannot broadcast');
      }

      final txid = await _rpc.callRAW('sendrawtransaction', [tx.finalHex!]) as String;

      await TransactionStatusManager.updateTransactionStatus(
        transactionId: tx.id,
        newStatus: TxStatus.broadcasted,
        txid: txid,
        broadcastTime: DateTime.now(),
        reason: 'Transaction broadcast',
      );

      await TransactionStorage.cleanupPSBTFromMultisigFile(tx.id);

      widget.onSuccess();

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaction broadcast successfully!\nTXID: ${txid.substring(0, 16)}...'),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isProcessing = false;
        });
      }
    } finally {
      if (mounted && _error == null) {
        setState(() => _isProcessing = false);
      }
    }
  }

  String get _actionButtonLabel {
    if (_selectedTransaction?.status == TxStatus.readyToCombine) {
      return 'Combine';
    } else if (_selectedTransaction?.status == TxStatus.readyForBroadcast) {
      return 'Broadcast';
    }
    return 'Process';
  }

  Future<void> _processTransaction() async {
    if (_selectedTransaction?.status == TxStatus.readyToCombine) {
      await _combineTransaction();
    } else if (_selectedTransaction?.status == TxStatus.readyForBroadcast) {
      await _broadcastTransaction();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
        child: SailCard(
          title: 'Combine & Broadcast',
          subtitle: _isLoading
              ? 'Loading transactions...'
              : _eligibleTransactions.isEmpty
              ? 'No transactions ready for processing'
              : 'Select transaction to combine PSBTs and broadcast',
          error: _error,
          widgetHeaderEnd: !_isLoading
              ? IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData, tooltip: 'Refresh transactions')
              : null,
          child: _isLoading
              ? const Center(
                  child: Padding(padding: EdgeInsets.all(48.0), child: CircularProgressIndicator()),
                )
              : SailColumn(
                  spacing: SailStyleValues.padding16,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_eligibleTransactions.isEmpty) ...[
                      SailText.secondary13('No transactions ready for processing found.'),
                      SailText.secondary12('Complete signing for transactions before processing.'),
                    ] else if (_eligibleTransactions.length == 1) ...[
                      _buildTransactionDetails(_selectedTransaction!),
                    ] else ...[
                      SailText.primary13('Available Transactions (${_eligibleTransactions.length})'),
                      SailSpacing(SailStyleValues.padding08),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _eligibleTransactions.length,
                          itemBuilder: (context, index) {
                            final tx = _eligibleTransactions[index];
                            final group = _multisigGroups.firstWhere(
                              (g) => g.id == tx.groupId,
                              orElse: () => throw Exception('Group not found'),
                            );

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedTransaction = tx),
                                child: SailCard(
                                  shadowSize: ShadowSize.none,
                                  child: SailRow(
                                    children: [
                                      Radio<String>(
                                        value: tx.id,
                                        groupValue: _selectedTransaction?.id,
                                        onChanged: _isProcessing
                                            ? null
                                            : (value) {
                                                setState(() => _selectedTransaction = tx);
                                              },
                                      ),
                                      Expanded(child: _buildTransactionSummary(tx, group)),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      if (_selectedTransaction != null) _buildTransactionDetails(_selectedTransaction!),
                    ],
                    SailRow(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SailButton(
                          label: 'Cancel',
                          onPressed: _isProcessing ? null : () async => Navigator.of(context).pop(),
                          variant: ButtonVariant.secondary,
                        ),
                        if (_eligibleTransactions.isNotEmpty)
                          SailButton(
                            label: _actionButtonLabel,
                            onPressed: _isProcessing || _selectedTransaction == null ? null : _processTransaction,
                            loading: _isProcessing,
                            variant: ButtonVariant.primary,
                          ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildTransactionSummary(MultisigTransaction tx, MultisigGroup group) {
    return SailColumn(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: SailStyleValues.padding04,
      children: [
        SailText.primary13('${tx.id} (${group.name})'),
        SailText.secondary12('${tx.signatureCount}/${group.m} signatures • ${tx.amount.toStringAsFixed(8)} BTC'),
        SailText.secondary12('To: ${tx.destination}'),
      ],
    );
  }

  Widget _buildTransactionDetails(MultisigTransaction tx) {
    final group = _multisigGroups.firstWhere(
      (g) => g.id == tx.groupId,
      orElse: () => throw Exception('Group not found'),
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: SailColumn(
        spacing: SailStyleValues.padding08,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailText.primary12('Transaction Details:'),
          SailText.secondary12('ID: ${tx.id}'),
          SailText.secondary12('Group: ${group.name} (${group.m} of ${group.n})'),
          SailText.secondary12('Amount: ${tx.amount.toStringAsFixed(8)} BTC'),
          SailText.secondary12('Destination: ${tx.destination}'),
          SailText.secondary12('Signatures: ${tx.signatureCount}/${group.m} required'),
          SailText.secondary12('Status: ${tx.status.displayName}'),
        ],
      ),
    );
  }
}
