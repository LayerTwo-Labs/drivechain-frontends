import 'package:faucet_client/api/api.dart';
import 'package:faucet_client/gen/bitcoin/bitcoind/v1alpha/bitcoin.pb.dart';

class MockAPI implements API {
  @override
  Future<String> claim(String address, double amount) async {
    return 'txid';
  }

  @override
  Future<List<GetTransactionResponse>> listClaims() async {
    return [];
  }

  @override
  String get host => 'localhost';

  @override
  int? get port => null;
}
