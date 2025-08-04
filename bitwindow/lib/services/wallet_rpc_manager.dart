import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/sail_ui.dart';

// Helper function to log wallet debugging information to file
Future<void> _logToFile(String message) async {
  try {
    final dir = Directory(path.dirname(path.current));
    final file = File(path.join(dir.path, 'bitwindow', 'multisig_output.txt'));
    
    // Ensure parent directory exists
    await file.parent.create(recursive: true);
    
    final timestamp = DateTime.now().toIso8601String();
    await file.writeAsString('[$timestamp] WALLET_RPC: $message\n', mode: FileMode.append);
  } catch (e) {
    print('Failed to write to multisig_output.txt: $e');
  }
}

class WalletRPCManager {
  static final WalletRPCManager _instance = WalletRPCManager._internal();
  factory WalletRPCManager() => _instance;
  WalletRPCManager._internal();

  MainchainRPC get _rpc => GetIt.I.get<MainchainRPC>();
  String? _currentlyLoadedWallet;
  final Map<String, Completer<void>> _loadingOperations = {};

  /// Execute wallet-specific operations on an existing wallet
  Future<T> withWallet<T>(
    String walletName,
    Future<T> Function() operation,
  ) async {
    // Load wallet if not already loaded
    if (!await isWalletLoaded(walletName)) {
      try {
        await loadWallet(walletName);
      } catch (e) {
        throw Exception('Wallet $walletName does not exist and could not be loaded: $e');
      }
    }

    // Execute the operation using wallet-specific endpoint
    return await operation();
  }

  /// Load a specific wallet
  Future<void> loadWallet(String walletName) async {
    try {
      // Check if wallet is already loaded
      final loadedWallets = await _rpc.callRAW('listwallets', []);
      if (loadedWallets is List && loadedWallets.contains(walletName)) {
        await _logToFile('Wallet $walletName is already loaded');
        return;
      }

      await _logToFile('Loading wallet: $walletName');
      await _rpc.callRAW('loadwallet', [walletName]);
      await _logToFile('Successfully loaded wallet: $walletName');
    } catch (e) {
      if (e.toString().contains('already loaded')) {
        await _logToFile('Wallet $walletName is already loaded (caught error)');
        return;
      }
      await _logToFile('Failed to load wallet $walletName: $e');
      rethrow;
    }
  }

  /// Unload a specific wallet
  Future<void> unloadWallet(String walletName) async {
    try {
      await _logToFile('Unloading wallet: $walletName');
      await _rpc.callRAW('unloadwallet', [walletName]);
      await _logToFile('Successfully unloaded wallet: $walletName');
    } catch (e) {
      if (e.toString().contains('not found') || 
          e.toString().contains('not loaded')) {
        await _logToFile('Wallet $walletName was not loaded (ignoring error)');
        return;
      }
      await _logToFile('Failed to unload wallet $walletName: $e');
      // Don't rethrow - we want to continue even if unloading fails
    }
  }

  /// Make a wallet-specific RPC call
  Future<T> callWalletRPC<T>(String walletName, String method, List<dynamic> params) async {
    final rpcLive = _rpc as MainchainRPCLive;
    final conf = rpcLive.conf;
    
    final dio = Dio();
    dio.options.baseUrl = 'http://${conf.host}:${conf.port}';
    dio.options.headers = {
      'Content-Type': 'application/json',
    };

    // Basic auth
    final auth = 'Basic ${base64Encode(utf8.encode('${conf.username}:${conf.password}'))}';
    dio.options.headers['Authorization'] = auth;

    // Build JSON-RPC payload
    final payload = {
      'jsonrpc': '2.0',
      'method': method,
      'params': params,
      'id': DateTime.now().millisecondsSinceEpoch,
    };

    try {
      final response = await dio.post(
        '/wallet/$walletName', 
        data: payload,
      );
      
      await _logToFile('Wallet RPC URL: ${response.requestOptions.uri}');
      
      final data = response.data;
      if (data['error'] != null) {
        final error = data['error'];
        throw Exception('RPC Error ${error['code']}: ${error['message']}');
      }
      return data['result'] as T;
    } catch (e) {
      await _logToFile('Wallet RPC failed for $walletName.$method: $e');
      rethrow;
    }
  }

  /// Get wallet balance
  Future<double> getWalletBalance(String walletName, {
    int minConf = 0,
    bool includeWatchOnly = true,
  }) async {
    return await withWallet<double>(walletName, () async {
      final result = await callWalletRPC<dynamic>(walletName, 'getbalance', [null, minConf, includeWatchOnly]);
      return result is num ? result.toDouble() : 0.0;
    });
  }

  /// Get wallet info
  Future<Map<String, dynamic>> getWalletInfo(String walletName) async {
    return await withWallet<Map<String, dynamic>>(walletName, () async {
      return await callWalletRPC<Map<String, dynamic>>(walletName, 'getwalletinfo', []);
    });
  }

  /// List unspent outputs
  Future<List<dynamic>> listUnspent(String walletName, {
    int minConf = 0,
    int maxConf = 9999999,
  }) async {
    return await withWallet<List<dynamic>>(walletName, () async {
      return await callWalletRPC<List<dynamic>>(walletName, 'listunspent', [minConf, maxConf]);
    });
  }

  /// Get new address
  Future<String> getNewAddress(String walletName, {String? label, String? addressType}) async {
    return await withWallet<String>(walletName, () async {
      final params = <dynamic>[];
      if (label != null) params.add(label);
      if (addressType != null) params.add(addressType);
      
      return await callWalletRPC<String>(walletName, 'getnewaddress', params);
    });
  }

  /// Import descriptors
  Future<List<dynamic>> importDescriptors(String walletName, List<Map<String, dynamic>> descriptors) async {
    return await withWallet<List<dynamic>>(walletName, () async {
      return await callWalletRPC<List<dynamic>>(walletName, 'importdescriptors', [descriptors]);
    });
  }

  /// Create wallet
  Future<Map<String, dynamic>> createWallet(
    String walletName, {
    bool disablePrivateKeys = false,
    bool blank = false,
    String? passphrase,
    bool avoidReuse = false,
    bool descriptors = true,
    bool loadOnStartup = false,
  }) async {
    final params = <dynamic>[
      walletName,
      disablePrivateKeys,
      blank,
      passphrase ?? '',
      avoidReuse,
      descriptors,
      loadOnStartup,
    ];

    return await _rpc.callRAW('createwallet', params) as Map<String, dynamic>;
  }

  /// Import wallet from file
  Future<void> importWallet(String walletName, String filename) async {
    await withWallet<void>(walletName, () async {
      await callWalletRPC<dynamic>(walletName, 'importwallet', [filename]);
    });
  }

  /// Unload all wallets (cleanup method)
  Future<void> unloadAllWallets() async {
    try {
      final loadedWallets = await _rpc.callRAW('listwallets', []);
      if (loadedWallets is List) {
        for (final walletName in loadedWallets) {
          if (walletName is String) {
            await unloadWallet(walletName);
          }
        }
      }
      _currentlyLoadedWallet = null;
    } catch (e) {
      await _logToFile('Failed to unload all wallets: $e');
    }
  }

  /// Get currently loaded wallet name
  String? get currentWallet => _currentlyLoadedWallet;

  /// Check if a wallet is loaded
  Future<bool> isWalletLoaded(String walletName) async {
    try {
      final loadedWallets = await _rpc.callRAW('listwallets', []);
      return loadedWallets is List && loadedWallets.contains(walletName);
    } catch (e) {
      return false;
    }
  }

  /// Check if an address belongs to a wallet
  Future<bool> isAddressMine(String walletName, String address) async {
    return await withWallet<bool>(walletName, () async {
      try {
        final result = await callWalletRPC<Map<String, dynamic>>(
          walletName,
          'getaddressinfo',
          [address],
        );
        return result['ismine'] == true || result['iswatchonly'] == true;
      } catch (e) {
        await _logToFile('Failed to check address ownership: $e');
        return false;
      }
    });
  }

  /// Rescan wallet from a specific block height or timestamp
  Future<void> rescanWallet(String walletName, {int? startHeight, int? startTime}) async {
    return await withWallet<void>(walletName, () async {
      await _logToFile('Starting rescan for wallet: $walletName');
      
      // Use rescanblockchain to rescan from a specific point
      if (startHeight != null) {
        await _logToFile('Rescanning from block height: $startHeight');
        await callWalletRPC<dynamic>(walletName, 'rescanblockchain', [startHeight]);
      } else if (startTime != null) {
        await _logToFile('Rescanning from timestamp: $startTime');
        await callWalletRPC<dynamic>(walletName, 'rescanblockchain', [startTime]);
      } else {
        // Rescan from the beginning (genesis block)
        await _logToFile('Rescanning entire blockchain');
        await callWalletRPC<dynamic>(walletName, 'rescanblockchain', []);
      }
      await _logToFile('Wallet $walletName rescanned successfully');
    });
  }

  /// Force rescan of recent blocks for a wallet (useful when UTXOs are missing)
  Future<void> rescanRecentBlocks(String walletName, {int hoursBack = 24}) async {
    return await withWallet<void>(walletName, () async {
      // Get current block height
      final blockchainInfo = await _rpc.callRAW('getblockchaininfo', []);
      
      if (blockchainInfo is! Map || blockchainInfo['blocks'] is! int) {
        throw Exception('getblockchaininfo returned invalid response: $blockchainInfo');
      }
      
      final currentHeight = blockchainInfo['blocks'] as int;
      
      // Calculate start height (approximately 6 blocks per hour)
      final blocksBack = hoursBack * 6;
      final startHeight = (currentHeight - blocksBack).clamp(0, currentHeight);
      
      await _logToFile('Rescanning wallet $walletName from height $startHeight to $currentHeight (last $hoursBack hours)');
      await callWalletRPC<dynamic>(walletName, 'rescanblockchain', [startHeight]);
      await _logToFile('Recent rescan completed for wallet $walletName');
    });
  }

  /// Get wallet balance, UTXO count, and detailed UTXO information
  Future<Map<String, dynamic>> getWalletBalanceAndUtxos(String walletName) async {
    return await withWallet<Map<String, dynamic>>(walletName, () async {
      await _logToFile('Fetching balance and UTXOs for wallet: $walletName');
      
      // First, check if wallet is properly loaded by getting wallet info
      final walletInfo = await callWalletRPC<Map<String, dynamic>>(walletName, 'getwalletinfo', []);
      await _logToFile('Wallet $walletName info: scanning=${walletInfo['scanning']}, txcount=${walletInfo['txcount']}');
      
      // Get detailed balance info
      final balances = await callWalletRPC<Map<String, dynamic>>(walletName, 'getbalances', []);
      await _logToFile('Wallet $walletName detailed balances: $balances');
      
      final balance = await callWalletRPC<dynamic>(walletName, 'getbalance', [null, 0, true]);
      final utxos = await callWalletRPC<List<dynamic>>(walletName, 'listunspent', [0, 9999999, null, true]);
      
      await _logToFile('Wallet $walletName balance: $balance, UTXOs: ${utxos.length}');
      
      // List all descriptors to verify they're imported
      try {
        final descriptors = await callWalletRPC<Map<String, dynamic>>(walletName, 'listdescriptors', []);
        await _logToFile('Wallet $walletName has ${descriptors['descriptors']?.length ?? 0} descriptors');
      } catch (e) {
        await _logToFile('Failed to list descriptors: $e');
      }
      
      // Fail fast if balance is not a number
      if (balance is! num) {
        throw Exception('getbalance returned invalid type: ${balance.runtimeType} for wallet $walletName');
      }
      
      return {
        'balance': balance.toDouble(),
        'utxos': utxos.length,
        'utxo_details': utxos.cast<Map<String, dynamic>>(),
      };
    });
  }
}