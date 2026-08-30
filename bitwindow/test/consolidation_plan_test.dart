import 'package:bitwindow/utils/consolidation.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

const addresses = <CoinScriptKind, String>{
  CoinScriptKind.p2pkh: '1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2',
  CoinScriptKind.p2sh: '3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy',
  CoinScriptKind.p2wpkh: 'bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4',
  CoinScriptKind.p2wsh: 'bc1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3qccfmv3',
  CoinScriptKind.p2tr: 'bc1p5d7rjq7g6rdk2yhzks9smlaqtedr4dekq08ge8ztwac72sfr9rusxg3297',
};

/// The weight the orchestrator computes from each coin's descriptor. The Go
/// test TestInputWeightUnits holds these same numbers.
const backendWeightUnits = <CoinScriptKind, int>{
  CoinScriptKind.p2pkh: 592,
  CoinScriptKind.p2sh: 364,
  CoinScriptKind.p2wpkh: 272,
  CoinScriptKind.p2wsh: 418,
  CoinScriptKind.p2tr: 231,
};

UnspentOutput coin(String id, int sats, {CoinScriptKind kind = CoinScriptKind.p2wpkh, bool measured = true}) =>
    UnspentOutput(
      output: '$id:0',
      valueSats: Int64(sats),
      address: addresses[kind]!,
      inputWeightUnits: measured ? backendWeightUnits[kind]! : 0,
    );

List<UnspentOutput> coins(int count, int sats, {CoinScriptKind kind = CoinScriptKind.p2wpkh}) =>
    List.generate(count, (i) => coin('tx$i', sats, kind: kind));

void main() {
  group('consolidationVbytes', () {
    // Two segwit inputs into one taproot output: 10 bytes of transaction, two
    // 41 byte inputs, one 43 byte output, and 218 weight units of witness.
    test('measures a segwit transaction to the vbyte', () {
      final size = consolidationVbytes(
        inputCount: 2,
        inputWeightUnits: 2 * 272,
        hasWitness: true,
        destinationKind: CoinScriptKind.p2tr,
      );

      expect(size, ((10 + (2 * 41) + 43) * 4 + 2 + (2 * 108) + 3) ~/ 4);
      expect(size, 190);
    });

    // A legacy transaction carries no witness, so its vbytes equal its bytes.
    test('measures a legacy transaction to the vbyte', () {
      final size = consolidationVbytes(
        inputCount: 2,
        inputWeightUnits: 2 * 592,
        hasWitness: false,
        destinationKind: CoinScriptKind.p2tr,
      );

      expect(size, 10 + (2 * 148) + 43);
      expect(size, 349);
    });

    // Segwit serialization gives every input a witness field, so a legacy
    // input still costs the empty item count byte. A calculation that drops it
    // reads low, and a low number builds an oversized transaction.
    test('charges an empty witness for a legacy input in a segwit transaction', () {
      // Four segwit inputs and four legacy inputs. The four empty witness
      // bytes add one whole vbyte.
      const weightUnits = (4 * 272) + (4 * 592);
      final counted = consolidationVbytes(
        inputCount: 8,
        inputWeightUnits: weightUnits,
        hasWitness: true,
        destinationKind: CoinScriptKind.p2tr,
        witnessFreeInputCount: 4,
      );
      final dropped = consolidationVbytes(
        inputCount: 8,
        inputWeightUnits: weightUnits,
        hasWitness: true,
        destinationKind: CoinScriptKind.p2tr,
      );

      expect(counted - dropped, 1);
      expect(counted, ((32 + 4 + 4 + 2 + 4 + weightUnits + 172) + 3) ~/ 4);
    });

    test('charges no empty witness when no input carries a witness', () {
      final legacy = consolidationVbytes(
        inputCount: 2,
        inputWeightUnits: 2 * 592,
        hasWitness: false,
        destinationKind: CoinScriptKind.p2tr,
        witnessFreeInputCount: 2,
      );

      expect(legacy, 10 + (2 * 148) + 43);
    });

    test('widens the input count field past 252 inputs', () {
      final small = consolidationVbytes(
        inputCount: 252,
        inputWeightUnits: 252 * 272,
        hasWitness: true,
        destinationKind: CoinScriptKind.p2tr,
      );
      final large = consolidationVbytes(
        inputCount: 253,
        inputWeightUnits: 252 * 272,
        hasWitness: true,
        destinationKind: CoinScriptKind.p2tr,
      );

      expect(large - small, 2, reason: 'the compact size grows from 1 byte to 3');
    });
  });

  group('coinInputWeightUnits', () {
    test('takes the weight the backend measured', () {
      final measured = UnspentOutput(
        output: 'a:0',
        valueSats: Int64(50000),
        address: addresses[CoinScriptKind.p2wpkh]!,
        inputWeightUnits: 999,
      );

      expect(coinInputWeightUnits(measured), 999);
    });

    test('falls back to the address kind when the backend reports nothing', () {
      final unmeasured = coin('a', 50000, kind: CoinScriptKind.p2tr, measured: false);

      expect(coinInputWeightUnits(unmeasured), fallbackInputWeightUnits(CoinScriptKind.p2tr));
    });

    test('the fallback matches what the backend reports, for every kind', () {
      backendWeightUnits.forEach((kind, weight) {
        expect(fallbackInputWeightUnits(kind), weight, reason: '$kind');
      });
    });
  });

  group('coinScriptKind', () {
    test('reads every kind from the address', () {
      addresses.forEach((kind, address) {
        expect(coinScriptKind(address), kind, reason: address);
      });
    });

    test('reads the test network and regtest forms', () {
      expect(coinScriptKind('bcrt1q6njrk7dd474vdmp3lrewjy9e52tny879g56kyx'), CoinScriptKind.p2wpkh);
      expect(coinScriptKind('tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx'), CoinScriptKind.p2wpkh);
      expect(coinScriptKind('mipcBbFg9gMiCh81Kj8tqqdgoZub1ZJRfn'), CoinScriptKind.p2pkh);
      expect(coinScriptKind('2N2JD6wb56AFK4d9ppFTAMvcRZHdc2XBGwm'), CoinScriptKind.p2sh);
    });

    test('falls back to the largest input for text it cannot read', () {
      expect(coinScriptKind('who knows what this is'), CoinScriptKind.unknown);
      expect(fallbackInputWeightUnits(CoinScriptKind.unknown), fallbackInputWeightUnits(CoinScriptKind.p2pkh));
    });
  });

  group('destinationKindFor', () {
    test('takes the type the wallet advertises', () {
      expect(destinationKindFor(wmpb.AddressType.ADDRESS_TYPE_SEGWIT), CoinScriptKind.p2wpkh);
      expect(destinationKindFor(wmpb.AddressType.ADDRESS_TYPE_TAPROOT), CoinScriptKind.p2tr);
    });

    // A legacy or nested segwit wallet advertises no type and derives no
    // taproot address. Asking for taproot fails every send.
    test('asks for nothing in particular when the wallet advertises no type', () {
      final kind = destinationKindFor(wmpb.AddressType.ADDRESS_TYPE_UNSPECIFIED);

      expect(addressTypeFor(kind), wmpb.AddressType.ADDRESS_TYPE_UNSPECIFIED);
      expect(outputWeightUnits(kind), outputWeightUnits(CoinScriptKind.p2tr), reason: 'the widest output');
    });
  });

  group('planConsolidation', () {
    test('sizes a mixed transaction from the weight of every coin', () {
      final mixed = [
        coin('legacy', 500000, kind: CoinScriptKind.p2pkh),
        coin('nested', 500000, kind: CoinScriptKind.p2sh),
        coin('segwit', 500000, kind: CoinScriptKind.p2wpkh),
        coin('taproot', 500000, kind: CoinScriptKind.p2tr),
      ];

      final batch = planConsolidation(coins: mixed, feeRateSatPerVbyte: 1).batches.single;

      expect(batch.inputWeightUnits, 592 + 364 + 272 + 231);
      expect(batch.witnessFreeInputCount, 1, reason: 'only the legacy coin carries no witness');
      expect(
        batch.vbytes,
        consolidationVbytes(
          inputCount: 4,
          inputWeightUnits: 592 + 364 + 272 + 231,
          hasWitness: true,
          destinationKind: CoinScriptKind.p2tr,
          witnessFreeInputCount: 1,
        ),
      );
    });

    // The answer to "can you cap it by coin count?" — no. The same size limit
    // holds far fewer legacy coins than taproot coins.
    test('fits fewer legacy coins than taproot coins in one transaction', () {
      final legacy = planConsolidation(coins: coins(6000, 500000, kind: CoinScriptKind.p2pkh), feeRateSatPerVbyte: 1);
      final taproot = planConsolidation(coins: coins(6000, 500000, kind: CoinScriptKind.p2tr), feeRateSatPerVbyte: 1);

      expect(legacy.batches.first.inputs.length, lessThan(taproot.batches.first.inputs.length));
      expect(legacy.transactionCount, greaterThan(taproot.transactionCount));
      expect(legacy.coinCount, 6000);
      expect(taproot.coinCount, 6000);
    });

    test('holds every transaction below the target size, for every kind', () {
      for (final kind in addresses.keys) {
        final plan = planConsolidation(coins: coins(6000, 500000, kind: kind), feeRateSatPerVbyte: 1);

        for (final batch in plan.batches) {
          expect(batch.vbytes, lessThanOrEqualTo(consolidationTargetVbytes), reason: '$kind');
          expect(batch.vbytes, lessThanOrEqualTo(maxStandardTxVbytes), reason: '$kind');
        }
      }
    });

    test('holds a mixed wallet below the target size', () {
      final mixed = <UnspentOutput>[];
      var index = 0;
      for (final kind in addresses.keys) {
        for (var i = 0; i < 1200; i++) {
          mixed.add(coin('tx${index++}', 500000, kind: kind));
        }
      }

      final plan = planConsolidation(coins: mixed, feeRateSatPerVbyte: 1);

      expect(plan.coinCount, mixed.length);
      expect(plan.largestVbytes, lessThanOrEqualTo(consolidationTargetVbytes));
      expect(plan.everyCoinMeasured, isTrue);
    });

    test('fills each transaction close to the target size', () {
      final plan = planConsolidation(coins: coins(6000, 500000), feeRateSatPerVbyte: 1);
      final full = plan.batches.first;

      expect(full.vbytes + 68, greaterThan(consolidationTargetVbytes));
    });

    test('splits a 20k coin wallet and keeps every coin', () {
      final plan = planConsolidation(coins: coins(20000, 100000), feeRateSatPerVbyte: 1);

      expect(plan.coinCount, 20000);
      expect(plan.transactionCount, greaterThan(10));
      expect(plan.largestVbytes, lessThanOrEqualTo(consolidationTargetVbytes));
    });

    test('leaves one output that pays the fee out of the merged value', () {
      final plan = planConsolidation(coins: coins(10, 50000), feeRateSatPerVbyte: 3);
      final batch = plan.batches.single;

      expect(batch.inputSats, 500000);
      expect(batch.feeSats, batch.vbytes * 3);
      expect(batch.outputSats, batch.inputSats - batch.feeSats);
    });

    test('reads the too small limit from the weight of the coin', () {
      // At 40 sat/vB a legacy coin costs 5920 sats to spend, and a taproot coin
      // costs 2360.
      final plan = planConsolidation(
        coins: [
          coin('legacy', 4000, kind: CoinScriptKind.p2pkh),
          coin('taproot', 4000, kind: CoinScriptKind.p2tr),
          coin('taproot2', 400000, kind: CoinScriptKind.p2tr),
        ],
        feeRateSatPerVbyte: 40,
      );

      expect(plan.skippedFor(ConsolidationSkipReason.tooSmall).single.output, 'legacy:0');
      expect(plan.coinCount, 2);
    });

    test('never spends a frozen coin', () {
      final plan = planConsolidation(
        coins: [coin('a', 50000), coin('b', 50000), coin('cold', 50000)],
        feeRateSatPerVbyte: 1,
        frozenOutpoints: {'cold:0'},
      );

      expect(plan.batches.single.outpoints, ['a:0', 'b:0']);
      expect(plan.skippedFor(ConsolidationSkipReason.frozen).single.output, 'cold:0');
    });

    test('refuses to merge a single coin', () {
      final plan = planConsolidation(coins: [coin('only', 100000)], feeRateSatPerVbyte: 1);

      expect(plan.isEmpty, isTrue);
      expect(plan.skippedFor(ConsolidationSkipReason.alone), hasLength(1));
    });

    // A tail of one coin borrows a partner from the transaction before it,
    // instead of dropping a coin the user selected.
    test('moves a coin back so a lone tail gets a partner', () {
      final perTransaction = planConsolidation(
        coins: coins(6000, 500000),
        feeRateSatPerVbyte: 1,
      ).batches.first.inputs.length;
      final plan = planConsolidation(coins: coins(perTransaction + 1, 500000), feeRateSatPerVbyte: 1);

      expect(plan.transactionCount, 2);
      expect(plan.coinCount, perTransaction + 1, reason: 'every coin still goes in');
      expect(plan.skippedFor(ConsolidationSkipReason.alone), isEmpty);
      expect(plan.batches.last.inputs, hasLength(2));
      expect(plan.largestVbytes, lessThanOrEqualTo(consolidationTargetVbytes));
    });

    // A taproot address hides its script tree, and a script path spend costs
    // far more than a key path spend. No number bounds it, so it stays out.
    test('leaves out a taproot coin the backend could not size', () {
      final plan = planConsolidation(
        coins: [
          coin('a', 500000),
          coin('b', 500000),
          coin('tree', 500000, kind: CoinScriptKind.p2tr, measured: false),
        ],
        feeRateSatPerVbyte: 1,
      );

      expect(plan.batches.single.outpoints, ['a:0', 'b:0']);
      expect(plan.skippedFor(ConsolidationSkipReason.unknownSize).single.output, 'tree:0');
    });

    test('keeps a segwit coin the backend could not size', () {
      final plan = planConsolidation(
        coins: [coin('a', 500000, measured: false), coin('b', 500000, measured: false)],
        feeRateSatPerVbyte: 1,
      );

      expect(plan.coinCount, 2, reason: 'the address bounds a P2WPKH input');
      expect(plan.everyCoinMeasured, isFalse);
    });

    // resultCoinCount covers the selection only. A caller that reports a
    // wallet total adds the coins the user left unselected.
    test('counts only the selection in the result', () {
      final wallet = [coin('a', 500000), coin('b', 500000), coin('spare', 500000)];
      final selected = wallet.take(2).toList();

      final plan = planConsolidation(coins: selected, feeRateSatPerVbyte: 1);

      expect(plan.resultCoinCount, 1, reason: 'one merged coin, from the selection');
      final walletAfter = wallet.length - plan.coinCount + plan.transactionCount;
      expect(walletAfter, 2, reason: 'the unselected coin stays');
    });

    // A skipped coin stays in the wallet beside the coin each transaction
    // makes, so the preview must count it.
    test('counts a skipped coin in the result', () {
      final plan = planConsolidation(
        coins: [coin('a', 500000), coin('b', 500000), coin('cold', 500000)],
        feeRateSatPerVbyte: 1,
        frozenOutpoints: {'cold:0'},
      );

      expect(plan.transactionCount, 1);
      expect(plan.resultCoinCount, 2, reason: 'one merged coin and the frozen one');
    });

    // Core sizes dust from what an output costs to make and to spend again,
    // so a taproot output may hold less than a legacy one.
    test('reads the dust limit from the destination kind', () {
      expect(dustThresholdFor(CoinScriptKind.p2tr), lessThan(dustThresholdFor(CoinScriptKind.p2pkh)));
      expect(dustThresholdFor(CoinScriptKind.p2wpkh), lessThan(dustThresholdFor(CoinScriptKind.p2tr)));
      expect(dustThresholdFor(CoinScriptKind.unknown), dustThresholdFor(CoinScriptKind.p2pkh));
    });

    test('keeps a small taproot consolidation a legacy one would drop', () {
      final small = [
        coin('a', 300, kind: CoinScriptKind.p2tr),
        coin('b', 300, kind: CoinScriptKind.p2tr),
      ];

      final toTaproot = planConsolidation(
        coins: small,
        feeRateSatPerVbyte: 1,
        destinationKind: CoinScriptKind.p2tr,
      );
      final toLegacy = planConsolidation(
        coins: small,
        feeRateSatPerVbyte: 1,
        destinationKind: CoinScriptKind.p2pkh,
      );

      expect(toTaproot.batches.single.outputSats, greaterThanOrEqualTo(dustThresholdFor(CoinScriptKind.p2tr)));
      expect(toLegacy.isEmpty, isTrue, reason: 'the same coins are dust to a legacy output');
    });

    test('drops a batch whose output falls below the dust limit', () {
      final plan = planConsolidation(coins: coins(3, 200), feeRateSatPerVbyte: 2);

      expect(plan.isEmpty, isTrue);
    });

    test('marks a plan that holds a coin the backend could not measure', () {
      final plan = planConsolidation(
        coins: [coin('a', 500000), coin('b', 500000, measured: false)],
        feeRateSatPerVbyte: 1,
      );

      expect(plan.everyCoinMeasured, isFalse);
    });

    test('rejects a fee rate below one', () {
      expect(() => planConsolidation(coins: coins(2, 100000), feeRateSatPerVbyte: 0), throwsArgumentError);
    });
  });
}
