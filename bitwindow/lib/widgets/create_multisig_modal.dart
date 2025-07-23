import 'dart:convert';
import 'dart:io';

import 'package:bitwindow/env.dart';
import 'package:bitwindow/pages/wallet/wallet_multisig_lounge.dart';
import 'package:bitwindow/providers/hd_wallet_provider.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class MultisigKey {
  final String owner;
  final String pubkey;
  final String derivationPath;
  final bool isWallet;

  MultisigKey({
    required this.owner,
    required this.pubkey,
    required this.derivationPath,
    required this.isWallet,
  });

  Map<String, dynamic> toJson() => {
        'owner': owner,
        'pubkey': pubkey,
        'path': derivationPath,
        'is_wallet': isWallet,
      };

  factory MultisigKey.fromJson(Map<String, dynamic> json) => MultisigKey(
        owner: json['owner'],
        pubkey: json['pubkey'],
        derivationPath: json['path'],
        isWallet: json['is_wallet'] ?? false,
      );
}

class CreateMultisigModal extends StatelessWidget {
  const CreateMultisigModal({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CreateMultisigModalViewModel>.reactive(
      viewModelBuilder: () => CreateMultisigModalViewModel(),
      onViewModelReady: (model) => model.init(),
      builder: (context, viewModel, child) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
            child: SailCard(
              title: viewModel.currentStep == 0 ? 'Create Multisig Group' : 'Import Public Keys',
              subtitle: viewModel.currentStep == 0 
                  ? 'Set up your multisig parameters'
                  : 'Add public keys to your multisig group (${viewModel.keys.length}/${viewModel.n})',
              error: viewModel.modalError,
              child: SingleChildScrollView(
                child: SailColumn(
                  spacing: SailStyleValues.padding16,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    if (viewModel.currentStep == 0) ...[
                      // Step 1: Basic Configuration
                      SailTextField(
                        label: 'Multisig Group Name',
                        controller: viewModel.nameController,
                        hintText: 'Enter a name for your multisig group',
                        size: TextFieldSize.small,
                      ),
                      SailRow(
                        spacing: SailStyleValues.padding08,
                        children: [
                          Expanded(
                            child: SailTextField(
                              label: 'Required Signatures (m)',
                              controller: viewModel.mController,
                              hintText: '2',
                              size: TextFieldSize.small,
                              textFieldType: TextFieldType.number,
                            ),
                          ),
                          Expanded(
                            child: SailTextField(
                              label: 'Total Keys (n)',
                              controller: viewModel.nController,
                              hintText: '3',
                              size: TextFieldSize.small,
                              textFieldType: TextFieldType.number,
                            ),
                          ),
                        ],
                      ),
                      if (viewModel.parameterError != null)
                        SailText.secondary12(
                          viewModel.parameterError!,
                          color: context.sailTheme.colors.error,
                        ),
                      
                      // Encryption option
                      SailCheckbox(
                        label: 'Encrypt multisig data',
                        value: viewModel.shouldEncrypt,
                        onChanged: (value) => viewModel.setShouldEncrypt(value ?? false),
                      ),
                      
                      if (viewModel.shouldEncrypt)
                        SailCard(
                          shadowSize: ShadowSize.none,
                          child: Container(
                            padding: const EdgeInsets.all(SailStyleValues.padding12),
                            decoration: BoxDecoration(
                              color: context.sailTheme.colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: SailRow(
                              spacing: SailStyleValues.padding08,
                              children: [
                                Icon(
                                  Icons.warning_outlined,
                                  color: context.sailTheme.colors.orange,
                                  size: 16,
                                ),
                                Expanded(
                                  child: SailText.secondary12(
                                    'Warning: Other participants will not be able to restore this multisig group via TXID if encrypted',
                                    color: context.sailTheme.colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ] else ...[
                      // Step 2: Public Key Management
                      SailCard(
                        shadowSize: ShadowSize.none,
                        child: SailColumn(
                          spacing: SailStyleValues.padding08,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SailRow(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SailText.primary15('${viewModel.nameController.text}'),
                                SailText.secondary12('${viewModel.m}-of-${viewModel.n} multisig'),
                              ],
                            ),
                            SailSpacing(SailStyleValues.padding04),
                            SailText.secondary12('Keys added: ${viewModel.keys.length}/${viewModel.n}'),
                            if (viewModel.keys.length >= viewModel.n)
                              SailText.secondary12(
                                'Maximum keys reached',
                                color: context.sailTheme.colors.orange,
                              ),
                          ],
                        ),
                      ),
                      
                      SailCard(
                        shadowSize: ShadowSize.none,
                        child: SailColumn(
                          spacing: SailStyleValues.padding12,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SailText.primary15('Add Public Key'),
                            SailRow(
                              spacing: SailStyleValues.padding08,
                              children: [
                                Expanded(
                                  child: SailTextField(
                                    label: 'Owner Name',
                                    controller: viewModel.ownerController,
                                    hintText: 'Key owner name',
                                    size: TextFieldSize.small,
                                  ),
                                ),
                                Expanded(
                                  child: SailTextField(
                                    label: 'Derivation Path',
                                    controller: viewModel.pathController,
                                    hintText: "m/44'/0'/0'/0/0",
                                    size: TextFieldSize.small,
                                  ),
                                ),
                              ],
                            ),
                            SailTextField(
                              label: 'Public Key',
                              controller: viewModel.pubkeyController,
                              hintText: 'Paste public key or generate from path',
                              size: TextFieldSize.small,
                              minLines: 2,
                            ),
                            SailRow(
                              spacing: SailStyleValues.padding08,
                              children: [
                                Expanded(
                                  child: SailTextField(
                                    label: 'Fee (BTC)',
                                    controller: viewModel.feeController,
                                    hintText: '0.001',
                                    size: TextFieldSize.small,
                                    textFieldType: TextFieldType.number,
                                  ),
                                ),
                                                                 SailButton(
                                   label: 'Generate Key',
                                   onPressed: viewModel.canGenerateKey && viewModel.keys.length < viewModel.n ? () async => await viewModel.generatePublicKey() : null,
                                   variant: ButtonVariant.secondary,
                                 ),
                                 SailButton(
                                   label: 'Paste Key',
                                   onPressed: viewModel.keys.length < viewModel.n ? () async => await viewModel.pastePublicKey() : null,
                                   variant: ButtonVariant.secondary,
                                 ),
                              ],
                            ),
                                                         SailButton(
                               label: 'Save Key',
                               onPressed: viewModel.canSaveKey ? () async => viewModel.saveKey() : null,
                               disabled: !viewModel.canSaveKey,
                             ),
                          ],
                        ),
                      ),
                      
                      if (viewModel.keys.isNotEmpty) ...[
                        SailRow(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SailText.primary15('Saved Keys (${viewModel.keys.length})'),
                            if (viewModel.keys.length == viewModel.n)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: context.sailTheme.colors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: SailText.secondary12(
                                  'Ready to save',
                                  color: context.sailTheme.colors.primary,
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: context.sailTheme.colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: SailText.secondary12(
                                  'Need ${viewModel.n - viewModel.keys.length} more',
                                  color: context.sailTheme.colors.orange,
                                ),
                              ),
                          ],
                        ),
                                                 ...viewModel.keys.asMap().entries.map((entry) {
                           final index = entry.key;
                           final key = entry.value;
                           return SailCard(
                             shadowSize: ShadowSize.none,
                             child: SailColumn(
                               spacing: SailStyleValues.padding08,
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 SailRow(
                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                   children: [
                                     SailColumn(
                                       crossAxisAlignment: CrossAxisAlignment.start,
                                       spacing: SailStyleValues.padding04,
                                       children: [
                                         SailText.primary13('${index + 1}. ${key.owner}'),
                                         SailRow(
                                           spacing: SailStyleValues.padding04,
                                           children: [
                                             Container(
                                               padding: const EdgeInsets.symmetric(
                                                 horizontal: 6,
                                                 vertical: 2,
                                               ),
                                               decoration: BoxDecoration(
                                                 color: key.isWallet 
                                                     ? context.sailTheme.colors.primary.withValues(alpha: 0.1)
                                                     : context.sailTheme.colors.orange.withValues(alpha: 0.1),
                                                 borderRadius: BorderRadius.circular(4),
                                               ),
                                                                                               child: SailText.secondary12(
                                                  key.isWallet ? 'Wallet Key' : 'External Key',
                                                  color: key.isWallet 
                                                      ? context.sailTheme.colors.primary
                                                      : context.sailTheme.colors.orange,
                                                ),
                                             ),
                                           ],
                                         ),
                                       ],
                                     ),
                                     SailButton(
                                       label: 'Remove',
                                       onPressed: () async => viewModel.removeKey(index),
                                       variant: ButtonVariant.ghost,
                                     ),
                                   ],
                                 ),
                                 SailText.secondary12('Path: ${key.derivationPath}'),
                                 SailText.secondary12('Pubkey: ${key.pubkey.substring(0, 20)}...'),
                               ],
                             ),
                           );
                         }),
                      ],
                    ],
                    
                    // Navigation Buttons
                    SailRow(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                                                 if (viewModel.currentStep > 0)
                           SailButton(
                             label: 'Back',
                             onPressed: () async => viewModel.goBack(),
                             variant: ButtonVariant.ghost,
                           )
                        else
                          Container(),
                        
                        SailRow(
                          spacing: SailStyleValues.padding08,
                          children: [
                            SailButton(
                              label: 'Cancel',
                              onPressed: () async => Navigator.of(context).pop(false),
                              variant: ButtonVariant.ghost,
                            ),
                                                         if (viewModel.currentStep == 0)
                               SailButton(
                                 label: 'Next',
                                 onPressed: viewModel.canProceed ? () async => viewModel.nextStep() : null,
                                 disabled: !viewModel.canProceed,
                               )
                             else if (viewModel.canSaveGroup)
                               SailButton(
                                 label: 'Save Multisig Group',
                                 onPressed: () => viewModel.saveMultisigGroup(context),
                                 loading: viewModel.isBusy,
                               )
                             else
                               SailButton(
                                 label: 'Need ${viewModel.m - viewModel.keys.length} more key(s)',
                                 onPressed: null,
                                 disabled: true,
                               ),
                          ],
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

class CreateMultisigModalViewModel extends BaseViewModel {
  final HDWalletProvider _hdWallet = GetIt.I.get<HDWalletProvider>();
  final BitwindowRPC _api = GetIt.I.get<BitwindowRPC>();

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mController = TextEditingController(text: '2');
  final TextEditingController nController = TextEditingController(text: '3');
  final TextEditingController ownerController = TextEditingController();
  final TextEditingController pubkeyController = TextEditingController();
  final TextEditingController pathController = TextEditingController(text: "m/44'/0'/0'/0/0");
  final TextEditingController feeController = TextEditingController(text: '0.001');

  // State
  int currentStep = 0;
  String? modalError;
  String? parameterError;
  List<MultisigKey> keys = [];
  bool shouldEncrypt = false; // Default to false (base64 only)
  
  // Constants
  static const int MULTISIG_DERIVATION_INDEX = 8000;
  static const String MULTISIG_DERIVATION_BASE = "m/84'/1'/0'/0/";
  static const int MULTISIG_FLAG = 0x02; // Flag to identify multisig transactions

  // Getters
  int get m => int.tryParse(mController.text) ?? 0;
  int get n => int.tryParse(nController.text) ?? 0;
  double get fee => double.tryParse(feeController.text) ?? 0.001;

  bool get canProceed => 
      nameController.text.isNotEmpty && 
      m > 0 && 
      n > 0 && 
      m <= n && 
      parameterError == null;

  bool get canGenerateKey => 
      ownerController.text.isNotEmpty && 
      pathController.text.isNotEmpty;

  bool get canSaveKey => 
      ownerController.text.isNotEmpty && 
      pubkeyController.text.isNotEmpty && 
      pathController.text.isNotEmpty &&
      keys.length < n; // Don't allow more than n keys

  bool get canSaveGroup => keys.length == n; // Need all n keys to save group

  void init() {
    // Listen for parameter changes
    mController.addListener(_validateParameters);
    nController.addListener(_validateParameters);
    
    notifyListeners();
  }

  void _validateParameters() {
    final mValue = int.tryParse(mController.text);
    final nValue = int.tryParse(nController.text);
    
    if (mValue != null && nValue != null) {
      if (mValue > nValue) {
        parameterError = 'Required signatures (m) must be less than or equal to total keys (n)';
      } else if (mValue < 1) {
        parameterError = 'Required signatures must be at least 1';
      } else if (mValue > 15) {
        parameterError = 'Required signatures cannot exceed 15';
      } else if (nValue > 15) {
        parameterError = 'Total keys cannot exceed 15';
      } else {
        parameterError = null;
      }
    } else {
      parameterError = 'Please enter valid numbers';
    }
    
    notifyListeners();
  }

  void nextStep() {
    if (canProceed) {
      currentStep = 1;
      ownerController.text = 'MyKey0';
      // Set default path for manual entry (external keys) to match enforcer pattern
      pathController.text = "m/84'/1'/0'/0/0";
      notifyListeners();
      
      // Auto-generate the first wallet key
      generatePublicKey();
    }
  }

  void goBack() {
    if (currentStep > 0) {
      currentStep--;
      notifyListeners();
    }
  }



  Future<int> _getNextWalletKeyIndex() async {
    try {
      final appDir = await Environment.datadir();
      final bitdriveDir = path.join(appDir.path, 'bitdrive');
      final dir = Directory(bitdriveDir);
      
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      
      final jsonFile = File(path.join(bitdriveDir, 'multisig.json'));
      
      int highestIndex = MULTISIG_DERIVATION_INDEX - 1; // Start from 7999
      
      // Check existing saved groups
      if (await jsonFile.exists()) {
        final content = await jsonFile.readAsString();
        final List<dynamic> existingGroups = json.decode(content);
        
        // Look through all groups and their wallet keys
        for (final group in existingGroups) {
          final keys = group['keys'] as List<dynamic>;
          for (final keyData in keys) {
            final isWallet = keyData['is_wallet'] ?? false;
            if (isWallet) {
              final keyPath = keyData['path'] as String;
              // Extract index from path like "m/84'/1'/0'/0/8005"
              final pathParts = keyPath.split('/');
              if (pathParts.length == 6 && keyPath.startsWith(MULTISIG_DERIVATION_BASE)) {
                final index = int.tryParse(pathParts[5]) ?? (MULTISIG_DERIVATION_INDEX - 1);
                if (index > highestIndex) {
                  highestIndex = index;
                }
              }
            }
          }
        }
      }
      
      // Also check keys already added to the current group
      for (final key in keys) {
        if (key.isWallet) {
          final pathParts = key.derivationPath.split('/');
          if (pathParts.length == 6 && key.derivationPath.startsWith(MULTISIG_DERIVATION_BASE)) {
            final index = int.tryParse(pathParts[5]) ?? (MULTISIG_DERIVATION_INDEX - 1);
            if (index > highestIndex) {
              highestIndex = index;
            }
          }
        }
      }
      
      return highestIndex + 1; // Return next available index
      
    } catch (e) {
      modalError = 'Failed to get next key index: $e';
      notifyListeners();
      return MULTISIG_DERIVATION_INDEX;
    }
  }

  Future<void> generatePublicKey() async {
    if (!canGenerateKey) return;

    try {
      modalError = null;
      setBusy(true);
      
      // Get the next available wallet key index
      final nextIndex = await _getNextWalletKeyIndex();
      final walletKeyPath = '$MULTISIG_DERIVATION_BASE$nextIndex';
      
      // Update the path controller to show the correct path
      pathController.text = walletKeyPath;
      
      // Update the owner name to show relative index (e.g., MyKey0, MyKey1, etc.)
      final relativeIndex = nextIndex - MULTISIG_DERIVATION_INDEX;
      ownerController.text = 'MyKey$relativeIndex';
      
      final keyInfo = await _hdWallet.deriveKeyInfo(
        _hdWallet.mnemonic ?? '', 
        walletKeyPath,
      );
      
      final publicKey = keyInfo['publicKey'] ?? '';
      if (publicKey.isNotEmpty) {
        pubkeyController.text = publicKey;
      } else {
        throw Exception('Failed to generate public key');
      }
      
    } catch (e) {
      modalError = 'Failed to generate public key: $e';
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  Future<void> pastePublicKey() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text != null) {
        pubkeyController.text = clipboardData!.text!;
        notifyListeners();
      }
    } catch (e) {
      modalError = 'Failed to paste from clipboard: $e';
      notifyListeners();
    }
  }

  void saveKey() {
    if (!canSaveKey) return;

    // Check if we've reached the maximum number of keys
    if (keys.length >= n) {
      modalError = 'Cannot add more than $n keys to this multisig group';
      notifyListeners();
      return;
    }

    // Check for duplicate public keys
    if (keys.any((key) => key.pubkey == pubkeyController.text)) {
      modalError = 'This public key has already been added';
      notifyListeners();
      return;
    }

    // Determine if this is a wallet-generated key
    final currentPath = pathController.text;
    final isWalletKey = currentPath.startsWith(MULTISIG_DERIVATION_BASE);

    // Extract the index from the path for wallet keys (e.g., "m/84'/1'/0'/0/8003" -> 8003)
    String ownerName = ownerController.text;
    if (isWalletKey) {
      final pathParts = currentPath.split('/');
      if (pathParts.length == 6) {
        final keyIndex = int.tryParse(pathParts[5]) ?? MULTISIG_DERIVATION_INDEX;
        final relativeIndex = keyIndex - MULTISIG_DERIVATION_INDEX;
        ownerName = 'MyKey$relativeIndex';
      }
    }

    final key = MultisigKey(
      owner: ownerName,
      pubkey: pubkeyController.text,
      derivationPath: currentPath,
      isWallet: isWalletKey,
    );

    keys.add(key);
    
    // Clear form and prepare for next key (only if we haven't reached the limit)
    if (keys.length < n) {
      ownerController.text = 'External Key ${keys.length + 1}';
      pubkeyController.clear();
      
      // Reset path to the default manual entry format for external keys (enforcer pattern)
      pathController.text = "m/84'/1'/0'/0/0";
    } else {
      // Clear form but don't set defaults since we're at the limit
      ownerController.clear();
      pubkeyController.clear();
      pathController.clear();
    }
    
    modalError = null;
    notifyListeners();
  }

  void removeKey(int index) {
    if (index >= 0 && index < keys.length) {
      keys.removeAt(index);
      notifyListeners();
    }
  }

  String _computeMultisigId(List<MultisigKey> sortedKeys) {
    try {
      // Concatenate all public keys in order
      final concatenatedPubkeys = sortedKeys.map((key) => key.pubkey).join('');
      final pubkeyBytes = hex.decode(concatenatedPubkeys);
      
      // Compute SHA256d (double SHA256)
      final firstHash = sha256.convert(pubkeyBytes).bytes;
      final secondHash = sha256.convert(firstHash).bytes;
      
      // Take first 3 bytes and convert to hex
      final idBytes = secondHash.sublist(0, 3);
      return hex.encode(idBytes);
    } catch (e) {
      throw Exception('Failed to compute multisig ID: $e');
    }
  }

  Future<void> saveMultisigGroup(BuildContext context) async {
    if (!canSaveGroup) return;

    try {
      modalError = null;
      setBusy(true);

      // Sort keys by BIP174 order (lexicographic order of public keys)
      final sortedKeys = List<MultisigKey>.from(keys);
      sortedKeys.sort((a, b) => a.pubkey.compareTo(b.pubkey));

      // Compute multisig ID
      final multisigId = _computeMultisigId(sortedKeys);

      // Create multisig JSON (without txid first)
      final multisigData = {
        'id': multisigId,
        'name': nameController.text,
        'n': n,
        'm': m,
        'keys': sortedKeys.map((key) => key.toJson()).toList(),
        'created': DateTime.now().millisecondsSinceEpoch,
      };

      // Broadcast via BitDrive with multisig flag and capture TXID
      final txid = await _broadcastMultisigGroup(multisigData);
      
      // Add TXID to the data before saving locally
      multisigData['txid'] = txid;

      // Save to local file
      await _saveToLocalFile(multisigData);

      // Close dialog on success
      if (context.mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
      }
      
    } catch (e) {
      modalError = 'Failed to save multisig group: $e';
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  Future<void> _saveToLocalFile(Map<String, dynamic> multisigData) async {
    try {
      final appDir = await Environment.datadir();
      final bitdriveDir = path.join(appDir.path, 'bitdrive');
      final dir = Directory(bitdriveDir);
      
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      
      final file = File(path.join(bitdriveDir, 'multisig.json'));
      
      // Load existing data or create new
      List<dynamic> existingGroups = [];
      if (await file.exists()) {
        final content = await file.readAsString();
        existingGroups = json.decode(content);
      }
      
      // Add new group
      existingGroups.add(multisigData);
      
      // Save updated data
      await file.writeAsString(json.encode(existingGroups));
      
    } catch (e) {
      throw Exception('Failed to save to local file: $e');
    }
  }

  Future<String> _broadcastMultisigGroup(Map<String, dynamic> multisigData) async {
    try {
      // Convert to JSON bytes
      final jsonBytes = Uint8List.fromList(utf8.encode(json.encode(multisigData)));
      
      // Use BitDrive's storage system with multisig flag
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      const fileType = 'json';
      
      // Create metadata with multisig flag (bit 1) + optional encryption flag (bit 0)
      final metadata = ByteData(9);
      final flags = MULTISIG_FLAG | (shouldEncrypt ? 0x01 : 0x00);
      metadata.setUint8(0, flags);
      metadata.setUint32(1, timestamp);
      
      // Set file type as 'json'
      final typeBytes = utf8.encode(fileType.padRight(4, ' '));
      for (var i = 0; i < 4; i++) {
        metadata.setUint8(5 + i, typeBytes[i]);
      }
      
      final metadataStr = base64.encode(metadata.buffer.asUint8List());
      
      // Encrypt or encode based on user choice
      final String contentStr;
      if (shouldEncrypt) {
        final encryptedContent = await _encryptContent(jsonBytes, timestamp, fileType);
        contentStr = base64.encode(encryptedContent);
      } else {
        // Just base64 encode for interoperability
        contentStr = base64.encode(jsonBytes);
      }
      
      // Combine and broadcast
      final opReturnData = '$metadataStr|$contentStr';
      
      // Convert fee to satoshis
      final feeSats = (fee * 100000000).toInt();
      
      final address = await _api.wallet.getNewAddress();
      final txid = await _api.wallet.sendTransaction(
        {address: 10000}, // 0.0001 BTC
        fixedFeeSats: feeSats,
        opReturnMessage: opReturnData,
      );
      
      return txid;
      
    } catch (e) {
      throw Exception('Failed to broadcast multisig group: $e');
    }
  }

  // BitDrive encryption methods (uses BitDrive's derivation paths)
  Future<Uint8List> _deriveKeyStream(int timestamp, String fileType, int length) async {
    const bitdriveDerivationPath = "m/84'/1'/0'/0/4000"; // BitDrive's encryption key path (enforcer pattern)
    final keyInfo = await _hdWallet.deriveKeyInfo(_hdWallet.mnemonic ?? '', bitdriveDerivationPath);
    final privateKeyHex = keyInfo['privateKey'] ?? '';

    final seedValue = utf8.encode('$privateKeyHex:$timestamp:$fileType');
    final seed = sha256.convert(seedValue).bytes;

    final result = Uint8List(length);
    var bytesGenerated = 0;
    var counter = 0;

    while (bytesGenerated < length) {
      final counterData = ByteData(4)..setUint32(0, counter);
      final counterBytes = counterData.buffer.asUint8List();

      final blockInput = Uint8List(seed.length + counterBytes.length);
      blockInput.setAll(0, seed);
      blockInput.setAll(seed.length, counterBytes);

      final block = sha256.convert(blockInput).bytes;
      final bytesToCopy = (block.length < length - bytesGenerated) ? block.length : length - bytesGenerated;
      result.setRange(bytesGenerated, bytesGenerated + bytesToCopy, block);

      bytesGenerated += bytesToCopy;
      counter++;
    }

    return result;
  }

  Future<Uint8List> _deriveAuthKey() async {
    const bitdriveAuthPath = "m/84'/1'/0'/1/4000"; // BitDrive's auth key path (enforcer pattern)
    final keyInfo = await _hdWallet.deriveKeyInfo(_hdWallet.mnemonic ?? '', bitdriveAuthPath);
    final privateKeyHex = keyInfo['privateKey'] ?? '';
    return Uint8List.fromList(hex.decode(privateKeyHex));
  }

  Future<Uint8List> _encryptContent(Uint8List content, int timestamp, String fileType) async {
    try {
      // Generate key stream and perform XOR encryption
      final keyStream = await _deriveKeyStream(timestamp, fileType, content.length);
      final encrypted = Uint8List(content.length);

      for (var i = 0; i < content.length; i++) {
        encrypted[i] = content[i] ^ keyStream[i];
      }

      // Generate truncated authentication tag
      final authKey = await _deriveAuthKey();
      const authTagSize = 8;
      final tag = Uint8List.fromList(Hmac(sha256, authKey).convert(encrypted).bytes.sublist(0, authTagSize));

      // Combine encrypted content with tag
      final result = Uint8List(encrypted.length + tag.length);
      result.setAll(0, encrypted);
      result.setAll(encrypted.length, tag);

      return result;
    } catch (e) {
      throw Exception('Encryption error: $e');
    }
  }

  void setShouldEncrypt(bool value) {
    shouldEncrypt = value;
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    mController.dispose();
    nController.dispose();
    ownerController.dispose();
    pubkeyController.dispose();
    pathController.dispose();
    feeController.dispose();
    super.dispose();
  }
}

class ImportMultisigModal extends StatelessWidget {
  const ImportMultisigModal({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ImportMultisigModalViewModel>.reactive(
      viewModelBuilder: () => ImportMultisigModalViewModel(),
      builder: (context, viewModel, child) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
            child: SailCard(
              title: 'Import Multisig from TXID',
              subtitle: 'Import a multisig group by providing the transaction ID',
              error: viewModel.modalError,
              child: SingleChildScrollView(
                child: SailColumn(
                  spacing: SailStyleValues.padding16,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!viewModel.hasFoundGroup) ...[
                      // Step 1: Enter TXID
                      SailTextField(
                        label: 'Transaction ID',
                        controller: viewModel.txidController,
                        hintText: 'Paste the transaction ID containing the multisig data',
                        size: TextFieldSize.small,
                      ),
                      SailButton(
                        label: 'Fetch Multisig Data',
                        onPressed: viewModel.canFetch ? () => viewModel.fetchMultisigData() : null,
                        loading: viewModel.isBusy,
                      ),
                    ] else ...[
                      // Step 2: Select owned keys
                      SailText.primary15('Select Your Keys'),
                      SailText.secondary12(
                        'Check the keys that belong to you. This helps the wallet know which keys it can use for signing.',
                      ),
                      SailSpacing(SailStyleValues.padding08),
                      
                      if (viewModel.importedGroup != null)
                        ...viewModel.importedGroup!.keys.asMap().entries.map((entry) {
                          final index = entry.key;
                          final key = entry.value;
                          return SailCard(
                            shadowSize: ShadowSize.none,
                            child: SailColumn(
                              spacing: SailStyleValues.padding08,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SailCheckbox(
                                  label: key.owner,
                                  value: viewModel.selectedKeys.contains(index),
                                  onChanged: (value) => viewModel.toggleKeySelection(index),
                                ),
                                SailText.secondary12('Path: ${key.derivationPath}'),
                                SailText.secondary12('Pubkey: ${key.pubkey.substring(0, 20)}...'),
                              ],
                            ),
                          );
                        }),
                      
                      SailSpacing(SailStyleValues.padding16),
                      SailText.primary13('Group Info:'),
                      SailText.secondary12('Name: ${viewModel.importedGroup?.name}'),
                      SailText.secondary12('ID: ${viewModel.importedGroup?.id.toUpperCase()}'),
                      SailText.secondary12('Required: ${viewModel.importedGroup?.m} of ${viewModel.importedGroup?.n}'),
                    ],
                    
                    // Navigation buttons
                    SailRow(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (viewModel.hasFoundGroup)
                          SailButton(
                            label: 'Back',
                            onPressed: () async => viewModel.goBack(),
                            variant: ButtonVariant.ghost,
                          )
                        else
                          Container(),
                        
                        SailRow(
                          spacing: SailStyleValues.padding08,
                          children: [
                            SailButton(
                              label: 'Cancel',
                              onPressed: () async => Navigator.of(context).pop(false),
                              variant: ButtonVariant.ghost,
                            ),
                            if (viewModel.hasFoundGroup)
                              SailButton(
                                label: 'Import Group',
                                onPressed: () async => await viewModel.importGroup(context),
                                loading: viewModel.isBusy,
                              ),
                          ],
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

class ImportMultisigModalViewModel extends BaseViewModel {
  final BitwindowRPC _api = GetIt.I.get<BitwindowRPC>();
  final HDWalletProvider _hdWallet = GetIt.I.get<HDWalletProvider>();
  
  final TextEditingController txidController = TextEditingController();
  
  String? modalError;
  MultisigGroup? importedGroup;
  Set<int> selectedKeys = {};
  bool hasFoundGroup = false;
  
  bool get canFetch => txidController.text.trim().isNotEmpty;
  
  Future<void> fetchMultisigData() async {
    try {
      modalError = null;
      setBusy(true);
      
      final txid = txidController.text.trim();
      
      // Get OP_RETURN data for this specific transaction
      final opReturns = await _api.misc.listOPReturns();
      final opReturn = opReturns.firstWhere(
        (op) => op.txid == txid,
        orElse: () => throw Exception('No OP_RETURN data found for this transaction'),
      );
      
      if (!opReturn.message.contains('|')) {
        throw Exception('Invalid OP_RETURN format');
      }
      
      final parts = opReturn.message.split('|');
      if (parts.length != 2) {
        throw Exception('Invalid OP_RETURN data structure');
      }
      
      // Parse metadata
      final metadataBytes = base64.decode(parts[0]);
      if (metadataBytes.length != 9) {
        throw Exception('Invalid metadata length');
      }
      
      final metadata = ByteData.view(Uint8List.fromList(metadataBytes).buffer);
      final flags = metadata.getUint8(0);
      final isMultisig = (flags & 0x02) != 0; // Check multisig flag
      final isEncrypted = (flags & 0x01) != 0;
      
      if (!isMultisig) {
        throw Exception('This transaction does not contain multisig data');
      }
      
      if (isEncrypted) {
        throw Exception('This multisig group is encrypted and cannot be imported via TXID');
      }
      
      // Decode the content (should be base64 encoded JSON)
      final contentBytes = base64.decode(parts[1]);
      final jsonString = utf8.decode(contentBytes);
      final multisigData = json.decode(jsonString) as Map<String, dynamic>;
      
      // Convert to MultisigGroup
      importedGroup = MultisigGroup.fromJson(multisigData);
      hasFoundGroup = true;
      
    } catch (e) {
      modalError = 'Failed to fetch multisig data: $e';
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }
  
  void toggleKeySelection(int index) {
    if (selectedKeys.contains(index)) {
      selectedKeys.remove(index);
    } else {
      selectedKeys.add(index);
    }
    notifyListeners();
  }
  
  void goBack() {
    hasFoundGroup = false;
    importedGroup = null;
    selectedKeys.clear();
    modalError = null;
    notifyListeners();
  }
  
  Future<void> importGroup(BuildContext context) async {
    if (importedGroup == null) return;
    
    try {
      modalError = null;
      setBusy(true);
      
      // Create updated multisig data with proper is_wallet flags
      final updatedKeys = importedGroup!.keys.asMap().entries.map((entry) {
        final index = entry.key;
        final key = entry.value;
        return MultisigKey(
          owner: key.owner,
          pubkey: key.pubkey,
          derivationPath: key.derivationPath,
          isWallet: selectedKeys.contains(index), // Set based on user selection
        );
      }).toList();
      
      final updatedGroup = {
        'id': importedGroup!.id,
        'name': importedGroup!.name,
        'n': importedGroup!.n,
        'm': importedGroup!.m,
        'keys': updatedKeys.map((key) => key.toJson()).toList(),
        'created': importedGroup!.created,
        'txid': txidController.text.trim(), // Include the TXID from import
      };
      
      // Save to local file
      await _saveToLocalFile(updatedGroup);
      
      if (context.mounted) {
        Navigator.of(context).pop(true);
      }
      
    } catch (e) {
      modalError = 'Failed to import group: $e';
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }
  
  Future<void> _saveToLocalFile(Map<String, dynamic> multisigData) async {
    try {
      final appDir = await Environment.datadir();
      final bitdriveDir = path.join(appDir.path, 'bitdrive');
      final dir = Directory(bitdriveDir);
      
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      
      final file = File(path.join(bitdriveDir, 'multisig.json'));
      
      // Load existing data or create new
      List<dynamic> existingGroups = [];
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.trim().isNotEmpty) {
          existingGroups = json.decode(content);
        }
      }
      
      // Check if this multisig group already exists (by ID)
      final groupId = multisigData['id'] as String;
      final existingIndex = existingGroups.indexWhere((group) => group['id'] == groupId);
      
      if (existingIndex != -1) {
        // Update existing group
        existingGroups[existingIndex] = multisigData;
      } else {
        // Add new group
        existingGroups.add(multisigData);
      }
      
      // Save updated data
      await file.writeAsString(json.encode(existingGroups));
      
    } catch (e) {
      throw Exception('Failed to save to local file: $e');
    }
  }
  
  @override
  void dispose() {
    txidController.dispose();
    super.dispose();
  }
}
