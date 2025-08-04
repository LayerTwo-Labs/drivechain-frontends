
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to broadcast: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBroadcasting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.eligibleTransactions.isEmpty) {
      return AlertDialog(
        title: const Text('No Transactions Available'),
        content: const Text('No transactions are available for combine and broadcast.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      );
    }

    if (widget.eligibleTransactions.length == 1) {
      return AlertDialog(
        title: const Text('Combine and Broadcast'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ready to broadcast transaction:'),
            const SizedBox(height: 8),
            Text('Transaction ID: ${_selectedTransaction!.shortId}'),
            Text('Amount: ${_selectedTransaction!.amount.toStringAsFixed(8)} BTC'),
            Text('Signatures: ${_selectedTransaction!.signatureCount}/${widget.multisigGroups.firstWhere((g) => g.id == _selectedTransaction!.groupId).m}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _isBroadcasting ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isBroadcasting ? null : _combineAndBroadcast,
            child: _isBroadcasting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Broadcast'),
          ),
        ],
      );
    }

    return AlertDialog(
      title: const Text('Select Transaction to Broadcast'),
      content: SizedBox(
        width: 400,
        height: 300,
        child: Column(
          children: [
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
                  
                  return ListTile(
                    selected: isSelected,
                    title: Text('${tx.shortId} (${group.name})'),
                    subtitle: Text('${tx.signatureCount}/${group.m} signatures - ${tx.status.displayName}'),
                    onTap: () => setState(() => _selectedTransaction = tx),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isBroadcasting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isBroadcasting || _selectedTransaction == null ? null : _combineAndBroadcast,
          child: _isBroadcasting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Broadcast'),
        ),
      ],
    );
  }
}