import 'dart:async';
import 'dart:convert';
import 'package:dart_coin_rpc/dart_coin_rpc.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

class WalletRPCManager {
  static final WalletRPCManager _instance = WalletRPCManager._internal();
  factory WalletRPCManager() => _instance;
  WalletRPCManager._internal();

  MainchainRPC get _rpc => GetIt.I.get<MainchainRPC>();
  String? _currentlyLoadedWallet;
  final Map<String, Completer<void>> _loadingOperations = {};

  /// Execute wallet-specific operations, ensuring wallet exists
  Future<T> withWallet<T>(
    String walletName,
    Future<T> Function() operation,
  ) async {
    // Ensure wallet exists (create if missing)
    if (!await isWalletLoaded(walletName)) {
      try {
        await _rpc.callRAW('createwallet', [walletName, true, true]); // disable_privkeys, blank
        print('Created missing wallet: $walletName');
      } catch (e) {
        if (!e.toString().contains('already exists')) {
          print('Failed to create wallet $walletName: $e');
          rethrow;
        }
      }
    }

    // Execute the operation using wallet-specific endpoint
    return await operation();
  }

  /// Load a specific wallet
  Future<void> _loadWallet(String walletName) async {
    try {
      // Check if wallet is already loaded
      final loadedWallets = await _rpc.callRAW('listwallets', []);
      if (loadedWallets is List && loadedWallets.contains(walletName)) {
        print('Wallet $walletName is already loaded');
        return;
      }

      print('Loading wallet: $walletName');
      await _rpc.callRAW('loadwallet', [walletName]);
      print('Successfully loaded wallet: $walletName');
    } catch (e) {
      if (e.toString().contains('already loaded')) {
        print('Wallet $walletName is already loaded (caught error)');
        return;
      }
      print('Failed to load wallet $walletName: $e');
      rethrow;
    }
  }

  /// Unload a specific wallet
  Future<void> _unloadWallet(String walletName) async {
    try {
      print('Unloading wallet: $walletName');
      await _rpc.callRAW('unloadwallet', [walletName]);
      print('Successfully unloaded wallet: $walletName');
    } catch (e) {
      if (e.toString().contains('not found') || 
          e.toString().contains('not loaded')) {
        print('Wallet $walletName was not loaded (ignoring error)');
        return;
      }
      print('Failed to unload wallet $walletName: $e');
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
      
      print('Wallet RPC URL: ${response.requestOptions.uri}');
      
      final data = response.data;
      if (data['error'] != null) {
        final error = data['error'];
        throw Exception('RPC Error ${error['code']}: ${error['message']}');
      }
      return data['result'] as T;
    } catch (e) {
      print('Wallet RPC failed for $walletName.$method: $e');
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
            await _unloadWallet(walletName);
          }
        }
      }
      _currentlyLoadedWallet = null;
    } catch (e) {
      print('Failed to unload all wallets: $e');
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
          [address]
        );
        return result['ismine'] == true || result['iswatchonly'] == true;
      } catch (e) {
        print('Failed to check address ownership: $e');
        return false;
      }
    });
  }

  /// Get wallet balance and UTXO info combined
  Future<Map<String, dynamic>> getWalletBalanceAndUtxos(String walletName) async {
    return await withWallet<Map<String, dynamic>>(walletName, () async {
      try {
        final balance = await callWalletRPC<dynamic>(walletName, 'getbalance', [null, 0, true]);
        final utxos = await callWalletRPC<List<dynamic>>(walletName, 'listunspent', []);
        
        return {
          'balance': balance is num ? balance.toDouble() : 0.0,
          'utxos': utxos.length,
        };
      } catch (e) {
        print('Balance fetch failed for $walletName: $e');
        return {
          'balance': 0.0,
          'utxos': 0,
        };
      }
    });
  }
}