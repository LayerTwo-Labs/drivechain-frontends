import 'dart:async';
import 'dart:convert';

import 'package:faucet_client/gen/bitcoin/bitcoind/v1alpha/bitcoin.pb.dart';
import 'package:faucet_client/gen/faucet/v1/faucet.pbgrpc.dart';
import 'package:faucet_client/gen/google/protobuf/timestamp.pb.dart';
import 'package:fixnum/fixnum.dart';
import 'package:get_it/get_it.dart';
import 'package:grpc/grpc.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

/// RPC connection to the mainchain node.
abstract class API {
  final String host;
  final int? port;

  API({
    required this.host,
    this.port = 443,
  });

  Future<List<GetTransactionResponse>> listClaims();
  Future<String> claim(String address, double amount);
}

class APILive extends API {
  Logger get log => GetIt.I.get<Logger>();
  late final FaucetServiceClient _client;

  APILive({
    required String host,
    int? port,
  }) : super(host: host, port: port) {
    bool ssl = false;
    if (host.contains('https://')) {
      ssl = true;
    }

    final channel = ClientChannel(
      host,
      port: port ?? 443,
      options: ChannelOptions(
        credentials: ssl ? ChannelCredentials.secure() : ChannelCredentials.insecure(),
      ),
    );

    _client = FaucetServiceClient(channel);
  }
  String get apiURL => port == null ? host : '$host:$port';

  @override
  Future<List<GetTransactionResponse>> listClaims() async {
    try {
      return (await _client.listClaims(ListClaimsRequest())).transactions;
    } catch (e) {
      final error = 'could not list claims: ${extractGRPCError(e)}';
      log.e(error);
      throw Exception(error);
    }
  }

  @override
  Future<String> claim(String address, double amount) async {
    amount = cleanAmount(amount);

    try {
      await _client.dispenseCoins(
        DispenseCoinsRequest()
          ..destination = address
          ..amount = amount,
      );
    } catch (e) {
      final error = 'could not dispense coins: ${extractGRPCError(e)}';
      log.e(error);
      throw Exception(error);
    }
  }
}

List<GetTransactionResponse> parseClaims(String jsonTXs) {
  final List<dynamic> jsonList = json.decode(jsonTXs);
  final transactions = jsonList.map((item) {
    return GetTransactionResponse(
      amount: double.tryParse(item['amount'].toString()),
      fee: double.tryParse(item['fee'].toString()),
      confirmations: int.tryParse(item['confirmations'].toString()),
      blockHash: item['block_hash'],
      blockIndex: int.tryParse(item['block_index'].toString()),
      blockTime: Timestamp(seconds: Int64.tryParseInt(item['block_time']?['seconds']?.toString() ?? '')),
      txid: item['txid'],
      walletConflicts: item['wallet_conflicts'],
      replacedByTxid: item['replaced_by_txid'],
      replacesTxid: item['replaces_txid'],
      time: Timestamp(seconds: Int64.tryParseInt(item['time']?['seconds']?.toString() ?? '')),
      timeReceived: Timestamp(seconds: Int64.tryParseInt(item['time_received']?['seconds']?.toString() ?? '')),
      bip125Replaceable: item['bip125_replaceable'] == 2
          ? GetTransactionResponse_Replaceable.REPLACEABLE_NO
          : GetTransactionResponse_Replaceable.REPLACEABLE_YES,
      details: (item['details'] as List<dynamic>?)?.map(
        (detail) => GetTransactionResponse_Details(
          involvesWatchOnly: detail['involvesWatchOnly'],
          address: detail['address'] ?? '',
          category: GetTransactionResponse_Category.valueOf(detail['category']) ??
              GetTransactionResponse_Category.CATEGORY_UNSPECIFIED,
          amount: double.tryParse(item['amount'].toString()),
          vout: detail['vout'],
        ),
      ),
      hex: item['hex'],
    );
  }).toList();

  return transactions;
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
