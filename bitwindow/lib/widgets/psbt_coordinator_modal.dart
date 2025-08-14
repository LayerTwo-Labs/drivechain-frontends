import 'dart:convert';
import 'package:bitwindow/models/multisig_group.dart';
import 'package:bitwindow/models/multisig_transaction.dart';
import 'package:bitwindow/providers/hd_wallet_provider.dart';
import 'package:bitwindow/providers/multisig_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class PSBTCoordinatorModal extends StatelessWidget {
  final MultisigGroup? group;
  final List<MultisigGroup>? availableGroups;
  
  const PSBTCoordinatorModal({
    super.key,
    this.group,
    this.availableGroups,
  });

  @override
  Widget build(BuildContext context) {
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
                  SailText.primary13(
                    'Available Balance: ${group!.balance.toStringAsFixed(8)} BTC (${group!.utxos} UTXOs)',
                  ),
                  
                  SailTextField(
                    label: 'Destination Address',
                    controller: viewModel.destinationController,
                    hintText: 'Enter destination address',
                    size: TextFieldSize.small,
                  ),
                  
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
                        child: SailRow(
                          children: [
                            Expanded(
                              child: SailColumn(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: SailStyleValues.padding04,
                                children: [
                                  SailText.primary13(group.name),
                                  SailText.secondary12('${group.m} of ${group.n} multisig'),
                                  SailText.secondary12('Balance: ${group.balance.toStringAsFixed(8)} BTC'),
                                  SailText.secondary12('UTXOs: ${group.utxos}'),
                                ],
                              ),
                            ),
                            const SizedBox(width: SailStyleValues.padding16),
                            SailButton(
                              label: 'Select Group',
                              onPressed: () async {
                                Navigator.of(context).pop();
                                await showDialog(
                                  context: context,
                                  builder: (context) => PSBTCoordinatorModal(group: group),
                                );
                              },
                              variant: ButtonVariant.primary,
                            ),
                          ],
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
  final MultisigGroup group;
  
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  
  String? _error;
  String? createdPSBT;
  String? transactionId;
  bool isCreating = false;
  bool isSigning = false;
  
  CreateTransactionViewModel({required this.group}) {
    destinationController.addListener(notifyListeners);
    amountController.addListener(notifyListeners);
  }
  
  bool get canCreateTransaction {
    if (destinationController.text.isEmpty || amountController.text.isEmpty) {
      return false;
    }
    
    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      return false;
    }
    
    return amount <= group.balance;
  }
  
  bool get hasWalletKeys => group.keys.any((key) => key.isWallet);
  
  String? get modalError => _error;
  
  Future<void> useMaxAmount() async {
    amountController.text = group.balance.toStringAsFixed(8);
    notifyListeners();
  }
  
  String _generateTransactionId(String psbt, String destination) {
    try {
      final data = utf8.encode(psbt + destination);
      final hash = sha256.convert(data);
      final doubleHash = sha256.convert(hash.bytes);
      
      final id = doubleHash.bytes.take(4)
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join()
          .toUpperCase();
      return id;
    } catch (e) {
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
      
      final walletManager = WalletRPCManager();
      final walletName = group.watchWalletName ?? 'multisig_${group.id}';
      
      
      final psbtResult = await walletManager.callWalletRPC<Map<String, dynamic>>(
        walletName,
        'walletcreatefundedpsbt',
        [
          [],
          outputs,
          0,
          {
            'includeWatching': true,
            'changePosition': 1,
          },
        ],
      );
      
      final psbt = psbtResult['psbt'] as String;
      final fee = (psbtResult['fee'] as num?)?.toDouble() ?? 0.0;
      
      
      createdPSBT = psbt;
      await Clipboard.setData(ClipboardData(text: psbt));
      
      final txId = _generateTransactionId(psbt, destinationController.text);
      transactionId = txId;
      
      final keyPSBTs = group.keys.map((key) => KeyPSBTStatus(
        keyId: key.xpub,
        psbt: psbt,
        isSigned: false,
        signedAt: null,
      ),).toList();
      
      final transaction = MultisigTransaction(
        id: txId,
        groupId: group.id,
        initialPSBT: psbt,
        keyPSBTs: keyPSBTs,
        inputs: [],
        destination: destinationController.text,
        amount: amount,
        status: TxStatus.needsSignatures,
        type: TxType.withdrawal,
        created: DateTime.now(),
        fee: fee,
        confirmations: 0,
      );
      
      await TransactionStorage.saveTransaction(transaction);
      
      
      if (context.mounted) {
        Navigator.of(context).pop(true);
      }
      
    } catch (e) {
      _error = 'Failed to create transaction: $e';
    } finally {
      isCreating = false;
      notifyListeners();
    }
  }
  
  Future<void> signWithWalletKeys(BuildContext context) async {
    if (createdPSBT == null || !hasWalletKeys) return;
    
    try {
      _error = null;
      isSigning = true;
      notifyListeners();
      
      final hdWalletProvider = GetIt.I.get<HDWalletProvider>();
      
      if (hdWalletProvider.mnemonic == null) {
        throw Exception('Wallet mnemonic not available - please ensure wallet is unlocked');
      }
      
      final walletKeys = group.keys.where((k) => k.isWallet).toList();
      
      if (walletKeys.isEmpty) {
        throw Exception('No wallet keys found in this multisig group');
      }
      
      final rpcSigner = MultisigRPCSigner();
      const isMainnet = String.fromEnvironment('BITWINDOW_NETWORK', defaultValue: 'signet') == 'mainnet';
      
      final signingResult = await rpcSigner.signPSBT(
        psbtBase64: createdPSBT!,
        group: group,
        mnemonic: hdWalletProvider.mnemonic!,
        walletKeys: walletKeys,
        isMainnet: isMainnet,
      );
      
      if (signingResult.errors.isNotEmpty) {
        MultisigLogger.error('PSBT signing errors: ${signingResult.errors}');
      }
      
      
      createdPSBT = signingResult.signedPsbt;
      await Clipboard.setData(ClipboardData(text: signingResult.signedPsbt));
      
      if (transactionId != null) {
        for (final key in walletKeys) {
          await TransactionStorage.updateKeyPSBT(
            transactionId!,
            key.xpub,
            signingResult.signedPsbt,
            signatureThreshold: group.m,
            isOwnedKey: true,
          );
        }
        
        if (signingResult.isComplete) {
          await TransactionStatusManager.updateTransactionStatus(
            transactionId: transactionId!,
            newStatus: TxStatus.readyForBroadcast,
            combinedPSBT: signingResult.signedPsbt,
            reason: 'PSBT coordinator signing complete',
          );
        }
      }
      
      if (signingResult.errors.isNotEmpty) {
      }
      
      
      if (context.mounted) {
        Navigator.of(context).pop(true);
      }
      
    } catch (e) {
      _error = 'Failed to sign with wallet keys: $e';
    } finally {
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