import 'dart:convert';
import 'dart:io';

import 'package:bitwindow/env.dart';
import 'package:bitwindow/widgets/create_multisig_modal.dart';
import 'package:bitwindow/models/multisig_group_enhanced.dart';
import 'package:bitwindow/models/multisig_transaction.dart';
import 'package:bitwindow/services/transaction_storage.dart';
import 'package:bitwindow/widgets/combine_broadcast_modal.dart';
import 'package:bitwindow/widgets/fund_group_modal.dart';
import 'package:bitwindow/widgets/import_psbt_modal.dart';
import 'package:bitwindow/widgets/psbt_coordinator_modal.dart';
import 'package:bitwindow/services/wallet_rpc_manager.dart';
import 'package:bitwindow/providers/hd_wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/sail_ui.dart';

typedef MultisigGroup = MultisigGroupEnhanced;
class TransactionRow {
  final MultisigTransaction transaction;
  final bool hasWalletKeys;
  final bool walletHasSigned;
  
  TransactionRow({
    required this.transaction,
    required this.hasWalletKeys,
    required this.walletHasSigned,
  });
}

class MultisigLoungeTab extends StatefulWidget {
  const MultisigLoungeTab({super.key});

  @override
  State<MultisigLoungeTab> createState() => _MultisigLoungeTabState();
}

class _MultisigLoungeTabState extends State<MultisigLoungeTab> {
  List<MultisigGroup> _multisigGroups = [];
  List<MultisigTransaction> _transactions = [];
  bool _isLoading = true;
  String? _error;
  MultisigGroup? _selectedGroup;
  MainchainRPC get _rpc => GetIt.I.get<MainchainRPC>();
  final _walletManager = WalletRPCManager();

  Future<Map<String, String>> _buildDescriptors(MultisigGroup group) async {
    final sortedKeys = List<MultisigKey>.from(group.keys);
    sortedKeys.sort((a, b) => a.xpub.compareTo(b.xpub));
    
    final keyDescriptors = sortedKeys.map((key) {
      if (key.isWallet && key.fingerprint != null && key.originPath != null) {
        return '[${key.fingerprint!}/${key.originPath!}]${key.xpub}';
      } else {
        return key.xpub;
      }
    }).join(',');
    
    String receiveDesc = 'wsh(sortedmulti(${group.m},$keyDescriptors/0/*))';
    String changeDesc = 'wsh(sortedmulti(${group.m},$keyDescriptors/1/*))';
    
    final receiveResult = await _rpc.callRAW('getdescriptorinfo', [receiveDesc]);
    if (receiveResult is Map && receiveResult['descriptor'] != null) {
      receiveDesc = receiveResult['descriptor'] as String;
    }
    
    final changeResult = await _rpc.callRAW('getdescriptorinfo', [changeDesc]);
    if (changeResult is Map && changeResult['descriptor'] != null) {
      changeDesc = changeResult['descriptor'] as String;
    }
    
    return {'receive': receiveDesc, 'change': changeDesc};
  }

  List<TransactionRow> get _transactionRows {
    final rows = <TransactionRow>[];
    
    for (final tx in _transactions) {
      // Find the group for this transaction
      final group = _multisigGroups.firstWhere(
        (g) => g.id == tx.groupId,
        orElse: () => MultisigGroup(
          id: tx.groupId,
          name: 'Unknown',
          n: 0,
          m: 0,
          keys: [],
          created: 0,
        ),
      );
      
      // Check if this group has wallet keys
      final walletKeys = group.keys.where((k) => k.isWallet).toList();
      final hasWalletKeys = walletKeys.isNotEmpty;
      
      // Check if wallet has signed (any wallet key has a signed PSBT)
      final walletHasSigned = hasWalletKeys && tx.keyPSBTs.any((kp) => 
        walletKeys.any((wk) => wk.xpub == kp.keyId) && kp.isSigned,
      );
      
      rows.add(TransactionRow(
        transaction: tx,
        hasWalletKeys: hasWalletKeys,
        walletHasSigned: walletHasSigned,
      ));
    }
    
    return rows;
  }

  Future<Map<String, dynamic>> _getWalletInfo(String walletName) async {
    try {
      final walletInfo = await _walletManager.getWalletBalanceAndUtxos(walletName);
      final balance = walletInfo['balance'] as double;
      final utxoCount = walletInfo['utxos'] as int;
      final utxoDetailsList = walletInfo['utxo_details'] as List<Map<String, dynamic>>;
      
      // Convert UTXO details to UtxoInfo objects
      final utxoDetails = utxoDetailsList.map((utxo) => UtxoInfo(
        txid: utxo['txid'] as String,
        vout: utxo['vout'] as int,
        address: utxo['address'] as String,
        amount: (utxo['amount'] as num).toDouble(),
        confirmations: utxo['confirmations'] as int,
        scriptPubKey: utxo['scriptPubKey'] as String?,
        spendable: utxo['spendable'] as bool? ?? true,
        solvable: utxo['solvable'] as bool? ?? true,
        safe: utxo['safe'] as bool? ?? true,
      ),).toList();
      
      return {
        'balance': balance,
        'utxos': utxoCount,
        'utxo_details': utxoDetails,
      };
    } catch (e) {
      return {
        'balance': 0.0,
        'utxos': 0,
        'utxo_details': <UtxoInfo>[],
      };
    }
  }

  @override
  void initState() {
    super.initState();
    _refreshData();
  }
  
  Future<void> _refreshData() async {
    await _loadMultisigGroups();
    await _loadAndUpdateTransactions();
    if (mounted) setState(() {});
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
        
        // Get wallet balance, UTXO count, and detailed UTXO info using wallet-specific RPC
        final walletInfo = await _getWalletInfo(walletName);
        final balance = walletInfo['balance'] as double;
        final utxoCount = walletInfo['utxos'] as int;
        final utxoDetails = walletInfo['utxo_details'] as List<UtxoInfo>;
        
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
            utxoDetails: utxoDetails,
            balance: balance,
            utxos: utxoCount,
            nextReceiveIndex: group.nextReceiveIndex,
            nextChangeIndex: group.nextChangeIndex,
          );
          hasUpdates = true;
          jsonGroup['watchWalletName'] = walletName;
        }

        try {
          // Get final wallet info to ensure we have the latest data
          final finalWalletInfo = await _getWalletInfo(walletName);
          final finalBalance = finalWalletInfo['balance'] as double;
          final finalUtxoCount = finalWalletInfo['utxos'] as int;
          final finalUtxoDetails = finalWalletInfo['utxo_details'] as List<UtxoInfo>;

          // Check if balance or UTXO count has changed
          if (group.balance != finalBalance || group.utxos != finalUtxoCount) {
            hasUpdates = true;
            
            // Update the JSON data
            jsonGroup['balance'] = finalBalance;
            jsonGroup['utxos'] = finalUtxoCount;
            jsonGroup['utxo_details'] = finalUtxoDetails.map((utxo) => utxo.toJson()).toList();
          }
          
          // Create updated group object with latest wallet data
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
            utxoDetails: finalUtxoDetails,
            balance: finalBalance,
            utxos: finalUtxoCount,
            nextReceiveIndex: group.nextReceiveIndex,
            nextChangeIndex: group.nextChangeIndex,
          );
          
        } catch (e) {
          
          // If wallet doesn't exist, try to create it
          if (e.toString().contains('Wallet file not specified') || 
              e.toString().contains('not found')) {
            try {
              await _createWatchOnlyWallet(group);
              
              // Try getting wallet info again after wallet creation
              // Note: At this point we'll update the group in the final section
              
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
                utxoDetails: utxoDetails,
                balance: balance,
                utxos: utxoCount,
                nextReceiveIndex: group.nextReceiveIndex,
                nextChangeIndex: group.nextChangeIndex,
              );
            } catch (createError) {
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
          // Silently continue if write fails
        }
      }
      
      // Load transactions and update confirmations for broadcasted transactions
      await _loadAndUpdateTransactions();
      
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

  Future<void> _loadAndUpdateTransactions() async {
    try {
      // Load all transactions
      _transactions = await TransactionStorage.loadTransactions();
      
      // Update confirmations for broadcasted transactions
      final broadcastedTransactions = _transactions
          .where((tx) => tx.status == TxStatus.broadcasted && tx.txid != null)
          .toList();
      
      for (final tx in broadcastedTransactions) {
        try {
          // Find the group for this transaction to get the wallet name
          final group = _multisigGroups.firstWhere(
            (g) => g.id == tx.groupId,
            orElse: () => throw Exception('Group not found'),
          );
          
          // Get transaction info from the watch-only wallet
          final txInfo = await _walletManager.callWalletRPC<Map<String, dynamic>>(
            group.watchWalletName ?? 'multisig_${group.id}',
            'gettransaction',
            [tx.txid!],
          );
          
          final confirmations = txInfo['confirmations'] as int? ?? 0;
          
          // Update status if confirmed
          if (confirmations >= 6 && tx.status != TxStatus.confirmed) {
            await TransactionStorage.updateTransactionStatus(
              tx.id,
              TxStatus.confirmed,
              confirmations: confirmations,
            );
          } else if (confirmations != tx.confirmations) {
            // Update confirmation count
            await TransactionStorage.updateTransactionStatus(
              tx.id,
              tx.status,
              confirmations: confirmations,
            );
          }
        } catch (e) {
          // Transaction might not be in wallet yet, continue
        }
      }
      
      // Reload transactions after updates
      _transactions = await TransactionStorage.loadTransactions();
      
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Failed to load transactions: $e');
      if (mounted) {
        setState(() {});
      }
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
          // Check if descriptors are imported
          bool needsImport = false;
          
          // Check if wallet exists and has correct configuration
          final walletExists = await _walletManager.isWalletLoaded(walletName);
          
          if (!walletExists) {
            await _walletManager.createWallet(
              walletName,
              disablePrivateKeys: false, // Enable private keys for signing
              blank: true,
            );
            needsImport = true;
          } else {
            // Check if existing wallet has private keys disabled
            try {
              final walletInfo = await _walletManager.getWalletInfo(walletName);
              final privateKeysDisabled = walletInfo['private_keys_enabled'] == false;
              
              if (privateKeysDisabled) {
                
                // Unload and remove the old wallet
                try {
                  await _rpc.callRAW('unloadwallet', [walletName]);
                } catch (e) {
                }
                
                // Create new wallet with private keys enabled
                await _walletManager.createWallet(
                  walletName,
                  disablePrivateKeys: false, // Enable private keys for signing
                  blank: true,
                );
                
                // Mark that we need to reimport descriptors
                needsImport = true;
              }
            } catch (e) {
            }
          }
          
          // Also check by trying to get balance - if it fails with specific errors, we need to import
          if (!needsImport) {
            try {
              await _walletManager.getWalletBalance(walletName);
            } catch (e) {
              if (e.toString().contains('does not have descriptors') || 
                  e.toString().contains('no descriptors')) {
                needsImport = true;
              }
            }
          }
          
          // Also check by trying to list descriptors
          try {
            final descriptors = await _walletManager.callWalletRPC<Map<String, dynamic>>(
              walletName, 
              'listdescriptors', 
              [],
            );
            if (descriptors['descriptors'] == null || 
                (descriptors['descriptors'] as List).isEmpty) {
              needsImport = true;
            }
          } catch (e) {
            needsImport = true;
          }
          
          if (needsImport) {
            
            // Build descriptors if not available
            String? receiveDesc = group.descriptorReceive;
            String? changeDesc = group.descriptorChange;
            
            if (receiveDesc == null || changeDesc == null) {
              final descriptors = await _buildDescriptors(group);
              receiveDesc = descriptors['receive'];
              changeDesc = descriptors['change'];
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
            
          }
          
          // Get wallet balance and UTXO info using wallet-specific RPC
          final walletInfo = await _getWalletInfo(walletName);
          final balance = walletInfo['balance'] as double;
          final utxoCount = walletInfo['utxos'] as int;
          final utxoDetails = walletInfo['utxo_details'] as List<UtxoInfo>;
          
          // Update if changed
          if (group.balance != balance || group.utxos != utxoCount) {
            hasUpdates = true;
            jsonGroup['balance'] = balance;
            jsonGroup['utxos'] = utxoCount;
            jsonGroup['utxo_details'] = utxoDetails.map((utxo) => utxo.toJson()).toList();
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
            utxoDetails: utxoDetails,
            balance: balance,
            utxos: utxoCount,
            nextReceiveIndex: group.nextReceiveIndex,
            nextChangeIndex: group.nextChangeIndex,
          ),);
          
        } catch (e) {
          groups.add(group); // Keep original on error
        }
      }
      
      // Save updates
      if (hasUpdates) {
        try {
          await file.writeAsString(json.encode(jsonGroups));
        } catch (e) {
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
      
      // Ensure wallet exists and has correct configuration
      if (!await _walletManager.isWalletLoaded(walletName)) {
        print('Wallet $walletName not found, creating it first');
        await _walletManager.createWallet(
          walletName,
          disablePrivateKeys: false, // Enable private keys for signing
          blank: true,
        );
      } else {
        // Check if existing wallet has private keys disabled
        try {
          final walletInfo = await _walletManager.getWalletInfo(walletName);
          final privateKeysDisabled = walletInfo['private_keys_enabled'] == false;
          
          if (privateKeysDisabled) {
            print('Wallet $walletName has private keys disabled, recreating...');
            
            // Unload and remove the old wallet
            try {
              await _rpc.callRAW('unloadwallet', [walletName]);
            } catch (e) {
              print('Failed to unload wallet (continuing): $e');
            }
            
            // Create new wallet with private keys enabled
            await _walletManager.createWallet(
              walletName,
              disablePrivateKeys: false, // Enable private keys for signing
              blank: true,
            );
          }
        } catch (e) {
          print('Could not check wallet configuration: $e');
        }
      }
      
      // Get descriptors
      String? receiveDesc = group.descriptorReceive;
      String? changeDesc = group.descriptorChange;
      
      if (receiveDesc == null || changeDesc == null) {
          final descriptors = await _buildDescriptors(group);
        receiveDesc = descriptors['receive'];
        changeDesc = descriptors['change'];
      }
      
      
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
      
      
      // Create wallet with private keys enabled for signing
      await _walletManager.createWallet(
        walletName,
        disablePrivateKeys: false, // Enable private keys for signing
        blank: true,
      );
      
      // Build descriptors on-demand if not available
      String? receiveDesc = group.descriptorReceive;
      String? changeDesc = group.descriptorChange;
      
      if (receiveDesc == null || changeDesc == null) {
        final descriptors = await _buildDescriptors(group);
        receiveDesc = descriptors['receive'];
        changeDesc = descriptors['change'];
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
      
      
    } catch (e) {
    }
  }

  // Transaction management methods
  Future<void> _createTransaction(MultisigGroup? group) async {
    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => PSBTCoordinatorModal(
          group: group, // Can be null to trigger group selection
          availableGroups: _multisigGroups.where((g) => g.balance > 0).toList(),
        ),
      );
      
      
      // Reload data after modal closes
      if (result == true) {
        await _refreshData();
      }
    } catch (e) {
    }
  }

  Future<void> _openTransactionModal(MultisigTransaction transaction) async {
    final group = _multisigGroups.firstWhere(
      (g) => g.id == transaction.groupId,
      orElse: () => throw Exception('Group not found for transaction'),
    );
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => PSBTCoordinatorModal(
        group: group,
      ),
    );
    
    // Reload data after modal closes
    if (result == true) {
      await _refreshData();
    }
  }

  String _getTransactionActionLabel(MultisigTransaction tx) {
    final group = _multisigGroups.firstWhere(
      (g) => g.id == tx.groupId,
      orElse: () => MultisigGroup(
        id: tx.groupId,
        name: 'Unknown',
        n: 0,
        m: 0,
        keys: [],
        created: 0,
      ),
    );
    
    // Check if current wallet has signed
    final walletKeys = group.keys.where((k) => k.isWallet).toList();
    final hasWalletSigned = tx.keyPSBTs.any((kp) => 
      walletKeys.any((wk) => wk.xpub == kp.keyId) && kp.isSigned,
    );
    
    switch (tx.status) {
      case TxStatus.needsSignatures:
        return hasWalletSigned ? 'Signed' : 'Sign';
      case TxStatus.readyForBroadcast:
        return 'Ready';
      case TxStatus.broadcasted:
        return 'Broadcasted';
      case TxStatus.confirmed:
        return 'Confirmed';
      case TxStatus.completed:
        return 'Completed';
      case TxStatus.voided:
        return 'Voided';
    }
  }

  Future<void> _handleTransactionAction(MultisigTransaction tx) async {
    final group = _multisigGroups.firstWhere(
      (g) => g.id == tx.groupId,
      orElse: () => throw Exception('Group not found'),
    );
    
    switch (tx.status) {
      case TxStatus.needsSignatures:
        // Check if current wallet needs to sign
        final walletKeys = group.keys.where((k) => k.isWallet).toList();
        final hasWalletSigned = tx.keyPSBTs.any((kp) => 
          walletKeys.any((wk) => wk.xpub == kp.keyId) && kp.isSigned,
        );
        
        if (!hasWalletSigned) {
          await _signTransaction(tx, group);
        } else {
          // Show transaction details
          await _openTransactionModal(tx);
        }
        break;
      case TxStatus.readyForBroadcast:
      case TxStatus.broadcasted:
      case TxStatus.confirmed:
      case TxStatus.completed:
      case TxStatus.voided:
        await _openTransactionModal(tx);
        break;
    }
  }
  
  Future<void> _signTransaction(MultisigTransaction tx, MultisigGroup group) async {
    print('=== STARTING TRANSACTION SIGNING WITH TEMPORARY WALLET ===');
    print('Transaction ID: ${tx.id}');
    print('Group: ${group.name} (${group.m}-of-${group.n})');
    
    try {
      final walletManager = WalletRPCManager();
      final hdWalletProvider = GetIt.I.get<HDWalletProvider>();
      
      // Find the wallet key(s)
      final walletKeys = group.keys.where((k) => k.isWallet).toList();
      if (walletKeys.isEmpty) {
        throw Exception('No wallet keys found in group');
      }
      
      print('Found ${walletKeys.length} wallet keys to sign with');
      for (final key in walletKeys) {
        print('  Wallet key: ${key.xpub.substring(0, 12)}... (path: ${key.derivationPath})');
      }
      
      // Check if already signed
      final alreadySigned = walletKeys.any((walletKey) =>
        tx.keyPSBTs.any((kp) => kp.keyId == walletKey.xpub && kp.isSigned),
      );
      
      if (alreadySigned) {
        print('WARNING: Wallet has already signed this transaction!');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaction already signed by this wallet')),
          );
        }
        return;
      }
      
      // Create a temporary wallet for signing
      final tempWalletName = 'temp_sign_${DateTime.now().millisecondsSinceEpoch}';
      print('Creating temporary wallet: $tempWalletName');
      
      try {
        // Create temp wallet with private keys enabled
        await walletManager.createWallet(
          tempWalletName,
          disablePrivateKeys: false,
          blank: true,
        );
        print('✓ Temporary wallet created successfully');
        
        // Build descriptors with xprv for wallet keys, xpub for external keys
        print('Building descriptors with private keys for wallet keys...');
        
        final sortedKeys = List<MultisigKey>.from(group.keys);
        sortedKeys.sort((a, b) => a.xpub.compareTo(b.xpub));
        
        final List<String> receiveKeyDescs = [];
        final List<String> changeKeyDescs = [];
        
        for (final key in sortedKeys) {
          String keyDesc;
          if (key.isWallet) {
            print('  Processing wallet key: ${key.xpub.substring(0, 12)}...');
            print('    Derivation path: ${key.derivationPath}');
            print('    Origin path: ${key.originPath}');
            print('    Fingerprint: ${key.fingerprint}');
            
            // Derive xprv for this key using HD wallet provider
            try {
              if (hdWalletProvider.mnemonic == null) {
                throw Exception('HD wallet not initialized - no mnemonic available');
              }
              
              final keyInfo = await hdWalletProvider.deriveExtendedKeyInfo(
                hdWalletProvider.mnemonic!,
                key.derivationPath ?? "m/84'/1'/0'", // Default if not set
              );
              
              final xprv = keyInfo['xprv'];
              if (xprv == null) {
                throw Exception('Failed to derive xprv for key ${key.xpub.substring(0, 12)}...');
              }
              
              print('    ✓ Successfully derived xprv: ${xprv.substring(0, 12)}...');
              
              if (key.fingerprint != null && key.originPath != null) {
                keyDesc = '[${key.fingerprint}/${key.originPath}]$xprv';
              } else {
                keyDesc = xprv;
              }
            } catch (e) {
              print('    ✗ Failed to derive xprv: $e');
              throw Exception('Failed to derive private key for wallet key: $e');
            }
          } else {
            // External key - use xpub
            print('  Processing external key: ${key.xpub.substring(0, 12)}...');
            if (key.fingerprint != null && key.originPath != null) {
              keyDesc = '[${key.fingerprint}/${key.originPath}]${key.xpub}';
            } else {
              keyDesc = key.xpub;
            }
          }
          
          receiveKeyDescs.add(keyDesc);
          changeKeyDescs.add(keyDesc);
        }
        
        // Build descriptors
        String receiveDesc = 'wsh(sortedmulti(${group.m},${receiveKeyDescs.join(',')}/0/*))';
        String changeDesc = 'wsh(sortedmulti(${group.m},${changeKeyDescs.join(',')}/1/*))';
        
        print('Built receive descriptor (first 100 chars): ${receiveDesc.substring(0, 100)}...');
        print('Built change descriptor (first 100 chars): ${changeDesc.substring(0, 100)}...');
        
        // Add checksums
        print('Adding checksums to descriptors...');
        final receiveResult = await _rpc.callRAW('getdescriptorinfo', [receiveDesc]);
        if (receiveResult is Map && receiveResult['descriptor'] != null) {
          receiveDesc = receiveResult['descriptor'] as String;
          print('✓ Receive descriptor with checksum: ${receiveDesc.substring(0, 100)}...');
        } else {
          throw Exception('Failed to get descriptor info for receive descriptor');
        }
        
        final changeResult = await _rpc.callRAW('getdescriptorinfo', [changeDesc]);
        if (changeResult is Map && changeResult['descriptor'] != null) {
          changeDesc = changeResult['descriptor'] as String;
          print('✓ Change descriptor with checksum: ${changeDesc.substring(0, 100)}...');
        } else {
          throw Exception('Failed to get descriptor info for change descriptor');
        }
        
        // Import descriptors to temporary wallet
        print('Importing descriptors to temporary wallet...');
        final importResult = await walletManager.importDescriptors(tempWalletName, [
          {
            'desc': receiveDesc,
            'active': true,
            'internal': false,
            'timestamp': 'now',
            'range': [0, 999],
          },
          {
            'desc': changeDesc,
            'active': true,
            'internal': true,
            'timestamp': 'now',
            'range': [0, 999],
          },
        ]);
        print('✓ Descriptors imported successfully: $importResult');
        
        // Process PSBT with temporary wallet
        print('Processing PSBT with temporary wallet...');
        print('Initial PSBT (first 100 chars): ${tx.initialPSBT.substring(0, 100)}...');
        
        final processResult = await walletManager.callWalletRPC<Map<String, dynamic>>(
          tempWalletName,
          'walletprocesspsbt',
          [tx.initialPSBT],
        );
        
        print('walletprocesspsbt result keys: ${processResult.keys.toList()}');
        print('walletprocesspsbt complete: ${processResult['complete']}');
        
        final signedPSBT = processResult['psbt'] as String?;
        final isComplete = processResult['complete'] as bool? ?? false;
        
        if (signedPSBT == null) {
          throw Exception('Failed to sign PSBT - no PSBT returned from wallet');
        }
        
        print('✓ PSBT signed successfully');
        print('Signed PSBT complete: $isComplete');
        print('Signed PSBT (first 100 chars): ${signedPSBT.substring(0, 100)}...');
        
        // Verify the signed PSBT actually has signatures
        try {
          final signedAnalysis = await _rpc.callRAW('analyzepsbt', [signedPSBT]);
          if (signedAnalysis is Map) {
            final inputs = signedAnalysis['inputs'] as List<dynamic>? ?? [];
            print('Signed PSBT analysis - inputs count: ${inputs.length}');
            for (int i = 0; i < inputs.length; i++) {
              final input = inputs[i] as Map<String, dynamic>;
              print('  Input[$i]: is_final=${input['is_final']}, missing=${input['missing']}');
              if (input.containsKey('partial_signatures')) {
                final partialSigs = input['partial_signatures'] as Map<String, dynamic>?;
                print('    Partial signatures count: ${partialSigs?.keys.length ?? 0}');
              }
            }
          }
        } catch (e) {
          print('Failed to analyze signed PSBT: $e');
        }
        
        // Update transaction with signed PSBT for all wallet keys
        print('Updating key PSBTs in storage...');
        for (final key in walletKeys) {
          print('  Updating key: ${key.xpub.substring(0, 12)}...');
          await TransactionStorage.updateKeyPSBT(
            tx.id, 
            key.xpub, 
            signedPSBT,
            signatureThreshold: group.m,
          );
        }
        print('✓ All wallet keys updated with signed PSBT');
        
      } finally {
        // Clean up temporary wallet
        try {
          print('Cleaning up temporary wallet...');
          await _rpc.callRAW('unloadwallet', [tempWalletName]);
          print('✓ Temporary wallet unloaded successfully');
        } catch (e) {
          print('Warning: Failed to unload temporary wallet: $e');
        }
      }
      
      // Reload transactions to reflect the new signatures
      print('Reloading transactions...');
      await _loadAndUpdateTransactions();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction signed successfully with temporary wallet'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      print('=== TRANSACTION SIGNING COMPLETED SUCCESSFULLY ===');
      
    } catch (e) {
      print('ERROR in _signTransaction: $e');
      print('Stack trace: ${StackTrace.current}');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sign transaction: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }


  
  Future<void> _openCombineAndBroadcastModal() async {
    final eligibleTransactions = _transactions.where((tx) => 
      tx.status != TxStatus.completed && 
      tx.status != TxStatus.voided && 
      tx.signedPSBTs.isNotEmpty,
    ).toList();
    
    await showDialog(
      context: context,
      builder: (context) => CombineBroadcastModal(
        eligibleTransactions: eligibleTransactions,
        multisigGroups: _multisigGroups,
        onBroadcastSuccess: _refreshData,
      ),
    );
  }


  Future<void> _openImportPSBTModal() async {
    await showDialog(
      context: context,
      builder: (context) => ImportPSBTModal(
        availableGroups: _multisigGroups,
        onImportSuccess: _refreshData,
      ),
    );
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
                              onSelectedRow: (rowId) {
                                if (rowId != null && _multisigGroups.isNotEmpty) {
                                  final group = _multisigGroups.firstWhere(
                                    (g) => g.id == rowId,
                                    orElse: () => _multisigGroups.first,
                                  );
                                  setState(() {
                                    _selectedGroup = group;
                                  });
                                }
                              },
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
                                await _refreshData();
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
                                await _refreshData();
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
                                await _refreshData();
                              }
                            },
                            variant: ButtonVariant.secondary,
                          ),
                          SailButton(
                            label: 'Refresh',
                            onPressed: _refreshData,
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
                        getRowId: (index) => _transactionRows.isNotEmpty 
                            ? _transactionRows[index].transaction.id
                            : 'empty$index',
                        headerBuilder: (context) => [
                          const SailTableHeaderCell(name: 'Group'),
                          const SailTableHeaderCell(name: 'MuSIG ID'),
                          const SailTableHeaderCell(name: 'Amount (BTC)'),
                          const SailTableHeaderCell(name: 'Signatures'),
                          const SailTableHeaderCell(name: 'Status'),
                          const SailTableHeaderCell(name: 'TXID'),
                          const SailTableHeaderCell(name: 'Confirmations'),
                          const SailTableHeaderCell(name: 'Action'),
                        ],
                        rowBuilder: (context, row, selected) {
                          if (_transactionRows.isEmpty) {
                            return [
                              const SailTableCell(value: 'No transactions yet'),
                              const SailTableCell(value: ''),
                              const SailTableCell(value: ''),
                              const SailTableCell(value: ''),
                              const SailTableCell(value: ''),
                              const SailTableCell(value: ''),
                              const SailTableCell(value: ''),
                              const SailTableCell(value: ''),
                            ];
                          }
                          
                          final txRow = _transactionRows[row];
                          final tx = txRow.transaction;
                          final group = _multisigGroups.firstWhere(
                            (g) => g.id == tx.groupId,
                            orElse: () => MultisigGroup(
                              id: tx.groupId,
                              name: 'Unknown',
                              n: 0,
                              m: 0,
                              keys: [],
                              created: 0,
                            ),
                          );
                          
                          return [
                            SailTableCell(value: group.name),
                            SailTableCell(value: tx.shortId),
                            SailTableCell(value: tx.amount.toStringAsFixed(8)),
                            SailTableCell(value: '${tx.signatureCount}/${group.m}'),
                            SailTableCell(value: tx.status.displayName),
                            SailTableCell(value: tx.shortTxid ?? '-'),
                            SailTableCell(value: tx.confirmations > 0 ? tx.confirmations.toString() : '-'),
                            txRow.hasWalletKeys && !txRow.walletHasSigned && tx.status == TxStatus.needsSignatures
                                ? SailTableCell(
                                    value: '',
                                    child: SailButton(
                                      label: 'Sign',
                                      variant: ButtonVariant.primary,
                                      insideTable: true,
                                      onPressed: () async {
                                        print('Sign button pressed for transaction: ${tx.id}');
                                        await _signTransaction(tx, group);
                                      },
                                    ),
                                  )
                                : tx.status == TxStatus.readyForBroadcast
                                    ? SailTableCell(
                                        value: '',
                                        child: SailButton(
                                          label: 'Broadcast',
                                          variant: ButtonVariant.secondary,
                                          insideTable: true,
                                          onPressed: () async {
                                            print('Broadcast button pressed for transaction: ${tx.id}');
                                            await _openCombineAndBroadcastModal();
                                          },
                                        ),
                                      )
                                    : SailTableCell(
                                        value: '',
                                        child: SailButton(
                                          label: 'View',
                                          variant: ButtonVariant.secondary,
                                          insideTable: true,
                                          onPressed: () async {
                                            print('View button pressed for transaction: ${tx.id}');
                                            await _openTransactionModal(tx);
                                          },
                                        ),
                                      ),
                          ];
                        },
                        rowCount: _transactionRows.isEmpty ? 1 : _transactionRows.length,
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
                          onPressed: _multisigGroups.any((g) => g.balance > 0) 
                            ? () async {
                                print('Create Transaction button pressed');
                                await _createTransaction(null); // Pass null to trigger group selection
                              }
                            : null, // Disable if no funded groups
                          variant: ButtonVariant.primary,
                        ),
                        SailSpacing(SailStyleValues.padding08),
                        SailButton(
                          label: 'Combine and Broadcast',
                          onPressed: _transactions.any((tx) => 
                            tx.status != TxStatus.completed && 
                            tx.status != TxStatus.voided && 
                            tx.signedPSBTs.isNotEmpty,)
                            ? () async => await _openCombineAndBroadcastModal()
                            : null,
                          variant: ButtonVariant.secondary,
                        ),
                        SailSpacing(SailStyleValues.padding08),
                        SailButton(
                          label: 'Import PSBT',
                          onPressed: () async => await _openImportPSBTModal(),
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