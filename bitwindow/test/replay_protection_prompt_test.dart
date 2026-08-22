import 'package:bitwindow/pages/wallet/wallet_send.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart';

UnspentOutput coin(String output, {bool? splittable}) {
  final u = UnspentOutput(output: output, valueSats: Int64(100_000));
  if (splittable != null) {
    u.splittable = splittable;
  }
  return u;
}

void main() {
  test('a coin the split engine never checked raises no prompt', () {
    expect(SendPageViewModel.splittableAmong([], [coin('aa:0')]), isEmpty);
  });

  test('a coin that exists on both chains raises the prompt', () {
    final both = coin('aa:0', splittable: true);
    expect(SendPageViewModel.splittableAmong([], [both]), [both]);
  });

  test('a coin that exists on one chain only raises no prompt', () {
    expect(SendPageViewModel.splittableAmong([], [coin('aa:0', splittable: false)]), isEmpty);
  });

  test('a selection hides the coins it leaves behind', () {
    final picked = coin('aa:0');
    final other = coin('bb:0', splittable: true);
    expect(SendPageViewModel.splittableAmong([picked], [picked, other]), isEmpty);
  });

  test('a selection of both-chain coins raises the prompt', () {
    final picked = coin('aa:0', splittable: true);
    expect(SendPageViewModel.splittableAmong([picked], [picked, coin('bb:0')]), [picked]);
  });
}
