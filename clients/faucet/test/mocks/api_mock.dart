import 'package:faucet/api/api_base.dart';
import 'package:grpc/grpc.dart';
import 'package:grpc/grpc_or_grpcweb.dart';

class MockAPI implements API {
  @override
  ServiceClients clients = ServiceClients.setup(
    callOptions: CallOptions(timeout: const Duration(seconds: 5)),
    channel: GrpcOrGrpcWebClientChannel.grpc(
      '127.0.0.1',
      port: 8080,
      options: ChannelOptions(
        credentials: ChannelCredentials.insecure(),
      ),
    ),
    interceptorFactory: () => [],
  );

  @override
  CallOptions createOptions() {
    return CallOptions(timeout: const Duration(seconds: 5));
  }
}
