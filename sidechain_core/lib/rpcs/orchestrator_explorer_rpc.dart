import 'package:connectrpc/protocol/connect.dart' as connect;
import 'package:sidechain_core/gen/explorer/v1/explorer.connect.client.dart';
import 'package:sidechain_core/gen/explorer/v1/explorer.pb.dart' as pb;

/// The block explorer, served by the orchestrator's ExplorerService.
///
/// A light client reads a hosted index. A full node answers from its own
/// chain, and a node keeps no address history, so [getAddress] needs an index.
class OrchestratorExplorerRPC {
  late ExplorerServiceClient _client;

  OrchestratorExplorerRPC.fromTransport(connect.Transport unary) {
    _client = ExplorerServiceClient(unary);
  }

  /// The newest blocks, what happened last, and what the treasury holds.
  Future<pb.GetOverviewResponse> getOverview(String chain) async {
    return await _client.getOverview(pb.GetOverviewRequest(chain: chain));
  }

  /// One block and what it carried. Name a hash or a height.
  Future<pb.GetBlockResponse> getBlock(String chain, {String? hash, int? height}) async {
    return await _client.getBlock(
      pb.GetBlockRequest(chain: chain, hash: hash ?? '', height: height ?? 0),
    );
  }

  /// One transaction, with the coins on both sides.
  Future<pb.Transaction> getTransaction(String chain, String txid) async {
    final response = await _client.getTransaction(
      pb.GetTransactionRequest(chain: chain, txid: txid),
    );
    return response.transaction;
  }

  /// What an address holds and what it did.
  Future<pb.GetAddressResponse> getAddress(String chain, String address) async {
    return await _client.getAddress(pb.GetAddressRequest(chain: chain, address: address));
  }

  /// The bundle the chain proposes to the mainchain.
  Future<pb.GetWithdrawalsResponse> getWithdrawals(String chain) async {
    return await _client.getWithdrawals(pb.GetWithdrawalsRequest(chain: chain));
  }
}
