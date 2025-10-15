import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/pages/router.gr.dart' show UnlockWalletRoute;
import 'package:sail_ui/providers/encryption_provider.dart';

/// Guard that checks if wallet is encrypted and locked.
/// If locked, navigates to unlock page before allowing navigation.
class PasswordGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    final encryptionProvider = GetIt.I.get<EncryptionProvider>();

    // Check if wallet is encrypted
    final isEncrypted = await encryptionProvider.isWalletEncrypted();

    // If not encrypted, allow navigation
    if (!isEncrypted) {
      resolver.next(true);
      return;
    }

    // If encrypted but already unlocked, allow navigation
    if (encryptionProvider.isWalletUnlocked) {
      resolver.next(true);
      return;
    }

    // Wallet is encrypted and locked - navigate to unlock page
    await router.push(const UnlockWalletRoute());

    // After returning from unlock page, check if wallet was unlocked
    if (encryptionProvider.isWalletUnlocked) {
      resolver.next(true);
    } else {
      // User didn't unlock, block navigation
      resolver.next(false);
    }
  }
}
