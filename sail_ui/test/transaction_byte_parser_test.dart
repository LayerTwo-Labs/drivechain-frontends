import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/widgets/transaction_byte_parser.dart';

void main() {
  // Legacy P2PKH: 1 input, 1 output, version 1, locktime 0.
  // value = 5000000000 sats (50 BTC) = 00f2052a01000000 LE.
  const legacyHex =
      '01000000' // version
      '01' // input count
      '0000000000000000000000000000000000000000000000000000000000000001' // prevout txid
      '02000000' // prevout vout = 2
      '00' // scriptSig length
      'ffffffff' // sequence
      '01' // output count
      '00f2052a01000000' // value 5000000000
      '19' // scriptPubKey length 25
      '76a914000000000000000000000000000000000000000088ac' // scriptPubKey
      '00000000'; // locktime

  // SegWit P2WPKH (BIP143 example tx, partial witness): version 1, marker+flag,
  // 1 input, 2 outputs, witness with 2 items, locktime 0x11.
  const segwitHex =
      '01000000' // version
      '0001' // segwit marker + flag
      '01' // input count
      'fff7f7881a8099afa6940d42d1e7f6362bec38171ea3edf433541db4e4ad969f' // txid
      '00000000' // vout
      '00' // scriptSig length
      'eeffffff' // sequence
      '02' // output count
      '202cb20600000000' // output 0 value = 112340000
      '1976a9148280b37df378db99f66f85c95a783a76ac7a6d5988ac' // output 0 spk
      '9093510d00000000' // output 1 value = 223450000
      '1976a9143bde42dbee7e4dbe6a21b2d50ce2f0167faa815988ac' // output 1 spk
      '02' // witness item count for input 0
      '47304402203609e17b84f6a7d30c80bfa610b5b4542f32a8a0d5447a12fb1366d7f01cc44a0220573a954c4518331561406f90300e8f3358f51928d43c212a8caed02de67eebee01' // witness[0]
      '21025476c2e83188368da1ff3e292e7acafcdb3566bb0ad253f62fc70f07aeee6357' // witness[1]
      '11000000'; // locktime = 17

  group('parseTransactionHex legacy', () {
    final tx = parseTransactionHex(legacyHex);

    test('not segwit', () => expect(tx.isSegwit, false));
    test('version', () => expect(tx.version, 1));
    test('input count', () => expect(tx.inputCount, 1));
    test('output count', () => expect(tx.outputCount, 1));
    test('locktime', () => expect(tx.locktime, 0));

    test('version field at offset 0', () {
      final f = tx.fields.first;
      expect(f.label, 'Version');
      expect(f.offset, 0);
      expect(f.hex, '01000000');
    });

    test('output value decoded', () {
      final f = tx.fields.firstWhere((f) => f.label == 'Output #0 value (sats)');
      expect(f.value, '5000000000');
    });

    test('prevout vout decoded', () {
      final f = tx.fields.firstWhere((f) => f.label == 'Input #0 prevout vout');
      expect(f.value, '2');
    });

    test('locktime field is the last field', () {
      final f = tx.fields.last;
      expect(f.label, 'Lock time');
      expect(f.value, '0');
    });
  });

  group('parseTransactionHex segwit', () {
    final tx = parseTransactionHex(segwitHex);

    test('is segwit', () => expect(tx.isSegwit, true));
    test('version', () => expect(tx.version, 1));
    test('input count', () => expect(tx.inputCount, 1));
    test('output count', () => expect(tx.outputCount, 2));
    test('locktime', () => expect(tx.locktime, 17));

    test('marker+flag field present after version', () {
      final f = tx.fields[1];
      expect(f.label, 'SegWit marker + flag');
      expect(f.offset, 4);
      expect(f.hex, '0001');
    });

    test('output values decoded', () {
      final v0 = tx.fields.firstWhere((f) => f.label == 'Output #0 value (sats)');
      final v1 = tx.fields.firstWhere((f) => f.label == 'Output #1 value (sats)');
      expect(v0.value, '112340000');
      expect(v1.value, '223450000');
    });

    test('witness items parsed', () {
      final count = tx.fields.firstWhere((f) => f.label == 'Input #0 witness item count');
      expect(count.value, '2');
      expect(tx.fields.any((f) => f.label == 'Input #0 witness[0]'), true);
      expect(tx.fields.any((f) => f.label == 'Input #0 witness[1]'), true);
    });

    test('prevout txid is byte-reversed for display', () {
      final f = tx.fields.firstWhere((f) => f.label == 'Input #0 prevout txid');
      expect(f.value, '9f96ade4b41d5433f4eda31e1738ec2b36f6e7d1420d94a6af99801a88f7f7ff');
    });

    test('no trailing bytes', () {
      // Re-parse to ensure the full buffer was consumed (no exception above).
      expect(parseTransactionHex(segwitHex).fields.isNotEmpty, true);
    });
  });

  group('parseTransactionHex malformed', () {
    test('empty throws', () {
      expect(() => parseTransactionHex(''), throwsA(isA<TxParseException>()));
    });

    test('odd-length throws', () {
      expect(() => parseTransactionHex('010000'), throwsA(isA<TxParseException>()));
    });

    test('non-hex throws', () {
      expect(() => parseTransactionHex('zzzz'), throwsA(isA<TxParseException>()));
    });

    test('truncated throws (not a generic Error)', () {
      // Version only, then claims an input but no data follows.
      expect(() => parseTransactionHex('0100000001'), throwsA(isA<TxParseException>()));
    });

    test('trailing bytes throw', () {
      expect(() => parseTransactionHex('${legacyHex}deadbeef'), throwsA(isA<TxParseException>()));
    });
  });
}
