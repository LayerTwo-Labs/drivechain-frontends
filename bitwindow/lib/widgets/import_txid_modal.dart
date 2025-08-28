import 'dart:convert';

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
                        onPressed: viewModel.isBusy
                            ? null
                            : () async {
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
  late final VoidCallback _textListener;

  ImportTxidModalViewModel() {
    _textListener = () {
      notifyListeners();
    };
    txidController.addListener(_textListener);
  }

  Future<void> _createWatchWallet(String walletName, String descriptorReceive, String descriptorChange) async {
    try {
      await MultisigStorage.createMultisigWallet(walletName, descriptorReceive, descriptorChange);
    } catch (e) {
      throw Exception('Failed to create watch wallet: $e');
    }
  }

  @override
  void dispose() {
    txidController.removeListener(_textListener);
    txidController.dispose();
    super.dispose();
  }

  Future<void> pasteFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData?.text != null) {
        txidController.text = clipboardData!.text!.trim();
        notifyListeners();
      }
    } catch (e) {
      modalError = 'Failed to paste from clipboard';
      notifyListeners();
    }
  }

  Future<void> importFromTxid(BuildContext context) async {
    setBusy(true);
    modalError = null;
    loadingStatus = null;

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
        modalError =
            'Cannot import multisig: this wallet cannot derive any of the $totalKeys keys in the group. Import is only allowed if this wallet owns at least one key.';
        return;
      }

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
          await _createWatchWallet(group.watchWalletName!, group.descriptorReceive!, group.descriptorChange!);
        }

        loadingStatus = 'Restoring transaction history...';
        notifyListeners();

        await MultisigStorage.restoreTransactionHistory(group);

        loadingStatus = 'Syncing wallet balance and addresses...';
        notifyListeners();
        await BalanceManager.updateGroupBalance(group);
      } catch (e) {
        // Failed to restore transaction history - not critical for import
      }

      loadingStatus = null;

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
      final keys = multisigData['keys'] as List<dynamic>? ?? [];

      if (keys.isEmpty) {
        return 0;
      }

      const isMainnet = String.fromEnvironment('BITWINDOW_NETWORK', defaultValue: 'signet') == 'mainnet';

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
              final derivedKeyInfo = await _hdWallet.deriveExtendedKeyInfo(
                _hdWallet.mnemonic ?? '',
                derivationPath,
                isMainnet,
              );

              if (derivedKeyInfo.isNotEmpty) {
                final derivedXpub = derivedKeyInfo['xpub'];

                if (derivedXpub == xpubFromPayload) {
                  keyData['is_wallet'] = true;
                  walletKeyCount++;
                }
              }
            } catch (e) {
              // Failed to derive key - skip this key
            }
          }
        }
      }
    } catch (e) {
      return 0;
    }

    return walletKeyCount;
  }

  Future<void> _saveMultisigToLocalFile(Map<String, dynamic> multisigData) async {
    final importedGroup = MultisigGroup.fromJson(multisigData);

    final existingGroups = await MultisigStorage.loadGroups();

    final existingIndex = existingGroups.indexWhere((g) => g.id == importedGroup.id);

    List<MultisigGroup> updatedGroups;
    if (existingIndex != -1) {
      _logger.d('Updating existing group: ${importedGroup.name}');
      updatedGroups = List<MultisigGroup>.from(existingGroups);
      updatedGroups[existingIndex] = importedGroup;
    } else {
      _logger.d('Adding new group: ${importedGroup.name}');
      updatedGroups = [...existingGroups, importedGroup];
    }

    await MultisigStorage.saveGroups(updatedGroups);
    _logger.d('Successfully saved group using atomic MultisigStorage operation');
  }
}
