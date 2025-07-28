import 'dart:convert';
import 'dart:io';

import 'package:bitwindow/env.dart';
import 'package:bitwindow/models/multisig_group_enhanced.dart';
import 'package:bitwindow/pages/wallet/wallet_multisig_lounge.dart';
import 'package:bitwindow/services/wallet_rpc_manager.dart';
import 'package:bitwindow/widgets/create_multisig_modal.dart';
import 'package:bitwindow/widgets/multisig_compatibility_note.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';
import 'package:sail_ui/rpcs/mainchain_rpc.dart';

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
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
            child: SailCard(
              title: 'Fund Multisig Group',
              subtitle: 'Select an xPub-based group to generate a funding address',
              error: viewModel.modalError,
              child: SingleChildScrollView(
                child: SailColumn(
                  spacing: SailStyleValues.padding16,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!viewModel.hasSelectedGroup) ...[
                      // Step 1: Select Group
                      SailText.primary15('Select Multisig Group:'),
                      if (viewModel.groups.isEmpty)
                        SailText.secondary12('No multisig groups available')
                      else
                        ...viewModel.groups.map((group) => SailCard(
                              shadowSize: ShadowSize.none,
                              child: SailRow(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SailColumn(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: SailStyleValues.padding04,
                                    children: [
                                      SailText.primary13(group.name),
                                      SailText.secondary12('ID: ${group.id.toUpperCase()}'),
                                      SailText.secondary12('${group.m} of ${group.n} multisig'),
                                      SailText.secondary12('Balance: ${group.balance.toStringAsFixed(8)} BTC'),
                                    ],
                                  ),
                                  SailButton(
                                    label: 'Select',
                                    onPressed: () async => viewModel.selectGroup(group),
                                    variant: ButtonVariant.primary,
                                  ),
                                ],
                              ),
                            ),),
                    ] else ...[
                      // Step 2: Show selected group and get address
                      SailCard(
                        shadowSize: ShadowSize.none,
                        child: SailColumn(
                          spacing: SailStyleValues.padding08,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SailText.primary15('Selected Group: ${viewModel.selectedGroup?.name}'),
                            SailText.secondary12('ID: ${viewModel.selectedGroup?.id.toUpperCase()}'),
                            SailText.secondary12('${viewModel.selectedGroup?.m} of ${viewModel.selectedGroup?.n} multisig'),
                          ],
                        ),
                      ),
                      
                      if (viewModel.generatedAddress != null) ...[
                        SailText.primary15('Funding Address:'),
                        SailCard(
                          shadowSize: ShadowSize.none,
                          child: SailColumn(
                            spacing: SailStyleValues.padding08,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SailRow(
                                children: [
                                  Expanded(
                                    child: SailText.primary13(viewModel.generatedAddress!),
                                  ),
                                  SailButton(
                                    label: 'Copy',
                                    onPressed: () async => await viewModel.copyAddress(),
                                    variant: ButtonVariant.ghost,
                                  ),
                                ],
                              ),
                              SailText.secondary12(
                                'Send funds to this address to fund the multisig group. '
                                'The watch-only wallet will automatically track UTXOs sent to this address.',
                              ),
                            ],
                          ),
                        ),
                        SailSpacing(SailStyleValues.padding08),
                        const MultisigCompatibilityNote(),
                      ] else ...[
                        SailButton(
                          label: 'Get Address',
                          onPressed: () async => await viewModel.generateAddress(),
                          loading: viewModel.isBusy,
                          variant: ButtonVariant.primary,
                        ),
                      ],
                    ],
                    
                    // Navigation buttons
                    SailRow(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (viewModel.hasSelectedGroup)
                          SailButton(
                            label: 'Back',
                            onPressed: () async => viewModel.goBack(),
                            variant: ButtonVariant.ghost,
                          )
                        else
                          Container(),
                        
                        SailButton(
                          label: 'Close',
                          onPressed: () async => Navigator.of(context).pop(false),
                          variant: ButtonVariant.ghost,
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

class FundGroupModalViewModel extends BaseViewModel {
  final List<MultisigGroup> groups;
  
  String? modalError;
  MultisigGroup? selectedGroup;
  String? generatedAddress;
  bool hasSelectedGroup = false;
  
  FundGroupModalViewModel({required this.groups});
  
  void init() {
    notifyListeners();
  }

  // Add checksum to descriptor using Bitcoin Core's getdescriptorinfo
  Future<String> _addDescriptorChecksum(String descriptor) async {
    try {
      // If descriptor already has checksum, return as-is
      if (descriptor.contains('#')) {
        return descriptor;
      }
      
      // Get checksum from Bitcoin Core
      final MainchainRPC rpc = GetIt.I.get<MainchainRPC>();
      final result = await rpc.callRAW('getdescriptorinfo', [descriptor]);
      
      if (result is Map && result['descriptor'] != null) {
        final descriptorWithChecksum = result['descriptor'] as String;
        GetIt.I.get<Logger>().d('Added checksum to descriptor: ${descriptorWithChecksum.substring(0, 50)}...');
        return descriptorWithChecksum;
      }
      
      // If failed to get checksum, throw error instead of returning invalid descriptor
      throw Exception('Bitcoin Core getdescriptorinfo returned invalid response: $result');
    } catch (e) {
      GetIt.I.get<Logger>().e('Failed to add checksum to descriptor: $e');
      GetIt.I.get<Logger>().e('Original descriptor: $descriptor');
      throw Exception('Failed to add checksum to descriptor: $e');
    }
  }

  // Build receive descriptor on-demand from keys
  Future<String> _buildReceiveDescriptor(MultisigGroupEnhanced group) async {
    try {
      // Sort keys by BIP67 order (lexicographic order of xpubs)
      final sortedKeys = List<MultisigKey>.from(group.keys);
      sortedKeys.sort((a, b) => a.xpub.compareTo(b.xpub));
      
      GetIt.I.get<Logger>().d('Building descriptor for ${group.keys.length} keys (${group.m}-of-${group.n})');
      
      // Build the key list with origins for wallet keys
      final keyDescriptors = sortedKeys.map((key) {
        if (key.isWallet && key.fingerprint != null && key.originPath != null) {
          final keyDesc = '[${key.fingerprint!}/${key.originPath!}]${key.xpub}/0/*';
          GetIt.I.get<Logger>().d('Wallet key: ${keyDesc.substring(0, 50)}...');
          return keyDesc;
        } else {
          final keyDesc = '${key.xpub}/0/*';
          GetIt.I.get<Logger>().d('External key: ${keyDesc.substring(0, 50)}...');
          return keyDesc;
        }
      }).join(',');
      
      // Build the receive descriptor
      final descriptor = 'wsh(sortedmulti(${group.m},$keyDescriptors))';
      GetIt.I.get<Logger>().d('Built descriptor (before checksum): ${descriptor.substring(0, 100)}...');
      return descriptor;
    } catch (e) {
      GetIt.I.get<Logger>().e('Failed to build receive descriptor: $e');
      throw Exception('Failed to build receive descriptor: $e');
    }
  }
  
  void selectGroup(MultisigGroup group) {
    selectedGroup = group;
    hasSelectedGroup = true;
    generatedAddress = null;
    modalError = null;
    notifyListeners();
  }
  
  void goBack() {
    hasSelectedGroup = false;
    selectedGroup = null;
    generatedAddress = null;
    modalError = null;
    notifyListeners();
  }
  
  Future<void> generateAddress() async {
    if (selectedGroup == null) return;
    
    try {
      modalError = null;
      setBusy(true);
      
      // Generate multisig address using ranged descriptors
      final address = await _generateMultisigAddress(selectedGroup!);
      
      generatedAddress = address;
      
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
      
      // Load enhanced group data from JSON
      final appDir = await Environment.datadir();
      final file = File(path.join(appDir.path, 'bitdrive', 'multisig.json'));
      
      if (!await file.exists()) {
        throw Exception('Multisig data file not found');
      }
      
      final content = await file.readAsString();
      final jsonGroups = json.decode(content) as List<dynamic>;
      
      // Find the group
      final groupIndex = jsonGroups.indexWhere((g) => g['id'] == group.id);
      if (groupIndex == -1) {
        throw Exception('Group not found in data file');
      }
      
      final groupData = jsonGroups[groupIndex];
      final enhancedGroup = MultisigGroupEnhanced.fromJson(groupData);
      
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
          []
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
        // Wallet doesn't exist or has issues, will create it below
      }
      
      // If no descriptor found, create/recreate the wallet
      if (descriptor == null) {
        try {
          // Create watch-only wallet
          await walletManager.createWallet(
            walletName,
            disablePrivateKeys: true,
            blank: true,
          );
        } catch (e) {
          // Wallet might already exist
          if (!e.toString().contains('already exists')) {
            rethrow;
          }
        }
        
        // Build and import descriptors
        final sortedKeys = List<MultisigKey>.from(enhancedGroup.keys);
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
        
        // Import descriptors
        await walletManager.importDescriptors(walletName, [
          {
            'desc': receiveWithChecksum,
            'active': true,
            'internal': false,
            'timestamp': enhancedGroup.created ?? 'now',
            'range': [0, 999],
          },
          {
            'desc': changeWithChecksum,
            'active': true,
            'internal': true,
            'timestamp': enhancedGroup.created ?? 'now',
            'range': [0, 999],
          },
        ]);
        
        // Verify the descriptor was actually imported by re-querying the wallet
        try {
          final verifyDescriptors = await walletManager.callWalletRPC<Map<String, dynamic>>(
            walletName,
            'listdescriptors',
            []
          );
          
          if (verifyDescriptors['descriptors'] != null) {
            for (final desc in verifyDescriptors['descriptors']) {
              if (desc is Map && desc['active'] == true && desc['internal'] == false) {
                descriptor = desc['desc'] as String;
                break;
              }
            }
          }
        } catch (e) {
          // Fallback to the checksum descriptor if verification failed
          descriptor = receiveWithChecksum;
        }
        
        // Fallback to the checksum descriptor if verification failed
        if (descriptor == null) {
          descriptor = receiveWithChecksum;
        }
        
        // Update the group data with descriptors for future use
        groupData['descriptorReceive'] = receiveWithChecksum;
        groupData['descriptorChange'] = changeWithChecksum;
        groupData['watchWalletName'] = walletName;
      }
      
      // Ensure we have a descriptor before proceeding
      if (descriptor == null) {
        throw Exception('No active receive descriptor found in wallet $walletName');
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
      
      // Save updated data back to file
      await file.writeAsString(json.encode(jsonGroups));
      
      return newAddress;
      
    } catch (e) {
      GetIt.I.get<Logger>().e('Error generating multisig address: $e');
      rethrow;
    }
  }
  
  
  Future<void> copyAddress() async {
    if (generatedAddress != null) {
      await Clipboard.setData(ClipboardData(text: generatedAddress!));
      modalError = null;
      notifyListeners();
    }
  }
}