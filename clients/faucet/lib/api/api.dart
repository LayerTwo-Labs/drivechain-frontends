import 'package:faucet/api/api_base.dart';
import 'package:faucet/env.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:grpc/grpc_or_grpcweb.dart';
import 'package:logger/logger.dart';

class APILive extends API {
  Logger get log => GetIt.I.get<Logger>();

  APILive() {
    final channel = getClientChannel();

    clients = ServiceClients.setup(
      channel: channel,
      callOptions: createOptions(),
      interceptorFactory: () => [PathInterceptor()],
    );
  }

  @override
  CallOptions createOptions() {
    final timeout = Duration(
      seconds: 3,
    );
    final providers = [
      (metadata, uri) async {},
    ];
    try {
      return getCallOptions(
        timeout: timeout,
        providers: providers,
      );
    } catch (error) {
      log.e('could not create callOptions: ${error.toString()}');
      return CallOptions();
    } finally {}
  }
}

GrpcOrGrpcWebClientChannel getClientChannel() {
  return GrpcOrGrpcWebClientChannel.toSingleEndpoint(
    host: Environment.apiHost,
    port: Environment.apiPort,
    transportSecure: Environment.grpcSSL,
  );
}

String extractGRPCError(
  Object error,
) {
  const messageIfUnknown = "We couldn't figure out exactly what went wrong. Reach out to the devs.";

  if (error is GrpcError) {
    return error.message ?? messageIfUnknown;
  } else if (error is String) {
    return error.toString();
  } else {
    return messageIfUnknown;
  }
}

class PathInterceptor extends ClientInterceptor {
  @override
  ResponseFuture<R> interceptUnary<Q, R>(
    ClientMethod<Q, R> method,
    Q request,
    CallOptions options,
    ClientUnaryInvoker<Q, R> invoker,
  ) {
    final modifiedMethod = ClientMethod<Q, R>(
      '/api${method.path}',
      method.requestSerializer,
      method.responseDeserializer,
    );

    final response = invoker(modifiedMethod, request, options);

    return response;
  }
}
