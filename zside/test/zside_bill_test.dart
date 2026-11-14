import 'package:flutter_test/flutter_test.dart';
import 'package:zside/pages/tabs/zside/zside_bill_page.dart';

void main() {
  test('a bill below 1 BTC shows in sats', () {
    expect(billAmountLabel(1), '1');
    expect(billAmountLabel(1024), '1 024');
    expect(billAmountLabel(1 << 17), '131 072');
    expect(billAmountLabel(1 << 26), '67 108 864');
  });

  test('a bill from 1 BTC up shows in BTC with spaced decimals', () {
    expect(billAmountLabel(1 << 27), '1.34 217 728');
    expect(billAmountLabel(1 << 30), '10.73 741 824');
    expect(billAmountLabel(1 << 41), '21 990.23 255 552');
  });
}
