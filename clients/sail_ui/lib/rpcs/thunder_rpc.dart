import 'package:dart_coin_rpc/dart_coin_rpc.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/bitcoin.dart';
import 'package:sail_ui/classes/node_connection_settings.dart';
import 'package:sail_ui/classes/rpc_connection.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/config/chains.dart';
import 'package:sail_ui/rpcs/rpc_sidechain.dart';
import 'package:sail_ui/widgets/components/core_transaction.dart';

final log = GetIt.I.get<Logger>();

/// API to the thunder server.
abstract class ThunderRPC extends SidechainRPC {
  ThunderRPC({
    required super.conf,
    required super.binary,
    required super.logPath,
    required super.restartOnFailure,
    required super.chain,
  });
}

class ThunderLive extends ThunderRPC {
  RPCClient _client() {
    final client = RPCClient(
      host: '127.0.0.1',
      port: binary.port,
      username: conf.username,
      password: conf.password,
      useSSL: false,
    );

    client.dioClient = Dio();
    return client;
  }

  // Private constructor
  ThunderLive._create({
    required super.conf,
    required super.binary,
    required super.logPath,
    required super.restartOnFailure,
    required super.chain,
  });

  // Async factory
  static Future<ThunderLive> create({
    required Binary binary,
    required String logPath,
    required Sidechain chain,
  }) async {
    final conf = await getMainchainConf();

    final instance = ThunderLive._create(
      conf: conf,
      binary: binary,
      logPath: logPath,
      restartOnFailure: false,
      chain: chain,
    );

    await instance._init();
    return instance;
  }

  Future<void> _init() async {
    await startConnectionTimer();
  }

  @override
  Future<List<String>> binaryArgs(NodeConnectionSettings mainchainConf) async {
    final args = <String>[];

    if (binary.mnemonicSeedPhrasePath != null) {
      args.addAll(['--mnemonic-seed-phrase-path', binary.mnemonicSeedPhrasePath!]);
    }

    return args;
  }

  @override
  Future<int> ping() async {
    final response = await _client().call('balance') as Map<String, dynamic>;
    return response['total_sats'] as int;
  }

  @override
  Future<(double, double)> balance() async {
    final response = await _client().call('balance') as Map<String, dynamic>;
    final totalSats = response['total_sats'] as int;
    final availableSats = response['available_sats'] as int;

    // Convert from sats to BTC
    final confirmed = satoshiToBTC(availableSats);
    final unconfirmed = satoshiToBTC(totalSats - availableSats);

    return (confirmed, unconfirmed);
  }

  @override
  Future<void> stopRPC() async {
    await _client().call('stop');
  }

  @override
  Future<BlockchainInfo> getBlockchainInfo() async {
    final blocks = await _client().call('get-blockcount') as int;
    return BlockchainInfo(
      chain: 'signet',
      blocks: blocks,
      headers: blocks,
      bestBlockHash: '',
      difficulty: 0,
      time: 0,
      medianTime: 0,
      verificationProgress: 100.0,
      initialBlockDownload: false,
      chainWork: '',
      sizeOnDisk: 0,
      pruned: false,
      warnings: [],
    );
  }

  @override
  List<String> getMethods() {
    return thunderRPCMethods;
  }

  @override
  Future<dynamic> callRAW(String method, [dynamic params]) async {
    return await _client().call(method, params).catchError((err) {
      log.t('rpc: $method threw exception: $err');
      throw err;
    });
  }

  @override
  Future<String> getDepositAddress() async {
    final response = await _client().call('get-new-address') as String;
    return formatDepositAddress(response, chain.slot);
  }

  @override
  Future<String> getSideAddress() async {
    final response = await _client().call('get-new-address');
    return response as String;
  }

  @override
  Future<List<CoreTransaction>> listTransactions() async {
    // TODO: Implement once we know the transaction format
    throw UnimplementedError();
  }

  @override
  Future<String> mainSend(String address, double amount, double sidechainFee, double mainchainFee) async {
    final response = await _client().call('withdraw', [
      address,
      btcToSatoshi(amount),
      btcToSatoshi(sidechainFee),
      btcToSatoshi(mainchainFee),
    ]);
    return response as String;
  }

  @override
  Future<double> sideEstimateFee() async {
    // Thunder has fixed fees for now
    return 0.00001;
  }

  @override
  Future<String> sideSend(String address, double amount, bool subtractFeeFromAmount) async {
    final response = await _client().call('transfer', [
      address,
      btcToSatoshi(amount),
      subtractFeeFromAmount,
    ]);
    return response as String;
  }
}

final thunderRPCMethods = [
  'balance',
  'connect-peer',
  'create-deposit',
  'format-deposit-address',
  'generate-mnemonic',
  'get-best-mainchain-block-hash',
  'get-best-sidechain-block-hash',
  'get-block',
  'get-bmm-inclusions',
  'get-new-address',
  'get-wallet-addresses',
  'get-wallet-utxos',
  'get-blockcount',
  'latest-failed-withdrawal-bundle-height',
  'list-peers',
  'list-utxos',
  'mine',
  'pending-withdrawal-bundle',
  'openapi-schema',
  'remove-from-mempool',
  'set-seed-from-mnemonic',
  'sidechain-wealth',
  'stop',
  'transfer',
  'withdraw',
];
