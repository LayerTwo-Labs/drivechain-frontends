import 'package:coinshift/coinshift_module.dart';
import 'package:coinshift/routing/router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the swap analytics page has a tab', () {
    final routes = CoinShiftModule().tabs.map((tab) => tab.route.routeName);

    expect(routes, contains(SwapAnalyticsRoute.name));
  });
}
