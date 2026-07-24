import 'dart:io';

import 'package:bitwindow/services/bitmessage_transport.dart';
import 'package:http/io_client.dart';
import 'package:socks5_proxy/socks_client.dart';

BitMessageHttpDialer createTorBitMessageDialer({
  String proxyHost = '127.0.0.1',
  int proxyPort = 19050,
}) {
  final address = InternetAddress.tryParse(proxyHost);
  if (address == null || !address.isLoopback) {
    throw ArgumentError.value(
      proxyHost,
      'proxyHost',
      'the BitNames Tor proxy must be a loopback address',
    );
  }
  if (proxyPort < 1 || proxyPort > 65535) {
    throw ArgumentError.value(proxyPort, 'proxyPort', 'must be a valid port');
  }

  final nativeClient = HttpClient();
  SocksTCPClient.assignToHttpClient(nativeClient, [
    ProxySettings(address, proxyPort),
  ]);
  return DirectBitMessageHttpDialer(client: IOClient(nativeClient));
}
