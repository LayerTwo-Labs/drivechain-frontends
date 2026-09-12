import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/utils/data_server_address.dart';

const _port = 6002;

void main() {
  test('a bare domain takes the default port', () {
    expect(hostWithPort('psztorc.com', _port), 'psztorc.com:6002');
  });

  test('a domain with a port keeps that port', () {
    expect(hostWithPort('psztorc.com:8080', _port), 'psztorc.com:8080');
  });

  test('an empty host gives null', () {
    expect(hostWithPort('', _port), isNull);
    expect(hostWithPort('   ', _port), isNull);
    expect(hostWithPort(null, _port), isNull);
  });

  test('the IPv4 address wins over every other field', () {
    expect(
      dataServerAddress(
        website: 'psztorc.com',
        ipv4: '8.8.8.8:6002',
        ipv6: '[2606:4700:4700::1111]:6002',
        defaultPort: _port,
      ),
      '8.8.8.8:6002',
    );
  });

  test('the IPv6 address wins over the website', () {
    expect(
      dataServerAddress(
        website: 'psztorc.com',
        ipv4: '',
        ipv6: '[2606:4700:4700::1111]:6002',
        defaultPort: _port,
      ),
      '[2606:4700:4700::1111]:6002',
    );
  });

  test('the website serves when no address is set', () {
    expect(
      dataServerAddress(website: 'psztorc.com', ipv4: null, ipv6: null, defaultPort: _port),
      'psztorc.com:6002',
    );
  });

  test('no field gives an empty address', () {
    expect(
      dataServerAddress(website: '', ipv4: '', ipv6: '', defaultPort: _port),
      '',
    );
  });
}
