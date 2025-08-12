
import 'package:bitwindow/models/multisig_group.dart';
import 'package:bitwindow/models/multisig_transaction.dart';
import 'package:bitwindow/providers/multisig_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

// MultisigGroup is now imported directly

class CombineBroadcastModal extends StatefulWidget {
  final List<MultisigTransaction> eligibleTransactions;
  final List<MultisigGroup> multisigGroups;
  final Function() onBroadcastSuccess;

  const CombineBroadcastModal({
    super.key,
    required this.eligibleTransactions,
    required this.multisigGroups,
    required this.onBroadcastSuccess,
  });

  @override
  State<CombineBroadcastModal> createState() => _CombineBroadcastModalState();
}

class _CombineBroadcastModalState extends State<CombineBroadcastModal> {
  MultisigTransaction? _selectedTransaction;
  bool _isBroadcasting = false;
  String? _error;
  MainchainRPC get _rpc => GetIt.I.get<MainchainRPC>();
  Logger get _logger => GetIt.I.get<Logger>();
  
  @override
  void initState() {
    super.initState();
    if (widget.eligibleTransactions.length == 1) {
      _selectedTransaction = widget.eligibleTransactions.first;
    }
  }

  Future<void> _combineAndBroadcast() async {
    if (_selectedTransaction == null) {
      _logger.e('ERROR: No transaction selected for broadcast');
      return;
    }

    setState(() => _isBroadcasting = true);
    // 'Starting broadcast process for transaction: ${_selectedTransaction!.id}');

    try {
      final tx = _selectedTransaction!;
      // 'Transaction details: ID=${tx.id}, GroupID=${tx.groupId}, Status=${tx.status}');
      // 'Transaction has ${tx.keyPSBTs.length} keyPSBT entries');
      
      final group = widget.multisigGroups.firstWhere(
        (g) => g.id == tx.groupId,
        orElse: () => throw Exception('Group not found'),
      );
      // 'Found group: ${group.name} (${group.m} of ${group.n} multisig)');
      
      // Log all keyPSBTs and their status
      for (int i = 0; i < tx.keyPSBTs.length; i++) {
        final kp = tx.keyPSBTs[i];
        final keyName = group.keys.where((k) => k.xpub == kp.keyId).firstOrNull?.owner ?? 'Unknown';
        // 'KeyPSBT $i: $keyName - isSigned=${kp.isSigned} - hasData=${kp.psbt != null}');
      }

      // Validate existing signed PSBTs
      // 'Validating existing signed PSBTs...');
      int validatedCount = 0;
      for (final kp in tx.keyPSBTs) {
        if (kp.isSigned && kp.psbt != null) {
          try {
            final keyName = group.keys.where((k) => k.xpub == kp.keyId).firstOrNull?.owner ?? 'Unknown';
            // 'Validating PSBT for $keyName...');
            final storedAnalysis = await _rpc.callRAW('analyzepsbt', [kp.psbt!]);
            // 'PSBT analysis for $keyName: $storedAnalysis');
            if (storedAnalysis is Map) {
              final inputs = storedAnalysis['inputs'] as List<dynamic>? ?? [];
              bool actuallyHasSignatures = false;
              
              for (final input in inputs) {
                if (input is Map<String, dynamic>) {
                  final isInputFinal = input['is_final'] as bool? ?? false;
                  final missing = input['missing'] as Map<String, dynamic>?;
                  final missingSignatures = missing?['signatures'] as List<dynamic>? ?? [];
                  final totalMissing = missingSignatures.length;
                  
                  // Look for evidence this is a multisig input
                  final hasRedeemScript = missing?.containsKey('redeemscript') == true;
                  final hasWitnessScript = missing?.containsKey('witnessscript') == true;
                  
                  // For multisig detection, we need to consider:
                  // 1. Traditional multisig (has redeemscript/witnessscript)
                  // 2. Native segwit multisig (can have any number of missing signatures)
                  // Since we know this is a multisig group, assume all inputs are multisig
                  final isMultisig = hasRedeemScript || hasWitnessScript || group.n > 1;
                  
                  // 'Input analysis: is_final=$isInputFinal, missing_count=$totalMissing, is_multisig=$isMultisig');
                  
                  if (isMultisig) {
                    // For m-of-n multisig: if missing fewer than m signatures, then some signatures are present
                    final requiredSignatures = group.m;
                    actuallyHasSignatures = totalMissing < requiredSignatures || isInputFinal;
                    // 'Multisig validation: required=$requiredSignatures, missing=$totalMissing, has_some=$actuallyHasSignatures');
                  } else {
                    // Single sig - either fully signed or not
                    actuallyHasSignatures = totalMissing == 0 || isInputFinal;
                  }
                  
                  if (actuallyHasSignatures) {
                    break; // Found at least one input with signatures
                  }
                }
              }
              
              if (kp.isSigned && !actuallyHasSignatures) {
                        _logger.w('WARNING: PSBT marked as signed but RPC analysis shows no signatures');
                _logger.w('Resetting transaction status due to invalid signatures');
                  
                final updatedKeyPSBTs = tx.keyPSBTs.map((keyPSBT) => KeyPSBTStatus(
                  keyId: keyPSBT.keyId,
                  psbt: keyPSBT.psbt,
                  isSigned: false,
                  signedAt: null,
                ),).toList();
                
                final updatedTx = tx.copyWith(
                  keyPSBTs: updatedKeyPSBTs,
                  status: TxStatus.needsSignatures,
                );
                
                await TransactionStorage.saveTransaction(updatedTx);
                widget.onBroadcastSuccess();
                
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invalid signatures detected - transaction status reset'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
                return;
              } else {
                // 'PSBT for $keyName validated successfully');
                validatedCount++;
              }
            }
          } catch (e) {
            _logger.e('Error validating PSBT: $e');
          }
        }
      }
      // 'Validated $validatedCount signed PSBTs');
      
      // Collect signed PSBTs for combination
      final signedPSBTs = tx.keyPSBTs
        .where((k) => k.isSigned && k.psbt != null)
        .map((k) => k.psbt!)
        .toList();
      
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
      // 'Unique PSBTs for combination: ${uniquePSBTs.length}');
      
      // Use first PSBT if only one, otherwise combine
      String combined;
      if (uniquePSBTs.length == 1) {
        combined = uniquePSBTs.first;
        // 'Using single PSBT directly: ${combined.substring(0, 50)}...');
      } else {
        // 'PSBTs to combine: ${uniquePSBTs.map((p) => '${p.substring(0, 20)}...').toList()}');
        final combineResult = await _rpc.callRAW('combinepsbt', [signedPSBTs]);
        combined = combineResult as String;
        // 'Combined PSBT: ${combined.substring(0, 50)}...');
      }
      
      // Analyze the combined PSBT
      // 'Analyzing combined PSBT...');
      final analyzeResult = await _rpc.callRAW('analyzepsbt', [combined]);
      // 'Analysis result: $analyzeResult');
      
      // Finalize the PSBT
      // 'Finalizing PSBT...');
      final finalizeResult = await _rpc.callRAW('finalizepsbt', [combined]);
      
      if (finalizeResult is! Map) {
        _logger.e('ERROR: PSBT finalization returned invalid result type');
        throw Exception('PSBT finalization returned invalid result type');
      }
      
      // 'Finalization result: $finalizeResult');
      final complete = finalizeResult['complete'] as bool? ?? false;
      // 'Transaction complete status: $complete');
      
      if (!complete) {
        final errors = finalizeResult['errors'] as List<dynamic>? ?? [];
        _logger.e('ERROR: PSBT finalization failed - errors: $errors');
        throw Exception('PSBT finalization failed - transaction not complete. Errors: $errors');
      }
      
      final hex = finalizeResult['hex'] as String?;
      if (hex == null) {
        _logger.e('ERROR: No transaction hex returned from finalization');
        throw Exception('No transaction hex returned from finalization');
      }
      
      // 'Transaction finalized successfully');
      // 'Transaction hex (first 50 chars): ${hex.substring(0, 50)}...');
      // 'Broadcasting transaction...');
      
      // Broadcast the transaction
      final txid = await _rpc.callRAW('sendrawtransaction', [hex]) as String;
      // 'Transaction broadcast successfully! TXID: $txid');
      
      // Update transaction status
      await TransactionStatusManager.updateTransactionStatus(
        transactionId: tx.id,
        newStatus: TxStatus.broadcasted,
        finalHex: hex,
        reason: 'Transaction broadcast',
      );
      
      // Clean up multisig PSBTs
      await TransactionStorage.cleanupPSBTFromMultisigFile(tx.id);
      
      widget.onBroadcastSuccess();
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaction broadcast successfully!\nTXID: ${txid.substring(0, 16)}...'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      _logger.e('Broadcast failed: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isBroadcasting = false;
        });
      }
    } finally {
      if (mounted && _error == null) {
        setState(() => _isBroadcasting = false);
      }
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
          subtitle: widget.eligibleTransactions.isEmpty 
            ? 'No transactions ready for broadcast'
            : 'Select transaction to combine PSBTs and broadcast',
          error: _error,
          child: SailColumn(
            spacing: SailStyleValues.padding16,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.eligibleTransactions.isEmpty) ...[
                SailText.secondary13('No transactions with sufficient signatures found.'),
                SailText.secondary12('Complete signing for transactions before broadcasting.'),
              ] else if (widget.eligibleTransactions.length == 1) ...[
                _buildTransactionDetails(_selectedTransaction!),
              ] else ...[
                SailText.primary13('Available Transactions (${widget.eligibleTransactions.length})'),
                SailSpacing(SailStyleValues.padding08),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.eligibleTransactions.length,
                    itemBuilder: (context, index) {
                      final tx = widget.eligibleTransactions[index];
                      final group = widget.multisigGroups.firstWhere(
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
                                  onChanged: _isBroadcasting ? null : (value) {
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
                    onPressed: _isBroadcasting ? null : () async => Navigator.of(context).pop(),
                    variant: ButtonVariant.secondary,
                  ),
                  if (widget.eligibleTransactions.isNotEmpty)
                    SailButton(
                      label: 'Combine & Broadcast',
                      onPressed: _isBroadcasting || _selectedTransaction == null ? null : _combineAndBroadcast,
                      loading: _isBroadcasting,
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
    final group = widget.multisigGroups.firstWhere(
      (g) => g.id == tx.groupId,
      orElse: () => throw Exception('Group not found'),
    );

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
    final group = widget.multisigGroups.firstWhere(
      (g) => g.id == tx.groupId,
      orElse: () => throw Exception('Group not found'),
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
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