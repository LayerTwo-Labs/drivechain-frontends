import 'package:collection/collection.dart';
import 'package:get_it/get_it.dart';
import 'package:sidechain_core/bitcoin.dart' as bitcoin;
import 'package:sidechain_core/classes/rpc_connection.dart';
import 'package:sidechain_core/gen/orchestrator/v1/orchestrator.pb.dart';
import 'package:sidechain_core/models/core_transaction.dart';
import 'package:sidechain_core/rpcs/orchestrator_rpc.dart';
import 'package:sidechain_core/rpcs/rpc_sidechain.dart';
import 'package:sidechain_core/rpcs/thunder_utxo.dart';

/// API to the FreeBank node, served by the orchestrator.
///
/// It uses only the orchestrator's generic routes, so it works for any FreeBank
/// build. A call those routes do not cover is unsupported.
class FreeBankRPC extends SidechainRPC {
  FreeBankRPC() : super(binaryType: BinaryType.BINARY_TYPE_FREEBANK);

  OrchestratorRPC get _orchestrator => GetIt.I.get<OrchestratorRPC>();

  /// The orchestrator builds the node's arguments.
  @override
  Future<List<String>> binaryArgs() async => [];

  @override
  Future<void> stopRPC() async {
    await _orchestrator.stopBinary('freebank');
  }

  @override
  Future<(double, double)> balance() async {
    final resp = await _orchestrator.getSidechainBalance(binaryType);
    return (
      bitcoin.satoshiToBTC(resp.confirmedSats.toInt()),
      bitcoin.satoshiToBTC(resp.pendingSats.toInt()),
    );
  }

  @override
  Future<int> getBlockCount() async => (await _sync()).blocks;

  @override
  Future<BlockchainInfo> getBlockchainInfo() async {
    final sync = await _sync();
    return BlockchainInfo(
      chain: '',
      blocks: sync.blocks,
      headers: sync.headers,
      bestBlockHash: '',
      difficulty: 0,
      time: sync.time.toInt(),
      medianTime: 0,
      verificationProgress: sync.headers > 0 ? sync.blocks / sync.headers : 0,
      initialBlockDownload: sync.blocks < sync.headers,
      chainWork: '',
      sizeOnDisk: 0,
      pruned: false,
      warnings: const [],
    );
  }

  /// The node's sync state as the orchestrator last read it.
  Future<ChainSync> _sync() async {
    final status = await _orchestrator.getSyncStatus();
    final entry = status.sidechains.firstWhereOrNull((s) => s.type == SidechainType.SIDECHAIN_TYPE_FREEBANK);
    if (entry == null) {
      throw StateError('the orchestrator reports no FreeBank sync status');
    }
    if (entry.sync.error.isNotEmpty) {
      throw StateError(entry.sync.error);
    }
    return entry.sync;
  }

  // ── Not served through the orchestrator ────────────────────────────────────

  @override
  Future<String> getDepositAddress() async =>
      throw UnsupportedError('BitWindow has no FreeBank route for addresses. Paste one from the FreeBank wallet.');

  @override
  Future<String> getSideAddress() async => throw _noRoute('addresses');

  @override
  Future<String> sideSend(String address, double amount, bool subtractFeeFromAmount) async => throw _noRoute('sends');

  @override
  Future<double> sideEstimateFee() async => throw _noRoute('fees');

  @override
  Future<List<SidechainUTXO>> listUTXOs() async => throw _noRoute('coins');

  @override
  Future<List<SidechainUTXO>> listAllUTXOs() async => throw _noRoute('coins');

  @override
  Future<List<CoreTransaction>> listTransactions() async => throw _noRoute('transactions');

  @override
  Future<BmmResult> mine(int feeSats) async => throw _noRoute('mining');

  @override
  Future<PendingWithdrawalBundle?> getPendingWithdrawalBundle() async => throw _noRoute('withdrawal bundles');

  @override
  Future<int?> getLatestFailedWithdrawalBundleHeight() async => throw _noRoute('withdrawal bundles');

  @override
  Future<String> withdraw(String address, int amountSats, int sidechainFeeSats, int mainchainFeeSats) async =>
      throw _noRoute('withdrawals');

  @override
  Future<dynamic> callRAW(String method, [List<dynamic>? params]) async => throw _noRoute('raw calls');

  @override
  List<String> getMethods() => const [];

  UnsupportedError _noRoute(String what) => UnsupportedError('BitWindow has no FreeBank route for $what');
}
