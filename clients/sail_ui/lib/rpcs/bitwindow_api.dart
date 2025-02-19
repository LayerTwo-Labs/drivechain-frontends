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
import 'package:sail_ui/gen/misc/v1/misc.connect.client.dart';
import 'package:sail_ui/gen/misc/v1/misc.pb.dart';
import 'package:sail_ui/gen/wallet/v1/wallet.connect.client.dart';
import 'package:sail_ui/gen/wallet/v1/wallet.pb.dart';
import 'dart:convert';
import 'dart:typed_data';

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

  Future<dynamic> callRAW(String url, [String body = '{}']);
  List<String> getMethods();
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
  Future<List<UnspentOutput>> listDenials();

  // BitDrive methods here
  Future<String> storeContent({
    required List<int> content,
    required bool encrypt,
    required double fee,
  });
  Future<List<int>> retrieveContent(String txid);
  Future<bool> hasOpReturn(String txid);

  // Address book methods here
  Future<List<AddressBookEntry>> listAddressBook();
  Future<void> createAddressBookEntry(String label, String address, Direction direction);
  Future<void> updateAddressBookEntry(Int64 id, String label);
  Future<void> deleteAddressBookEntry(Int64 id);
}

abstract class WalletAPI {
  // pure bitcoind wallet stuff here
  Future<String> sendTransaction(
    String destination,
    int amountSatoshi, {
    double? btcPerKvB,
    String? opReturnMessage,
    String? label,
  });
  Future<GetBalanceResponse> getBalance();
  Future<String> getNewAddress();
  Future<List<WalletTransaction>> listTransactions();

  // drivechain wallet stuff here
  Future<List<ListSidechainDepositsResponse_SidechainDeposit>> listSidechainDeposits(int slot);
  Future<String> createSidechainDeposit(int slot, String destination, double amount, double fee);
  Future<String> signMessage(String message);
  Future<bool> verifyMessage(String message, String signature, String publicKey);
}

abstract class BitcoindAPI {
  Future<List<Peer>> listPeers();
  Future<List<RecentTransaction>> listRecentTransactions();
  Future<(List<Block>, bool)> listBlocks({int startHeight = 0, int pageSize = 50});
  Future<GetBlockchainInfoResponse> getBlockchainInfo();
  Future<EstimateSmartFeeResponse> estimateSmartFee(int confTarget);
  Future<GetRawTransactionResponse> getRawTransaction(String txid);
  Future<Block> getBlock({String? hash, int? height});
}

abstract class DrivechainAPI {
  Future<List<ListSidechainsResponse_Sidechain>> listSidechains();
  Future<List<SidechainProposal>> listSidechainProposals();
}

abstract class MiscAPI {
  Future<List<OPReturn>> listOPReturns();
  Future<List<CoinNews>> listCoinNews();
  Future<List<Topic>> listTopics();
  Future<CreateTopicResponse> createTopic(String topic, String name);
  Future<BroadcastNewsResponse> broadcastNews(String topic, String headline, String content);
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

    final conf = await getMainchainConf();
    final logPath = binary.logPath();

    final instance = BitwindowRPCLive._create(
      conf: conf,
      binary: binary,
      logPath: logPath,
      restartOnFailure: true,
    );

    instance._init(transport);
    return instance;
  }

  void _init(Transport transport) {
    bitwindowd = _BitwindowAPILive(BitwindowdServiceClient(transport), this);
    wallet = _WalletAPILive(WalletServiceClient(transport));
    bitcoind = _BitcoindAPILive(BitcoindServiceClient(transport));
    drivechain = _DrivechainAPILive(DrivechainServiceClient(transport));
    misc = _MiscAPILive(MiscServiceClient(transport));

    startConnectionTimer();
  }

  @override
  Future<List<String>> binaryArgs(NodeConnectionSettings mainchainConf) async {
    return [
      '--bitcoincore.rpcuser=${mainchainConf.username}',
      '--bitcoincore.rpcpassword=${mainchainConf.password}',
      '--log.path=$logPath',
    ];
  }

  @override
  Future<int> ping() async {
    return await bitcoind.getBlockchainInfo().then((value) => value.blocks);
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
    throw Exception('getBlockchainInfo not implemented');
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
}

class _BitwindowAPILive implements BitwindowAPI {
  final BitwindowdServiceClient _client;
  final BitwindowRPC api;
  Logger get log => GetIt.I.get<Logger>();

  _BitwindowAPILive(this._client, this.api);

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
  Future<List<UnspentOutput>> listDenials() async {
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
  Future<String> storeContent({
    required List<int> content,
    required bool encrypt,
    required double fee,
  }) async {
    try {
      log.d('BitDrive: Storing content...');
      log.d('BitDrive: Content size: ${content.length} bytes');
      log.d('BitDrive: Encryption enabled: $encrypt');
      log.d('BitDrive: Fee rate: $fee BTC/kvB');

      // Create compact metadata
      // Format: <1 byte encryption flag><4 bytes unix timestamp><4 bytes file extension>
      final metadata = ByteData(9);
      
      // Store flags and timestamp first
      metadata.setUint8(0, encrypt ? 1 : 0);
      metadata.setUint32(1, DateTime.now().millisecondsSinceEpoch ~/ 1000);
      
      // Store file type last
      final fileType = _detectFileType(content);
      final typeBytes = utf8.encode(fileType.padRight(4, ' '));
      for (var i = 0; i < 4; i++) {
        metadata.setUint8(5 + i, typeBytes[i]);
      }

      // Convert metadata to base64
      final metadataBytes = metadata.buffer.asUint8List();
      final metadataStr = base64.encode(metadataBytes);

      // Encode content
      final contentStr = encrypt 
          ? base64.encode(content)
          : base64.encode(content); // Always base64 encode for consistency

      // Combine with a single delimiter
      final opReturnData = '$metadataStr|$contentStr';
      log.d('BitDrive: OP_RETURN data size: ${opReturnData.length} bytes');

      // Get a new address to send to
      final address = await api.wallet.getNewAddress();
      log.d('BitDrive: Generated new address: $address');

      // Send transaction with OP_RETURN
      final txid = await api.wallet.sendTransaction(
        address,
        10000, // 0.0001 BTC in satoshis
        btcPerKvB: fee,
        opReturnMessage: opReturnData,
      );
      log.d('BitDrive: Content stored in transaction: $txid');
      
      return txid;
    } catch (e) {
      final error = 'could not store content: ${extractConnectException(e)}';
      log.e('BitDrive: Error storing content:');
      log.e('BitDrive: $error');
      throw BitcoindException(error);
    }
  }

  String _detectFileType(List<int> content) {
    // Check file magic numbers
    if (content.length >= 2) {
      // JPEG
      if (content[0] == 0xFF && content[1] == 0xD8) {
        return 'jpg';
      }
      // PNG
      if (content.length >= 8 &&
          content[0] == 0x89 && content[1] == 0x50 &&
          content[2] == 0x4E && content[3] == 0x47) {
        return 'png';
      }
      // GIF
      if (content.length >= 6 &&
          content[0] == 0x47 && content[1] == 0x49 &&
          content[2] == 0x46) {
        return 'gif';
      }
      // PDF
      if (content.length >= 4 &&
          content[0] == 0x25 && content[1] == 0x50 &&
          content[2] == 0x44 && content[3] == 0x46) {
        return 'pdf';
      }
    }

    // Try to detect text files
    try {
      final str = utf8.decode(content.take(1024).toList());
      if (str.trim().isNotEmpty) {
        return 'txt';
      }
    } catch (_) {}

    // Default to binary
    return 'bin';
  }

  @override
  Future<List<int>> retrieveContent(String txid) async {
    try {
      log.d('BitDrive: Retrieving content from txid: $txid');

      // Get current block height for file identification
      final blockInfo = await api.bitcoind.getBlockchainInfo();
      final currentHeight = blockInfo.blocks;
      log.d('BitDrive: Current block height: $currentHeight');

      // Get all OP_RETURN messages
      final opReturns = await api.misc.listOPReturns();
      log.d('BitDrive: Found ${opReturns.length} total OP_RETURN messages');
      
      // Find the one matching our txid
      final opReturn = opReturns.firstWhere(
        (op) => op.txid == txid,
        orElse: () {
          log.e('BitDrive: No OP_RETURN data found for transaction $txid');
          throw BitcoindException('No OP_RETURN data found for transaction $txid');
        },
      );
      log.d('BitDrive: Found OP_RETURN data for txid: $txid');

      // Parse the data
      final parts = opReturn.message.split('|');
      if (parts.length != 2) {
        log.e('BitDrive: Invalid OP_RETURN data format. Expected 2 parts, got ${parts.length}');
        throw BitcoindException('Invalid OP_RETURN data format');
      }
      log.d('BitDrive: Successfully split OP_RETURN data');

      // Parse metadata
      final metadataBytes = base64.decode(parts[0]);
      if (metadataBytes.length != 9) {
        throw BitcoindException('Invalid metadata length');
      }

      final metadata = ByteData.view(Uint8List.fromList(metadataBytes).buffer);
      final isEncrypted = metadata.getUint8(0) == 1;
      final timestamp = metadata.getUint32(1);
      final fileType = utf8.decode(metadataBytes.sublist(4, 8)).trim();

      log.d('BitDrive: Metadata:');
      log.d('BitDrive: - Encrypted: $isEncrypted');
      log.d('BitDrive: - Timestamp: $timestamp');
      log.d('BitDrive: - File type: $fileType');

      // Decode content
      final contentBytes = base64.decode(parts[1]);
      log.d('BitDrive: Decoded content size: ${contentBytes.length} bytes');

      return contentBytes;
    } catch (e) {
      final error = 'could not retrieve content: ${extractConnectException(e)}';
      log.e('BitDrive: Error retrieving content:');
      log.e('BitDrive: $error');
      throw BitcoindException(error);
    }
  }

  @override
  Future<bool> hasOpReturn(String txid) async {
    try {
      log.d('BitDrive: Checking for OP_RETURN in txid: $txid');

      // Get all OP_RETURN messages
      final opReturns = await api.misc.listOPReturns();
      log.d('BitDrive: Found ${opReturns.length} total OP_RETURN messages');
      
      // Check if any match our txid
      final hasOpReturn = opReturns.any((op) => op.txid == txid);
      log.d('BitDrive: Transaction $txid ${hasOpReturn ? "has" : "does not have"} OP_RETURN data');
      
      return hasOpReturn;
    } catch (e) {
      final error = 'could not check for OP_RETURN: ${extractConnectException(e)}';
      log.e('BitDrive: Error checking for OP_RETURN:');
      log.e('BitDrive: $error');
      throw BitcoindException(error);
    }
  }
}

class _WalletAPILive implements WalletAPI {
  final WalletServiceClient _client;
  Logger get log => GetIt.I.get<Logger>();

  _WalletAPILive(this._client);

  @override
  Future<String> sendTransaction(
    String destination,
    int amountSatoshi, {
    double? btcPerKvB,
    String? opReturnMessage,
    String? label,
  }) async {
    try {
      final request = SendTransactionRequest(
        destination: destination,
        amount: Int64(amountSatoshi),
        feeRate: btcPerKvB,
        opReturnMessage: opReturnMessage,
        label: label,
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
      log.e(error);
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
      log.e(error);
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
      log.e(error);
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
      log.e(error);
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
      log.e('could not create deposit: $error');
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
      log.e('could not sign message: $error');
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
      log.e('could not verify message: $error');
      throw WalletException(error);
    }
  }
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
      log.e(error);
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
      log.e(error);
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
      log.e(error);
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
      log.e(error);
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
      log.e(error);
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
      log.e(error);
      throw BitcoindException(error);
    }
  }
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
      log.e(error);
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
      log.e(error);
      throw DrivechainException(error);
    }
  }
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
      log.e(error);
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
      log.e(error);
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
      log.e(error);
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
      log.e(error);
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
      log.e(error);
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