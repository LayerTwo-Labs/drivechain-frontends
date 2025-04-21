import 'package:faucet/api/api_base.dart';

class MockAPI implements API {
  @override
  ServiceClients clients = ServiceClients.setup(
    baseUrl: 'http://127.0.0.1:8080',
  );
}
