import 'package:http/http.dart';
import 'package:sidesail/config/sidechains.dart';
import 'package:sidesail/pages/tabs/settings/node_settings_tab.dart';
import 'package:sidesail/rpc/models/core_transaction.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web3dart/json_rpc.dart' as jsonrpc;

abstract class EthereumRPC extends SidechainSubRPC {
  EthereumAddress? account;
  Future<void> newAccount();
}

class EthereumRPCLive extends EthereumRPC {
  final sgweiPerSat = 1000000000;

  late Web3Client _client;

  @override
  Future<dynamic> callRAW(String method, [params]) async {
    try {
      final res = await _client.makeRPCCall(method, params);
      return res;
    } on jsonrpc.RPCError catch (err) {
      const magicErrCode = -32601; // no clue what this is
      if (err.errorCode == magicErrCode && method.startsWith('personal')) {
        throw "The 'personal' API is not enabled on your Ethereum node. Add the \n`--http.api=personal` argument, and try again.";
      }
      rethrow;
    }
  }

  // Apparently Ethereum doesn't have a conf file?
  @override
  Future<void> createClient() async {
    final url = 'http://${connectionSettings.host}:${connectionSettings.port}';
    _client = Web3Client(url, Client());
  }

  EthereumRPCLive._create() {
    chain = EthereumSidechain();
    try {
      _setAndGetAccount();
    } catch (error) {
      //
    }
  }

  static Future<EthereumRPCLive> create() async {
    final rpc = EthereumRPCLive._create();
    await rpc._init();
    return rpc;
  }

  Future<void> _init() async {
    // TODO: implement authed RPCs
    // TODO: make this configurable
    connectionSettings = SingleNodeConnectionSettings('', 'localhost', 8545, '', '');

    await createClient();
    await testConnection();
  }

  @override
  Future<void> ping() async {
    await _client.getChainId();
    return;
  }

  @override
  Future<(double, double)> getBalance() async {
    final account = await _setAndGetAccount();
    final balance = await _client.getBalance(account);
    return (balance.getInEther.toDouble(), 0.0);
  }

  Future<EthereumAddress> _setAndGetAccount() async {
    if (account != null) {
      return account!;
    }

    final accountFut = await callRAW('eth_accounts');
    final accounts = await accountFut as List<dynamic>;

    if (accounts.isEmpty) {
      throw Exception('Create account from cli using personal.newAccount before getting balance');
    }

    account = EthereumAddress.fromHex(accounts[0] as String);
    return account!;
  }

  @override
  Future<void> newAccount() async {
    final accountFut = await callRAW('personal_newAccount', ['passphrase']);
    final accountStr = await accountFut as String;

    if (accountStr.isEmpty) {
      throw Exception('Could not create account. Try using CLI with personal.newAccount');
    }

    account = EthereumAddress.fromHex(accountStr);
  }

  // ignore: unused_element
  Future<bool> _deposit(int amountSat, int feeSat) async {
    final amount = sgweiPerSat * amountSat;
    final fee = sgweiPerSat * feeSat;
    final deposit = await callRAW('eth_deposit', [account!.hex, _toHex(amount), _toHex(fee)]);
    return deposit as bool;
  }

  String _toHex(int number) {
    return '0x${number.toRadixString(16)}';
  }

  @override
  Future<List<CoreTransaction>> listTransactions() async {
    // TODO: Implement listtransactions
    return List.empty();
  }
}

/// List of all known RPC methods available /
final ethRpcMethods = [
  'web3_clientVersion',
  'web3_sha3',
  'net_version',
  'net_listening',
  'net_peerCount',
  'eth_syncing',
  'eth_coinbase',
  'eth_chainId',
  'eth_mining',
  'eth_hashrate',
  'eth_gasPrice',
  'eth_accounts',
  'eth_blockNumber',
  'eth_getBalance',
  'eth_getStorageAt',
  'eth_getTransactionCount',
  'eth_getBlockTransactionCountByHash',
  'eth_getBlockTransactionCountByNumber',
  'eth_getUncleCountByBlockHash',
  'eth_getUncleCountByBlockNumber',
  'eth_getCode',
  'eth_sign',
  'eth_signTransaction',
  'eth_sendTransaction',
  'eth_sendRawTransaction',
  'eth_call',
  'eth_estimateGas',
  'eth_getBlockByHash',
  'eth_getBlockByNumber',
  'eth_getTransactionByHash',
  'eth_getTransactionByBlockHashAndIndex',
  'eth_getTransactionByBlockNumberAndIndex',
  'eth_getTransactionReceipt',
  'eth_getUncleByBlockHashAndIndex',
  'eth_getUncleByBlockNumberAndIndex',
  'eth_newFilter',
  'eth_newBlockFilter',
  'eth_newPendingTransactionFilter',
  'eth_uninstallFilter',
  'eth_getFilterChanges',
  'eth_getFilterLogs',
  'eth_getLogs',

  // Wallet (?) stuff
  'personal_newAccount',
  'personal_importRawKey',
  'personal_unlockAccount',
  'personal_ecRecover',
  'personal_sign',
  'personal_sendTransaction',
  'personal_lockAccount',
  'personal_listAccounts',
  'personal_openWallet',
  'personal_deriveAccount',
  'personal_signTransaction',
  'personal_unpair',
  'personal_initializeWallet',
  'personal_listWallets',

  // Sidechain specific RPC calls
  'eth_deposit',
  'eth_withdraw',
  'eth_getUnspentWithdrawals',
  'eth_refund',
];
