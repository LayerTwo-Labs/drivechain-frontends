import 'dart:convert';
import 'dart:io';

import 'package:bitwindow/env.dart';
import 'package:bitwindow/models/multisig_group.dart';
import 'package:bitwindow/providers/hd_wallet_provider.dart';
import 'package:bitwindow/providers/multisig_provider.dart';
import 'package:bs58/bs58.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class MultisigKey {
  final String owner;
  final String xpub;
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
        'path': derivationPath,
        'fingerprint': fingerprint,
        'origin_path': originPath,
        'is_wallet': isWallet,
        if (activePSBTs != null) 'active_psbts': activePSBTs,
        if (initialPSBTs != null) 'initial_psbts': initialPSBTs,
      };

  factory MultisigKey.fromJson(Map<String, dynamic> json) => MultisigKey(
        owner: json['owner'],
        xpub: json['xpub'] ?? json['pubkey'],
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
                      SailCheckbox(
                        label: 'Do not store on chain (Not recommended)',
                        value: viewModel.shouldNotBroadcast,
                        onChanged: (value) => viewModel.setShouldNotBroadcast(value),
                      ),
                      if (viewModel.shouldNotBroadcast)
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
                                  Icons.info_outlined,
                                  color: context.sailTheme.colors.orange,
                                  size: 16,
                                ),
                                Expanded(
                                  child: SailText.secondary12(
                                    'If you check this box, you must manually back up the multisig configuration. This is very risky but in some situations has a privacy benefit',
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
                                suffixWidget: SailButton(
                                  label: 'Paste',
                                  variant: ButtonVariant.ghost,
                                  small: true,
                                  onPressed: viewModel.keys.length < viewModel.n
                                      ? () async => await viewModel.pastePublicKey()
                                      : null,
                                ),
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
                                  SailButton(
                                    label: 'Generate Wallet xPub',
                                    onPressed: viewModel.canGenerateKey && viewModel.keys.length < viewModel.n
                                        ? () async => await viewModel.generatePublicKey()
                                        : null,
                                    variant: ButtonVariant.secondary,
                                  ),
                                  SailButton(
                                    label: 'Import Key',
                                    onPressed: viewModel.keys.length < viewModel.n
                                        ? () async => await viewModel.importKeyFromFile(context)
                                        : null,
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: SailColumn(
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

  final Set<int> _sessionUsedAccountIndices = <int>{};

  final bool isMainnet = const String.fromEnvironment('BITWINDOW_NETWORK', defaultValue: 'signet') == 'mainnet';

  String get coinType => isMainnet ? "0'" : "1'";
  String get xpubPrefix => isMainnet ? 'xpub' : 'tpub';
  String get bech32HRP => isMainnet ? 'bc' : 'tb';

  bool _isValidXpub(String xpub) {
    if (xpub.isEmpty) return false;

    if (!xpub.startsWith(xpubPrefix)) return false;
    if (xpub.length < 100 || xpub.length > 120) return false;
    try {
      base58.decode(xpub);
      return true;
    } catch (e) {
      return false;
    }
  }

  bool _isWalletGeneratedPath(String path) {
    final match = RegExp(r"m/84'/[01]'/(\d+)'").firstMatch(path);
    if (match != null) {
      final accountIndex = int.tryParse(match.group(1)!);
      return accountIndex != null && accountIndex >= 8000;
    }
    return false;
  }

  String _generateUniqueKeyName({String baseName = 'MyKey'}) {
    int index = 0;
    String proposedName = '$baseName$index';

    while (keys.any((key) => key.owner == proposedName)) {
      index++;
      proposedName = '$baseName$index';
    }

    return proposedName;
  }

  final TextEditingController nameController = TextEditingController();
  final TextEditingController mController = TextEditingController(text: '2');
  final TextEditingController nController = TextEditingController(text: '2');
  final TextEditingController ownerController = TextEditingController();
  final TextEditingController pubkeyController = TextEditingController();
  final TextEditingController pathController = TextEditingController(text: "m/84'/1'/8000'");
  final TextEditingController fingerprintController = TextEditingController();

  int currentStep = 0;
  String? modalError;
  String? parameterError;
  List<MultisigKey> keys = [];
  bool shouldNotBroadcast = false;
  bool _lastKeyWasGenerated = false;
  String? _importedOriginPath;

  static const int MULTISIG_DERIVATION_INDEX = 8000;
  static const String MULTISIG_DERIVATION_BASE = "m/84'/1'/0'/0/";
  static const int MULTISIG_FLAG = 0x02;

  int get m => int.tryParse(mController.text) ?? 0;
  int get n => int.tryParse(nController.text) ?? 0;

  bool get canProceed => nameController.text.isNotEmpty && m > 0 && n > 0 && m <= n && parameterError == null;

  bool get canGenerateKey =>
      ownerController.text.isNotEmpty &&
      pathController.text.isNotEmpty &&
      _hdWallet.isInitialized &&
      _hdWallet.mnemonic != null;

  bool get canSaveKey =>
      ownerController.text.isNotEmpty &&
      pubkeyController.text.isNotEmpty &&
      pathController.text.isNotEmpty &&
      keys.length < n;

  bool get canSaveGroup => keys.length == n;

  void init() {
    mController.addListener(_validateParameters);
    nController.addListener(_validateParameters);
    nameController.addListener(_clearNameError);
    _validateParameters();

    notifyListeners();
  }

  void _clearNameError() {
    if (parameterError != null && parameterError!.contains('already exists')) {
      parameterError = null;
    }
    notifyListeners();
  }

  void _validateParameters() {
    final mValue = int.tryParse(mController.text);
    final nValue = int.tryParse(nController.text);

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
        return false;
      }

      final content = await jsonFile.readAsString();
      if (content.trim().isEmpty) {
        return false;
      }

      final jsonData = json.decode(content) as Map<String, dynamic>;

      final existingGroups = jsonData['groups'] as List<dynamic>? ?? [];
      return existingGroups.any(
        (group) => (group['name'] as String?)?.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return false;
    }
  }

  Future<void> nextStep() async {
    if (!canProceed) return;

    final nameAlreadyUsed = await _isNameAlreadyUsed(nameController.text.trim());
    if (nameAlreadyUsed) {
      parameterError = 'A multisig group with this name already exists';
      notifyListeners();
      return;
    }

    parameterError = null;
    currentStep = 1;
    _sessionUsedAccountIndices.clear();

    ownerController.text = _generateUniqueKeyName();
    pathController.text = "m/84'/1'/0'/0/0";
    notifyListeners();
    await generatePublicKey();
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

      if (!_hdWallet.isInitialized) {
        await _hdWallet.init();
      }

      if (!_hdWallet.isInitialized || _hdWallet.mnemonic == null) {
        throw Exception('HD Wallet not properly initialized. Please ensure wallet is set up.');
      }

      if (!canGenerateKey) return;

      final accountIndex = await _hdWallet.getNextAccountIndex(_sessionUsedAccountIndices);
      _sessionUsedAccountIndices.add(accountIndex);
      final keyInfo = await _hdWallet.generateWalletXpub(accountIndex, isMainnet);

      if (keyInfo.isEmpty) {
        throw Exception('Failed to generate xPub');
      }

      pubkeyController.text = keyInfo['xpub'] ?? '';
      pathController.text = keyInfo['derivation_path'] ?? '';
      fingerprintController.text = keyInfo['fingerprint'] ?? '';
      ownerController.text = _generateUniqueKeyName();
      _lastKeyWasGenerated = true;
    } catch (e) {
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

        if (!_isValidXpub(xpub)) {
          modalError = 'Invalid xPub format. Expected valid $xpubPrefix format.';
          notifyListeners();
          return;
        }

        pubkeyController.text = xpub;

        if (!pathController.text.contains("8000'")) {
          fingerprintController.clear();
        }

        _lastKeyWasGenerated = false;
        modalError = null;

        notifyListeners();
      }
    } catch (e) {
      modalError = 'Failed to paste from clipboard: $e';
      notifyListeners();
    }
  }

  Future<void> importKeyFromFile(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'conf'],
        dialogTitle: 'Select Key File to Import',
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      if (file.path == null) {
        modalError = 'Could not access file path';
        notifyListeners();
        return;
      }

      final keyData = await _loadKeyFile(file.path!);

      ownerController.text = keyData['owner'] ?? keyData['name'] ?? '';
      pubkeyController.text =
          keyData['xpub'] ?? keyData['extended_public_key'] ?? keyData['pubkey'] ?? ''; // pubkey is legacy fallback
      pathController.text = keyData['path'] ?? keyData['derivation_path'] ?? keyData['bip32_path'] ?? '';
      fingerprintController.text = keyData['fingerprint'] ?? keyData['master_fingerprint'] ?? '';

      _importedOriginPath = keyData['origin_path'] ?? keyData['origin'];

      _lastKeyWasGenerated = false;

      await _copyKeyToImportedKeys(file.path!, keyData);

      modalError = null;
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Key imported from ${file.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      modalError = 'Failed to import key: $e';
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> _loadKeyFile(String filePath) async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();

      final jsonData = jsonDecode(content) as Map<String, dynamic>;

      if (jsonData['xpub'] == null && jsonData['extended_public_key'] == null && jsonData['pubkey'] == null) {
        throw Exception('Key file missing required field: must contain xpub, extended_public_key, or pubkey');
      }

      return jsonData;
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Invalid conf file format: File must be valid JSON');
      }
      throw Exception('Failed to load key file: $e');
    }
  }

  Future<void> _copyKeyToImportedKeys(String sourceFilePath, Map<String, dynamic> keyData) async {
    final appDir = await Environment.datadir();
    final importedKeysDir = Directory(path.join(appDir.path, 'bitdrive', 'multisig', 'imported_keys'));

    await importedKeysDir.create(recursive: true);

    final originalFileName = path.basename(sourceFilePath);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final newFileName = '${path.basenameWithoutExtension(originalFileName)}_imported_$timestamp.conf';
    final destinationPath = path.join(importedKeysDir.path, newFileName);

    final destinationFile = File(destinationPath);
    await destinationFile.writeAsString(jsonEncode(keyData));
  }

  Future<void> saveKey() async {
    if (!canSaveKey) return;

    if (keys.length >= n) {
      modalError = 'Cannot add more than $n keys to this multisig group';
      notifyListeners();
      return;
    }

    if (keys.any((key) => key.owner == ownerController.text)) {
      modalError = 'Key owner name "${ownerController.text}" is already used. Each key must have a unique owner name.';
      notifyListeners();
      return;
    }

    if (keys.any((key) => key.xpub == pubkeyController.text)) {
      modalError = 'This xPub has already been added';
      notifyListeners();
      return;
    }

    final xpub = pubkeyController.text;
    if (!_isValidXpub(xpub)) {
      modalError = 'Invalid xPub format';
      notifyListeners();
      return;
    }

    final currentPath = pathController.text;
    final isWalletKey = _lastKeyWasGenerated;

    if (isWalletKey && !_isWalletGeneratedPath(currentPath)) {
      modalError = 'Invalid wallet key: path does not match wallet generation pattern';
      notifyListeners();
      return;
    }

    String? originPath;
    if (_lastKeyWasGenerated) {
      originPath = currentPath.startsWith('m/') ? currentPath.substring(2) : currentPath;
    } else {
      originPath = _importedOriginPath;
    }

    final key = MultisigKey(
      owner: ownerController.text,
      xpub: pubkeyController.text,
      derivationPath: currentPath,
      fingerprint: fingerprintController.text.isNotEmpty ? fingerprintController.text : null,
      originPath: originPath,
      isWallet: isWalletKey,
    );

    keys.add(key);

    if (keys.length < n) {
      ownerController.text = _generateUniqueKeyName(baseName: 'ExtKey');
      pubkeyController.clear();
      fingerprintController.clear();

      pathController.text = "m/84'/$coinType/0'";
    } else {
      ownerController.clear();
      pubkeyController.clear();
      pathController.clear();
      fingerprintController.clear();
    }

    _lastKeyWasGenerated = false;
    _importedOriginPath = null;

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
      final concatenatedXpubs = sortedKeys.map((key) => key.xpub).join('');
      final xpubBytes = utf8.encode(concatenatedXpubs);

      final firstHash = sha256.convert(xpubBytes).bytes;
      final secondHash = sha256.convert(firstHash).bytes;

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

      final sortedKeys = List<MultisigKey>.from(keys);
      sortedKeys.sort((a, b) => a.xpub.compareTo(b.xpub));

      final multisigId = _computeMultisigId(sortedKeys);

      late MultisigDescriptors descriptors;

      try {
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
        GetIt.I.get<Logger>().e('Failed to build descriptors: $e');
        throw Exception('Failed to build multisig descriptors: $e');
      }

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

      try {
        await _createMultisigWallet('multisig_$multisigId', descriptors.receive, descriptors.change);
      } catch (e) {
        GetIt.I.get<Logger>().w('Failed to create multisig wallet: $e');
      }

      String? txid;
      if (!shouldNotBroadcast) {
        txid = await _broadcastMultisigGroup(multisigData);
        multisigData['txid'] = txid;
      }

      await _saveToLocalFile(multisigData);

      if (context.mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      GetIt.I.get<Logger>().e('Failed to save multisig group: $e');
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

      Map<String, dynamic> jsonData = {
        'groups': [],
        'solo_keys': [],
      };

      if (await file.exists()) {
        final content = await file.readAsString();
        jsonData = json.decode(content) as Map<String, dynamic>;
      }

      final groups = jsonData['groups'] as List<dynamic>;
      groups.add(multisigData);

      await file.writeAsString(json.encode(jsonData));
    } catch (e) {
      throw Exception('Failed to save to local file: $e');
    }
  }

  Future<String> _broadcastMultisigGroup(Map<String, dynamic> multisigData) async {
    try {
      final jsonBytes = Uint8List.fromList(utf8.encode(json.encode(multisigData)));

      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      const fileType = 'json';

      final metadata = ByteData(9);
      const flags = MULTISIG_FLAG;
      metadata.setUint8(0, flags);
      metadata.setUint32(1, timestamp);

      final typeBytes = utf8.encode(fileType.padRight(4, ' '));
      for (var i = 0; i < 4; i++) {
        metadata.setUint8(5 + i, typeBytes[i]);
      }

      final metadataStr = base64.encode(metadata.buffer.asUint8List());

      final contentStr = base64.encode(jsonBytes);

      final opReturnData = '$metadataStr|$contentStr';

      final address = await _api.wallet.getNewAddress();
      final txid = await _api.wallet.sendTransaction(
        {address: 10000},
        opReturnMessage: opReturnData,
      );

      return txid;
    } catch (e) {
      throw Exception('Failed to broadcast multisig group: $e');
    }
  }

  void setShouldNotBroadcast(bool value) {
    shouldNotBroadcast = value;
    notifyListeners();
  }

  Future<void> _createMultisigWallet(String walletName, String descriptorReceive, String descriptorChange) async {
    await MultisigStorage.createMultisigWallet(walletName, descriptorReceive, descriptorChange);
  }

  @override
  void dispose() {
    _sessionUsedAccountIndices.clear();

    nameController.removeListener(_clearNameError);
    nameController.dispose();
    mController.dispose();
    nController.dispose();
    ownerController.dispose();
    pubkeyController.dispose();
    pathController.dispose();
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
                      SailText.primary15('Detected Keys'),
                      SailText.secondary12(
                        'The wallet has automatically detected which keys belong to you.',
                      ),
                      SailSpacing(SailStyleValues.padding08),
                      if (viewModel.processedKeys != null)
                        ...viewModel.processedKeys!.asMap().entries.map((entry) {
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
                                    SailText.primary13('${index + 1}. ${key.owner}'),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: key.isWallet
                                            ? context.sailTheme.colors.primary.withValues(alpha: 0.1)
                                            : context.sailTheme.colors.text.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: SailText.secondary12(
                                        key.isWallet ? 'Wallet Key' : 'External Key',
                                        color: key.isWallet
                                            ? context.sailTheme.colors.primary
                                            : context.sailTheme.colors.text,
                                      ),
                                    ),
                                  ],
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
                      if (viewModel.processedKeys != null)
                        SailText.secondary12(
                          'Wallet controls ${viewModel.processedKeys!.where((k) => k.isWallet).length} of ${viewModel.processedKeys!.length} keys',
                        ),
                    ],
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
  List<MultisigKey>? processedKeys; // Keys with is_wallet flags set automatically
  bool hasFoundGroup = false;

  bool get canFetch => txidController.text.trim().isNotEmpty;

  Future<void> fetchMultisigData() async {
    try {
      modalError = null;
      setBusy(true);

      final txid = txidController.text.trim();

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

      final metadataBytes = base64.decode(parts[0]);
      if (metadataBytes.length != 9) {
        throw Exception('Invalid metadata length');
      }

      final metadata = ByteData.view(Uint8List.fromList(metadataBytes).buffer);
      final flags = metadata.getUint8(0);
      final isMultisig = (flags & 0x02) != 0; // Check multisig flag

      if (!isMultisig) {
        throw Exception('This transaction does not contain multisig data');
      }

      final contentBytes = base64.decode(parts[1]);
      final jsonString = utf8.decode(contentBytes);
      final multisigData = json.decode(jsonString) as Map<String, dynamic>;

      importedGroup = MultisigGroup.fromJson(multisigData);

      await _detectWalletKeys();

      hasFoundGroup = true;
    } catch (e) {
      modalError = 'Failed to fetch multisig data: $e';
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  Future<void> _detectWalletKeys() async {
    if (importedGroup == null) return;

    try {
      if (!_hdWallet.isInitialized) {
        await _hdWallet.init();
      }

      if (_hdWallet.mnemonic == null) {
        processedKeys = importedGroup!.keys
            .map(
              (key) => MultisigKey(
                owner: key.owner,
                xpub: key.xpub,
                derivationPath: key.derivationPath,
                fingerprint: key.fingerprint,
                originPath: key.originPath,
                isWallet: false, // No wallet available, all keys are external
              ),
            )
            .toList();
        return;
      }

      processedKeys = [];
      for (final key in importedGroup!.keys) {
        bool isWalletKey = false;

        try {
          final keyInfo = await _hdWallet.deriveKeyInfo(_hdWallet.mnemonic!, key.derivationPath);
          final derivedXpub = keyInfo['xpub'] ?? '';

          if (derivedXpub.isNotEmpty && derivedXpub == key.xpub) {
            isWalletKey = true;
          }
        } catch (e) {
          // Key derivation failed, treat as external key
        }

        processedKeys!.add(
          MultisigKey(
            owner: key.owner,
            xpub: key.xpub,
            derivationPath: key.derivationPath,
            fingerprint: key.fingerprint,
            originPath: key.originPath,
            isWallet: isWalletKey,
          ),
        );
      }
    } catch (e) {
      processedKeys = importedGroup!.keys
          .map(
            (key) => MultisigKey(
              owner: key.owner,
              xpub: key.xpub,
              derivationPath: key.derivationPath,
              fingerprint: key.fingerprint,
              originPath: key.originPath,
              isWallet: false,
            ),
          )
          .toList();
    }
  }

  void goBack() {
    hasFoundGroup = false;
    importedGroup = null;
    processedKeys = null;
    modalError = null;
    notifyListeners();
  }

  Future<void> importGroup(BuildContext context) async {
    if (importedGroup == null || processedKeys == null) return;

    try {
      modalError = null;
      setBusy(true);

      final updatedGroup = {
        'id': importedGroup!.id,
        'name': importedGroup!.name,
        'n': importedGroup!.n,
        'm': importedGroup!.m,
        'keys': processedKeys!.map((key) => key.toJson()).toList(),
        'created': importedGroup!.created,
        'txid': txidController.text.trim(), // Include the TXID from import
      };

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

      final groups = jsonData['groups'] as List<dynamic>;
      final groupId = multisigData['id'] as String;
      final existingIndex = groups.indexWhere((group) => group['id'] == groupId);

      if (existingIndex != -1) {
        groups[existingIndex] = multisigData;
      } else {
        groups.add(multisigData);
      }

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
