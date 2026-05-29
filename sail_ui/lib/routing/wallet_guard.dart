import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/providers/wallet_reader_provider.dart';

typedef CreateWalletRoute = PageRouteInfo Function(VoidCallback onWalletCreated);

/// Guard that checks if a wallet exists.
/// If no wallet exists, navigates to wallet creation page.
///
/// This guard allows sidechains to boot standalone without BitWindow.
/// If the wallet doesn't exist, the user is redirected to create one.
class WalletGuard extends AutoRouteGuard {
  /// Factory function that creates the wallet creation route.
  /// Each app provides its own route (e.g., SailCreateWalletRoute()).
  final CreateWalletRoute createWalletRoute;

  WalletGuard({required this.createWalletRoute});

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    final walletReader = GetIt.I.get<WalletReaderProvider>();

    final walletExists = await walletReader.hasWallet();

    if (walletExists) {
      resolver.next(true);
      return;
    }

    void resumeAfterWalletCreation() {
      if (resolver.isResolved) return;
      unawaited(() async {
        final walletNowExists = await walletReader.hasWallet();
        if (!resolver.isResolved) {
          resolver.next(walletNowExists);
        }
      }());
    }

    // No wallet - redirect to wallet creation while the guarded route stays
    // suspended. The route's success action resolves this guard directly.
    resolver.redirectUntil(createWalletRoute(resumeAfterWalletCreation));
  }
}
