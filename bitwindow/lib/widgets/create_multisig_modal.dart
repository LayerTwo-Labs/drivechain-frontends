import 'dart:io';
import 'dart:convert';

import 'package:bitwindow/env.dart';
import 'package:bitwindow/providers/hd_wallet_provider.dart';
import 'package:bitwindow/providers/bitdrive_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class CreateMultisigModal extends StatelessWidget {
  const CreateMultisigModal({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CreateMultisigModalViewModel>.reactive(
      viewModelBuilder: () => CreateMultisigModalViewModel(),
      onViewModelReady: (model) => model.init(),
      builder: (context, model, child) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SailCard(
              title: model.isFirstPage
                  ? 'Create Multisig Lounge'
                  : 'Create ${model.n} of ${model.m} Multisig Lounge: ${model.loungeName}',
              subtitle: model.isFirstPage ? 'Configure your multisig lounge settings' : 'Add keys for the participants',
              error: model.modelError,
              padding: true,
              child: model.isFirstPage ? _buildFirstPage(context, model) : _buildSecondPage(context, model),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFirstPage(
    BuildContext context,
    CreateMultisigModalViewModel model,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Lounge Name text field
        SailTextField(
          controller: model.loungeNameController,
          hintText: 'Enter lounge name',
        ),
        const SailSpacing(SailStyleValues.padding16),

        // N and M selection
        SailRow(
          spacing: SailStyleValues.padding16,
          children: [
            Expanded(
              child: SailColumn(
                spacing: SailStyleValues.padding08,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SailText.primary13('Required Signatures (N)'),
                  SailDropdownButton<int>(
                    value: model.n,
                    items: List.generate(model.m, (i) => i + 1)
                        .map(
                          (n) => SailDropdownItem<int>(value: n, label: '$n'),
                        )
                        .toList(),
                    onChanged: model.setN,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SailColumn(
                spacing: SailStyleValues.padding08,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SailText.primary13('Total Participants (M)'),
                  SailDropdownButton<int>(
                    value: model.m,
                    items: List.generate(15, (i) => i + 2)
                        .map(
                          (m) => SailDropdownItem<int>(value: m, label: '$m'),
                        )
                        .toList(),
                    onChanged: model.setM,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SailSpacing(SailStyleValues.padding16),

        // Action buttons
        SailRow(
          spacing: SailStyleValues.padding08,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SailButton(
              label: 'Next',
              onPressed: model.canGoToNextPage ? () async => await model.goToSecondPage() : null,
              variant: model.canGoToNextPage ? ButtonVariant.primary : ButtonVariant.secondary,
            ),
            SailButton(
              label: 'Cancel',
              variant: ButtonVariant.ghost,
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSecondPage(
    BuildContext context,
    CreateMultisigModalViewModel model,
  ) {
    final theme = SailTheme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Key input area
        SailRow(
          spacing: SailStyleValues.padding08,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SailButton(
              label: 'Use My Key',
              onPressed: () async => await model.useMyKey(),
              variant: ButtonVariant.secondary,
            ),
            SizedBox(
              width: 120,
              child: SailTextField(
                controller: model.keyNameController,
                hintText: 'Key Name',
                size: TextFieldSize.small,
                maxLines: 1,
              ),
            ),
            Expanded(
              flex: 3,
              child: SailTextField(
                controller: model.publicKeyController,
                hintText: 'Public Key',
                size: TextFieldSize.small,
                maxLines: 1,
              ),
            ),
            SailButton(
              label: 'Lock',
              onPressed: model.canLockKey ? () async => await model.lockKey() : null,
              variant: model.canLockKey ? ButtonVariant.primary : ButtonVariant.secondary,
            ),
          ],
        ),
        if (model.keyNameError != null) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0, left: 128.0),
              child: SailText.primary13(
                model.keyNameError!,
                color: theme.colors.error,
              ),
            ),
          ),
        ],
        if (model.publicKeyError != null) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0, left: 128.0),
              child: SailText.primary13(
                model.publicKeyError!,
                color: theme.colors.error,
              ),
            ),
          ),
        ],
        const SailSpacing(SailStyleValues.padding16),

        // Added keys display
        if (model.keys.isNotEmpty) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: SailText.primary13(
              'Added Keys (${model.keys.length}/${model.m})',
            ),
          ),
          const SailSpacing(SailStyleValues.padding08),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: model.keys.map((key) {
              return SailButton(
                label: key.name,
                onPressed: () async => await model.showKeyDetails(context, key),
                variant: ButtonVariant.secondary,
              );
            }).toList(),
          ),
          const SailSpacing(SailStyleValues.padding16),
        ],

        // Action buttons
        SailRow(
          spacing: SailStyleValues.padding08,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SailButton(
              label: 'Save',
              onPressed: model.canCreate ? () async => await model.create(context) : null,
              variant: model.canCreate ? ButtonVariant.primary : ButtonVariant.secondary,
            ),
            SailButton(
              label: 'Back',
              variant: ButtonVariant.secondary,
              onPressed: () async => await model.goToFirstPage(),
            ),
            SailButton(
              label: 'Cancel',
              variant: ButtonVariant.ghost,
              onPressed: () async {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ],
    );
  }
}

class MultisigKey {
  final String name;
  final String publicKey;

  MultisigKey({required this.name, required this.publicKey});
}

class CreateMultisigModalViewModel extends BaseViewModel {
  final TextEditingController loungeNameController = TextEditingController();
  final TextEditingController keyNameController = TextEditingController();
  final TextEditingController publicKeyController = TextEditingController();
  final HDWalletProvider hdWalletProvider = GetIt.I.get<HDWalletProvider>();
  final BitDriveProvider bitDriveProvider = GetIt.I.get<BitDriveProvider>();
  Logger get log => GetIt.I.get<Logger>();

  int n = 2; // Required signatures
  int m = 2; // Total participants
  int nextP = 0;
  bool isFirstPage = true;
  List<MultisigKey> keys = [];
  String? keyNameError;
  String? publicKeyError;

  String get loungeName => loungeNameController.text;

  bool get canLockKey =>
      keyNameController.text.isNotEmpty && publicKeyController.text.isNotEmpty && keyNameError == null;

  bool get canCreate => keys.length == m;

  bool get canGoToNextPage => loungeNameController.text.trim().isNotEmpty;

  // Define the multisig derivation path base
  String get derivationPath => "m/44'/0'/0'/${7000 + nextP}";

  Future<void> init() async {
    try {
      // Load the HD wallet provider
      await hdWalletProvider.init();

      // Initialize BitDrive if needed
      if (!bitDriveProvider.initialized) {
        await bitDriveProvider.init();
      }

      // Find the next available P value
      nextP = await _getNextP();

      // Add listener to text controllers to update UI when text changes
      loungeNameController.addListener(() {
        notifyListeners();
      });

      keyNameController.addListener(() {
        validateKeyNameFormat(keyNameController.text);
      });

      notifyListeners();
    } catch (e) {
      log.e('Error initializing multisig modal: $e');
      setError(e.toString());
    }
  }

  Future<int> _getNextP() async {
    try {
      // Query BitDrive files for existing configurations
      int maxP = -1;

      final appDir = await Environment.datadir();
      final multisigDir = '${appDir.path}/bitdrive/multisig';
      final dir = Directory(multisigDir);

      if (await dir.exists()) {
        final configFile = File('$multisigDir/multisig.conf');
        if (await configFile.exists()) {
          final lines = await configFile.readAsLines();

          // Find highest P value
          for (final line in lines) {
            if (line.trim().isEmpty) continue;

            final parts = line.split('=');
            if (parts.length != 2) continue;

            final pStr = parts[0].trim();
            if (!pStr.startsWith('P')) continue;

            try {
              final p = int.parse(pStr.substring(1));
              maxP = p > maxP ? p : maxP;
            } catch (_) {
              continue;
            }
          }
        }
      }

      return maxP + 1;
    } catch (e) {
      log.e('Error getting next P value: $e');
      return 0;
    }
  }

  void setN(int? value) {
    if (value != null && value <= m) {
      n = value;
      notifyListeners();
    }
  }

  void setM(int? value) {
    if (value != null) {
      m = value;
      // Adjust n if it's now greater than m
      if (n > m) {
        n = m;
      }
      keys = [];
      notifyListeners();
    }
  }

  void validateKeyNameFormat(String value) {
    // Only validate the format (spaces), not existence in the list
    if (value.contains(' ')) {
      keyNameError = 'Spaces not allowed';
    } else {
      keyNameError = null;
    }
    notifyListeners();
  }

  // Validate both key name and public key uniqueness before locking
  bool validateKeyUniqueness() {
    final keyName = keyNameController.text;
    final publicKey = publicKeyController.text;

    // Check for key name uniqueness
    if (keys.any((key) => key.name == keyName)) {
      keyNameError = 'Name already used';
      publicKeyError = null;
      notifyListeners();
      return false;
    }

    // Check for key public key uniqueness
    if (keys.any((key) => key.publicKey == publicKey)) {
      keyNameError = null;
      publicKeyError = 'Key already added to this multisig';
      notifyListeners();
      return false;
    }

    // All validations passed
    keyNameError = null;
    publicKeyError = null;
    notifyListeners();
    return true;
  }

  Future<void> goToSecondPage() async {
    if (!canGoToNextPage) return;

    isFirstPage = false;

    // Prepare the key list if empty
    if (keys.isEmpty) {
      // Add default key if needed
      keyNameController.clear();
      publicKeyController.clear();
      keyNameError = null;
      publicKeyError = null;
    }

    notifyListeners();
  }

  Future<void> goToFirstPage() async {
    isFirstPage = true;
    notifyListeners();
  }

  Future<void> useMyKey() async {
    try {
      setBusy(true);

      // First, make sure wallet is loaded
      await hdWalletProvider.loadMnemonic();
      if (hdWalletProvider.mnemonic == null) {
        throw Exception("Couldn't load wallet mnemonic");
      }

      // Derive the public key from the multisig path
      final keyInfo = await hdWalletProvider.deriveKeyInfo(
        hdWalletProvider.mnemonic!,
        derivationPath,
      );

      // Get the derived public key
      final pubKey = keyInfo['publicKey'];
      if (pubKey == null || pubKey.isEmpty) {
        throw Exception('Failed to derive public key');
      }

      // Set the derived key info (validation will happen on lock)
      keyNameController.text = 'MyKey';
      publicKeyController.text = pubKey;

      // Clear any previous error
      keyNameError = null;
      publicKeyError = null;

      notifyListeners();
    } catch (e) {
      log.e('Error deriving key: $e');
      setError(e.toString());
    } finally {
      setBusy(false);
    }
  }

  Future<void> lockKey() async {
    if (!canLockKey) return;

    // Validate uniqueness of both name and public key
    if (!validateKeyUniqueness()) {
      return;
    }

    // All validations passed, add the key
    keys.add(
      MultisigKey(
        name: keyNameController.text,
        publicKey: publicKeyController.text,
      ),
    );

    // Clear input fields
    keyNameController.clear();
    publicKeyController.clear();
    keyNameError = null;
    publicKeyError = null;

    notifyListeners();
  }

  Future<void> showKeyDetails(BuildContext context, MultisigKey key) async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SailCard(
            title: key.name,
            subtitle: 'Public Key Details',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SailText.secondary13(key.publicKey, monospace: true),
                const SailSpacing(SailStyleValues.padding16),
                SailRow(
                  spacing: SailStyleValues.padding08,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SailButton(
                      label: 'Copy',
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: key.publicKey),
                        );
                        if (context.mounted) {
                          showSnackBar(
                            context,
                            'Public key copied to clipboard',
                          );
                        }
                      },
                      variant: ButtonVariant.secondary,
                    ),
                    SailButton(
                      label: 'Close',
                      onPressed: () async {
                        Navigator.of(context).pop();
                      },
                      variant: ButtonVariant.primary,
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

  Future<void> create(BuildContext context) async {
    if (!canCreate) return;

    setBusy(true);
    try {
      // Validate lounge name
      final name = loungeNameController.text.trim();
      if (name.isEmpty) {
        throw Exception('Lounge name cannot be empty');
      }

      // Create multisig config in JSON format
      final configData = {
        'p': nextP,
        'name': name,
        'n': n,
        'm': m,
        'keys': keys.map((k) => {'name': k.name, 'publicKey': k.publicKey}).toList(),
      };

      final jsonConfig = jsonEncode(configData);

      // Store the configuration using BitDrive with multisig flag
      log.i('Storing multisig config in BitDrive');
      await bitDriveProvider.setTextContent(jsonConfig, isMultisig: true);
      bitDriveProvider.setEncryption(false); // Don't encrypt to allow for easier recovery
      await bitDriveProvider.store(isMultisig: true);

      // Create multisig directory if it doesn't exist (for autoRestore)
      final appDir = await Environment.datadir();
      final multisigDir = '${appDir.path}/bitdrive/multisig';
      final dir = Directory(multisigDir);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      if (context.mounted) {
        showSnackBar(context, 'Multisig lounge created successfully');
        Navigator.of(context).pop();
      }
    } catch (e) {
      log.e('Error creating multisig lounge: $e');
      setError(e.toString());
    } finally {
      setBusy(false);
    }
  }

  @override
  void dispose() {
    loungeNameController.removeListener(notifyListeners);
    loungeNameController.dispose();
    keyNameController.removeListener(() => validateKeyNameFormat(keyNameController.text));
    keyNameController.dispose();
    publicKeyController.dispose();
    super.dispose();
  }
}
