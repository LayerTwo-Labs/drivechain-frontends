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

  @override
  void dispose() {
    _psbtController.dispose();
    _txIdController.dispose();
    super.dispose();
  }

  Future<void> _pickAndLoadPSBTFile() async {
    try {
      setState(() {
        _modalError = null;
      });

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
          
          if (!data.containsKey('transaction_id') || !data.containsKey('psbt')) {
            throw Exception('Invalid PSBT export format');
          }
          
          setState(() {
            _importedData = data;
            _selectedFileName = result.files.single.name;
            _txIdController.text = data['transaction_id'] ?? '';
            _psbtController.text = data['psbt'] ?? '';
          });
          
        } catch (e) {
          setState(() {
            _modalError = 'Invalid JSON format: $e';
          });
        }
      }
    } catch (e) {
      setState(() {
        _modalError = 'Failed to load file: $e';
      });
    }
  }

  Future<MultisigKey?> _findTargetKey(MultisigGroup group, String keyOwner, int? derivationIndex) async {
    if (derivationIndex != null) {
      final walletDerivedXpub = await _getDerivedXpubAtPath(derivationIndex);
      if (walletDerivedXpub != null) {
        final matchingKey = group.keys.where((k) => k.xpub == walletDerivedXpub).firstOrNull;
        if (matchingKey != null) {
          return matchingKey;
        }
        
        final derivedKey = await _rederiveAndStoreMissingKey(derivationIndex, keyOwner);
        if (derivedKey != null) {
          group.keys.add(derivedKey);
          return derivedKey;
        }
      }
    }
    
    final candidates = group.keys.where((k) => k.owner == keyOwner).toList();
    if (candidates.isNotEmpty) {
      return candidates.firstWhere(
        (k) => k.isWallet,
        orElse: () => candidates.first,
      );
    }
    
    return null;
  }

  Future<String?> _getDerivedXpubAtPath(int derivationIndex) async {
    try {
      if (!_hdWallet.isInitialized) {
        await _hdWallet.init();
      }
      
      bool isMainnet = false;
      final keyInfo = await _hdWallet.generateWalletXpub(derivationIndex, isMainnet);
      
      return keyInfo['xpub'];
    } catch (e) {
      return null;
    }
  }

  Future<MultisigKey?> _rederiveAndStoreMissingKey(int derivationIndex, String keyOwner) async {
    try {
      if (!_hdWallet.isInitialized) {
        await _hdWallet.init();
      }
      
      bool isMainnet = false;
      
      final keyInfo = await _hdWallet.generateWalletXpub(derivationIndex, isMainnet);
      
      if (keyInfo.isEmpty || keyInfo['xpub'] == null) {
        throw Exception('Failed to derive key at index $derivationIndex');
      }
      
      final multisigKey = MultisigKey(
        owner: keyOwner,
        xpub: keyInfo['xpub']!,
        derivationPath: keyInfo['derivation_path'] ?? "m/84'/1'/$derivationIndex'",
        fingerprint: keyInfo['fingerprint'],
        originPath: keyInfo['origin_path'],
        isWallet: true,
      );
      
      final soloKeys = await MultisigStorage.loadSoloKeys();
      final existingKeyIndex = soloKeys.indexWhere((key) => key['xpub'] == multisigKey.xpub);
      
      if (existingKeyIndex == -1) {
        await MultisigStorage.addSoloKey(multisigKey.toJson());
      }
      
      return multisigKey;
      
    } catch (e) {
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

    try {
      final cleanPsbt = _psbtController.text.replaceAll(RegExp(r'\s'), '');

      final decodedPsbt = await _rpc.callRAW('decodepsbt', [cleanPsbt]);
      if (decodedPsbt is! Map) {
        throw Exception('Invalid PSBT format');
      }

      final groups = await MultisigStorage.loadGroups();
      final group = groups.firstWhere(
        (g) => g.id == _selectedGroupId,
        orElse: () => throw Exception('Group not found'),
      );

      final validationResult = await PSBTValidator.validatePSBT(
        psbtBase64: cleanPsbt,
        group: group,
        keyId: 'import_validation',
      );
      
      if (!validationResult.isValid) {
        throw Exception('PSBT validation failed: ${validationResult.errors.join(', ')}');
      }
      
      final isSigned = validationResult.isSigned;

      String? keyOwner = _importedData?['key_owner'];
      int? derivationIndex = _importedData?['derivation_index'];

      final txId = _txIdController.text.trim();
      
      var existingTx = await TransactionStorage.getTransaction(txId);

      if (keyOwner == null) {
        throw Exception('key_owner is required in PSBT import data');
      }
      
      MultisigKey? targetKey = await _findTargetKey(group, keyOwner, derivationIndex);
      if (targetKey == null) {
        throw Exception('Could not find or derive key for $keyOwner');
      }

      if (existingTx == null) {
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

        final keyPSBTs = group.keys.map((key) => KeyPSBTStatus(
          keyId: key.xpub,
          psbt: null,
          isSigned: false,
          signedAt: null,
        ),).toList();
        
        final newTx = MultisigTransaction(
          id: txId,
          groupId: _selectedGroupId!,
          initialPSBT: cleanPsbt,
          status: TxStatus.needsSignatures,
          type: TxType.withdrawal,
          created: DateTime.now(),
          amount: amount,
          destination: destination,
          fee: 0.0001,
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
      }

      if (isSigned) {
        await TransactionStorage.addOrUpdateKeyPSBT(
          txId,
          targetKey.xpub,
          cleanPsbt,
          true,
          signatureThreshold: group.m,
        );
      } else {
        final allRelevantKeys = <MultisigKey>[];
        
        final walletKeys = group.keys.where((k) => k.isWallet).toList();
        allRelevantKeys.addAll(walletKeys);
        
        if (!targetKey.isWallet && !allRelevantKeys.any((k) => k.xpub == targetKey.xpub)) {
          allRelevantKeys.add(targetKey);
        }
        
        final existingTx = await TransactionStorage.getTransaction(txId);
        
        for (final key in allRelevantKeys) {
          bool shouldSkip = false;
          if (existingTx != null) {
            final existingKeyPSBT = existingTx.keyPSBTs.where((kp) => kp.keyId == key.xpub).firstOrNull;
            if (existingKeyPSBT != null && existingKeyPSBT.isSigned) {
              shouldSkip = true;
            }
          }
          
          if (!shouldSkip) {
            await TransactionStorage.addOrUpdateKeyPSBT(
              txId,
              key.xpub,
              cleanPsbt,
              false,
              signatureThreshold: group.m,
            );
          }
        }
      }

      final finalTx = await TransactionStorage.getTransaction(txId);
      if (finalTx != null) {
        final signedCount = finalTx.keyPSBTs.where((kp) => kp.isSigned).length;
        
        if (signedCount >= group.m) {
          await TransactionStatusManager.updateTransactionStatus(
            transactionId: txId,
            newStatus: TxStatus.readyForBroadcast,
            reason: 'Sufficient signatures imported',
          );
        } else {
          await TransactionStatusManager.updateTransactionStatus(
            transactionId: txId,
            newStatus: TxStatus.needsSignatures,
            reason: 'Insufficient signatures',
          );
        }
      }

      final allGroups = await MultisigStorage.loadGroups();
      final existingIndex = allGroups.indexWhere((g) => g.id == group.id);
      
      if (existingIndex != -1) {
        allGroups[existingIndex] = group;
      } else {
        allGroups.add(group);
      }
      
      await MultisigStorage.saveGroups(allGroups);
      
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
      _logger.e('Failed to import PSBT: $e');
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
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
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
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedFileName != null 
                            ? Colors.green.withValues(alpha: 0.5)
                            : Colors.grey.withValues(alpha: 0.3),
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: _selectedFileName != null
                          ? Colors.green.withValues(alpha: 0.05)
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
                                  ? context.sailTheme.colors.success
                                  : context.sailTheme.colors.textSecondary,
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
                  
                  if (_importedData != null) ...[
                    Container(
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