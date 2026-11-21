import 'dart:convert';
import 'dart:io';

/// The test routes of `scripts/phone-regtest.sh`: they mine regtest blocks and pay from the Core wallet on the Mac.
class RegtestControl {
  final Uri base;

  RegtestControl(this.base);

  /// The control URL from `--dart-define=PHONE_REGTEST_CONTROL_URL`.
  factory RegtestControl.fromDefine() {
    const url = String.fromEnvironment('PHONE_REGTEST_CONTROL_URL');
    if (url.isEmpty) {
      throw StateError('give --dart-define=PHONE_REGTEST_CONTROL_URL; see scripts/phone-regtest.sh defines');
    }
    return RegtestControl(Uri.parse(url));
  }

  Future<Map<String, dynamic>> _call(String method, String path, [Map<String, Object?>? body]) async {
    final client = HttpClient();
    try {
      final request = await client.openUrl(method, base.resolve(path));
      if (body != null) {
        request.headers.contentType = ContentType.json;
        request.write(jsonEncode(body));
      }
      final response = await request.close();
      final text = await utf8.decodeStream(response);
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException('$method $path: ${response.statusCode} $text');
      }
      return jsonDecode(text) as Map<String, dynamic>;
    } finally {
      client.close();
    }
  }

  /// Mines [blocks] blocks to [address], or to the Core wallet.
  Future<void> mine(int blocks, {String address = ''}) =>
      _call('POST', '/regtest/mine', {'blocks': blocks, 'address': address});

  /// Pays [amountBtc] to [address] from the Core wallet and returns the txid.
  Future<String> send(String address, String amountBtc) async =>
      (await _call('POST', '/regtest/send', {'address': address, 'amount_btc': amountBtc}))['txid'] as String;

  /// A new address of the Core wallet.
  Future<String> newAddress() async => (await _call('GET', '/regtest/newaddress'))['address'] as String;

  /// The txids in the regtest mempool.
  Future<List<String>> mempool() async {
    final client = HttpClient();
    try {
      final response = await (await client.getUrl(base.resolve('/mempool/txids'))).close();
      return (jsonDecode(await utf8.decodeStream(response)) as List).cast<String>();
    } finally {
      client.close();
    }
  }
}
