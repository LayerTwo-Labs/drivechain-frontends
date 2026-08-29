import 'package:connectrpc/protobuf.dart';
import 'package:connectrpc/protocol/connect.dart' as connect;
import 'package:fixnum/fixnum.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/auth/local_auth.dart';
import 'package:sidechain_core/bitcoin.dart' as bitcoin;
import 'package:sidechain_core/classes/rpc_connection.dart';
import 'package:sidechain_core/config/binaries.dart';
import 'package:sidechain_core/config/sidechains.dart';
import 'package:sidechain_core/gen/bbc/v1/bbc.connect.client.dart';
import 'package:sidechain_core/gen/bbc/v1/bbc.pb.dart' as pb;
import 'package:sidechain_core/models/core_transaction.dart';
import 'package:sidechain_core/rpcs/keepalive_http_client.dart';
import 'package:sidechain_core/rpcs/orchestrator_rpc.dart';
import 'package:sidechain_core/rpcs/rpc_sidechain.dart';
import 'package:sidechain_core/rpcs/thunder_utxo.dart';

/// Peg state as reported by the node's own view of the enforcer.
class BbcPegInfo {
  final bool synced;
  final String? mainchainTip;
  final String? lastError;

  const BbcPegInfo({required this.synced, this.mainchainTip, this.lastError});
}

/// API to the Bbc node, served by the orchestrator.
///
/// Unlike the CUSF sidechains, this one is Bitcoin Core derived, so the
/// operations the CUSF interface assumes — mining, withdrawals, bundle queries
/// — are either unavailable or not yet wired into consensus, and are reported
/// as such rather than faked.
abstract class BbcRPC extends SidechainRPC {
  BbcRPC({required super.binaryType});

  /// Whether the node's mirror of the enforcer is complete, and the mainchain
  /// tip it last saw.
  Future<BbcPegInfo> getPegInfo();

  /// The mainchain tip according to the enforcer, fetched live.
  Future<String> getMainchainTip();

  /// The BMM commitment this slot made in a mainchain block, if any.
  Future<String?> getBmmCommitment(String mainchainBlockHash);
}

class BbcLive extends BbcRPC {
  @override
  final log = GetIt.I.get<Logger>();

  late BbcServiceClient _client;

  BbcLive() : super(binaryType: BinaryType.BINARY_TYPE_BBC) {
    final transport = connect.Transport(
      baseUrl: OrchestratorEndpoint.url,
      codec: const ProtoCodec(),
      httpClient: unaryHttpClient(),
      interceptors: [LocalAuth.interceptor()],
    );
    _client = BbcServiceClient(transport);
  }

  @override
  Future<List<String>> binaryArgs() async => ['-sidechainslot=${Bbc().slot}'];

  @override
  Future<BbcPegInfo> getPegInfo() async {
    final resp = await _client.getSidechainInfo(pb.GetSidechainInfoRequest());
    return BbcPegInfo(
      synced: resp.synced,
      mainchainTip: resp.mainchainTip.isEmpty ? null : resp.mainchainTip,
      lastError: resp.lastError.isEmpty ? null : resp.lastError,
    );
  }

  @override
  Future<String> getMainchainTip() async {
    final resp = await _client.getMainchainTip(pb.GetMainchainTipRequest());
    return resp.blockHash;
  }

  @override
  Future<String?> getBmmCommitment(String mainchainBlockHash) async {
    final resp = await _client.getBmmCommitment(
      pb.GetBmmCommitmentRequest(mainchainBlockHash: mainchainBlockHash),
    );
    return resp.commitment.isEmpty ? null : resp.commitment;
  }

  @override
  Future<int> getBlockCount() async {
    final resp = await _client.getBlockCount(pb.GetBlockCountRequest());
    return resp.count.toInt();
  }

  @override
  Future<void> stopRPC() async {
    await _client.stop(pb.StopRequest());
  }

  @override
  Future<(double, double)> balance() async {
    final resp = await GetIt.I.get<OrchestratorRPC>().getSidechainBalance(binaryType);
    return (
      bitcoin.satoshiToBTC(resp.confirmedSats.toInt()),
      bitcoin.satoshiToBTC(resp.pendingSats.toInt()),
    );
  }

  @override
  Future<BlockchainInfo> getBlockchainInfo() async {
    final info = await _client.getBlockchainInfo(pb.GetBlockchainInfoRequest());
    return BlockchainInfo(
      chain: info.chain,
      blocks: info.blocks.toInt(),
      headers: info.headers.toInt(),
      bestBlockHash: info.bestBlockHash,
      difficulty: info.difficulty,
      time: info.time.toInt(),
      medianTime: info.medianTime.toInt(),
      verificationProgress: info.verificationProgress,
      initialBlockDownload: info.initialBlockDownload,
      chainWork: info.chainWork,
      sizeOnDisk: info.sizeOnDisk.toInt(),
      pruned: info.pruned,
      warnings: info.warnings,
    );
  }

  @override
  Future<String> getSideAddress() async {
    final resp = await _client.getNewAddress(pb.GetNewAddressRequest());
    return resp.address;
  }

  @override
  Future<String> getDepositAddress() async {
    return bitcoin.formatDepositAddress(await getSideAddress(), chain.slot);
  }

  @override
  Future<String> sideSend(String address, double amount, bool subtractFeeFromAmount) async {
    final resp = await _client.send(
      pb.SendRequest(
        address: address,
        amountSats: Int64(bitcoin.btcToSatoshi(amount).toInt()),
        subtractFeeFromAmount: subtractFeeFromAmount,
      ),
    );
    return resp.txid;
  }

  @override
  Future<double> sideEstimateFee() async {
    final resp = await _client.estimateFee(pb.EstimateFeeRequest());
    return bitcoin.satoshiToBTC(resp.satsPerKvb.toInt());
  }

  @override
  Future<List<SidechainUTXO>> listUTXOs() async => _listUnspent();

  /// Core's wallet only knows its own coins, so this is listUTXOs.
  @override
  Future<List<SidechainUTXO>> listAllUTXOs() async => _listUnspent();

  Future<List<SidechainUTXO>> _listUnspent() async {
    final resp = await _client.listUtxos(pb.ListUtxosRequest());
    return resp.utxos
        .map(
          (u) => SidechainUTXO(
            outpoint: '${u.txid}:${u.vout}',
            address: u.address,
            valueSats: u.valueSats.toInt(),
            type: OutpointType.regular,
          ),
        )
        .toList();
  }

  @override
  Future<List<CoreTransaction>> listTransactions() async {
    final resp = await _client.listTransactions(pb.ListTransactionsRequest(count: Int64(100)));
    return resp.transactions
        .map(
          (tx) => CoreTransaction.fromMap({
            'txid': tx.txid,
            'amount': bitcoin.satoshiToBTC(tx.amountSats.toInt()),
            'confirmations': tx.confirmations.toInt(),
            'time': tx.time.toInt(),
            'address': tx.address,
            'category': tx.category,
          }),
        )
        .toList();
  }

  // ── Not available on this chain ────────────────────────────────────────────
  // Blocks are blind-merge-mined: production needs a mainchain BMM transaction,
  // which this node deliberately cannot create (it holds no mainchain wallet).

  @override
  Future<BmmResult> mine(int feeSats) async {
    throw UnsupportedError(
      'Bbc blocks are blind-merge-mined; the node holds no mainchain wallet',
    );
  }

  // The withdrawal lifecycle is not yet wired into consensus. Reporting "none"
  // would be indistinguishable from a working chain with nothing pending, so
  // these fail loudly instead.

  @override
  Future<PendingWithdrawalBundle?> getPendingWithdrawalBundle() async {
    throw UnsupportedError('withdrawals are not wired into consensus yet');
  }

  @override
  Future<int?> getLatestFailedWithdrawalBundleHeight() async {
    throw UnsupportedError('withdrawals are not wired into consensus yet');
  }

  @override
  Future<String> withdraw(String address, int amountSats, int sidechainFeeSats, int mainchainFeeSats) async {
    throw UnsupportedError('withdrawals are not wired into consensus yet');
  }

  @override
  Future<dynamic> callRAW(String method, [dynamic params]) async {
    throw UnsupportedError('the bbc node has no raw RPC passthrough');
  }

  @override
  List<String> getMethods() => const [];
}
