
import 'package:bitwindow/models/multisig_group.dart';
import 'package:bitwindow/models/multisig_transaction.dart';
import 'package:bitwindow/providers/multisig_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

// MultisigGroup is now imported directly

class CombineBroadcastModal extends StatefulWidget {
  final Function() onSuccess;

  const CombineBroadcastModal({
    super.key,
    required this.onSuccess,
  });

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
  Logger get _logger => GetIt.I.get<Logger>();
  
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

      // Load all transactions and filter for eligible ones
      final allTransactions = await TransactionStorage.loadTransactions();
      _eligibleTransactions = allTransactions
          .where((tx) => tx.status == TxStatus.readyToCombine || tx.status == TxStatus.readyForBroadcast)
          .toList();

      // Load all multisig groups
      _multisigGroups = await MultisigStorage.loadGroups();

      // Select first transaction if available
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
      _logger.e('ERROR: No transaction selected for broadcast');
      return;
    }

    setState(() => _isProcessing = true);
    // 'Starting broadcast process for transaction: ${_selectedTransaction!.id}');

    try {
      final tx = _selectedTransaction!;
      // 'Transaction details: ID=${tx.id}, GroupID=${tx.groupId}, Status=${tx.status}');
      // 'Transaction has ${tx.keyPSBTs.length} keyPSBT entries');
      
      final group = _multisigGroups.firstWhere(
        (g) => g.id == tx.groupId,
        orElse: () => throw Exception('Group not found'),
      );
      // 'Found group: ${group.name} (${group.m} of ${group.n} multisig)');
      
      // Log all keyPSBTs and their status

      // Collect signed PSBTs - only those marked as signed
      final signedPSBTs = <String>[];
      
      _logger.i('Collecting signed PSBTs for transaction ${tx.id}:');
      for (final kp in tx.keyPSBTs) {
        if (kp.isSigned && kp.psbt != null) {
          // Trust the isSigned flag - it should have been validated during import/signing
          signedPSBTs.add(kp.psbt!);
          _logger.i('  Key ${kp.keyId}: ${kp.psbt!.substring(0, 50)}...');
        } else {
          _logger.i('  Key ${kp.keyId}: isSigned=${kp.isSigned}, haspsbt=${kp.psbt != null}');
        }
      }
      
      _logger.i('Total PSBTs collected: ${signedPSBTs.length} (need ${group.m} signatures for ${group.m}-of-${group.n} multisig)');
      
      // 'Collected ${signedPSBTs.length} signed PSBTs for combination');
      
      if (signedPSBTs.isEmpty) {
        _logger.e('ERROR: No signed PSBTs found - cannot broadcast');
        throw Exception('No signed PSBTs found');
      }
      
      // 'Signature count check: ${tx.signatureCount}/${group.m} required');
      if (tx.signatureCount < group.m) {
        _logger.e('ERROR: Insufficient signatures for broadcast');
        throw Exception('Insufficient signatures: ${tx.signatureCount}/${group.m} required');
      }
      
      // Remove duplicates for combination
      final uniquePSBTs = signedPSBTs.toSet().toList();
      _logger.i('Unique PSBTs for combination: ${uniquePSBTs.length}');
      
      // Before combining, let's analyze each PSBT to see what signatures they contain
      for (int i = 0; i < uniquePSBTs.length; i++) {
        _logger.i('Analyzing PSBT $i before combination:');
        try {
          final analysis = await _rpc.callRAW('analyzepsbt', [uniquePSBTs[i]]);
          if (analysis is Map) {
            final inputs = analysis['inputs'] as List<dynamic>? ?? [];
            for (int j = 0; j < inputs.length; j++) {
              final input = inputs[j];
              if (input is Map<String, dynamic>) {
                final partialSigs = input['partial_signatures'] as Map<String, dynamic>? ?? {};
                _logger.i('  Input $j: ${partialSigs.length} partial signatures');
              }
            }
          }
        } catch (e) {
          _logger.e('Failed to analyze PSBT $i: $e');
        }
      }
      
      // Use first PSBT if only one, otherwise combine
      String combined;
      if (uniquePSBTs.length == 1) {
        combined = uniquePSBTs.first;
        _logger.i('Using single PSBT directly');
      } else {
        _logger.i('Combining ${uniquePSBTs.length} PSBTs...');
        final combineResult = await _rpc.callRAW('combinepsbt', [uniquePSBTs]);
        combined = combineResult as String;
        _logger.i('Combined PSBT successfully');
      }
      
      // Finalize the PSBT (this validates signatures internally)
      _logger.i('Finalizing combined PSBT...');
      final finalizeResult = await _rpc.callRAW('finalizepsbt', [combined]);
      
      if (finalizeResult is! Map) {
        _logger.e('ERROR: PSBT finalization returned invalid result type');
        throw Exception('PSBT finalization returned invalid result type');
      }
      
      _logger.d('Finalization result: $finalizeResult');
      final complete = finalizeResult['complete'] as bool? ?? false;
      final resultPsbt = finalizeResult['psbt'] as String?;
      _logger.i('Transaction complete status: $complete');
      
      if (!complete) {
        // Analyze what we actually got to understand why it's incomplete
        if (resultPsbt != null) {
          _logger.i('Analyzing incomplete PSBT to understand missing signatures...');
          final analysis = await _rpc.callRAW('analyzepsbt', [resultPsbt]);
          _logger.d('Analysis of combined PSBT: $analysis');
          
          if (analysis is Map) {
            final inputs = analysis['inputs'] as List<dynamic>? ?? [];
            for (int i = 0; i < inputs.length; i++) {
              final input = inputs[i];
              if (input is Map<String, dynamic>) {
                final partialSigs = input['partial_signatures'] as Map<String, dynamic>? ?? {};
                final missing = input['missing'] as Map<String, dynamic>?;
                final missingSignatures = missing?['signatures'] as List<dynamic>? ?? [];
                
                _logger.i('Input $i: ${partialSigs.length} partial signatures, ${missingSignatures.length} missing signatures');
                _logger.d('  Partial sigs: ${partialSigs.keys.toList()}');
                _logger.d('  Missing sigs: $missingSignatures');
              }
            }
          }
        }
        
        final errors = finalizeResult['errors'] as List<dynamic>? ?? [];
        _logger.e('ERROR: PSBT finalization failed - transaction incomplete despite having ${group.m}-of-${group.n} signatures. Errors: $errors');
        throw Exception('PSBT finalization failed - transaction not complete. Expected ${group.m}-of-${group.n} but finalization failed. Errors: $errors');
      }
      
      final hex = finalizeResult['hex'] as String?;
      if (hex == null) {
        _logger.e('ERROR: No transaction hex returned from finalization');
        throw Exception('No transaction hex returned from finalization');
      }
      
      _logger.i('Transaction finalized successfully');
      _logger.d('Transaction hex (first 50 chars): ${hex.substring(0, 50)}...');
      
      // Update transaction status to ready for broadcast
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
      _logger.e('Combine failed: $e');
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
      _logger.e('ERROR: No transaction selected for broadcast');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final tx = _selectedTransaction!;
      
      if (tx.finalHex == null) {
        throw Exception('Transaction not finalized - cannot broadcast');
      }
      
      _logger.i('Broadcasting transaction: ${tx.id}');
      
      // Broadcast the transaction
      final txid = await _rpc.callRAW('sendrawtransaction', [tx.finalHex!]) as String;
      _logger.i('Transaction broadcast successfully! TXID: $txid');
      
      // Update transaction status
      await TransactionStatusManager.updateTransactionStatus(
        transactionId: tx.id,
        newStatus: TxStatus.broadcasted,
        txid: txid,
        broadcastTime: DateTime.now(),
        reason: 'Transaction broadcast',
      );
      
      // Clean up multisig PSBTs
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
      _logger.e('Broadcast failed: $e');
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
            ? IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadData,
                tooltip: 'Refresh transactions',
              )
            : null,
          child: _isLoading 
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(48.0),
                  child: CircularProgressIndicator(),
                ),
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
                                  onChanged: _isProcessing ? null : (value) {
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
                if (_selectedTransaction != null)
                  _buildTransactionDetails(_selectedTransaction!),
              ],
              
              // Action buttons
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