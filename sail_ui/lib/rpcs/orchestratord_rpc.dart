import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/classes/rpc_connection.dart';
import 'package:sail_ui/config/binaries.dart';
import 'package:sail_ui/rpcs/orchestrator_rpc.dart';

/// RPC connection for the shared orchestrator daemon.
abstract class OrchestratordRPC extends RPCConnection {
  OrchestratordRPC({required super.binaryType, required super.restartOnFailure});
}

class OrchestratordLive extends OrchestratordRPC {
  @override
  final log = GetIt.I.get<Logger>();

  late final OrchestratorRPC _client;

  OrchestratordLive() : super(binaryType: BinaryType.orchestratord, restartOnFailure: false) {
    _client = OrchestratorRPC(host: 'localhost', port: binary.port);
    startConnectionTimer();
  }

  @override
  Future<List<String>> binaryArgs() async {
    return binary.extraBootArgs;
  }

  @override
  Future<void> stopRPC() async {
    try {
      await for (final progress in _client.shutdownAll()) {
        if (progress.done) {
          break;
        }
      }
    } catch (error) {
      // The daemon may tear down the connection before the stream finishes,
      // or it may already be down. Stop() still waits on the PID afterward.
      log.i('orchestratord shutdown RPC finished early: $error');
    }
  }

  @override
  Future<int> ping() async {
    final response = await _client.listBinaries();
    return response.binaries.length;
  }

  @override
  List<String> startupErrors() {
    return [];
  }

  @override
  Future<(double, double)> balance() async {
    return (0.0, 0.0);
  }

  @override
  Future<BlockchainInfo> getBlockchainInfo() async {
    return BlockchainInfo(
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
  }
}
