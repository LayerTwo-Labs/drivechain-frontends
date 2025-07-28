import 'dart:convert';
import 'dart:io';

import 'package:bitwindow/env.dart';
import 'package:bitwindow/widgets/create_multisig_modal.dart';
import 'package:bitwindow/models/multisig_group_enhanced.dart';
import 'package:bitwindow/widgets/fund_group_modal.dart';
import 'package:bitwindow/services/wallet_rpc_manager.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/sail_ui.dart';

// Use the enhanced MultisigGroup from models
typedef MultisigGroup = MultisigGroupEnhanced;

class MultisigLoungeTab extends StatefulWidget {
  const MultisigLoungeTab({super.key});

  @override
  State<MultisigLoungeTab> createState() => _MultisigLoungeTabState();
}

class _MultisigLoungeTabState extends State<MultisigLoungeTab> {
  List<MultisigGroup> _multisigGroups = [];
  bool _isLoading = true;
  String? _error;
  MainchainRPC get _rpc => GetIt.I.get<MainchainRPC>();
  final _walletManager = WalletRPCManager();

  @override
  void initState() {
    super.initState();
    _loadMultisigGroups();
  }

  Future<void> _loadMultisigGroups() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final appDir = await Environment.datadir();
      final bitdriveDir = path.join(appDir.path, 'bitdrive');
      final file = File(path.join(bitdriveDir, 'multisig.json'));

      if (!await file.exists()) {
        setState(() {
          _multisigGroups = [];
          _isLoading = false;
        });
        return;
      }

      final content = await file.readAsString();
      final List<dynamic> jsonGroups = json.decode(content);
      
      final groups = <MultisigGroup>[];
      
      // Load groups and update balances from watch-only wallets
      bool hasUpdates = false;
      
      for (int i = 0; i < jsonGroups.length; i++) {
        final jsonGroup = jsonGroups[i];
        var group = MultisigGroup.fromJson(jsonGroup);
        
        // Ensure group has a watch wallet name
        final walletName = group.watchWalletName ?? 'multisig_${group.id}';
        
        // Ensure group has watchWalletName set
        if (group.watchWalletName == null) {
          group = MultisigGroupEnhanced(
            id: group.id,
            name: group.name,
            n: group.n,
            m: group.m,
            keys: group.keys,
            created: group.created,
            txid: group.txid,
            descriptor: group.descriptor,
            descriptorReceive: group.descriptorReceive,
            descriptorChange: group.descriptorChange,
            watchWalletName: walletName,
            addresses: group.addresses,
            utxoDetails: group.utxoDetails,
            balance: group.balance,
            utxos: group.utxos,
            nextReceiveIndex: group.nextReceiveIndex,
            nextChangeIndex: group.nextChangeIndex,
          );
          hasUpdates = true;
          jsonGroup['watchWalletName'] = walletName;
        }

        try {
          // Get wallet balance and UTXO count together to ensure consistency
          final walletInfo = await _walletManager.getWalletBalanceAndUtxos(walletName);
          final balance = walletInfo['balance'] as double;
          final utxoCount = walletInfo['utxos'] as int;
          
          // Check if balance or UTXO count has changed
          if (group.balance != balance || group.utxos != utxoCount) {
            hasUpdates = true;
            
            // Update the JSON data
            jsonGroup['balance'] = balance;
            jsonGroup['utxos'] = utxoCount;
            
          }
          
          // Create updated group object
          group = MultisigGroupEnhanced(
            id: group.id,
            name: group.name,
            n: group.n,
            m: group.m,
            keys: group.keys,
            created: group.created,
            txid: group.txid,
            descriptor: group.descriptor,
            descriptorReceive: group.descriptorReceive,
            descriptorChange: group.descriptorChange,
            watchWalletName: walletName,
            addresses: group.addresses,
            utxoDetails: group.utxoDetails,
            balance: balance,
            utxos: utxoCount,
            nextReceiveIndex: group.nextReceiveIndex,
            nextChangeIndex: group.nextChangeIndex,
          );
          
        } catch (e) {
          print('Balance fetch failed for ${group.id}: $e');
          
          // If wallet doesn't exist, try to create it
          if (e.toString().contains('Wallet file not specified') || 
              e.toString().contains('not found')) {
            try {
              await _createWatchOnlyWallet(group);
              
              // Try balance again
              final walletInfo = await _walletManager.getWalletBalanceAndUtxos(walletName);
              final balance = walletInfo['balance'] as double;
              final utxoCount = walletInfo['utxos'] as int;
              
              if (group.balance != balance || group.utxos != utxoCount) {
                hasUpdates = true;
                jsonGroup['balance'] = balance;
                jsonGroup['utxos'] = utxoCount;
              }
              
              group = MultisigGroupEnhanced(
                id: group.id,
                name: group.name,
                n: group.n,
                m: group.m,
                keys: group.keys,
                created: group.created,
                txid: group.txid,
                descriptor: group.descriptor,
                descriptorReceive: group.descriptorReceive,
                descriptorChange: group.descriptorChange,
                watchWalletName: walletName,
                addresses: group.addresses,
                utxoDetails: group.utxoDetails,
                balance: balance,
                utxos: utxoCount,
                nextReceiveIndex: group.nextReceiveIndex,
                nextChangeIndex: group.nextChangeIndex,
              );
            } catch (createError) {
              print('Failed to create wallet: $createError');
            }
          }
        }
        
        groups.add(group);
      }
      
      // Write updates back to multisig.json if there were changes
      if (hasUpdates) {
        try {
          await file.writeAsString(json.encode(jsonGroups));
        } catch (e) {
          print('Failed to write updated balances to multisig.json: $e');
        }
      }
      
      setState(() {
        _multisigGroups = groups;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load multisig groups: $e';
        _isLoading = false;
      });
    }
  }
  
  Future<void> _refreshAllGroups() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final appDir = await Environment.datadir();
      final bitdriveDir = path.join(appDir.path, 'bitdrive');
      final file = File(path.join(bitdriveDir, 'multisig.json'));

      if (!await file.exists()) {
        setState(() {
          _multisigGroups = [];
          _isLoading = false;
        });
        return;
      }

      final content = await file.readAsString();
      final List<dynamic> jsonGroups = json.decode(content);
      
      final groups = <MultisigGroup>[];
      bool hasUpdates = false;
      
      
      for (int i = 0; i < jsonGroups.length; i++) {
        final jsonGroup = jsonGroups[i];
        var group = MultisigGroup.fromJson(jsonGroup);
        
        final walletName = group.watchWalletName ?? 'multisig_${group.id}';
        
        try {
          // Check if wallet exists
          final walletExists = await _walletManager.isWalletLoaded(walletName);
          
          if (!walletExists) {
            print('Creating wallet $walletName');
            await _walletManager.createWallet(
              walletName,
              disablePrivateKeys: true,
              blank: true,
            );
          }
          
          // Check if descriptors are imported
          bool needsImport = false;
          try {
            // Try to get balance - if it fails with specific errors, we need to import
            await _walletManager.getWalletBalance(walletName);
          } catch (e) {
            if (e.toString().contains('does not have descriptors') || 
                e.toString().contains('no descriptors')) {
              needsImport = true;
            }
          }
          
          // Also check by trying to list descriptors
          try {
            final descriptors = await _walletManager.callWalletRPC<Map<String, dynamic>>(
              walletName, 
              'listdescriptors', 
              []
            );
            if (descriptors['descriptors'] == null || 
                (descriptors['descriptors'] as List).isEmpty) {
              needsImport = true;
            }
          } catch (e) {
            needsImport = true;
          }
          
          if (needsImport) {
            print('Importing descriptors for $walletName');
            
            // Build descriptors if not available
            String? receiveDesc = group.descriptorReceive;
            String? changeDesc = group.descriptorChange;
            
            if (receiveDesc == null || changeDesc == null) {
              // Sort keys by BIP67 order
              final sortedKeys = List<MultisigKey>.from(group.keys);
              sortedKeys.sort((a, b) => a.xpub.compareTo(b.xpub));
              
              final keyDescriptors = sortedKeys.map((key) {
                if (key.isWallet && key.fingerprint != null && key.originPath != null) {
                  return '[${key.fingerprint!}/${key.originPath!}]${key.xpub}';
                } else {
                  return key.xpub;
                }
              }).join(',');
              
              receiveDesc = 'wsh(sortedmulti(${group.m},$keyDescriptors/0/*))';
              changeDesc = 'wsh(sortedmulti(${group.m},$keyDescriptors/1/*))';
              
              // Add checksums
              final receiveResult = await _rpc.callRAW('getdescriptorinfo', [receiveDesc]);
              if (receiveResult is Map && receiveResult['descriptor'] != null) {
                receiveDesc = receiveResult['descriptor'] as String;
              }
              
              final changeResult = await _rpc.callRAW('getdescriptorinfo', [changeDesc]);
              if (changeResult is Map && changeResult['descriptor'] != null) {
                changeDesc = changeResult['descriptor'] as String;
              }
            }
            
            // Import with appropriate timestamp
            final timestamp = group.created ?? 'now';
            await _walletManager.importDescriptors(walletName, [
              {
                'desc': receiveDesc,
                'active': true,
                'internal': false,
                'timestamp': timestamp,
                'range': [0, 999],
              },
              {
                'desc': changeDesc,
                'active': true,
                'internal': true,
                'timestamp': timestamp,
                'range': [0, 999],
              },
            ]);
            
            print('Descriptors imported successfully for $walletName');
          }
          
          // Get updated balance and UTXO count together
          var walletInfo = await _walletManager.getWalletBalanceAndUtxos(walletName);
          var balance = walletInfo['balance'] as double;
          var utxoCount = walletInfo['utxos'] as int;
          
          
          // If balance is 0, force reimport and rescan
          if (balance == 0.0 && group.balance > 0) {
            print('Balance dropped to 0, forcing reimport and rescan');
            needsImport = true;
          }
          
          // Check if wallet is still scanning
          try {
            final walletInfo = await _walletManager.getWalletInfo(walletName);
            if (walletInfo['scanning'] != null && walletInfo['scanning'] != false) {
              final scanning = walletInfo['scanning'];
              print('Wallet $walletName is still scanning: $scanning');
              // Show scanning progress if available
              if (scanning is Map && scanning['progress'] != null) {
                print('Scan progress: ${(scanning['progress'] * 100).toStringAsFixed(2)}%');
              }
            }
          } catch (e) {
            print('Could not check scan status: $e');
          }
          
          // If we imported descriptors, trigger explicit rescan if balance is still 0
          if (needsImport && balance == 0.0) {
            print('Triggering explicit rescan for $walletName');
            try {
              // Rescan from block 0 to catch all transactions
              await _walletManager.callWalletRPC<dynamic>(
                walletName,
                'rescanblockchain',
                [0] // Start from genesis
              );
              print('Rescan initiated for $walletName');
              
              // Get balance again after rescan
              walletInfo = await _walletManager.getWalletBalanceAndUtxos(walletName);
              balance = walletInfo['balance'] as double;
              utxoCount = walletInfo['utxos'] as int;
              print('After rescan - balance=$balance BTC, utxos=$utxoCount');
            } catch (e) {
              print('Rescan failed: $e');
            }
          }
          
          // Also check the specific funded address from the screenshot
          const fundedAddress = 'tb1qtsnwp66fyyvan3mcvshcu3xr2fhn8ffxlzg4vqshn5arwxxp3myqj4qxvc';
          try {
            print('Checking funded address: $fundedAddress');
            final fundedInfo = await _walletManager.callWalletRPC<Map<String, dynamic>>(
              walletName,
              'getaddressinfo',
              [fundedAddress]
            );
            print('Funded address info: ismine=${fundedInfo['ismine']}, iswatchonly=${fundedInfo['iswatchonly']}, solvable=${fundedInfo['solvable']}');
            
            if (fundedInfo['ismine'] == false && fundedInfo['iswatchonly'] == false) {
              // Address not recognized - descriptors may need updating
              try {
                final walletDescriptors = await _walletManager.callWalletRPC<Map<String, dynamic>>(
                  walletName,
                  'listdescriptors',
                  []
                );
                
                String? walletReceiveDesc;
                String? walletChangeDesc;
                
                if (walletDescriptors['descriptors'] != null) {
                  for (final desc in walletDescriptors['descriptors']) {
                    if (desc is Map) {
                      final descStr = desc['desc']?.toString() ?? '';
                      final isActive = desc['active'] == true;
                      final isInternal = desc['internal'] == true;
                      
                      // Save the descriptors from wallet
                      if (isActive && !isInternal && walletReceiveDesc == null) {
                        walletReceiveDesc = descStr;
                      } else if (isActive && isInternal && walletChangeDesc == null) {
                        walletChangeDesc = descStr;
                      }
                    }
                  }
                }
                
                // If descriptors are missing in JSON but exist in wallet, update them
                if ((group.descriptorReceive == null || group.descriptorChange == null) && 
                    (walletReceiveDesc != null || walletChangeDesc != null)) {
                  hasUpdates = true;
                  
                  if (walletReceiveDesc != null) {
                    jsonGroup['descriptorReceive'] = walletReceiveDesc;
                  }
                  if (walletChangeDesc != null) {
                    jsonGroup['descriptorChange'] = walletChangeDesc;
                  }
                  
                  // Update group object with descriptors
                  group = MultisigGroupEnhanced(
                    id: group.id,
                    name: group.name,
                    n: group.n,
                    m: group.m,
                    keys: group.keys,
                    created: group.created,
                    txid: group.txid,
                    descriptor: group.descriptor,
                    descriptorReceive: walletReceiveDesc ?? group.descriptorReceive,
                    descriptorChange: walletChangeDesc ?? group.descriptorChange,
                    watchWalletName: walletName,
                    addresses: group.addresses,
                    utxoDetails: group.utxoDetails,
                    balance: group.balance,
                    utxos: group.utxos,
                    nextReceiveIndex: group.nextReceiveIndex,
                    nextChangeIndex: group.nextChangeIndex,
                  );
                }
              } catch (e) {
                print('Failed to list descriptors: $e');
              }
              
            }
            
            // Get transactions for balance calculation
            final txList = await _walletManager.callWalletRPC<List<dynamic>>(
              walletName,
              'listtransactions',
              ['*', 100] // Last 100 transactions
            );
            
          } catch (e) {
            print('Failed to check funded address: $e');
          }
          
          
          // Update if changed
          if (group.balance != balance || group.utxos != utxoCount) {
            hasUpdates = true;
            jsonGroup['balance'] = balance;
            jsonGroup['utxos'] = utxoCount;
          }
          
          // Ensure watchWalletName is saved
          if (group.watchWalletName == null) {
            hasUpdates = true;
            jsonGroup['watchWalletName'] = walletName;
          }
          
          groups.add(MultisigGroupEnhanced(
            id: group.id,
            name: group.name,
            n: group.n,
            m: group.m,
            keys: group.keys,
            created: group.created,
            txid: group.txid,
            descriptor: group.descriptor,
            descriptorReceive: group.descriptorReceive,
            descriptorChange: group.descriptorChange,
            watchWalletName: walletName,
            addresses: group.addresses,
            utxoDetails: group.utxoDetails,
            balance: balance,
            utxos: utxoCount,
            nextReceiveIndex: group.nextReceiveIndex,
            nextChangeIndex: group.nextChangeIndex,
          ));
          
        } catch (e) {
          print('Error refreshing wallet $walletName: $e');
          groups.add(group); // Keep original on error
        }
      }
      
      // Save updates
      if (hasUpdates) {
        try {
          await file.writeAsString(json.encode(jsonGroups));
        } catch (e) {
          print('Failed to write updates: $e');
        }
      }
      
      setState(() {
        _multisigGroups = groups;
        _isLoading = false;
      });
      
    } catch (e) {
      setState(() {
        _error = 'Failed to refresh groups: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _reimportDescriptors(MultisigGroup group) async {
    try {
      final walletName = group.watchWalletName ?? 'multisig_${group.id}';
      
      print('Reimporting descriptors for wallet: $walletName');
      
      // Ensure wallet exists
      if (!await _walletManager.isWalletLoaded(walletName)) {
        print('Wallet $walletName not found, creating it first');
        await _walletManager.createWallet(
          walletName,
          disablePrivateKeys: true,
          blank: true,
        );
      }
      
      // Get descriptors
      String? receiveDesc = group.descriptorReceive;
      String? changeDesc = group.descriptorChange;
      
      if (receiveDesc == null || changeDesc == null) {
        print('Building descriptors for reimport');
        
        // Sort keys by BIP67 order
        final sortedKeys = List<MultisigKey>.from(group.keys);
        sortedKeys.sort((a, b) => a.xpub.compareTo(b.xpub));
        
        // Build the key list with origins
        final keyDescriptors = sortedKeys.map((key) {
          if (key.isWallet && key.fingerprint != null && key.originPath != null) {
            return '[${key.fingerprint!}/${key.originPath!}]${key.xpub}';
          } else {
            return key.xpub;
          }
        }).join(',');
        
        // Build descriptors
        receiveDesc = 'wsh(sortedmulti(${group.m},$keyDescriptors/0/*))';
        changeDesc = 'wsh(sortedmulti(${group.m},$keyDescriptors/1/*))';
        
        // Add checksums
        final receiveResult = await _rpc.callRAW('getdescriptorinfo', [receiveDesc]);
        if (receiveResult is Map && receiveResult['descriptor'] != null) {
          receiveDesc = receiveResult['descriptor'] as String;
        }
        
        final changeResult = await _rpc.callRAW('getdescriptorinfo', [changeDesc]);
        if (changeResult is Map && changeResult['descriptor'] != null) {
          changeDesc = changeResult['descriptor'] as String;
        }
      }
      
      print('Importing descriptors to wallet $walletName');
      print('Receive descriptor: ${receiveDesc.substring(0, 50)}...');
      print('Change descriptor: ${changeDesc.substring(0, 50)}...');
      
      // Import descriptors with rescan
      final importResult = await _walletManager.importDescriptors(walletName, [
        {
          'desc': receiveDesc,
          'active': true,
          'internal': false,
          'timestamp': 0,  // Rescan from genesis
          'range': [0, 999],  // Import first 1000 addresses
        },
        {
          'desc': changeDesc,
          'active': true,
          'internal': true,
          'timestamp': 0,  // Rescan from genesis
          'range': [0, 999],  // Import first 1000 addresses
        },
      ]);
      
      print('Import descriptors result: $importResult');
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Descriptors reimported for ${group.name}. Rescanning blockchain...'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
      
    } catch (e) {
      print('Error reimporting descriptors: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reimport descriptors: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createWatchOnlyWallet(MultisigGroup group) async {
    try {
      final walletName = group.watchWalletName ?? 'multisig_${group.id}';
      
      print('Creating watch-only wallet: $walletName');
      
      // Create watch-only wallet using wallet manager
      await _walletManager.createWallet(
        walletName,
        disablePrivateKeys: true,
        blank: true,
      );
      
      // Build descriptors on-demand if not available
      String? receiveDesc = group.descriptorReceive;
      String? changeDesc = group.descriptorChange;
      
      if (receiveDesc == null || changeDesc == null) {
        print('Building descriptors on-demand for wallet $walletName');
        
        // Sort keys by BIP67 order (lexicographic order of xpubs)
        final sortedKeys = List<MultisigKey>.from(group.keys);
        sortedKeys.sort((a, b) => a.xpub.compareTo(b.xpub));
        
        // Build the key list with origins for wallet keys
        final keyDescriptors = sortedKeys.map((key) {
          if (key.isWallet && key.fingerprint != null && key.originPath != null) {
            return '[${key.fingerprint!}/${key.originPath!}]${key.xpub}';
          } else {
            return key.xpub;
          }
        }).join(',');
        
        // Build descriptors
        receiveDesc = 'wsh(sortedmulti(${group.m},$keyDescriptors/0/*))';
        changeDesc = 'wsh(sortedmulti(${group.m},$keyDescriptors/1/*))';
        
        // Add checksums
        final receiveResult = await _rpc.callRAW('getdescriptorinfo', [receiveDesc]);
        if (receiveResult is Map && receiveResult['descriptor'] != null) {
          receiveDesc = receiveResult['descriptor'] as String;
        }
        
        final changeResult = await _rpc.callRAW('getdescriptorinfo', [changeDesc]);
        if (changeResult is Map && changeResult['descriptor'] != null) {
          changeDesc = changeResult['descriptor'] as String;
        }
        
        print('Built receive descriptor: ${receiveDesc.substring(0, 50)}...');
        print('Built change descriptor: ${changeDesc.substring(0, 50)}...');
      }
      
      // Import descriptors using wallet manager
      final importResult = await _walletManager.importDescriptors(walletName, [
        {
          'desc': receiveDesc,
          'active': true,
          'internal': false,
          'timestamp': 'now',
        },
        {
          'desc': changeDesc,
          'active': true,
          'internal': true,
          'timestamp': 'now',
        },
      ]);
      
      print('Import descriptors result: $importResult');
      
    } catch (e) {
      print('Error creating watch-only wallet: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return QtPage(
      child: SingleChildScrollView(
        child: SailColumn(
          spacing: SailStyleValues.padding16,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Groups section
            SailCard(
              title: 'Multisig Groups',
              subtitle: 'Create and manage multi-signature wallets',
              error: _error,
              child: SizedBox(
                height: 300,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : SailTable(
                              getRowId: (index) => _multisigGroups.isNotEmpty 
                                  ? _multisigGroups[index].id 
                                  : 'empty$index',
                              headerBuilder: (context) => [
                                const SailTableHeaderCell(name: 'Name'),
                                const SailTableHeaderCell(name: 'ID'),
                                const SailTableHeaderCell(name: 'Balance (BTC)'),
                                const SailTableHeaderCell(name: 'UTXOs'),
                                const SailTableHeaderCell(name: 'Total Keys'),
                                const SailTableHeaderCell(name: 'Keys Required'),
                                const SailTableHeaderCell(name: 'Type'),
                              ],
                              rowBuilder: (context, row, selected) {
                                if (_multisigGroups.isEmpty) {
                                  return [
                                    const SailTableCell(value: 'No multisig groups yet'),
                                    const SailTableCell(value: ''),
                                    const SailTableCell(value: ''),
                                    const SailTableCell(value: ''),
                                    const SailTableCell(value: ''),
                                    const SailTableCell(value: ''),
                                    const SailTableCell(value: ''),
                                  ];
                                }
                                
                                final group = _multisigGroups[row];
                                return [
                                  SailTableCell(value: group.name),
                                  SailTableCell(value: group.id.toUpperCase()),
                                  SailTableCell(value: group.balance.toStringAsFixed(8)),
                                  SailTableCell(value: group.utxos.toString()),
                                  SailTableCell(value: group.n.toString()),
                                  SailTableCell(value: group.m.toString()),
                                  SailTableCell(value: 'xPub'),
                                ];
                              },
                              rowCount: _multisigGroups.isEmpty ? 1 : _multisigGroups.length,
                              drawGrid: true,
                            ),
                    ),
                    const SizedBox(width: SailStyleValues.padding16),
                    Center(
                      child: SailColumn(
                        spacing: SailStyleValues.padding08,
                        children: [
                          SailButton(
                            label: 'Create New Group',
                            onPressed: () async {
                              final result = await showDialog(
                                context: context,
                                builder: (context) => const CreateMultisigModal(),
                              );
                              
                              // Reload groups after modal closes
                              if (result != false) {
                                await _loadMultisigGroups();
                              }
                            },
                            variant: ButtonVariant.primary,
                          ),
                          SailButton(
                            label: 'Import from TXID',
                            onPressed: () async {
                              final result = await showDialog(
                                context: context,
                                builder: (context) => const ImportMultisigModal(),
                              );
                              
                              // Reload groups after import
                              if (result == true) {
                                await _loadMultisigGroups();
                              }
                            },
                            variant: ButtonVariant.secondary,
                          ),
                          SailButton(
                            label: 'Fund Group',
                            onPressed: _multisigGroups.isEmpty ? null : () async {
                              final result = await showDialog(
                                context: context,
                                builder: (context) => FundGroupModal(
                                  groups: _multisigGroups,
                                ),
                              );
                              
                              if (result == true) {
                                await _loadMultisigGroups();
                              }
                            },
                            variant: ButtonVariant.secondary,
                          ),
                          SailButton(
                            label: 'Refresh',
                            onPressed: () async {
                              await _refreshAllGroups();
                            },
                            variant: ButtonVariant.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Transaction History section
            SailCard(
              title: 'Transaction History',
              subtitle: 'View and manage multisig transactions',
              child: SizedBox(
                height: 300,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SailTable(
                        getRowId: (index) => 'tx_empty$index',
                        headerBuilder: (context) => [
                          const SailTableHeaderCell(name: 'Group'),
                          const SailTableHeaderCell(name: 'MuTxid'),
                          const SailTableHeaderCell(name: 'Status'),
                          const SailTableHeaderCell(name: 'Action'),
                          const SailTableHeaderCell(name: 'Bitcoin Txid'),
                        ],
                        rowBuilder: (context, row, selected) {
                          return [
                            const SailTableCell(value: 'Multisig functionality coming soon...'),
                            const SailTableCell(value: ''),
                            const SailTableCell(value: ''),
                            const SailTableCell(value: ''),
                            const SailTableCell(value: ''),
                          ];
                        },
                        rowCount: 1,
                        drawGrid: true,
                      ),
                    ),
                    const SizedBox(width: SailStyleValues.padding16),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SailText.primary13('Transaction Tools'),
                        SailSpacing(SailStyleValues.padding08),
                        SailButton(
                          label: 'Create Transaction',
                          onPressed: null,
                          variant: ButtonVariant.secondary,
                        ),
                        SailSpacing(SailStyleValues.padding08),
                        SailButton(
                          label: 'Sign and Send',
                          onPressed: null,
                          variant: ButtonVariant.secondary,
                        ),
                        SailSpacing(SailStyleValues.padding08),
                        SailButton(
                          label: 'Finalize and Broadcast',
                          onPressed: null,
                          variant: ButtonVariant.secondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}