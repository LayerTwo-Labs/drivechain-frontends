import 'dart:convert';
import 'dart:io';

import 'package:bitwindow/env.dart';
import 'package:bitwindow/models/multisig_group.dart';
import 'package:bitwindow/providers/hd_wallet_provider.dart';
import 'package:bitwindow/providers/multisig_provider.dart';
import 'package:bs58/bs58.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';


class MultisigKey {
  final String owner;
  final String xpub;  // Changed from pubkey to xpub
  final String derivationPath;
  final String? fingerprint;
  final String? originPath;
  final bool isWallet;
  
  final Map<String, String>? activePSBTs;
  final Map<String, String>? initialPSBTs;

  MultisigKey({
    required this.owner,
    required this.xpub,
    required this.derivationPath,
    this.fingerprint,
    this.originPath,
    required this.isWallet,
    this.activePSBTs,
    this.initialPSBTs,
  });

  Map<String, dynamic> toJson() => {
        'owner': owner,
        'xpub': xpub,
        'pubkey': xpub,
        'path': derivationPath,
        'fingerprint': fingerprint,
        'origin_path': originPath,
        'is_wallet': isWallet,
        if (activePSBTs != null) 'active_psbts': activePSBTs,
        if (initialPSBTs != null) 'initial_psbts': initialPSBTs,
      };

  factory MultisigKey.fromJson(Map<String, dynamic> json) => MultisigKey(
        owner: json['owner'],
        xpub: json['xpub'] ?? json['pubkey'], // Support legacy pubkey field
        derivationPath: json['path'],
        fingerprint: json['fingerprint'],
        originPath: json['origin_path'],
        isWallet: json['is_wallet'] ?? false,
        activePSBTs: json['active_psbts'] != null ? Map<String, String>.from(json['active_psbts']) : null,
        initialPSBTs: json['initial_psbts'] != null ? Map<String, String>.from(json['initial_psbts']) : null,
      );

  MultisigKey copyWith({
    String? owner,
    String? xpub,
    String? derivationPath,
    String? fingerprint,
    String? originPath,
    bool? isWallet,
    Map<String, String>? activePSBTs,
    Map<String, String>? initialPSBTs,
  }) {
    return MultisigKey(
      owner: owner ?? this.owner,
      xpub: xpub ?? this.xpub,
      derivationPath: derivationPath ?? this.derivationPath,
      fingerprint: fingerprint ?? this.fingerprint,
      originPath: originPath ?? this.originPath,
      isWallet: isWallet ?? this.isWallet,
      activePSBTs: activePSBTs ?? this.activePSBTs,
      initialPSBTs: initialPSBTs ?? this.initialPSBTs,
    );
  }
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
                      SailCard(
                        shadowSize: ShadowSize.none,
                        child: SailColumn(
                          spacing: SailStyleValues.padding08,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SailRow(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SailText.primary15(viewModel.nameController.text),
                                SailSpacing(SailStyleValues.padding16),
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
                      
                      if (viewModel.keys.length != viewModel.n)
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
                                    hintText: "m/84'/1'/0'/0/0",
                                    size: TextFieldSize.small,
                                  ),
                                ),
                              ],
                            ),
                            SailTextField(
                              label: 'Extended Public Key (xPub)',
                              controller: viewModel.pubkeyController,
                              hintText: 'Paste xPub or generate wallet xPub',
                              size: TextFieldSize.small,
                              minLines: 2,
                            ),
                            SailRow(
                              spacing: SailStyleValues.padding08,
                              children: [
                                Expanded(
                                  child: SailTextField(
                                    label: 'Master Fingerprint (Optional)',
                                    controller: viewModel.fingerprintController,
                                    hintText: 'e.g., d34db33f',
                                    size: TextFieldSize.small,
                                  ),
                                ),
                              ],
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
                                   label: 'Generate Wallet xPub',
                                   onPressed: viewModel.canGenerateKey && viewModel.keys.length < viewModel.n ? () async => await viewModel.generatePublicKey() : null,
                                   variant: ButtonVariant.secondary,
                                 ),
                                 SailButton(
                                   label: 'Paste xPub',
                                   onPressed: viewModel.keys.length < viewModel.n ? () async => await viewModel.pastePublicKey() : null,
                                   variant: ButtonVariant.secondary,
                                 ),
                                 SailButton(
                                   label: 'Import Key',
                                   onPressed: viewModel.keys.length < viewModel.n ? () async => await viewModel.importKeyFromFile(context) : null,
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
                                 SailText.secondary12('xPub: ${key.xpub.substring(0, 20)}...'),
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
                                 onPressed: viewModel.canProceed ? () async => await viewModel.nextStep() : null,
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
  Logger get log => GetIt.I.get<Logger>();
  final HDWalletProvider _hdWallet = GetIt.I.get<HDWalletProvider>();
  final BitwindowRPC _api = GetIt.I.get<BitwindowRPC>();
  final MainchainRPC _rpc = GetIt.I.get<MainchainRPC>();
  
  // Session tracking for in-progress key generation
  final Set<int> _sessionUsedAccountIndices = <int>{};

  // Network configuration (simplified)
  final bool isMainnet = const String.fromEnvironment('BITWINDOW_NETWORK', defaultValue: 'signet') == 'mainnet';
  
  // Network utility methods
  String get coinType => isMainnet ? "0'" : "1'";
  String get xpubPrefix => isMainnet ? 'xpub' : 'tpub';
  String get bech32HRP => isMainnet ? 'bc' : 'tb';
  
  // Validate xPub format
  bool _isValidXpub(String xpub) {
    if (xpub.isEmpty) return false;
    
    // Check prefix
    if (!xpub.startsWith(xpubPrefix)) return false;
    
    // Check length (xpubs are typically 111 characters, but allow some flexibility)
    if (xpub.length < 100 || xpub.length > 120) return false;
    
    // Check if it's valid base58
    try {
      base58.decode(xpub);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Check if a derivation path represents a wallet-generated key
  bool _isWalletGeneratedPath(String path) {
    // Extract account index from path like "m/84'/1'/8000'"
    final match = RegExp(r"m/84'/[01]'/(\d+)'").firstMatch(path);
    if (match != null) {
      final accountIndex = int.tryParse(match.group(1)!);
      return accountIndex != null && accountIndex >= 8000;
    }
    return false;
  }


  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mController = TextEditingController(text: '2');
  final TextEditingController nController = TextEditingController(text: '2');
  final TextEditingController ownerController = TextEditingController();
  final TextEditingController pubkeyController = TextEditingController();
  final TextEditingController pathController = TextEditingController(text: "m/84'/1'/8000'");
  final TextEditingController feeController = TextEditingController(text: '0.001');
  final TextEditingController fingerprintController = TextEditingController();

  // State
  int currentStep = 0;
  String? modalError;
  String? parameterError;
  List<MultisigKey> keys = [];
  bool shouldEncrypt = false; // Default to false (base64 only)
  bool _lastKeyWasGenerated = false; // Track if the last key operation was wallet generation
  
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
      pathController.text.isNotEmpty &&
      _hdWallet.isInitialized &&
      _hdWallet.mnemonic != null;

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
    
    // Listen for name changes to clear error state
    nameController.addListener(_clearNameError);
    
    // Run initial validation to recognize default values
    _validateParameters();
    
    notifyListeners();
  }

  void _clearNameError() {
    // Clear name-related errors when user types in the name field
    if (parameterError != null && parameterError!.contains('already exists')) {
      parameterError = null;
    }
    // Always notify listeners when name changes to update canProceed state
    notifyListeners();
  }

  void _validateParameters() {
    final mValue = int.tryParse(mController.text);
    final nValue = int.tryParse(nController.text);
    
    // Clear name-related errors when user modifies parameters
    if (parameterError != null && parameterError!.contains('already exists')) {
      parameterError = null;
    }
    
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

  Future<bool> _isNameAlreadyUsed(String name) async {
    try {
      final appDir = await Environment.datadir();
      final bitdriveDir = path.join(appDir.path, 'bitdrive');
      final jsonFile = File(path.join(bitdriveDir, 'multisig', 'multisig.json'));
      
      if (!await jsonFile.exists()) {
        return false; // No existing groups, name is available
      }
      
      final content = await jsonFile.readAsString();
      if (content.trim().isEmpty) {
        return false; // Empty file, name is available
      }
      
      final jsonData = json.decode(content) as Map<String, dynamic>;
      
      final existingGroups = jsonData['groups'] as List<dynamic>? ?? [];
      
      // Check if any existing group has the same name (case-insensitive)
      return existingGroups.any((group) => 
        (group['name'] as String?)?.toLowerCase() == name.toLowerCase(),
      );
      
    } catch (e) {
      // If there's an error reading the file, assume name is available
      GetIt.I.get<Logger>().w('Error checking existing group names: $e');
      return false;
    }
  }

  Future<void> nextStep() async {
    if (!canProceed) return;
    
    // Check if the name is already used
    final nameAlreadyUsed = await _isNameAlreadyUsed(nameController.text.trim());
    if (nameAlreadyUsed) {
      parameterError = 'A multisig group with this name already exists';
      notifyListeners();
      return;
    }
    
    // Clear any previous errors and proceed
    parameterError = null;
    currentStep = 1;
    
    // Reset session tracking when starting key creation
    _sessionUsedAccountIndices.clear();
    
    ownerController.text = 'MyKey0';
    // Set default path for manual entry (external keys) to match enforcer pattern
    pathController.text = "m/84'/1'/0'/0/0";
    notifyListeners();
    
    // Auto-generate the first wallet key
    generatePublicKey();
  }

  void goBack() {
    if (currentStep > 0) {
      currentStep--;
      notifyListeners();
    }
  }




  Future<void> generatePublicKey() async {
    try {
      modalError = null;
      setBusy(true);
      
      // Ensure HD wallet is initialized before proceeding
      if (!_hdWallet.isInitialized) {
        await _hdWallet.init();
      }
      
      // Check if initialization was successful
      if (!_hdWallet.isInitialized || _hdWallet.mnemonic == null) {
        throw Exception('HD Wallet not properly initialized. Please ensure wallet is set up.');
      }
      
      // Now check if we can generate the key
      if (!canGenerateKey) return;
      
      // Get the next available account index (considering session usage)
      final accountIndex = await _hdWallet.getNextAccountIndex(_sessionUsedAccountIndices);
      
      // Track this index in the session
      _sessionUsedAccountIndices.add(accountIndex);
      
      // Generate wallet xPub
      final keyInfo = await _hdWallet.generateWalletXpub(accountIndex, isMainnet);
      
      if (keyInfo.isEmpty) {
        throw Exception('Failed to generate xPub');
      }
      
      
      // Update controllers
      pubkeyController.text = keyInfo['xpub'] ?? '';
      pathController.text = keyInfo['derivation_path'] ?? '';
      fingerprintController.text = keyInfo['fingerprint'] ?? '';
      
      // Update the owner name to show relative index
      final relativeIndex = accountIndex - 8000;
      ownerController.text = 'MyKey$relativeIndex';
      
      // Mark that this was a wallet-generated key
      _lastKeyWasGenerated = true;
      
    } catch (e) {
      MultisigLogger.error('Failed to generate key: $e');
      modalError = 'Failed to generate xPub: $e';
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  Future<void> pastePublicKey() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text != null) {
        final xpub = clipboardData!.text!.trim();
        
        // Validate xPub format
        if (!_isValidXpub(xpub)) {
          modalError = 'Invalid xPub format. Expected valid $xpubPrefix format.';
          notifyListeners();
          return;
        }
        
        pubkeyController.text = xpub;
        
        // For external keys, prompt for fingerprint if not provided
        if (!pathController.text.contains("8000'")) {
          // This is an external key, clear fingerprint
          fingerprintController.clear();
        }
        
        // Mark that this was NOT a wallet-generated key
        _lastKeyWasGenerated = false;
        
        notifyListeners();
      }
    } catch (e) {
      modalError = 'Failed to paste from clipboard: $e';
      notifyListeners();
    }
  }

  Future<void> importKeyFromFile(BuildContext context) async {
    try {
      // Get available key files from bitdrive directory
      final keyFiles = await _getAvailableKeyFiles();
      
      if (keyFiles.isEmpty) {
        modalError = 'No .conf key files found in bitdrive/multisig or bitdrive/multisig/imported_keys directories. Use "Get Key" to generate keys first.';
        notifyListeners();
        return;
      }

      // Show dialog to select key file
      final selectedFile = await showDialog<String>(
        context: context,
        builder: (context) => _buildKeyFileSelectionDialog(context, keyFiles),
      );

      if (selectedFile == null) return;

      // Load and parse the selected key file
      final keyData = await _loadKeyFile(selectedFile);
      
      // Populate the form fields with the imported data
      ownerController.text = keyData['owner'] ?? '';
      pubkeyController.text = keyData['xpub'] ?? keyData['pubkey'] ?? '';
      pathController.text = keyData['path'] ?? '';
      fingerprintController.text = keyData['fingerprint'] ?? '';

      // Mark that this was NOT a wallet-generated key (imported from file)
      _lastKeyWasGenerated = false;

      // Copy the imported key to imported_keys directory
      await _copyKeyToImportedKeys(selectedFile, keyData);

      modalError = null;
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Key imported from ${path.basename(selectedFile)} and copied to imported_keys'),
            backgroundColor: Colors.green,
          ),
        );
      }

    } catch (e) {
      modalError = 'Failed to import key: $e';
      notifyListeners();
    }
  }

  Future<List<String>> _getAvailableKeyFiles() async {
    final appDir = await Environment.datadir();
    final multisigDir = Directory(path.join(appDir.path, 'bitdrive', 'multisig'));
    final importedKeysDir = Directory(path.join(appDir.path, 'bitdrive', 'multisig', 'imported_keys'));
    
    List<String> allKeyFiles = [];
    
    // Wallet-generated keys in multisig directory
    final multisigFiles = await multisigDir.list().toList();
    final walletKeys = multisigFiles
        .where((file) => file is File && file.path.endsWith('.conf'))
        .map((file) => file.path)
        .toList();
    allKeyFiles.addAll(walletKeys);
    
    // Imported keys in imported_keys subdirectory
    final importedFiles = await importedKeysDir.list().toList();
    final importedKeys = importedFiles
        .where((file) => file is File && file.path.endsWith('.conf'))
        .map((file) => file.path)
        .toList();
    allKeyFiles.addAll(importedKeys);
    
    return allKeyFiles;
  }

  Future<Map<String, dynamic>> _loadKeyFile(String filePath) async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();
      final jsonData = jsonDecode(content) as Map<String, dynamic>;
      
      // Validate that it has the required fields
      if (jsonData['xpub'] == null && jsonData['pubkey'] == null) {
        throw Exception('Key file missing xpub/pubkey field');
      }
      
      return jsonData;
    } catch (e) {
      throw Exception('Failed to load key file: $e');
    }
  }

  Future<void> _copyKeyToImportedKeys(String sourceFilePath, Map<String, dynamic> keyData) async {
    final appDir = await Environment.datadir();
    final importedKeysDir = Directory(path.join(appDir.path, 'bitdrive', 'multisig', 'imported_keys'));
    
    // Create imported_keys directory
    await importedKeysDir.create(recursive: true);
    
    // Generate a unique filename for the imported key
    final originalFileName = path.basename(sourceFilePath);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final newFileName = '${path.basenameWithoutExtension(originalFileName)}_imported_$timestamp.conf';
    final destinationPath = path.join(importedKeysDir.path, newFileName);
    
    // Write the key data to the new location
    final destinationFile = File(destinationPath);
    await destinationFile.writeAsString(jsonEncode(keyData));
  }

  Widget _buildKeyFileSelectionDialog(BuildContext context, List<String> keyFiles) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 400),
        child: SailCard(
          title: 'Select Key File to Import',
          subtitle: 'Choose a .conf file from the bitdrive/multisig directories',
          child: SingleChildScrollView(
            child: SailColumn(
              spacing: SailStyleValues.padding12,
              children: [
                ...keyFiles.map((filePath) {
                  final fileName = path.basename(filePath);
                  return SailCard(
                    shadowSize: ShadowSize.none,
                    child: ListTile(
                      title: Text(fileName, style: TextStyle(color: Colors.white)),
                      subtitle: Text(filePath),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => Navigator.of(context).pop(filePath),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                SailButton(
                  label: 'Cancel',
                  onPressed: () async => Navigator.of(context).pop(),
                  variant: ButtonVariant.secondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> saveKey() async {
    if (!canSaveKey) return;

    // Check if we've reached the maximum number of keys
    if (keys.length >= n) {
      modalError = 'Cannot add more than $n keys to this multisig group';
      notifyListeners();
      return;
    }

    // Check for duplicate xPubs
    if (keys.any((key) => key.xpub == pubkeyController.text)) {
      modalError = 'This xPub has already been added';
      notifyListeners();
      return;
    }
    
    // Validate xPub
    final xpub = pubkeyController.text;
    if (!_isValidXpub(xpub)) {
      modalError = 'Invalid xPub format';
      notifyListeners();
      return;
    }

    // Determine if this is a wallet-generated key
    // ONLY mark as wallet key if it was generated by the wallet in this session
    final currentPath = pathController.text;
    final isWalletKey = _lastKeyWasGenerated;

    // Validate wallet-generated keys have proper path
    if (isWalletKey && !_isWalletGeneratedPath(currentPath)) {
      modalError = 'Invalid wallet key: path does not match wallet generation pattern';
      notifyListeners();
      return;
    }

    // Extract origin path (remove 'm/')
    final originPath = currentPath.startsWith('m/') ? currentPath.substring(2) : currentPath;

    final key = MultisigKey(
      owner: ownerController.text,
      xpub: pubkeyController.text,
      derivationPath: currentPath,
      fingerprint: fingerprintController.text.isNotEmpty ? fingerprintController.text : null,
      originPath: originPath,
      isWallet: isWalletKey,
    );


    keys.add(key);
    
    
    // Clear form and prepare for next key (only if we haven't reached the limit)
    if (keys.length < n) {
      ownerController.text = 'External Key ${keys.length + 1}';
      pubkeyController.clear();
      fingerprintController.clear();
      
      // Reset path to the default manual entry format for external keys
      pathController.text = "m/84'/$coinType/0'";
    } else {
      // Clear form but don't set defaults since we're at the limit
      ownerController.clear();
      pubkeyController.clear();
      pathController.clear();
      fingerprintController.clear();
    }
    
    // Reset the flag for next key
    _lastKeyWasGenerated = false;
    
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
      // Concatenate all xpubs in order
      final concatenatedXpubs = sortedKeys.map((key) => key.xpub).join('');
      final xpubBytes = utf8.encode(concatenatedXpubs);
      
      // Compute SHA256d (double SHA256)
      final firstHash = sha256.convert(xpubBytes).bytes;
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


      // Sort keys by BIP67 order (lexicographic order of xpubs)
      final sortedKeys = List<MultisigKey>.from(keys);
      sortedKeys.sort((a, b) => a.xpub.compareTo(b.xpub));


      // Compute multisig ID
      final multisigId = _computeMultisigId(sortedKeys);

      // Build descriptors for the multisig using centralized builder
      late MultisigDescriptors descriptors;
      
      try {
        // Create a temporary MultisigGroup object with the sorted keys
        final tempGroup = MultisigGroup(
          id: multisigId,
          name: nameController.text,
          n: n,
          m: m,
          keys: sortedKeys,
          created: DateTime.now().millisecondsSinceEpoch,
        );
        
        descriptors = await MultisigDescriptorBuilder.buildWatchOnlyDescriptors(tempGroup);
        
      } catch (e) {
        MultisigLogger.error('Failed to build descriptors: $e');
        throw Exception('Failed to build multisig descriptors: $e');
      }

      // Create multisig JSON with all required data including descriptors
      final multisigData = {
        'id': multisigId,
        'name': nameController.text,
        'n': n,
        'm': m,
        'keys': sortedKeys.map((key) => key.toJson()).toList(),
        'created': DateTime.now().millisecondsSinceEpoch,
        'descriptorReceive': descriptors.receive,
        'descriptorChange': descriptors.change,
        'watch_wallet_name': 'multisig_$multisigId',
      };


      // Create the Bitcoin Core watch-only wallet
      
      try {
        // Create the multisig wallet in Bitcoin Core with private keys enabled
        await _createMultisigWallet('multisig_$multisigId', descriptors.receive, descriptors.change);
        
      } catch (e) {
        MultisigLogger.error('Failed to create multisig wallet (continuing anyway): $e');
        // Don't fail the entire process if wallet creation fails
        // The wallet can be created later when needed
      }

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
      MultisigLogger.error('Failed to save multisig group: $e');
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
      
      final multisigDir = Directory(path.join(bitdriveDir, 'multisig'));
      if (!await multisigDir.exists()) {
        await multisigDir.create(recursive: true);
      }
      final file = File(path.join(bitdriveDir, 'multisig', 'multisig.json'));
      
      // Load existing data or create new structure
      Map<String, dynamic> jsonData = {
        'groups': [],
        'solo_keys': [],
      };
      
      if (await file.exists()) {
        final content = await file.readAsString();
        jsonData = json.decode(content) as Map<String, dynamic>;
      }
      
      // Add new group to groups array
      final groups = jsonData['groups'] as List<dynamic>;
      groups.add(multisigData);
      
      // Save updated data
      await file.writeAsString(json.encode(jsonData));
      
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


  Future<void> _createMultisigWallet(String walletName, String descriptorReceive, String descriptorChange) async {
    try {
      
      // Create wallet as watch-only (no private keys) for multisig tracking
      // Bitcoin Core automatically places wallets in the wallets subdirectory when using createwallet
      final createResult = await _rpc.callRAW('createwallet', [
        walletName,
        true,   // disable_private_keys - DISABLE private keys (watch-only)
        true,   // blank (start empty)
        '',     // passphrase (empty)
        false,  // avoid_reuse 
        true,   // descriptors (modern descriptor wallet format)
        false,  // load_on_startup
      ]);
      
      
      // Import descriptors using direct wallet RPC call
      
      // Load the wallet first to make sure it's active
      try {
        await _rpc.callRAW('loadwallet', [walletName]);
      } catch (e) {
        // Wallet might already be loaded, continue
      }
      
      // Import descriptors to enable UTXO tracking
      
      final descriptorsToImport = [
        {
          'desc': descriptorReceive,
          'active': true,
          'internal': false,
          'timestamp': 'now',
          'range': [0, 999],
          // Don't specify watchonly - let Bitcoin Core handle it based on available keys
        },
        {
          'desc': descriptorChange,
          'active': true,
          'internal': true,
          'timestamp': 'now',
          'range': [0, 999],
          // Don't specify watchonly - let Bitcoin Core handle it based on available keys
        },
      ];
      
      try {
        // Use WalletRPCManager to import descriptors
        final walletManager = WalletRPCManager();
        final importResult = await walletManager.importDescriptors(walletName, descriptorsToImport);
        
        // Check if import was successful
        for (int i = 0; i < importResult.length; i++) {
          final result = importResult[i] as Map<String, dynamic>;
          final success = result['success'] as bool? ?? false;
          final desc = i == 0 ? 'receive' : 'change';
          
          if (success) {
          } else {
            final error = result['error'] ?? 'Unknown error';
            MultisigLogger.error('Failed to import $desc descriptor: $error');
            throw Exception('Failed to import $desc descriptor: $error');
          }
        }
        
        // Skip rescan here - wallet is just created and has no UTXOs yet
        // Rescan will be done when funding the wallet
        
      } catch (e) {
        MultisigLogger.error('Failed to import descriptors: $e');
        throw Exception('Failed to import descriptors for wallet $walletName: $e');
      }
      
    } catch (e) {
      
      // Check if it's just a "wallet already exists" error
      if (e.toString().contains('already exists') || e.toString().contains('Database already exists')) {
        return; // Not a fatal error
      }
      
      // Re-throw for other errors
      throw Exception('Failed to create multisig wallet in wallets directory: $e');
    }
  }


  @override
  void dispose() {
    // Clean up session tracking when modal is disposed
    _sessionUsedAccountIndices.clear();
    
    nameController.removeListener(_clearNameError);
    nameController.dispose();
    mController.dispose();
    nController.dispose();
    ownerController.dispose();
    pubkeyController.dispose();
    pathController.dispose();
    feeController.dispose();
    fingerprintController.dispose();
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
                                SailText.secondary12('xPub: ${key.xpub.substring(0, 20)}...'),
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
          xpub: key.xpub,
          derivationPath: key.derivationPath,
          fingerprint: key.fingerprint,
          originPath: key.originPath,
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
      
      final multisigDir = Directory(path.join(bitdriveDir, 'multisig'));
      if (!await multisigDir.exists()) {
        await multisigDir.create(recursive: true);
      }
      final file = File(path.join(bitdriveDir, 'multisig', 'multisig.json'));
      
      // Load existing data or create new structure
      Map<String, dynamic> jsonData = {
        'groups': [],
        'solo_keys': [],
      };
      
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.trim().isNotEmpty) {
          jsonData = json.decode(content) as Map<String, dynamic>;
        }
      }
      
      // Check if this multisig group already exists (by ID)
      final groups = jsonData['groups'] as List<dynamic>;
      final groupId = multisigData['id'] as String;
      final existingIndex = groups.indexWhere((group) => group['id'] == groupId);
      
      if (existingIndex != -1) {
        // Update existing group
        groups[existingIndex] = multisigData;
      } else {
        // Add new group
        groups.add(multisigData);
      }
      
      // Save updated data
      await file.writeAsString(json.encode(jsonData));
      
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

