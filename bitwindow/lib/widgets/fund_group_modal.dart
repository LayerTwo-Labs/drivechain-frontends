import 'dart:convert';
import 'dart:io';

import 'package:bitwindow/env.dart';
import 'package:bitwindow/models/multisig_group.dart';
import 'package:bitwindow/providers/hd_wallet_provider.dart';
import 'package:bitwindow/providers/multisig_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';


class FundGroupModal extends StatelessWidget {
  final List<MultisigGroup> groups;

  const FundGroupModal({
    super.key,
    required this.groups,
  });

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<FundGroupModalViewModel>.reactive(
      viewModelBuilder: () => FundGroupModalViewModel(groups: groups),
      onViewModelReady: (model) => model.init(),
      builder: (context, viewModel, child) {
        if (viewModel.selectedGroup != null && viewModel.currentAddress.isNotEmpty) {
          // Show address like wallet receive page - immediately after group selection
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(24),
            child: IntrinsicHeight(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SailCard(
                  title: 'Fund ${viewModel.selectedGroup!.name}',
                  subtitle: 'Send Bitcoin to this address to fund the multisig group',
                  child: SailColumn(
                    spacing: SailStyleValues.padding16,
                    children: [
                      SailTextField(
                        label: 'Funding Address',
                        hintText: 'Funding address',
                        controller: TextEditingController(text: viewModel.currentAddress),
                        readOnly: true,
                        suffixWidget: CopyButton(
                          text: viewModel.currentAddress,
                        ),
                      ),
                      SailButton(
                        label: 'Close',
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

        // Show group selection
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
            child: SailCard(
              title: 'Select Multisig Group to Fund',
              subtitle: 'Choose which group you want to generate a funding address for',
              error: viewModel.modalError,
              child: SingleChildScrollView(
                child: SailColumn(
                  spacing: SailStyleValues.padding16,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (viewModel.groups.isEmpty)
                      SailText.secondary12('No multisig groups available')
                    else
                      ...viewModel.groups.map((group) => SailCard(
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
                                    ],
                                  ),
                                ),
                                const SizedBox(width: SailStyleValues.padding16),
                                SailButton(
                                  label: 'Fund This Group',
                                  onPressed: () async => viewModel.selectGroup(group),
                                  variant: ButtonVariant.primary,
                                ),
                              ],
                            ),
                          ),),
                    SailButton(
                      label: 'Close',
                      onPressed: () async => Navigator.of(context).pop(),
                      variant: ButtonVariant.ghost,
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

class FundGroupModalViewModel extends BaseViewModel {
  final List<MultisigGroup> groups;
  
  String? modalError;
  MultisigGroup? selectedGroup;
  String currentAddress = '';
  HDWalletProvider? _hdWalletProvider;
  
  FundGroupModalViewModel({required this.groups});
  
  bool get hasMnemonic => _hdWalletProvider?.mnemonic != null;
  String? get mnemonic => _hdWalletProvider?.mnemonic;
  
  Future<void> init() async {
    try {
      _hdWalletProvider = GetIt.I.get<HDWalletProvider>();
      
      if (!_hdWalletProvider!.isInitialized) {
        await _hdWalletProvider!.init();
      }
      
      if (_hdWalletProvider!.error != null) {
        modalError = 'Failed to load wallet mnemonic: ${_hdWalletProvider!.error}';
      } else if (_hdWalletProvider!.mnemonic == null) {
        modalError = 'Wallet mnemonic not available';
      }
    } catch (e) {
      modalError = 'Failed to initialize wallet: $e';
    }
    
    notifyListeners();
  }

  Future<void> selectGroup(MultisigGroup group) async {
    selectedGroup = group;
    modalError = null;
    setBusy(true);
    notifyListeners();
    
    try {
      // Generate address immediately when group is selected
      currentAddress = await _generateMultisigAddress(group);
    } catch (e) {
      modalError = 'Failed to generate address: $e';
      GetIt.I.get<Logger>().e('Error generating multisig address: $e');
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }
  
  Future<String> _generateMultisigAddress(MultisigGroup group) async {
    try {
      final api = GetIt.I.get<MainchainRPC>();
      
      // Load group data from JSON
      final appDir = await Environment.datadir();
      final file = File(path.join(appDir.path, 'bitdrive', 'multisig.json'));
      
      if (!await file.exists()) {
        throw Exception('Multisig data file not found');
      }
      
      final content = await file.readAsString();
      final jsonData = json.decode(content);
      
      // Expect new format only
      if (jsonData is! Map<String, dynamic>) {
        throw Exception('Invalid multisig.json format: expected object with groups and solo_keys');
      }
      
      final jsonGroups = jsonData['groups'] as List<dynamic>;
      
      // Find the group
      final groupIndex = jsonGroups.indexWhere((g) => g['id'] == group.id);
      if (groupIndex == -1) {
        throw Exception('Group not found in data file');
      }
      
      final groupData = jsonGroups[groupIndex];
      final enhancedGroup = MultisigGroup.fromJson(groupData);
      
      // Use wallet manager to work with the watch-only wallet
      final walletManager = WalletRPCManager();
      final walletName = enhancedGroup.watchWalletName ?? 'multisig_${enhancedGroup.id}';
      
      // Ensure wallet exists and has descriptors
      String? descriptor;
      
      try {
        // Try to get descriptor from wallet
        final walletDescriptors = await walletManager.callWalletRPC<Map<String, dynamic>>(
          walletName,
          'listdescriptors',
          [],
        );
        
        if (walletDescriptors['descriptors'] != null) {
          for (final desc in walletDescriptors['descriptors']) {
            if (desc is Map && desc['active'] == true && desc['internal'] == false) {
              descriptor = desc['desc'] as String;
              break;
            }
          }
        }
      } catch (e) {
        // Wallet might not exist
      }
      
      // If no descriptor found, create/recreate the wallet
      if (descriptor == null) {
        try {
          // Create multisig wallet as descriptor wallet
          await walletManager.createWallet(
            walletName,
            disablePrivateKeys: true,
            blank: true,
            descriptors: true,
          );
        } catch (e) {
          if (!e.toString().contains('already exists')) {
            MultisigLogger.error('Failed to create multisig wallet $walletName: $e');
            rethrow;
          }
        }
        
        // Build and import descriptors
        final sortedKeys = List<dynamic>.from(enhancedGroup.keys);
        sortedKeys.sort((a, b) => a.xpub.compareTo(b.xpub));
        
        final keyDescriptors = sortedKeys.map((key) {
          if (key.isWallet && key.fingerprint != null && key.originPath != null) {
            return '[${key.fingerprint!}/${key.originPath!}]${key.xpub}';
          } else {
            return key.xpub;
          }
        }).join(',');
        
        final receiveDesc = 'wsh(sortedmulti(${enhancedGroup.m},$keyDescriptors/0/*))';
        final changeDesc = 'wsh(sortedmulti(${enhancedGroup.m},$keyDescriptors/1/*))';
        
        // Add checksums
        final receiveResult = await api.callRAW('getdescriptorinfo', [receiveDesc]);
        final receiveWithChecksum = receiveResult is Map && receiveResult['descriptor'] != null
            ? receiveResult['descriptor'] as String
            : receiveDesc;
            
        final changeResult = await api.callRAW('getdescriptorinfo', [changeDesc]);
        final changeWithChecksum = changeResult is Map && changeResult['descriptor'] != null
            ? changeResult['descriptor'] as String
            : changeDesc;
        
        final importTimestamp = 'now';
        
        await walletManager.importDescriptors(walletName, [
          {
            'desc': receiveWithChecksum,
            'active': true,
            'internal': false,
            'timestamp': importTimestamp,
            'range': [0, 999],
          },
          {
            'desc': changeWithChecksum,
            'active': true,
            'internal': true,
            'timestamp': importTimestamp,
            'range': [0, 999],
          },
        ]);
        
        MultisigLogger.info('Descriptors imported successfully to wallet: $walletName');
        
        // Set descriptor for address generation
        descriptor = receiveWithChecksum;
        
        // Update the group data with descriptors for future use
        groupData['descriptorReceive'] = receiveWithChecksum;
        groupData['descriptorChange'] = changeWithChecksum;
        groupData['watchWalletName'] = walletName;
      }
      
      // Get current address index
      int nextIndex = enhancedGroup.nextReceiveIndex;
      
      // Derive address using the descriptor from wallet
      final addresses = await api.callRAW(
        'deriveaddresses',
        [descriptor, [nextIndex, nextIndex]],
      );
      
      if (addresses is! List || addresses.isEmpty) {
        throw Exception('Failed to derive address from descriptor');
      }
      
      final newAddress = addresses.first as String;
      final addressIndex = nextIndex;
      
      // Update the group data with new address
      final updatedAddresses = Map<String, dynamic>.from(groupData['addresses'] ?? {});
      final receiveAddresses = List<Map<String, dynamic>>.from(
        updatedAddresses['receive'] ?? [],
      );
      
      receiveAddresses.add({
        'index': addressIndex,
        'address': newAddress,
        'used': false,
      });
      
      updatedAddresses['receive'] = receiveAddresses;
      groupData['addresses'] = updatedAddresses;
      
      // Increment index for next address
      groupData['next_receive_index'] = addressIndex + 1;
      
      // Update the groups in the full structure and save
      jsonData['groups'] = jsonGroups;
      await file.writeAsString(json.encode(jsonData));
      
      return newAddress;
      
    } catch (e) {
      GetIt.I.get<Logger>().e('Error generating multisig address: $e');
      rethrow;
    }
  }
}