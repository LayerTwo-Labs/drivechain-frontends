import 'package:bitwindow/providers/fork_provider.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart' as bwpb;
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

bwpb.UnspentOutput utxo(String output, {bool? splittable}) {
  final u = bwpb.UnspentOutput(output: output, valueSats: Int64(100));
  if (splittable != null) {
    u.splittable = splittable;
  }
  return u;
}

WalletClaim claimWith(List<bwpb.UnspentOutput> utxos, {wmpb.MultisigInfo? multisig}) {
  return WalletClaim(
    walletId: 'w1',
    walletName: 'Main wallet',
    claimableSats: 300,
    replayProtectable: true,
    multisig: multisig,
    utxos: utxos,
  );
}

wmpb.MultisigInfo policy(int m, int n) => wmpb.MultisigInfo(m: m, n: n);

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

  test('a claim without a policy is single-sig', () {
    expect(claimWith([utxo('aa:0')]).isMultisig, isFalse);
  });

  test('a claim with a policy needs cosigner signatures', () {
    final claim = claimWith([utxo('aa:0')], multisig: policy(2, 3));
    expect(claim.isMultisig, isTrue);
    expect(claim.multisig!.m, 2);
    expect(claim.multisig!.n, 3);
  });

  test('a split needs signatures only when every selected claim is multisig', () {
    final single = claimWith([utxo('aa:0')]);
    final multi = claimWith([utxo('bb:0')], multisig: policy(2, 3));
    expect(ForkProvider.splitNeedsSignatures([multi]), isTrue);
    expect(ForkProvider.splitNeedsSignatures([multi, single]), isFalse);
    expect(ForkProvider.splitNeedsSignatures([single]), isFalse);
  });

  test('an empty selection never needs signatures', () {
    expect(ForkProvider.splitNeedsSignatures([]), isFalse);
  });
}
