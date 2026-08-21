import 'package:bitwindow/providers/fork_provider.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart' as bwpb;

bwpb.UnspentOutput utxo(String output, {bool? splittable}) {
  final u = bwpb.UnspentOutput(output: output, valueSats: Int64(100));
  if (splittable != null) {
    u.splittable = splittable;
  }
  return u;
}

WalletClaim claimWith(List<bwpb.UnspentOutput> utxos) {
  return WalletClaim(
    walletId: 'w1',
    walletName: 'Main wallet',
    claimableSats: 300,
    replayProtectable: true,
    utxos: utxos,
  );
}

void main() {
  test('a coin with unknown BTC status stays selectable', () {
    expect(ForkProvider.isSelectable(utxo('aa:0')), isTrue);
  });

  test('a splittable coin is selectable', () {
    expect(ForkProvider.isSelectable(utxo('aa:0', splittable: true)), isTrue);
  });

  test('a confirmed non-splittable coin is not selectable', () {
    expect(ForkProvider.isSelectable(utxo('aa:0', splittable: false)), isFalse);
  });

  test('default inputs exclude only confirmed non-splittable coins', () {
    final claim = claimWith([
      utxo('unknown:0'),
      utxo('yes:0', splittable: true),
      utxo('no:0', splittable: false),
    ]);
    final outputs = ForkProvider.defaultClaimInputs(claim).map((u) => u.output).toList();
    expect(outputs, ['unknown:0', 'yes:0']);
  });

  test('default inputs keep every coin while nothing is checked', () {
    final claim = claimWith([utxo('aa:0'), utxo('bb:1')]);
    expect(ForkProvider.defaultClaimInputs(claim).length, 2);
  });

  test('minClaimSats keeps the post-fee output above dust', () {
    expect(ForkProvider.minClaimSats(1), 766);
    expect(ForkProvider.minClaimSats(4), 976);
  });

  test('hasSelectableCoins is false when every coin is non-splittable', () {
    final provider = ForkProvider();
    provider.claims = [
      claimWith([utxo('aa:0', splittable: false), utxo('bb:1', splittable: false)]),
    ];
    expect(provider.hasSelectableCoins, isFalse);

    provider.claims = [
      claimWith([utxo('aa:0', splittable: false), utxo('bb:1')]),
    ];
    expect(provider.hasSelectableCoins, isTrue);
  });
}
