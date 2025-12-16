import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/pages/router.gr.dart' show UnlockWalletRoute;
import 'package:sail_ui/providers/wallet_reader_provider.dart';

/// Guard that checks if wallet is unlocked.
/// If locked, navigates to unlock page before allowing navigation.
/// isWalletUnlocked is true for both unencrypted wallets and unlocked encrypted wallets.
///
/// Only redirects to unlock page if wallet is actually encrypted.
/// If wallet file exists but is not encrypted (e.g. empty wallet.json),
/// allows navigation through so WalletGuard can handle wallet creation.
class PasswordGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    final walletReader = GetIt.I.get<WalletReaderProvider>();

    // If wallet is already unlocked (has wallets loaded), allow through
    if (walletReader.isWalletUnlocked) {
      resolver.next(true);
      return;
    }

    // Check if wallet is actually encrypted
    // If not encrypted, there's nothing to unlock - allow through
    // WalletGuard will handle redirecting to wallet creation if needed
    final isEncrypted = await walletReader.isWalletEncrypted();
    if (!isEncrypted) {
      resolver.next(true);
      return;
    }

    // Wallet is encrypted but locked - show unlock page
    await router.push(UnlockWalletRoute());

    if (walletReader.isWalletUnlocked) {
      resolver.next(true);
    } else {
      resolver.next(false);
    }
  }
}
