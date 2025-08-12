import 'dart:convert';
import 'dart:io';

import 'package:bitwindow/env.dart';
import 'package:bitwindow/providers/hd_wallet_provider.dart';
import 'package:bitwindow/providers/multisig_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class MultisigKeyModal extends StatelessWidget {
  const MultisigKeyModal({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MultisigKeyModalViewModel>.reactive(
      viewModelBuilder: () => MultisigKeyModalViewModel(),
      onViewModelReady: (model) => model.init(),
      builder: (context, viewModel, child) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
            child: SailCard(
              title: 'Get Multisig Key',
              subtitle: 'Your next available key for multisig wallet creation',
              error: viewModel.modalError,
              child: SingleChildScrollView(
                child: SailColumn(
                  spacing: SailStyleValues.padding16,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (viewModel.isBusy)
                      const Center(child: CircularProgressIndicator())
                    else if (viewModel.keyInfo != null) ...[
                      SailText.primary15('Your Multisig Key Information:'),
                      const SizedBox(height: 16),
                      SailTextField(
                        label: 'Key Index',
                        hintText: 'Key index',
                        controller: TextEditingController(text: viewModel.keyInfo!['index'].toString()),
                        readOnly: true,
                        suffixWidget: CopyButton(
                          text: viewModel.keyInfo!['index'].toString(),
                        ),
                      ),
                      SailTextField(
                        label: 'Derivation Path',
                        hintText: 'Derivation path',
                        controller: TextEditingController(text: viewModel.keyInfo!['path']),
                        readOnly: true,
                        suffixWidget: CopyButton(
                          text: viewModel.keyInfo!['path'],
                        ),
                      ),
                      SailTextField(
                        label: 'Extended Public Key (xpub)',
                        hintText: 'Extended public key',
                        controller: TextEditingController(text: viewModel.keyInfo!['xpub']),
                        readOnly: true,
                        suffixWidget: CopyButton(
                          text: viewModel.keyInfo!['xpub'],
                        ),
                      ),
                      if (viewModel.keyInfo!['fingerprint'] != null)
                        SailTextField(
                          label: 'Key Fingerprint',
                          hintText: 'Key fingerprint',
                          controller: TextEditingController(text: viewModel.keyInfo!['fingerprint']),
                          readOnly: true,
                          suffixWidget: CopyButton(
                            text: viewModel.keyInfo!['fingerprint'],
                          ),
                        ),
                      if (viewModel.keyInfo!['originPath'] != null)
                        SailTextField(
                          label: 'Origin Path',
                          hintText: 'Origin path',
                          controller: TextEditingController(text: viewModel.keyInfo!['originPath']),
                          readOnly: true,
                          suffixWidget: CopyButton(
                            text: viewModel.keyInfo!['originPath'],
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
                            SailText.primary13('Instructions:', color: Colors.blue.shade800),
                            SailText.secondary12(
                              '1. Share this information with other multisig participants\n'
                              '2. Use the derivation path when creating the multisig wallet\n'
                              '3. Each participant needs their own unique key and path\n'
                              '4. Keep your private keys secure - never share them!',
                              color: Colors.blue.shade700,
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SailRow(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (viewModel.keyInfo != null)
                          SailButton(
                            label: 'Save Key',
                            onPressed: () async => viewModel.saveKey(context),
                            variant: ButtonVariant.primary,
                          )
                        else
                          const SizedBox(),
                        SailButton(
                          label: 'Close',
                          onPressed: () async => Navigator.of(context).pop(),
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

class MultisigKeyModalViewModel extends BaseViewModel {
  final HDWalletProvider _hdWalletProvider = GetIt.I.get<HDWalletProvider>();
  Logger get _logger => GetIt.I.get<Logger>();
  
  String? modalError;
  Map<String, dynamic>? keyInfo;
  
  Future<void> init() async {
    setBusy(true);
    
    try {
      if (!_hdWalletProvider.isInitialized) {
        await _hdWalletProvider.init();
      }
      
      if (_hdWalletProvider.error != null) {
        modalError = 'Failed to load wallet: ${_hdWalletProvider.error}';
        return;
      }
      
      if (_hdWalletProvider.mnemonic == null) {
        modalError = 'Wallet mnemonic not available';
        return;
      }
      
      await _generateNextMultisigKey();
      
    } catch (e) {
      modalError = 'Failed to generate multisig key: $e';
      _logger.e('Error generating multisig key: $e');
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }
  
  Future<void> _generateNextMultisigKey() async {
    try {
      if (!_hdWalletProvider.isInitialized) {
        await _hdWalletProvider.init();
      }
      
      if (!_hdWalletProvider.isInitialized || _hdWalletProvider.mnemonic == null) {
        throw Exception('HD Wallet not properly initialized. Please ensure wallet is set up.');
      }
      
      final accountIndex = await _hdWalletProvider.getNextAccountIndex(<int>{});
      
      final keyInfoResult = await _hdWalletProvider.generateWalletXpub(accountIndex, false);
      
      if (keyInfoResult.isEmpty) {
        throw Exception('Failed to generate xPub');
      }
      
      final relativeIndex = accountIndex - 8000;
      
      keyInfo = {
        'index': relativeIndex,
        'accountIndex': accountIndex,
        'path': keyInfoResult['derivation_path'] ?? '',
        'xpub': keyInfoResult['xpub'] ?? '',
        'fingerprint': keyInfoResult['fingerprint'] ?? '',
        'originPath': keyInfoResult['derivation_path']?.toString().startsWith('m/') == true 
            ? keyInfoResult['derivation_path']?.substring(2) 
            : keyInfoResult['derivation_path'],
      };
      
      
    } catch (e) {
      _logger.e('Error generating multisig key: $e');
      rethrow;
    }
  }
  
  Future<void> _writeKeyToMultisigJson() async {
    if (keyInfo == null) return;
    
    try {
      final keyIndex = keyInfo!['index'];
      
      final soloKeyData = {
        'xpub': keyInfo!['xpub'],
        'owner': 'MyKey$keyIndex',
        'path': keyInfo!['path'],
        'fingerprint': keyInfo!['fingerprint'],
        'origin_path': keyInfo!['originPath'],
      };
      
      await MultisigStorage.addSoloKey(soloKeyData);
    } catch (e) {
      _logger.e('Failed to write key to multisig.json: $e');
    }
  }

  Future<void> saveKey(BuildContext context) async {
    if (keyInfo == null) return;

    try {
      await _writeKeyToMultisigJson();
      await _saveConfigFile(context);

      if (context.mounted) {
        final keyIndex = keyInfo!['index'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Key saved to multisig.json and key$keyIndex.conf'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.of(context).pop();
      }

    } catch (e) {
      _logger.e('Failed to save key: $e');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save key: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _saveConfigFile(BuildContext context) async {
    if (keyInfo == null) return;

    final appDir = await Environment.datadir();
    final bitdriveDir = Directory(path.join(appDir.path, 'bitdrive'));
    
    if (!await bitdriveDir.exists()) {
      await bitdriveDir.create(recursive: true);
    }

    final keyIndex = keyInfo!['index'];
    final filename = 'key$keyIndex.conf';
    final multisigDir = Directory(path.join(bitdriveDir.path, 'multisig'));
    if (!await multisigDir.exists()) {
      await multisigDir.create(recursive: true);
    }
    final filePath = path.join(multisigDir.path, filename);

    final configData = {
      'owner': 'MyKey$keyIndex',
      'xpub': keyInfo!['xpub'],
      'path': keyInfo!['path'],
      'fingerprint': keyInfo!['fingerprint'],
      'origin_path': keyInfo!['originPath'],
      'is_wallet': true,
    };

    final file = File(filePath);
    const encoder = JsonEncoder.withIndent('  ');
    final prettyJson = encoder.convert(configData);
    await file.writeAsString(prettyJson);
  }
}