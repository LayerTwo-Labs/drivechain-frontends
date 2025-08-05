import 'dart:convert';

import 'package:bitwindow/models/multisig_group.dart';
import 'package:bitwindow/providers/multisig_provider.dart';
import 'package:bitwindow/widgets/create_multisig_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class ImportTxidModal extends StatelessWidget {
  const ImportTxidModal({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ImportTxidModalViewModel>.reactive(
      viewModelBuilder: () => ImportTxidModalViewModel(),
      builder: (context, viewModel, child) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 400),
            child: SailCard(
              title: 'Import Multisig from TXID',
              subtitle: 'Import multisig group data from transaction OP_RETURN',
              error: viewModel.modalError,
              child: SingleChildScrollView(
                child: SailColumn(
                  spacing: SailStyleValues.padding16,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SailText.primary13('Enter the transaction ID containing the multisig data:'),
                    const SizedBox(height: 8),
                    
                    SailTextField(
                      label: 'Transaction ID (TXID)',
                      hintText: 'Enter or paste transaction ID',
                      controller: viewModel.txidController,
                      enabled: !viewModel.isBusy,
                      suffixWidget: SailButton(
                        label: 'Paste',
                        variant: ButtonVariant.ghost,
                        small: true,
                        onPressed: viewModel.isBusy ? null : () async {
                          await viewModel.pasteFromClipboard();
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        border: Border.all(color: Colors.blue.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SailColumn(
                        spacing: SailStyleValues.padding08,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SailText.primary13('Note:', color: Colors.blue.shade800),
                          SailText.secondary12(
                            'This will scan the transaction for OP_RETURN data containing multisig configuration. '
                            'If the data was encrypted, it cannot be imported this way. '
                            'Only unencrypted (base64 encoded) multisig data can be imported.',
                            color: Colors.blue.shade700,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    SailRow(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SailButton(
                          label: 'Import',
                          onPressed: viewModel.isBusy || viewModel.txidController.text.trim().isEmpty 
                              ? null 
                              : () async {
                                await viewModel.importFromTxid(context);
                              },
                          variant: ButtonVariant.primary,
                          loading: viewModel.isBusy,
                        ),
                        SailButton(
                          label: 'Cancel',
                          onPressed: viewModel.isBusy ? null : () async => Navigator.of(context).pop(),
                          variant: ButtonVariant.secondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ImportTxidModalViewModel extends BaseViewModel {
  final MainchainRPC _rpc = GetIt.I.get<MainchainRPC>();
  final Logger _logger = GetIt.I.get<Logger>();
  
  final txidController = TextEditingController();
  String? modalError;
  
  @override
  void dispose() {
    txidController.dispose();
    super.dispose();
  }
  
  Future<void> pasteFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text != null) {
        txidController.text = clipboardData!.text!.trim();
        notifyListeners();
      }
    } catch (e) {
      _logger.e('Failed to paste from clipboard: $e');
      modalError = 'Failed to paste from clipboard';
      notifyListeners();
    }
  }
  
  Future<void> importFromTxid(BuildContext context) async {
    setBusy(true);
    modalError = null;
    
    try {
      final txid = txidController.text.trim();
      if (txid.isEmpty) {
        modalError = 'Please enter a transaction ID';
        return;
      }
      
      // Validate TXID format (64 hex characters)
      if (txid.length != 64 || !RegExp(r'^[0-9a-fA-F]+$').hasMatch(txid)) {
        modalError = 'Invalid transaction ID format';
        return;
      }
      
      _logger.i('Importing multisig from TXID: $txid');
      
      // Get transaction data from RPC
      final transactionData = await _getTransactionData(txid);
      if (transactionData == null) {
        modalError = 'Transaction not found or not accessible';
        return;
      }
      
      // Extract OP_RETURN data
      final opReturnData = _extractOpReturnData(transactionData);
      if (opReturnData == null) {
        modalError = 'No OP_RETURN data found in transaction';
        return;
      }
      
      // Try to decode multisig data
      final multisigData = await _decodeMultisigData(opReturnData);
      if (multisigData == null) {
        modalError = 'Could not decode multisig data - it may be encrypted';
        return;
      }
      
      // Create and save the multisig group
      var group = await _createMultisigGroup(multisigData, txid);
      
      // Check if any imported keys match existing wallet keys and update isWallet flag
      group = await _checkAndUpdateWalletKeys(group);
      
      await MultisigStorage.saveGroup(group);
      
      _logger.i('Successfully imported multisig group: ${group.name}');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully imported multisig: ${group.name}'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
      
    } catch (e) {
      _logger.e('Failed to import from TXID: $e');
      modalError = 'Import failed: $e';
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }
  
  Future<Map<String, dynamic>?> _getTransactionData(String txid) async {
    try {
      final result = await _rpc.callRAW('getrawtransaction', [txid, true]);
      if (result is Map<String, dynamic>) {
        return result;
      }
      return null;
    } catch (e) {
      _logger.e('Failed to get transaction data: $e');
      return null;
    }
  }
  
  String? _extractOpReturnData(Map<String, dynamic> transactionData) {
    try {
      final vout = transactionData['vout'] as List<dynamic>?;
      if (vout == null) return null;
      
      for (final output in vout) {
        if (output is Map<String, dynamic>) {
          final scriptPubKey = output['scriptPubKey'] as Map<String, dynamic>?;
          if (scriptPubKey != null) {
            final type = scriptPubKey['type'] as String?;
            if (type == 'nulldata') {
              final hex = scriptPubKey['hex'] as String?;
              if (hex != null && hex.startsWith('6a')) {
                // Remove OP_RETURN opcode (6a) and length byte
                var data = hex.substring(4);
                return data;
              }
            }
          }
        }
      }
      return null;
    } catch (e) {
      _logger.e('Failed to extract OP_RETURN data: $e');
      return null;
    }
  }
  
  Future<Map<String, dynamic>?> _decodeMultisigData(String hexData) async {
    try {
      // Convert hex to bytes
      final bytes = <int>[];
      for (int i = 0; i < hexData.length; i += 2) {
        bytes.add(int.parse(hexData.substring(i, i + 2), radix: 16));
      }
      
      // Convert to UTF-8 string
      final utf8String = utf8.decode(bytes);
      
      // BitDrive format: metadata|content (both base64 encoded)
      if (!utf8String.contains('|')) {
        throw Exception('Invalid BitDrive format: missing pipe separator');
      }
      
      final parts = utf8String.split('|');
      if (parts.length != 2) {
        throw Exception('Invalid BitDrive format: expected metadata|content');
      }
      
      // Decode metadata (9 bytes)
      final metadataBytes = base64.decode(parts[0]);
      if (metadataBytes.length != 9) {
        throw Exception('Invalid metadata length: expected 9 bytes');
      }
      
      final metadata = ByteData.view(Uint8List.fromList(metadataBytes).buffer);
      final flags = metadata.getUint8(0);
      final isEncrypted = (flags & 0x01) != 0;
      final isMultisig = (flags & 0x02) != 0; // MULTISIG_FLAG = 0x02
      
      if (!isMultisig) {
        throw Exception('Transaction is not marked as multisig');
      }
      
      if (isEncrypted) {
        throw Exception('Multisig data is encrypted and cannot be imported');
      }
      
      // Decode content
      final contentBytes = base64.decode(parts[1]);
      final jsonString = utf8.decode(contentBytes);
      
      // Parse as JSON
      final jsonData = json.decode(jsonString);
      if (jsonData is Map<String, dynamic>) {
        return jsonData;
      }
      
      return null;
    } catch (e) {
      _logger.e('Failed to decode multisig data: $e');
      return null;
    }
  }
  
  Future<MultisigGroup> _createMultisigGroup(Map<String, dynamic> data, String txid) async {
    try {
      // Extract multisig configuration from decoded data
      final name = data['name'] as String? ?? 'Imported Multisig';
      final m = data['m'] as int? ?? data['threshold'] as int? ?? 2;
      final n = data['n'] as int? ?? data['total'] as int? ?? 3;
      final keysData = data['keys'] as List<dynamic>? ?? [];
      
      // Parse keys
      final keys = keysData.map((keyData) {
        if (keyData is Map<String, dynamic>) {
          return MultisigKey(
            xpub: keyData['xpub'] as String? ?? keyData['pubkey'] as String? ?? '',
            owner: keyData['owner'] as String? ?? 'Unknown',
            derivationPath: keyData['path'] as String? ?? keyData['derivation_path'] as String? ?? '',
            isWallet: false, // Imported keys are not wallet keys initially
            fingerprint: keyData['fingerprint'] as String?,
            originPath: keyData['origin_path'] as String? ?? keyData['originPath'] as String?,
          );
        }
        return MultisigKey(
          xpub: keyData.toString(),
          owner: 'Unknown',
          derivationPath: '',
          isWallet: false,
        );
      }).toList();
      
      if (keys.isEmpty) {
        throw Exception('No valid keys found in multisig data');
      }
      
      // Create unique ID based on keys and configuration
      final keyString = keys.map((k) => k.xpub).join('');
      final idHash = keyString.hashCode.abs().toString();
      final groupId = 'imported_${idHash.substring(0, 8)}';
      
      return MultisigGroup(
        id: groupId,
        name: name,
        n: n,
        m: m,
        keys: keys,
        created: DateTime.now().millisecondsSinceEpoch,
        txid: txid,
      );
      
    } catch (e) {
      _logger.e('Failed to create multisig group from data: $e');
      rethrow;
    }
  }
  
  Future<MultisigGroup> _checkAndUpdateWalletKeys(MultisigGroup group) async {
    try {
      // Load solo keys to check for matching wallet keys
      final soloKeys = await MultisigStorage.loadSoloKeys();
      
      final updatedKeys = <MultisigKey>[];
      
      for (final key in group.keys) {
        bool foundMatch = false;
        
        // Check against solo keys for matching xpub
        for (final soloKey in soloKeys) {
          if (soloKey['xpub'] == key.xpub) {
            // Found a matching wallet key, update the imported key
            final updatedKey = MultisigKey(
              xpub: key.xpub,
              owner: soloKey['owner'] ?? key.owner,
              derivationPath: soloKey['path'] ?? key.derivationPath,
              isWallet: true, // This key belongs to our wallet
              fingerprint: soloKey['fingerprint'] ?? key.fingerprint,
              originPath: soloKey['origin_path'] ?? key.originPath,
            );
            
            updatedKeys.add(updatedKey);
            foundMatch = true;
            
            _logger.i('Found matching wallet key in solo_keys: ${key.xpub.substring(0, 20)}...');
            break;
          }
        }
        
        if (!foundMatch) {
          // Keep the original key (external key)
          updatedKeys.add(key);
        }
      }
      
      // Update the group with the corrected keys
      return group.copyWith(keys: updatedKeys);
      
    } catch (e) {
      _logger.e('Error checking wallet keys: $e');
      // Return original group if error occurs
      return group;
    }
  }
}