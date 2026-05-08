import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sail_ui/rpcs/orchestrator_rpc.dart';

/// Surfaces the orchestrator's Bitcoin Core variant picker.
///
/// The backend filters by current network (and returns an empty list on
/// mainnet), so the provider is intentionally dumb — it forwards calls and
/// caches the latest list/active value.
class CoreVariantProvider extends ChangeNotifier {
  final Logger _logger = GetIt.I.get<Logger>();
  OrchestratorRPC get _orch => GetIt.I.get<OrchestratorRPC>();

  List<wmpb.CoreVariant> _variants = const [];
  String _activeId = '';
  bool _busy = false;
  String? _lastError;

  List<wmpb.CoreVariant> get variants => _variants;
  String get activeId => _activeId;
  bool get busy => _busy;
  String? get lastError => _lastError;

  /// True when the picker should be visible. Backend hides it on mainnet by
  /// returning an empty list.
  bool get isVisible => _variants.isNotEmpty;

  CoreVariantProvider() {
    refresh();
  }

  Future<void> refresh() async {
    try {
      final resp = await _orch.wallet.listCoreVariants();
      _variants = resp.variants;
      _activeId = resolveActiveId(
        reportedActiveId: resp.activeId,
        visibleIds: _variants.map((v) => v.id),
      );
      _lastError = null;
      notifyListeners();
    } catch (e) {
      _logger.e('CoreVariantProvider: list failed: $e');
      _lastError = e.toString();
      notifyListeners();
    }
  }

  /// Clamps the orchestrator-reported active id to something the dropdown
  /// can actually render. A persisted id from another network would feed
  /// SailDropdownButton a value not in its items list and trigger an
  /// assertion; an empty reported id leaves the dropdown blank. In both
  /// cases we fall back to the first visible variant when one exists.
  static String resolveActiveId({
    required String reportedActiveId,
    required Iterable<String> visibleIds,
  }) {
    final ids = visibleIds.toList();
    if (ids.contains(reportedActiveId)) return reportedActiveId;
    return ids.isEmpty ? '' : ids.first;
  }

  /// Switches the active Core variant via the orchestrator. Stops bitcoind,
  /// downloads the new build if needed, and restarts. Errors are absorbed
  /// into [lastError]; UI surfaces them via [notifyListeners].
  Future<void> setVariant(String id) async {
    if (_busy) return;
    _busy = true;
    _lastError = null;
    notifyListeners();
    try {
      await _orch.wallet.setCoreVariant(id);
      await refresh();
    } catch (e) {
      _logger.e('CoreVariantProvider: set $id failed: $e');
      _lastError = e.toString();
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
