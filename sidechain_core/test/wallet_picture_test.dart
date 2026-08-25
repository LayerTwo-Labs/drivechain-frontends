import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/models/wallet_gradient.dart';
import 'package:sidechain_core/models/wallet_metadata.dart';

WalletGradient _gradient({String? picturePath}) => WalletGradient(
  backgroundSvg: 'background_northern.svg',
  picturePath: picturePath,
  colors: const ['#000000', '#111111', '#222222'],
  stops: const [0, 0.5, 1],
  centerX: 0,
  centerY: 0,
  radius: 1.2,
  seed: 7,
);

void main() {
  _nameTests();

  test('a picture survives a save and a read', () {
    final json = _gradient(picturePath: '/data/wallet_pictures/a.png').toJson();
    expect(json['picture_path'], '/data/wallet_pictures/a.png');

    final back = WalletGradient.fromJson(json);
    expect(back.picturePath, '/data/wallet_pictures/a.png');
    expect(back.backgroundSvg, 'background_northern.svg');
  });

  test('a wallet with no picture writes no picture field', () {
    expect(_gradient().toJson().containsKey('picture_path'), isFalse);
    expect(WalletGradient.fromJson(_gradient().toJson()).picturePath, isNull);
  });

  // Remove picture brings back the generated avatar, so the background stays.
  test('withoutPicture drops the picture and keeps the background', () {
    final withPicture = _gradient(picturePath: '/data/a.png');
    final without = withPicture.withoutPicture();

    expect(without.picturePath, isNull);
    expect(without.backgroundSvg, 'background_northern.svg');
    expect(without.seed, withPicture.seed);
  });

  // Every new wallet takes a background from the shipped set, and the user
  // never picks one.
  test('a generated avatar takes one of the shipped backgrounds', () {
    for (final id in ['A1', 'B2', 'C3', 'D4']) {
      final g = WalletGradient.fromWalletId(id);
      expect(WalletGradient.allBackgrounds, contains(g.backgroundSvg));
      expect(g.picturePath, isNull);
    }
  });
}

void _nameTests() {
  // The wizard names every wallet, so the sequence must skip what is taken.
  test('the next name follows the sequence', () {
    expect(nextWalletName(const []), 'wallet1');
    expect(nextWalletName(const ['wallet1']), 'wallet2');
    expect(nextWalletName(const ['wallet1', 'wallet2', 'wallet3']), 'wallet4');
  });

  test('a name the user typed does not collide', () {
    expect(nextWalletName(const ['Cold storage', 'bitkey']), 'wallet1');
    expect(nextWalletName(const ['WALLET1', 'wallet2']), 'wallet3', reason: 'the check folds case');
  });

  test('a gap in the sequence fills first', () {
    expect(nextWalletName(const ['wallet1', 'wallet3']), 'wallet2');
  });
}
