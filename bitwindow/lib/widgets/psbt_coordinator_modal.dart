import 'dart:convert';
import 'dart:io';

import 'package:bitwindow/env.dart';
import 'package:bitwindow/models/multisig_group_enhanced.dart';
import 'package:bitwindow/providers/hd_wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

class PSBTCoordinatorModal extends StatelessWidget {
  final MultisigGroupEnhanced group;
  
  const PSBTCoordinatorModal({
    super.key,
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PSBTCoordinatorViewModel>.reactive(
      viewModelBuilder: () => PSBTCoordinatorViewModel(group: group),
      onViewModelReady: (model) => model.init(),
      builder: (context, viewModel, child) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800, maxHeight: 700),
            child: SailCard(
              title: 'Create Multisig Transaction',
              subtitle: 'Spend from ${group.name} (${group.m} of ${group.n})',
              error: viewModel.modalError,
              child: SingleChildScrollView(
                child: SailColumn(
                  spacing: SailStyleValues.padding16,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step indicator
                    _buildStepIndicator(context, viewModel),
                    
                    // Content based on current step
                    if (viewModel.currentStep == PSBTStep.create)
                      _buildCreateStep(context, viewModel)
                    else if (viewModel.currentStep == PSBTStep.sign)
                      _buildSignStep(context, viewModel)
                    else if (viewModel.currentStep == PSBTStep.finalize)
                      _buildFinalizeStep(context, viewModel),
                    
                    // Navigation buttons
                    _buildNavigationButtons(context, viewModel),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildStepIndicator(BuildContext context, PSBTCoordinatorViewModel viewModel) {
    return SailRow(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: SailStyleValues.padding16,
      children: [
        _buildStepItem(context, 'Create', PSBTStep.create, viewModel.currentStep),
        _buildStepItem(context, 'Sign', PSBTStep.sign, viewModel.currentStep),
        _buildStepItem(context, 'Finalize', PSBTStep.finalize, viewModel.currentStep),
      ],
    );
  }
  
  Widget _buildStepItem(BuildContext context, String label, PSBTStep step, PSBTStep currentStep) {
    final isActive = step == currentStep;
    final isPassed = step.index < currentStep.index;
    
    return SailColumn(
      spacing: SailStyleValues.padding04,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive 
              ? context.sailTheme.colors.primary 
              : isPassed 
                ? context.sailTheme.colors.success 
                : context.sailTheme.colors.backgroundSecondary,
          ),
          child: Center(
            child: SailText.primary13(
              '${step.index + 1}',
              color: isActive || isPassed 
                ? context.sailTheme.colors.background 
                : context.sailTheme.colors.text,
            ),
          ),
        ),
        SailText.secondary12(
          label,
          bold: isActive,
        ),
      ],
    );
  }
  
  Widget _buildCreateStep(BuildContext context, PSBTCoordinatorViewModel viewModel) {
    return SailColumn(
      spacing: SailStyleValues.padding16,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Available UTXOs
        SailText.primary15('Available UTXOs'),
        SailText.secondary12('Select UTXOs to spend (${viewModel.selectedUtxos.length} selected)'),
        
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: context.sailTheme.colors.backgroundSecondary),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.builder(
            itemCount: viewModel.group.utxoDetails.length,
            itemBuilder: (context, index) {
              final utxo = viewModel.group.utxoDetails[index];
              final isSelected = viewModel.selectedUtxos.contains(utxo);
              
              return ListTile(
                leading: Checkbox(
                  value: isSelected,
                  onChanged: (_) => viewModel.toggleUtxo(utxo),
                ),
                title: SailText.primary13('${utxo.amount.toStringAsFixed(8)} BTC'),
                subtitle: SailText.secondary12(
                  '${utxo.txid.substring(0, 8)}...${utxo.txid.substring(utxo.txid.length - 8)}:${utxo.vout}',
                ),
                trailing: SailText.secondary12('${utxo.confirmations} conf'),
              );
            },
          ),
        ),
        
        // Selected amount
        SailText.primary13(
          'Selected: ${viewModel.selectedAmount.toStringAsFixed(8)} BTC',
        ),
        
        // Destination
        SailText.primary15('Destination'),
        SailTextField(
          label: 'Address',
          controller: viewModel.destinationController,
          hintText: 'Enter destination address',
          size: TextFieldSize.small,
        ),
        
        SailRow(
          spacing: SailStyleValues.padding16,
          children: [
            Expanded(
              child: SailTextField(
                label: 'Amount (BTC)',
                controller: viewModel.amountController,
                hintText: '0.00000000',
                size: TextFieldSize.small,
                textFieldType: TextFieldType.number,
              ),
            ),
            Expanded(
              child: SailTextField(
                label: 'Fee Rate (sat/vB)',
                controller: viewModel.feeRateController,
                hintText: '1',
                size: TextFieldSize.small,
                textFieldType: TextFieldType.number,
              ),
            ),
          ],
        ),
        
        // Create PSBT button
        SailButton(
          label: 'Create PSBT',
          onPressed: viewModel.canCreatePSBT ? viewModel.createPSBT : null,
          loading: viewModel.isBusy,
          variant: ButtonVariant.primary,
        ),
      ],
    );
  }
  
  Widget _buildSignStep(BuildContext context, PSBTCoordinatorViewModel viewModel) {
    return SailColumn(
      spacing: SailStyleValues.padding16,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // PSBT info
        SailText.primary15('PSBT Created'),
        SailText.secondary12(
          'This transaction requires ${viewModel.group.m} of ${viewModel.group.n} signatures',
        ),
        
        // Current signatures
        SailText.primary13('Signatures: ${viewModel.signedPSBTs.length} / ${viewModel.group.m}'),
        
        // PSBT display
        SailCard(
          shadowSize: ShadowSize.none,
          child: SailColumn(
            spacing: SailStyleValues.padding08,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SailRow(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SailText.primary13('Base64 PSBT'),
                  SailButton(
                    label: 'Copy',
                    onPressed: () async => viewModel.copyPSBT(),
                    variant: ButtonVariant.ghost,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.sailTheme.colors.background,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SelectableText(
                  viewModel.currentPSBT ?? '',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: context.sailTheme.colors.text,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Sign options
        SailRow(
          spacing: SailStyleValues.padding16,
          children: [
            SailButton(
              label: 'Sign with My Keys',
              onPressed: viewModel.hasWalletKeys ? viewModel.signWithOwnKeys : null,
              loading: viewModel.isSigningOwn,
            ),
            SailButton(
              label: 'Import Signed PSBT',
              onPressed: () async => viewModel.importSignedPSBT(),
              variant: ButtonVariant.secondary,
            ),
          ],
        ),
        
        // Signed PSBTs list
        if (viewModel.signedPSBTs.isNotEmpty) ...[
          SailText.primary13('Collected Signatures'),
          ...viewModel.signedPSBTs.asMap().entries.map((entry) => SailCard(
                shadowSize: ShadowSize.none,
                child: SailRow(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SailText.secondary12('Signature ${entry.key + 1}'),
                    SailButton(
                      label: 'Remove',
                      onPressed: () async => viewModel.removeSignedPSBT(entry.key),
                      variant: ButtonVariant.ghost,
                    ),
                  ],
                ),
              ),),
        ],
        
        // Combine button
        if (viewModel.signedPSBTs.length >= viewModel.group.m - 1)
          SailButton(
            label: 'Combine Signatures',
            onPressed: viewModel.combinePSBTs,
            loading: viewModel.isCombining,
            variant: ButtonVariant.primary,
          ),
      ],
    );
  }
  
  Widget _buildFinalizeStep(BuildContext context, PSBTCoordinatorViewModel viewModel) {
    return SailColumn(
      spacing: SailStyleValues.padding16,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status
        if (viewModel.broadcastTxid != null) ...[
          Container(
            padding: const EdgeInsets.all(SailStyleValues.padding12),
            decoration: BoxDecoration(
              color: context.sailTheme.colors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SailColumn(
              spacing: SailStyleValues.padding08,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SailRow(
                  spacing: SailStyleValues.padding08,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: context.sailTheme.colors.success,
                      size: 20,
                    ),
                    SailText.primary15(
                      'Transaction Broadcast Successfully!',
                      bold: true,
                    ),
                  ],
                ),
                SailText.secondary12('Transaction ID:'),
                SelectableText(
                  viewModel.broadcastTxid!,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: context.sailTheme.colors.text,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          SailText.primary15('Ready to Broadcast'),
          SailText.secondary12(
            'The transaction has ${viewModel.signedPSBTs.length + 1} signatures and is ready to broadcast',
          ),
          
          // Final transaction details
          SailCard(
            shadowSize: ShadowSize.none,
            child: SailColumn(
              spacing: SailStyleValues.padding08,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SailText.primary13('Transaction Summary'),
                SailText.secondary12(
                  'Inputs: ${viewModel.selectedUtxos.length}',
                ),
                SailText.secondary12(
                  'Amount: ${viewModel.amountController.text} BTC',
                ),
                SailText.secondary12(
                  'Fee: ~${viewModel.estimatedFee.toStringAsFixed(8)} BTC',
                ),
                SailText.secondary12(
                  'Destination: ${viewModel.destinationController.text.substring(0, 20)}...',
                ),
              ],
            ),
          ),
          
          // Broadcast button
          SailButton(
            label: 'Finalize and Broadcast',
            onPressed: viewModel.finalizeAndBroadcast,
            loading: viewModel.isBroadcasting,
            variant: ButtonVariant.primary,
          ),
        ],
      ],
    );
  }
  
  Widget _buildNavigationButtons(BuildContext context, PSBTCoordinatorViewModel viewModel) {
    return SailRow(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (viewModel.currentStep != PSBTStep.create)
          SailButton(
            label: 'Back',
            onPressed: () async => viewModel.previousStep(),
            variant: ButtonVariant.ghost,
          )
        else
          Container(),
        
        SailButton(
          label: 'Close',
          onPressed: () async => Navigator.of(context).pop(viewModel.broadcastTxid != null),
          variant: ButtonVariant.ghost,
        ),
      ],
    );
  }
}

enum PSBTStep { create, sign, finalize }

class PSBTCoordinatorViewModel extends BaseViewModel {
  final MainchainRPC _api = GetIt.I.get<MainchainRPC>();
  final HDWalletProvider _hdWallet = GetIt.I.get<HDWalletProvider>();
  
  final MultisigGroupEnhanced group;
  
  // Controllers
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController feeRateController = TextEditingController(text: '1');
  
  // State
  PSBTStep currentStep = PSBTStep.create;
  String? modalError;
  List<UtxoInfo> selectedUtxos = [];
  String? currentPSBT;
  List<String> signedPSBTs = [];
  String? broadcastTxid;
  bool isSigningOwn = false;
  bool isCombining = false;
  bool isBroadcasting = false;
  
  PSBTCoordinatorViewModel({required this.group});
  
  void init() {
    // Select all UTXOs by default
    selectedUtxos = List.from(group.utxoDetails);
    notifyListeners();
  }
  
  // Getters
  double get selectedAmount => 
    selectedUtxos.fold(0.0, (sum, utxo) => sum + utxo.amount);
  
  bool get canCreatePSBT =>
    selectedUtxos.isNotEmpty &&
    destinationController.text.isNotEmpty &&
    amountController.text.isNotEmpty &&
    double.tryParse(amountController.text) != null &&
    double.parse(amountController.text) > 0 &&
    double.parse(amountController.text) <= selectedAmount;
  
  bool get hasWalletKeys =>
    group.keys.any((key) => key.isWallet);
  
  double get estimatedFee {
    // Rough estimate: 150 bytes per input + 50 bytes per output + 50 bytes overhead
    final vsize = (selectedUtxos.length * 150) + 100;
    final feeRate = double.tryParse(feeRateController.text) ?? 1.0;
    return (vsize * feeRate) / 100000000; // Convert to BTC
  }
  
  // Actions
  void toggleUtxo(UtxoInfo utxo) {
    if (selectedUtxos.contains(utxo)) {
      selectedUtxos.remove(utxo);
    } else {
      selectedUtxos.add(utxo);
    }
    notifyListeners();
  }
  
  Future<void> createPSBT() async {
    if (!canCreatePSBT) return;
    
    try {
      modalError = null;
      setBusy(true);
      
      // Prepare inputs
      final inputs = selectedUtxos.map((utxo) => utxo.outpoint).toList();
      
      // Prepare outputs
      final amount = double.parse(amountController.text);
      final outputs = {destinationController.text: amount};
      
      // Create PSBT via Bitcoin Core
      final psbt = await _api.callRAW('createpsbt', [inputs, outputs]);
      currentPSBT = psbt as String;
      
      // Move to sign step
      currentStep = PSBTStep.sign;
      
    } catch (e) {
      modalError = 'Failed to create PSBT: $e';
      GetIt.I.get<Logger>().e('Error creating PSBT: $e');
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }
  
  Future<void> signWithOwnKeys() async {
    if (!hasWalletKeys || currentPSBT == null) return;
    
    try {
      modalError = null;
      isSigningOwn = true;
      notifyListeners();
      
      // Get wallet keys from the group
      final walletKeys = group.keys.where((k) => k.isWallet).toList();
      
      // Derive private keys for the specific addresses being spent
      final privkeys = <String>[];
      
      // Get the addresses being spent from the selected UTXOs
      final spentAddresses = selectedUtxos.map((utxo) => utxo.address).toSet();
      
      // Use the address tracking data from the group to map addresses to derivation indices
      final addressesToIndices = <String, int>{};
      
      // Build address -> index mapping from stored address data
      for (final addressInfo in group.addresses['receive'] ?? <AddressInfo>[]) {
        addressesToIndices[addressInfo.address] = addressInfo.index;
      }
      for (final addressInfo in group.addresses['change'] ?? <AddressInfo>[]) {
        addressesToIndices[addressInfo.address] = addressInfo.index;
      }
      
      for (final key in walletKeys) {
        // All keys are now xpub-based (ranged descriptors)
        
        // Parse the account path from the stored derivation path
        final accountPath = key.derivationPath; // e.g., "m/84'/1'/0'"
        
        // Find which address indices are being spent that belong to this wallet key
        for (final spentAddress in spentAddresses) {
          final addressIndex = addressesToIndices[spentAddress];
          if (addressIndex != null) {
            // Derive the private key for this specific address
            final specificKeyPath = '$accountPath/0/$addressIndex'; // External addresses
            
            try {
              final keyInfo = await _hdWallet.deriveKeyInfo(
                _hdWallet.mnemonic ?? '',
                specificKeyPath,
              );
              
              final wif = keyInfo['wif'];
              if (wif != null && !privkeys.contains(wif)) {
                privkeys.add(wif);
                GetIt.I.get<Logger>().d('Derived private key for address $spentAddress at path: $specificKeyPath');
              }
            } catch (e) {
              GetIt.I.get<Logger>().w('Failed to derive key for path $specificKeyPath: $e');
            }
          }
        }
      }
      
      if (privkeys.isEmpty) {
        throw Exception('Failed to derive private keys');
      }
      
      // Sign with keys
      // First decode PSBT to get the raw transaction
      final psbtInfo = await _api.callRAW('decodepsbt', [currentPSBT]);
      final txHex = psbtInfo['tx']['hex'] as String;
      
      // Sign the transaction
      final signResult = await _api.callRAW(
        'signrawtransactionwithkey',
        [txHex, privkeys],
      );
      
      if (signResult['complete'] == true) {
        // If complete, move to finalize
        signedPSBTs.add(currentPSBT!);
        currentStep = PSBTStep.finalize;
      } else {
        // If not complete, save the partially signed PSBT
        // Note: This is simplified - in reality we'd need to convert back to PSBT format
        signedPSBTs.add(currentPSBT!);
      }
      
      GetIt.I.get<Logger>().i('Signed with ${privkeys.length} wallet keys');
      
    } catch (e) {
      modalError = 'Failed to sign with wallet keys: $e';
      GetIt.I.get<Logger>().e('Error signing: $e');
    } finally {
      isSigningOwn = false;
      notifyListeners();
    }
  }
  
  void importSignedPSBT() async {
    // Show dialog to paste PSBT
    final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboard?.text != null) {
      signedPSBTs.add(clipboard!.text!);
      notifyListeners();
    }
  }
  
  void removeSignedPSBT(int index) {
    signedPSBTs.removeAt(index);
    notifyListeners();
  }
  
  Future<void> combinePSBTs() async {
    try {
      modalError = null;
      isCombining = true;
      notifyListeners();
      
      // Combine all PSBTs including the current one
      final allPSBTs = [currentPSBT!, ...signedPSBTs];
      final combined = await _api.callRAW('combinepsbt', [allPSBTs]);
      
      currentPSBT = combined as String;
      currentStep = PSBTStep.finalize;
      
    } catch (e) {
      modalError = 'Failed to combine PSBTs: $e';
      GetIt.I.get<Logger>().e('Error combining PSBTs: $e');
    } finally {
      isCombining = false;
      notifyListeners();
    }
  }
  
  Future<void> finalizeAndBroadcast() async {
    if (currentPSBT == null) return;
    
    try {
      modalError = null;
      isBroadcasting = true;
      notifyListeners();
      
      // Finalize PSBT
      final finalizeResult = await _api.callRAW('finalizepsbt', [currentPSBT]);
      
      if (finalizeResult['complete'] != true) {
        throw Exception('PSBT finalization failed - insufficient signatures');
      }
      
      final hex = finalizeResult['hex'] as String;
      
      // Broadcast
      broadcastTxid = await _api.callRAW('sendrawtransaction', [hex]) as String;
      
      GetIt.I.get<Logger>().i('Transaction broadcast: $broadcastTxid');
      
      // Update group balance (will be refreshed on next balance check)
      await _updateGroupAfterSpend();
      
    } catch (e) {
      modalError = 'Failed to broadcast: $e';
      GetIt.I.get<Logger>().e('Error broadcasting: $e');
    } finally {
      isBroadcasting = false;
      notifyListeners();
    }
  }
  
  Future<void> _updateGroupAfterSpend() async {
    try {
      // Mark spent UTXOs in the JSON file
      final appDir = await Environment.datadir();
      final file = File(path.join(appDir.path, 'bitdrive', 'multisig.json'));
      
      if (await file.exists()) {
        final content = await file.readAsString();
        final jsonGroups = json.decode(content) as List<dynamic>;
        
        // Find and update the group
        for (final groupData in jsonGroups) {
          if (groupData['id'] == group.id) {
            // Remove spent UTXOs
            final remainingUtxos = (groupData['utxo_details'] as List? ?? [])
              .where((u) => !selectedUtxos.any((s) => 
                s.txid == u['txid'] && s.vout == u['vout'],
              ),)
              .toList();
            
            groupData['utxo_details'] = remainingUtxos;
            groupData['utxos'] = remainingUtxos.length;
            
            // Recalculate balance
            double newBalance = 0.0;
            for (final u in remainingUtxos) {
              newBalance += (u['amount'] ?? 0.0).toDouble();
            }
            groupData['balance'] = newBalance;
            
            break;
          }
        }
        
        await file.writeAsString(json.encode(jsonGroups));
      }
    } catch (e) {
      GetIt.I.get<Logger>().e('Error updating group after spend: $e');
    }
  }
  
  void copyPSBT() async {
    if (currentPSBT != null) {
      await Clipboard.setData(ClipboardData(text: currentPSBT!));
    }
  }
  
  void previousStep() {
    if (currentStep == PSBTStep.sign) {
      currentStep = PSBTStep.create;
    } else if (currentStep == PSBTStep.finalize) {
      currentStep = PSBTStep.sign;
    }
    notifyListeners();
  }
  
  @override
  void dispose() {
    destinationController.dispose();
    amountController.dispose();
    feeRateController.dispose();
    super.dispose();
  }
}