import 'package:connectrpc/protocol/connect.dart' as connect;
import 'package:sidechain_core/gen/stratum/v1/stratum.connect.client.dart';
import 'package:sidechain_core/gen/stratum/v1/stratum.pb.dart' as stratumpb;
import 'package:sidechain_core/gen/stratum/v1/stratum.pbenum.dart';

/// The Stratum server for ASIC miners, served by the orchestrator's
/// StratumService. The server runs in the backend with no client attached.
class OrchestratorStratumRPC {
  late StratumServiceClient _client;

  OrchestratorStratumRPC.fromTransport(connect.Transport unary) {
    _client = StratumServiceClient(unary);
  }

  Future<void> start({int port = 0}) async {
    await _client.startStratum(stratumpb.StartStratumRequest(port: port));
  }

  Future<void> stop() async {
    await _client.stopStratum(stratumpb.StopStratumRequest());
  }

  Future<stratumpb.GetStratumStatusResponse> status() {
    return _client.getStratumStatus(stratumpb.GetStratumStatusRequest());
  }

  Future<void> setTarget(stratumpb.Target target) async {
    await _client.setTarget(stratumpb.SetTargetRequest(target: target));
  }

  Future<List<stratumpb.CatalogPool>> listPools() async {
    final resp = await _client.listTargets(stratumpb.ListTargetsRequest());
    return resp.pools;
  }

  Future<void> setWorkMode(String address, WorkMode mode) async {
    await _client.setWorkMode(stratumpb.SetWorkModeRequest(address: address, mode: mode));
  }

  Future<void> setMiningSettings({int? port, bool? cpuMining, int? cpuThreads, bool? keepMiningOnClose}) async {
    await _client.setMiningSettings(
      stratumpb.SetMiningSettingsRequest(
        port: port,
        cpuMining: cpuMining,
        cpuThreads: cpuThreads,
        keepMiningOnClose: keepMiningOnClose,
      ),
    );
  }

  Future<stratumpb.GetHashrateHistoryResponse> hashrateHistory(HashrateRange range) {
    return _client.getHashrateHistory(stratumpb.GetHashrateHistoryRequest(range: range));
  }

  Future<stratumpb.ListPoolBlocksResponse> listPoolBlocks({int limit = 0}) {
    return _client.listPoolBlocks(stratumpb.ListPoolBlocksRequest(limit: limit));
  }
}
