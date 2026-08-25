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
    multisig: multisig,
    utxos: utxos,
  );
}

wmpb.MultisigInfo policy(int m, int n) => wmpb.MultisigInfo(m: m, n: n);

void main() {
  _dismissalTests();

  _oneWalletActionTests();

  _claimsForWalletTests();

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

  test('a coin inside a pending split draft leaves the selection', () {
    final provider = ForkProvider();
    final claim = claimWith([utxo('aa:0'), utxo('bb:1')], multisig: policy(2, 3));
    provider.claims = [claim];
    expect(provider.selectableInputs(claim).length, 2);

    provider.pendingSplits = [
      PendingSplit(walletId: 'w1', draftId: 'd1', outpoints: {'aa:0'}),
    ];
    expect(provider.canSelect(claim, utxo('aa:0')), isFalse);
    expect(provider.selectableInputs(claim).map((u) => u.output), ['bb:1']);
  });

  test('a wallet whose coins all wait for signatures offers no claim', () {
    final provider = ForkProvider();
    provider.claims = [
      claimWith([utxo('aa:0')], multisig: policy(2, 3)),
    ];
    expect(provider.hasSelectableCoins, isTrue);

    provider.pendingSplits = [
      PendingSplit(walletId: 'w1', draftId: 'd1', outpoints: {'aa:0'}),
    ];
    expect(provider.hasSelectableCoins, isFalse);
  });

  test('a live draft keeps holding the coins it spends', () {
    final pending = [
      PendingSplit(walletId: 'w1', draftId: 'd1', outpoints: {'aa:0'}),
    ];
    expect(ForkProvider.keepLivePendingSplits(pending, {'d1'}, {}, {'d1'}).length, 1);
  });

  test('a discarded draft releases the coins it held', () {
    final pending = [
      PendingSplit(walletId: 'w1', draftId: 'd1', outpoints: {'aa:0'}),
    ];
    expect(ForkProvider.keepLivePendingSplits(pending, {}, {}, {'d1'}), isEmpty);
  });

  test('a wallet that answers nothing keeps its coins held', () {
    final pending = [
      PendingSplit(walletId: 'w2', draftId: 'd2', outpoints: {'bb:1'}),
    ];
    expect(ForkProvider.keepLivePendingSplits(pending, {}, {'w2'}, {'d2'}).length, 1);
  });

  test('a wallet with unread drafts offers no coin', () {
    final provider = ForkProvider();
    final claim = claimWith([utxo('aa:0')], multisig: policy(2, 3));
    provider.claims = [claim];
    expect(provider.hasSelectableCoins, isTrue);

    provider.walletsWithUnreadDrafts = {'w1'};
    expect(provider.canSelect(claim, utxo('aa:0')), isFalse);
    expect(provider.hasSelectableCoins, isFalse);
  });

  test('a claim whose wallet record is missing offers no sweep', () {
    final provider = ForkProvider();
    provider.claims = [
      WalletClaim(
        walletId: 'w1',
        walletName: 'Main wallet',
        claimableSats: 300,
        walletResolved: false,
        utxos: [utxo('aa:0')],
      ),
    ];
    expect(provider.sweepableClaims, isEmpty);
  });

  test('a split saved while the read ran keeps its coins', () {
    final pending = [
      PendingSplit(walletId: 'w1', draftId: 'new', outpoints: {'aa:0'}),
    ];
    expect(ForkProvider.keepLivePendingSplits(pending, {}, {}, {}).length, 1);
  });
}

void _claimsForWalletTests() {
  test('claimsForWallet returns only the open wallet', () {
    final fork = ForkProvider();
    fork.claims = [
      WalletClaim(walletId: 'open', walletName: 'Open', claimableSats: 100, utxos: [utxo('a:0')]),
      WalletClaim(walletId: 'other', walletName: 'Other', claimableSats: 100, utxos: [utxo('b:0')]),
    ];

    expect(fork.claimsForWallet('open').map((c) => c.walletId), ['open']);
    expect(fork.claimsForWallet('other').map((c) => c.walletId), ['other']);
  });

  test('claimsForWallet is empty without an open wallet', () {
    final fork = ForkProvider();
    fork.claims = [
      WalletClaim(walletId: 'open', walletName: 'Open', claimableSats: 100, utxos: [utxo('a:0')]),
    ];

    expect(fork.claimsForWallet(null), isEmpty);
  });

  test('a wallet whose coins are all unselectable drops out', () {
    final fork = ForkProvider();
    fork.claims = [
      WalletClaim(walletId: 'spent', walletName: 'Spent', claimableSats: 100, utxos: [utxo('a:0', splittable: false)]),
    ];

    expect(fork.claimsForWallet('spent'), isEmpty);
    expect(fork.walletsWithClaims, isEmpty);
  });

  test('walletsWithClaims names every wallet the picker must mark', () {
    final fork = ForkProvider();
    fork.claims = [
      WalletClaim(walletId: 'one', walletName: 'One', claimableSats: 100, utxos: [utxo('a:0')]),
      WalletClaim(walletId: 'two', walletName: 'Two', claimableSats: 100, utxos: [utxo('b:0')]),
    ];

    expect(fork.walletsWithClaims, {'one', 'two'});
  });
}

void _oneWalletActionTests() {
  // The card acts for the wallet the user has open. A claim there must never
  // reach into another wallet's coins.
  test('the open wallet sees only its own claims', () {
    final fork = ForkProvider();
    fork.claims = [
      WalletClaim(walletId: 'open', walletName: 'Open', claimableSats: 100, utxos: [utxo('a:0'), utxo('b:0')]),
      WalletClaim(walletId: 'other', walletName: 'Other', claimableSats: 100, utxos: [utxo('c:0')]),
    ];

    final mine = fork.claimsForWallet('open');
    expect(mine, hasLength(1));
    expect(mine.single.utxos.map((u) => u.output), ['a:0', 'b:0']);

    final coins = mine.expand((c) => c.utxos).map((u) => u.output).toSet();
    expect(coins.contains('c:0'), isFalse, reason: "another wallet's coin must not appear");
  });
}

void _dismissalTests() {
  ForkProvider twoWallets() {
    final fork = ForkProvider();
    fork.hasFundsToClaim = true;
    fork.claims = [
      WalletClaim(walletId: 'a', walletName: 'A', claimableSats: 100, utxos: [utxo('a1:0')]),
      WalletClaim(walletId: 'b', walletName: 'B', claimableSats: 100, utxos: [utxo('b1:0')]),
    ];
    return fork;
  }

  // Closing one wallet's card must leave the other wallet's card, or its red
  // dot points at a card that never opens.
  test('closing one card leaves the other wallet alone', () {
    final fork = twoWallets();
    fork.dismissClaimCardFor('a');

    expect(fork.claimCardDismissedFor('a'), isTrue);
    expect(fork.claimCardDismissedFor('b'), isFalse);
  });

  test('a new coin brings the card back for that wallet', () {
    final fork = twoWallets();
    fork.dismissClaimCardFor('a');

    fork.claims = [
      WalletClaim(walletId: 'a', walletName: 'A', claimableSats: 200, utxos: [utxo('a1:0'), utxo('a2:0')]),
      WalletClaim(walletId: 'b', walletName: 'B', claimableSats: 100, utxos: [utxo('b1:0')]),
    ];

    expect(fork.claimCardDismissedFor('a'), isFalse);
  });

  test('a wallet with no claim reads as not dismissed', () {
    expect(twoWallets().claimCardDismissedFor('missing'), isFalse);
  });
}
