import 'dart:async';

import 'package:connectrpc/connect.dart';
import 'package:connectrpc/http2.dart';
import 'package:connectrpc/protobuf.dart';
import 'package:connectrpc/protocol/connect.dart' as connect;
import 'package:fixnum/fixnum.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:sail_ui/bitcoin.dart';
import 'package:sail_ui/classes/node_connection_settings.dart';
import 'package:sail_ui/classes/rpc_connection.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/gen/bitcoind/v1/bitcoind.connect.client.dart';
import 'package:sail_ui/gen/bitcoind/v1/bitcoind.pb.dart';
import 'package:sail_ui/gen/bitwindowd/v1/bitwindowd.connect.client.dart';
import 'package:sail_ui/gen/bitwindowd/v1/bitwindowd.pb.dart';
import 'package:sail_ui/gen/drivechain/v1/drivechain.connect.client.dart';
import 'package:sail_ui/gen/drivechain/v1/drivechain.pb.dart';
import 'package:sail_ui/gen/google/protobuf/empty.pb.dart';
import 'package:sail_ui/gen/health/v1/health.connect.client.dart';
import 'package:sail_ui/gen/health/v1/health.pb.dart';
import 'package:sail_ui/gen/misc/v1/misc.connect.client.dart';
import 'package:sail_ui/gen/misc/v1/misc.pb.dart';
import 'package:sail_ui/gen/wallet/v1/wallet.connect.client.dart';
import 'package:sail_ui/gen/wallet/v1/wallet.pb.dart';

/// API to the drivechain server.
abstract class BitwindowRPC extends RPCConnection {
  BitwindowRPC({
    required super.conf,
    required super.binary,
    required super.logPath,
    required super.restartOnFailure,
  });

  BitwindowAPI get bitwindowd;
  WalletAPI get wallet;
  BitcoindAPI get bitcoind;
  DrivechainAPI get drivechain;
  MiscAPI get misc;
  HealthAPI get health;

  Future<dynamic> callRAW(String url, [String body = '{}']);
  List<String> getMethods();
}

class BitwindowRPCLive extends BitwindowRPC {
  @override
  late final BitwindowAPI bitwindowd;
  @override
  late final WalletAPI wallet;
  @override
  late final BitcoindAPI bitcoind;
  @override
  late final DrivechainAPI drivechain;
  @override
  late final MiscAPI misc;
  @override
  late final HealthAPI health;

  // Private constructor
  BitwindowRPCLive._create({
    required super.conf,
    required super.binary,
    required super.logPath,
    required super.restartOnFailure,
  });

  // Async factory
  static Future<BitwindowRPCLive> create({
    required String host,
    required int port,
    required Binary binary,
  }) async {
    final httpClient = createHttpClient();
    final baseUrl = 'http://$host:$port';
    final transport = connect.Transport(
      baseUrl: baseUrl,
      codec: const ProtoCodec(),
      httpClient: httpClient,
    );

    final conf = await readConf();
    final logPath = binary.logPath();

    final liveInstance = BitwindowRPCLive._create(
      conf: conf,
      binary: binary,
      logPath: logPath,
      restartOnFailure: true,
    );

    await liveInstance._init(transport);
    return liveInstance;
  }

  Future<void> _init(Transport transport) async {
    bitwindowd = _BitwindowAPILive(BitwindowdServiceClient(transport));
    wallet = _WalletAPILive(WalletServiceClient(transport));
    bitcoind = _BitcoindAPILive(BitcoindServiceClient(transport));
    drivechain = _DrivechainAPILive(DrivechainServiceClient(transport));
    misc = _MiscAPILive(MiscServiceClient(transport));
    health = _HealthAPILive(HealthServiceClient(transport));

    // must test connection before moving on, in case it is already running!
    await startConnectionTimer();
    startHealthStream();
  }

  @override
  Future<List<String>> binaryArgs(NodeConnectionSettings mainchainConf) async {
    return [
      '--bitcoincore.rpcuser=${mainchainConf.username}',
      '--bitcoincore.rpcpassword=${mainchainConf.password}',
      '--log.path=$logPath',
      if (binary.extraBootArgs.isNotEmpty) ...binary.extraBootArgs,
    ];
  }

  @override
  Future<int> ping() async {
    final syncInfo = await bitwindowd.getSyncInfo();
    return syncInfo.tipBlockHeight.toInt();
  }

  @override
  List<String> startupErrors() {
    return [];
  }

  @override
  Future<(double, double)> balance() async {
    final balanceSat = await wallet.getBalance();
    return (satoshiToBTC(balanceSat.confirmedSatoshi.toInt()), satoshiToBTC(balanceSat.pendingSatoshi.toInt()));
  }

  @override
  Future<void> stopRPC() async {
    await bitwindowd.stop();
  }

  @override
  Future<BlockchainInfo> getBlockchainInfo() async {
    final syncInfo = await bitwindowd.getSyncInfo();
    // TODO: create an info type that makes sense. a lot of unused fields here
    return BlockchainInfo(
      chain: 'signet',
      bestBlockHash: syncInfo.tipBlockHash,
      difficulty: 0,
      time: syncInfo.tipBlockTime.toInt(),
      medianTime: 0,
      initialBlockDownload: false,
      chainWork: '0',
      blocks: syncInfo.tipBlockHeight.toInt(),
      headers: syncInfo.headerHeight.toInt(),
      verificationProgress: syncInfo.syncProgress,
      sizeOnDisk: 0,
      pruned: false,
      warnings: [],
    );
  }

  @override
  Future<dynamic> callRAW(String url, [String body = '{}']) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/$url'),
        headers: {
          'content-type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode != 200) {
        throw Exception('Request failed: ${response.body}');
      }

      return response.body;
    } catch (e) {
      rethrow;
    }
  }

  @override
  List<String> getMethods() {
    return [
      'bitcoind.v1.BitcoindService/EstimateSmartFee',
      'bitcoind.v1.BitcoindService/GetBlock',
      'bitcoind.v1.BitcoindService/GetBlockchainInfo',
      'bitcoind.v1.BitcoindService/GetRawTransaction',
      'bitcoind.v1.BitcoindService/ListBlocks',
      'bitcoind.v1.BitcoindService/ListPeers',
      'bitcoind.v1.BitcoindService/ListRecentTransactions',
      'bitwindowd.v1.BitwindowdService/GetSyncInfo',
      'bitwindowd.v1.BitwindowdService/CancelDenial',
      'bitwindowd.v1.BitwindowdService/CreateAddressBookEntry',
      'bitwindowd.v1.BitwindowdService/CreateDenial',
      'bitwindowd.v1.BitwindowdService/DeleteAddressBookEntry',
      'bitwindowd.v1.BitwindowdService/ListAddressBook',
      'bitwindowd.v1.BitwindowdService/ListDenials',
      'bitwindowd.v1.BitwindowdService/Stop',
      'bitwindowd.v1.BitwindowdService/UpdateAddressBookEntry',
      'drivechain.v1.DrivechainService/ListSidechainProposals',
      'drivechain.v1.DrivechainService/ListSidechains',
      'misc.v1.MiscService/BroadcastNews',
      'misc.v1.MiscService/CreateTopic',
      'misc.v1.MiscService/ListCoinNews',
      'misc.v1.MiscService/ListOPReturn',
      'misc.v1.MiscService/ListTopics',
      'wallet.v1.WalletService/CreateSidechainDeposit',
      'wallet.v1.WalletService/GetBalance',
      'wallet.v1.WalletService/GetNewAddress',
      'wallet.v1.WalletService/ListSidechainDeposits',
      'wallet.v1.WalletService/ListTransactions',
      'wallet.v1.WalletService/SendTransaction',
      'wallet.v1.WalletService/SignMessage',
      'wallet.v1.WalletService/VerifyMessage',
    ];
  }

  // Store the previous response for comparison
  CheckResponse? _previousHealthResponse;

  // Keep track of the current stream subscription
  StreamSubscription<CheckResponse>? _healthStreamSubscription;

  @override
  void onConnectionStateChanged(bool isConnected) {
    if (isConnected) {
      log.i('Connection state changed to true, starting health stream');
      startHealthStream();
    } else {
      log.i('Connection state changed to false, stopping health stream');
      _healthStreamSubscription?.cancel();
      _previousHealthResponse = null;
    }
  }

  void startHealthStream() {
    // Cancel any existing subscription first
    _healthStreamSubscription?.cancel();

    _healthStreamSubscription = health.watch().listen(
      (response) {
        // Only notify if the health status has changed
        if (_previousHealthResponse == null) {
          _previousHealthResponse = response;
          notifyListeners();
        } else if (!_areHealthResponsesEqual(_previousHealthResponse!, response)) {
          _previousHealthResponse = response;
          notifyListeners();
        }
      },
      onError: (error) {
        log.e('Health stream error: $error');
        if (error is Exception) {
          log.e('Error details: ${error.toString()}');
        }
        // Reset previous response on error since state is uncertain
        _previousHealthResponse = null;
        notifyListeners();

        // If we're still connected, try to restart the stream after a delay
        if (connected) {
          log.i('Health stream dropped, but still connected, restarting health stream in 5 seconds...');
          Future.delayed(const Duration(seconds: 5), () {
            startHealthStream();
          });
        }
      },
      cancelOnError: false,
    )..onDone(() {
        log.i('Health stream completed');
        // If we're still connected, restart the stream
        if (connected) {
          log.i('Stream completed but still connected, restarting health stream in 5 seconds...');
          Future.delayed(const Duration(seconds: 5), () {
            startHealthStream();
          });
        }
      });
  }

  @override
  void dispose() {
    _healthStreamSubscription?.cancel();
    super.dispose();
  }

  bool _areHealthResponsesEqual(
    CheckResponse previous,
    CheckResponse current,
  ) {
    if (previous.serviceStatuses.length != current.serviceStatuses.length) {
      return false;
    }

    final prevMap = {
      for (var status in previous.serviceStatuses) status.serviceName: status.status,
    };

    for (var status in current.serviceStatuses) {
      final prevStatus = prevMap[status.serviceName];
      if (prevStatus != status.status) {
        log.i(
          '${status.serviceName} health status changed from ${prevStatus?.name.split('STATUS_').last} to ${status.status.name.split('STATUS_').last}',
        );
        return false;
      }
    }

    return true;
  }
}

abstract class BitwindowAPI {
  Future<void> stop();

  // Denial methods here
  Future<void> createDenial({
    required String txid,
    required int vout,
    required int numHops,
    required int delaySeconds,
  });
  Future<void> cancelDenial(Int64 id);
  Future<GetSyncInfoResponse> getSyncInfo();
  Future<List<DeniabilityUTXO>> listDenials();

  // Address book methods here
  Future<List<AddressBookEntry>> listAddressBook();
  Future<void> createAddressBookEntry(String label, String address, Direction direction);
  Future<void> updateAddressBookEntry(Int64 id, String label);
  Future<void> deleteAddressBookEntry(Int64 id);

  // Transaction note methods here
  Future<void> setTransactionNote(String txid, String note);
}

class _BitwindowAPILive implements BitwindowAPI {
  final BitwindowdServiceClient _client;
  Logger get log => GetIt.I.get<Logger>();

  _BitwindowAPILive(this._client);

  @override
  Future<void> stop() async {
    await _client.stop(Empty());
  }

  @override
  Future<void> createDenial({
    required String txid,
    required int vout,
    required int numHops,
    required int delaySeconds,
  }) async {
    await _client.createDenial(
      CreateDenialRequest(
        txid: txid,
        vout: vout,
        numHops: numHops,
        delaySeconds: delaySeconds,
      ),
    );
  }

  @override
  Future<void> cancelDenial(Int64 id) async {
    await _client.cancelDenial(CancelDenialRequest()..id = id);
  }

  @override
  Future<GetSyncInfoResponse> getSyncInfo() async {
    final response = await _client.getSyncInfo(Empty());
    return response;
  }

  @override
  Future<List<DeniabilityUTXO>> listDenials() async {
    final response = await _client.listDenials(Empty());
    return response.utxos;
  }

  @override
  Future<List<AddressBookEntry>> listAddressBook() async {
    final response = await _client.listAddressBook(Empty());
    return response.entries;
  }

  @override
  Future<void> createAddressBookEntry(String label, String address, Direction direction) async {
    await _client.createAddressBookEntry(
      CreateAddressBookEntryRequest()
        ..label = label
        ..address = address
        ..direction = direction,
    );
  }

  @override
  Future<void> updateAddressBookEntry(Int64 id, String label) async {
    await _client.updateAddressBookEntry(
      UpdateAddressBookEntryRequest()
        ..id = id
        ..label = label,
    );
  }

  @override
  Future<void> deleteAddressBookEntry(Int64 id) async {
    await _client.deleteAddressBookEntry(
      DeleteAddressBookEntryRequest()..id = id,
    );
  }

  @override
  Future<void> setTransactionNote(String txid, String note) async {
    await _client.setTransactionNote(
      SetTransactionNoteRequest()
        ..txid = txid
        ..note = note,
    );
  }
}

abstract class WalletAPI {
  // pure bitcoind wallet stuff here
  Future<String> sendTransaction(
    Map<String, int> destinations, {
    double? btcPerKvB,
    String? opReturnMessage,
    String? label,
    List<UnspentOutput> requiredInputs,
  });
  Future<GetBalanceResponse> getBalance();
  Future<String> getNewAddress();
  Future<List<WalletTransaction>> listTransactions();
  Future<List<UnspentOutput>> listUnspent();
  Future<List<ReceiveAddress>> listReceiveAddresses();

  // drivechain wallet stuff here
  Future<List<ListSidechainDepositsResponse_SidechainDeposit>> listSidechainDeposits(int slot);
  Future<String> createSidechainDeposit(int slot, String destination, double amount, double fee);
  Future<String> signMessage(String message);
  Future<bool> verifyMessage(String message, String signature, String publicKey);
  Future<GetStatsResponse> getStats();
}

class _WalletAPILive implements WalletAPI {
  final WalletServiceClient _client;
  Logger get log => GetIt.I.get<Logger>();

  _WalletAPILive(this._client);

  @override
  Future<String> sendTransaction(
    Map<String, int> destinations, {
    double? btcPerKvB,
    String? opReturnMessage,
    String? label,
    List<UnspentOutput>? requiredInputs,
  }) async {
    try {
      final request = SendTransactionRequest(
        destinations: destinations.map((k, v) => MapEntry(k, Int64(v))),
        feeRate: btcPerKvB,
        opReturnMessage: opReturnMessage,
        label: label,
        requiredInputs: requiredInputs,
      );

      final response = await _client.sendTransaction(request);
      return response.txid;
    } catch (e) {
      final error = 'could not send transaction: ${extractConnectException(e)}';
      log.e(error);
      throw WalletException(error);
    }
  }

  @override
  Future<GetBalanceResponse> getBalance() async {
    try {
      return await _client.getBalance(Empty());
    } catch (e) {
      final error = 'could not get balance: ${extractConnectException(e)}';
      throw WalletException(error);
    }
  }

  @override
  Future<String> getNewAddress() async {
    try {
      final response = await _client.getNewAddress(Empty());
      return response.address;
    } catch (e) {
      final error = 'could not get new address: ${extractConnectException(e)}';
      throw WalletException(error);
    }
  }

  @override
  Future<List<WalletTransaction>> listTransactions() async {
    try {
      final response = await _client.listTransactions(Empty());
      return response.transactions;
    } catch (e) {
      final error = 'could not list transactions: ${extractConnectException(e)}';
      throw WalletException(error);
    }
  }

  @override
  Future<List<UnspentOutput>> listUnspent() async {
    try {
      final response = await _client.listUnspent(Empty());
      return response.utxos;
    } catch (e) {
      final error = 'could not list utxos: ${extractConnectException(e)}';
      throw WalletException(error);
    }
  }

  @override
  Future<List<ReceiveAddress>> listReceiveAddresses() async {
    try {
      final response = await _client.listReceiveAddresses(Empty());
      return response.addresses;
    } catch (e) {
      final error = 'could not list receive addresses: ${extractConnectException(e)}';
      throw WalletException(error);
    }
  }

  @override
  Future<List<ListSidechainDepositsResponse_SidechainDeposit>> listSidechainDeposits(int slot) async {
    try {
      final response = await _client.listSidechainDeposits(ListSidechainDepositsRequest()..slot = slot);
      return response.deposits;
    } catch (e) {
      final error = 'could not list sidechain deposits: ${extractConnectException(e)}';
      throw WalletException(error);
    }
  }

  @override
  Future<String> createSidechainDeposit(int slot, String destination, double amount, double fee) async {
    try {
      final response = await _client.createSidechainDeposit(
        CreateSidechainDepositRequest()
          ..slot = Int64(slot)
          ..destination = destination
          ..amount = amount
          ..fee = fee,
      );
      return response.txid;
    } catch (e) {
      final error = extractConnectException(e);
      throw WalletException(error);
    }
  }

  @override
  Future<String> signMessage(String message) async {
    try {
      final response = await _client.signMessage(SignMessageRequest()..message = message);
      return response.signature;
    } catch (e) {
      final error = extractConnectException(e);
      throw WalletException(error);
    }
  }

  @override
  Future<bool> verifyMessage(String message, String signature, String publicKey) async {
    try {
      final response = await _client.verifyMessage(
        VerifyMessageRequest()
          ..message = message
          ..signature = signature
          ..publicKey = publicKey,
      );
      return response.valid;
    } catch (e) {
      final error = extractConnectException(e);
      throw WalletException(error);
    }
  }

  @override
  Future<GetStatsResponse> getStats() async {
    try {
      final response = await _client.getStats(Empty());
      return response;
    } catch (e) {
      final error = extractConnectException(e);
      throw WalletException(error);
    }
  }
}

abstract class BitcoindAPI {
  Future<List<Peer>> listPeers();
  Future<List<RecentTransaction>> listRecentTransactions();
  Future<(List<Block>, bool)> listBlocks({int startHeight = 0, int pageSize = 50});
  Future<GetBlockchainInfoResponse> getBlockchainInfo();
  Future<EstimateSmartFeeResponse> estimateSmartFee(int confTarget);
  Future<GetRawTransactionResponse> getRawTransaction(String txid);
  Future<Block> getBlock({String? hash, int? height});

  Future<CreateWalletResponse> createWallet(
    String name,
    String passphrase,
    bool avoidReuse,
    bool disablePrivateKeys,
    bool blank,
  );
  Future<BackupWalletResponse> backupWallet(String destination, String wallet);
  Future<DumpWalletResponse> dumpWallet(String filename, String wallet);
  Future<ImportWalletResponse> importWallet(String filename, String wallet);
  Future<UnloadWalletResponse> unloadWallet(String walletName, String wallet);

  // Key/Address management
  Future<DumpPrivKeyResponse> dumpPrivKey(String address, String wallet);
  Future<ImportPrivKeyResponse> importPrivKey(String privateKey, String label, bool rescan, String wallet);
  Future<ImportAddressResponse> importAddress(String address, String label, bool rescan, String wallet);
  Future<ImportPubKeyResponse> importPubKey(String pubkey, bool rescan, String wallet);
  Future<KeyPoolRefillResponse> keyPoolRefill(int newSize, String wallet);

  // Account operations
  Future<GetAccountResponse> getAccount(String address, String wallet);

  Future<SetAccountResponse> setAccount(String address, String account, String wallet);
  Future<GetAddressesByAccountResponse> getAddressesByAccount(String account, String wallet);
  Future<ListAccountsResponse> listAccounts(int minConf, String wallet);

  // Multi-sig operations
  Future<AddMultisigAddressResponse> addMultisigAddress(
    int requiredSigs,
    List<String> keys,
    String label,
    String wallet,
  );
  Future<CreateMultisigResponse> createMultisig(int requiredSigs, List<String> keys);

  // PSBT handling
  Future<CreatePsbtResponse> createPsbt(CreatePsbtRequest request);
  Future<DecodePsbtResponse> decodePsbt(DecodePsbtRequest request);
  Future<AnalyzePsbtResponse> analyzePsbt(AnalyzePsbtRequest request);
  Future<CombinePsbtResponse> combinePsbt(CombinePsbtRequest request);
  Future<UtxoUpdatePsbtResponse> utxoUpdatePsbt(UtxoUpdatePsbtRequest request);
  Future<JoinPsbtsResponse> joinPsbts(JoinPsbtsRequest request);

  // Transaction misc
  Future<TestMempoolAcceptResponse> testMempoolAccept(TestMempoolAcceptRequest request);
}

class _BitcoindAPILive implements BitcoindAPI {
  final BitcoindServiceClient _client;
  Logger get log => GetIt.I.get<Logger>();

  _BitcoindAPILive(this._client);

  @override
  Future<List<RecentTransaction>> listRecentTransactions() async {
    try {
      final response = await _client.listRecentTransactions(ListRecentTransactionsRequest()..count = Int64(20));
      return response.transactions;
    } catch (e) {
      final error = 'could not list unconfirmed transactions: ${extractConnectException(e)}';
      throw BitcoindException(error);
    }
  }

  @override
  Future<(List<Block>, bool)> listBlocks({int startHeight = 0, int pageSize = 50}) async {
    try {
      final response = await _client.listBlocks(
        ListBlocksRequest()
          ..startHeight = startHeight
          ..pageSize = pageSize,
      );
      return (response.recentBlocks, response.hasMore);
    } catch (e) {
      final error = 'could not list blocks: ${extractConnectException(e)}';
      throw BitcoindException(error);
    }
  }

  @override
  Future<GetBlockchainInfoResponse> getBlockchainInfo() async {
    // This should not try catched because callers elsewhere expect
    // it to throw if the connection is not live.
    final response = await _client.getBlockchainInfo(Empty());
    return response;
  }

  @override
  Future<List<Peer>> listPeers() async {
    try {
      final response = await _client.listPeers(Empty());
      return response.peers;
    } catch (e) {
      final error = 'could not list peers: ${extractConnectException(e)}';
      throw BitcoindException(error);
    }
  }

  @override
  Future<EstimateSmartFeeResponse> estimateSmartFee(int confTarget) async {
    try {
      final response = await _client.estimateSmartFee(EstimateSmartFeeRequest()..confTarget = Int64(confTarget));
      return response;
    } catch (e) {
      final error = 'could not estimate smart fee: ${extractConnectException(e)}';
      throw BitcoindException(error);
    }
  }

  @override
  Future<GetRawTransactionResponse> getRawTransaction(String txid) async {
    try {
      final response = await _client.getRawTransaction(GetRawTransactionRequest()..txid = txid);
      return response;
    } catch (e) {
      final error = 'could not get transaction: ${extractConnectException(e)}';
      throw BitcoindException(error);
    }
  }

  @override
  Future<Block> getBlock({String? hash, int? height}) async {
    try {
      final request = GetBlockRequest();
      if (hash != null) {
        request.hash = hash;
      } else if (height != null) {
        request.height = height;
      } else {
        throw BitcoindException('Either hash or height must be provided');
      }

      final response = await _client.getBlock(request);

      return response.block;
    } catch (e) {
      final error = 'could not get block: ${extractConnectException(e)}';
      throw BitcoindException(error);
    }
  }

  // Key/Address management
  @override
  Future<DumpPrivKeyResponse> dumpPrivKey(String address, String wallet) async {
    try {
      final response = await _client.dumpPrivKey(
        DumpPrivKeyRequest()..address = address,
      );
      log.i('Successfully dumped private key for wallet $wallet address $address');
      return response;
    } catch (e) {
      final error = 'could not dump private key: ${extractConnectException(e)}';
      throw BitcoindException(error);
    }
  }

  @override
  Future<ImportPrivKeyResponse> importPrivKey(String privateKey, String label, bool rescan, String wallet) async {
    try {
      final response = await _client.importPrivKey(
        ImportPrivKeyRequest()
          ..privateKey = privateKey
          ..label = label
          ..rescan = rescan
          ..wallet = wallet,
      );
      log.i('Successfully imported private key with label $label');
      return response;
    } catch (e) {
      final error = 'could not import private key: ${extractConnectException(e)}';
      throw BitcoindException(error);
    }
  }

  @override
  Future<ImportAddressResponse> importAddress(String address, String label, bool rescan, String wallet) async {
    try {
      final response = await _client.importAddress(
        ImportAddressRequest()
          ..address = address
          ..label = label
          ..rescan = rescan
          ..wallet = wallet,
      );
      log.i('Successfully imported address $address with label $label');
      return response;
    } catch (e) {
      final error = 'could not import address: ${extractConnectException(e)}';
      throw BitcoindException(error);
    }
  }

  @override
  Future<ImportPubKeyResponse> importPubKey(String pubkey, bool rescan, String wallet) async {
    try {
      final response = await _client.importPubKey(
        ImportPubKeyRequest()
          ..pubkey = pubkey
          ..rescan = rescan
          ..wallet = wallet,
      );
      log.i('Successfully imported public key');
      return response;
    } catch (e) {
      final error = 'could not import public key: ${extractConnectException(e)}';
      throw BitcoindException(error);
    }
  }

  @override
  Future<KeyPoolRefillResponse> keyPoolRefill(int newSize, String wallet) async {
    try {
      final response = await _client.keyPoolRefill(
        KeyPoolRefillRequest()..newSize = newSize,
      );
      log.i('Successfully refilled key pool to size $newSize');
      return response;
    } catch (e) {
      final error = 'could not refill key pool: ${extractConnectException(e)}';
      throw BitcoindException(error);
    }
  }

  // Account operations
  @override
  Future<GetAccountResponse> getAccount(String address, String wallet) async {
    try {
      final response = await _client.getAccount(
        GetAccountRequest()..address = address,
      );
      log.i('Successfully got account for wallet $wallet address $address');
      return response;
    } catch (e) {
      final error = 'could not get account: ${extractConnectException(e)}';
      throw BitcoindException(error);
    }
  }

  @override
  Future<SetAccountResponse> setAccount(String address, String account, String wallet) async {
    try {
      final response = await _client.setAccount(
        SetAccountRequest()
          ..address = address
          ..account = account
          ..wallet = wallet,
      );
      log.i('Successfully set account $account for address $address');
      return response;
    } catch (e) {
      final error = 'could not set account: ${extractConnectException(e)}';
      throw BitcoindException(error);
    }
  }

  @override
  Future<GetAddressesByAccountResponse> getAddressesByAccount(String account, String wallet) async {
    try {
      final response = await _client.getAddressesByAccount(
        GetAddressesByAccountRequest()..account = account,
      );
      log.i('Successfully got addresses for account $account');
      return response;
    } catch (e) {
      final error = 'could not get addresses by account: ${extractConnectException(e)}';
      throw BitcoindException(error);
    }
  }

  @override
  Future<ListAccountsResponse> listAccounts(int minConf, String wallet) async {
    try {
      final response = await _client.listAccounts(
        ListAccountsRequest()..minConf = minConf,
      );
      log.i('Successfully listed accounts with minConf=$minConf');
      return response;
    } catch (e) {
      final error = 'could not list accounts: ${extractConnectException(e)}';
      throw BitcoindException(error);
    }
  }

  // Multi-sig operations
  @override
  Future<AddMultisigAddressResponse> addMultisigAddress(
    int requiredSigs,
    List<String> keys,
    String label,
    String wallet,
  ) async {
    try {
      final response = await _client.addMultisigAddress(
        AddMultisigAddressRequest()
          ..requiredSigs = requiredSigs
          ..keys.addAll(keys)
          ..label = label
          ..wallet = wallet,
      );
      log.i('Successfully added multisig address with required=$requiredSigs, keys=${keys.length}, account=$label');
      return response;
    } catch (e) {
      final error = 'could not add multisig address: ${extractConnectException(e)}';
      throw BitcoindException(error);
    }
  }

  @override
  Future<CreateMultisigResponse> createMultisig(int requiredSigs, List<String> keys) async {
    try {
      final response = await _client.createMultisig(
        CreateMultisigRequest()
          ..requiredSigs = requiredSigs
          ..keys.addAll(keys),
      );
      log.i('Successfully created multisig with required=$requiredSigs, keys=${keys.length}');
      return response;
    } catch (e) {
      final error = 'could not create multisig: ${extractConnectException(e)}';
      throw BitcoindException(error);
    }
  }

  @override
  Future<BackupWalletResponse> backupWallet(String destination, String wallet) async {
    try {
      final response = await _client.backupWallet(
        BackupWalletRequest()
          ..destination = destination
          ..wallet = wallet,
      );
      log.i('Successfully backed up wallet $wallet to $destination');
      return response;
    } catch (e) {
      final error = 'could not backup wallet: ${extractConnectException(e)}';
      throw BitcoindException(error);
    }
  }

  @override
  Future<CreateWalletResponse> createWallet(
    String name,
    String passphrase,
    bool avoidReuse,
    bool disablePrivateKeys,
    bool blank,
  ) async {
    try {
      final response = await _client.createWallet(
        CreateWalletRequest()
          ..name = name
          ..passphrase = passphrase
          ..avoidReuse = avoidReuse
          ..disablePrivateKeys = disablePrivateKeys
          ..blank = blank,
      );
      log.i('Successfully created wallet $name');
      return response;
    } catch (e) {
      final error = 'could not create wallet: ${extractConnectException(e)}';
      throw BitcoindException(error);
    }
  }

  @override
  Future<DumpWalletResponse> dumpWallet(String filename, String wallet) async {
    try {
      final response = await _client.dumpWallet(
        DumpWalletRequest()
          ..filename = filename
          ..wallet = wallet,
      );
      log.i('Successfully dumped wallet $wallet to $filename');
      return response;
    } catch (e) {
      final error = 'could not dump wallet: ${extractConnectException(e)}';
      throw BitcoindException(error);
    }
  }

  @override
  Future<ImportWalletResponse> importWallet(String filename, String wallet) async {
    try {
      final response = await _client.importWallet(
        ImportWalletRequest()
          ..filename = filename
          ..wallet = wallet,
      );
      log.i('Successfully imported wallet');
      return response;
    } catch (e) {
      final error = 'could not import wallet: ${extractConnectException(e)}';
      throw BitcoindException(error);
    }
  }

  @override
  Future<UnloadWalletResponse> unloadWallet(String walletName, String wallet) async {
    try {
      final response = await _client.unloadWallet(
        UnloadWalletRequest()
          ..walletName = walletName
          ..wallet = wallet,
      );
      log.i('Successfully unloaded wallet');
      return response;
    } catch (e) {
      final error = 'could not unload wallet: ${extractConnectException(e)}';
      throw BitcoindException(error);
    }
  }

  @override
  Future<CreatePsbtResponse> createPsbt(CreatePsbtRequest request) async {
    try {
      final response = await _client.createPsbt(request);
      log.i('Successfully created PSBT');
      return response;
    } catch (e) {
      final error = 'could not create PSBT: ${extractConnectException(e)}';
      throw BitcoindException(error);
    }
  }

  @override
  Future<DecodePsbtResponse> decodePsbt(DecodePsbtRequest request) async {
    try {
      final response = await _client.decodePsbt(request);
      log.i('Successfully decoded PSBT');
      return response;
    } catch (e) {
      final error = 'could not decode PSBT: ${extractConnectException(e)}';
      throw BitcoindException(error);
    }
  }

  @override
  Future<AnalyzePsbtResponse> analyzePsbt(AnalyzePsbtRequest request) async {
    try {
      final response = await _client.analyzePsbt(request);
      log.i('Successfully analyzed PSBT');
      return response;
    } catch (e) {
      final error = 'could not analyze PSBT: ${extractConnectException(e)}';
      throw BitcoindException(error);
    }
  }

  @override
  Future<CombinePsbtResponse> combinePsbt(CombinePsbtRequest request) async {
    try {
      final response = await _client.combinePsbt(request);
      log.i('Successfully combined PSBTs');
      return response;
    } catch (e) {
      final error = 'could not combine PSBTs: ${extractConnectException(e)}';
      throw BitcoindException(error);
    }
  }

  @override
  Future<UtxoUpdatePsbtResponse> utxoUpdatePsbt(UtxoUpdatePsbtRequest request) async {
    try {
      final response = await _client.utxoUpdatePsbt(request);
      log.i('Successfully updated PSBT UTXOs');
      return response;
    } catch (e) {
      final error = 'could not update PSBT UTXOs: ${extractConnectException(e)}';
      throw BitcoindException(error);
    }
  }

  @override
  Future<JoinPsbtsResponse> joinPsbts(JoinPsbtsRequest request) async {
    try {
      final response = await _client.joinPsbts(request);
      log.i('Successfully joined PSBTs');
      return response;
    } catch (e) {
      final error = 'could not join PSBTs: ${extractConnectException(e)}';
      throw BitcoindException(error);
    }
  }

  @override
  Future<TestMempoolAcceptResponse> testMempoolAccept(TestMempoolAcceptRequest request) async {
    try {
      log.d('Testing mempool acceptance');
      final response = await _client.testMempoolAccept(request);
      log.i('Successfully tested mempool acceptance');
      return response;
    } catch (e) {
      final error = 'could not test mempool acceptance: ${extractConnectException(e)}';
      throw BitcoindException(error);
    }
  }
}

abstract class DrivechainAPI {
  Future<List<ListSidechainsResponse_Sidechain>> listSidechains();
  Future<List<SidechainProposal>> listSidechainProposals();
}

class _DrivechainAPILive implements DrivechainAPI {
  final DrivechainServiceClient _client;
  Logger get log => GetIt.I.get<Logger>();

  _DrivechainAPILive(this._client);

  @override
  Future<List<ListSidechainsResponse_Sidechain>> listSidechains() async {
    try {
      final response = await _client.listSidechains(ListSidechainsRequest());
      return response.sidechains;
    } catch (e) {
      final error = 'could not list sidechains: ${extractConnectException(e)}';
      throw DrivechainException(error);
    }
  }

  @override
  Future<List<SidechainProposal>> listSidechainProposals() async {
    try {
      final response = await _client.listSidechainProposals(ListSidechainProposalsRequest());
      return response.proposals;
    } catch (e) {
      final error = 'could not list sidechain proposals: ${extractConnectException(e)}';
      throw DrivechainException(error);
    }
  }
}

abstract class MiscAPI {
  Future<List<OPReturn>> listOPReturns();
  Future<List<CoinNews>> listCoinNews();
  Future<List<Topic>> listTopics();
  Future<CreateTopicResponse> createTopic(String topic, String name);
  Future<BroadcastNewsResponse> broadcastNews(String topic, String headline, String content);
}

class _MiscAPILive implements MiscAPI {
  final MiscServiceClient _client;
  Logger get log => GetIt.I.get<Logger>();

  _MiscAPILive(this._client);

  @override
  Future<List<OPReturn>> listOPReturns() async {
    try {
      final response = await _client.listOPReturn(Empty());
      return response.opReturns;
    } catch (e) {
      final error = 'could not list op returns: ${extractConnectException(e)}';
      throw BitcoindException(error);
    }
  }

  @override
  Future<BroadcastNewsResponse> broadcastNews(String topic, String headline, String content) async {
    try {
      final response = await _client.broadcastNews(
        BroadcastNewsRequest()
          ..topic = topic
          ..headline = headline
          ..content = content,
      );
      return response;
    } catch (e) {
      final error = 'could not broadcast news: ${extractConnectException(e)}';
      throw BitcoindException(error);
    }
  }

  @override
  Future<CreateTopicResponse> createTopic(String topic, String name) async {
    try {
      final response = await _client.createTopic(
        CreateTopicRequest()
          ..topic = topic
          ..name = name,
      );
      return response;
    } catch (e) {
      final error = 'could not create topic: ${extractConnectException(e)}';
      throw BitcoindException(error);
    }
  }

  @override
  Future<List<CoinNews>> listCoinNews() async {
    try {
      final response = await _client.listCoinNews(ListCoinNewsRequest());
      return response.coinNews;
    } catch (e) {
      final error = 'could not list coin news: ${extractConnectException(e)}';
      throw BitcoindException(error);
    }
  }

  @override
  Future<List<Topic>> listTopics() async {
    try {
      final response = await _client.listTopics(Empty());
      return response.topics;
    } catch (e) {
      final error = 'could not list topics: ${extractConnectException(e)}';
      throw BitcoindException(error);
    }
  }
}

abstract class HealthAPI {
  Future<CheckResponse> check();
  Stream<CheckResponse> watch();
}

class _HealthAPILive implements HealthAPI {
  final HealthServiceClient _client;
  Logger get log => GetIt.I.get<Logger>();

  _HealthAPILive(this._client);

  @override
  Future<CheckResponse> check() async {
    try {
      final response = await _client.check(Empty());
      return response;
    } catch (e) {
      final error = 'could not check health: ${extractConnectException(e)}';
      throw BitcoindException(error);
    }
  }

  @override
  Stream<CheckResponse> watch() {
    try {
      final response = _client.watch(Empty());
      return response;
    } catch (e) {
      final error = 'could not watch health: ${extractConnectException(e)}';
      throw BitcoindException(error);
    }
  }
}

class WalletException implements Exception {
  final String message;
  WalletException(this.message);
  @override
  String toString() => 'WalletException: $message';
}

class BitcoindException implements Exception {
  final String message;
  BitcoindException(this.message);
  @override
  String toString() => 'BitcoindException: $message';
}

class DrivechainException implements Exception {
  final String message;
  DrivechainException(this.message);
  @override
  String toString() => 'DrivechainException: $message';
}

// Helper extension
extension StringExtension on String {
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}
