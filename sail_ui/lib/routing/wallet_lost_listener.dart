import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/providers/wallet_reader_provider.dart';

/// Watches WalletReaderProvider.hasWalletOnDisk and invokes
/// [onWalletLost] when it transitions `true -> false`. WalletGuard
/// (an AutoRouteGuard) only fires on navigation, so a user sitting on
/// the Overview page while someone manually deletes wallet.json would
/// never be prompted. This listener closes that gap.
///
/// The caller owns routing — [onWalletLost] typically reaches the app's
/// root router via GetIt (e.g. `GetIt.I.get<AppRouter>().replaceAll(...)`).
/// Routing through `AutoRouter.of(context)` is unsafe here because this
/// widget is wrapped in `MaterialApp.router`'s `builder`, where the
/// AutoRouter sits *below* (in `child`), not above — so the lookup
/// throws.
class WalletLostListener extends StatefulWidget {
  final Widget child;

  /// Invoked when wallet.json transitions from present to absent.
  /// Called from the listener callback, not during build.
  final void Function() onWalletLost;

  const WalletLostListener({
    super.key,
    required this.child,
    required this.onWalletLost,
  });

  @override
  State<WalletLostListener> createState() => _WalletLostListenerState();
}

class _WalletLostListenerState extends State<WalletLostListener> {
  late final WalletReaderProvider _walletReader;
  late final Logger _log;

  bool _lastHasWallet = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _walletReader = GetIt.I.get<WalletReaderProvider>();
    _log = GetIt.I.get<Logger>();
    _lastHasWallet = _walletReader.hasWalletOnDisk;
    _walletReader.addListener(_onWalletChanged);
  }

  @override
  void dispose() {
    _walletReader.removeListener(_onWalletChanged);
    super.dispose();
  }

  void _onWalletChanged() {
    final now = _walletReader.hasWalletOnDisk;

    // First stream delivery arrives with the real state; don't route on it.
    if (!_initialized) {
      _initialized = true;
      _lastHasWallet = now;
      return;
    }

    final lost = _lastHasWallet && !now;
    _lastHasWallet = now;

    if (!lost) return;
    if (!mounted) return;

    _log.w('WalletLostListener: wallet.json disappeared, invoking onWalletLost');
    widget.onWalletLost();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
