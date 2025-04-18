import 'package:http/http.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:web3dart/json_rpc.dart' as jsonrpc;
import 'package:web3dart/web3dart.dart';

abstract class EthereumRPC extends SidechainRPC {
  EthereumRPC({
    required super.conf,
    required super.binary,
    required super.logPath,
    required super.restartOnFailure,
  }) : super(chain: EthereumSidechain());

  EthereumAddress? account;
  Future<void> newAccount();
  Future<bool> deposit(double amount, double fee);
}

class EthereumRPCLive extends EthereumRPC {
  final sgweiPerSat = 1000000000;

  EthereumRPCLive({
    required super.conf,
    required super.binary,
    required super.logPath,
    required super.restartOnFailure,
  }) {
    try {
      _setAndGetAccount();
    } catch (error) {
      // we could not get the account, probably because it doesn't exist
      // try to make one!
      newAccount();
    }
  }

  Web3Client get _client => Web3Client(
        'http://${conf.host}:${conf.port}',
        Client(),
      );

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

  @override
  Future<(double, double)> balance() async {
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
    notifyListeners();
  }

  @override
  Future<bool> deposit(double amount, double fee) async {
    final depositAmount = sgweiPerSat * btcToSatoshi(amount);
    final depositFee = sgweiPerSat * btcToSatoshi(fee);
    final deposit = await callRAW('eth_deposit', [account!.hex, _toHex(depositAmount), _toHex(depositFee)]);
    return deposit as bool;
  }

  String _toHex(int number) {
    return '0x${number.toRadixString(16)}';
  }

  int _fromHex(String hexString) {
    return int.parse(hexString.replaceFirst('0x', ''), radix: 16);
  }

  @override
  Future<List<CoreTransaction>> listTransactions() async {
    return List.empty();
  }

  @override
  Future<List<String>> binaryArgs(
    NodeConnectionSettings mainchainConf,
  ) async {
    return [
      '--http',
      '--http.api=eth,web3,personal,admin,miner,net,txpool',
      '--http.addr=0.0.0.0',
      '--http.port=${conf.port}',
      '--main.host=${mainchainConf.host}',
      '--main.password=${mainchainConf.password}',
      '--main.user=${mainchainConf.username}',
      '--main.port=${mainchainConf.port}',
    ];
  }

  @override
  Future<String> getDepositAddress() async {
    if (account == null) {
      return '';
    }
    return formatDepositAddress(account!.hex, chain.slot);
  }

  @override
  Future<String> mainSend(String address, double amount, double sidechainFee, double mainchainFee) async {
    final withdrawAmount = sgweiPerSat * btcToSatoshi(amount);
    final fee = sgweiPerSat * btcToSatoshi(sidechainFee + mainchainFee);
    final withdraw = await callRAW(
      'eth_withdraw',
      [
        account!.hex,
        _toHex(withdrawAmount.toInt()),
        _toHex(fee),
      ],
    ) as String;

    return withdraw;
  }

  @override
  Future<double> sideEstimateFee() async {
    return 0.00001;
  }

  @override
  Future<int> ping() async {
    final blockCount = await callRAW('eth_blockNumber');
    return _fromHex(blockCount);
  }

  @override
  List<String> startupErrors() {
    return [];
  }

  @override
  Future<String> sideSend(String address, double amount, bool subtractFeeFromAmount) {
    throw UnimplementedError();
  }

  @override
  Future<void> stopRPC() async {
    return;
  }

  @override
  Future<String> getSideAddress() {
    throw UnimplementedError();
  }

  @override
  Future<BlockchainInfo> getBlockchainInfo() async {
    return BlockchainInfo(
      chain: chain.name,
      initialBlockDownload: false,
      blocks: 68,
      headers: 68,
      bestBlockHash: '',
      difficulty: 0,
      time: 0,
      medianTime: 0,
      verificationProgress: 0,
      chainWork: '',
      sizeOnDisk: 0,
      pruned: false,
      warnings: [],
    );
  }

  @override
  Future<void> initBinary({
    List<String>? arg,
    bool testConnectedWithBackoff = false,
  }) async {
    await super.initBinary(arg: arg);
  }

  @override
  List<String> getMethods() {
    return ethRPCMethods;
  }
}

/// List of all known RPC methods available /
final ethRPCMethods = [
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
