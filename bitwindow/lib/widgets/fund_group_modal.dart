import 'dart:convert';
import 'dart:io';

import 'package:bitwindow/env.dart';
import 'package:bitwindow/models/multisig_group.dart';
import 'package:bitwindow/providers/hd_wallet_provider.dart';
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

// Helper function to log multisig debugging information to file
Future<void> _logToFile(String message) async {
  try {
    final dir = Directory(path.dirname(path.current));
    final file = File(path.join(dir.path, 'bitwindow', 'multisig_output.txt'));
    
    // Ensure parent directory exists
    await file.parent.create(recursive: true);
    
    final timestamp = DateTime.now().toIso8601String();
    await file.writeAsString('[$timestamp] FUND_GROUP: $message\n', mode: FileMode.append);
  } catch (e) {
    print('Failed to write to multisig_output.txt: $e');
  }
}

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
                          onPressed: () async => Navigator.of(context).pop(viewModel.generatedAddress != null),
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
  HDWalletProvider? _hdWalletProvider;
  
  FundGroupModalViewModel({required this.groups});
  
  // Getter to check if mnemonic is available
  bool get hasMnemonic => _hdWalletProvider?.mnemonic != null;
  String? get mnemonic => _hdWalletProvider?.mnemonic;
  
  Future<void> init() async {
    try {
      // Get the HD wallet provider singleton that's already initialized
      _hdWalletProvider = GetIt.I.get<HDWalletProvider>();
      
      // Ensure it's initialized
      if (!_hdWalletProvider!.isInitialized) {
        await _hdWalletProvider!.init();
      }
      
      if (_hdWalletProvider!.error != null) {
        GetIt.I.get<Logger>().w('HD wallet provider error: ${_hdWalletProvider!.error}');
        modalError = 'Failed to load wallet mnemonic: ${_hdWalletProvider!.error}';
      } else if (_hdWalletProvider!.mnemonic != null) {
        GetIt.I.get<Logger>().d('Successfully loaded mnemonic from l1_starter.txt for fund group modal');
      } else {
        GetIt.I.get<Logger>().w('HD wallet provider initialized but no mnemonic available');
        modalError = 'Wallet mnemonic not available';
      }
    } catch (e) {
      GetIt.I.get<Logger>().e('Failed to access HD wallet provider: $e');
      modalError = 'Failed to initialize wallet: $e';
    }
    
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
  Future<String> _buildReceiveDescriptor(MultisigGroup group) async {
    try {
      // Sort keys by BIP67 order (lexicographic order of xpubs)
      final sortedKeys = List<MultisigKey>.from(group.keys);
      sortedKeys.sort((a, b) => a.xpub.compareTo(b.xpub));
      
      GetIt.I.get<Logger>().d('Building descriptor for ${group.keys.length} keys (${group.m}-of-${group.n})');
      
      // Build the key list with origins for wallet keys (consistent with other methods)
      final keyDescriptors = sortedKeys.map((key) {
        if (key.isWallet && key.fingerprint != null && key.originPath != null) {
          final keyDesc = '[${key.fingerprint!}/${key.originPath!}]${key.xpub}';
          GetIt.I.get<Logger>().d('Wallet key: ${keyDesc.substring(0, 50)}...');
          return keyDesc;
        } else {
          final keyDesc = key.xpub;
          GetIt.I.get<Logger>().d('External key: ${keyDesc.substring(0, 50)}...');
          return keyDesc;
        }
      }).join(',');
      
      // Build the receive descriptor
      final descriptor = 'wsh(sortedmulti(${group.m},$keyDescriptors/0/*))';
      GetIt.I.get<Logger>().d('Built descriptor (before checksum): ${descriptor.substring(0, 100)}...');
      
      // Add checksum using Bitcoin Core
      try {
        final api = GetIt.I.get<MainchainRPC>();
        final descriptorInfo = await api.callRAW('getdescriptorinfo', [descriptor]);
        if (descriptorInfo is Map && descriptorInfo['descriptor'] != null) {
          final descriptorWithChecksum = descriptorInfo['descriptor'] as String;
          GetIt.I.get<Logger>().d('Generated descriptor with checksum: ${descriptorWithChecksum.substring(0, 50)}...');
          return descriptorWithChecksum;
        } else {
          throw Exception('Invalid descriptor info response: $descriptorInfo');
        }
      } catch (e) {
        GetIt.I.get<Logger>().e('Failed to add checksum to descriptor: $e');
        // Fall back to descriptor without checksum if checksum generation fails
        return descriptor;
      }
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
      
      // Load group data from JSON
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
        await _logToFile('Wallet $walletName is not loaded or has issues, will create/recreate it: $e');
      }
      
      // If no descriptor found, create/recreate the wallet
      if (descriptor == null) {
        try {
          // Create multisig wallet as descriptor wallet
          await walletManager.createWallet(
            walletName,
            disablePrivateKeys: true, // Disable private keys for watch-only wallet
            blank: true,
            descriptors: true, // Enable descriptor wallet
          );
        } catch (e) {
          // Wallet might already exist
          if (!e.toString().contains('already exists')) {
            await _logToFile('Failed to create multisig wallet $walletName: $e');
            rethrow;
          }
          await _logToFile('Wallet $walletName already exists, continuing with descriptor import');
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
        
        // Import descriptors - use a recent timestamp to avoid long rescans
        // For existing groups, we'll use 'now' and rely on manual rescan if needed
        final importTimestamp = 'now';
        
        await _logToFile('Importing descriptors with timestamp: $importTimestamp');
        await _logToFile('Receive descriptor: ${receiveWithChecksum.substring(0, 100)}...');
        await _logToFile('Change descriptor: ${changeWithChecksum.substring(0, 100)}...');
        
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
        
        await _logToFile('Descriptors imported successfully to wallet: $walletName');
        
        // For descriptor wallets, addresses are automatically derived from the descriptors
        // The range [0, 999] we specified means it will track up to 1000 addresses
        await _logToFile('Descriptor wallet configured with address range [0, 999]');
        
        // Trigger a rescan to detect any existing UTXOs
        // Only scan recent blocks (last 1000) for performance
        await _logToFile('Starting blockchain rescan for wallet: $walletName');
        try {
          // Get current block height
          final blockchainInfo = await api.callRAW('getblockchaininfo', []);
          final currentHeight = blockchainInfo['blocks'] as int;
          final scanFromHeight = (currentHeight - 1000).clamp(0, currentHeight);
          
          await _logToFile('Rescanning from block $scanFromHeight to $currentHeight');
          await walletManager.callWalletRPC(
            walletName,
            'rescanblockchain',
            [scanFromHeight, currentHeight],
          );
          await _logToFile('Rescan completed successfully');
        } catch (e) {
          await _logToFile('Rescan failed (non-critical): $e');
          // Continue even if rescan fails - UTXOs might still be detected
        }
        
        // Verify the descriptor was actually imported by re-querying the wallet
        try {
          final verifyDescriptors = await walletManager.callWalletRPC<Map<String, dynamic>>(
            walletName,
            'listdescriptors',
            [],
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
          await _logToFile('Failed to verify imported descriptors for wallet $walletName: $e');
          // Fallback to the checksum descriptor if verification failed
          descriptor = receiveWithChecksum;
        }
        
        // Fallback to the checksum descriptor if verification failed
        descriptor ??= receiveWithChecksum;
        
        // Update the group data with descriptors for future use
        groupData['descriptorReceive'] = receiveWithChecksum;
        groupData['descriptorChange'] = changeWithChecksum;
        groupData['watchWalletName'] = walletName;
      }
      
      // Get current address index
      int nextIndex = enhancedGroup.nextReceiveIndex;
      
      // Derive address using the descriptor from wallet
      await _logToFile('Deriving address at index $nextIndex from descriptor: ${descriptor.substring(0, 100)}...');
      final addresses = await api.callRAW(
        'deriveaddresses',
        [descriptor, [nextIndex, nextIndex]],
      );
      
      if (addresses is! List || addresses.isEmpty) {
        throw Exception('Failed to derive address from descriptor');
      }
      
      await _logToFile('Derived address: ${addresses[0]}');
      
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
      
      // After saving, trigger a wallet balance check to update UTXOs
      try {
        await _logToFile('Checking wallet balance after address generation');
        final balance = await walletManager.callWalletRPC<Map<String, dynamic>>(
          walletName,
          'getbalances',
          [],
        );
        await _logToFile('Wallet balance: ${balance.toString()}');
        
        // Get unspent UTXOs to update the count
        final utxos = await walletManager.callWalletRPC<List<dynamic>>(
          walletName,
          'listunspent',
          [],
        );
        
        final utxoCount = utxos.length;
        await _logToFile('Found $utxoCount UTXOs in wallet $walletName');
        
        // Update the group data with current balance and UTXO count
        if (balance['mine'] != null && balance['mine']['trusted'] != null) {
          groupData['balance'] = balance['mine']['trusted'];
          groupData['utxos'] = utxoCount;
          await file.writeAsString(json.encode(jsonGroups));
        }
      } catch (e) {
        await _logToFile('Failed to update balance after address generation: $e');
      }
      
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