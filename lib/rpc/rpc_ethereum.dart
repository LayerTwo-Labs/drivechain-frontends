import 'package:http/http.dart';
import 'package:sidesail/config/sidechains.dart';
import 'package:sidesail/pages/tabs/settings/node_settings_tab.dart';
import 'package:sidesail/rpc/models/core_transaction.dart';
import 'package:sidesail/rpc/rpc_sidechain.dart';
import 'package:web3dart/json_rpc.dart' as jsonrpc;
import 'package:web3dart/web3dart.dart';

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
  // Sidechain specific RPC calls
  'eth_deposit',
  'eth_withdraw',
  'eth_getUnspentWithdrawals',
  'eth_refund',

  'web3_clientVersion',
  'web3_sha3',

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
  'personal_getListAccounts',
  'personal_listAccounts',
  'personal_openWallet',
  'personal_unlockAccount',
  'personal_getListWallets',
  'personal_listWallets',
  'personal_sendTransaction',
  'personal_unpair',
  'personal_deriveAccount',
  'personal_importRawKey',
  'personal_lockAccount',
  'personal_sign',
  'personal_ecRecover',
  'personal_initializeWallet',
  'personal_newAccount',
  'personal_signTransaction',

  'admin_startHTTP',
  'admin_addPeer',
  'admin_importChain',
  'admin_startRPC',
  'admin_addTrustedPeer',
  'admin_startWS',
  'admin_nodeInfo',
  'admin_stopHTTP',
  'admin_peers',
  'admin_stopRPC',
  'admin_datadir',
  'admin_stopWS',
  'admin_exportChain',
  'admin_removePeer',
  'admin_getDatadir',
  'admin_removeTrustedPeer',
  'admin_getNodeInfo',
  'admin_sleep',
  'admin_getPeers',
  'admin_sleepBlocks',
  'admin_clearHistory',

  'jeth_newAccount',
  'jeth_sign',
  'jeth_unlockAccount',
  'jeth_openWallet',

  'miner_setGasLimit',
  'miner_stop',
  'miner_getHashrate',
  'miner_setGasPrice',
  'miner_setEtherbase',
  'miner_setRecommitInterval',
  'miner_setExtra',
  'miner_start',

  'net_getListening',
  'net_getVersion',
  'net_peerCount',
  'net_getPeerCount',
  'net_listening',
  'net_version',

  'txpool_contentFrom',
  'txpool_getStatus',
  'txpool_getContent',
  'txpool_content',
  'txpool_getInspect',
  'txpool_inspect',
  'txpool_status',
];
