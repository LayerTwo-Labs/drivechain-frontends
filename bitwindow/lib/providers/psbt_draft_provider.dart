import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:protobuf/protobuf.dart';
import 'package:sidechain_core/gen/walletpsbt/v1/walletpsbt.pb.dart';
import 'package:sail_ui/sail_ui.dart';

/// Signing progress for one draft, derived from the orchestrator.
class DraftSigningStatus {
  final int threshold;
  final int signatures;
  final bool finalizable;
  final List<bool> cosignerSigned;

  const DraftSigningStatus({
    required this.threshold,
    required this.signatures,
    required this.finalizable,
    required this.cosignerSigned,
  });
}

/// Holds the open PSBT drafts for the active wallet. Every change goes
/// through SaveDraft at once, so a crash between two signatures loses
/// nothing. Signing progress is derived from the PSBT, never stored.
class PsbtDraftProvider extends ChangeNotifier implements NetworkScoped {
  WalletPsbtAPI get _api => GetIt.I.get<BitwindowRPC>().walletpsbt;
  WalletReaderProvider get _walletReader => GetIt.I.get<WalletReaderProvider>();
  OrchestratorWalletRPC get _orchestratorWallet => GetIt.I.get<OrchestratorRPC>().wallet;

  List<PsbtDraft> drafts = [];
  final Map<String, DraftSigningStatus> statuses = {};
  String? modelError;

  String? _walletId;

  // Increments on a network swap, so a response from the old network's
  // daemon never lands in the new network's state.
  int _generation = 0;

  /// Callers capture this token before a slow build, and the create path
  /// rejects the result when a network swap happened in between.
  int get generation => _generation;

  // Drafts with a broadcast in flight; deletion is blocked for these.
  final Set<String> _broadcastPending = {};

  // One retry timer per draft after a failed status read, so a transient
  // daemon error cannot leave a finalizable draft stuck as unsigned.
  final Map<String, Timer> _statusRetries = {};

  // Retry for a failed list fetch: at a cold start the daemon can still be
  // down, and no wallet notification comes later to trigger a reload.
  Timer? _fetchRetry;

  // One write chain per draft; see _serializedSave.
  final Map<String, Future<void>> _writeQueues = {};

  // Tombstones for deleted drafts: a signing result that lands after the
  // delete must not upsert the row back.
  final Set<String> _deleted = {};

  bool isBroadcastPending(String id) => _broadcastPending.contains(id);

  void setBroadcastPending(String id, bool pending) {
    if (pending) {
      _broadcastPending.add(id);
    } else {
      _broadcastPending.remove(id);
    }
    notifyListeners();
  }

  PsbtDraftProvider() {
    _walletReader.addListener(_onWalletChanged);
    unawaited(fetch());
  }

  Future<void> fetch() async {
    _fetchRetry?.cancel();
    _fetchRetry = null;
    final walletId = _walletReader.activeWalletId;
    if (_walletId != walletId) {
      // Another wallet's drafts must never render under this wallet's id —
      // clear at once, before the list request completes or fails.
      _clearWalletState();
      notifyListeners();
    }
    _walletId = walletId;
    if (walletId == null) {
      return;
    }

    final generation = _generation;
    try {
      final loaded = await _api.listDrafts(walletId);
      if (_walletId != walletId || _generation != generation) {
        return;
      }
      drafts = loaded;
      modelError = null;
      notifyListeners();
      await _refreshStatuses(walletId);
    } catch (e) {
      // A late failure from a superseded wallet or network must not
      // overwrite the current wallet's state.
      if (_walletId != walletId || _generation != generation) {
        return;
      }
      modelError = e.toString();
      notifyListeners();
      _fetchRetry?.cancel();
      _fetchRetry = Timer(const Duration(seconds: 10), () {
        _fetchRetry = null;
        unawaited(fetch());
      });
    }
  }

  void _clearWalletState() {
    drafts = [];
    statuses.clear();
    _broadcastPending.clear();
    for (final t in _statusRetries.values) {
      t.cancel();
    }
    _statusRetries.clear();
    _writeQueues.clear();
    _deleted.clear();
  }

  /// Saves a new draft and returns it with its server-generated id.
  /// [walletId] binds the draft to the wallet the PSBT was built for, so a
  /// wallet switch mid-build cannot file it under the wrong wallet. A
  /// network swap during the save voids the result.
  Future<PsbtDraft> create(String psbtBase64, {required String walletId}) async {
    final gen = _generation;
    final saved = await _api.saveDraft(PsbtDraft(walletId: walletId, psbtBase64: psbtBase64));
    if (_generation != gen) {
      throw Exception('The network changed during the save. Create the transaction again.');
    }
    if (_walletId == walletId) {
      drafts = [...drafts, saved];
      notifyListeners();
      unawaited(_refreshStatus(walletId, saved));
    }
    return saved;
  }

  /// Merges a newly signed PSBT into the draft. Two overlapped sign
  /// operations can start from the same base PSBT; a combine keeps the
  /// union of their signatures instead of the last write alone.
  Future<PsbtDraft> updatePsbt(String id, String psbtBase64) async {
    final saved = await _serializedSave(id, (d) async {
      if (d.psbtBase64 != psbtBase64) {
        d.psbtBase64 = await _orchestratorWallet.combinePsbt(psbtsBase64: [d.psbtBase64, psbtBase64]);
      }
    });
    unawaited(_refreshStatus(saved.walletId, saved));
    return saved;
  }

  Future<void> rename(String id, String label) async {
    await _serializedSave(id, (d) async => d.label = label);
  }

  Future<void> setTxid(String id, String txid) async {
    await _serializedSave(id, (d) async => d.txid = txid);
  }

  /// Store.Save replaces the whole record, so overlapped writes must run one
  /// at a time, each against the latest local state — otherwise a delayed
  /// rename can erase a fresh signature or a txid. A delete or a network
  /// swap voids every write still in the queue.
  Future<PsbtDraft> _serializedSave(String id, Future<void> Function(PsbtDraft) mutate) {
    final generation = _generation;
    final prev = _writeQueues[id] ?? Future<void>.value();
    final next = prev.then((_) async {
      _checkWriteStillValid(id, generation);
      final draft = _byId(id).deepCopy();
      await mutate(draft);
      _checkWriteStillValid(id, generation);
      final saved = await _api.saveDraft(draft);
      _replace(saved);
      return saved;
    });
    _writeQueues[id] = next.then<void>((_) {}, onError: (_) {});
    return next;
  }

  void _checkWriteStillValid(String id, int generation) {
    if (_deleted.contains(id)) {
      throw StateError('The transaction was deleted. The change was not saved.');
    }
    if (_generation != generation) {
      throw StateError('The network changed. The change was not saved.');
    }
  }

  Future<void> delete(String id) async {
    // The tombstone voids a signing result that lands after this point, and
    // the queue await lets an already-captured write finish first. The
    // stored chain never throws; see _serializedSave.
    _deleted.add(id);
    try {
      await (_writeQueues.remove(id) ?? Future<void>.value());
      await _api.deleteDraft(id);
    } catch (e) {
      _deleted.remove(id);
      rethrow;
    }
    drafts = drafts.where((d) => d.id != id).toList();
    statuses.remove(id);
    _statusRetries.remove(id)?.cancel();
    notifyListeners();
  }

  DraftSigningStatus? statusFor(String id) => statuses[id];

  PsbtDraft _byId(String id) => drafts.firstWhere((d) => d.id == id);

  PsbtDraft? _currentDraft(String id) {
    for (final d in drafts) {
      if (d.id == id) {
        return d;
      }
    }
    return null;
  }

  void _replace(PsbtDraft saved) {
    drafts = drafts.map((d) => d.id == saved.id ? saved : d).toList();
    notifyListeners();
  }

  Future<void> _refreshStatuses(String walletId) async {
    for (final draft in List.of(drafts)) {
      await _refreshStatus(walletId, draft);
    }
  }

  Future<void> _refreshStatus(String walletId, PsbtDraft draft) async {
    if (draft.txid.isNotEmpty) {
      return;
    }
    final generation = _generation;
    try {
      final s = await _orchestratorWallet.multisigPsbtStatus(
        walletId: walletId,
        psbtBase64: draft.psbtBase64,
      );
      // A slow response for an older PSBT must not overwrite the status of a
      // newer signature — drop it unless the draft still holds this PSBT.
      final current = _currentDraft(draft.id);
      if (_walletId != walletId ||
          _generation != generation ||
          current == null ||
          current.psbtBase64 != draft.psbtBase64) {
        return;
      }
      statuses[draft.id] = DraftSigningStatus(
        threshold: s.threshold,
        signatures: s.signatures,
        finalizable: s.finalizable,
        cosignerSigned: s.cosignerSigned,
      );
      modelError = null;
      _statusRetries.remove(draft.id)?.cancel();
      notifyListeners();
    } catch (e) {
      if (_walletId != walletId || _generation != generation) {
        return;
      }
      modelError = 'Failed to read signing status: $e';
      notifyListeners();
      _statusRetries[draft.id]?.cancel();
      _statusRetries[draft.id] = Timer(const Duration(seconds: 10), () {
        _statusRetries.remove(draft.id);
        final current = _currentDraft(draft.id);
        final retryWalletId = _walletId;
        if (current == null || retryWalletId == null) {
          return;
        }
        unawaited(_refreshStatus(retryWalletId, current));
      });
    }
  }

  void _onWalletChanged() {
    if (_walletReader.activeWalletId != _walletId) {
      unawaited(fetch());
    }
  }

  @override
  Future<void> onNetworkChanged() async {
    _generation++;
    _walletId = null;
    _clearWalletState();
    modelError = null;
    notifyListeners();
    // The wallet reader can reseed the active wallet before this clear runs,
    // and its notification then never fires again — reload here as well.
    await fetch();
  }

  @override
  void dispose() {
    _walletReader.removeListener(_onWalletChanged);
    for (final t in _statusRetries.values) {
      t.cancel();
    }
    _fetchRetry?.cancel();
    super.dispose();
  }
}
