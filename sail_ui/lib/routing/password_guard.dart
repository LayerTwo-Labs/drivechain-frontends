import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/pages/router.gr.dart' show UnlockWalletRoute;
import 'package:sail_ui/providers/wallet_reader_provider.dart';

/// Guard that checks if wallet is unlocked.
/// If locked, navigates to unlock page before allowing navigation.
/// isWalletUnlocked is true for both unencrypted wallets and unlocked encrypted wallets.
class PasswordGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    final walletReader = GetIt.I.get<WalletReaderProvider>();

    if (walletReader.isWalletUnlocked) {
      resolver.next(true);
      return;
    }

    await router.push(UnlockWalletRoute());

    if (walletReader.isWalletUnlocked) {
      resolver.next(true);
    } else {
      resolver.next(false);
    }
  }
}
