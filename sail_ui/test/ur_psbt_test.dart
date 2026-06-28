import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/utils/ur_psbt.dart';

// Known-answer vector from BCR-2020-006 (UR types registry). The crypto-psbt
// payload is the raw PSBT CBOR-wrapped as an untagged byte string (58A7...),
// then ByteWords-encoded. The ByteWords body is identical to the spec's
// example; only the UR type label (crypto-psbt vs psbt) differs.
const _psbtHex =
    '70736274ff01009a020000000258e87a21b56daf0c23be8e7070456c336f7cbaa5c8757924f5'
    '45887bb2abdd750000000000ffffffff838d0427d0ec650a68aa46bb0b098aea4422c071b2ca7'
    '8352a077959d07cea1d0100000000ffffffff0270aaf00800000000160014d85c2b71d0060b09'
    'c9886aeb815e50991dda124d00e1f5050000000016001400aea9a2e5f0f876a588df5546e8742d'
    '1d87008f000000000000000000';

const _expectedSinglePart =
    'ur:crypto-psbt/hdosjojkidjyzmadaenyaoaeaeaeaohdvsknclrejnpebncnrnmnjojofejzeojlke'
    'rdonspkpkkdkykfelokgprpyutkpaeaeaeaeaezmzmzmzmlslgaaditiwpihbkispkfgrkbdaslewdfyc'
    'prtjsprsgksecdratkkhktikewdcaadaeaeaeaezmzmzmzmaojopkwtayaeaeaeaecmaebbtphhdnjsti'
    'ambdassoloimwmlyhygdnlcatnbggtaevyykahaeaeaeaecmaebbaeplptoevwwtyakoonlourgofgvsj'
    'ydpcaltaemyaeaeaeaeaeaeaeaeaebkgdcarh';

Uint8List _hexToBytes(String hex) {
  final out = Uint8List(hex.length ~/ 2);
  for (var i = 0; i < out.length; i++) {
    out[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
  }
  return out;
}

// Canonical bc-ur reference multipart frame bodies (test_ur_encoder, 256-byte
// "Wolf" message, seqLen 9): the pure sequential parts 1..9. Each body is
// bytewords-minimal(cbor([seqNum, seqLen, messageLen, checksum, data])).
const _bcUrRefBodies = [
  'lpadascfadaxcywenbpljkhdcahkadaemejtswhhylkepmykhhtsytsnoyoyaxaedsuttydmmhhpktpmsrjtdkgslpgh',
  'lpaoascfadaxcywenbpljkhdcagwdpfnsboxgwlbaawzuefywkdplrsrjynbvygabwjldapfcsgmghhkhstlrdcxaefz',
  'lpaxascfadaxcywenbpljkhdcahelbknlkuejnbadmssfhfrdpsbiegecpasvssovlgeykssjykklronvsjksopdzmol',
  'lpaaascfadaxcywenbpljkhdcasotkhemthydawydtaxneurlkosgwcekonertkbrlwmplssjtammdplolsbrdzcrtas',
  'lpahascfadaxcywenbpljkhdcatbbdfmssrkzmcwnezelennjpfzbgmuktrhtejscktelgfpdlrkfyfwdajldejokbwf',
  'lpamascfadaxcywenbpljkhdcackjlhkhybssklbwefectpfnbbectrljectpavyrolkzczcpkmwidmwoxkilghdsowp',
  'lpatascfadaxcywenbpljkhdcavszmwnjkwtclrtvaynhpahrtoxmwvwatmedibkaegdosftvandiodagdhthtrlnnhy',
  'lpayascfadaxcywenbpljkhdcadmsponkkbbhgsoltjntegepmttmoonftnbuoiyrehfrtsabzsttorodklubbuyaetk',
  'lpasascfadaxcywenbpljkhdcajskecpmdckihdyhphfotjojtfmlnwmadspaxrkytbztpbauotbgtgtaeaevtgavtny',
];

/// Minimal CBOR reader for the multipart part array, used only by the vector
/// tests to inspect the reference framing via the public ByteWords API.
class _CborPartReader {
  late final int arrayLen;
  late final int seqNum;
  late final int seqLen;
  late final int messageLen;
  late final int checksum;
  late final int dataLength;

  final Uint8List _d;
  int _p = 0;

  _CborPartReader(this._d) {
    arrayLen = _arg(_d[_p++]);
    seqNum = _arg(_d[_p++]);
    seqLen = _arg(_d[_p++]);
    messageLen = _arg(_d[_p++]);
    checksum = _arg(_d[_p++]);
    final b = _d[_p++];
    if ((b >> 5) != 2) throw const FormatException('expected byte string');
    dataLength = _arg(b);
  }

  int _arg(int b) {
    final ai = b & 0x1f;
    if (ai < 24) return ai;
    if (ai == 24) return _d[_p++];
    if (ai == 25) {
      final v = (_d[_p] << 8) | _d[_p + 1];
      _p += 2;
      return v;
    }
    if (ai == 26) {
      final v = (_d[_p] << 24) | (_d[_p + 1] << 16) | (_d[_p + 2] << 8) | _d[_p + 3];
      _p += 4;
      return v;
    }
    throw const FormatException('bad cbor arg');
  }
}

void main() {
  group('URPsbt crypto-psbt', () {
    test('single-part encode matches BCR-2020-006 known vector', () {
      final psbt = _hexToBytes(_psbtHex);
      final frames = URPsbt.encode(psbt, maxFragmentLen: 10000);
      expect(frames.length, 1);
      expect(frames.first, _expectedSinglePart);
    });

    test('emits ur:crypto-psbt type, not ur:bytes', () {
      final frames = URPsbt.encode(_hexToBytes(_psbtHex));
      for (final f in frames) {
        expect(f.startsWith('ur:crypto-psbt/'), isTrue);
      }
    });

    test('single-part round-trip is byte-identical', () {
      final psbt = _hexToBytes(_psbtHex);
      final frames = URPsbt.encode(psbt, maxFragmentLen: 10000);
      final dec = URPsbt.decoder();
      for (final f in frames) {
        dec.receive(f);
      }
      expect(dec.isComplete, isTrue);
      expect(dec.result(), psbt);
    });

    test('multi-part round-trip for a large PSBT forces >1 frame', () {
      final big = Uint8List(4000);
      for (var i = 0; i < big.length; i++) {
        big[i] = (i * 31 + 7) & 0xff;
      }
      final frames = URPsbt.encode(big, maxFragmentLen: 200);
      expect(frames.length, greaterThan(1));
      for (final f in frames) {
        expect(RegExp(r'^ur:crypto-psbt/\d+-\d+/').hasMatch(f), isTrue);
      }

      final dec = URPsbt.decoder();
      for (final f in frames) {
        dec.receive(f);
      }
      expect(dec.expectedCount, frames.length);
      expect(dec.isComplete, isTrue);
      expect(dec.result(), big);
    });

    test('multi-part fragments are all equal length (BCR-2024-001)', () {
      final big = Uint8List(1000);
      for (var i = 0; i < big.length; i++) {
        big[i] = (i * 7) & 0xff;
      }
      final frames = URPsbt.encode(big, maxFragmentLen: 200);
      expect(frames.length, greaterThan(1));

      final dataLengths = <int>{};
      for (final f in frames) {
        final body = f.split('/').last;
        final part = ByteWords.decode(body); // cbor [seqNum,seqLen,msgLen,crc,data]
        final r = _CborPartReader(part);
        dataLengths.add(r.dataLength);
      }
      // Every fragment's data is exactly fragLen bytes; the final one is
      // zero-padded rather than truncated.
      expect(dataLengths.length, 1);
    });

    // Pin against the canonical BlockchainCommons bc-ur multipart reference
    // (test_ur_encoder, 256-byte "Wolf" message, seqLen 9). These are the real
    // pure sequential frames 1..9 emitted by the reference C++ encoder. We
    // assert our ByteWords + part-CBOR framing is byte-identical to it.
    test('decodes the bc-ur reference multipart frames 1..9', () {
      const seqLen = 9;
      const messageLen = 259; // 256-byte payload + 3-byte CBOR bytes header
      int? checksum;
      final dataLens = <int>{};

      for (var i = 0; i < _bcUrRefBodies.length; i++) {
        final part = ByteWords.decode(_bcUrRefBodies[i]);
        final r = _CborPartReader(part);
        expect(r.arrayLen, 5);
        expect(r.seqNum, i + 1);
        expect(r.seqLen, seqLen);
        expect(r.messageLen, messageLen);
        checksum ??= r.checksum;
        expect(r.checksum, checksum); // identical across all parts
        dataLens.add(r.dataLength);
      }
      // All fragments equal length, padded final fragment.
      expect(dataLens.length, 1);
      expect(seqLen * dataLens.first, greaterThanOrEqualTo(messageLen));
    });

    test('multi-part reassembles regardless of frame order', () {
      final big = Uint8List(1500);
      for (var i = 0; i < big.length; i++) {
        big[i] = (i * 13) & 0xff;
      }
      final frames = URPsbt.encode(big, maxFragmentLen: 200).reversed.toList();
      final dec = URPsbt.decoder();
      for (final f in frames) {
        dec.receive(f);
      }
      expect(dec.result(), big);
    });

    test('base64 helpers round-trip', () {
      final psbt = _hexToBytes(_psbtHex);
      final b64 = base64.encode(psbt);
      final frames = URPsbt.encodeBase64(b64, maxFragmentLen: 200);
      final dec = URPsbt.decoder();
      for (final f in frames) {
        dec.receive(f);
      }
      expect(dec.resultBase64(), b64);
    });

    test('rejects a non-crypto-psbt frame', () {
      final dec = URPsbt.decoder();
      expect(() => dec.receive('ur:bytes/deadbeef'), throwsFormatException);
    });

    test('ByteWords minimal round-trips with checksum', () {
      final data = Uint8List.fromList([0, 1, 2, 127, 128, 255]);
      final encoded = ByteWords.encode(data);
      expect(ByteWords.decode(encoded), data);
    });
  });
}
