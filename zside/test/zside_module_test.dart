import 'package:flutter_test/flutter_test.dart';
import 'package:zside/routing/router.dart';
import 'package:zside/zside_module.dart';

void main() {
  test('the transfer page has a tab', () {
    final routes = ZSideModule().tabs.map((tab) => tab.route.routeName);

    expect(routes, contains(ZSideTransferTabRoute.name));
  });
}
