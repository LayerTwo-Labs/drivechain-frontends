import 'dart:async';
import 'dart:convert';

import 'package:faucet_client/gen/bitcoin/bitcoind/v1alpha/bitcoin.pb.dart';
import 'package:faucet_client/gen/google/protobuf/timestamp.pb.dart';
import 'package:fixnum/fixnum.dart';
import 'package:http/http.dart' as http;
import 'package:sail_ui/sail_ui.dart';

/// RPC connection to the mainchain node.
abstract class API {
  final String apiURL;

  API({required this.apiURL});

  Future<List<GetTransactionResponse>> listClaims();
  Future<String> claim(String address, double amount);
}

class APILive extends API {
  APILive({required super.apiURL});

  @override
  Future<List<GetTransactionResponse>> listClaims() async {
    final url = Uri.parse('$apiURL/listclaims');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      return parseClaims(res.body);
    } else {
      throw Exception('could not list claims');
    }
  }

  @override
  Future<String> claim(String address, double amount) async {
    amount = cleanAmount(amount);

    final url = Uri.parse('$apiURL/claim');

    Map<String, dynamic> requestBody = {
      'destination': address.trim(),
      'amount': amount.toString().trim(),
    };

    final res = await http.post(
      url,
      body: json.encode(requestBody),
    );

    if (res.statusCode == 200) {
      final jsonResponse = json.decode(res.body);
      final txid = jsonResponse['txid'];
      return txid;
    } else {
      throw Exception(res.body);
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
