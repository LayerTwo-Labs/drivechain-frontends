import 'package:faucet/api/api_base.dart';
import 'package:faucet/env.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class APILive extends API {
  Logger get log => GetIt.I.get<Logger>();

  APILive() {
    clients = ServiceClients.setup(
      baseUrl: Environment.baseUrl,
    );
  }
}
