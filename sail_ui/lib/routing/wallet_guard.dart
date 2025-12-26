import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/providers/wallet_reader_provider.dart';

/// Guard that checks if a wallet exists.
/// If no wallet exists, navigates to wallet creation page.
///
/// This guard allows sidechains to boot standalone without BitWindow.
/// If the wallet doesn't exist, the user is redirected to create one.
class WalletGuard extends AutoRouteGuard {
  /// Factory function that creates the wallet creation route.
  /// Each app provides its own route (e.g., SailCreateWalletRoute()).
  final PageRouteInfo Function() createWalletRoute;

  WalletGuard({required this.createWalletRoute});

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    final walletReader = GetIt.I.get<WalletReaderProvider>();

    // Check if wallet file exists
    final walletFile = walletReader.getWalletFile();
    final walletExists = await walletFile.exists();

    if (walletExists) {
      // Wallet exists, allow navigation
      resolver.next(true);
      return;
    }

    // No wallet - redirect to wallet creation
    await router.push(createWalletRoute());

    // After wallet creation, check if wallet now exists
    final walletNowExists = await walletFile.exists();
    resolver.next(walletNowExists);
  }
}
