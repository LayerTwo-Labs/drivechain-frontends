import 'package:faucet/gen/bitcoin/bitcoind/v1alpha/bitcoin.pb.dart';

/// RPC connection to the mainchain node.
abstract class API {
  final String host;
  final int? port;

  API({
    required this.host,
    this.port = 443,
  });

  Future<List<GetTransactionResponse>> listClaims();
  Future<String?> claim(String address, double amount);
}
