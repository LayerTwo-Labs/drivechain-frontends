import 'dart:convert';
import 'dart:io';

import 'package:connectrpc/http2.dart';
import 'package:connectrpc/protobuf.dart';
import 'package:connectrpc/protocol/grpc.dart' as grpc;
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:sail_ui/sail_ui.dart';

/// API to the enforcer server
abstract class EnforcerRPC extends RPCConnection {
  EnforcerRPC({
    required super.binaryType,
    required super.restartOnFailure,
  });

  ValidatorServiceClient get validator;

  Future<dynamic> callRAW(String url, [String body = '{}']);
  Future<Map<String, dynamic>> getBlockTemplate();
  List<String> getMethods();
}

class EnforcerLive extends EnforcerRPC {
  @override
  late ValidatorServiceClient validator;
  late grpc.Transport _grpcTransport;

  EnforcerLive() : super(binaryType: BinaryType.enforcer, restartOnFailure: true) {
    _initializeConnection();
    startConnectionTimer();
  }

  void _initializeConnection() {
    // Create new HTTP/2 transport and client
    final httpClient = createHttpClient();
    final baseUrl = 'http://localhost:${binary.port}';
    _grpcTransport = grpc.Transport(
      baseUrl: baseUrl,
      codec: const ProtoCodec(),
      httpClient: httpClient,
      statusParser: const StatusParser(),
    );

    validator = ValidatorServiceClient(_grpcTransport);
  }

  @override
  Future<List<String>> binaryArgs() async {
    var host = 'localhost';
    if (host == 'localhost' && !Platform.isWindows) {
      host = '0.0.0.0';
    }

    final downloadsDir = await getDownloadsDirectory();
    if (downloadsDir == null) {
      throw Exception('Could not determine downloads directory');
    }

    binary.extraBootArgs = binary.extraBootArgs.where((arg) => !arg.startsWith('--wallet-seed-file')).toList();

    final walletReader = GetIt.I.get<WalletReaderProvider>();
    final mnemonicFile = await walletReader.writeL1Starter();
    binary.addBootArg('--wallet-seed-file=${mnemonicFile.path}');

    // now set the esplora-url
    switch (GetIt.I.get<BitcoinConfProvider>().network) {
      case Network.NETWORK_REGTEST:
        binary.addBootArg('--wallet-esplora-url=http://localhost:3002');

      case Network.NETWORK_TESTNET:
        throw Exception('testnet not supported for enforcer');

      case Network.NETWORK_MAINNET:
        binary.addBootArg('--wallet-esplora-url=https://mempool.space/api');

      case Network.NETWORK_SIGNET:
      default:
      // default is signet, for which we dont need anything extra
    }

    final mainchainConf = readMainchainConf();
    return [
      '--node-rpc-pass=${mainchainConf.password}',
      '--node-rpc-user=${mainchainConf.username}',
      '--node-rpc-addr=$host:${mainchainConf.port}',
      '--enable-wallet',
      '--enable-mempool', // Required for getblocktemplate support
      if (binary.extraBootArgs.isNotEmpty) ...binary.extraBootArgs,
    ];
  }

  @override
  Map<String, String> get environment {
    return {'RUST_BACKTRACE': '1'};
  }

  @override
  Future<int> ping() async {
    return await _withRecreate(() async {
      final res = await validator.getChainTip(GetChainTipRequest());
      return res.blockHeaderInfo.height;
    });
  }

  @override
  List<String> startupErrors() {
    return ['Validator is not synced'];
  }

  @override
  Future<(double, double)> balance() async {
    return (0.0, 0.0);
  }

  @override
  Future<void> stopRPC() async {
    await _withRecreate(() async {
      await validator.stop(StopRequest());
    });
  }

  @override
  Future<BlockchainInfo> getBlockchainInfo() async {
    return await _withRecreate(() async {
      final res = await validator.getChainTip(GetChainTipRequest());

      return BlockchainInfo(
        chain: GetIt.I.get<BitcoinConfProvider>().network.toReadableNet(),
        blocks: res.blockHeaderInfo.height,
        headers: res.blockHeaderInfo.height,
        bestBlockHash: res.blockHeaderInfo.blockHash.hex.toString(),
        difficulty: 0,
        time: 0,
        medianTime: 0,
        verificationProgress: 0,
        initialBlockDownload: false,
        chainWork: '',
        sizeOnDisk: 0,
        pruned: false,
        warnings: [],
      );
    });
  }

  @override
  Future<Map<String, dynamic>> getBlockTemplate() async {
    // Call the enforcer's JSON-RPC server for getblocktemplate
    // Port 8122 serves RPCs like getblocktemplate (not 8123 which serves other JSON-RPC methods)
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8122/'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({
        'jsonrpc': '2.0',
        'method': 'getblocktemplate',
        'params': [
          {
            'rules': ['segwit'],
          },
        ],
        'id': 1,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('getblocktemplate request failed: ${response.body}');
    }

    final jsonResponse = jsonDecode(response.body);
    if (jsonResponse['error'] != null) {
      throw Exception('getblocktemplate error: ${jsonResponse['error']}');
    }

    final blockTemplate = jsonResponse['result'] ?? {};

    // Log the block template for debugging
    log.i('Block template received from enforcer:');
    log.i('Height: ${blockTemplate['height']}');
    log.i('Previous block hash: ${blockTemplate['previousblockhash']}');
    log.i('Transactions count: ${blockTemplate['transactions']?.length ?? 0}');
    log.i('Coinbase value: ${blockTemplate['coinbasevalue']}');
    log.i('Full template: ${jsonEncode(blockTemplate)}');

    return blockTemplate;
  }

  @override
  Future<dynamic> callRAW(String url, [String body = '{}']) async {
    try {
      final response = await http.post(
        // 2122 is correct! raw http requests must go through bitwindowd, because
        // the enforcer does not have a http-server, only a grpc-server
        Uri.parse('http://localhost:2122/$url'),
        headers: {'content-type': 'application/json'},
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

  void _recreateConnection() {
    log.w('Recreating HTTP/2 connection for enforcer');
    _initializeConnection();
  }

  Future<T> _withRecreate<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (e) {
      final errorString = e.toString().toLowerCase();

      // Check for various connection errors that require recreation
      if (errorString.contains('http/2 connection is finishing') ||
          errorString.contains('connection closed') ||
          errorString.contains('stream closed') ||
          errorString.contains('transport closed') ||
          errorString.contains('forcefully terminated') ||
          errorString.contains('connection reset') ||
          errorString.contains('broken pipe') ||
          (errorString.contains('unavailable') && errorString.contains('grpc'))) {
        log.w('Connection error detected, recreating connection: ${e.toString()}');
        _recreateConnection();
        // Retry the operation with the new connection
        return await operation();
      }
      rethrow;
    }
  }

  @override
  List<String> getMethods() {
    return [
      'cusf.crypto.v1.CryptoService/HmacSha512',
      'cusf.crypto.v1.CryptoService/Ripemd160',
      'cusf.crypto.v1.CryptoService/Secp256k1SecretKeyToPublicKey',
      'cusf.crypto.v1.CryptoService/Secp256k1Sign',
      'cusf.crypto.v1.CryptoService/Secp256k1Verify',
      'cusf.mainchain.v1.ValidatorService/GetBlockHeaderInfo',
      'cusf.mainchain.v1.ValidatorService/GetBlockInfo',
      'cusf.mainchain.v1.ValidatorService/GetBmmHStarCommitment',
      'cusf.mainchain.v1.ValidatorService/GetChainInfo',
      'cusf.mainchain.v1.ValidatorService/GetChainTip',
      'cusf.mainchain.v1.ValidatorService/GetCoinbasePSBT',
      'cusf.mainchain.v1.ValidatorService/GetCtip',
      'cusf.mainchain.v1.ValidatorService/GetSidechainProposals',
      'cusf.mainchain.v1.ValidatorService/GetSidechains',
      'cusf.mainchain.v1.ValidatorService/GetTwoWayPegData',
      'cusf.mainchain.v1.ValidatorService/SubscribeEvents',
      'cusf.mainchain.v1.WalletService/BroadcastWithdrawalBundle',
      'cusf.mainchain.v1.WalletService/CreateBmmCriticalDataTransaction',
      'cusf.mainchain.v1.WalletService/CreateDepositTransaction',
      'cusf.mainchain.v1.WalletService/CreateNewAddress',
      'cusf.mainchain.v1.WalletService/CreateSidechainProposal',
      'cusf.mainchain.v1.WalletService/CreateWallet',
      'cusf.mainchain.v1.WalletService/GenerateBlocks',
      'cusf.mainchain.v1.WalletService/GetBalance',
      'cusf.mainchain.v1.WalletService/ListSidechainDepositTransactions',
      'cusf.mainchain.v1.WalletService/ListTransactions',
      'cusf.mainchain.v1.WalletService/ListUnspentOutputs',
      'cusf.mainchain.v1.WalletService/SendTransaction',
      'cusf.mainchain.v1.WalletService/UnlockWallet',
    ];
  }
}
