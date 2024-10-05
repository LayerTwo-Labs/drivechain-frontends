import 'dart:async';

import 'package:faucet/api/api_base.dart';
import 'package:faucet/gen/bitcoin/bitcoind/v1alpha/bitcoin.pb.dart';
import 'package:faucet/gen/faucet/v1/faucet.pbgrpc.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc_web.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

class APILive extends API {
  Logger get log => GetIt.I.get<Logger>();
  late final FaucetServiceClient _client;

  APILive({
    required String host,
    int? port,
  }) : super(host: host, port: port) {
    final url = Uri.parse('${host.startsWith('https://') ? host : 'http://$host'}${port != null ? ':$port' : ''}');
    final channel = GrpcWebClientChannel.xhr(
      url,
    );

    _client = FaucetServiceClient(channel);
  }

  String get apiURL => port == null ? host : '$host:$port';

  @override
  Future<List<GetTransactionResponse>> listClaims() async {
    try {
      return (await _client.listClaims(ListClaimsRequest())).transactions;
    } catch (e) {
      final error = 'could not list claims: $e: ${extractGRPCError(e)}';
      log.e(error);
      throw Exception(error);
    }
  }

  @override
  Future<String?> claim(String address, double amount) async {
    amount = cleanAmount(amount);

    try {
      final res = await _client.dispenseCoins(
        DispenseCoinsRequest()
          ..destination = address
          ..amount = amount,
      );
      return res.txid;
    } catch (e) {
      final error = 'could not dispense coins: ${extractGRPCError(e)}';
      log.e(error);
      throw Exception(error);
    }
  }
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
