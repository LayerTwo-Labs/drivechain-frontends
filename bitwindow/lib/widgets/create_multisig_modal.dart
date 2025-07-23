import 'dart:convert';
import 'dart:io';

import 'package:bitwindow/env.dart';
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
                  : 'Add public keys to your multisig group (${viewModel.keys.length}/${viewModel.m})',
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
                    ] else ...[
                      // Step 2: Public Key Management
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
                                   onPressed: viewModel.canGenerateKey ? () async => await viewModel.generatePublicKey() : null,
                                   variant: ButtonVariant.secondary,
                                 ),
                                 SailButton(
                                   label: 'Paste Key',
                                   onPressed: () async => await viewModel.pastePublicKey(),
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
                        SailText.primary15('Saved Keys (${viewModel.keys.length})'),
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
      pathController.text.isNotEmpty;

  bool get canSaveGroup => keys.length >= m;

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
      
      if (!await jsonFile.exists()) {
        return MULTISIG_DERIVATION_INDEX; // Start at 8000 if no groups exist
      }
      
      final content = await jsonFile.readAsString();
      final List<dynamic> existingGroups = json.decode(content);
      
      int highestIndex = MULTISIG_DERIVATION_INDEX - 1; // Start from 7999
      
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
    
    // Clear form and prepare for next key
    ownerController.text = 'External Key ${keys.length + 1}';
    pubkeyController.clear();
    
    // Reset path to the default manual entry format for external keys (enforcer pattern)
    pathController.text = "m/84'/1'/0'/0/0";
    
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

      // Create multisig JSON
      final multisigData = {
        'id': multisigId,
        'name': nameController.text,
        'n': n,
        'm': m,
        'keys': sortedKeys.map((key) => key.toJson()).toList(),
        'created': DateTime.now().millisecondsSinceEpoch,
      };

      // Save to local file
      await _saveToLocalFile(multisigData);
      
      // Broadcast via BitDrive with multisig flag
      await _broadcastMultisigGroup(multisigData);

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

  Future<void> _broadcastMultisigGroup(Map<String, dynamic> multisigData) async {
    try {
      // Convert to JSON bytes
      final jsonBytes = Uint8List.fromList(utf8.encode(json.encode(multisigData)));
      
      // Use BitDrive's encryption system with multisig flag
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      const fileType = 'json';
      
      // Create metadata with multisig flag (bit 1) + encryption flag (bit 0)
      final metadata = ByteData(9);
      metadata.setUint8(0, MULTISIG_FLAG | 0x01); // Multisig flag + encryption flag
      metadata.setUint32(1, timestamp);
      
      // Set file type as 'json'
      final typeBytes = utf8.encode(fileType.padRight(4, ' '));
      for (var i = 0; i < 4; i++) {
        metadata.setUint8(5 + i, typeBytes[i]);
      }
      
      final metadataStr = base64.encode(metadata.buffer.asUint8List());
      
      // Encrypt using BitDrive's encryption method
      final encryptedContent = await _encryptContent(jsonBytes, timestamp, fileType);
      final contentStr = base64.encode(encryptedContent);
      
      // Combine and broadcast
      final opReturnData = '$metadataStr|$contentStr';
      
      // Convert fee to satoshis
      final feeSats = (fee * 100000000).toInt();
      
      final address = await _api.wallet.getNewAddress();
      await _api.wallet.sendTransaction(
        {address: 10000}, // 0.0001 BTC
        fixedFeeSats: feeSats,
        opReturnMessage: opReturnData,
      );
      
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
