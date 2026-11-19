import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/pages/root_page.dart';
import 'package:bitwindow/pages/wallet/wallet_page.dart';
import 'package:bitwindow/routing/router.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

class _Router extends AppRouter {
  final navigated = <String>[];

  @override
  Future<dynamic> navigate(PageRouteInfo route, {OnNavigationFailure? onFailure}) async {
    navigated.add(route.routeName);
  }
}

void main() {
  tearDown(() => GetIt.I.reset());

  testWidgets('a menu tab of the wallet waits for a wallet page that never built', (tester) async {
    final router = _Router();
    GetIt.I.registerSingleton<AppRouter>(router);
    expect(WalletPage.tabKey.currentState, isNull);

    openWalletSubtab('Send');

    expect(router.navigated, [WalletRoute.name]);
    expect(WalletPage.pendingSubtab, 'Send');
  });
}
