import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/providers/wallet_reader_provider.dart';

/// Watches WalletReaderProvider.hasWalletOnDisk and pushes the
/// create-wallet route when it transitions `true -> false`. Mid-session
/// WalletGuard (an AutoRouteGuard) only fires on navigation, so a user
/// sitting on the Overview page while someone manually deletes
/// wallet.json would never be prompted. This listener closes that gap.
///
/// Placement: wrap the child that lives *inside* `MaterialApp.router`
/// (typically the app shell beneath AutoRouter), so AutoRouter.of(context)
/// resolves to the app's root router.
class WalletLostListener extends StatefulWidget {
  final Widget child;

  /// Factory for the create-wallet route — same contract as WalletGuard.
  final PageRouteInfo Function() createWalletRoute;

  const WalletLostListener({
    super.key,
    required this.child,
    required this.createWalletRoute,
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

    _log.w('WalletLostListener: wallet.json disappeared, routing to create-wallet');
    // replaceAll so the user can't back-button into a dead Overview page
    // against an enforcer that refuses to boot without an L1 seed.
    AutoRouter.of(context).replaceAll([widget.createWalletRoute()]);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
