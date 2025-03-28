import 'dart:ui';

import 'package:logger/logger.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/gen/bitcoind/v1/bitcoind.pb.dart';
import 'package:sail_ui/gen/cusf/mainchain/v1/validator.connect.client.dart';
import 'package:sail_ui/gen/google/protobuf/timestamp.pb.dart';
import 'package:sail_ui/rpcs/bitnames_rpc.dart';
import 'package:sail_ui/rpcs/bitwindow_api.dart';
import 'package:sail_ui/rpcs/enforcer_rpc.dart';
import 'package:sail_ui/rpcs/mainchain_rpc.dart';
import 'package:sail_ui/rpcs/thunder_rpc.dart';
import 'package:sail_ui/sail_ui.dart';

class MockMainchainRPC extends MainchainRPC {
  MockMainchainRPC()
      : super(
          conf: NodeConnectionSettings.empty(),
          binary: ParentChain(),
          logPath: '',
          restartOnFailure: false,
        );

  bool _connected = false;
  bool _initializing = false;
  bool _stopping = false;
  String? _error;
  bool _inIBD = true;

  @override
  bool get connected => _connected;
  @override
  bool get initializingBinary => _initializing;
  @override
  bool get stoppingBinary => _stopping;
  @override
  String? get connectionError => _error;
  @override
  bool get inIBD => _inIBD;

  void setConnected(bool value) {
    _connected = value;
    notifyListeners();
  }

  void setInitializing(bool value) {
    _initializing = value;
    notifyListeners();
  }

  void setStopping(bool value) {
    _stopping = value;
    notifyListeners();
  }

  void setError(String? value) {
    _error = value;
    notifyListeners();
  }

  void setIBD(bool value) {
    _inIBD = value;
    notifyListeners();
  }

  @override
  Future<void> waitForIBD() async {}

  @override
  Future<BlockchainInfo> getBlockchainInfo() async {
    return BlockchainInfo(
      chain: 'test',
      blocks: 100,
      headers: 200,
      bestBlockHash: 'mock_hash',
      difficulty: 1.0,
      time: 0,
      medianTime: 0,
      verificationProgress: 0.5,
      initialBlockDownload: _inIBD,
      chainWork: '',
      sizeOnDisk: 0,
      pruned: false,
      warnings: [],
    );
  }

  @override
  Future<void> stopRPC() async {}

  @override
  Future<(double, double)> balance() {
    return Future.value((0.0, 0.0));
  }

  @override
  Future<List<String>> binaryArgs(NodeConnectionSettings mainchainConf) {
    return Future.value([]);
  }

  @override
  Future<int> ping() {
    return Future.value(0);
  }

  @override
  Future<void> waitForHeaderSync() async {
    return;
  }

  @override
  Future<dynamic> callRAW(String method, [List? params]) {
    return Future.value(null);
  }

  @override
  List<String> getMethods() {
    return [];
  }

  @override
  Future<List<PeerInfo>> getPeerInfo() {
    return Future.value([]);
  }

  @override
  Future<String> getDataDir() {
    throw UnimplementedError();
  }

  @override
  Future<MempoolInfo> getMempoolInfo() {
    throw UnimplementedError();
  }

  @override
  Future<MiningInfo> getMiningInfo() {
    throw UnimplementedError();
  }

  @override
  Future<NetworkInfo> getNetworkInfo() {
    throw UnimplementedError();
  }

  @override
  Future<TxOutsetInfo> getTxOutsetInfo() {
    throw UnimplementedError();
  }
}

class MockEnforcerRPC extends EnforcerRPC {
  MockEnforcerRPC()
      : super(
          conf: NodeConnectionSettings.empty(),
          binary: Enforcer(),
          logPath: '',
          restartOnFailure: true,
        );

  bool _connected = false;
  bool _initializing = false;
  bool _stopping = false;
  String? _error;

  @override
  bool get connected => _connected;
  @override
  bool get initializingBinary => _initializing;
  @override
  bool get stoppingBinary => _stopping;
  @override
  String? get connectionError => _error;

  void setConnected(bool value) {
    _connected = value;
    notifyListeners();
  }

  void setInitializing(bool value) {
    _initializing = value;
    notifyListeners();
  }

  void setStopping(bool value) {
    _stopping = value;
    notifyListeners();
  }

  void setError(String? value) {
    _error = value;
    notifyListeners();
  }

  @override
  Future<void> stopRPC() async {}

  @override
  Future<(double, double)> balance() {
    return Future.value((0.0, 0.0));
  }

  @override
  Future<List<String>> binaryArgs(NodeConnectionSettings mainchainConf) {
    return Future.value([]);
  }

  @override
  Future<int> ping() {
    return Future.value(0);
  }

  @override
  ValidatorServiceClient get validator => throw UnimplementedError();

  @override
  Future<BlockchainInfo> getBlockchainInfo() {
    throw UnimplementedError();
  }

  @override
  Future<dynamic> callRAW(String url, [String body = '{}']) {
    return Future.value(null);
  }

  @override
  List<String> getMethods() {
    return [];
  }
}

class MockBitwindowRPC extends BitwindowRPC {
  MockBitwindowRPC()
      : super(conf: NodeConnectionSettings.empty(), binary: BitWindow(), logPath: '', restartOnFailure: true);

  bool _connected = false;
  bool _initializing = false;
  bool _stopping = false;
  String? _error;

  @override
  bool get connected => _connected;
  @override
  bool get initializingBinary => _initializing;
  @override
  bool get stoppingBinary => _stopping;
  @override
  String? get connectionError => _error;

  void setConnected(bool value) {
    _connected = value;
    notifyListeners();
  }

  void setInitializing(bool value) {
    _initializing = value;
    notifyListeners();
  }

  void setStopping(bool value) {
    _stopping = value;
    notifyListeners();
  }

  void setError(String? value) {
    _error = value;
    notifyListeners();
  }

  @override
  Future<void> stopRPC() async {}

  @override
  Future<(double, double)> balance() {
    return Future.value((0.0, 0.0));
  }

  @override
  Future<List<String>> binaryArgs(NodeConnectionSettings mainchainConf) {
    return Future.value([]);
  }

  @override
  BitcoindAPI get bitcoind => throw UnimplementedError();

  @override
  DrivechainAPI get drivechain => throw UnimplementedError();

  @override
  MiscAPI get misc => throw UnimplementedError();

  @override
  Future<int> ping() {
    return Future.value(0);
  }

  @override
  WalletAPI get wallet => throw UnimplementedError();
  @override
  BitwindowAPI get bitwindowd => throw UnimplementedError();

  @override
  Future<BlockchainInfo> getBlockchainInfo() {
    throw UnimplementedError();
  }

  @override
  Future<dynamic> callRAW(String url, [String body = '{}']) {
    return Future.value(null);
  }

  @override
  List<String> getMethods() {
    return [];
  }
}

class MockThunderRPC extends ThunderRPC {
  MockThunderRPC()
      : super(
          conf: NodeConnectionSettings.empty(),
          binary: Thunder(),
          logPath: '',
          restartOnFailure: true,
          chain: Thunder(),
        );

  bool _connected = false;
  bool _initializing = false;
  bool _stopping = false;
  String? _error;

  @override
  bool get connected => _connected;
  @override
  bool get initializingBinary => _initializing;
  @override
  bool get stoppingBinary => _stopping;
  @override
  String? get connectionError => _error;

  void setConnected(bool value) {
    _connected = value;
    notifyListeners();
  }

  void setInitializing(bool value) {
    _initializing = value;
    notifyListeners();
  }

  void setStopping(bool value) {
    _stopping = value;
    notifyListeners();
  }

  void setError(String? value) {
    _error = value;
    notifyListeners();
  }

  @override
  Future<void> stopRPC() async {}

  @override
  Future<(double, double)> balance() {
    return Future.value((0.0, 0.0));
  }

  @override
  Future<List<String>> binaryArgs(NodeConnectionSettings mainchainConf) {
    return Future.value([]);
  }

  @override
  Future<int> ping() {
    return Future.value(0);
  }

  @override
  Future<BlockchainInfo> getBlockchainInfo() {
    throw UnimplementedError();
  }

  @override
  List<String> getMethods() {
    return thunderRPCMethods;
  }

  @override
  Future<dynamic> callRAW(String method, [dynamic params]) async {
    return;
  }

  @override
  Future<String> getDepositAddress() {
    return Future.value('tb1qxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
  }

  @override
  Future<String> getSideAddress() {
    return Future.value('tb1qyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy');
  }

  @override
  Future<List<CoreTransaction>> listTransactions() {
    return Future.value([]);
  }

  @override
  Future<String> mainSend(String address, double amount, double sidechainFee, double mainchainFee) {
    return Future.value('txid_mainchain_send_1234');
  }

  @override
  Future<double> sideEstimateFee() {
    return Future.value(0.00001);
  }

  @override
  Future<String> sideSend(String address, double amount, bool subtractFeeFromAmount) {
    return Future.value('txid_sidechain_send_5678');
  }
}

class MockBitnamesRPC extends BitnamesRPC {
  MockBitnamesRPC()
      : super(
          conf: NodeConnectionSettings.empty(),
          binary: Bitnames(),
          logPath: '',
          restartOnFailure: true,
          chain: Bitnames(),
        );

  bool _connected = false;
  bool _initializing = false;
  bool _stopping = false;
  String? _error;

  @override
  bool get connected => _connected;
  @override
  bool get initializingBinary => _initializing;
  @override
  bool get stoppingBinary => _stopping;
  @override
  String? get connectionError => _error;

  void setConnected(bool value) {
    _connected = value;
    notifyListeners();
  }

  void setInitializing(bool value) {
    _initializing = value;
    notifyListeners();
  }

  void setStopping(bool value) {
    _stopping = value;
    notifyListeners();
  }

  void setError(String? value) {
    _error = value;
    notifyListeners();
  }

  @override
  Future<void> stopRPC() async {}

  @override
  Future<(double, double)> balance() {
    return Future.value((0.0, 0.0));
  }

  @override
  Future<List<String>> binaryArgs(NodeConnectionSettings mainchainConf) {
    return Future.value([]);
  }

  @override
  Future<int> ping() {
    return Future.value(0);
  }

  @override
  Future<BlockchainInfo> getBlockchainInfo() {
    throw UnimplementedError();
  }

  @override
  List<String> getMethods() {
    return [];
  }

  @override
  Future<dynamic> callRAW(String method, [dynamic params]) async {
    return;
  }

  @override
  Future<String> getDepositAddress() {
    return Future.value('tb1qxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx');
  }

  @override
  Future<String> getSideAddress() {
    return Future.value('tb1qyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy');
  }

  @override
  Future<List<CoreTransaction>> listTransactions() {
    return Future.value([]);
  }

  @override
  Future<String> mainSend(String address, double amount, double sidechainFee, double mainchainFee) {
    return Future.value('txid_mainchain_send_1234');
  }

  @override
  Future<double> sideEstimateFee() {
    return Future.value(0.00001);
  }

  @override
  Future<String> sideSend(String address, double amount, bool subtractFeeFromAmount) {
    return Future.value('txid_sidechain_send_5678');
  }
}

class MockBlockInfoProvider implements BlockInfoProvider {
  MockBlockInfoProvider() : super();

  @override
  BlockchainInfo blockchainInfo = BlockchainInfo(
    chain: '',
    blocks: 0,
    headers: 0,
    bestBlockHash: '',
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

  @override
  String? error;

  @override
  void addListener(VoidCallback listener) {
    return;
  }

  @override
  void dispose() {
    return;
  }

  @override
  Future<void> fetch() async {
    return;
  }

  @override
  bool get hasListeners => false;

  @override
  Timestamp? get lastBlockAt => null;

  @override
  Logger get log => Logger();

  @override
  void notifyListeners() {
    return;
  }

  @override
  void removeListener(VoidCallback listener) {
    return;
  }

  @override
  String get verificationProgress => '0';

  @override
  RPCConnection get connection => throw UnimplementedError();
}

class MockBitcoindAPI implements BitcoindAPI {
  @override
  Future<List<Peer>> listPeers() {
    return Future.value([]);
  }

  @override
  Future<List<RecentTransaction>> listRecentTransactions() {
    return Future.value([]);
  }

  @override
  Future<(List<Block>, bool)> listBlocks({int startHeight = 0, int pageSize = 50}) {
    return Future.value((<Block>[], false));
  }

  @override
  Future<GetBlockchainInfoResponse> getBlockchainInfo() {
    return Future.value(GetBlockchainInfoResponse());
  }

  @override
  Future<EstimateSmartFeeResponse> estimateSmartFee(int confTarget) {
    return Future.value(EstimateSmartFeeResponse());
  }

  @override
  Future<GetRawTransactionResponse> getRawTransaction(String txid) {
    return Future.value(GetRawTransactionResponse());
  }

  @override
  Future<Block> getBlock({String? hash, int? height}) async {
    return Block();
  }
}
