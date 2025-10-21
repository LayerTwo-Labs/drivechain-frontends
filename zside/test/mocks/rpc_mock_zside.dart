import 'package:sail_ui/sail_ui.dart';

class MockZSideRPC extends ZSideRPC {
  MockZSideRPC()
    : super(
        binaryType: BinaryType.zSide,
        restartOnFailure: false,
      );

  @override
  Future<dynamic> callRAW(String method, [params]) async {
    return;
  }

  @override
  Future<(double, double)> balance() async {
    return (123.0, 0.0);
  }

  @override
  Future<List<CoreTransaction>> listTransactions() async {
    return List.empty();
  }

  @override
  Future<List<SidechainUTXO>> listUTXOs() async {
    return [
      SidechainUTXO(
        address: 'tmBd8jBt7FGDjN8KL9Wh4s925R6EopAGacu',
        outpoint: '',
        valueSats: 859,
        type: OutpointType.regular,
      ),
      SidechainUTXO(
        address: 'tmBd8jBt7FGDjN8KL9Wh4s925R6EopAGacu',
        outpoint: '',
        valueSats: 860,
        type: OutpointType.regular,
      ),
      SidechainUTXO(
        address: 'tmBd8jBt7FGDjN8KL9Wh4s925R6EopAGacu',
        outpoint: '',
        valueSats: 861,
        type: OutpointType.regular,
      ),
      SidechainUTXO(
        address: 'tmBd8jBt7FGDjN8KL9Wh4s925R6EopAGacu',
        outpoint: '',
        valueSats: 859,
        type: OutpointType.regular,
      ),
      SidechainUTXO(
        address: 'tmBd8jBt7FGDjN8KL9Wh4s925R6EopAGacu',
        outpoint: '',
        valueSats: 860,
        type: OutpointType.regular,
      ),
      SidechainUTXO(
        address: 'tmBd8jBt7FGDjN8KL9Wh4s925R6EopAGacu',
        outpoint: '',
        valueSats: 861,
        type: OutpointType.regular,
      ),
    ];
  }

  @override
  Future<String> deshield(ShieldedUTXO utxo, double amount) async {
    return 'txid-7c484106 409a-47dc-b853-3c641beaf166';
  }

  @override
  Future<String> shield(UnshieldedUTXO utxo, double amount) async {
    return 'opid-7c484106 409a-47dc-b853-3c641beaf166';
  }

  @override
  Future<String> getDepositAddress() async {
    return formatDepositAddress('3CUZ683astRsmACdRKyx7eFb1y9yvMRzGi', chain.slot);
  }

  @override
  Future<String> withdraw(String address, int amountSats, int sidechainFeeSats, int mainchainFeeSats) async {
    return 'some-sidechain-txid';
  }

  @override
  Future<double> sideEstimateFee() async {
    return 0.00001;
  }

  @override
  Future<String> getNewShieldedAddress() async {
    return 'regtestsapling13gh808131h6x3fd9legOargk0q03ugkkjrhptermv7gnz62kc7u20cp5rtxmize219crk5veq6q';
  }

  @override
  Future<int> ping() async {
    return 100;
  }

  @override
  List<String> startupErrors() {
    return [];
  }

  @override
  Future<String> sideSend(String address, double amount, bool subtractFeeFromAmount) async {
    return 'txiddeadbeef';
  }

  @override
  Future<String> getSideAddress() async {
    return 'tmBd8jBt7FGDjN8KL9Wh4s925R6EopAGacu';
  }

  @override
  Future<void> stopRPC() async {
    return;
  }

  @override
  Future<String> sendTransparent(String address, double amount, double feeSats) async {
    return 'txiddeadbeef';
  }

  @override
  Future<List<ShieldedUTXO>> listPrivateTransactions() async {
    return [];
  }

  @override
  Future<BlockchainInfo> getBlockchainInfo() async {
    await Future.delayed(const Duration(seconds: 3));
    return BlockchainInfo(
      chain: 'mocknet',
      blocks: 100,
      headers: 100,
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
    return zsideRPCMethods;
  }

  @override
  Future<BmmResult> mine(int feeSats) async {
    return BmmResult.empty();
  }

  @override
  Future<PendingWithdrawalBundle?> getPendingWithdrawalBundle() async {
    return null;
  }

  @override
  Future<List<String>> binaryArgs() async {
    return [];
  }

  @override
  Future<void> connectPeer(String peerAddress) async {
    return;
  }

  @override
  Future<String> createDeposit(String address, double amount, double fee) async {
    return 'txiddeadbeef';
  }

  @override
  Future<String> generateMnemonic() async {
    return 'mnemonic';
  }

  @override
  Future<String> getBMMInclusions(String blockHash) async {
    return 'bmm-inclusions';
  }

  @override
  Future<String?> getBestMainchainBlockHash() async {
    return 'best-mainchain-block-hash';
  }

  @override
  Future<String?> getBestSidechainBlockHash() async {
    return 'best-sidechain-block-hash';
  }

  @override
  Future<Map<String, dynamic>?> getBlock(String hash) async {
    return {'hash': hash};
  }

  @override
  Future<int?> getLatestFailedWithdrawalBundleHeight() async {
    return 100;
  }

  @override
  Future<String> getNewTransparentAddress() async {
    return 'new-transparent-address';
  }

  @override
  Future<List<String>> getShieldedWalletAddresses() async {
    return ['shielded-wallet-address'];
  }

  @override
  Future<double> getSidechainWealth() async {
    return 100.0;
  }

  @override
  Future<List<String>> getTransparentWalletAddresses() async {
    return ['transparent-wallet-address'];
  }

  @override
  Future<List<Map<String, dynamic>>> listPeers() async {
    return [];
  }

  @override
  Future<List<UnshieldedUTXO>> listTransparentTransactions() async {
    return [];
  }

  @override
  Future<void> removeFromMempool(String txid) async {
    return;
  }

  @override
  Future<String> sendShielded(String dest, double valueSats, double feeSats) async {
    return 'txiddeadbeef';
  }

  @override
  Future<void> setSeedFromMnemonic(String mnemonic) async {
    return;
  }

  @override
  Future<List<ShieldedUTXO>> listShieldedUTXOs() async {
    return [];
  }

  @override
  Future<List<UnshieldedUTXO>> listUnshieldedUTXOs() async {
    return [];
  }

  @override
  Future<int> getBlockCount() async {
    return 1;
  }
}
