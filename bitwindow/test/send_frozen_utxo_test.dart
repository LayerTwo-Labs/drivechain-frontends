import 'package:bitwindow/pages/wallet/wallet_send.dart';
import 'package:bitwindow/utils/coin_selection.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart';

UnspentOutput coin(String output, int sats) => UnspentOutput(output: output, valueSats: Int64(sats));

String formatSats(int sats) => '$sats sats';

void main() {
  test('a send picks its inputs around a frozen coin', () {
    final frozen = coin('aa:0', 200_000);
    final free = coin('bb:0', 100_000);
    expect(
      SendPageViewModel.unfrozenInputs(
        selected: const [],
        allUtxos: [frozen, free],
        frozenOutpoints: {'aa:0'},
        targetSats: 50_000,
        formatSats: formatSats,
      ),
      [free],
    );
  });

  test('a send with nothing frozen pins no inputs', () {
    expect(
      SendPageViewModel.unfrozenInputs(
        selected: const [],
        allUtxos: [coin('aa:0', 200_000)],
        frozenOutpoints: const {},
        targetSats: 50_000,
        formatSats: formatSats,
      ),
      isEmpty,
    );
  });

  test('a frozen coin the user picked is still spent', () {
    final frozen = coin('aa:0', 200_000);
    expect(
      SendPageViewModel.unfrozenInputs(
        selected: [frozen],
        allUtxos: [frozen, coin('bb:0', 100_000)],
        frozenOutpoints: {'aa:0'},
        targetSats: 50_000,
        formatSats: formatSats,
      ),
      [frozen],
    );
  });

  test('a send the unfrozen coins cannot pay fails instead of thawing one', () {
    expect(
      () => SendPageViewModel.unfrozenInputs(
        selected: const [],
        allUtxos: [coin('aa:0', 200_000), coin('bb:0', 10_000)],
        frozenOutpoints: {'aa:0'},
        targetSats: 50_000,
        formatSats: formatSats,
      ),
      throwsA(isA<InsufficientFundsException>()),
    );
  });
}
