import 'package:http/http.dart';
import 'package:sidesail/pages/tabs/settings/node_settings_tab.dart';
import 'package:sidesail/rpc/rpc.dart';
import 'package:web3dart/web3dart.dart';

abstract class EthereumRPC extends RPCConnection {
  Future<dynamic> call(String rpc, [args]);
}

class EthereumRPCLive extends EthereumRPC {
  late Web3Client _client;

  @override
  Future<dynamic> call(String rpc, [args]) async {
    return _client.makeRPCCall(rpc, args);
  }

  // Apparently Ethereum doesn't have a conf file?
  @override
  Future<void> createClient() async {
    final url = 'http://${connectionSettings.host}:${connectionSettings.port}';
    _client = Web3Client(url, Client());
  }

  EthereumRPCLive._create();

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
}

/// List of all known RPC methods available /
final ethRpcMethods = [
  'web3_clientVersion',
  'web3_sha3',
  'net_version',
  'net_listening',
  'net_peerCount',
  'eth_protocolVersion',
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

  // Sidechain specific RPC calls
  'eth_deposit',
  'eth_withdraw',
  'eth_getUnspentWithdrawals',
  'eth_refund',
];
