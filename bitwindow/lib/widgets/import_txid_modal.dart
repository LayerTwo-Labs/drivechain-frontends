import 'dart:convert';
import 'dart:io';

import 'package:bitwindow/env.dart';
import 'package:bitwindow/providers/hd_wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
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
                    
                    // Loading status display
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
  final Logger _logger = GetIt.I.get<Logger>();
  final HDWalletProvider _hdWallet = GetIt.I.get<HDWalletProvider>();
  
  final txidController = TextEditingController();
  String? modalError;
  String? loadingStatus;
  
  // File logging for import debug output
  File? _importLogFile;
  
  @override
  void dispose() {
    txidController.dispose();
    super.dispose();
  }
  
  Future<void> _initImportLogging() async {
    try {
      // Create import_error.txt file in the project root directory (where we know we have write access)
      _importLogFile = File('/Users/marcplatt/Desktop/l2l-projects/drivechain-frontends/bitwindow/import_error.txt');
      
      // Clear previous content and add header
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
    // Also log to console for development
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
    
    // Initialize file logging
    await _initImportLogging();
    
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
      
      await _logToFile('Importing multisig from TXID: $txid');
      
      // Step 1: Fetch transaction data
      loadingStatus = 'Fetching transaction data...';
      notifyListeners();
      
      final opReturns = await _api.misc.listOPReturns();
      final opReturn = opReturns.firstWhere(
        (op) => op.txid == txid,
        orElse: () => throw Exception('No OP_RETURN data found for transaction'),
      );
      
      // Step 2: Parse transaction data
      loadingStatus = 'Parsing transaction data...';
      notifyListeners();
      
      // Parse the OP_RETURN message (BitDrive format: metadata|content)
      if (!opReturn.message.contains('|')) {
        modalError = 'Invalid OP_RETURN format - not a BitDrive transaction';
        return;
      }
      
      final parts = opReturn.message.split('|');
      if (parts.length != 2) {
        modalError = 'Invalid OP_RETURN format';
        return;
      }
      
      // Parse metadata (9 bytes)
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
      
      // Decode content
      final contentBytes = base64.decode(parts[1]);
      final jsonString = utf8.decode(contentBytes);
      final multisigData = json.decode(jsonString) as Map<String, dynamic>;
      
      // Add the TXID to the data
      multisigData['txid'] = txid;
      
      // Step 3: Validate wallet keys
      loadingStatus = 'Validating wallet keys...';
      notifyListeners();
      
      // Update is_wallet state for keys that can be derived by this wallet
      final walletKeyCount = await _updateWalletKeyStates(multisigData);
      
      // Prevent import if this wallet can't derive any of the keys
      final totalKeys = (multisigData['keys'] as List<dynamic>?)?.length ?? 0;
      if (walletKeyCount == 0) {
        modalError = 'Cannot import multisig: this wallet cannot derive any of the $totalKeys keys in the group. Import is only allowed if this wallet owns at least one key.';
        await _logToFile('IMPORT REJECTED: Wallet owns 0 out of $totalKeys keys');
        return;
      }
      
      await _logToFile('IMPORT APPROVED: Wallet can derive $walletKeyCount out of $totalKeys keys in this multisig group');
      
      // Step 4: Save to local storage
      loadingStatus = 'Saving multisig group...';
      notifyListeners();
      
      // Save directly to multisig.json file like BitDrive provider does
      await _saveMultisigToLocalFile(multisigData);
      
      // Restore transaction history for this group
      try {
        loadingStatus = 'Restoring transaction history...';
        notifyListeners();
        
        final groups = await MultisigStorage.loadGroups();
        final group = groups.firstWhere(
          (g) => g.id == multisigData['id'],
          orElse: () => throw Exception('Group not found after import'),
        );
        
        await _logToFile('Restoring transaction history for group: ${group.name}');
        await MultisigStorage.restoreTransactionHistory(group);
        await _logToFile('Transaction history restoration completed for group: ${group.name}');
      } catch (e) {
        await _logToFile('Failed to restore transaction history: $e');
        // Don't fail the whole import process if transaction history fails
      }
      
      // Clear loading status on success
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
      
      // Determine network type for proper derivation
      const isMainnet = String.fromEnvironment('BITWINDOW_NETWORK', defaultValue: 'signet') == 'mainnet';
      await _logToFile('Using ${isMainnet ? 'mainnet' : 'testnet/signet'} for key derivation');
      
      for (int i = 0; i < keys.length; i++) {
        final keyData = keys[i];
        
        if (keyData is Map<String, dynamic>) {
          final keyOwner = keyData['owner'] as String? ?? 'Key ${i + 1}';
          
          // Update progress for each key
          loadingStatus = 'Validating $keyOwner (${i + 1} of ${keys.length})...';
          notifyListeners();
          
          // Initialize as non-wallet key
          keyData['is_wallet'] = false;
          
          final xpubFromPayload = keyData['xpub'] as String?;
          final derivationPath = keyData['path'] as String?;
          
          if (xpubFromPayload != null && derivationPath != null) {
            try {
              await _logToFile('Processing key validation for ${keyData['owner']}');
              await _logToFile('Key xpub from TXID: $xpubFromPayload');
              await _logToFile('Key derivation path: $derivationPath');
              
              // Derive the key at the exact path specified in the payload
              await _logToFile('Deriving key at exact path: $derivationPath');
              final derivedKeyInfo = await _hdWallet.deriveExtendedKeyInfo(_hdWallet.mnemonic ?? '', derivationPath, isMainnet);
              
              if (derivedKeyInfo.isNotEmpty) {
                final derivedXpub = derivedKeyInfo['xpub'];
                
                if (derivedXpub == xpubFromPayload) {
                  // This wallet can derive this exact key at this exact path
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
      // Return 0 on error to prevent import
      return 0;
    }
    
    return walletKeyCount;
  }
  
  Future<void> _saveMultisigToLocalFile(Map<String, dynamic> multisigData) async {
    final appDir = await Environment.datadir();
    final bitdriveDir = path.join(appDir.path, 'bitdrive');
    final multisigDir = Directory(path.join(bitdriveDir, 'multisig'));
    await multisigDir.create(recursive: true);
    final file = File(path.join(bitdriveDir, 'multisig', 'multisig.json'));
    
    // Load existing data or create new structure
    Map<String, dynamic> jsonData = {
      'groups': [],
      'solo_keys': [],
    };
    
    if (await file.exists()) {
      final content = await file.readAsString();
      if (content.trim().isNotEmpty) {
        final decoded = json.decode(content);
        jsonData = decoded as Map<String, dynamic>;
      }
    }
    
    // Get groups array
    final groups = jsonData['groups'] as List<dynamic>;
    
    // Check if this multisig group already exists (by ID - the unique identifier)
    final groupId = multisigData['id'] as String?;
    
    if (groupId != null && groupId.isNotEmpty) {
      final existingIndex = groups.indexWhere((group) => group['id'] == groupId);
      
      if (existingIndex != -1) {
        // Update existing group (prevents duplicates from multiple restoration runs)
        groups[existingIndex] = multisigData;
      } else {
        // Add new group
        groups.add(multisigData);
      }
    } else {
      // No fallback to name-based checking - require ID
      throw Exception('Multisig group must have an ID');
    }
    
    // Save updated data - this is the single source of truth for multisig groups
    await file.writeAsString(json.encode(jsonData));
  }
}