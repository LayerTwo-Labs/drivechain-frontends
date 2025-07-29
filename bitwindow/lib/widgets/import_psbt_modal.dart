import 'dart:convert';

import 'package:bitwindow/models/multisig_group_enhanced.dart';
import 'package:bitwindow/models/multisig_transaction.dart';
import 'package:bitwindow/services/transaction_storage.dart';
import 'package:bitwindow/services/wallet_rpc_manager.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

typedef MultisigGroup = MultisigGroupEnhanced;

class ImportPSBTModal extends StatefulWidget {
  final List<MultisigGroup> availableGroups;
  final Function() onImportSuccess;

  const ImportPSBTModal({
    super.key,
    required this.availableGroups,
    required this.onImportSuccess,
  });

  @override
  State<ImportPSBTModal> createState() => _ImportPSBTModalState();
}

class _ImportPSBTModalState extends State<ImportPSBTModal> {
  final TextEditingController _psbtController = TextEditingController();
  final TextEditingController _txIdController = TextEditingController();
  String? _selectedGroupId;
  bool _isImporting = false;
  MainchainRPC get _rpc => GetIt.I.get<MainchainRPC>();

  @override
  void dispose() {
    _psbtController.dispose();
    _txIdController.dispose();
    super.dispose();
  }

  Future<void> _importPSBT() async {
    if (_selectedGroupId == null || 
        _txIdController.text.isEmpty || 
        _psbtController.text.isEmpty) {
      return;
    }

    setState(() => _isImporting = true);

    try {
      final cleanPsbt = _psbtController.text.replaceAll(RegExp(r'\s'), '');
      
      final decodedPsbt = await _rpc.callRAW('decodepsbt', [cleanPsbt]);
      if (decodedPsbt is! Map) {
        throw Exception('Invalid PSBT format');
      }
      
      final analyzePsbt = await _rpc.callRAW('analyzepsbt', [cleanPsbt]);
      if (analyzePsbt is! Map) {
        throw Exception('Failed to analyze PSBT');
      }
      
      final inputs = analyzePsbt['inputs'] as List<dynamic>? ?? [];
      final hasSignatures = inputs.any((input) => 
        input is Map && (input['has_utxo'] == true) && (input['is_final'] == true || 
        (input['signatures'] as List<dynamic>?)?.isNotEmpty == true),
      );
      
      final group = widget.availableGroups.firstWhere(
        (g) => g.id == _selectedGroupId,
        orElse: () => throw Exception('Group not found'),
      );
      
      final existingTx = await TransactionStorage.getTransaction(_txIdController.text.trim());
      
      if (existingTx != null) {
        if (hasSignatures) {
          final walletKeys = group.keys.where((k) => k.isWallet).toList();
          for (final walletKey in walletKeys) {
            final existingKeyPsbt = existingTx.keyPSBTs.firstWhere(
              (kp) => kp.keyId == walletKey.xpub,
              orElse: () => KeyPSBTStatus(keyId: walletKey.xpub, isSigned: false),
            );
            
            if (!existingKeyPsbt.isSigned) {
              await TransactionStorage.updateKeyPSBT(
                _txIdController.text.trim(), 
                walletKey.xpub, 
                cleanPsbt,
                signatureThreshold: group.m,
              );
              break;
            }
          }
          
          final updatedTx = await TransactionStorage.getTransaction(_txIdController.text.trim());
          if (updatedTx != null && updatedTx.signatureCount >= group.m) {
            await TransactionStorage.updateTransactionStatus(
              _txIdController.text.trim(),
              TxStatus.readyForBroadcast,
            );
          }
        }
      } else {
        final tx = decodedPsbt['tx'] as Map<String, dynamic>;
        final outputs = tx['vout'] as List<dynamic>;
        
        double amount = 0.0;
        String destination = '';
        if (outputs.isNotEmpty) {
          final firstOutput = outputs.first as Map<String, dynamic>;
          amount = (firstOutput['value'] as num).toDouble();
          final scriptPubKey = firstOutput['scriptPubKey'] as Map<String, dynamic>;
          destination = scriptPubKey['address'] as String? ?? 'Unknown';
        }
        
        final newTx = MultisigTransaction(
          id: _txIdController.text.trim(),
          groupId: _selectedGroupId!,
          initialPSBT: cleanPsbt,
          status: hasSignatures ? TxStatus.needsSignatures : TxStatus.needsSignatures,
          created: DateTime.now(),
          amount: amount,
          destination: destination,
          fee: 0.0,
          inputs: [],
        );
        
        await TransactionStorage.saveTransaction(newTx);
      }
      
      widget.onImportSuccess();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PSBT imported successfully${hasSignatures ? ' (with signatures)' : ' (unsigned)'}'),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to import PSBT: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Import PSBT'),
      content: SizedBox(
        width: 500,
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Multisig Group:'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedGroupId,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Select a multisig group',
              ),
              items: widget.availableGroups.map((group) => DropdownMenuItem(
                value: group.id,
                child: Text('${group.name} (${group.id})'),
              )).toList(),
              onChanged: (value) => setState(() => _selectedGroupId = value),
            ),
            const SizedBox(height: 16),
            const Text('Transaction ID (MuSIG_TXID):'),
            const SizedBox(height: 8),
            TextField(
              controller: _txIdController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter the MuSIG transaction ID',
              ),
            ),
            const SizedBox(height: 16),
            const Text('PSBT Data:'),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: _psbtController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Paste the PSBT data here...',
                  alignLabelWithHint: true,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isImporting ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isImporting || 
                    _selectedGroupId == null || 
                    _txIdController.text.isEmpty || 
                    _psbtController.text.isEmpty
              ? null
              : _importPSBT,
          child: _isImporting 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Import'),
        ),
      ],
    );
  }
}