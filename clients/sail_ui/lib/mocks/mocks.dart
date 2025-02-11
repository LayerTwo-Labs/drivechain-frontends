import 'dart:ui';

import 'package:logger/logger.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/gen/bitcoind/v1/bitcoind.pb.dart';
import 'package:sail_ui/gen/cusf/mainchain/v1/validator.connect.client.dart';
import 'package:sail_ui/gen/google/protobuf/timestamp.pb.dart';
import 'package:sail_ui/gen/misc/v1/misc.pb.dart';
import 'package:sail_ui/rpcs/bitnames_rpc.dart';
import 'package:sail_ui/rpcs/bitwindow_api.dart';
import 'package:sail_ui/rpcs/enforcer_rpc.dart';
import 'package:sail_ui/rpcs/mainchain_rpc.dart';
import 'package:sail_ui/rpcs/thunder_rpc.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/services/blockinfo_service.dart';

class MockMainchainRPC extends MainchainRPC {
  MockMainchainRPC() : super(conf: NodeConnectionSettings.empty(), binary: ParentChain(), logPath: '');

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
}

class MockEnforcerRPC extends EnforcerRPC {
  MockEnforcerRPC() : super(conf: NodeConnectionSettings.empty(), binary: Enforcer(), logPath: '');

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
}

class MockBitwindowRPC extends BitwindowRPC {
  MockBitwindowRPC() : super(conf: NodeConnectionSettings.empty(), binary: BitWindow(), logPath: '');

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
}

class MockThunderRPC extends ThunderRPC {
  MockThunderRPC() : super(conf: NodeConnectionSettings.empty(), binary: Thunder(), logPath: '');

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
}

class MockBitnamesRPC extends BitnamesRPC {
  MockBitnamesRPC() : super(conf: NodeConnectionSettings.empty(), binary: Bitnames(), logPath: '');

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
}

class MockBlockchainProvider implements BlockchainProvider {
  MockBlockchainProvider() : super();

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
  List<OPReturn> opReturns = [];

  @override
  List<Peer> peers = [];

  @override
  List<Block> blocks = [];

  @override
  List<RecentTransaction> recentTransactions = [];

  @override
  void addListener(VoidCallback listener) {
    return;
  }

  @override
  BitwindowRPC get api => throw UnimplementedError();

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
  MainchainRPC get mainchain => throw UnimplementedError();

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
  bool hasMoreBlocks = false;

  @override
  bool isLoadingMoreBlocks = false;

  @override
  Future<void> loadMoreBlocks() {
    return Future.value();
  }

  @override
  Set<int> loadedBlockHeights = {};

  @override
  BlockInfoService infoService = BlockInfoService(connection: MockMainchainRPC());
}

class MockBitcoindAPI implements BitcoindAPI {
  @override
  Future<List<Peer>> listPeers() {
    throw UnimplementedError();
  }

  @override
  Future<List<RecentTransaction>> listRecentTransactions() {
    throw UnimplementedError();
  }

  @override
  Future<(List<Block>, bool)> listBlocks({int startHeight = 0, int pageSize = 50}) {
    throw UnimplementedError();
  }

  @override
  Future<GetBlockchainInfoResponse> getBlockchainInfo() {
    throw UnimplementedError();
  }

  @override
  Future<EstimateSmartFeeResponse> estimateSmartFee(int confTarget) {
    throw UnimplementedError();
  }

  @override
  Future<GetRawTransactionResponse> getRawTransaction(String txid) {
    throw UnimplementedError();
  }

  @override
  Future<Block> getBlock({String? hash, int? height}) async {
    return Block();
  }
}
