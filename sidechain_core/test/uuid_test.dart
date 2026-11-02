import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/sidechain_core.dart';

void main() {
  group('uuidV4', () {
    test('has the 8-4-4-4-12 lowercase form', () {
      for (var i = 0; i < 1000; i++) {
        expect(uuidV4(), matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')));
      }
    });

    test('sets version 4 and the RFC 9562 variant', () {
      for (var i = 0; i < 1000; i++) {
        final id = uuidV4();
        expect(id[14], '4');
        expect('89ab', contains(id[19]));
      }
    });

    test('gives a different value each call', () {
      final ids = {for (var i = 0; i < 10000; i++) uuidV4()};
      expect(ids, hasLength(10000));
    });

    test('passes its own check', () {
      for (var i = 0; i < 1000; i++) {
        expect(isValidUuid(uuidV4()), isTrue);
      }
    });
  });

  group('isValidUuid', () {
    test('accepts versions 1 and 3 to 8', () {
      expect(isValidUuid('c232ab00-9414-11ec-b3c8-9f6bdeced846'), isTrue);
      expect(isValidUuid('5df41881-3aed-3515-88a7-2f4a814cf09e'), isTrue);
      expect(isValidUuid('919108f7-52d1-4320-9bac-f847db4148a8'), isTrue);
      expect(isValidUuid('2ed6657d-e927-568b-95e1-2665a8aea6a2'), isTrue);
      expect(isValidUuid('1ec9414c-232a-6b00-b3c8-9f6bdeced846'), isTrue);
      expect(isValidUuid('017f22e2-79b0-7cc3-98c4-dc0c0c07398f'), isTrue);
      expect(isValidUuid('320c3d4d-cc00-875b-8ec9-32d5f69181c0'), isTrue);
    });

    test('accepts upper case', () {
      expect(isValidUuid('919108F7-52D1-4320-9BAC-F847DB4148A8'), isTrue);
    });

    test('accepts the nil and max UUID', () {
      expect(isValidUuid('00000000-0000-0000-0000-000000000000'), isTrue);
      expect(isValidUuid('ffffffff-ffff-ffff-ffff-ffffffffffff'), isTrue);
    });

    test('rejects a version above 8', () {
      expect(isValidUuid('919108f7-52d1-9320-9bac-f847db4148a8'), isFalse);
    });

    test('rejects a variant outside 8, 9, a, b', () {
      expect(isValidUuid('919108f7-52d1-4320-cbac-f847db4148a8'), isFalse);
      expect(isValidUuid('919108f7-52d1-4320-7bac-f847db4148a8'), isFalse);
    });

    test('rejects a wrong shape', () {
      expect(isValidUuid(''), isFalse);
      expect(isValidUuid('919108f752d143209bacf847db4148a8'), isFalse);
      expect(isValidUuid('919108f7-52d1-4320-9bac-f847db4148a'), isFalse);
      expect(isValidUuid('919108f7-52d1-4320-9bac-f847db4148a8 '), isFalse);
      expect(isValidUuid('919108g7-52d1-4320-9bac-f847db4148a8'), isFalse);
    });
  });
}
