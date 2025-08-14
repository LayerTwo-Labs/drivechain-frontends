import 'dart:convert';
import 'dart:io';

import 'package:bitwindow/models/multisig_group.dart';
import 'package:bitwindow/providers/hd_wallet_provider.dart';
import 'package:bitwindow/providers/multisig_provider.dart';
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
                    
                    if (viewModel.loadingStatus != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SailRow(
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SailText.secondary13(
                                viewModel.loadingStatus!,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
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
  final BitwindowRPC _api = GetIt.I.get<BitwindowRPC>();
  final HDWalletProvider _hdWallet = GetIt.I.get<HDWalletProvider>();
  Logger get _logger => GetIt.I.get<Logger>();
  
  final txidController = TextEditingController();
  String? modalError;
  String? loadingStatus;
  
  File? _importLogFile;
  
  Future<void> _createWatchWallet(String walletName, String descriptorReceive, String descriptorChange) async {
    try {
      await MultisigStorage.createMultisigWallet(walletName, descriptorReceive, descriptorChange);
    } catch (e) {
      await _logToFile('Failed to create watch wallet: $e');
      throw Exception('Failed to create watch wallet: $e');
    }
  }
  
  @override
  void dispose() {
    txidController.dispose();
    super.dispose();
  }
  
  Future<void> _initImportLogging() async {
    try {
      _importLogFile = File('/Users/marcplatt/Desktop/l2l-projects/drivechain-frontends/bitwindow/import_error.txt');
      
      final timestamp = DateTime.now().toIso8601String();
      await _importLogFile!.writeAsString(
        '=== Import Debug Log - $timestamp ===\n\n',
        mode: FileMode.write,
      );
      
      await _logToFile('Import logging initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize import logging: $e');
    }
  }
  
  Future<void> _logToFile(String message) async {
    if (_importLogFile != null) {
      try {
        final timestamp = DateTime.now().toIso8601String();
        await _importLogFile!.writeAsString(
          '[$timestamp] $message\n',
          mode: FileMode.append,
        );
      } catch (e) {
        _logger.e('Failed to write to import log file: $e');
      }
    }
    _logger.d(message);
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
    loadingStatus = null;
    
    await _initImportLogging();
    
    try {
      final txid = txidController.text.trim();
      if (txid.isEmpty) {
        modalError = 'Please enter a transaction ID';
        return;
      }
      
      if (txid.length != 64 || !RegExp(r'^[0-9a-fA-F]+$').hasMatch(txid)) {
        modalError = 'Invalid transaction ID format';
        return;
      }
      
      await _logToFile('Importing multisig from TXID: $txid');
      
      loadingStatus = 'Fetching transaction data...';
      notifyListeners();
      
      final opReturns = await _api.misc.listOPReturns();
      final opReturn = opReturns.firstWhere(
        (op) => op.txid == txid,
        orElse: () => throw Exception('No OP_RETURN data found for transaction'),
      );
      
      loadingStatus = 'Parsing transaction data...';
      notifyListeners();
      
      if (!opReturn.message.contains('|')) {
        modalError = 'Invalid OP_RETURN format - not a BitDrive transaction';
        return;
      }
      
      final parts = opReturn.message.split('|');
      if (parts.length != 2) {
        modalError = 'Invalid OP_RETURN format';
        return;
      }
      
      final metadataBytes = base64.decode(parts[0]);
      if (metadataBytes.length != 9) {
        modalError = 'Invalid metadata format';
        return;
      }
      
      final metadata = ByteData.view(Uint8List.fromList(metadataBytes).buffer);
      final flags = metadata.getUint8(0);
      final isEncrypted = (flags & 0x01) != 0;
      final isMultisig = (flags & 0x02) != 0; // MULTISIG_FLAG = 0x02
      
      if (!isMultisig) {
        modalError = 'Transaction is not marked as multisig';
        return;
      }
      
      if (isEncrypted) {
        modalError = 'Cannot import encrypted multisig data - encryption key required';
        return;
      }
      
      final contentBytes = base64.decode(parts[1]);
      final jsonString = utf8.decode(contentBytes);
      final multisigData = json.decode(jsonString) as Map<String, dynamic>;
      
      multisigData['txid'] = txid;
      
      loadingStatus = 'Validating wallet keys...';
      notifyListeners();
      
      final walletKeyCount = await _updateWalletKeyStates(multisigData);
      
      final totalKeys = (multisigData['keys'] as List<dynamic>?)?.length ?? 0;
      if (walletKeyCount == 0) {
        modalError = 'Cannot import multisig: this wallet cannot derive any of the $totalKeys keys in the group. Import is only allowed if this wallet owns at least one key.';
        await _logToFile('IMPORT REJECTED: Wallet owns 0 out of $totalKeys keys');
        return;
      }
      
      await _logToFile('IMPORT APPROVED: Wallet can derive $walletKeyCount out of $totalKeys keys in this multisig group');
      
      loadingStatus = 'Saving multisig group...';
      notifyListeners();
      
      await _saveMultisigToLocalFile(multisigData);
      
      try {
        loadingStatus = 'Setting up watch wallet...';
        notifyListeners();
        
        final groups = await MultisigStorage.loadGroups();
        final group = groups.firstWhere(
          (g) => g.id == multisigData['id'],
          orElse: () => throw Exception('Group not found after import'),
        );
        
        if (group.descriptorReceive != null && group.descriptorChange != null && group.watchWalletName != null) {
          await _logToFile('Creating watch wallet: ${group.watchWalletName}');
          await _createWatchWallet(group.watchWalletName!, group.descriptorReceive!, group.descriptorChange!);
          await _logToFile('Watch wallet created successfully');
        }
        
        loadingStatus = 'Restoring transaction history...';
        notifyListeners();
        
        await _logToFile('Restoring transaction history for group: ${group.name} (watchWallet: ${group.watchWalletName})');
        await MultisigStorage.restoreTransactionHistory(group);
        await _logToFile('Transaction history restoration completed for group: ${group.name}');
        
        loadingStatus = 'Syncing wallet balance and addresses...';
        notifyListeners();
        await _logToFile('Updating group balance and wallet state');
        await BalanceManager.updateGroupBalance(group);
        await _logToFile('Balance and wallet state updated successfully');
      } catch (e) {
        await _logToFile('Failed to restore transaction history: $e');
      }
      
      loadingStatus = null;
      await _logToFile('Successfully imported multisig group');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully imported multisig: ${multisigData['name'] ?? 'Unknown'}'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
      
    } catch (e) {
      await _logToFile('Failed to import from TXID: $e');
      _logger.e('Failed to import from TXID: $e');
      loadingStatus = null; // Clear loading status on error
      modalError = e.toString().contains('Multisig group must have an ID') 
          ? 'Invalid multisig data - missing group ID'
          : 'Import failed: ${e.toString()}';
    } finally {
      setBusy(false);
      loadingStatus = null; // Ensure loading status is cleared
      notifyListeners();
    }
  }
  
  Future<int> _updateWalletKeyStates(Map<String, dynamic> multisigData) async {
    int walletKeyCount = 0;
    
    try {
      await _logToFile('Updating is_wallet state for imported multisig keys');
      
      final keys = multisigData['keys'] as List<dynamic>? ?? [];
      
      if (keys.isEmpty) {
        await _logToFile('No keys found in multisig data');
        return 0;
      }
      
      const isMainnet = String.fromEnvironment('BITWINDOW_NETWORK', defaultValue: 'signet') == 'mainnet';
      await _logToFile('Using ${isMainnet ? 'mainnet' : 'testnet/signet'} for key derivation');
      
      for (int i = 0; i < keys.length; i++) {
        final keyData = keys[i];
        
        if (keyData is Map<String, dynamic>) {
          final keyOwner = keyData['owner'] as String? ?? 'Key ${i + 1}';
          
          loadingStatus = 'Validating $keyOwner (${i + 1} of ${keys.length})...';
          notifyListeners();
          
          keyData['is_wallet'] = false;
          
          final xpubFromPayload = keyData['xpub'] as String?;
          final derivationPath = keyData['path'] as String?;
          
          if (xpubFromPayload != null && derivationPath != null) {
            try {
              await _logToFile('Processing key validation for ${keyData['owner']}');
              await _logToFile('Key xpub from TXID: $xpubFromPayload');
              await _logToFile('Key derivation path: $derivationPath');
              
              await _logToFile('Deriving key at exact path: $derivationPath');
              final derivedKeyInfo = await _hdWallet.deriveExtendedKeyInfo(_hdWallet.mnemonic ?? '', derivationPath, isMainnet);
              
              if (derivedKeyInfo.isNotEmpty) {
                final derivedXpub = derivedKeyInfo['xpub'];
                
                if (derivedXpub == xpubFromPayload) {
                  keyData['is_wallet'] = true;
                  walletKeyCount++;
                  await _logToFile('✅ Key ${keyData['owner']} MATCHES - marked as wallet key');
                } else {
                  await _logToFile('❌ Key ${keyData['owner']} does not match - not a wallet key');
                  await _logToFile('  Expected: $xpubFromPayload');
                  await _logToFile('  Derived:  $derivedXpub');
                }
              } else {
                await _logToFile('❌ Failed to derive key info for ${keyData['owner']}');
              }
            } catch (e) {
              await _logToFile('❌ Failed to derive key for ${keyData['owner']}: $e');
            }
          } else {
            await _logToFile('❌ Key ${keyData['owner']} missing xpub or path data');
          }
        }
      }
      
      await _logToFile('Validation complete: $walletKeyCount out of ${keys.length} keys belong to this wallet');
      
    } catch (e) {
      await _logToFile('Error updating wallet key states: $e');
      return 0;
    }
    
    return walletKeyCount;
  }
  
  Future<void> _saveMultisigToLocalFile(Map<String, dynamic> multisigData) async {
    await _logToFile('Using atomic MultisigStorage operations for safe file writing');
    
    final importedGroup = MultisigGroup.fromJson(multisigData);
    
    final existingGroups = await MultisigStorage.loadGroups();
    
    final existingIndex = existingGroups.indexWhere((g) => g.id == importedGroup.id);
    
    List<MultisigGroup> updatedGroups;
    if (existingIndex != -1) {
      await _logToFile('Updating existing group: ${importedGroup.name}');
      updatedGroups = List<MultisigGroup>.from(existingGroups);
      updatedGroups[existingIndex] = importedGroup;
    } else {
      await _logToFile('Adding new group: ${importedGroup.name}');
      updatedGroups = [...existingGroups, importedGroup];
    }
    
    await MultisigStorage.saveGroups(updatedGroups);
    await _logToFile('Successfully saved group using atomic MultisigStorage operation');
  }
}