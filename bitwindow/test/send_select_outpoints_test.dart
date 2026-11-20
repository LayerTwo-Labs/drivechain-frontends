import 'package:bitwindow/pages/wallet/wallet_send.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart';

void main() {
  final a = UnspentOutput(output: 'aa:0', valueSats: Int64(1000));
  final b = UnspentOutput(output: 'bb:1', valueSats: Int64(2000));
  final c = UnspentOutput(output: 'cc:0', valueSats: Int64(3000));

  test('the send form takes the coins of a chart bucket', () {
    expect(SendPageViewModel.coinsAt([a, b, c], ['cc:0', 'aa:0']), [a, c]);
  });

  test('the send form leaves out a bucket coin it cannot spend', () {
    expect(SendPageViewModel.coinsAt([a, c], ['aa:0', 'bb:1']), [a]);
  });
}
