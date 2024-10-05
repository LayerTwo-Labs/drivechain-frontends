import 'package:faucet/gen/faucet/v1/faucet.pbgrpc.dart';
import 'package:grpc/grpc.dart';
import 'package:grpc/grpc_or_grpcweb.dart';

/// RPC connection to the mainchain node.
abstract class API {
  late ServiceClients clients;

  API();

  CallOptions createOptions();
}

CallOptions getCallOptions({
  Duration? timeout,
  Map<String, String>? metadata,
  List<MetadataProvider>? providers,
}) {
  return CallOptions(
    timeout: timeout,
    metadata: metadata,
    providers: providers,
  );
}

class ServiceClients {
  final FaucetServiceClient faucet;

  ServiceClients._({
    required this.faucet,
  });

  factory ServiceClients.setup({
    required GrpcOrGrpcWebClientChannel channel,
    required CallOptions callOptions,
    required List<ClientInterceptor> Function() interceptorFactory,
  }) {
    return ServiceClients._(
      faucet: FaucetServiceClient(channel, options: callOptions, interceptors: interceptorFactory()),
    );
  }
}
