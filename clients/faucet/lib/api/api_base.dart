import 'package:connectrpc/protobuf.dart';
import 'package:connectrpc/protocol/connect.dart' as protocol;
import 'package:connectrpc/web.dart';

import 'package:faucet/gen/faucet/v1/faucet.connect.client.dart';

/// RPC connection to the mainchain node.
abstract class API {
  late ServiceClients clients;

  API();
}

class ServiceClients {
  final FaucetServiceClient faucet;

  ServiceClients._({
    required this.faucet,
  });

  factory ServiceClients.setup({
    required String baseUrl,
  }) {
    final httpClient = createHttpClient();
    var transport = protocol.Transport(
      baseUrl: baseUrl,
      codec: const JsonCodec(),
      httpClient: httpClient,
      useHttpGet: true,
    );
    return ServiceClients._(
      faucet: FaucetServiceClient(transport),
    );
  }
}
