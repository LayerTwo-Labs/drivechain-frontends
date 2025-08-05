
import 'package:bitwindow/models/multisig_group.dart';
import 'package:bitwindow/models/multisig_transaction.dart';
import 'package:bitwindow/providers/multisig_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
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

  @override
  void initState() {
    super.initState();
    if (widget.eligibleTransactions.length == 1) {
      _selectedTransaction = widget.eligibleTransactions.first;
    }
  }

  Future<void> _combineAndBroadcast() async {
    if (_selectedTransaction == null) return;

    setState(() => _isBroadcasting = true);

    try {
      final tx = _selectedTransaction!;
      final group = widget.multisigGroups.firstWhere(
        (g) => g.id == tx.groupId,
        orElse: () => throw Exception('Group not found'),
      );

      // Check keyPSBTs for signed entries and reset if necessary
      for (final kp in tx.keyPSBTs) {
        if (kp.isSigned && kp.psbt != null) {
          try {
            final storedAnalysis = await _rpc.callRAW('analyzepsbt', [kp.psbt!]);
            if (storedAnalysis is Map) {
              final inputs = storedAnalysis['inputs'] as List<dynamic>? ?? [];
              if (inputs.isNotEmpty) {
                final input = inputs[0] as Map<String, dynamic>;
                final missing = input['missing'] as Map<String, dynamic>? ?? {};
                final signatures = missing['signatures'] as List<dynamic>? ?? [];
                
                if (kp.isSigned && signatures.isNotEmpty) {
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
                      const SnackBar(content: Text('Transaction reset - signatures were invalid')),
                    );
                  }
                  return;
                }
              }
            }
          } catch (e) {
            // Invalid PSBT signatures - continue processing
          }
        }
      }
      
      final signedPSBTs = tx.keyPSBTs
        .where((k) => k.isSigned && k.psbt != null)
        .map((k) => k.psbt!)
        .toList();
      
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
        final combineResult = await _rpc.callRAW('combinepsbt', [signedPSBTs]);
        combined = combineResult as String;
      }
      
      final analyzeResult = await _rpc.callRAW('analyzepsbt', [combined]);
      
      final finalizeResult = await _rpc.callRAW('finalizepsbt', [combined]);
      
      if (finalizeResult is! Map) {
        throw Exception('PSBT finalization returned invalid result type');
      }
      
      final complete = finalizeResult['complete'] as bool? ?? false;
      
      if (!complete) {
        final errors = finalizeResult['errors'] as List<dynamic>? ?? [];
        throw Exception('PSBT finalization failed - transaction not complete. Errors: $errors');
      }
      
      final hex = finalizeResult['hex'] as String?;
      if (hex == null) {
        throw Exception('No transaction hex returned from finalization');
      }
      
      final txid = await _rpc.callRAW('sendrawtransaction', [hex]);
      
      if (txid is! String) {
        throw Exception('Invalid txid returned from broadcast');
      }
      
      await TransactionStorage.updateTransactionStatus(
        tx.id,
        TxStatus.broadcasted,
        txid: txid,
        broadcastTime: DateTime.now(),
        finalHex: hex,
        combinedPSBT: combined,
      );
      
      // Clean up PSBT data from multisig.json since transaction is now broadcast
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
          title: 'Combine and Broadcast',
          subtitle: widget.eligibleTransactions.isEmpty 
              ? 'No transactions available'
              : 'Select a transaction to broadcast',
          error: _error,
          withCloseButton: true,
          child: SailColumn(
            spacing: SailStyleValues.padding16,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.eligibleTransactions.isEmpty) ...[
                SailText.secondary13('No transactions are ready for broadcast.'),
                SailText.secondary12('Transactions must have enough signatures before they can be broadcast.'),
              ] else if (widget.eligibleTransactions.length == 1) ...[
                _buildTransactionDetails(_selectedTransaction!),
              ] else ...[
                SailText.primary13('Select Transaction'),
                SailSpacing(SailStyleValues.padding08),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.eligibleTransactions.length,
                    itemBuilder: (context, index) {
                      final tx = widget.eligibleTransactions[index];
                      final group = widget.multisigGroups.firstWhere(
                        (g) => g.id == tx.groupId,
                        orElse: () => MultisigGroup(
                          id: tx.groupId, 
                          name: 'Unknown', 
                          n: 0, 
                          m: 0, 
                          keys: [], 
                          created: 0,
                        ),
                      );
                      
                      final isSelected = _selectedTransaction?.id == tx.id;
                      
                      return SailCard(
                        shadowSize: ShadowSize.none,
                        child: ListTile(
                          selected: isSelected,
                          selectedTileColor: context.sailTheme.colors.primary.withValues(alpha: 0.1),
                          title: SailText.primary13('${tx.shortId} - ${group.name}'),
                          subtitle: SailColumn(
                            spacing: SailStyleValues.padding04,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SailText.secondary12('Amount: ${tx.amount.toStringAsFixed(8)} BTC'),
                              SailText.secondary12('Signatures: ${tx.signatureCount}/${group.m}'),
                            ],
                          ),
                          trailing: isSelected 
                              ? Icon(Icons.check_circle, color: context.sailTheme.colors.primary)
                              : null,
                          onTap: () => setState(() => _selectedTransaction = tx),
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
                spacing: SailStyleValues.padding12,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SailButton(
                    label: 'Cancel',
                    onPressed: _isBroadcasting ? null : () async => Navigator.of(context).pop(),
                    variant: ButtonVariant.ghost,
                  ),
                  if (widget.eligibleTransactions.isNotEmpty)
                    SailButton(
                      label: 'Broadcast',
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
  
  Widget _buildTransactionDetails(MultisigTransaction tx) {
    final group = widget.multisigGroups.firstWhere(
      (g) => g.id == tx.groupId,
      orElse: () => MultisigGroup(
        id: tx.groupId, 
        name: 'Unknown', 
        n: 0, 
        m: 0, 
        keys: [], 
        created: 0,
      ),
    );
    
    return SailCard(
      shadowSize: ShadowSize.none,
      child: SailColumn(
        spacing: SailStyleValues.padding08,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SailText.primary13('Transaction Details'),
          SailSpacing(SailStyleValues.padding04),
          SailRow(
            spacing: SailStyleValues.padding16,
            children: [
              SailColumn(
                spacing: SailStyleValues.padding04,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SailText.secondary12('Transaction ID:'),
                  SailText.primary13(tx.shortId),
                ],
              ),
              SailColumn(
                spacing: SailStyleValues.padding04,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SailText.secondary12('Amount:'),
                  SailText.primary13('${tx.amount.toStringAsFixed(8)} BTC'),
                ],
              ),
              SailColumn(
                spacing: SailStyleValues.padding04,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SailText.secondary12('Signatures:'),
                  SailText.primary13('${tx.signatureCount}/${group.m}'),
                ],
              ),
            ],
          ),
          SailText.secondary12('Destination: ${tx.destination}'),
          SailText.secondary12('Fee: ${tx.fee.toStringAsFixed(8)} BTC'),
        ],
      ),
    );
  }
}