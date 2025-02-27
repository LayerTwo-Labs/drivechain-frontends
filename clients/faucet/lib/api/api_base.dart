import 'package:connectrpc/protobuf.dart';
import 'package:connectrpc/protocol/connect.dart' as protocol;
import 'package:connectrpc/web.dart';

import 'package:faucet/gen/faucet/v1/faucet.connect.client.dart';
import 'package:faucet/gen/explorer/v1/explorer.connect.client.dart';

/// RPC connection to the mainchain node.
abstract class API {
  late ServiceClients clients;

  API();
}

class ServiceClients {
  final FaucetServiceClient faucet;
  final ExplorerServiceClient explorer;

  ServiceClients._({
    required this.faucet,
    required this.explorer,
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
      explorer: ExplorerServiceClient(transport),
    );
  }
}
