import 'dart:io';

import 'package:connectrpc/connect.dart';
import 'package:http/http.dart' as http;
import 'package:sail_ui/classes/node_connection_settings.dart';
import 'package:sail_ui/classes/rpc_connection.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/gen/cusf/mainchain/v1/validator.connect.client.dart';
import 'package:sail_ui/gen/cusf/mainchain/v1/validator.pb.dart';

/// API to the enforcer server
abstract class EnforcerRPC extends RPCConnection {
  EnforcerRPC({
    required super.conf,
    required super.binary,
    required super.logPath,
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
    required super.logPath,
    required super.restartOnFailure,
  });

  // Async factory
  static Future<EnforcerLive> create({
    required Binary binary,
    required Transport transport,
  }) async {
    final conf = await getMainchainConf();
    final logPath = binary.logPath();

    final instance = EnforcerLive._create(
      conf: conf,
      binary: binary,
      logPath: logPath,
      restartOnFailure: true,
    );

    await instance._init(transport);
    return instance;
  }

  Future<void> _init(Transport transport) async {
    validator = ValidatorServiceClient(transport);
    await startConnectionTimer();
  }

  @override
  Future<List<String>> binaryArgs(NodeConnectionSettings mainchainConf) async {
    var host = mainchainConf.host;
    if (host == 'localhost' && !Platform.isWindows) {
      host = '0.0.0.0';
    }

    return [
      '--node-rpc-pass=${mainchainConf.password}',
      '--node-rpc-user=${mainchainConf.username}',
      '--node-rpc-addr=$host:${mainchainConf.port}',
      '--node-zmq-addr-sequence=tcp://$host:29000',
      '--enable-wallet',
      '--wallet-auto-create',
    ];
  }

  @override
  Future<int> ping() async {
    final res = await validator.getChainTip(GetChainTipRequest());
    return res.blockHeaderInfo.height;
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
