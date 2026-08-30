import 'dart:convert';

import 'package:connectrpc/connect.dart';
import 'package:connectrpc/protobuf.dart';
import 'package:connectrpc/protocol/grpc.dart' as grpc;
import 'package:get_it/get_it.dart';
import 'package:sidechain_core/sidechain_core.dart';

/// API to the enforcer server
abstract class EnforcerRPC extends RPCConnection {
  EnforcerRPC({required super.binaryType});

  ValidatorServiceClient get validator;

  Future<dynamic> callRAW(String url, [String body = '{}']);
  Future<Map<String, dynamic>> getBlockTemplate();
  List<String> getMethods();
}

class EnforcerLive extends EnforcerRPC {
  @override
  late ValidatorServiceClient validator;
  late grpc.Transport _grpcTransport;

  final String _host;
  final int _port;
  String get _baseUrl => 'http://$_host:$_port';

  ({HttpClient client, void Function() close}) _pool = closableUnaryHttpClient();

  /// [host]/[port] point at the app's local daemon, which bridges all
  /// enforcer traffic: bitwindowd in bitwindow, drivechaind in sidechain
  /// apps. The enforcer itself is never dialed directly.
  EnforcerLive({required this._host, required this._port}) : super(binaryType: BinaryType.BINARY_TYPE_ENFORCER) {
    _initializeConnection();
  }

  void _initializeConnection() {
    // The transport reads the pool per request rather than capture one, so a
    // rebuild never strands a client a consumer already holds.
    _grpcTransport = grpc.Transport(
      baseUrl: _baseUrl,
      codec: const ProtoCodec(),
      httpClient: (req) => _pool.client(req),
      statusParser: const StatusParser(),
      interceptors: [LocalAuth.interceptor()],
    );

    validator = ValidatorServiceClient(_grpcTransport);
  }

  @override
  Future<List<String>> binaryArgs() async {
    // The enforcer runs no wallet, and the orchestrator strips
    // --wallet-seed-file from its args anyway.
    binary.extraBootArgs = binary.extraBootArgs.where((arg) => !arg.startsWith('--wallet-seed-file')).toList();

    final bitcoinConfProvider = GetIt.I.get<BitcoinConfProvider>();
    final network = bitcoinConfProvider.network;

    // Get all CLI args from EnforcerConfProvider (includes node-rpc-* synced from Bitcoin conf)
    List<String> configArgs;
    if (GetIt.I.isRegistered<EnforcerConfProvider>()) {
      final enforcerConfProvider = GetIt.I.get<EnforcerConfProvider>();
      configArgs = enforcerConfProvider.getCliArgs(network);
    } else {
      // Fallback if provider not registered yet
      configArgs = _getDefaultCliArgs(network);
    }

    // Add any extra boot args that aren't already in configArgs
    final extraArgs = binary.extraBootArgs.where((arg) {
      final argKey = arg.split('=').first;
      return !configArgs.any((a) => a.startsWith(argKey));
    }).toList();

    return [...configArgs, ...extraArgs];
  }

  /// Fallback CLI args when EnforcerConfProvider is not available
  List<String> _getDefaultCliArgs(BitcoinNetwork network) {
    final args = <String>[];

    // Add node-rpc-* from mainchainConf
    final mainchainConf = readMainchainConf();
    const host = '127.0.0.1';
    args.add('--node-rpc-user=${mainchainConf.username}');
    args.add('--node-rpc-pass=${mainchainConf.password}');
    args.add('--node-rpc-addr=$host:${mainchainConf.port}');

    // Set esplora URL based on network
    switch (network) {
      case BitcoinNetwork.BITCOIN_NETWORK_REGTEST:
        args.add('--wallet-esplora-url=http://localhost:3002');

      case BitcoinNetwork.BITCOIN_NETWORK_TESTNET:
        throw Exception('testnet not supported for enforcer');

      case BitcoinNetwork.BITCOIN_NETWORK_MAINNET:
        args.add('--wallet-esplora-url=https://esplora.mainnet.drivechain.info');

      case BitcoinNetwork.BITCOIN_NETWORK_FORKNET:
        args.add('--wallet-esplora-url=https://explorer.forknet.drivechain.info/api');

      case BitcoinNetwork.BITCOIN_NETWORK_ECASH:
        args.add('--wallet-esplora-url=${ecashEsploraUrl()}');

      case BitcoinNetwork.BITCOIN_NETWORK_SIGNET:
      default:
      // Signet uses the enforcer's built-in default
    }

    // ZMQ sequence address (read from bitcoin.conf, fallback to default)
    var zmqSequence = 'tcp://127.0.0.1:29000';
    try {
      final bitcoinConf = GetIt.I.get<BitcoinConfProvider>();
      final fromConf = bitcoinConf.currentConfig?.getEffectiveSetting(
        'zmqpubsequence',
        bitcoinConf.network.toCoreNetwork(),
      );
      if (fromConf != null && fromConf.isNotEmpty) {
        zmqSequence = fromConf;
      }
    } catch (_) {}
    args.add('--node-zmq-addr-sequence=$zmqSequence');

    // Default flags. The block template server replaces the wallet: it serves
    // getblocktemplate and block generation, and pays to an address we pass in.
    args.add('--enable-mempool');
    args.add('--enable-block-template-server');

    return args;
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
        chain: (GetIt.I.get<BitcoinConfProvider>().network).toReadableNet(),
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
    final response = await LocalAuth.postJsonWithAuth(
      Uri.parse('$_baseUrl/enforcer/jsonrpc'),
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
      final response = await LocalAuth.postJsonWithAuth(
        // Raw http requests go through bitwindowd's enforcer bridge.
        Uri.parse('$_baseUrl/$url'),
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

  /// Replace the socket pool behind the transport. The old pool closes, or its
  /// sockets stay open until GC runs and a reconnect loop exhausts the process
  /// file descriptors.
  void _recreateConnection() {
    log.w('Recreating HTTP/2 connection for enforcer');
    final previous = _pool;
    _pool = closableUnaryHttpClient();
    previous.close();
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
        log.w(
          'Connection error detected, recreating connection: ${e.toString()}',
        );
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
    ];
  }
}
