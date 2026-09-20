import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/providers/mining_words.dart';

void main() {
  group('leading zeros', () {
    test('a difficulty of one needs eight zeros', () {
      expect(leadingZeros(1), 8);
    });

    test('a harder network needs more zeros', () {
      expect(leadingZeros(4e9), greaterThan(leadingZeros(1)));
    });

    test('a difficulty below one needs fewer zeros', () {
      expect(leadingZeros(1 / 1024), lessThan(8));
    });
  });

  group('best share tooltip', () {
    const opening =
        'The closest your miner came to a block. To win, your miner must produce a hash that starts with '
        'at least 8 zeros';

    test('a share below the network target', () {
      final text = bestShareInfo(bestShare: 1, networkDifficulty: 4e9);
      expect(text, contains('must produce a hash that starts with at least 15 zeros.'));
      expect(text, contains('Your best guess started with 8.'));
    });

    test('a share that reached the zeros but stayed too big', () {
      final text = bestShareInfo(bestShare: 1, networkDifficulty: 1);
      expect(text, startsWith('$opening, and is a smaller number than '));
      expect(text, contains('Your best guess reached 8 zeros, but the digits after them were too big.'));
    });

    test('a share that won a block', () {
      final text = bestShareInfo(bestShare: 4e9, networkDifficulty: 1);
      expect(text, startsWith('$opening.'));
      expect(text, contains('Your best guess reached 15 zeros, and it won a block.'));
    });
  });

  group('hashrate tooltip', () {
    test('no miner stops after the first sentence', () {
      expect(
        hashrateInfo(
          hashrate: 0,
          networkHashrate: 171e15,
          networkDifficulty: 4e9,
          formattedHashrate: '0 H/s',
          formattedNetwork: '171 PH/s',
        ),
        'How many guesses per second your miners make. No miner is connected.',
      );
    });

    test('a miner gets the plain words and the expected time', () {
      final text = hashrateInfo(
        hashrate: 7.33e12,
        networkHashrate: 171e15,
        networkDifficulty: 4e9,
        formattedHashrate: '7.33 TH/s',
        formattedNetwork: '171 PH/s',
      );
      expect(text, contains('7.33 TH/s is 7.33 trillion guesses each second.'));
      expect(text, contains('The whole network makes 171 PH/s, so your miner is expected to find a block every '));
    });
  });

  test('spell count', () {
    expect(spellCount(412000), '412 thousand');
    expect(spellCount(7.33e12), '7.33 trillion');
    expect(spellCount(171e15), '171 quadrillion');
    expect(spellCount(42), '42');
  });

  test('truncate middle', () {
    expect(truncateMiddle('0000000000000000000a1b2c3d4e5f60718293a4b5c6d7e8f9000000deadbeef'), '00000000…deadbeef');
    expect(truncateMiddle('short'), 'short');
  });
}
