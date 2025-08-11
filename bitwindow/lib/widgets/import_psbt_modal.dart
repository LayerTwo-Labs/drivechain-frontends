import 'dart:convert';
import 'dart:io';

import 'package:bitwindow/models/multisig_group.dart';
import 'package:bitwindow/models/multisig_transaction.dart';
import 'package:bitwindow/providers/hd_wallet_provider.dart';
import 'package:bitwindow/providers/multisig_provider.dart';
import 'package:bitwindow/widgets/create_multisig_modal.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

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
  String? _modalError;
  String? _selectedFileName;
  Map<String, dynamic>? _importedData;
  MainchainRPC get _rpc => GetIt.I.get<MainchainRPC>();
  Logger get _logger => GetIt.I.get<Logger>();
  HDWalletProvider get _hdWallet => GetIt.I.get<HDWalletProvider>();
  
  // File logging for import debug output
  File? _importLogFile;

  @override
  void dispose() {
    _psbtController.dispose();
    _txIdController.dispose();
    super.dispose();
  }
  
  Future<void> _initImportLogging() async {
    try {
      // Create import_error.txt file in the project root directory (where we know we have write access)
      _importLogFile = File('/Users/marcplatt/Desktop/l2l-projects/drivechain-frontends/bitwindow/import_error.txt');
      
      // Append to existing content with header
      final timestamp = DateTime.now().toIso8601String();
      await _importLogFile!.writeAsString(
        '\n=== PSBT Import Debug Log - $timestamp ===\n\n',
        mode: FileMode.append,
      );
      
      await _logToFile('PSBT import logging initialized successfully');
    } catch (e) {
      // Can't log to file if initialization failed, use console
      print('Failed to initialize import logging: $e');
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
        // If file logging fails, at least print to console
        print('Failed to write to import log file: $e');
      }
    }
    // Also log to console for development
    print('[PSBT-IMPORT] $message');
  }

  Future<void> _pickAndLoadPSBTFile() async {
    try {
      setState(() {
        _modalError = null;
      });

      // Open file picker for JSON files
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        dialogTitle: 'Select PSBT Export File',
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        
        try {
          final data = json.decode(jsonString) as Map<String, dynamic>;
          
          // Validate the JSON structure
          if (!data.containsKey('transaction_id') || !data.containsKey('psbt')) {
            throw Exception('Invalid PSBT export format');
          }
          
          setState(() {
            _importedData = data;
            _selectedFileName = result.files.single.name;
            _txIdController.text = data['transaction_id'] ?? '';
            _psbtController.text = data['psbt'] ?? '';
          });
          
          await _logToFile('Loaded PSBT file: $_selectedFileName');
          await _logToFile('Transaction ID: ${data['transaction_id']}');
          await _logToFile('Is signed: ${data['is_signed']}');
          await _logToFile('Key owner: ${data['key_owner']}');
          
        } catch (e) {
          setState(() {
            _modalError = 'Invalid JSON format: $e';
          });
        }
      }
    } catch (e) {
      await _logToFile('Failed to pick PSBT file: $e');
      setState(() {
        _modalError = 'Failed to load file: $e';
      });
    }
  }

  /// Find the target key for PSBT import, with fallback to re-derivation if needed
  Future<MultisigKey?> _findTargetKey(MultisigGroup group, String keyOwner, int? derivationIndex) async {
    MultisigKey? targetKey;
    
    if (derivationIndex != null) {
      // Match by exact derivation path, prioritizing wallet keys over imported keys
      try {
        final candidates = group.keys.where(
          (k) => k.derivationPath.contains("$derivationIndex'") ||
                 k.derivationPath.contains('/$derivationIndex/') ||
                 k.owner == keyOwner,
        ).toList();
        
        if (candidates.isNotEmpty) {
          // Prioritize wallet keys (isWallet=true) over imported keys
          targetKey = candidates.firstWhere(
            (k) => k.isWallet,
            orElse: () => candidates.first,
          );
          await _logToFile('Found target key by derivation index: ${targetKey.owner} with path: ${targetKey.derivationPath} (isWallet=${targetKey.isWallet})');
        } else {
          throw Exception('No matching keys found');
        }
      } catch (e) {
        await _logToFile('Could not find key by derivation index $derivationIndex, trying by owner name');
        try {
          final candidates = group.keys.where((k) => k.owner == keyOwner).toList();
          if (candidates.isNotEmpty) {
            // Prioritize wallet keys over imported keys
            targetKey = candidates.firstWhere(
              (k) => k.isWallet,
              orElse: () => candidates.first,
            );
            await _logToFile('Found target key by owner name: ${targetKey.owner} (isWallet=${targetKey.isWallet})');
          } else {
            throw Exception('No keys with owner $keyOwner');
          }
        } catch (e2) {
          await _logToFile('Could not find key by owner $keyOwner, attempting to re-derive key');
          // Try to re-derive the missing key
          targetKey = await _rederiveAndStoreMissingKey(derivationIndex, keyOwner);
          if (targetKey != null) {
            // Add the re-derived key to the group so it's available for signing
            group.keys.add(targetKey);
            await _logToFile('Successfully re-derived and added key: ${targetKey.owner}');
          } else {
            await _logToFile('Failed to re-derive key');
          }
        }
      }
    } else {
      // Match by owner name only, prioritizing wallet keys
      try {
        final candidates = group.keys.where((k) => k.owner == keyOwner).toList();
        if (candidates.isNotEmpty) {
          // Prioritize wallet keys over imported keys
          targetKey = candidates.firstWhere(
            (k) => k.isWallet,
            orElse: () => candidates.first,
          );
          await _logToFile('Found target key by owner name: ${targetKey.owner} (isWallet=${targetKey.isWallet})');
        } else {
          throw Exception('No keys with owner $keyOwner');
        }
      } catch (e) {
        await _logToFile('Could not find key by owner $keyOwner');
      }
    }
    
    return targetKey;
  }

  /// Re-derive and store a missing solo key for the specified derivation index
  Future<MultisigKey?> _rederiveAndStoreMissingKey(int derivationIndex, String keyOwner) async {
    try {
      await _logToFile('Re-deriving missing key for $keyOwner at derivation index $derivationIndex');
      
      // Ensure HD wallet is initialized
      if (!_hdWallet.isInitialized) {
        await _hdWallet.init();
      }
      
      // Use the SAME network setting as key generation - always testnet/false for now
      // This matches the hardcoded 'false' in multisig_key_modal.dart line 208
      bool isMainnet = false;
      
      // Use the SAME method as key generation to derive the key
      final keyInfo = await _hdWallet.generateWalletXpub(derivationIndex, isMainnet);
      
      if (keyInfo.isEmpty || keyInfo['xpub'] == null) {
        throw Exception('Failed to derive key at index $derivationIndex');
      }
      
      // Create the MultisigKey object
      final multisigKey = MultisigKey(
        owner: keyOwner,
        xpub: keyInfo['xpub']!,
        derivationPath: keyInfo['derivation_path'] ?? "m/84'/1'/$derivationIndex'",
        fingerprint: keyInfo['fingerprint'],
        originPath: keyInfo['origin_path'],
        isWallet: true, // This is a wallet-derived key
      );
      
      // Check if this key already exists
      final soloKeys = await MultisigStorage.loadSoloKeys();
      final existingKeyIndex = soloKeys.indexWhere((key) => key['xpub'] == multisigKey.xpub);
      
      if (existingKeyIndex != -1) {
        await _logToFile('Key already exists in solo keys: $keyOwner');
      } else {
        // Add new key
        await MultisigStorage.addSoloKey(multisigKey.toJson());
        await _logToFile('Added new solo key: $keyOwner');
      }
      
      await _logToFile('Successfully re-derived and stored key $keyOwner with xpub: ${multisigKey.xpub.substring(0, 20)}...');
      
      return multisigKey;
      
    } catch (e) {
      await _logToFile('Failed to re-derive key for $keyOwner at index $derivationIndex: $e');
      return null;
    }
  }

  Future<void> _importPSBT() async {
    if (_selectedGroupId == null ||
        _txIdController.text.isEmpty ||
        _psbtController.text.isEmpty) {
      setState(() {
        _modalError = 'Please select a file and choose a group';
      });
      return;
    }

    setState(() {
      _isImporting = true;
      _modalError = null;
    });

    // Initialize file logging
    await _initImportLogging();

    try {
      final cleanPsbt = _psbtController.text.replaceAll(RegExp(r'\s'), '');

      // Decode and analyze PSBT
      final decodedPsbt = await _rpc.callRAW('decodepsbt', [cleanPsbt]);
      if (decodedPsbt is! Map) {
        throw Exception('Invalid PSBT format');
      }

      final analyzePsbt = await _rpc.callRAW('analyzepsbt', [cleanPsbt]);
      if (analyzePsbt is! Map) {
        throw Exception('Failed to analyze PSBT');
      }
      
      await _logToFile('PSBT analysis result: $analyzePsbt');

      // Get the group first - needed for proper validation logic
      final groups = await MultisigStorage.loadGroups();
      final group = groups.firstWhere(
        (g) => g.id == _selectedGroupId,
        orElse: () => throw Exception('Group not found'),
      );
      await _logToFile('Loaded group ${group.name} with ${group.keys.length} keys (${group.m}-of-${group.n} multisig)');

      // Determine if PSBT is actually signed by analyzing the RPC response
      bool isSigned = false;
      bool isComplete = false;
      
      // Check if the PSBT has any inputs that are finalized or have signatures
      final inputs = analyzePsbt['inputs'] as List<dynamic>? ?? [];
      for (final input in inputs) {
        if (input is Map<String, dynamic>) {
          final isInputFinal = input['is_final'] as bool? ?? false;
          final missing = input['missing'] as Map<String, dynamic>?;
          final missingSignatures = missing?['signatures'] as List<dynamic>? ?? [];
          
          // According to Bitcoin Core analyzepsbt docs, we need to check:
          // - is_final: input is completely signed
          // - missing.signatures: list of missing signature hashes
          final totalMissing = missingSignatures.length;
          
          // Look for evidence this is a multisig input
          final hasRedeemScript = missing?.containsKey('redeemscript') == true;
          final hasWitnessScript = missing?.containsKey('witnessscript') == true;
          
          // For multisig detection, we need to consider:
          // 1. Traditional multisig (has redeemscript/witnessscript)  
          // 2. Native segwit multisig (can have any number of missing signatures)
          // Since we know this is a multisig group, assume all inputs are multisig
          final isMultisig = hasRedeemScript || hasWitnessScript || group.n > 1;
          
          // For any m-of-n multisig setup:
          // - If unsigned: missing m signatures (all required signatures missing)
          // - If partially signed: missing < m signatures (some signatures present)
          // - If fully signed: missing 0 signatures (and is_final=true)
          bool hasSomeSignatures = false;
          
          if (isMultisig) {
            // This is a multisig - check if we have partial signatures
            // For m-of-n: if missing fewer than m signatures, then some signatures are present
            final requiredSignatures = group.m;
            hasSomeSignatures = totalMissing < requiredSignatures;
            await _logToFile('Multisig validation: required=$requiredSignatures, missing=$totalMissing, has_some=$hasSomeSignatures');
          } else {
            // Single sig - either fully signed or not
            hasSomeSignatures = totalMissing == 0;
          }
          
          await _logToFile('PSBT input analysis (import): is_final=$isInputFinal, missing_count=$totalMissing, has_redeem=$hasRedeemScript, has_witness=$hasWitnessScript, is_multisig=$isMultisig, has_some_sigs=$hasSomeSignatures');
          
          if (isInputFinal || hasSomeSignatures) {
            isSigned = true;
          }
          
          await _logToFile('Input analysis: is_final=$isInputFinal, missing_signatures=${missingSignatures.length}');
        }
      }
      
      // Check overall completion status
      final nextRole = analyzePsbt['next'] as String?;
      isComplete = (nextRole == 'extractor' || nextRole == null);
      
      await _logToFile('PSBT validation: isSigned=$isSigned, isComplete=$isComplete, nextRole=$nextRole');
      
      // Override the imported flag with RPC analysis results
      final importedIsSigned = _importedData?['is_signed'] ?? false;
      if (importedIsSigned != isSigned) {
        await _logToFile('WARNING: Import flag (is_signed=$importedIsSigned) differs from RPC analysis (isSigned=$isSigned). Using RPC result.');
      }
      
      // Debug: Log all keys and their isWallet status
      for (int i = 0; i < group.keys.length; i++) {
        final key = group.keys[i];
        await _logToFile('Key $i: ${key.owner} - isWallet=${key.isWallet} - path=${key.derivationPath}');
      }

      // Extract key owner info if available
      String? keyOwner = _importedData?['key_owner'];
      int? keyIndex;
      int? derivationIndex; // The actual index used in derivation path (8000+N)
      
      if (keyOwner != null && keyOwner.contains('MyKey')) {
        // Extract the number from "MyKey2" format
        final match = RegExp(r'MyKey(\d+)').firstMatch(keyOwner);
        if (match != null) {
          keyIndex = int.tryParse(match.group(1) ?? '');
          if (keyIndex != null) {
            derivationIndex = 8000 + keyIndex; // Convert to actual derivation index
            await _logToFile('Extracted key index: $keyIndex from $keyOwner, derivation index: $derivationIndex');
          }
        }
      }

      final txId = _txIdController.text.trim();
      
      // Check if transaction already exists (double-check for race conditions)
      var existingTx = await TransactionStorage.getTransaction(txId);

      // Find the target key first (needed for both create and update operations)
      if (keyOwner == null) {
        throw Exception('key_owner is required in PSBT import data');
      }
      
      MultisigKey? targetKey = await _findTargetKey(group, keyOwner, derivationIndex);
      if (targetKey == null) {
        throw Exception('Could not find or derive key for $keyOwner');
      }
      
      await _logToFile('Target key ${targetKey.owner} has isWallet=${targetKey.isWallet}');

      if (existingTx == null) {
        await _logToFile('Creating new transaction: $txId');
        
        // Parse transaction details from PSBT
        final tx = decodedPsbt['tx'] as Map<String, dynamic>;
        final outputs = tx['vout'] as List<dynamic>;
        final inputs = tx['vin'] as List<dynamic>? ?? [];

        double amount = 0.0;
        String destination = '';
        
        if (outputs.isNotEmpty) {
          final firstOutput = outputs.first as Map<String, dynamic>;
          amount = (firstOutput['value'] as num).toDouble();
          final scriptPubKey = firstOutput['scriptPubKey'] as Map<String, dynamic>;
          destination = scriptPubKey['address'] as String? ?? 'Unknown';
        }

        // Initialize keyPSBTs for all group keys
        // When importing a signed PSBT without an existing transaction:
        // - Only the signing key gets a PSBT entry (the signed one)
        // - Other keys get null PSBTs since we don't have the unsigned version
        final keyPSBTs = group.keys.map((key) => KeyPSBTStatus(
          keyId: key.xpub,
          psbt: null, // Will be set for the signing key only
          isSigned: false, // Will be updated for the signing key below
          signedAt: null,
        ),).toList();
        
        // Create new transaction
        final newTx = MultisigTransaction(
          id: txId,
          groupId: _selectedGroupId!,
          initialPSBT: cleanPsbt,
          status: TxStatus.needsSignatures,
          created: DateTime.now(),
          amount: amount,
          destination: destination,
          fee: 0.0001, // Default fee, will be updated later
          inputs: inputs.map((input) => UtxoInfo(
            txid: input['txid'] ?? '',
            vout: input['vout'] ?? 0,
            amount: 0.0,
            confirmations: 0,
            address: '',
          ),).toList(),
          keyPSBTs: keyPSBTs,
        );

        await TransactionStorage.saveTransaction(newTx);
        await _logToFile('Created new transaction with ${keyPSBTs.length} keyPSBT entries');
      }

      // Associate PSBT with the target key (works for both new and existing transactions)
      if (isSigned) {
        // For signed PSBTs, only associate with the signing key
        await TransactionStorage.addOrUpdateKeyPSBT(
          txId,
          targetKey.xpub,
          cleanPsbt,
          true,
          signatureThreshold: group.m,
        );
        await _logToFile('Associated signed PSBT with key: ${targetKey.owner} (isWallet: ${targetKey.isWallet})');
      } else {
        // For unsigned PSBTs, associate with ALL keys that should have access to sign it
        final allRelevantKeys = <MultisigKey>[];
        
        // Add all wallet keys
        final walletKeys = group.keys.where((k) => k.isWallet).toList();
        allRelevantKeys.addAll(walletKeys);
        
        // Add the importing key if it's not already included (and not a wallet key)
        if (!targetKey.isWallet && !allRelevantKeys.any((k) => k.xpub == targetKey.xpub)) {
          allRelevantKeys.add(targetKey);
        }
        
        await _logToFile('Associating unsigned PSBT with ${allRelevantKeys.length} keys (${walletKeys.length} wallet, ${allRelevantKeys.length - walletKeys.length} external)');
        
        // Get existing transaction to check for already signed PSBTs
        final existingTx = await TransactionStorage.getTransaction(txId);
        
        for (final key in allRelevantKeys) {
          // Check if this key already has a signed PSBT - if so, don't overwrite it
          bool shouldSkip = false;
          if (existingTx != null) {
            final existingKeyPSBT = existingTx.keyPSBTs.where((kp) => kp.keyId == key.xpub).firstOrNull;
            if (existingKeyPSBT != null && existingKeyPSBT.isSigned) {
              await _logToFile('Skipping key ${key.owner} - already has signed PSBT');
              shouldSkip = true;
            }
          }
          
          if (!shouldSkip) {
            await TransactionStorage.addOrUpdateKeyPSBT(
              txId,
              key.xpub,
              cleanPsbt,
              false, // All unsigned initially
              signatureThreshold: group.m,
            );
            await _logToFile('Associated unsigned PSBT with key: ${key.owner} (isWallet=${key.isWallet})');
          }
        }
      }

      // Re-calculate signature count and update transaction status
      final finalTx = await TransactionStorage.getTransaction(txId);
      if (finalTx != null) {
        final signedCount = finalTx.keyPSBTs.where((kp) => kp.isSigned).length;
        await _logToFile('Final transaction has $signedCount/${group.m} signatures');
        
        if (signedCount >= group.m) {
          await TransactionStorage.updateTransactionStatus(
            txId,
            TxStatus.readyForBroadcast,
          );
          await _logToFile('Transaction ready for broadcast');
        } else {
          // Ensure status is correct for partial signatures
          await TransactionStorage.updateTransactionStatus(
            txId,
            TxStatus.needsSignatures,
          );
          await _logToFile('Transaction needs more signatures');
        }
      }

      // Update multisig.json if needed
      await MultisigStorage.saveGroup(group);
      
      widget.onImportSuccess();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'PSBT imported successfully${isSigned ? ' (signed)' : ' (unsigned)'}',),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      await _logToFile('Failed to import PSBT: $e');
      if (mounted) {
        setState(() => _modalError = 'Failed to import PSBT: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show PSBT import form after group selection
    if (_selectedGroupId != null) {
      final selectedGroup =
          widget.availableGroups.firstWhere((g) => g.id == _selectedGroupId);
      return Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
          child: SailCard(
            title: 'Import PSBT',
            subtitle:
                'Import a partially signed Bitcoin transaction for ${selectedGroup.name}',
            error: _modalError,
            child: SingleChildScrollView(
              child: SailColumn(
                spacing: SailStyleValues.padding16,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Show selected group info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: SailRow(
                      children: [
                        Expanded(
                          child: SailColumn(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: SailStyleValues.padding04,
                            children: [
                              SailText.primary13(
                                  'Selected Group: ${selectedGroup.name}',),
                              SailText.secondary12(
                                  '${selectedGroup.m} of ${selectedGroup.n} multisig',),
                            ],
                          ),
                        ),
                        SailButton(
                          label: 'Change',
                          onPressed: () async {
                            setState(() => _selectedGroupId = null);
                          },
                          variant: ButtonVariant.ghost,
                          small: true,
                        ),
                      ],
                    ),
                  ),
                  // File picker section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedFileName != null 
                            ? Colors.green.withOpacity(0.5)
                            : Colors.grey.withOpacity(0.3),
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: _selectedFileName != null
                          ? Colors.green.withOpacity(0.05)
                          : null,
                    ),
                    child: SailColumn(
                      spacing: SailStyleValues.padding12,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SailRow(
                          children: [
                            Icon(
                              _selectedFileName != null 
                                  ? Icons.check_circle
                                  : Icons.upload_file,
                              color: _selectedFileName != null 
                                  ? Colors.green
                                  : Colors.grey,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: SailColumn(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: SailStyleValues.padding04,
                                children: [
                                  SailText.primary13(
                                    _selectedFileName ?? 'No file selected',
                                  ),
                                  if (_selectedFileName == null)
                                    SailText.secondary12(
                                      'Select a JSON file containing the PSBT export',
                                    )
                                  else if (_importedData != null) ...[
                                    SailText.secondary12(
                                      'Transaction: ${_importedData!['transaction_id']}',
                                    ),
                                    SailText.secondary12(
                                      'Status: ${_importedData!['is_signed'] == true ? 'Signed' : 'Unsigned'}',
                                    ),
                                    if (_importedData!['key_owner'] != null)
                                      SailText.secondary12(
                                        'Key: ${_importedData!['key_owner']}',
                                      ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        SailButton(
                          label: _selectedFileName != null 
                              ? 'Choose Different File'
                              : 'Choose File',
                          onPressed: _isImporting ? null : _pickAndLoadPSBTFile,
                          variant: _selectedFileName != null 
                              ? ButtonVariant.secondary
                              : ButtonVariant.primary,
                        ),
                      ],
                    ),
                  ),
                  
                  // Show parsed data info if available
                  if (_importedData != null) ...[
                    Container(
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
                          SailText.primary12('Import Details:'),
                          if (_importedData!['exported_at'] != null)
                            SailText.secondary12(
                              'Exported: ${_importedData!['exported_at']}',
                            ),
                        ],
                      ),
                    ),
                  ],
                  SailRow(
                    mainAxisAlignment: MainAxisAlignment.end,
                    spacing: SailStyleValues.padding08,
                    children: [
                      SailButton(
                        label: 'Cancel',
                        onPressed: _isImporting
                            ? null
                            : () async {
                                Navigator.of(context).pop(false);
                              },
                        variant: ButtonVariant.ghost,
                      ),
                      SailButton(
                        label: 'Import',
                        onPressed: _isImporting || _importedData == null
                            ? null
                            : _importPSBT,
                        loading: _isImporting,
                        disabled: _importedData == null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Show group selection
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
        child: SailCard(
          title: 'Select Multisig Group',
          subtitle: 'Choose which group this PSBT belongs to',
          error: _modalError,
          child: SingleChildScrollView(
            child: SailColumn(
              spacing: SailStyleValues.padding16,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.availableGroups.isEmpty)
                  SailText.secondary12('No multisig groups available')
                else
                  ...widget.availableGroups.map(
                    (group) => SailCard(
                      shadowSize: ShadowSize.none,
                      child: SailRow(
                        children: [
                          Expanded(
                            child: SailColumn(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: SailStyleValues.padding04,
                              children: [
                                SailText.primary13(group.name),
                                SailText.secondary12(
                                    '${group.m} of ${group.n} multisig',),
                                SailText.secondary12(
                                    'Balance: ${group.balance.toStringAsFixed(8)} BTC',),
                              ],
                            ),
                          ),
                          const SizedBox(width: SailStyleValues.padding16),
                          SailButton(
                            label: 'Select Group',
                            onPressed: () async => setState(() => _selectedGroupId = group.id),
                            variant: ButtonVariant.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                SailButton(
                  label: 'Cancel',
                  onPressed: () async {
                    Navigator.of(context).pop(false);
                  },
                  variant: ButtonVariant.ghost,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
