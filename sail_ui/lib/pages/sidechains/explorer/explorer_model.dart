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

  /// chain is the key the orchestrator files this chain under.
  String get chain => _sidechain.chain.registryKey;

  pb.GetOverviewResponse? overview;
  String? readError;

  /// olderBlocks holds the pages a reader scrolled back to. The overview keeps
  /// the newest blocks, and these continue below them.
  final List<pb.Block> olderBlocks = [];

  Timer? _timer;

  /// _reading holds one read at a time. A slow answer must not land on top of
  /// a newer one.
  bool _reading = false;
  bool _readingOlder = false;
  bool _reachedGenesis = false;

  /// blocks are the newest blocks, then every page a reader scrolled back to.
  List<pb.Block> get blocks => [...?overview?.blocks, ...olderBlocks];

  /// reachedGenesis is true when no block sits below the last page.
  bool get reachedGenesis => _reachedGenesis;

  /// _trimOlderBlocks drops every cached page that no longer continues the
  /// newest blocks. A new block, or a reorg, breaks that boundary, and the
  /// pages below it read again.
  void _trimOlderBlocks(List<pb.Block> head) {
    if (head.isEmpty) {
      return;
    }
    var next = head.last.height - 1;
    final keep = <pb.Block>[];
    for (final block in olderBlocks) {
      if (block.height != next) {
        break;
      }
      keep.add(block);
      next--;
    }
    olderBlocks
      ..clear()
      ..addAll(keep);
    final last = keep.isNotEmpty ? keep.last : head.last;
    _reachedGenesis = last.height == 0;
  }

  /// loadOlderBlocks reads the page below the last block a reader can see.
  Future<void> loadOlderBlocks() async {
    if (_readingOlder || _reachedGenesis) {
      return;
    }
    final seen = blocks;
    if (seen.isEmpty || seen.last.height == 0) {
      _reachedGenesis = true;
      return;
    }
    _readingOlder = true;
    try {
      final page = await _orchestrator.explorer.listBlocks(
        chain,
        beforeHeight: seen.last.height - 1,
      );
      if (page.isEmpty) {
        _reachedGenesis = true;
      } else {
        olderBlocks.addAll(page);
        _reachedGenesis = page.last.height == 0;
      }
      notifyListeners();
    } catch (e) {
      readError = e.toString();
      notifyListeners();
    } finally {
      _readingOlder = false;
    }
  }

  ExplorerModel() {
    unawaited(refresh());
    _timer = Timer.periodic(explorerRefreshInterval, (_) => refresh());
  }

  Future<void> refresh() async {
    if (_reading) {
      return;
    }
    _reading = true;
    try {
      final next = await _orchestrator.explorer.getOverview(chain);
      if (overview?.writeToJson() != next.writeToJson()) {
        overview = next;
        _trimOlderBlocks(next.blocks);
        readError = null;
        notifyListeners();
      } else if (readError != null) {
        readError = null;
        notifyListeners();
      }
    } catch (e) {
      readError = e.toString();
      notifyListeners();
    } finally {
      _reading = false;
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

  String get chain => _sidechain.chain.registryKey;

  pb.GetWithdrawalsResponse? state;
  String? readError;

  Timer? _timer;

  /// _reading holds one read at a time. A slow answer must not land on top of
  /// a newer one.
  bool _reading = false;

  WithdrawalsModel() {
    unawaited(refresh());
    _timer = Timer.periodic(explorerRefreshInterval, (_) => refresh());
  }

  Future<void> refresh() async {
    if (_reading) {
      return;
    }
    _reading = true;
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
    } finally {
      _reading = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
