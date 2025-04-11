import 'package:fixnum/src/int64.dart';
import 'package:sail_ui/classes/node_connection_settings.dart';
import 'package:sail_ui/classes/rpc_connection.dart';
import 'package:sail_ui/gen/bitcoind/v1/bitcoind.pb.dart';
import 'package:sail_ui/gen/bitwindowd/v1/bitwindowd.pb.dart';
import 'package:sail_ui/gen/drivechain/v1/drivechain.pb.dart';
import 'package:sail_ui/gen/misc/v1/misc.pb.dart';
import 'package:sail_ui/gen/wallet/v1/wallet.pb.dart';
import 'package:sail_ui/rpcs/bitwindow_api.dart';

class MockAPI extends BitwindowRPC {
  @override
  BitwindowAPI get bitwindowd => MockBitwindowdAPI();
  @override
  final WalletAPI wallet = MockWalletAPI();
  @override
  final BitcoindAPI bitcoind = MockBitcoindAPI();
  @override
  final DrivechainAPI drivechain = MockDrivechainAPI();
  @override
  final MiscAPI misc = MockMiscAPI();
  @override
  final MultisigAPI multisig = MockMultisigAPI();

  MockAPI({
    required super.conf,
    required super.binary,
    required super.logPath,
    required super.restartOnFailure,
  });

  @override
  Future<List<String>> binaryArgs(NodeConnectionSettings mainchainConf) async {
    return [];
  }

  @override
  Future<int> ping() async {
    return 1;
  }

  @override
  Future<(double, double)> balance() async {
    return (1.0, 2.0);
  }

  @override
  Future<void> stopRPC() async {
    return;
  }

  @override
  Future<BlockchainInfo> getBlockchainInfo() {
    throw UnimplementedError();
  }

  @override
  Future callRAW(String url, [String body = '{}']) {
    return Future.value(null);
  }

  @override
  List<String> getMethods() {
    return [];
  }
}

class MockBitwindowdAPI implements BitwindowAPI {
  @override
  Future<void> stop() async {
    return;
  }

  @override
  Future<void> cancelDenial(Int64 id) {
    return Future.value();
  }

  @override
  Future<void> createDenial({
    required String txid,
    required int vout,
    required int numHops,
    required int delaySeconds,
  }) {
    return Future.value();
  }

  @override
  Future<List<UnspentOutput>> listDenials() {
    return Future.value([]);
  }

  @override
  Future<List<AddressBookEntry>> listAddressBook() {
    return Future.value([]);
  }

  @override
  Future<void> createAddressBookEntry(String label, String address, Direction direction) {
    return Future.value();
  }

  @override
  Future<void> updateAddressBookEntry(Int64 id, String label) {
    return Future.value();
  }

  @override
  Future<void> deleteAddressBookEntry(Int64 id) {
    return Future.value();
  }
}

class MockWalletAPI implements WalletAPI {
  @override
  Future<String> sendTransaction(
    String destination,
    int amountSatoshi, {
    double? btcPerKvB,
    String? label,
    String? opReturnMessage,
  }) async {
    return 'mock_txid';
  }

  @override
  Future<GetBalanceResponse> getBalance() async {
    return GetBalanceResponse();
  }

  @override
  Future<String> getNewAddress() async {
    return 'mock_address';
  }

  @override
  Future<List<WalletTransaction>> listTransactions() async {
    return [];
  }

  @override
  Future<List<ListSidechainDepositsResponse_SidechainDeposit>> listSidechainDeposits(int slot) async {
    return [];
  }

  @override
  Future<String> createSidechainDeposit(int slot, String destination, double amount, double fee) async {
    return 'mock_deposit_txid';
  }

  @override
  Future<String> signMessage(String message) async {
    return 'mock_signature';
  }

  @override
  Future<bool> verifyMessage(String message, String signature, String publicKey) async {
    return true;
  }
}

class MockBitcoindAPI implements BitcoindAPI {
  @override
  Future<List<Peer>> listPeers() async {
    return [];
  }

  @override
  Future<List<RecentTransaction>> listRecentTransactions() async {
    return [];
  }

  @override
  Future<GetBlockchainInfoResponse> getBlockchainInfo() async {
    return GetBlockchainInfoResponse();
  }

  @override
  Future<EstimateSmartFeeResponse> estimateSmartFee(int confTarget) async {
    return EstimateSmartFeeResponse();
  }

  @override
  Future<GetRawTransactionResponse> getRawTransaction(String txid) async {
    return GetRawTransactionResponse();
  }

  @override
  Future<Block> getBlock({String? hash, int? height}) async {
    return Block();
  }

  @override
  Future<(List<Block>, bool)> listBlocks({int startHeight = 0, int pageSize = 50}) {
    return Future.value((<Block>[], false));
  }
}

class MockDrivechainAPI implements DrivechainAPI {
  @override
  Future<List<ListSidechainsResponse_Sidechain>> listSidechains() async {
    return [];
  }

  @override
  Future<List<SidechainProposal>> listSidechainProposals() async {
    return [];
  }
}

class MockMiscAPI implements MiscAPI {
  @override
  Future<List<OPReturn>> listOPReturns() async {
    return [];
  }

  @override
  Future<BroadcastNewsResponse> broadcastNews(String topic, String headline, String content) async {
    return BroadcastNewsResponse();
  }

  @override
  Future<CreateTopicResponse> createTopic(String topic, String name) async {
    return CreateTopicResponse();
  }

  @override
  Future<List<CoinNews>> listCoinNews() async {
    return [];
  }

  @override
  Future<List<Topic>> listTopics() async {
    return [];
  }
}

class MockMultisigAPI implements MultisigAPI {
  @override
  Future<Map<String, String>> addMultisigAddress(int nRequired, List<String> keys, String label) async {
    return {
      'address': 'mock_multisig_address',
      'redeemScript': 'mock_redeem_script',
      'descriptor': 'mock_descriptor',
    };
  }

  @override
  Future<Map<String, dynamic>> analyzePsbt(String psbt) async {
    return {
      'inputs': [],
      'next': 'signer',
      'fee': 0.0001,
      'error': '',
    };
  }

  @override
  Future<String> combinePsbt(List<String> psbts) async {
    return 'mock_combined_psbt';
  }

  @override
  Future<String> createPsbt(List<Map<String, dynamic>> inputs, List<Map<String, dynamic>> outputs,
      {int? locktime,}) async {
    return 'mock_psbt';
  }

  @override
  Future<String> createRawTransaction(List<Map<String, dynamic>> inputs, List<Map<String, dynamic>> outputs,
      {int? locktime,}) async {
    return 'mock_raw_tx_hex';
  }

  @override
  Future<Map<String, dynamic>> decodePsbt(String psbt) async {
    return {
      'tx': {},
      'unknown': {},
      'inputs': [],
      'outputs': [],
      'fee': 0.0001,
    };
  }

  @override
  Future<Map<String, dynamic>> finalizePsbt(String psbt) async {
    return {
      'psbt': 'mock_finalized_psbt',
      'hex': 'mock_tx_hex',
      'complete': true,
    };
  }

  @override
  Future<Map<String, dynamic>> getAddressInfo(String address) async {
    return {
      'address': address,
      'scriptPubKey': 'mock_script_pubkey',
      'isMine': true,
      'isWatchonly': false,
    };
  }

  @override
  Future<Map<String, dynamic>> getTransaction(String txid, {bool includeWatchonly = false}) async {
    return {
      'txid': txid,
      'confirmations': 1,
      'amount': 1000000,
    };
  }

  @override
  Future<void> importAddress(String address, String label, bool rescan) async {
    return;
  }

  @override
  Future<String> joinPsbts(List<String> psbts) async {
    return 'mock_joined_psbt';
  }

  @override
  Future<List<List<Map<String, dynamic>>>> listAddressGroupings() async {
    return [
      [
        {'address': 'mock_address1', 'amount': 1000000, 'label': 'mock_label1'},
      ]
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> listUnspent(
      {int minConf = 1, int maxConf = 9999999, List<String>? addresses,}) async {
    return [
      {
        'txid': 'mock_txid',
        'vout': 0,
        'address': 'mock_address',
        'amount': 1000000,
        'confirmations': 10,
        'spendable': true,
      }
    ];
  }

  @override
  Future<String> sendRawTransaction(String hexString, {double? maxFeeRate}) async {
    return 'mock_txid';
  }

  @override
  Future<Map<String, dynamic>> signRawTransactionWithWallet(String hexString,
      {List<Map<String, dynamic>>? prevTxs, String? sighashType,}) async {
    return {
      'hex': 'mock_signed_tx_hex',
      'complete': true,
      'errors': [],
    };
  }

  @override
  Future<Map<String, dynamic>> testMempoolAccept(String hexString) async {
    return {
      'txid': 'mock_txid',
      'allowed': true,
      'rejectReason': '',
    };
  }

  @override
  Future<String> utxoUpdatePsbt(String psbt) async {
    return 'mock_updated_psbt';
  }

  @override
  Future<Map<String, dynamic>> walletCreateFundedPsbt(
      List<Map<String, dynamic>> inputs, List<Map<String, dynamic>> outputs,
      {int? locktime, Map<String, dynamic>? options,}) async {
    return {
      'psbt': 'mock_funded_psbt',
      'fee': 1000,
      'changePosition': 1,
    };
  }

  @override
  Future<Map<String, dynamic>> walletProcessPsbt(String psbt, {bool sign = true, String? sighashType}) async {
    return {
      'psbt': 'mock_processed_psbt',
      'complete': true,
    };
  }
}
