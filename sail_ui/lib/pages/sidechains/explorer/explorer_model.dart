import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:sidechain_core/gen/explorer/v1/explorer.pb.dart' as pb;
import 'package:sidechain_core/sidechain_core.dart';
import 'package:stacked/stacked.dart';

/// How often the overview refreshes. A sidechain block arrives with a
/// mainchain block, so this only has to beat a reader's patience.
const explorerRefreshInterval = Duration(seconds: 3);

/// ExplorerModel reads the chain through the orchestrator. A light client
/// answers from a hosted index, a full node from its own chain.
class ExplorerModel extends BaseViewModel {
  final SidechainRPC _sidechain = GetIt.I.get<SidechainRPC>();
  final OrchestratorRPC _orchestrator = GetIt.I.get<OrchestratorRPC>();

  /// chain is the name the orchestrator keys its configs on.
  String get chain => _sidechain.chain.name.toLowerCase();

  pb.GetOverviewResponse? overview;
  String? readError;

  Timer? _timer;

  ExplorerModel() {
    unawaited(refresh());
    _timer = Timer.periodic(explorerRefreshInterval, (_) => refresh());
  }

  Future<void> refresh() async {
    try {
      final next = await _orchestrator.explorer.getOverview(chain);
      if (overview?.writeToJson() != next.writeToJson()) {
        overview = next;
        readError = null;
        notifyListeners();
      } else if (readError != null) {
        readError = null;
        notifyListeners();
      }
    } catch (e) {
      readError = e.toString();
      notifyListeners();
    }
  }

  Future<pb.GetBlockResponse> block({String? hash, int? height}) {
    return _orchestrator.explorer.getBlock(chain, hash: hash, height: height);
  }

  Future<pb.Transaction> transaction(String txid) {
    return _orchestrator.explorer.getTransaction(chain, txid);
  }

  Future<pb.GetAddressResponse> address(String address) {
    return _orchestrator.explorer.getAddress(chain, address);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// WithdrawalsModel reads the bundle the chain proposes to the mainchain.
class WithdrawalsModel extends BaseViewModel {
  final SidechainRPC _sidechain = GetIt.I.get<SidechainRPC>();
  final OrchestratorRPC _orchestrator = GetIt.I.get<OrchestratorRPC>();

  String get chain => _sidechain.chain.name.toLowerCase();

  pb.GetWithdrawalsResponse? state;
  String? readError;

  Timer? _timer;

  WithdrawalsModel() {
    unawaited(refresh());
    _timer = Timer.periodic(explorerRefreshInterval, (_) => refresh());
  }

  Future<void> refresh() async {
    try {
      final next = await _orchestrator.explorer.getWithdrawals(chain);
      if (state?.writeToJson() != next.writeToJson()) {
        state = next;
        readError = null;
        notifyListeners();
      } else if (readError != null) {
        readError = null;
        notifyListeners();
      }
    } catch (e) {
      readError = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
