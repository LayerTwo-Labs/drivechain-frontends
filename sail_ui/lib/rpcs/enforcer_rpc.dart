import 'dart:io';

import 'package:connectrpc/connect.dart';
import 'package:connectrpc/http2.dart';
import 'package:connectrpc/protobuf.dart';
import 'package:connectrpc/protocol/grpc.dart' as grpc;
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sail_ui/sail_ui.dart';

/// API to the enforcer server
abstract class EnforcerRPC extends RPCConnection {
  EnforcerRPC({
    required super.conf,
    required super.binary,
    required super.restartOnFailure,
  });

  ValidatorServiceClient get validator;

  Future<dynamic> callRAW(String url, [String body = '{}']);
  List<String> getMethods();
}

class EnforcerLive extends EnforcerRPC {
  @override
  late final ValidatorServiceClient validator;

  // Private constructor
  EnforcerLive._create({
    required super.conf,
    required super.binary,
    required super.restartOnFailure,
  });

  // Async factory
  static Future<EnforcerLive> create({
    required String host,
    required int port,
    required Binary binary,
  }) async {
    final httpClient = createHttpClient();
    final conf = await readConf();

    final baseUrl = 'http://$host:$port';
    final transport = grpc.Transport(
      baseUrl: baseUrl,
      codec: const ProtoCodec(),
      httpClient: httpClient,
      statusParser: const StatusParser(),
    );

    final liveInstance = EnforcerLive._create(
      conf: conf,
      binary: binary,
      restartOnFailure: true,
    );
    // must test connection before moving on, in case it is already running!
    await liveInstance._init(transport);
    return liveInstance;
  }

  Future<void> _init(Transport transport) async {
    validator = ValidatorServiceClient(transport);
    await startConnectionTimer();
  }

  @override
  Future<List<String>> binaryArgs(NodeConnectionSettings mainchainConf) async {
    final binaryProvider = GetIt.I.get<BinaryProvider>();
    final enforcerBinary = binaryProvider.binaries.where((b) => b.name == binary.name).first;

    var host = mainchainConf.host;

    if (host == 'localhost' && !Platform.isWindows) {
      host = '0.0.0.0';
    }

    final downloadsDir = await getDownloadsDirectory();
    if (downloadsDir == null) {
      throw Exception('Could not determine downloads directory');
    }

    final appDir = await getApplicationSupportDirectory();
    final walletDir = getWalletDir(appDir);

    var walletArg = '--wallet-auto-create';
    if (walletDir != null) {
      // we have a bitwindow wallet dir, and the enforcer does NOT have a wallet loaded
      // we should add a fitting arg!
      final mnemonicFile = File(path.join(walletDir.path, 'l1_starter.txt'));

      if (mnemonicFile.existsSync()) {
        // we have a mnemonic file! Use that seed
        walletArg = '--wallet-seed-file=${mnemonicFile.path}';
      }
    }

    enforcerBinary.addBootArg(walletArg);

    return [
      '--node-rpc-pass=${mainchainConf.password}',
      '--node-rpc-user=${mainchainConf.username}',
      '--node-rpc-addr=$host:${mainchainConf.port}',
      '--enable-wallet',
      if (enforcerBinary.extraBootArgs.isNotEmpty) ...enforcerBinary.extraBootArgs,
    ];
  }

  @override
  Map<String, String> get environment {
    return {
      'RUST_BACKTRACE': '1',
    };
  }

  @override
  Future<int> ping() async {
    final res = await validator.getChainTip(GetChainTipRequest());
    return res.blockHeaderInfo.height;
  }

  @override
  List<String> startupErrors() {
    return [
      'Validator is not synced',
    ];
  }

  @override
  Future<(double, double)> balance() async {
    return (0.0, 0.0);
  }

  @override
  Future<void> stopRPC() async {
    throw Exception('stop not implemented');
  }

  @override
  Future<BlockchainInfo> getBlockchainInfo() async {
    final res = await validator.getChainTip(GetChainTipRequest());
    return BlockchainInfo(
      chain: 'signet',
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
