//
//  Generated code. Do not modify.
//  source: faucet/v1/faucet.proto
//

import 'package:connectrpc/connect.dart' as connect;
import 'package:faucet/gen/faucet/v1/faucet.pb.dart' as faucetv1faucet;
import 'package:faucet/gen/faucet/v1/faucet.connect.spec.dart' as specs;

extension type FaucetServiceClient (connect.Transport _transport) {
  Future<faucetv1faucet.DispenseCoinsResponse> dispenseCoins(
    faucetv1faucet.DispenseCoinsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.FaucetService.dispenseCoins,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<faucetv1faucet.ListClaimsResponse> listClaims(
    faucetv1faucet.ListClaimsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.FaucetService.listClaims,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
