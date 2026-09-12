import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/rpcs/bitnames_rpc.dart';

void main() {
  group('BitnameDetails.fromJson', () {
    test('reads the website a registration holds', () {
      final details = BitnameDetails.fromJson({
        'seq_id': '1',
        'commitment': 'a' * 64,
        'socket_addr_host': 'psztorc.com:6002',
      });

      expect(details.socketAddrHost, 'psztorc.com:6002');
      expect(details.socketAddrV4, isNull);
      expect(details.socketAddrV6, isNull);
    });

    test('reads a registration with no website', () {
      final details = BitnameDetails.fromJson({
        'seq_id': '2',
        'socket_addr_v4': '203.0.113.7:6002',
      });

      expect(details.socketAddrHost, isNull);
      expect(details.socketAddrV4, '203.0.113.7:6002');
    });
  });
}
