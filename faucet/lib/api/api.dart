import 'package:faucet/api/api_base.dart';
import 'package:faucet/env.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class APILive extends API {
  Logger get log => GetIt.I.get<Logger>();

  APILive() {
    clients = ServiceClients.setup(
      baseUrl: Environment.baseUrl,
    );
  }

  @override
  Future<dynamic> callRAW(String url, String service, [String body = '{}']) async {
    try {
      final response = await http.post(
        Uri.parse('${Environment.baseUrl}/$service/$url'),
        headers: {
          'content-type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode != 200) {
        throw Exception('Request failed: ${response.body}');
      }

      return response.body;
    } catch (e) {
      rethrow;
    }
  }

  @override
  List<String> getMethods() {
    return [
      'GetBlockHeaderInfo',
      'GetBlockInfo',
      'GetBmmHStarCommitment',
      'GetChainInfo',
      'GetChainTip',
      'GetCoinbasePSBT',
      'GetCtip',
      'GetSidechainProposals',
      'GetSidechains',
      'GetTwoWayPegData',
      'SubscribeEvents',
      'SubscribeHeaderSyncProgress',
    ];
  }
}
