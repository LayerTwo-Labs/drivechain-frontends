import 'dart:convert';
import 'dart:typed_data';
import 'package:bitwindow/models/multisig_group_enhanced.dart';
import 'package:bitwindow/models/multisig_transaction.dart';
import 'package:bitwindow/providers/hd_wallet_provider.dart';
import 'package:bitwindow/services/transaction_storage.dart';
import 'package:bitwindow/services/wallet_rpc_manager.dart';
import 'package:bs58/bs58.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:dart_bip32_bip44/dart_bip32_bip44.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class PSBTCoordinatorModal extends StatelessWidget {
  final MultisigGroupEnhanced? group;
  final List<MultisigGroupEnhanced>? availableGroups;
  
  const PSBTCoordinatorModal({
    super.key,
    this.group,
    this.availableGroups,
  });

  @override
  Widget build(BuildContext context) {
    // If no group is provided, show group selection first
    if (group == null) {
      return _buildGroupSelectionModal(context);
    }
    
    return ViewModelBuilder<CreateTransactionViewModel>.reactive(
      viewModelBuilder: () => CreateTransactionViewModel(group: group!),
      builder: (context, viewModel, child) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
            child: SailCard(
              title: 'Create Transaction',
              subtitle: 'Spend from ${group!.name} (${group!.m} of ${group!.n})',
              error: viewModel.modalError,
              withCloseButton: true,
              child: SailColumn(
                spacing: SailStyleValues.padding16,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Available balance
                  SailText.primary13(
                    'Available Balance: ${group!.balance.toStringAsFixed(8)} BTC (${group!.utxos} UTXOs)',
                  ),
                  
                  // Destination
                  SailTextField(
                    label: 'Destination Address',
                    controller: viewModel.destinationController,
                    hintText: 'Enter destination address',
                    size: TextFieldSize.small,
                  ),
                  
                  // Amount
                  NumericField(
                    label: 'Amount (BTC)',
                    controller: viewModel.amountController,
                    suffixWidget: SailButton(
                      label: 'MAX',
                      variant: ButtonVariant.link,
                      onPressed: () async => viewModel.useMaxAmount(),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  
                  SailText.secondary12(
                    'Transaction fee will be automatically calculated and deducted from the amount.',
                  ),
                  
                  // Action buttons
                  SailRow(
                    spacing: SailStyleValues.padding12,
                    children: [
                      SailButton(
                        label: 'Create Transaction',
                        onPressed: viewModel.canCreateTransaction 
                          ? () => viewModel.createTransaction(context) 
                          : null,
                        loading: viewModel.isCreating,
                        variant: ButtonVariant.primary,
                      ),
                      if (viewModel.hasWalletKeys && viewModel.createdPSBT != null)
                        SailButton(
                          label: 'Sign with My Keys',
                          onPressed: () => viewModel.signWithWalletKeys(context),
                          loading: viewModel.isSigning,
                          variant: ButtonVariant.secondary,
                        ),
                      SailButton(
                        label: 'Cancel',
                        onPressed: () async => Navigator.of(context).pop(),
                        variant: ButtonVariant.ghost,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildGroupSelectionModal(BuildContext context) {
    final fundedGroups = availableGroups?.where((g) => g.balance > 0).toList() ?? [];
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
        child: SailCard(
          title: 'Select Multisig Group',
          subtitle: 'Choose a funded group to create a transaction',
          withCloseButton: true,
          child: SailColumn(
            spacing: SailStyleValues.padding16,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (fundedGroups.isEmpty) ...[
                SailText.secondary13('No funded multisig groups available.'),
                SailText.secondary12('Fund a group first to create transactions.'),
              ] else ...[
                SailText.primary13('Funded Groups (${fundedGroups.length})'),
                SailSpacing(SailStyleValues.padding08),
                Expanded(
                  child: ListView.builder(
                    itemCount: fundedGroups.length,
                    itemBuilder: (context, index) {
                      final group = fundedGroups[index];
                      return SailCard(
                        shadowSize: ShadowSize.none,
                        child: ListTile(
                          title: SailText.primary13(group.name),
                          subtitle: SailColumn(
                            spacing: SailStyleValues.padding04,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SailText.secondary12('${group.m} of ${group.n} multisig'),
                              SailText.secondary12('Balance: ${group.balance.toStringAsFixed(8)} BTC'),
                              SailText.secondary12('UTXOs: ${group.utxos}'),
                            ],
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                            showDialog(
                              context: context,
                              builder: (context) => PSBTCoordinatorModal(group: group),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class CreateTransactionViewModel extends BaseViewModel {
  final MultisigGroupEnhanced group;
  
  // Controllers
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  
  // State
  String? _error;
  String? createdPSBT;
  String? transactionId;
  bool isCreating = false;
  bool isSigning = false;
  
  CreateTransactionViewModel({required this.group}) {
    destinationController.addListener(notifyListeners);
    amountController.addListener(notifyListeners);
  }
  
  // Getters
  bool get canCreateTransaction {
    if (destinationController.text.isEmpty || amountController.text.isEmpty) {
      return false;
    }
    
    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      return false;
    }
    
    // Check against group balance (wallet will automatically deduct fee)
    return amount <= group.balance;
  }
  
  bool get hasWalletKeys => group.keys.any((key) => key.isWallet);
  
  String? get modalError => _error;
  
  // Actions
  Future<void> useMaxAmount() async {
    // Use full group balance (fee will be deducted automatically by wallet)
    amountController.text = group.balance.toStringAsFixed(8);
    notifyListeners();
  }
  
  String _generateTransactionId(String psbt, String destination) {
    try {
      // Create unique ID based on PSBT + destination
      final data = utf8.encode(psbt + destination);
      final hash = sha256.convert(data);
      final doubleHash = sha256.convert(hash.bytes);
      
      // Take first 4 bytes as hex
      final id = doubleHash.bytes.take(4)
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join()
          .toUpperCase();
      return id;
    } catch (e) {
      // Fallback to timestamp-based ID
      return DateTime.now().millisecondsSinceEpoch.toRadixString(16).toUpperCase();
    }
  }

  Future<void> createTransaction(BuildContext context) async {
    if (!canCreateTransaction) return;
    
    try {
      _error = null;
      isCreating = true;
      notifyListeners();
      
      final amount = double.parse(amountController.text);
      final outputs = {destinationController.text: amount};
      
      // Use wallet-specific RPC call to create funded PSBT
      final walletManager = WalletRPCManager();
      final walletName = group.watchWalletName ?? 'multisig_${group.id}';
      
      GetIt.I.get<Logger>().d('Creating PSBT for wallet: $walletName');
      GetIt.I.get<Logger>().d('Outputs: $outputs');
      
      // Create the PSBT using walletcreatefundedpsbt
      final psbtResult = await walletManager.callWalletRPC<Map<String, dynamic>>(
        walletName,
        'walletcreatefundedpsbt',
        [
          [], // empty inputs - let wallet choose UTXOs
          outputs,
          0, // locktime
          {
            'includeWatching': true,
            'changePosition': 1, // Put change output at position 1
          },
        ],
      );
      
      final psbt = psbtResult['psbt'] as String;
      final fee = (psbtResult['fee'] as num?)?.toDouble() ?? 0.0;
      
      GetIt.I.get<Logger>().i('Created PSBT with fee: ${fee.toStringAsFixed(8)} BTC');
      
      // Store PSBT and copy to clipboard
      createdPSBT = psbt;
      await Clipboard.setData(ClipboardData(text: psbt));
      
      // Generate transaction ID
      final txId = _generateTransactionId(psbt, destinationController.text);
      transactionId = txId;
      
      // Create KeyPSBTStatus for each key in the group
      final keyPSBTs = group.keys.map((key) => KeyPSBTStatus(
        keyId: key.xpub,
        psbt: psbt,
        isSigned: false,
        signedAt: null,
      )).toList();
      
      // Create and save transaction
      final transaction = MultisigTransaction(
        id: txId,
        groupId: group.id,
        initialPSBT: psbt,
        keyPSBTs: keyPSBTs,
        inputs: [], // UTXOs are selected automatically by wallet
        destination: destinationController.text,
        amount: amount,
        status: TxStatus.needsSignatures,
        created: DateTime.now(),
        fee: fee,
        confirmations: 0,
      );
      
      await TransactionStorage.saveTransaction(transaction);
      
      GetIt.I.get<Logger>().i('Created transaction $txId - needs ${group.m} of ${group.n} signatures');
      GetIt.I.get<Logger>().i('PSBT copied to clipboard');
      
      // Close modal immediately after successful creation
      if (context.mounted) {
        Navigator.of(context).pop(true);
      }
      
    } catch (e) {
      _error = 'Failed to create transaction: $e';
      GetIt.I.get<Logger>().e('Error creating transaction: $e');
    } finally {
      isCreating = false;
      notifyListeners();
    }
  }
  
  Future<void> signWithWalletKeys(BuildContext context) async {
    if (createdPSBT == null || !hasWalletKeys) return;
    
    String? tempWalletName;
    try {
      _error = null;
      isSigning = true;
      notifyListeners();
      
      final walletManager = WalletRPCManager();
      final hdWalletProvider = GetIt.I.get<HDWalletProvider>();
      final api = GetIt.I.get<MainchainRPC>();
      
      if (hdWalletProvider.seedHex == null) {
        throw Exception('Wallet seed not available - please ensure wallet is unlocked');
      }
      
      // Create a temporary wallet for signing
      tempWalletName = 'temp_sign_${DateTime.now().millisecondsSinceEpoch}';
      
      GetIt.I.get<Logger>().d('Creating temporary wallet: $tempWalletName');
      
      // Create temp wallet with private keys enabled
      try {
        await walletManager.createWallet(
          tempWalletName,
          disablePrivateKeys: false,
          blank: true,
        );
        GetIt.I.get<Logger>().d('Temporary wallet created successfully');
      } catch (e) {
        throw Exception('Failed to create temporary wallet: $e');
      }
      
      // Get wallet keys that we can sign with
      final walletKeys = group.keys.where((k) => k.isWallet).toList();
      GetIt.I.get<Logger>().d('Found ${walletKeys.length} wallet keys in group');
      
      if (walletKeys.isEmpty) {
        throw Exception('No wallet keys found in this multisig group');
      }
      
      // Import private keys for each wallet key
      int importedCount = 0;
      for (final key in walletKeys) {
        if (key.fingerprint != null && key.originPath != null) {
          try {
            GetIt.I.get<Logger>().d('Processing wallet key: ${key.xpub.substring(0, 20)}...');
            
            // Use the origin path to derive the private key
            final derivationPath = key.originPath!.startsWith('m/') 
                ? key.originPath!
                : 'm/${key.originPath!}';
            
            GetIt.I.get<Logger>().d('Deriving key at path: $derivationPath');
            
            // Derive the private key using HD wallet
            final chain = Chain.seed(hdWalletProvider.seedHex!);
            final derivedKey = chain.forPath(derivationPath);
            final privateKeyHex = derivedKey.privateKeyHex();
            
            // Convert to WIF format for testnet (0xef prefix for testnet)
            final privateKeyBytes = [0xef, ...hex.decode(privateKeyHex), 0x01];
            final sha256_1 = SHA256Digest().process(Uint8List.fromList(privateKeyBytes));
            final sha256_2 = SHA256Digest().process(sha256_1);
            final checksum = sha256_2.sublist(0, 4);
            final privateKeyWIF = base58.encode(Uint8List.fromList([...privateKeyBytes, ...checksum]));
            
            GetIt.I.get<Logger>().d('Importing private key to temp wallet');
            
            // Import private key to temp wallet
            await walletManager.callWalletRPC<dynamic>(
              tempWalletName,
              'importprivkey',
              [privateKeyWIF, '', false], // No label, no rescan
            );
            
            importedCount++;
            GetIt.I.get<Logger>().d('Successfully imported private key ${importedCount}/${walletKeys.length}');
            
          } catch (e) {
            GetIt.I.get<Logger>().w('Failed to import private key for key ${key.xpub.substring(0, 20)}: $e');
            throw Exception('Failed to import private key for wallet key: $e');
          }
        } else {
          throw Exception('Wallet key missing required fingerprint or origin path');
        }
      }
      
      if (importedCount == 0) {
        throw Exception('No private keys were successfully imported to temp wallet');
      }
      
      GetIt.I.get<Logger>().d('Processing PSBT with temp wallet (imported $importedCount keys)');
      
      // Process PSBT with temp wallet to add signatures
      Map<String, dynamic> processResult;
      try {
        processResult = await walletManager.callWalletRPC<Map<String, dynamic>>(
          tempWalletName,
          'walletprocesspsbt',
          [createdPSBT!],
        );
      } catch (e) {
        throw Exception('walletprocesspsbt RPC call failed: $e');
      }
      
      final signedPSBT = processResult['psbt'] as String?;
      final isComplete = processResult['complete'] as bool? ?? false;
      
      if (signedPSBT == null) {
        throw Exception('walletprocesspsbt returned null PSBT');
      }
      
      if (signedPSBT == createdPSBT) {
        throw Exception('No signatures were added to the PSBT - wallet may not have the correct private keys for this transaction');
      }
      
      GetIt.I.get<Logger>().i('Successfully signed PSBT${isComplete ? ' (complete)' : ' (partial)'}');
      
      // Update the stored PSBT and transaction
      createdPSBT = signedPSBT;
      await Clipboard.setData(ClipboardData(text: signedPSBT));
      
      if (transactionId != null) {
        // Update transaction storage for each wallet key that signed
        for (final key in walletKeys) {
          await TransactionStorage.updateKeyPSBT(
            transactionId!,
            key.xpub,
            signedPSBT,
            signatureThreshold: group.m,
          );
        }
        
        // Update transaction status if complete
        if (isComplete) {
          await TransactionStorage.updateTransactionStatus(
            transactionId!,
            TxStatus.readyForBroadcast,
            combinedPSBT: signedPSBT,
          );
        }
      }
      
      GetIt.I.get<Logger>().i('Signed PSBT copied to clipboard');
      
      // Close modal after successful signing
      if (context.mounted) {
        Navigator.of(context).pop(true);
      }
      
    } catch (e) {
      _error = 'Failed to sign with wallet keys: $e';
      GetIt.I.get<Logger>().e('Error signing with wallet keys: $e');
    } finally {
      // Always clean up temp wallet
      if (tempWalletName != null) {
        try {
          GetIt.I.get<Logger>().d('Cleaning up temporary wallet: $tempWalletName');
          final api = GetIt.I.get<MainchainRPC>();
          await api.callRAW('unloadwallet', [tempWalletName]);
          GetIt.I.get<Logger>().d('Temporary wallet unloaded successfully');
        } catch (e) {
          GetIt.I.get<Logger>().w('Failed to unload temp wallet $tempWalletName: $e');
        }
      }
      
      isSigning = false;
      notifyListeners();
    }
  }
  
  
  @override
  void dispose() {
    destinationController.removeListener(notifyListeners);
    amountController.removeListener(notifyListeners);
    destinationController.dispose();
    amountController.dispose();
    super.dispose();
  }
}